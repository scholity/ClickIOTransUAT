/************************************************************************************************************************************
** Author: Salesforce Services
************************************************************************************************************************************/
trigger ILTRosterTrigger on redwing__ILT_Roster__c (before insert, before update) {
	if (!PHSS_TriggerSettings__c.getOrgDefaults().ILTRosterTrigger_Disabled__c) {
        ILTRosterTriggerHandler handler = new ILTRosterTriggerHandler();
        if (Trigger.isBefore && Trigger.isInsert) {
            handler.onBeforeInsert(Trigger.new);
        } else if (Trigger.isBefore && Trigger.isUpdate) {
            handler.onBeforeUpdate(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
        }
	}
}