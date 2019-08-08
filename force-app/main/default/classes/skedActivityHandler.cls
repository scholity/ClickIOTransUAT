public class skedActivityHandler {
    
    public static void afterInsert(List<sked__Activity__c> newRecords) {
        updateResourceScheduledHours(newRecords);
    }

    public static void beforeUpdate(List<sked__Activity__c> newRecords, Map<Id, sked__Activity__c> updatedRecords) {
        doTimezoneChecking(newRecords, updatedRecords);
    }
    
    public static void afterUpdate(List<sked__Activity__c> newRecords, Map<Id, sked__Activity__c> updatedRecords) {
        updateResourceScheduledHours(updatedRecords, newRecords);
    }
    
    public static void afterDelete(List<sked__Activity__c> deletedRecords, Map<Id, sked__Activity__c> recordMap) {
        updateResourceScheduledHours(recordMap.values());
    }

    private static void doTimezoneChecking(List<sked__Activity__c> newRecords, Map<Id, sked__Activity__c> updatedRecords) {
        for (sked__Activity__c newRecord : newRecords) {
            if (string.isBlank(newRecord.sked__Timezone__c)) {
                newRecord.addError('Timezone cannot be empty.');
            }
        }
    }
    
    private static void updateResourceScheduledHours(List<sked__Activity__c> newRecords) {
        Set<Id> resourceIds = new Set<Id>();
        for (sked__Activity__c newRecord : newRecords) {
            resourceIds.add(newRecord.sked__Resource__c);
        }
        skedUtils.updateResourceScheduledHours(resourceIds);
    }

    private static void updateResourceScheduledHours(Map<Id, sked__Activity__c> updatedRecords, List<sked__Activity__c> newRecords) {
        Set<Id> resourceIds = new Set<Id>();
        for (sked__Activity__c newRecord : newRecords) {
            sked__Activity__c oldData = updatedRecords.get(newRecord.Id);
            if (newRecord.sked__Start__c != oldData.sked__Start__c || newRecord.sked__End__c != oldData.sked__End__c) {
                resourceIds.add(newRecord.sked__Resource__c);
            }
        }
        if (!resourceIds.isEmpty()) {
            skedUtils.updateResourceScheduledHours(resourceIds);
        }
    }
    
}