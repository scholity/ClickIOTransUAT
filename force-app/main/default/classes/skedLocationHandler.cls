public class skedLocationHandler {
    
    public static void afterInsert(List<sked__Location__c> newRecords) {
        updateGeoLocation(newRecords);
    }
    
    public static void afterUpdate(List<sked__Location__c> newRecords, Map<Id, sked__Location__c> updatedRecords) {
        deactivateLocations(updatedRecords, newRecords);
        updateGeoLocation(updatedRecords, newRecords);
    }
    
    private static void updateGeoLocation(List<sked__Location__c> newRecords) {
        string recordIds = '';
        list<string> resIds = new list<string>();
        for (sked__Location__c location : newRecords) {
            if (location.sked__GeoLocation__Latitude__s == NULL) {
                recordIds += location.Id + ';';
                resIds.add(location.id);
            }
        }
        if (resIds.size() > 1) {
            skedFillResourceGeoLocationBatch b = new skedFillResourceGeoLocationBatch(resIds, 'location');
            Database.executeBatch(b, 10);
        }
        else if (resIds.size() == 1) {
            recordIds = recordIds.substring(0, recordIds.length() - 1);
            skedLocationService.updateGeoLocation(recordIds, 'location');
        }
    }
    
    private static void updateGeoLocation(Map<Id, sked__Location__c> updatedRecords, List<sked__Location__c> newRecords) {
        string recordIds = '';
        list<string> resIds = new list<string>();
        for (sked__Location__c location : newRecords) {
            sked__Location__c oldData = updatedRecords.get(location.Id);
            if (location.sked__Address__c != oldData.sked__Address__c ) {
                recordIds += location.Id + ';';
                resIds.add(location.id);
            }
        }
        if (resIds.size() > 1) {
            skedFillResourceGeoLocationBatch b = new skedFillResourceGeoLocationBatch(resIds,'location');
            Database.executeBatch(b,10);
        }
        else if (resIds.size() == 1) {
            recordIds = recordIds.substring(0, recordIds.length() - 1);
            skedLocationService.updateGeoLocation(recordIds, 'location');
        }
    }

    private static void deactivateLocations(Map<Id, sked__Location__c> updatedRecords, List<sked__Location__c> newRecords) {
        Map<Id, sked__Location__c> mapDeactivatedLocation = new Map<Id, sked__Location__c>();
        for (sked__Location__c newLocation : newRecords) {
            sked__Location__c oldData = updatedRecords.get(newLocation.Id);
            if (oldData.Is_Active__c == TRUE && newLocation.Is_Active__c == FALSE) {
                mapDeactivatedLocation.put(newLocation.Id, newLocation);
            }
        }
        if (!mapDeactivatedLocation.isEmpty()) {
            DateTime currentTime = system.now();
            List<sked__Location__c> locationWithJobs = [SELECT Id,
                                                        (SELECT Id
                                                         FROM sked__Jobs__r
                                                         WHERE (sked__Start__c > :currentTime OR sked__Finish__c > :currentTime)
                                                         AND sked__Job_Status__c != :skedConstants.JOB_STATUS_CANCELLED)
                                                        FROM sked__Location__c
                                                        WHERE Id IN :mapDeactivatedLocation.keySet()];
            for (sked__Location__c locationWithJob : locationWithJobs) {
                if (locationWithJob.sked__Jobs__r != NULL && locationWithJob.sked__Jobs__r.size() > 0) {
                    sked__Location__c deactivatedLocation = mapDeactivatedLocation.get(locationWithJob.Id);
                    deactivatedLocation.addError('Cannot deactivate this facility because this facility has job(s) scheduled in the future.');
                }
            }
        }
    }

}