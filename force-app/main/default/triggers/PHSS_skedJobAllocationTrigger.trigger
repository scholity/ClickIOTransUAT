trigger PHSS_skedJobAllocationTrigger on sked__Job_Allocation__c (after insert, after update, before delete) {
    if (!PHSS_TriggerSettings__c.getOrgDefaults().skedJobAlloctoILTInstructTriggerDisabled__c) {
        if (Trigger.isAfter) {
            if (Trigger.isInsert) {
                skedJobAllocationtoILTInstructor lmsHandler = new skedJobAllocationtoILTInstructor();
                lmsHandler.afterInsert(Trigger.new);
            }
            else if (Trigger.isUpdate) {
                skedJobAllocationtoILTInstructor lmsHandler = new skedJobAllocationtoILTInstructor();
                lmsHandler.afterUpdate(Trigger.new, Trigger.oldMap);
            }
        }
    }
}