/************************************************************************************************************************************
** Author: Salesforce Services
************************************************************************************************************************************/
trigger PHSS_LearningTrigger on redwing__Learning__c (after insert, after update) {
    if (!PHSS_TriggerSettings__c.getOrgDefaults().LearningTriggerDisabled__c) {
        PHSS_LearningTriggerHandler handler = new PHSS_LearningTriggerHandler();
        if (Trigger.isAfter) {
            if (Trigger.isInsert) {
                handler.initializeOnlineVoucher(Trigger.new);
            } else if (Trigger.isUpdate) {
                handler.initializeOnlineVoucher(Trigger.new);
            }
        }
    }
}