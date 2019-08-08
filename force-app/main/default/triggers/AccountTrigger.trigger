/************************************************************************************************************************************
** Author: Salesforce Services
************************************************************************************************************************************/
trigger AccountTrigger on Account (before insert, before update) {
    if (!PHSS_TriggerSettings__c.getOrgDefaults().AccountTrigger_Disabled__c) {
        AccountTriggerHandler handler = new AccountTriggerHandler();
        if (Trigger.isBefore && Trigger.isInsert) {
            handler.onBeforeInsert(Trigger.new);
        } else if (Trigger.isBefore && Trigger.isUpdate) {
            handler.onBeforeUpdate(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
        }
    }
}