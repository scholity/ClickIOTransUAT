trigger PHSS_skedResourceTrigger on sked__Resource__c (after insert, after update, before delete) {
    if (!PHSS_TriggerSettings__c.getOrgDefaults().skedResourcetoILTInstructTriggerDisabled__c) {
        if (Trigger.isAfter) {
            if (Trigger.isInsert) {
                skedResourcetoILTInstructor.afterInsert(Trigger.new);
            }
            else if (Trigger.isUpdate) {
                skedResourcetoILTInstructor.afterUpdate(Trigger.new, Trigger.oldMap);
            }
        }
        if(Trigger.IsDelete){
            skedResourcetoILTInstructor.beforeDelete(Trigger.OldMap);
        }
    }
}