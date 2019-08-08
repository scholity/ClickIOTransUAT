@isTest
private class skedCommunitySchedulingController_Test {
    
    static testmethod void testGetCSCConfigData() {
        Map<string, sObject> mapObject = skedDataSetup.setupCommunitySchedulingData();
        Test.startTest();
        skedCommunitySchedulingController.getCSCConfigData();
        Test.stopTest();
    }
    
    static testmethod void testGetCSCConfigDataError() {
        Test.startTest();
        skedCommunitySchedulingController.getCSCConfigData();
        Test.stopTest();
    }
    
    static testmethod void testGetFacilityList() {
        Map<string, sObject> mapTestData = skedDataSetup.setupCommunitySchedulingData();
        skedCommunitySchedulingController.facilityQueryModel model = new skedCommunitySchedulingController.facilityQueryModel();
        sked__Region__c sanFranciscoRegion = (sked__Region__c)mapTestData.get('sanFranciscoRegion');
        
        Date nextMonthStartDate = system.today().toStartOfMonth().addMonths(1);
        Date startDate = nextMonthStartDate.addDays(7).toStartOfWeek();
        DateTime startTime = DateTime.newInstance(startDate, time.newInstance(0, 0, 0, 0));
        Date nextWeekStartDate = startDate.addDays(7);
        DateTime nextWeekStartTime = DateTime.newInstance(nextWeekStartDate, time.newInstance(0, 0, 0, 0));
        
        model.regionId = sanFranciscoRegion.id;
        model.startDateIso = Json.serialize(startDate).replace('"', '');
        model.endDateIso = Json.serialize(nextWeekStartDate).replace('"', '');
        
        Test.startTest();
        skedCommunitySchedulingController.getFacilityList(model);
        Test.stopTest();
    }
    
    static testmethod void testCopyClassPattern(){
        Map<string, sObject> mapTestData = skedDataSetup.setupCommunitySchedulingData();
        sked__Region__c sanFranciscoRegion = (sked__Region__c)mapTestData.get('sanFranciscoRegion');
        
        Date nextMonthStartDate = system.today().toStartOfMonth().addMonths(1);
        Date startDate = nextMonthStartDate.addDays(7).toStartOfWeek();
        Date destinationWeekStartDate = startDate.addDays(7);
        
        Test.startTest();
        skedCommunitySchedulingController.copyClassPattern(Json.serialize(startDate).replace('"', ''), Json.serialize(destinationWeekStartDate).replace('"', ''), sanFranciscoRegion.id);
        Test.stopTest();
    }
    
    static testmethod void testGetJobDetails(){
        Map<string, sObject> mapTestData = skedDataSetup.setupCommunitySchedulingData();
        sked__Region__c sanFranciscoRegion = (sked__Region__c)mapTestData.get('sanFranciscoRegion');
        sked__Job__c dispatchjob = (sked__Job__c)mapTestData.get('dispatchjob');
        
        Test.startTest();
        skedCommunitySchedulingController.getJobDetails(dispatchjob.id);
        Test.stopTest();
    }
    
    static testmethod void testCreateJob(){
        string timezoneSidId = UserInfo.getTimeZone().getId();
        
        Date nextMonthStartDate = system.today().toStartOfMonth().addMonths(1);
        
        Date startDate = nextMonthStartDate.addDays(7).toStartOfWeek();
        DateTime startTime = DateTime.newInstance(startDate, time.newInstance(0, 0, 0, 0));
        
        Date nextWeekStartDate = startDate.addDays(7);
        DateTime nextWeekStartTime = DateTime.newInstance(nextWeekStartDate, time.newInstance(0, 0, 0, 0));
        
        map<string, sObject> mapTestData = skedDataSetup.setupCommunitySchedulingData();
        Course_Catalog__c courseCatalog2 = (Course_Catalog__c)mapTestData.get('courseCatalog2');
        sked__Region__c sanFranciscoRegion = (sked__Region__c)mapTestData.get('sanFranciscoRegion');
        Contact testContact = (Contact)mapTestData.get('testContact');
        sked__Location__c communityLocation1 = (sked__Location__c)mapTestData.get('communityLocation1');
        sked__Tag__c tagPickup = (sked__Tag__c)mapTestData.get('tagPickup');
        
        Test.startTest();
        
        skedCommunitySchedulingController.jobSaveModel model = new skedCommunitySchedulingController.jobSaveModel();
        
        model.courseCatalogId = courseCatalog2.id;
        model.numberOfInstructors = 1;
        model.numberOfStudents = 20;
        model.classDuration = 180;
        model.breakDuration = 30;
        model.numberOfBreaks = 1;
        model.locationConfirmed = false;
        
        model.isRecurring = true;
        model.skipHolidays = true;
        model.every = 1;
        model.weekdays = new List<string>();
        model.weekdays.add('mon');
        model.weekdays.add('tue');
        model.weekdays.add('wed');
        model.weekdays.add('thu');
        model.weekdays.add('fri');
        model.numberOfClasses = 5;
        model.facilityId = communityLocation1.id;
        model.regionId = sanFranciscoRegion.Id;        
        model.selectedDate = Json.serialize(startDate).replace('"', '');
        model.startTime = 1000;
        model.finishTime = 1200;
        
        model.offerings = new List<skedCommunitySchedulingController.offeringModel>();
        skedCommunitySchedulingController.offeringModel offering1 = new skedCommunitySchedulingController.offeringModel();
        offering1.Name = 'Test';
        model.offerings.add(offering1);
        
        model.tagIds = new List<string>();
        model.tagIds.add(tagPickup.Id);
        
        skedRemoteResultModel result = skedCommunitySchedulingController.saveJob(model, true);
        
        Test.stopTest();
    }
    
    static testmethod void testEditJob(){
        string timezoneSidId = UserInfo.getTimeZone().getId();
        
        Date nextMonthStartDate = system.today().toStartOfMonth().addMonths(1);
        
        Date startDate = nextMonthStartDate.addDays(7).toStartOfWeek();
        DateTime startTime = DateTime.newInstance(startDate, time.newInstance(0, 0, 0, 0));
        
        Date nextWeekStartDate = startDate.addDays(7);
        DateTime nextWeekStartTime = DateTime.newInstance(nextWeekStartDate, time.newInstance(0, 0, 0, 0));
        
        map<string, sObject> mapTestData = skedDataSetup.setupCommunitySchedulingData();
        Course_Catalog__c courseCatalog2 = (Course_Catalog__c)mapTestData.get('courseCatalog2');
        sked__Region__c sanFranciscoRegion = (sked__Region__c)mapTestData.get('sanFranciscoRegion');
        Contact testContact = (Contact)mapTestData.get('testContact');
        sked__Location__c communityLocation2 = (sked__Location__c)mapTestData.get('communityLocation2');
        sked__Tag__c tagPickup = (sked__Tag__c)mapTestData.get('tagPickup');
        sked__Job__c dispatchjob = (sked__Job__c)mapTestData.get('dispatchjob');
        Offering__c offferingDispatch = (Offering__c)mapTestData.get('offferingDispatch');
        
        Test.startTest();
        
        skedCommunitySchedulingController.jobSaveModel model = new skedCommunitySchedulingController.jobSaveModel();
        
        model.Id = dispatchjob.id;
        model.courseCatalogId = courseCatalog2.id;
        model.numberOfInstructors = 1;
        model.numberOfStudents = 20;
        model.classDuration = 180;
        model.breakDuration = 30;
        model.numberOfBreaks = 1;
        model.locationConfirmed = false;
        model.facilityId = communityLocation2.id;
        model.regionId = sanFranciscoRegion.Id;        
        model.selectedDate = Json.serialize(startDate).replace('"', '');
        model.startTime = 1000;
        model.finishTime = 1200;
        
        model.offerings = new List<skedCommunitySchedulingController.offeringModel>();
        skedCommunitySchedulingController.offeringModel offering1 = new skedCommunitySchedulingController.offeringModel(offferingDispatch);
        offering1.isChanged = true;
        model.offerings.add(offering1);
        
        model.tagIds = new List<string>();
        model.tagIds.add(tagPickup.Id);
        
        skedRemoteResultModel result = skedCommunitySchedulingController.saveJob(model, true);
        
        Test.stopTest();
    }
    
    static testmethod void testRescheduleJob(){
        string timezoneSidId = UserInfo.getTimeZone().getId();
        
        Date nextMonthStartDate = system.today().toStartOfMonth().addMonths(1);
        
        Date startDate = nextMonthStartDate.addDays(7).toStartOfWeek();
        DateTime startTime = DateTime.newInstance(startDate, time.newInstance(0, 0, 0, 0));
        
        Date nextWeekStartDate = startDate.addDays(7);
        DateTime nextWeekStartTime = DateTime.newInstance(nextWeekStartDate, time.newInstance(0, 0, 0, 0));
        
        map<string, sObject> mapTestData = skedDataSetup.setupCommunitySchedulingData();
        Course_Catalog__c courseCatalog2 = (Course_Catalog__c)mapTestData.get('courseCatalog2');
        sked__Region__c sanFranciscoRegion = (sked__Region__c)mapTestData.get('sanFranciscoRegion');
        Contact testContact = (Contact)mapTestData.get('testContact');
        sked__Location__c communityLocation2 = (sked__Location__c)mapTestData.get('communityLocation2');
        Attendee__c attendeeTest = (Attendee__c)mapTestData.get('attendee');
        sked__Tag__c tagPickup = (sked__Tag__c)mapTestData.get('tagPickup');
        sked__Job__c dispatchjob = (sked__Job__c)mapTestData.get('dispatchjob');
        Offering__c offferingDispatch = (Offering__c)mapTestData.get('offferingDispatch');
        
        Test.startTest();
        
        skedCommunitySchedulingController.jobSaveModel model = new skedCommunitySchedulingController.jobSaveModel();
        
        model.Id = dispatchjob.id;
        model.courseCatalogId = courseCatalog2.id;
        model.numberOfInstructors = 1;
        model.numberOfStudents = 20;
        model.classDuration = 180;
        model.breakDuration = 30;
        model.numberOfBreaks = 1;
        model.locationConfirmed = false;
        model.facilityId = communityLocation2.id;
        model.regionId = sanFranciscoRegion.Id;        
        model.selectedDate = Json.serialize(startDate.addDays(1)).replace('"', '');
        model.startTime = 800;
        model.finishTime = 1100;
        
        model.offerings = new List<skedCommunitySchedulingController.offeringModel>();
        skedCommunitySchedulingController.offeringModel offering1 = new skedCommunitySchedulingController.offeringModel(offferingDispatch);
        offering1.isChanged = true;
        model.offerings.add(offering1);
        
        model.tagIds = new List<string>();
        model.tagIds.add(tagPickup.Id);
        
        skedRemoteResultModel result = skedCommunitySchedulingController.rescheduleJob(model, false);
        result = skedCommunitySchedulingController.rescheduleJob(model, true);
        
        Test.stopTest();
    }
    
    static testmethod void testResolveQueuedJobs(){
        map<string, sObject> mapTestData = skedDataSetup.setupCommunitySchedulingData();
        sked__Job__c dispatchjob = (sked__Job__c)mapTestData.get('dispatchjob');
        list<id> jobIds = new list<id>();
        jobIds.add(dispatchjob.id);
        
        Test.startTest();
        skedCommunitySchedulingController.resolveQueuedJobs(jobIds);
        Test.stopTest();
    }
    
    static testmethod void testDeleteJobs(){
        map<string, sObject> mapTestData = skedDataSetup.setupCommunitySchedulingData();
        sked__Job__c dispatchjob = (sked__Job__c)mapTestData.get('dispatchjob');
        list<id> jobIds = new list<id>();
        jobIds.add(dispatchjob.id);
        
        Test.startTest();
        skedCommunitySchedulingController.deleteJobs(jobIds);
        Test.stopTest();
    }
    
    static testmethod void testCancelJobs(){
        map<string, sObject> mapTestData = skedDataSetup.setupCommunitySchedulingData();
        sked__Job__c dispatchjob = (sked__Job__c)mapTestData.get('dispatchjob');
        list<id> jobIds = new list<id>();
        jobIds.add(dispatchjob.id);
        
        Test.startTest();
        skedCommunitySchedulingController.cancelJobs(jobIds);
        Test.stopTest();
    }
}