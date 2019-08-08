public with sharing class PHSS_TriggerDispatcher {
    public static void run(PHSS_TriggerHandler handler) {
        Boolean isDisabled = handler.isDisabled() || PHSS_TriggerUtility.getSettings().AllDisabled__c;
        if(Trigger.isBefore && Trigger.isInsert && !isDisabled) {
            handler.beforeInsert(Trigger.new);
        }
        if(Trigger.isBefore && Trigger.isUpdate && !isDisabled) {
            handler.beforeUpdate(Trigger.newMap, Trigger.oldMap);
        } 
        //if(Trigger.isBefore && Trigger.isDelete && !isDisabled) {
        //    handler.beforeDelete(Trigger.oldMap);
        //}
        if(Trigger.isAfter && Trigger.isInsert && !isDisabled) {
            handler.afterInsert(Trigger.newMap);
        }
        if(Trigger.isAfter && Trigger.isUpdate && !isDisabled) {
            handler.afterUpdate(Trigger.newMap, Trigger.oldMap);
        }
        //if(Trigger.isAfter && Trigger.isDelete && !isDisabled) {
        //    handler.afterDelete(Trigger.oldMap);
        //}
        //if(Trigger.isAfter && Trigger.isUndelete && !isDisabled) {
        //    handler.afterUndelete(Trigger.oldMap);
        //}
    }
}