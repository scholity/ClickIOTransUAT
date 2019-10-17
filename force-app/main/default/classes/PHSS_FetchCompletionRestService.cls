/* @RestResource is used to tell the apex that this class is exposing/consuming the Salesforce API.
    urlMapping - URL of the API that will be used to hit the APEX REST
*/

/* Configuration Required: In Site Public Access Settings, Apex Class Access, insure that this class (PHSS_CancelEnrollmentRestService)
   is added as an allowed class.  
   
   The endpoint for this service is https://<mycommunitydomain>/learner/services/apexrest/PHSS/fetchCompletion/
*/
@RestResource(urlMapping='/PHSS/fetchCompletion')
global without sharing class PHSS_FetchCompletionRestService {
    
    @HttpPost
    global static FetchCompletionResponse fetchCompletion()
    {
        // Parse request
        RestRequest req = RestContext.request;
        RestResponse res = Restcontext.response;        
        
        JSONParser parser = JSON.createParser(RestContext.request.requestBody.toString());
        String orderId;
        String classId;
        String action;
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
                if(parser.getText() == 'action') {
                    parser.nextToken();
                    if(parser.getText() != '') {
                        action = parser.getText();    
                    }
                }
            } 
        }
       
        Status stat;
        FetchCompletion fetchCompletion;
        FetchCompletionResponse fetchCompletionResponse;
        
        // Write request to log 
        Rest_Service_Calls__c serviceLog = new Rest_Service_Calls__c();
        serviceLog.Name = 'PHSS/fetchCompletion';
        serviceLog.Request_Method__c = 'POST';
        serviceLog.Service_Action__c = action;
        serviceLog.Payload__c = req.requestBody.toString();
        insert serviceLog;            
        
        Rest_Service_Calls__c responseLog = new Rest_Service_Calls__c();
        responseLog.Name = 'PHSS/fetchCompletion';   
        responseLog.Request_Method__c = 'POST';
        responseLog.Service_Action__c = action;             
        
        // Code - 1001 - One of the required fields is missing (order id, class id)
        if (String.isBlank(orderId) || String.isBlank(classId)) {
            stat = new Status('One of the required fields is missing',1001);
            fetchCompletion = new FetchCompletion(stat,'','','','','');
            fetchCompletionResponse = new FetchCompletionResponse(fetchCompletion); 
            res.responseBody = Blob.valueOf(JSON.serializePretty(fetchCompletionResponse));
            
            // Write response to log
            responseLog.Response__c = JSON.serialize(fetchCompletionResponse); 
            insert responseLog;  
                        
            return fetchCompletionResponse;           
        }
        else {
            // fetch learning plan for this RCO order/class Id (orders can be many-to-one on class)
            List<redwing__Learning_Assignment__c> lst_la = new List<redwing__Learning_Assignment__c>();
            List<voucher__c> lst_vouchers = new List<voucher__c>();

            lst_vouchers = [SELECT Id, RCO_Order_Id__c, ILT_Class__c, ILT_Class__r.Learning_Plan__c FROM voucher__c
                    WHERE RCO_Order_Id__c = :orderId AND ILT_Class__c = :classId];

            if (lst_vouchers.size() > 0 && lst_vouchers[0].ILT_Class__r.Learning_Plan__c != null) {
                // grab learning plan Id from voucher (should be only one record)
                Id theLearningPlanId = lst_vouchers[0].ILT_Class__r.Learning_Plan__c;
                // fetch all learning assignments with this RCO Order Id and learning plan Id,
                // and of Learning record type 'ILT Class' or 'Media' (could be many others, we don't need them)
                lst_la = [
                        SELECT Id, redwing__Evaluation_Result__c, redwing__Evaluation_Score__c,
                                Grade_Reason__c, Grade_Additional_Info__c, redwing__Progress__c,
                                redwing__Progress_Percentage__c, redwing__Completed_On__c, Learning_Record_Type__c
                        FROM redwing__Learning_Assignment__c
                        WHERE RCO_Order_Id__c = :OrderId AND redwing__Training_Plan__c = :theLearningPlanId AND
                        (Learning_Record_Type__c = 'ILT Class' OR Learning_Record_Type__c = 'Media')];

                // if no learning assignment records found
                if (lst_la.size() == 0) {
                    stat = new Status('No related Learning Assignment record found', 5001);
                    fetchCompletion = new FetchCompletion(stat, '', '', '', '', '');
                    fetchCompletionResponse = new FetchCompletionResponse(fetchCompletion);
                    res.responseBody = Blob.valueOf(JSON.serializePretty(fetchCompletionResponse));

                    // Write response to log
                    responseLog.Response__c = JSON.serialize(fetchCompletionResponse);
                    insert responseLog;

                    return fetchCompletionResponse;
                } else {
                    redwing__Learning_Assignment__c obj_ILTClassLA = new redwing__Learning_Assignment__c();
                    redwing__Learning_Assignment__c obj_MediaLA = new redwing__Learning_Assignment__c();

                    // loop over list and find records of type 'ILT Class' and 'Media', should only be one of each type
                    for (redwing__Learning_Assignment__c obj_la : lst_la) {
                        if (obj_la.Learning_Record_Type__c == 'ILT Class')
                            obj_ILTClassLA = obj_la;
                        if (obj_la.Learning_Record_Type__c == 'Media')
                            obj_MediaLA = obj_la;
                    }

                    String completionStatusILTClass = 'Not Started';
                    String completionDateILTClass = '';
                    String scoreILTClass = '0.00';
                    String completionStatusOnline = 'Not Started';
                    String completionDateOnline = '';
                    String scoreOnline = '0.00';
                    String completionStatus = 'Not Started';
                    String completionDate = '';
                    String score = '0.00';

                    // If record of type ILT Class is available, fetch completion status from the record
                    // Valid completion statuses (mapped to Appinium progress value) are: Successful, Unsuccessful, Cancelled, Suspended, Not Evaluated
                    if (obj_ILTClassLA.Id != NULL) {
                            /*
                            List<redwing__ILT_Session__c> lst_session = [Select Id, redwing__Date__c
                                    From redwing__ILT_Session__c
                                    Where redwing__ILT_Class__c = :classId
                                    Order by redwing__Date__c ASC LIMIT 1];
                            Date todaysDate = Date.Today();
                            if (lst_session.size() > 0 && lst_session[0].redwing__Date__c != null &&
                                lst_session[0].redwing__Date__c > todaysDate ) {
                                completeStatusILTClass = 'Not Evaluated';
                                completionDateILTClass = '';
                                scoreILTClass = '0.00';
                            } else {
                            */
                        completionStatusILTClass = (obj_ILTClassLA.redwing__Progress__c == NULL) ? 'Not Started' : obj_ILTClassLA.redwing__Progress__c;
                        if (completionStatusILTClass == 'Completed') completionStatusILTClass = obj_ILTClassLA.redwing__Evaluation_Result__c;
                        completionDateILTCLass = (obj_ILTClassLA.redwing__Completed_On__c == NULL) ? '' : obj_ILTClassLA.redwing__Completed_On__c.format();
                        scoreILTClass = (obj_ILTClassLA.redwing__Progress_Percentage__c == NULL) ? '0.00' : String.valueOf(obj_ILTClassLA.redwing__Progress_Percentage__c);
                            //}
                    }

                    //else look for record of type Media
                    //else{
                    //if record of type Media available, fetch completion status from the record
                    if (obj_MediaLA.Id != NULL) {
                        completionStatusOnline = obj_MediaLA.redwing__Progress__c == NULL ? 'Not Started' : obj_MediaLA.redwing__Progress__c;
                        if (completionStatusOnline == 'Completed') completionStatusOnline = obj_MediaLA.redwing__Evaluation_Result__c;
                        completionDateOnline = obj_MediaLA.redwing__Completed_On__c == NULL ? '' : obj_MediaLA.redwing__Completed_On__c.format();
                        scoreOnline = obj_MediaLA.redwing__Progress_Percentage__c == NULL ? '0.00' : String.valueOf(obj_MediaLA.redwing__Progress_Percentage__c);
                    }
                    //}

                    // DE1745 - SJC - Transform Not Started into Demandware equivalent Not Registered
                    if (completionStatusILTClass == 'Not Started' && completionStatusOnline == 'Not Started') {
                        completionStatus = 'Not Evaluated';
                    } else {
                        if (completionStatusILTClass != 'Not Started') {
                            completionStatus = completionStatusILTClass;
                            completionDate = completionDateILTClass;
                            score = scoreILTClass;
                        } else {
                            completionStatus = completionStatusOnline;
                            completionDate = completionDateOnline;
                            score = scoreOnline;
                        }
                    }

                    // Code - 100 - Completion data fetched Successful.
                    stat = new Status('Completion data fetch Successful.', 100);
                    fetchCompletion = new FetchCompletion(stat, classId, completionStatus, completionDate, Score, '');
                    fetchCompletionResponse = new FetchCompletionResponse(fetchCompletion);
                    res.responseBody = Blob.valueOf(JSON.serializePretty(fetchCompletionResponse));

                    // Write response to log
                    responseLog.Response__c = JSON.serialize(fetchCompletionResponse);
                    insert responseLog;

                    return fetchCompletionResponse;
                }
            }
            // No learning plan (and therefore no voucher) found for this order/class Id
            stat = new Status('No related voucher or learning plan record found', 5002);
            fetchCompletion = new FetchCompletion(stat, '', '', '', '', '');
            fetchCompletionResponse = new FetchCompletionResponse(fetchCompletion);
            res.responseBody = Blob.valueOf(JSON.serializePretty(fetchCompletionResponse));

            // Write response to log
            responseLog.Response__c = JSON.serialize(fetchCompletionResponse);
            insert responseLog;

            return fetchCompletionResponse;
        }

    }
    
    global class FetchCompletionResponse {
        public FetchCompletion fetchCompletion;
        
        FetchCompletionResponse(FetchCompletion fetchCompletion) {
            this.fetchCompletion = fetchCompletion;
        }
    }
    
    global class FetchCompletion {
        public Status status;
        public String sabaOrderItemId;
        public String completeStatus;
        public String completionDate;
        public String score;
        public String grade;
        
        FetchCompletion(Status stat,String sabaOrderItemId,String completeStatus,String completionDate,String score,String grade) {
            this.status = stat;
            this.sabaOrderItemId = sabaOrderItemId;
            this.completeStatus = completeStatus;
            this.completionDate = completionDate;
            this.score = score;
            this.grade = grade;
        }
    }
 
    global class Status {
        public String description;
        public Integer code;
        
        Status(String descrip, Integer code) {
            this.description = descrip;
            this.code = code;
        }
    }
   
}