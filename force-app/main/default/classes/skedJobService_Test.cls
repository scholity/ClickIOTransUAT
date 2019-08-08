@isTest
public class skedJobService_Test {
    
    @isTest static void MainTest() {
        Date nextMonthStartDate = system.today().toStartOfMonth().addMonths(1);
        
        Date startDate = nextMonthStartDate.addDays(7).toStartOfWeek();
        DateTime startTime = DateTime.newInstance(startDate, time.newInstance(0, 0, 0, 0));
        
        Date nextWeekStartDate = startDate.addDays(7);
        DateTime nextWeekStartTime = DateTime.newInstance(nextWeekStartDate, time.newInstance(0, 0, 0, 0));
        
        map<string, sObject> mapTestData = skedDataSetup.setupCommonTestData();
        sked__Region__c sanFranciscoRegion = (sked__Region__c)mapTestData.get('sanFranciscoRegion');
        Account testAccount = (Account)mapTestData.get('testAccount');
        Contact testContact = (Contact)mapTestData.get('testContact');
        Course_Catalog__c courseCatalog1 = (Course_Catalog__c)mapTestData.get('courseCatalog1');
        sked__Resource__c instructor1 = (sked__Resource__c)mapTestData.get('instructor1');
        sked__Tag__c tagPickup = (sked__Tag__c)mapTestData.get('tagPickup');
        
        sked__Job__c job = new sked__Job__c(
            sked__Address__c = '2951 Bush St #C, San Francisco, CA 94115',
            sked__GeoLocation__Latitude__s = 37.785504, 
            sked__GeoLocation__Longitude__s = -122.445256,
            sked__Account__c = testAccount.Id,
            sked__Contact__c = testContact.Id,
            sked__Region__c = sanFranciscoRegion.Id,
            sked__Type__c = skedConstants.JOB_TYPE_FULL_SERVICE,
            sked__Start__c = startTime.addDays(1).addHours(8),
            sked__Finish__c = startTime.addDays(1).addHours(11),
            sked__Job_Status__c = skedConstants.JOB_STATUS_PENDING_DISPATCH,
            Equipment__c = 'DVD and TV on site',
            Number_of_Students__c = 10,
            Number_of_Instructors__c = 1,
            Course_Catalog__c = courseCatalog1.Id,
            sked__Duration__c = 180,
            Break_Duration__c = 30,
            Number_of_Breaks__c = 1,
            Test__c = false,
            Special_Instructions__c = 'None'
        );
        insert job;
        
        sked__Job_Allocation__c jobAlloc = new sked__Job_Allocation__c(
            sked__Resource__c = instructor1.Id,
            sked__Job__c = job.Id,
            sked__Status__c = skedConstants.JOB_ALLOCATION_STATUS_PENDING_DISPATCH
        );
        insert jobAlloc;
        
        Test.startTest();
        
        job.sked__Job_Status__c = skedConstants.JOB_STATUS_DISPATCHED;
        update job;
        jobAlloc.sked__Status__c = skedConstants.JOB_ALLOCATION_STATUS_DISPATCHED;
        update jobAlloc;
        
        Map<Id, sked__Job__c> mapJob = new Map<Id, sked__Job__c>();
        mapJob.put(job.Id, job);
        
        List<string> jobIds = new List<string>();
        jobIds.add(job.Id);
        
        List<string> tagIds = new List<string>();
        tagIds.add(tagPickup.Id);
        
        skedJobService.insertJobTags(mapJob.values(), tagIds);
        
        job.sked__Job_Status__c = skedConstants.JOB_STATUS_READY;
        update job;
        jobAlloc.sked__Status__c = skedConstants.JOB_ALLOCATION_STATUS_CONFIRMED;
        update jobAlloc;
        skedJobService.cancelJobs(jobIds);
        
        skedJobService.deleteJobs(jobIds);
        
        Test.stopTest();
    }

}