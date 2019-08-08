global virtual class skedSkeduloApiManager {
    
    public static final string DISPATCH_ENDPOINT = 'https://app.skedulo.com/dispatch'; 
    
    public static void dispatchJobs(Set<Id> jobIds) {
        List<sked__Job__c> skedJobs = [SELECT Id, Name, Skedulo_API_Error__c, Skedulo_API_Error_Message__c,
                                       (SELECT Id, sked__Job__c, sked__Resource__c, sked__Status__c
                                        FROM sked__Job_Allocations__r
                                        WHERE sked__Status__c != :skedConstants.JOB_ALLOCATION_STATUS_DELETED)
                                       FROM sked__Job__c
                                       WHERE Id IN :jobIds];
        List<sked__Job_Allocation__c> skedAllocationsToUpdate = new List<sked__Job_Allocation__c>();
        for (sked__Job__c skedJob : skedJobs) {
            skedSkeduloApiData.dispatchJobResult result = dispatchJob(skedJob.Id);
            if (result.success == false) {
                skedJob.Skedulo_API_Error_Message__c += 'Error Code: ';
                skedJob.Skedulo_API_Error_Message__c += result.message;
                skedJob.Skedulo_API_Error_Message__c += '\n';
            }
            else {
                skedJob.sked__Job_Status__c = skedConstants.JOB_STATUS_DISPATCHED;
                for (sked__Job_Allocation__c skedAllocation : skedJob.sked__Job_Allocations__r) {
                    string resourceResponseString = Json.serialize(result.data.get(skedAllocation.sked__Resource__c));
                    skedSkeduloApiData.dispatchJobData allocResponse = (skedSkeduloApiData.dispatchJobData)Json.deserialize(resourceResponseString, skedSkeduloApiData.dispatchJobData.class);
                    
                    if (allocResponse.success == FALSE) {
                        skedAllocation.Skedulo_API_Error__c = TRUE;
                        skedAllocation.Skedulo_API_Error_Message__c = '';
                        if (!string.isBlank(allocResponse.errorCode)) {
                            skedAllocation.Skedulo_API_Error_Message__c += 'Error Code: ';
                            skedAllocation.Skedulo_API_Error_Message__c += allocResponse.errorCode;
                            skedAllocation.Skedulo_API_Error_Message__c += '\n';
                        }
                        if (!string.isBlank(allocResponse.errorMessage)) {
                            skedAllocation.Skedulo_API_Error_Message__c += 'Error Message: ';
                            skedAllocation.Skedulo_API_Error_Message__c += allocResponse.errorMessage;
                        }
                    }
                    skedAllocation.sked__Status__c = skedConstants.JOB_ALLOCATION_STATUS_DISPATCHED;
                    skedAllocationsToUpdate.add(skedAllocation);
                }
            }
        }
        update skedJobs;
        if (!skedAllocationsToUpdate.isEmpty()) {
            update skedAllocationsToUpdate;
        }
    }

    public static void dispatchJobAllocations(Set<Id> jobAllocationIds) {
        List<sked__Job_Allocation__c> skedAllocations = [SELECT Id, sked__Job__c, sked__Resource__c, 
                                                         sked__Status__c
                                                         FROM sked__Job_Allocation__c
                                                         WHERE Id IN :jobAllocationIds];
        Set<Id> jobIdsToUpdateStatus = new Set<Id>();
        for (sked__Job_Allocation__c skedAllocation : skedAllocations) {
            skedSkeduloApiData.dispatchJobResult result = dispatchJob(skedAllocation.sked__Job__c, skedAllocation.sked__Resource__c);
            if (result.success == TRUE) {
                string resourceResponseString = Json.serialize(result.data.get(skedAllocation.sked__Resource__c));
                skedSkeduloApiData.dispatchJobData allocResponse = (skedSkeduloApiData.dispatchJobData)Json.deserialize(resourceResponseString, skedSkeduloApiData.dispatchJobData.class);
                
                if (allocResponse.success == FALSE) {
                    skedAllocation.Skedulo_API_Error__c = TRUE;
                    skedAllocation.Skedulo_API_Error_Message__c = '';
                    if (!string.isBlank(allocResponse.errorCode)) {
                        skedAllocation.Skedulo_API_Error_Message__c += 'Error Code: ';
                        skedAllocation.Skedulo_API_Error_Message__c += allocResponse.errorCode;
                        skedAllocation.Skedulo_API_Error_Message__c += '\n';
                    }
                    if (!string.isBlank(allocResponse.errorMessage)) {
                        skedAllocation.Skedulo_API_Error_Message__c += 'Error Message: ';
                        skedAllocation.Skedulo_API_Error_Message__c += allocResponse.errorMessage;
                    }
                }
                else {
                    jobIdsToUpdateStatus.add(skedAllocation.sked__Job__c);
                }
            }
        }
        update skedAllocations;

        if (!jobIdsToUpdateStatus.isEmpty()) {
            skedJobService.updateJobStatus(jobIdsToUpdateStatus);
        }
    }
    
    public static skedSkeduloApiData.dispatchJobResult dispatchJob(Id jobId) {
        return dispatchJob(jobId, null);
    }

    public static skedSkeduloApiData.dispatchJobResult dispatchJob(Id jobId, Id resourceId) {
        sked_Admin_Setting__c skeduloApiSetting = sked_Admin_Setting__c.getOrgDefaults();
        
        string endPoint = DISPATCH_ENDPOINT;
        string jobParams = EncodingUtil.urlEncode(jobId, 'UTF-8');
        endPoint = endPoint + '?job=' + jobParams;
        if (!string.isBlank(resourceId)) {
            string resourceParams = EncodingUtil.urlEncode(resourceId, 'UTF-8');
            endPoint = endPoint + '&resource=' + resourceParams;
        }
        string httpMethod = 'POST';
        
        Map<string, string> mapHeader = new Map<string, string>();
        mapHeader.put('Content-Type', 'application/x-www-form-urlencoded');
        mapHeader.put('apiToken', skeduloApiSetting.API_Token__c);
        
        dispatchJobAction action = new dispatchJobAction();
        skedSkeduloApiData.dispatchJobResult result = (skedSkeduloApiData.dispatchJobResult)action.execute(endPoint, httpMethod, mapHeader, '');
        
        return result;
    }
    
    /*************************************************Nested classes*******************************************************/
    global class dispatchJobAction extends actionBase {
        protected override skedCalloutResultBase initializeResult() {
            return new skedSkeduloApiData.dispatchJobResult();
        }
        
        protected override skedCalloutResultBase processResponse(string response) {
            skedSkeduloApiData.dispatchJobResult result = new skedSkeduloApiData.dispatchJobResult();
            Map<string, object> deserializedResponse = (Map<string, object>)Json.deserializeUntyped(response);
            result.data = (Map<string, object>)deserializedResponse.get('results');
            return result;
        }
    }
    
    global virtual class actionBase extends skedCalloutActionBase {
        protected override skedCalloutResultBase doExecute(string endPoint, string httpMethod, Map<string, string> mapHeader, string body) {
            skedCalloutResultBase result;
            try {
                result = super.doExecute(endPoint, httpMethod, mapHeader, body);
                result.success = true;
            }
            catch (skedCalloutException ex) {
                result = initializeResult();
                result.success = false;
                result.message = ex.response;
            }
            catch (Exception ex) {
                result = initializeResult();
                result.success = false;
                result.message = ex.getMessage() + ' - ' + ex.getStackTraceString();
            }
            return result;
        }
    }

}