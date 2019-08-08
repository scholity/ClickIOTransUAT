public class skedCourseCatalogHandler {
    
    public static void beforeUpdate(List<Course_Catalog__c> newRecords, Map<Id, Course_Catalog__c> updatedRecords) {
        deactivateCatalogs(newRecords, updatedRecords);
    }
    
    private static void deactivateCatalogs(List<Course_Catalog__c> newRecords, Map<Id, Course_Catalog__c> updatedRecords) {
        Map<Id, Course_Catalog__c> mapCatalog = new Map<Id, Course_Catalog__c>();
        for (Course_Catalog__c newRecord : newRecords) {
            if (newRecord.Type__c.contains(skedConstants.JOB_TYPE_NURSE_ASSISTANT_TRAINING)) {
                Course_Catalog__c oldData = updatedRecords.get(newRecord.Id);
                if (newRecord.Is_Active__c == FALSE && newRecord.Is_Active__c != oldData.Is_Active__c) {
                    mapCatalog.put(newRecord.Id, newRecord);
                }
            }
        }
        if (!mapCatalog.isEmpty()) {
            DateTime currentTime = system.now();
            List<sked__Job__c> futureJobs = [SELECT Id, Course_Catalog__c
                                             FROM sked__Job__c
                                             WHERE Course_Catalog__c IN :mapCatalog.keySet()
                                             AND sked__Finish__c > :currentTime
                                             AND sked__Job_Status__c != :skedConstants.JOB_STATUS_CANCELLED];
            Set<Id> violatedCatalogIds = new Set<Id>();
            for (sked__Job__c skedJob : futureJobs) {
                violatedCatalogIds.add(skedJob.Course_Catalog__c);
            }
            for (Id catalogId : violatedCatalogIds) {
                Course_Catalog__c violatedCatalog = mapCatalog.get(catalogId);
                violatedCatalog.addError('This Course has classes scheduled in the future, please update these classes to a different course before marking this course as inactive.');
            }
        }
    }

}