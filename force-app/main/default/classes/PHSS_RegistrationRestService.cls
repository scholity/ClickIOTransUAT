/* @RestResource is used to tell the apex that this class is exposing/consuming the Salesforce API.
    urlMapping - URL of the API that will be used to hit the APEX REST
*/

/* Configuration Required: In Security Settings for this Apex class (PHSS_RegistrationRestService),
   Enabled Profiles, insure that the System Administrator and Integration User profiles are selected.  
   
   The endpoint for this service is https://<mydomain>/services/apexrest/PHSS/Register/
*/

@RestResource(urlMapping='/PHSS/register')
global without sharing class PHSS_RegistrationRestService {
    
    private redwing__ILT_Class__c theClass;
    
    global class AvailabilityResponseBody {
        @testVisible ValidateCreateOrder validateCreateOrder;
    
        @testVisible
        AvailabilityResponseBody() {
            validateCreateOrder = new ValidateCreateOrder();
        }
    }
      
    global class EnrollResponseBody {
        @testVisible CreateOrder createOrder;
    
        @testVisible
        EnrollResponseBody() {
            createOrder = new CreateOrder();
        }
    }    
          
    global class ErrorResponseBody {
        @testVisible VCOStatus status;
        
        @testVisible
        ErrorResponseBody() {
            status = new VCOStatus();
        }
    }
    
    global class ValidateCreateOrder {
        @testVisible VCOStatus status;
        @testVisible Integer remainingQuantity;
        
        @testVisible
        ValidateCreateOrder() {
            status = new VCOStatus();
            remainingQuantity = 0;
        }
    }
    
    global class VCOStatus {
        @testVisible Integer code;
        @testVisible String description;
       
        @testVisible
        VCOStatus() {
            code = 0;
            description = '';
        }
    }
   
    global class CreateOrder {
        @testVisible List<COCommerceItems> commerceItems;
        @testVisible COStatus status;
        
        @testVisible
        CreateOrder() {
            commerceItems = new List<COCommerceItems>();
            status = new COStatus();
        }
    }
    
    global class COCommerceItems {
        @testVisible String commerceItemId;
        @testVisible String orderItemId;
        
        @testVisible
        COCommerceItems() {
            commerceItemId = '';
            orderItemId = '';
        }
    }
    
    global class COStatus {
        @testVisible Integer code;
        @testVisible String description;
       
        @testVisible
        COStatus() {
            code = 0;
            description = '';
        }
    }
    
    public class JSONavailability {
    
        public String action;
        public String offeringId;
        public Double orderTotal;
        public Double discount;
        public Double listPrice;
        public String orderId;
        public String couponId;
        public String unitCode;
    
        
        public JSONavailability parse(String json) {
            return (JSONavailability) System.JSON.deserialize(json, JSONavailability.class);
        }
    }     
    
    public class JSONenroll {

        public String action;
        public String paymentInformation;
        public Customer customer;
        public String orderId;
        public String couponId;
        public List<CommerceItems> commerceItems;
        public String unitCode;
        
        public JSONenroll parse(String json) {
            return (JSONenroll) System.JSON.deserialize(json, JSONenroll.class);
        }
    }   
    
    public class Customer {
        public String email;
        public String phone;
        public String firstName;
        public String lastName;
    }
            
    public class CommerceItems {
        public String commerceItemId;
        public String offeringId;
        public Double listPrice;
        public Double discount;
        public String itemTotal;
    }
    
    public class JSONEnrollStudentViaVoucher {
        public List<StudentItems> Students;
        
        JSONEnrollStudentViaVoucher() {
            Students = new List<StudentItems>();
        }
    }
    
    public class StudentItems {
        public String FirstName;
        public String LastName;
        public String Email;
        public String Phone;
        public String VoucherId;
        
        @testVisible
        StudentItems() {
            FirstName = '';
            LastName = '';
            Email = '';
            Phone = '';
            VoucherId = '';
        }
    }
    
    // POST request 1 - Check Availability
    @HttpPost 
    global static void processPost() {          
        
        RestRequest  req = RestContext.request;
        RestResponse res = RestContext.response;
            
        ErrorResponseBody httpResponseBody = new ErrorResponseBody();    
        AvailabilityResponseBody availabilityResponseBody = new AvailabilityResponseBody();
        EnrollResponseBody enrollResponseBody = new EnrollResponseBody();  
        // Set default status code (OK)
        Integer statuscode = 0;

        String bodyString = req.requestBody.toString();
        System.debug('===Request Body:'+bodyString);
        
        Map<String, Object> mapJSONObjects = (Map<String, Object>)JSON.deserializeUntyped(bodyString);      
        String action = (String)mapJSONObjects.get('action');
        
        // Write request to log 
        Rest_Service_Calls__c serviceLog = new Rest_Service_Calls__c();
        serviceLog.Name = 'PHSS/register';
        serviceLog.Request_Method__c = 'POST';
        serviceLog.Service_Action__c = action;
        serviceLog.Payload__c = bodyString;
        insert serviceLog;
        
        if (action != null && action == 'availability') {
            JSONavailability parsedJSON = (JSONavailability) System.JSON.deserialize(bodyString, JSONavailability.class);
            String offeringId = parsedJSON.offeringId;
            Double orderTotal = parsedJSON.orderTotal;
            Double discount   = parsedJSON.discount;
            Double listPrice  = parsedJSON.listPrice;
            String orderId    = parsedJSON.orderId;
            String couponId   = parsedJSON.couponId;
            String unitCode   = parsedJSON.unitCode;

            statuscode = 100;
            String jobId = '';
              
            availabilityResponseBody.validateCreateOrder.status.code = statuscode;
            
            // Determine if product is online or classroom (including blended)
            String classroomSetting = '';
            
            // Offering Id: an ILT Class record Id (instructor-led or blended) or a Learning record Id (online)
            Id theOfferingId = offeringId;            
            String objectName = String.valueOf(theOfferingId.getsobjecttype());
            
            // classroomSetting of 'Classroom' applies to both 'Classroom' and 'Online + Classroom' Learning Plans
            if (objectName == 'redwing__ILT_Class__c') classroomSetting = 'Classroom';
            if (objectName == 'redwing__Learning__c') classroomSetting = 'Online'; 
            
            if (classroomSetting == 'Classroom' || classroomSetting == 'Online') {
            
                // Validate class (offeringId = Class Id or Learning Id for a specific SKU)
                
                List<redwing__ILT_Class__c> theClassList = new List<redwing__ILT_Class__c>();
                if (classroomSetting == 'Classroom') theClassList = getClassRecord(offeringId);
                
                if ((classroomSetting == 'Online') || (theClassList != Null && theClassList.size() == 1 && 
                    theClassList[0].Skedulo_Job_Id__c != null && !theClassList[0].redwing__Cancelled__c)) {
             
                    // Verify reservation does not already exist for this basket Id (if so, reset timer)  
                                
                    if (classroomSetting == 'Classroom') jobId = theClassList[0].Skedulo_Job_Id__c;
                    
                    List<Voucher__c> theVouchers = getVouchers(offeringId);
                    
                    Integer seatsOpenInClass = 0; 
                    Integer seatsHeldInClass = 0;
                    Integer seatsReservedInClass = 0;
                    Integer seatsClaimedInClass = 0;
                    
                    // US1494 - Unlimited inventory for online classes
                    Integer seatsAvailableInClass = 0;
                    if (classroomSetting == 'Classroom') {
                        seatsAvailableInClass = getSeatsAvailable(offeringId, jobId);
                    } else seatsAvailableInClass = 999;      
                               
                    Boolean voucherPreviouslyHeld = false;  
                    List<Voucher__c> openVouchers = new List<Voucher__c>();              
                    
                    if (theVouchers != null && theVouchers.size() > 0) {
                        for (Voucher__c theVoucher : theVouchers) {
                            if (theVoucher.Status__c == 'Issued') {
                                openVouchers.add(theVoucher);
                                seatsOpenInClass++;
                            }
                            if (theVoucher.Status__c == 'Temp Hold') {
                                if (theVoucher.RCO_Order_Id__c == orderId) {
                                    voucherPreviouslyHeld = true;
                                }                        
                                seatsHeldInClass++;
                            }
                            if (theVoucher.Status__c == 'Reserved') seatsReservedInClass++;                        
                            if (theVoucher.Status__c == 'Claimed')  seatsClaimedInClass++;
                        } 
                    }
                    
                    if (classroomSetting == 'Online' && seatsOpenInClass == 0 && !voucherPreviouslyHeld) {
                        seatsOpenInClass = 1;
                        // US1494 - Dynamically Create Voucher for Online Class
                        Voucher__c theNewVoucher = new Voucher__c();
                        theNewVoucher.Status__c = 'Issued';
                        theNewVoucher.Online_Class__c = theOfferingId;
                        theNewVoucher.Learning_Plan__c = [Select redwing__Training_Plan_Section__r.redwing__Training_Plan__c From redwing__Training_Plan_Section_Item__c 
                            Where redwing__Learning__c = :theOfferingId Limit 1][0].redwing__Training_Plan_Section__r.redwing__Training_Plan__c;
                        
                        Database.SaveResult srInsert = Database.insert(theNewVoucher);

                        if (srInsert.isSuccess()) {
                            // Operation was successful; retrieve Id of the voucher that was created
                            Id theNewVoucherId = srInsert.getId();
                            openVouchers.add([Select Id, Status__c, Online_Class__c From Voucher__c Where Id = :theNewVoucherId LIMIT 1]);
                        }
                        else {
                            // Could not create voucher, forcing sold out condition for online class
                            seatsOpenInClass = 0;
                        }
            
                    }

                    System.debug('===== Availability Check: Open='+seatsOpenInClass+',Held='+seatsHeldInClass+',Reserved='+seatsReservedInClass+',Claimed='+seatsClaimedInClass);                
                    
                    if (!voucherPreviouslyHeld) {
                    
                        // Assume quantity of one (stub for future support for multiple seats)
                        Integer seatsRequested = 1;
                        
                        if (seatsOpenInClass >= seatsRequested) {               
                            // Hold seat in class (modify voucher for community course with status = 'Temp Hold')
                            // Note: this function returns the number of available seats after reservation has been made                            
                            Integer seatsRemainingInClass = holdSeatsInClass(seatsRequested, openVouchers, orderId, classroomSetting);
                            if (seatsRemainingInClass >= 0) {
                                statuscode = 100;
                                availabilityResponseBody.validateCreateOrder.status.code = statuscode;
                                availabilityResponseBody.validateCreateOrder.status.description = 'Hold Successful';
                                availabilityResponseBody.validateCreateOrder.remainingQuantity = seatsRemainingInClass;
                            } else {
                                statuscode = 41043;
                                availabilityResponseBody.validateCreateOrder.status.code = statuscode;
                                availabilityResponseBody.validateCreateOrder.status.description = 'Seat(s) already sold for this orderId/class';
                            }
                         } else {
                            statuscode = 41043;
                            availabilityResponseBody.validateCreateOrder.status.code = statuscode;
                            availabilityResponseBody.validateCreateOrder.status.description = 'Insufficient Inventory for this orderId/class';       
                         }             
                  
                    
                    } else {
                        statuscode = 100;
                        availabilityResponseBody.validateCreateOrder.status.code = statuscode;
                        availabilityResponseBody.validateCreateOrder.status.description = 'Seat already on hold for this orderId/class';
                    }
                    
                } else {
                    statuscode = 2001;
                    availabilityResponseBody.validateCreateOrder.status.code = statuscode;
                    availabilityResponseBody.validateCreateOrder.status.description = 'Class invalid or cancelled';
                }
                
            } else {
                statuscode = 2001;
                availabilityResponseBody.validateCreateOrder.status.code = statuscode;
                availabilityResponseBody.validateCreateOrder.status.description = 'Class invalid';
            }
            
        } else if (action != null && action == 'enroll') {
        
            JSONenroll parsedJSON = (JSONenroll) System.JSON.deserialize(bodyString, JSONenroll.class);
            String paymentInformation = parsedJSON.paymentInformation;
            String studentEmail       = parsedJSON.customer.email;
            String studentPhone       = parsedJSON.customer.phone;
            String studentFirstName   = parsedJSON.customer.firstName;
            String studentLastName    = parsedJSON.customer.lastName;
            String orderId            = parsedJSON.orderId;
            String couponId           = parsedJSON.couponId;
            List<CommerceItems> 
                        commerceItems = parsedJSON.commerceItems;
            String unitCode           = parsedJSON.unitCode;

            statuscode = 100;
            String jobId = '';
            
            enrollResponseBody.createOrder.status.code = statuscode;    
            
            //Map<Id, redwing__Training_Plan_Section_Item__c> TPSIMap = new Map<Id, redwing__Training_Plan_Section_Item__c>();
            Map<Id, Id> learningPlanMap = new Map<Id, Id>(); 
            Map<Id, String> classroomSettingMap = new Map<Id, String>();
            
            Set<Id> learningIds = new Set<Id>();
            Set<Id> ILTClassIds = new Set<Id>();
            
            String prefixILTClass = redwing__ILT_Class__c.sobjecttype.getDescribe().getKeyPrefix();
            String prefixLearningObject = redwing__Learning__c.sobjecttype.getDescribe().getKeyPrefix();
            
            for (CommerceItems theCommerceItem : commerceItems) {
                if (theCommerceItem.offeringId != null) {
                    if (theCommerceItem.offeringId.substring(0,3) == prefixILTClass) {
                        ILTClassIds.add(theCommerceItem.offeringId);
                    } else if (theCommerceItem.offeringId.substring(0,3) == prefixLearningObject) {
                        learningIds.add(theCommerceItem.offeringId);
                    }
                }
            }

            List<redwing__ILT_Class__c> classList = [Select Id, Learning_Plan__c, Learning_Plan__r.Classroom_Setting__c
                 From redwing__ILT_Class__c
                Where Id In :ILTClassIds];
            
            List<redwing__Training_Plan_Section_Item__c> tpsiList = [Select Id, redwing__Learning__c, 
                          redwing__Training_Plan_Section__r.redwing__Training_Plan__c,
                          redwing__Training_Plan_Section__r.redwing__Training_Plan__r.Classroom_Setting__c
                     From redwing__Training_Plan_Section_Item__c
                    Where redwing__Learning__c In :learningIds];

            
            for (redwing__ILT_Class__c theILTClass : classList) {
                learningPlanMap.put(theILTClass.Id, theILTClass.Learning_Plan__c);
                classroomSettingMap.put(theILTClass.Id, theILTClass.Learning_Plan__r.Classroom_Setting__c);
            }
            
            for (redwing__Training_Plan_Section_Item__c theTPSI : tpsiList) {
                //TPSIMap.put(theTPSI.redwing__Learning__c, theTPSI);
                learningPlanMap.put(theTPSI.redwing__Learning__c, theTPSI.redwing__Training_Plan_Section__r.redwing__Training_Plan__c);
                classroomSettingMap.put(theTPSI.redwing__Learning__c, theTPSI.redwing__Training_Plan_Section__r.redwing__Training_Plan__r.Classroom_Setting__c);
            }
                
            
            // Process each line of order (iterate over commerceItems list) 
            
            for (CommerceItems theCommerceItem : commerceItems) {
                if (theCommerceItem.offeringId != null) {
                    String offeringId = theCommerceItem.offeringId;
                    Id theOfferingId = offeringId;                  
                                        
                    String voucherId = '';
                    Boolean voucherFound = false;
        
                    // Retrieve the voucher(s) which is/are held for this request
                    List<Voucher__c> theVouchers = getVouchers(offeringId);
                    
                    if (theVouchers != null && theVouchers.size() > 0) {
                        for (Voucher__c theVoucher : theVouchers) {
                            if (theVoucher.Status__c == 'Temp Hold') {
                                if (theVoucher.RCO_Order_Id__c == orderId) {
                                    voucherFound = true;
                                    voucherId = String.valueOf(theVoucher.Voucher_Claim__c).subString(0,15);
                                    break;
                                }
                            }
                        }
                    }                       
    
                    if (voucherFound) {
                        // Create JSON request to add student via voucher
                        JSONWrapper.Students student = new JSONWrapper.Students();
                        List<JSONWrapper.Students> studentList = new List<JSONWrapper.Students>();
                        
                        student.FirstName = studentFirstName;
                        student.LastName = studentLastName;
                        student.Email = studentEmail;
                        student.Phone = studentPhone;
                        student.voucherid = voucherId;
                        student.Rosterid = '';
                        studentList.add(student);
            
                        // Enroll the student in the class                          
                        
                        String JSONStudentList = JSON.serialize(studentList);
                        System.debug('=======JSONAddStudents:'+JSONStudentList);
                        
                        try {         
                            Id theLearningPlanId = learningPlanMap.get(offeringId);
                            String theClassroomSetting = classroomSettingMap.get(offeringId);
                            //redwing__Training_Plan_Section_Item__c theTPSI = TPSIMap.get(offeringId); 
                            
                            System.debug('====== LearningPlanId:'+theLearningPlanId);
                            
                            if (theLearningPlanId != null) {                                        
                                ILTInstructorCommunity.enrollStudents(JSONStudentList, theLearningPlanId, theClassroomSetting, orderId); // Enroll this student 
                                statuscode = 100;
                                enrollResponseBody.createOrder.status.description = 'Enrollment Successful'; 
                            } else {
                                statuscode = 2001;
                                enrollResponseBody.createOrder.status.description = 'Class invalid or cancelled'; 
                            }                           
                                                                        
                        } catch (exception e) {
                            String exceptionMessage = e.getMessage();
                            if (exceptionMessage.contains('You are already assigned to this class')) {
                                statuscode = 41056;
                                enrollResponseBody.createOrder.status.description = 'You are already assigned to this class'; 
                            } else if (exceptionMessage.contains('Invalid Voucher') || exceptionMessage.contains('Voucher already Claimed')) {
                                statuscode = 9999;
                                enrollResponseBody.createOrder.status.description = 'Internal Voucher Error'; 
                            } 
                            enrollResponseBody.createOrder.status.code = statuscode;
                            break;                              
                        }           
                    } else {
                        // Voucher not found for this orderId

                        statuscode = 9999;
                        enrollResponseBody.createOrder.status.code = statuscode;
                        enrollResponseBody.createOrder.status.description = 'Reservation not found for this orderId/class';         
                    } 

                } // offering Id != null
            } // next CommerceItem
        } else { // no action match
            statuscode = 500;
            httpResponseBody.status.code = statuscode;
            httpResponseBody.status.description = 'Unsupported action';
        }
        
        if (statuscode != 500) {
            Rest_Service_Calls__c responseLog = new Rest_Service_Calls__c();
            responseLog.Name = 'PHSS/register';  
            responseLog.Request_Method__c = 'POST';
            responseLog.Service_Action__c = action; 
                        
            if (action == 'availability') {
                res.responseBody = Blob.valueOf(JSON.serialize(availabilityResponseBody));
                responseLog.Response__c = JSON.serialize(availabilityResponseBody);                     
            } else {
                res.responseBody = Blob.valueOf(JSON.serialize(enrollResponseBody));
                responseLog.Response__c = JSON.serialize(enrollResponseBody);               
            }
            res.statusCode = 200;            
        
            // Write response to log 
            insert responseLog;            
            
        } else {
            //res.responseBody = Blob.valueOf(e.getMessage());
            res.responseBody = Blob.valueOf(JSON.serialize(httpResponseBody));
            res.statusCode = 500;
        }     
   }
   
   private static List<redwing__ILT_Class__c> getClassRecord(String recordId) { 
       
        List<redwing__ILT_Class__c> theClassList = [Select Id, Name, Learning_Plan__c, 
                          redwing__Max_Seats__c, redwing__Cancelled__c, Skedulo_Job_Id__c 
                          From redwing__ILT_Class__c Where Id = :recordId Limit 1];
                              
        return theClassList;
   }
   
   private static List<Voucher__c> getVouchers(String recordId) {
   
       List<Voucher__c> theVoucherList = [Select Id, Name, Status__c, Learning_Plan__c, ILT_Class__c, RCO_Order_Id__c, Voucher_Claim__c 
                              From Voucher__c Where ILT_Class__c = :recordId Or Online_Class__c = :recordId];
                              
       return theVoucherList;
       
   }
   
   private static Integer getSeatsAvailable(String recordId, String jobId) {
       
       Integer seatsAvailable = 0;
       List<sked__Job__c> skeduloJobList = [Select Number_of_Students__c from sked__Job__c Where Id = :jobId Limit 1];
       
       if (skeduloJobList != null && skeduloJobList.size() > 0) seatsAvailable = Integer.valueOf(skeduloJobList[0].Number_of_Students__c);
       
       return seatsAvailable;
   }
   
   private static Integer holdSeatsInClass(Integer numberOfSeats, List<Voucher__c> openVouchers, String orderId, String classroomSetting) {
       List<Voucher__c> heldVoucherList = new List<Voucher__c>();
       
       Integer numberOfOpenSeats = openVouchers.size();
       Integer numberOfRemainingSeatsToHold = numberOfSeats;
       Integer openVoucherIndex = 0;
       
       while (numberOfRemainingSeatsToHold >= 1) {
            if (openVoucherIndex < numberOfOpenSeats) {
                   Voucher__c theVoucher = openVouchers[openVoucherIndex];
                   
                   // Hold a seat for this eCommerce order (cart)
                   theVoucher.Status__c = 'Temp Hold';
                   theVoucher.RCO_Order_Id__c = orderId;
                   theVoucher.RCO_Reservation_Timestamp__c = DateTime.Now().addMinutes(-45);
                   
                   heldVoucherList.add(theVoucher);
                   
                   ++openVoucherIndex;
                   --numberOfRemainingSeatsToHold;
                   --numberOfOpenSeats;
            } else {
                   return -1; // Should never occur - force error condition
            }      
       }
       
       try {
           Database.update(heldVoucherList);
       } catch (exception e) {
       
       }
   
       return (classroomSetting == 'Online') ? 999 : numberOfOpenSeats;
   }
}