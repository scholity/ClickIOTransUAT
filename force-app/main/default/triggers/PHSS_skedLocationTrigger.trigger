trigger PHSS_skedLocationTrigger on sked__Location__c (after insert, after update, before delete) {
    if (!PHSS_TriggerSettings__c.getOrgDefaults().skedLocationtoILTLocationTriggerDisabled__c) {
        if (Trigger.isAfter) {
            if (Trigger.isInsert) {
                PHSS_skedLocationtoILTlocation.afterInsert(Trigger.new);
            }
            else if (Trigger.isUpdate) {
                PHSS_skedLocationtoILTlocation.afterupdate(Trigger.new,Trigger.oldMap);
            }
        }
        if(Trigger.IsDelete){
            PHSS_skedLocationtoILTlocation.beforeDelete(Trigger.oldMap);
        }
    }
}