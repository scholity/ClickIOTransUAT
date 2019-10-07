trigger PHSS_skedJobTrigger on sked__Job__c (after insert, after update, before delete) {
    if (!PHSS_TriggerSettings__c.getOrgDefaults().skedJobtoILTClassTriggerDisabled__c) {
        if (Trigger.isBefore) {
            if(Trigger.isDelete){
                // Future support for Skedulo job deletion in PHSS framework
            }
        }
        else if (Trigger.isAfter) {
            if (Trigger.isInsert) { 
                PHSS_skedJobtoILTClass lmsHandler = new PHSS_skedJobtoILTClass();
                lmsHandler.afterInsert(Trigger.new);                
            }
            else if (Trigger.isUpdate) {
                PHSS_skedJobtoILTClass lmsHandler = new PHSS_skedJobtoILTClass();
                lmsHandler.afterUpdate(Trigger.new, Trigger.oldMap);                
            }
        }
    }
}