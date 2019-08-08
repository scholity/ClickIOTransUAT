/************************************************************************************************************************************
** Author: Salesforce Services
************************************************************************************************************************************/
trigger UserTrigger on User (after insert, after update) {
	if (!PHSS_TriggerSettings__c.getOrgDefaults().UserTrigger_Disabled__c) {
        UserTriggerHandler handler = new UserTriggerHandler();
        if (Trigger.isAfter && Trigger.isInsert) {
            handler.onAfterInsert(Trigger.new);
        } else if (Trigger.isAfter && Trigger.isUpdate) {
            handler.onAfterUpdate(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
        }
	}
}