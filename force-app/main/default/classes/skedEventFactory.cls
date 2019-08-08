public class skedEventFactory {

	public static void captureJobEvents(Set<Id> jobIds) { 
		Map<Id, sked__Job_Allocation__c> mapAllocation = new Map<Id, sked__Job_Allocation__c>([SELECT Id
                                                                                               FROM sked__Job_Allocation__c
                                                                                               WHERE sked__Job__c IN :jobIds
                                                                                               AND sked__Status__c != :skedConstants.JOB_ALLOCATION_STATUS_DELETED
                                                                                               AND sked__Status__c != :skedConstants.JOB_ALLOCATION_STATUS_DECLINED]);
        captureJobAllocationEvents(mapAllocation.keySet());
	}

	public static void captureJobAllocationEvents(Set<Id> jobAllocationIds) {
		List<sked__Job_Allocation__c> skedAllocations = [SELECT Id, sked__Job__r.Name, sked__Job__r.sked__Description__c, sked__Job__r.sked__Start__c, 
                                                         sked__Job__r.sked__Finish__c, sked__Job__r.sked__Duration__c, sked__Job__r.sked__Address__c, 
                                                         sked__Resource__c, sked__Resource__r.sked__User__c, Event_Id__c
                                                         FROM sked__Job_Allocation__c
                                                         WHERE Id IN :jobAllocationIds
                                                         AND sked__Resource__r.sked__User__c != NULL];
        Set<Id> existingEventIds = new Set<Id>();
        for (sked__Job_Allocation__c skedAllocation : skedAllocations) {
        	if (!string.isBlank(skedAllocation.Event_Id__c)) {
	        	existingEventIds.add(skedAllocation.Event_Id__c);
	        }
        }

        Map<Id, Event> mapExistingEvent = new Map<Id, Event>([SELECT Id
	        												  FROM Event
	        												  WHERE Id IN :existingEventIds]);
		Map<Id, Event> map_allocationId_event = new Map<Id, Event>();
		List<Event> eventsToUpsert = new List<Event>();
		for (sked__Job_Allocation__c skedAllocation : skedAllocations) {
			Event relatedEvent;
        	if (!string.isBlank(skedAllocation.Event_Id__c) && mapExistingEvent.containsKey(skedAllocation.Event_Id__c)) {
        		relatedEvent = mapExistingEvent.get(skedAllocation.Event_Id__c);
        	}
        	else {
        		relatedEvent = new Event();
        		map_allocationId_event.put(skedAllocation.Id, relatedEvent);
        	}
        	relatedEvent.Subject = skedAllocation.sked__Job__r.Name + ' - ' + skedAllocation.sked__Job__r.sked__Description__c;
            relatedEvent.Description = skedAllocation.sked__Job__r.Name + ' - ' + skedAllocation.sked__Job__r.sked__Description__c;
        	relatedEvent.StartDateTime = skedAllocation.sked__Job__r.sked__Start__c;
        	relatedEvent.DurationInMinutes = integer.valueOf(skedAllocation.sked__Job__r.sked__Duration__c);
        	relatedEvent.EndDateTime = skedAllocation.sked__Job__r.sked__Finish__c;
        	relatedEvent.Location = skedAllocation.sked__Job__r.sked__Address__c;
        	relatedEvent.Type = skedConstants.EVENT_TYPE_OTHER;
        	relatedEvent.OwnerId = skedAllocation.sked__Resource__r.sked__User__c;

        	eventsToUpsert.add(relatedEvent);
        }
        if (!eventsToUpsert.isEmpty()) {
    		upsert eventsToUpsert;
    	}

        if (!map_allocationId_event.isEmpty()) {
        	List<sked__Job_Allocation__c> skedAllocationsToUpdate = new List<sked__Job_Allocation__c>();
        	for (Id allocationId : map_allocationId_event.keySet()) {
        		Event relatedEvent = map_allocationId_event.get(allocationId);
        		sked__Job_Allocation__c skedAllocation = new sked__Job_Allocation__c(
        			Id = allocationId,
        			Event_Id__c = relatedEvent.Id
    			);
    			skedAllocationsToUpdate.add(skedAllocation);
        	}
        	if (!skedAllocationsToUpdate.isEmpty()) {
        		update skedAllocationsToUpdate;
        	}
        }
	}

	public static void removeJobEvents(Set<Id> jobIds) {
		Map<Id, sked__Job_Allocation__c> mapAllocation = new Map<Id, sked__Job_Allocation__c>([SELECT Id
                                                                                               FROM sked__Job_Allocation__c
                                                                                               WHERE sked__Job__c IN :jobIds
                                                                                               AND sked__Status__c != :skedConstants.JOB_ALLOCATION_STATUS_DELETED
                                                                                               AND sked__Status__c != :skedConstants.JOB_ALLOCATION_STATUS_DECLINED]);
        removeJobAllocationEvents(mapAllocation.keySet());
	}

	public static void removeJobAllocationEvents(Set<Id> jobAllocationIds) {
		List<sked__Job_Allocation__c> skedAllocations = [SELECT Id, Event_Id__c
                                                         FROM sked__Job_Allocation__c
                                                         WHERE Id IN :jobAllocationIds];
        Set<Id> existingEventIds = new Set<Id>();
        for (sked__Job_Allocation__c skedAllocation : skedAllocations) {
        	if (!string.isBlank(skedAllocation.Event_Id__c)) {
	        	existingEventIds.add(skedAllocation.Event_Id__c);
	        }
        }
        if (!existingEventIds.isEmpty()) {
			List<Event> existingEvents = [SELECT Id
										  FROM Event
										  WHERE Id IN :existingEventIds];
		    delete existingEvents;
		}
	}

}