trigger skedResourceTrigger on sked__Resource__c (after insert, after update, before delete) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            skedResourceHandler.afterInsert(Trigger.new);
        }
        else if (Trigger.isUpdate) {
            skedResourceHandler.afterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}