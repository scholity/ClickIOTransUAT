public class skedAvailabilityHandler {
    
    public static void beforeInsert(List<sked__Availability__c> newRecords) {
        doFieldHistoryTracking(newRecords);
    }
    
    public static void beforeUpdate(List<sked__Availability__c> newRecords, Map<Id, sked__Availability__c> updatedRecords) {
        doTimezoneChecking(newRecords, updatedRecords);
        doFieldHistoryTracking(newRecords, updatedRecords);
    }

    private static void doTimezoneChecking(List<sked__Availability__c> newRecords, Map<Id, sked__Availability__c> updatedRecords) {
        for (sked__Availability__c newRecord : newRecords) {
            if (string.isBlank(newRecord.sked__Timezone__c)) {
                newRecord.addError('Timezone cannot be empty.');
            }
        }
    }

    private static void doFieldHistoryTracking(List<sked__Availability__c> newRecords) {
        Id userId = UserInfo.getUserId();
        DateTime currentTime = system.now();
        for (sked__Availability__c newRecord : newRecords) {
            newRecord.Status_Updated_By__c = userId;
            newRecord.Status_Updated_At__c = currentTime;
        }
    }
    
    private static void doFieldHistoryTracking(List<sked__Availability__c> newRecords, Map<Id, sked__Availability__c> updatedRecords) {
        Id userId = UserInfo.getUserId();
        DateTime currentTime = system.now();
        for (sked__Availability__c newRecord : newRecords) {
            sked__Availability__c oldData = updatedRecords.get(newRecord.Id);
            if (newRecord.sked__Status__c != oldData.sked__Status__c) {
                newRecord.Status_Updated_By__c = userId;
                newRecord.Status_Updated_At__c = currentTime;
            }
        }
    }

}