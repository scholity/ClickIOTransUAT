global class skedCopyCommunityJobBatch implements Database.Batchable<sked__Job__c> {
    
    protected List<sked__Job__c> skedJobs;
    protected Map<Id, sked__Job__c> mapSourceJob;
    protected boolean isIncludingSubclasses;
    protected string timezoneSidId;
    protected integer daysDifferent;
    protected Map<Id, Course_Catalog__c> mapSourceCourseCatalog;
	
    global skedCopyCommunityJobBatch(List<sked__Job__c> inputSkedJobs, List<sked__Job__c> sourceJobs, boolean isIncludingSubclasses, string timezoneSidId, integer daysDifferent) {
        this.skedJobs = inputSkedJobs;
        this.mapSourceJob = new Map<Id, sked__Job__c>(sourceJobs);
        this.isIncludingSubclasses = isIncludingSubclasses;
        this.daysDifferent = daysDifferent;
        this.timezoneSidId = timezoneSidId;
        
        Set<Id> sourceCourseCatalogIds = new Set<Id>();
        for (sked__Job__c sourceJob : sourceJobs) {
            sourceCourseCatalogIds.add(sourceJob.Course_Catalog__c);
        }
        this.mapSourceCourseCatalog = new Map<Id, Course_Catalog__c>([SELECT Id, Name, Number_of_Students__c, Number_of_Instructors__c, 
                                                                      Break_Duration__c, Number_of_Breaks__c,
                                                                      (SELECT Tag__c, Tag__r.Name
                                                                       FROM Course_Catalog_Tags__r)
                                                                      FROM Course_Catalog__c
                                                                      WHERE Id IN :sourceCourseCatalogIds]);
    }
    
    global List<sked__Job__c> start(Database.BatchableContext BC) {
        return this.skedJobs;
    }
    
    global void execute(Database.BatchableContext BC, List<sked__Job__c> copiedJobs) {
        insert copiedJobs;
        
        if (this.isIncludingSubclasses == TRUE) {
            List<sked__Job__c> subClasses = new List<sked__Job__c>();
            for (sked__Job__c copiedJob : copiedJobs) {
                sked__Job__c sourceJob = mapSourceJob.get(copiedJob.Source_Job__c);
                if (sourceJob.Is_Stacked_Class__c == TRUE && sourceJob.sked__Followups__r != NULL) {
                    for (sked__Job__c sourceSubClass : sourceJob.sked__Followups__r) {
                        sked__Job__c subClass = sourceSubClass.clone();
                        subClass.sked__Parent__c = copiedJob.Id;
                        subClass.sked__Start__c = skedDateTimeUtils.addDays(subClass.sked__Start__c, daysDifferent, timezoneSidId);
                        subClass.sked__Finish__c = skedDateTimeUtils.addDays(subClass.sked__Finish__c, daysDifferent, timezoneSidId);
                        subClass.sked__Job_Status__c = skedConstants.JOB_STATUS_QUEUED;
                        subClass.sked__Recurring_Schedule__c = NULL;
                        subClasses.add(subClass);
                    }
                }
            }
            if (!subClasses.isEmpty()) {
                insert subClasses;
            }
        }
        
        List<sked__Job_Tag__c> copiedJobTags = new List<sked__Job_Tag__c>();
        for (sked__Job__c copiedJob : copiedJobs) {
            Course_Catalog__c skedCourseCatalog = mapSourceCourseCatalog.get(copiedJob.Course_Catalog__c);
            
            for (Course_Catalog_Tag__c courseCatalogTag : skedCourseCatalog.Course_Catalog_Tags__r) {
                sked__Job_Tag__c copiedJobTag = new sked__Job_Tag__c(
                    sked__Job__c = copiedJob.Id,
                    sked__Tag__c = courseCatalogTag.Tag__c
                );
                copiedJobTags.add(copiedJobTag);
            }
        }
        if (!copiedJobTags.isEmpty()) {
            insert copiedJobTags;
        }
        
        skedJobService.validateQueuedJobs(copiedJobs.get(0).sked__Region__c, copiedJobs);
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
}