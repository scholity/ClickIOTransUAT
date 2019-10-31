global class skedResolveCommunityJobBatch implements Database.Batchable<sked__Job__c> {
    
    protected string[] jobIds;
    
    global skedResolveCommunityJobBatch(string[] jobIds) {
        this.jobIds = jobIds;
    }
    
    global List<sked__Job__c> start(Database.BatchableContext BC) {        
        List<sked__Job__c> skedJobs = [SELECT Id, Job_Month__c, sked__Region__c 
                                       FROM sked__Job__c 
                                       WHERE Id IN :jobIds];
        return skedJobs;
    }
    
    global void execute(Database.BatchableContext BC, List<sked__Job__c> skedJobs) {
        sked__Job__c firstJob = skedJobs.get(0);
        
        List<sked__Job__c> validatedQueuedJobs = skedJobService.validateQueuedJobsInMonth(firstJob.sked__Region__c, firstJob.Job_Month__c);
        Map<Id, sked__Job__c> mapValidatedQueuedJobs = new Map<Id, sked__Job__c>(validatedQueuedJobs);
        Set<Id> errorRecurringScheduleIds = new Set<Id>();
        for (sked__Job__c validatedQueuedJob : validatedQueuedJobs) {
            if (!string.isBlank(validatedQueuedJob.Copy_Result_Message__c) && validatedQueuedJob.sked__Recurring_Schedule__c != NULL) {
                errorRecurringScheduleIds.add(validatedQueuedJob.sked__Recurring_Schedule__c);
            }
        }
        
        List<sked__Job__c> jobsToUpdate = new List<sked__Job__c>();
        
        for (sked__Job__c skedJob : skedJobs) {
            if (mapValidatedQueuedJobs.containsKey(skedJob.Id)) {
                sked__Job__c validatedQueuedJob = mapValidatedQueuedJobs.get(skedJob.Id);
                if (string.isBlank(validatedQueuedJob.Copy_Result_Message__c) 
                    || (validatedQueuedJob.Copy_Result_Message__c == skedConstants.COMMUNITY_COPY_OUT_OF_MONTH + '. ')) {
                        if (validatedQueuedJob.sked__Recurring_Schedule__c == NULL || !errorRecurringScheduleIds.contains(validatedQueuedJob.sked__Recurring_Schedule__c)) {
                            skedJob.sked__Job_Status__c = skedConstants.JOB_STATUS_PENDING_ALLOCATION;
                            skedJob.Is_Queued__c = FALSE;
                            skedJob.Job_Month__c = NULL;
                            jobsToUpdate.add(skedJob);
                        }
                    }
            }
        }
        if (!jobsToUpdate.isEmpty()) {
            update jobsToUpdate;
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }

}