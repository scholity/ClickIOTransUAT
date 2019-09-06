trigger skedJobAllocationTrigger on sked__Job_Allocation__c (after insert, after update, before delete) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            skedJobAllocationHandler.afterInsert(Trigger.new);
            if (!PHSS_TriggerSettings__c.getOrgDefaults().skedJobAlloctoILTInstructTriggerDisabled__c) {
                skedJobAllocationtoILTInstructor lmsHandler = new skedJobAllocationtoILTInstructor();
                lmsHandler.afterInsert(Trigger.new);
            }
        }
        else if (Trigger.isUpdate) {
            skedJobAllocationHandler.afterUpdate(Trigger.new, Trigger.oldMap);
            if (!PHSS_TriggerSettings__c.getOrgDefaults().skedJobAlloctoILTInstructTriggerDisabled__c) {
                skedJobAllocationtoILTInstructor lmsHandler = new skedJobAllocationtoILTInstructor();
                lmsHandler.afterUpdate(Trigger.new, Trigger.oldMap);
            }
        }
    }
}