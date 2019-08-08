global class skedScheduleWeeklyHoursBatch implements Schedulable {

    global void execute(SchedulableContext sc) {
        Map<Id, sked__Resource__c> mapResource = new Map<Id, sked__Resource__c>([SELECT Id
                                                                                 FROM sked__Resource__c
                                                                                 WHERE sked__Is_Active__c = TRUE]);
        skedUtils.updateResourceScheduledHours(mapResource.keySet());
    }

}