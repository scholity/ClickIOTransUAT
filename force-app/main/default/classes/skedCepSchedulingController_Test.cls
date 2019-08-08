@isTest
private class skedCepSchedulingController_Test {
    
    static testmethod void testGetCEPConfigData() {
        Map<string, sObject> mapObject = skedDataSetup.setupCepSchedulingData();
        Test.startTest();
        skedCepSchedulingController.getCEPConfigData();
        Test.stopTest();
    }
    
    static testmethod void testGetCSCConfigDataError() {
        Test.startTest();
        skedCepSchedulingController.getCEPConfigData();
        Test.stopTest();
    }
    
    static testmethod void testGetFacilityList() {
        Map<string, sObject> mapTestData = skedDataSetup.setupCepSchedulingData();
        skedCepSchedulingController.facilityQueryModel model = new skedCepSchedulingController.facilityQueryModel();
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
        skedCepSchedulingController.getFacilityList(model);
        Test.stopTest();
    }
    
    static testmethod void testGetJobDetails(){
        Map<string, sObject> mapTestData = skedDataSetup.setupCepSchedulingData();
        sked__Region__c sanFranciscoRegion = (sked__Region__c)mapTestData.get('sanFranciscoRegion');
        sked__Job__c dispatchjob = (sked__Job__c)mapTestData.get('dispatchjob');
        
        Test.startTest();
        skedCepSchedulingController.getJobDetails(dispatchjob.id);
        Test.stopTest();
    }
    
    static testmethod void testCreateJob(){
        string timezoneSidId = UserInfo.getTimeZone().getId();
        
        Date nextMonthStartDate = system.today().toStartOfMonth().addMonths(1);
        
        Date startDate = nextMonthStartDate.addDays(7).toStartOfWeek();
        DateTime startTime = DateTime.newInstance(startDate, time.newInstance(0, 0, 0, 0));
        
        Date nextWeekStartDate = startDate.addDays(7);
        DateTime nextWeekStartTime = DateTime.newInstance(nextWeekStartDate, time.newInstance(0, 0, 0, 0));
        
        map<string, sObject> mapTestData = skedDataSetup.setupCepSchedulingData();
        sked__Region__c sanFranciscoRegion = (sked__Region__c)mapTestData.get('sanFranciscoRegion');
        Contact testContact = (Contact)mapTestData.get('testContact');
        sked__Location__c cepLocation1 = (sked__Location__c)mapTestData.get('cepLocation1');
        sked__Tag__c tagPickup = (sked__Tag__c)mapTestData.get('tagPickup');
        
        Test.startTest();
        
        skedCepSchedulingController.jobSaveModel model = new skedCepSchedulingController.jobSaveModel();
        
        model.numberOfEvaluators = 1;
        model.facilityId = cepLocation1.id;
        model.regionId = sanFranciscoRegion.Id;        
        model.selectedDate = Json.serialize(startDate).replace('"', '');
        model.startTime = 1000;
        model.finishTime = 1200;
        
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
        
        model.tagIds = new List<string>();
        model.tagIds.add(tagPickup.Id);
        
        skedRemoteResultModel result = skedCepSchedulingController.saveJob(model, true);
        
        Test.stopTest();
    }
    
    static testmethod void testEditJob(){
        string timezoneSidId = UserInfo.getTimeZone().getId();
        
        Date nextMonthStartDate = system.today().toStartOfMonth().addMonths(1);
        
        Date startDate = nextMonthStartDate.addDays(7).toStartOfWeek();
        DateTime startTime = DateTime.newInstance(startDate, time.newInstance(0, 0, 0, 0));
        
        Date nextWeekStartDate = startDate.addDays(7);
        DateTime nextWeekStartTime = DateTime.newInstance(nextWeekStartDate, time.newInstance(0, 0, 0, 0));
        
        map<string, sObject> mapTestData = skedDataSetup.setupCepSchedulingData();
        sked__Region__c sanFranciscoRegion = (sked__Region__c)mapTestData.get('sanFranciscoRegion');
        Contact testContact = (Contact)mapTestData.get('testContact');
        sked__Location__c cepLocation2 = (sked__Location__c)mapTestData.get('cepLocation2');
        sked__Tag__c tagPickup = (sked__Tag__c)mapTestData.get('tagPickup');
        sked__Job__c dispatchjob = (sked__Job__c)mapTestData.get('dispatchjob');
        
        Test.startTest();
        
        skedCepSchedulingController.jobSaveModel model = new skedCepSchedulingController.jobSaveModel();
        
        model.Id = dispatchjob.id;
        model.numberOfEvaluators = 1;
        model.facilityId = cepLocation2.id;
        model.regionId = sanFranciscoRegion.Id;        
        model.selectedDate = Json.serialize(startDate).replace('"', '');
        model.startTime = 1000;
        model.finishTime = 1200;
        
        model.tagIds = new List<string>();
        model.tagIds.add(tagPickup.Id);
        
        skedRemoteResultModel result = skedCepSchedulingController.saveJob(model, true);
        
        Test.stopTest();
    }
    
    static testmethod void testRescheduleJob(){
        string timezoneSidId = UserInfo.getTimeZone().getId();
        
        Date nextMonthStartDate = system.today().toStartOfMonth().addMonths(1);
        
        Date startDate = nextMonthStartDate.addDays(7).toStartOfWeek();
        DateTime startTime = DateTime.newInstance(startDate, time.newInstance(0, 0, 0, 0));
        
        Date nextWeekStartDate = startDate.addDays(7);
        DateTime nextWeekStartTime = DateTime.newInstance(nextWeekStartDate, time.newInstance(0, 0, 0, 0));
        
        map<string, sObject> mapTestData = skedDataSetup.setupCepSchedulingData();
        sked__Region__c sanFranciscoRegion = (sked__Region__c)mapTestData.get('sanFranciscoRegion');
        Contact testContact = (Contact)mapTestData.get('testContact');
        sked__Location__c cepLocation2 = (sked__Location__c)mapTestData.get('cepLocation2');
        sked__Tag__c tagPickup = (sked__Tag__c)mapTestData.get('tagPickup');
        sked__Job__c dispatchjob = (sked__Job__c)mapTestData.get('dispatchjob');
        
        Test.startTest();
        
        skedCepSchedulingController.jobSaveModel model = new skedCepSchedulingController.jobSaveModel();
        
        model.Id = dispatchjob.id;
        model.numberOfEvaluators = 1;
        model.facilityId = cepLocation2.id;
        model.regionId = sanFranciscoRegion.Id;        
        model.selectedDate = Json.serialize(startDate).replace('"', '');
        model.startTime = 1000;
        model.finishTime = 1200;
        
        model.tagIds = new List<string>();
        model.tagIds.add(tagPickup.Id);
        
        skedRemoteResultModel result = skedCepSchedulingController.rescheduleJob(model, false);
        result = skedCepSchedulingController.rescheduleJob(model, true);
        system.debug('#rescheduleJob result#' + result);
        
        Test.stopTest();
    }
    
    static testmethod void testDeleteJobs(){
        map<string, sObject> mapTestData = skedDataSetup.setupCepSchedulingData();
        sked__Job__c dispatchjob = (sked__Job__c)mapTestData.get('dispatchjob');
        list<id> jobIds = new list<id>();
        jobIds.add(dispatchjob.id);
        
        Test.startTest();
        skedCepSchedulingController.deleteJobs(jobIds);
        Test.stopTest();
    }
    
    static testmethod void testCancelJobs(){
        map<string, sObject> mapTestData = skedDataSetup.setupCepSchedulingData();
        sked__Job__c dispatchjob = (sked__Job__c)mapTestData.get('dispatchjob');
        list<id> jobIds = new list<id>();
        jobIds.add(dispatchjob.id);
        
        Test.startTest();
        skedCepSchedulingController.cancelJobs(jobIds);
        Test.stopTest();
    }
}