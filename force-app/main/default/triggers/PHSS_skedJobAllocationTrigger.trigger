trigger PHSS_skedJobAllocationTrigger on sked__Job_Allocation__c (after insert, after update, before delete) {
    if (!PHSS_TriggerSettings__c.getOrgDefaults().skedJobAlloctoILTInstructTriggerDisabled__c) {
        if (Trigger.isAfter) {
            if (Trigger.isInsert) {
                PHSS_skedJobAllocationtoILTInstructor lmsHandler = new PHSS_skedJobAllocationtoILTInstructor();
                lmsHandler.afterInsert(Trigger.new);
            }
            else if (Trigger.isUpdate) {
                PHSS_skedJobAllocationtoILTInstructor lmsHandler = new PHSS_skedJobAllocationtoILTInstructor();
                lmsHandler.afterUpdate(Trigger.new, Trigger.oldMap);
            }
        }
    }
}