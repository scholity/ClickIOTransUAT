trigger skedLocationTrigger on sked__Location__c (after insert, after update, before delete) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            skedLocationHandler.afterInsert(Trigger.new);
            if (!PHSS_TriggerSettings__c.getOrgDefaults().skedLocationtoILTLocationTriggerDisabled__c) {
                skedLocationtoILTlocation.afterInsert(Trigger.new);
            }
        }
        else if (Trigger.isUpdate) {
            skedLocationHandler.afterUpdate(Trigger.new, Trigger.oldMap);
            if (!PHSS_TriggerSettings__c.getOrgDefaults().skedLocationtoILTLocationTriggerDisabled__c) {
                skedLocationtoILTlocation.afterupdate(Trigger.new,Trigger.oldMap);
            }
        }
    }
    if(Trigger.IsDelete){
        skedLocationtoILTlocation.beforeDelete(Trigger.oldMap);
    }
}