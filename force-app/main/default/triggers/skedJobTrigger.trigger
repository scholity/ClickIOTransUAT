trigger skedJobTrigger on sked__Job__c (before insert, before update, after insert, after update, before delete) {
    if (Trigger.isBefore) {
        if(trigger.isInsert){
            skedJobHandler.beforeInsert(trigger.new);
        }
        else if (Trigger.isUpdate) {
            skedJobHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }
    else if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            skedJobHandler.afterInsert(Trigger.new);
            if (!PHSS_TriggerSettings__c.getOrgDefaults().skedJobtoILTClassTriggerDisabled__c) {
                if (skedJobtoILTClass.initSkedJobtoILTClassInsert) {
                    //skedJobtoILTClass.initSkedJobtoILTClassInsert = false;
                    skedJobtoILTClass lmsHandler = new skedJobtoILTClass();
                    lmsHandler.afterInsert(Trigger.new);
                }
            } 
        }
        else if (Trigger.isUpdate) {
            System.debug('Updated job' +Trigger.new +Trigger.oldMap);
            skedJobHandler.afterUpdate(Trigger.new, Trigger.oldMap);
            if (!PHSS_TriggerSettings__c.getOrgDefaults().skedJobtoILTClassTriggerDisabled__c) {
                if (skedJobtoILTClass.initSkedJobtoILTClassUpdate) {
                    //skedJobtoILTClass.initSkedJobtoILTClassUpdate = false;
                    skedJobtoILTClass lmsHandler = new skedJobtoILTClass();
                    lmsHandler.afterUpdate(Trigger.new, Trigger.oldMap);
                }
            }
        }
    }
}