trigger skedAvailabilityTrigger on sked__Availability__c (before insert, before update) {
	if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            skedAvailabilityHandler.beforeInsert(Trigger.new);
        }
        else if (Trigger.isUpdate) {
            skedAvailabilityHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}