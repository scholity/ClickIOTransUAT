/* @RestResource is used to tell the apex that this class is exposing/consuming the Salesforce API.
    urlMapping - URL of the API that will be used to hit the APEX REST
*/

/* Configuration Required: In Site Public Access Settings, Apex Class Access, insure that this class (PHSS_CancelEnrollmentRestService)
   is added as an allowed class.  
   
   The endpoint for this service is https://<mycommunitydomain>/learner/services/apexrest/PHSS/cancelEnrollment/
*/
@RestResource(urlMapping='/PHSS/cancelEnrollment')
global without sharing class PHSS_CancelEnrollmentRestService {
    
    @HttpPost
    global static void cancel()
    {
        // Parse request
        RestRequest req = RestContext.request;
        RestResponse res = Restcontext.response;
        
        // Write request to log 
        String bodyString = req.requestBody.toString();
        Map<String, Object> mapJSONObjects = (Map<String, Object>)JSON.deserializeUntyped(bodyString);      
        String action = (String)mapJSONObjects.get('action');
        
        Rest_Service_Calls__c serviceLog = new Rest_Service_Calls__c();
        serviceLog.Name = 'PHSS/cancelEnrollment';
        serviceLog.Request_Method__c = 'POST';
        serviceLog.Service_Action__c = action;
        serviceLog.Payload__c = bodyString;
        insert serviceLog;    
        
        JSONParser parser = JSON.createParser(RestContext.request.requestBody.toString());
        String orderId;
        String classId;
        String cancelReason;
        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                if(parser.getText() == 'orderID') {
                    parser.nextToken();
                    if(parser.getText() != '') {
                        orderId = parser.getText();    
                    }
                }
                if(parser.getText() == 'classID') {
                    parser.nextToken();
                    if(parser.getText() != '') {
                        classId = parser.getText();    
                    }
                }
                if(parser.getText() == 'cancelReason') {
                    parser.nextToken();
                    if(parser.getText() != '') {
                        cancelReason = parser.getText();    
                    }
                }
            } 
        }
       
        Boolean isStatusSet = false;
        Status stat;
        Id learningPlanId;
        List<redwing__Learning_Assignment__c> assignList = new List<redwing__Learning_Assignment__c>();
        List<redwing__ILT_Roster__c> rosterList = new List<redwing__ILT_Roster__c>();
        List<Voucher__c> voucherList = new List<Voucher__c>();

        // Code - 1004 - One of the required fields is missing (order id, class id)
        if(orderId == null || classId == null) {
            stat = new Status('One of the required fields is missing',1004);
            isStatusSet = true;
        } else {
            // DE2012 - Need to add ILT Class Id/Online Class Id to query to differentiate between
            // multiple classes on same RCO order

            String keyPrefixOnline;
            String keyPrefixILTClass;
            Boolean onlineClass = false;
            Boolean ILTClass = false;

            // Get the value of Online prefix (Learning Object)
            Schema.DescribeSObjectResult ol = redwing__Learning__c.sObjectType.getDescribe();
            keyPrefixOnline = ol.getKeyPrefix();

            // Get the value of Classroom/Blended Class prefix (ILT Class)
            Schema.DescribeSObjectResult cl = redwing__ILT_Class__c.sObjectType.getDescribe();
            keyPrefixILTClass = cl.getKeyPrefix();

            if (classId.substring(0,3) == keyPrefixILTClass) {
                ILTClass = true;

                voucherList = [
                        SELECT Id, RCO_Order_Id__c, ILT_Class__c, Learning_Plan__c, Learning_Plan__r.Classroom_Setting__c
                        FROM Voucher__c
                        WHERE RCO_Order_Id__c = :orderId
                        AND ILT_Class__c = :classId
                ];

                if (!voucherList.isEmpty()) {
                    rosterList = [
                            SELECT Id, redwing__ILT_Class__c, redwing__User__c, RCO_Order_Id__c,
                                    redwing__Learning_Assignment__c, redwing__Status__c
                            FROM redwing__ILT_Roster__c
                            WHERE Voucher_Id__c = :voucherList[0].Id
                    ];
                }
            } else if (classId.substring(0,3) == keyPrefixOnline) {
                onlineClass = true;

                // if(rosterList.isEmpty()) {
                voucherList = [
                        SELECT Id, RCO_Order_Id__c, Online_Class__c, Learning_Plan__c, Learning_Plan__r.Classroom_Setting__c
                        FROM Voucher__c
                        WHERE RCO_Order_Id__c = :orderId
                        AND Online_Class__c = :classId
                ];
                /*
                assignList = [Select Id,redwing__User__c,redwing__Approval_Status__c,External_Id__c,redwing__Training_Plan__c
                        From redwing__Learning_Assignment__c
                        Where RCO_Order_Id__c = :orderId
                        And Learning_Record_Type__c = 'Media'
                ];
                */
            }

            // Code - 4000 - Order Id does not exist (no roster or learning assignement record found)
            if (voucherList.isEmpty()) {
            //if(rosterList.isEmpty() && assignList.isEmpty())
                stat = new Status('Order Id or Class Id does not exist', 4000);
                isStatusSet = true;
            } else {
                /*
                else {
                  //Code if ILT Class does not exist for the class
                  if(!rosterList.isEmpty()){
                        if(rosterList[0].redwing__ILT_Class__c == null) {
                            // Code - 4001 - Class Id does not exist
                            stat = new Status('Class Id does not exist', 4001);
                            isStatusSet = true;
                        }
                */
                learningPlanId = voucherList[0].Learning_Plan__c;
                assignList = [
                        SELECT Id, redwing__Evaluation_Result__c, redwing__Evaluation_Score__c,
                                Grade_Reason__c, Grade_Additional_Info__c, redwing__Progress__c,
                                redwing__Progress_Percentage__c, redwing__Completed_On__c, Learning_Record_Type__c
                        FROM redwing__Learning_Assignment__c
                        WHERE RCO_Order_Id__c = :orderId
                        AND redwing__Training_Plan__c = :learningPlanId
                        AND (Learning_Record_Type__c = 'ILT Class' OR Learning_Record_Type__c = 'Media')
                        AND redwing__Progress__c != 'Cancelled' // Learning Assignment is retained when ILT Class is
                                                                // canceled in order to preserve Roster records
                ];
                //Code 4003 - If roster status is cancelled
                if (assignList.isEmpty()) {
                    //if((!rosterList.isEmpty()) && (rosterList[0].redwing__Status__c == 'Cancelled')) {
                    // Code - 4003 - Student is already canceled from the class
                    stat = new Status('Student is not registered in the class', 4003);
                    isStatusSet = true;
                } else {
                    redwing__Learning_Assignment__c theLearningAssignment = assignList[0];
                    if (theLearningAssignment.redwing__Progress__c == 'Completed') {
                        stat = new Status('Cannot cancel enrollment, course has already been completed', 14002);
                        isStatusSet = true;
                    } else {
                        /*
                            if((!rosterList.isEmpty()) && (rosterList[0].redwing__Learning_Assignment__c != null)){
                            // Code - 14002 - Cannot cancel enrollment, course has already been completed
                            List<redwing__Learning_Assignment__c> la = [Select Id, redwing__Progress__c
                                                                        From redwing__Learning_Assignment__c
                                                                        Where redwing__Progress__c = 'Completed' And
                                                                              (RCO_Order_Id__c = :orderId Or
                                                                               Id = :rosterList[0].redwing__Learning_Assignment__c)];
                            if(!la.isEmpty() && !isStatusSet) {
                                stat = new Status('Cannot cancel enrollment, course has already been completed', 14002);
                                isStatusSet = true;
                            }
                        }
                        }
                        else {
                           List<redwing__Learning_Assignment__c> laas = [Select Id, redwing__Progress__c
                                                                        From redwing__Learning_Assignment__c
                                                                        Where redwing__Progress__c = 'Completed' And
                                                                              (RCO_Order_Id__c = :orderId Or
                                                                               Id = :assignList[0].id)];
                                if(!laas.isEmpty() && !isStatusSet) {
                                stat = new Status('Cannot cancel enrollment, course has already been completed', 14002);
                                isStatusSet = true;
                            }
                        }
                        */

                        // call cancel enrollment
                        //if(!isStatusSet) {
                        // Not yet cancelled

                        // ILT Class (Roster) cancel call
                        //if((!rosterList.isEmpty()) && (rosterList[0].Id != null)) {
                        if (ILTClass && !rosterList.isEmpty()) {
                            PHSS_CancelEnrollmentController.cancelEnrollment(rosterList[0].Id, cancelReason);
                            stat = new Status('Cancellation Successful', 100);
                            res.statusCode = 200;
                        }
                        // Online Learning Assignment cancel call
                        else if (onlineClass) {
                            PHSS_CancelEnrollmentController.cancelEnrollment(assignList[0].Id, cancelReason);
                            stat = new Status('Cancellation Successful', 100);
                            res.statusCode = 200;
                        }
                    }
                    //}
                }
            }
        }
            
        OrderCancellation orderCancel = new OrderCancellation(stat);
        JsonResponse jsonResp = new JSONResponse(orderCancel);    
        res.responseBody = Blob.valueOf(JSON.serializePretty(jsonResp));
        
        // Write response to log 
        Rest_Service_Calls__c responseLog = new Rest_Service_Calls__c();
        responseLog.Name = 'PHSS/cancelEnrollment';  
        responseLog.Request_Method__c = 'POST';
        responseLog.Service_Action__c = action;         
        responseLog.Response__c = JSON.serialize(jsonResp); 
        insert responseLog;                   
    }   
    
    public class JsonResponse {
        OrderCancellation orderCancellation;
        
        JsonResponse(OrderCancellation orderCancel) {
            this.orderCancellation = orderCancel;
        }
    }
    
    public class OrderCancellation {
        Status status;
        
        OrderCancellation(Status stat) {
            this.status = stat;
        }
    }
    
    public class Status {
        public String description;
        public Integer code;
        
        Status(String descrip, Integer code) {
            this.description = descrip;
            this.code = code;
        }
    }
}