trigger skedJobAllocationTrigger on sked__Job_Allocation__c (before insert, after insert, after update, before delete) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            skedJobAllocationHandler.afterInsert(Trigger.new);
        }
        else if (Trigger.isUpdate) {
            skedJobAllocationHandler.afterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
    else if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            skedJobAllocationHandler.beforeInsert(Trigger.new);
        }
        else if (Trigger.isDelete) {
            skedJobAllocationHandler.beforeDelete(Trigger.old);
        }
    }
}