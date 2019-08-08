trigger skedActivityTrigger on sked__Activity__c (before update, after insert, after update, after delete) {
    if (Trigger.isBefore) {
        if (Trigger.isUpdate) {
            skedActivityHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }
	else if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            skedActivityHandler.afterInsert(Trigger.new);
        }
        else if (Trigger.isUpdate) {
            skedActivityHandler.afterUpdate(Trigger.new, Trigger.oldMap);
        }
        else if (Trigger.isDelete) {
            skedActivityHandler.afterDelete(Trigger.new, Trigger.oldMap);
        }
    }
}