public class skedResourceHandler {
    
    public static void afterInsert(List<sked__Resource__c> newRecords) {
        updateGeoLocation(newRecords);
    }
    
    public static void afterUpdate(List<sked__Resource__c> newRecords, Map<Id, sked__Resource__c> updatedRecords) {
        updateGeoLocation(updatedRecords, newRecords);
        deactivateResources(updatedRecords, newRecords);
    }
    
    private static void updateGeoLocation(List<sked__Resource__c> newRecords) {
        string recordIds = '';
        list<string> resIds = new list<string>();
        for (sked__Resource__c resource : newRecords) {
            if (resource.sked__GeoLocation__Latitude__s == NULL) {
                recordIds += resource.Id + ';';
                resIds.add(resource.id);
            }
        }
        if (resIds.size() > 1) {
            skedFillResourceGeoLocationBatch b = new skedFillResourceGeoLocationBatch(resIds, 'resource');
            Database.executeBatch(b, 10);
        }
        else if (resIds.size() == 1) {
            recordIds = recordIds.substring(0, recordIds.length() - 1);
            skedLocationService.updateGeoLocation(recordIds, 'resource');
        }
    }
    
    private static void updateGeoLocation(Map<Id, sked__Resource__c> updatedRecords, List<sked__Resource__c> newRecords) {
        string recordIds = '';
        list<string> resIds = new list<string>();
        for (sked__Resource__c resource : newRecords) {
            sked__Resource__c oldData = updatedRecords.get(resource.Id);
            if (resource.sked__Home_Address__c != oldData.sked__Home_Address__c ) {
                recordIds += resource.Id + ';';
                resIds.add(resource.id);
            }
        }
        if (resIds.size() > 1) {
            skedFillResourceGeoLocationBatch b = new skedFillResourceGeoLocationBatch(resIds,'resource');
            Database.executeBatch(b,10);
        }
        else if (resIds.size() == 1) {
            recordIds = recordIds.substring(0, recordIds.length() - 1);
            skedLocationService.updateGeoLocation(recordIds, 'resource');
        }
    }

    private static void deactivateResources(Map<Id, sked__Resource__c> updatedRecords, List<sked__Resource__c> newRecords) {
        Set<Id> deactivatedResourceIds = new Set<Id>();
        for (sked__Resource__c newRecord : newRecords) {
            sked__Resource__c oldData = updatedRecords.get(newRecord.Id);
            if (newRecord.Inactive_From__c != oldData.Inactive_From__c && newRecord.Inactive_From__c != NULL) {
                deactivatedResourceIds.add(newRecord.Id);
            }
        }
        List<sked__Job_Allocation__c> skedAllocs = [SELECT Id, sked__Job__r.sked__Start__c, 
                                                    sked__Resource__r.Inactive_From__c
                                                    FROM sked__Job_Allocation__c
                                                    WHERE sked__Resource__c IN :deactivatedResourceIds
                                                    AND sked__Job__r.sked__Start__c >= :system.now()
                                                    AND sked__Status__c != :skedConstants.JOB_ALLOCATION_STATUS_DELETED];
        List<sked__Job_Allocation__c> skedAllocsToUpdate = new List<sked__Job_Allocation__c>();
        for (sked__Job_Allocation__c skedAlloc : skedAllocs) {
            if (skedAlloc.sked__Job__r.sked__Start__c.date() >= skedAlloc.sked__Resource__r.Inactive_From__c) {
                skedAlloc.sked__Status__c = skedConstants.JOB_ALLOCATION_STATUS_DELETED;
                skedAllocsToUpdate.add(skedAlloc);
            }
        }
        if (!skedAllocsToUpdate.isEmpty()) {
            update skedAllocsToUpdate;
        }
    }

}