@isTest
private class skedNatSchedulingController_Test {
    
    static testmethod void testGetCSCConfigData() {
        Map<string, sObject> mapObject = skedDataSetup.setupNatSchedulingData();
        Test.startTest();
        skedNatSchedulingController.getNATConfigData();
        Test.stopTest();
    }
    
    static testmethod void testGetCSCConfigDataError() {
        Test.startTest();
        skedNatSchedulingController.getNATConfigData();
        Test.stopTest();
    }
    
    static testmethod void testSaveCourse(){
        Map<string, sObject> mapTestData = skedDataSetup.setupNatSchedulingData();
        sked__Region__c sanFranciscoRegion = (sked__Region__c)mapTestData.get('sanFranciscoRegion');
        Course_Catalog__c courseCatalog1 = (Course_Catalog__c)mapTestData.get('courseCatalog1');
        sked__Tag__c tagPickup = (sked__Tag__c)mapTestData.get('tagPickup');
        
        Date nextMonthStartDate = system.today().toStartOfMonth().addMonths(1);
        Date startDate = nextMonthStartDate.addDays(7).toStartOfWeek();
        DateTime startTime = DateTime.newInstance(startDate, time.newInstance(0, 0, 0, 0));
        Date nextWeekStartDate = startDate.addDays(7);
        DateTime nextWeekStartTime = DateTime.newInstance(nextWeekStartDate, time.newInstance(0, 0, 0, 0));
        
        skedNatSchedulingController.courseSaveModel model = new skedNatSchedulingController.courseSaveModel();
        model.name = 'Test';
        model.courseCatalogId = courseCatalog1.Id;
        model.specialInstructions = 'None';
        model.regionId = sanFranciscoRegion.Id;
        model.numberOfStudents = 10;
        model.startMonth = Json.serialize(nextMonthStartDate).replace('"', '');
        model.beforeClassDuration = 20;
        model.afterClassDuration = 10;
        
        model.maxHoursPerDay = 7;
        model.notes = 'No Notes';
        model.skipHolidays = true;
        
        model.tagIds = new List<string>();
        model.tagIds.add(tagPickup.id);
        model.courseTemplate = skedARCUtils.getCourseTemplates().get(0);
        model.selectedDates = new List<string>();
        
        Test.startTest();
        skedRemoteResultModel calResult = skedNatSchedulingController.calculateDays(model);
        integer totalDays = integer.valueOf(calResult.data);
        for(integer i = 0; i < totalDays; i++){
            model.selectedDates.add(Json.serialize(startDate.addDays(i)).replace('"', ''));
        }
        
        skedRemoteResultModel suggestionResult = skedNatSchedulingController.getSuggestion(model);
        
        skedNatSchedulingController.courseModel course = (skedNatSchedulingController.courseModel)suggestionResult.data;
        
        system.debug('#model.regionId#' + model.regionId);
        skedRemoteResultModel createCourseResult = skedNatSchedulingController.createCourse(course, model);
        
        skedNatSchedulingController.courseModel courseData = (skedNatSchedulingController.courseModel)suggestionResult.data;
        
        for (skedNatSchedulingController.jobModel job : courseData.jobs) {
            system.debug('#job#' + job);
        }
        
        system.debug('#createCourseResult#' + createCourseResult);
        
        skedNatSchedulingController.courseQueryModel queryModel = new skedNatSchedulingController.courseQueryModel();
        queryModel.regionId = sanFranciscoRegion.id;
        queryModel.startDateIso = Json.serialize(nextMonthStartDate).replace('"', '');
        queryModel.endDateIso = Json.serialize(nextMonthStartDate.addMonths(1).addDays(-1)).replace('"', '');
        skedNatSchedulingController.getCourses(queryModel);
        
        Course__c skedCourse = [SELECT Id, Region__c FROM Course__c WHERE Region__c = :sanFranciscoRegion.Id ORDER BY CreatedDate DESC LIMIT 1];
        system.debug('#skedCourse#' + skedCourse.Region__c);
        skedRemoteResultModel getCourseResult = skedNatSchedulingController.getCourseDetails(skedCourse.Id);
        
        skedNatSchedulingController.courseModel editCourseModel = (skedNatSchedulingController.courseModel)getCourseResult.data;
        skedRemoteResultModel editCourseResult = skedNatSchedulingController.editCourse(editCourseModel, false);
        editCourseResult = skedNatSchedulingController.editCourse(editCourseModel, true);
        
        skedNatSchedulingController.cancelCourse(skedCourse.Id);
        
        Test.stopTest();
    }
    
    static testmethod void testGetJobDetails(){
        Map<string, sObject> mapTestData = skedDataSetup.setupNatSchedulingData();
        sked__Region__c sanFranciscoRegion = (sked__Region__c)mapTestData.get('sanFranciscoRegion');
        sked__Job__c dispatchjob = (sked__Job__c)mapTestData.get('dispatchjob');
        
        Test.startTest();
        skedNatSchedulingController.getJobDetails(dispatchjob.id);
        Test.stopTest();
    }
    
    static testmethod void testCreateJob(){
        string timezoneSidId = UserInfo.getTimeZone().getId();
        
        Date nextMonthStartDate = system.today().toStartOfMonth().addMonths(1);
        
        Date startDate = nextMonthStartDate.addDays(7).toStartOfWeek();
        DateTime startTime = DateTime.newInstance(startDate, time.newInstance(0, 0, 0, 0));
        
        Date nextWeekStartDate = startDate.addDays(7);
        DateTime nextWeekStartTime = DateTime.newInstance(nextWeekStartDate, time.newInstance(0, 0, 0, 0));
        
        map<string, sObject> mapTestData = skedDataSetup.setupNatSchedulingData();
        Course_Catalog__c courseCatalog2 = (Course_Catalog__c)mapTestData.get('courseCatalog2');
        sked__Region__c sanFranciscoRegion = (sked__Region__c)mapTestData.get('sanFranciscoRegion');
        Contact testContact = (Contact)mapTestData.get('testContact');
        sked__Location__c communityLocation1 = (sked__Location__c)mapTestData.get('communityLocation1');
        sked__Tag__c tagPickup = (sked__Tag__c)mapTestData.get('tagPickup');
        course__c course1 = (course__c)mapTestData.get('course1');
        
        Test.startTest();
        
        skedNatSchedulingController.jobSaveModel model = new skedNatSchedulingController.jobSaveModel();
        
        model.courseCatalogId = courseCatalog2.id;
        model.numberOfInstructors = 1;
        model.courseId = course1.id;
        
        model.facilityId = communityLocation1.id;
        model.regionId = sanFranciscoRegion.Id;        
        model.selectedDate = Json.serialize(startDate).replace('"', '');
        model.startTime = 1000;
        model.finishTime = 1200;
        
        model.tagIds = new List<string>();
        model.tagIds.add(tagPickup.Id);
        
        skedRemoteResultModel result = skedNatSchedulingController.saveJob(model);
        system.debug('#saveJob result#' + result);
        
        Test.stopTest();
    }
    
    static testmethod void testEditJob(){
        string timezoneSidId = UserInfo.getTimeZone().getId();
        
        Date nextMonthStartDate = system.today().toStartOfMonth().addMonths(1);
        
        Date startDate = nextMonthStartDate.addDays(7).toStartOfWeek();
        DateTime startTime = DateTime.newInstance(startDate, time.newInstance(0, 0, 0, 0));
        
        Date nextWeekStartDate = startDate.addDays(7);
        DateTime nextWeekStartTime = DateTime.newInstance(nextWeekStartDate, time.newInstance(0, 0, 0, 0));
        
        map<string, sObject> mapTestData = skedDataSetup.setupNatSchedulingData();
        Course_Catalog__c courseCatalog2 = (Course_Catalog__c)mapTestData.get('courseCatalog2');
        sked__Region__c sanFranciscoRegion = (sked__Region__c)mapTestData.get('sanFranciscoRegion');
        Contact testContact = (Contact)mapTestData.get('testContact');
        sked__Location__c communityLocation2 = (sked__Location__c)mapTestData.get('communityLocation2');
        sked__Tag__c tagPickup = (sked__Tag__c)mapTestData.get('tagPickup');
        sked__Job__c dispatchjob = (sked__Job__c)mapTestData.get('dispatchjob');
        course__c course1 = (course__c)mapTestData.get('course1');
        
        Test.startTest();
        
        skedNatSchedulingController.jobSaveModel model = new skedNatSchedulingController.jobSaveModel();
        
        model.Id = dispatchjob.id;
        model.courseCatalogId = courseCatalog2.id;
        model.numberOfInstructors = 1;
        model.facilityId = communityLocation2.id;
        model.regionId = sanFranciscoRegion.Id;        
        model.selectedDate = Json.serialize(startDate).replace('"', '');
        model.startTime = 1000;
        model.finishTime = 1200;
        model.courseId = course1.id;
        
        model.tagIds = new List<string>();
        model.tagIds.add(tagPickup.Id);
        
        skedRemoteResultModel result = skedNatSchedulingController.saveJob(model);
        system.debug('#saveJob result#' + result);
        
        Test.stopTest();
    }
    
    static testmethod void testDeleteJobs(){
        map<string, sObject> mapTestData = skedDataSetup.setupNatSchedulingData();
        sked__Job__c dispatchjob = (sked__Job__c)mapTestData.get('dispatchjob');
        list<id> jobIds = new list<id>();
        jobIds.add(dispatchjob.id);
        
        Test.startTest();
        skedNatSchedulingController.deleteJobs(jobIds);
        Test.stopTest();
    }
    
    static testmethod void testCancelJobs(){
        map<string, sObject> mapTestData = skedDataSetup.setupNatSchedulingData();
        sked__Job__c dispatchjob = (sked__Job__c)mapTestData.get('dispatchjob');
        list<id> jobIds = new list<id>();
        jobIds.add(dispatchjob.id);
        
        Test.startTest();
        skedNatSchedulingController.cancelJobs(jobIds);
        Test.stopTest();
    }
    
}