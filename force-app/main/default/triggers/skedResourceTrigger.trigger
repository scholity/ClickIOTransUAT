trigger skedResourceTrigger on sked__Resource__c (after insert, after update, before delete) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            skedResourceHandler.afterInsert(Trigger.new);
            if (!PHSS_TriggerSettings__c.getOrgDefaults().skedResourcetoILTInstructTriggerDisabled__c) {
                skedResourcetoILTInstructor.afterInsert(Trigger.new);
            }
        }
        else if (Trigger.isUpdate) {
            skedResourceHandler.afterUpdate(Trigger.new, Trigger.oldMap);
            if (!PHSS_TriggerSettings__c.getOrgDefaults().skedResourcetoILTInstructTriggerDisabled__c) {
                skedResourcetoILTInstructor.afterUpdate(Trigger.new, Trigger.oldMap);
            }
        }
    }
    if(Trigger.IsDelete){
        skedResourcetoILTInstructor.beforeDelete(Trigger.OldMap);
    }
}