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
        List<redwing__Learning_Assignment__c> assignList = new List<redwing__Learning_Assignment__c>();
        // Code - 1004 - One of the required fields is missing (order id, class id)
        if(orderId == null || classId == null) {
            stat = new Status('One of the required fields is missing',1004);
        }
        else {
            List<redwing__ILT_Roster__c> rosterList = [Select Id, redwing__ILT_Class__c, redwing__User__c, RCO_Order_Id__c, 
                                                       redwing__Learning_Assignment__c, redwing__Status__c 
                                                       From redwing__ILT_Roster__c 
                                                       Where RCO_Order_Id__c = :orderId];
            
            
            if(rosterList.isEmpty()) {
                //stat = new Status('Order Id does not exist', 4000);
                   assignList = [Select Id,redwing__User__c,redwing__Approval_Status__c,External_Id__c,redwing__Training_Plan__c 
                                                            From redwing__Learning_Assignment__c 
                                                            Where RCO_Order_Id__c = :orderId and Learning_Record_Type__c = 'Media'];
            }
            // Code - 4000 - Order Id does not exist (no roster or learning assignement record found)
            if(rosterList.isEmpty() && assignList.isEmpty())
            {
                stat = new Status('Order Id does not exist', 4000);
            }
            
            else {
              //Code if ILT Class does not exist for the class
              if(!rosterList.isEmpty()){
                    if(rosterList[0].redwing__ILT_Class__c == null) { 
                        // Code - 4001 - Class Id does not exist
                        stat = new Status('Class Id does not exist', 4001);
                        isStatusSet = true;
                    }
                    
                    
               // Assumption that assignment list does not have class
              /*if(!assignList.isEmpty()){
                if(!assignList[0].External_Id__c.contains('a31'))
                {
                   //stat = new Status('Class Id does not exist', 4001);
                   //isStatusSet = true;
                }
                }*/
                //Code 4003 - If roster status in cancelled 
                else if((!rosterList.isEmpty()) && (rosterList[0].redwing__Status__c == 'Cancelled')) {
                    // Code - 4003 - Student is already canceled from the class
                    stat = new Status('Student is already canceled from the class', 4003);
                    isStatusSet = true;
                }
                else if((!rosterList.isEmpty()) && (rosterList[0].redwing__Learning_Assignment__c != null)){
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
                
                
                // call cancel enrollment 
                if(!isStatusSet) {
                    // Not yet cancelled
                    //Roster cancel call
                    if((!rosterList.isEmpty()) && (rosterList[0].Id != null))
                    {
                    PHSS_CancelEnrollmentController.cancelEnrollment(rosterList[0].Id, cancelReason);
                    stat = new Status('Cancellation Successful',100);
                    res.statusCode = 200;
                    }
                    
                    //Learning Assignment cancel call
                    else 
                    {
                    PHSS_CancelEnrollmentController.cancelEnrollment(assignList[0].id, cancelReason);
                    stat = new Status('Cancellation Successful',100);
                    res.statusCode = 200;
                    }
                   
                    
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