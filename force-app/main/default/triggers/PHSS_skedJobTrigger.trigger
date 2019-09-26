trigger PHSS_skedJobTrigger on sked__Job__c (after insert, after update, before delete) {
    if (!PHSS_TriggerSettings__c.getOrgDefaults().skedJobtoILTClassTriggerDisabled__c) {
        if (Trigger.isBefore) {
            if(trigger.isDelete){
                // Future support for Skedulo job deletion in PHSS framework
            }
        }
        else if (Trigger.isAfter) {
            if (Trigger.isInsert) { 
                skedJobtoILTClass lmsHandler = new skedJobtoILTClass();
                lmsHandler.afterInsert(Trigger.new);                
            }
            else if (Trigger.isUpdate) {
                skedJobtoILTClass lmsHandler = new skedJobtoILTClass();
                lmsHandler.afterUpdate(Trigger.new, Trigger.oldMap);                
            }
        }
    }
}