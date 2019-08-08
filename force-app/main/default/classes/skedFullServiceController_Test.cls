@isTest
public class skedFullServiceController_Test {

    static testmethod void testGetConfigData(){
        map<string, sObject> mapTestData = skedDataSetup.setupFullServiceTestData();
        Training_Events__c trainingEvent = (Training_Events__c)mapTestData.get('trainingEvent1');
        
        Test.startTest();

        System.currentPageReference().getParameters().put('id', trainingEvent.Id);
        skedFullServiceBookingGridController con = new skedFullServiceBookingGridController();
        
        skedFullServiceBookingGridController.getConfigData(trainingEvent.id);
        
        Test.stopTest();
    }
    
    static testmethod void testGetConfigDataError(){
        map<string, sObject> mapTestData = skedDataSetup.setupFullServiceTestData();
        Training_Events__c trainingEvent = (Training_Events__c)mapTestData.get('trainingEvent1');
        sked__Job__c dispatchjob = (sked__Job__c)mapTestData.get('dispatchjob');
        
        dispatchjob.sked__Job_Status__c = skedConstants.JOB_STATUS_IN_PROGRESS;
        update dispatchjob;
        
        Test.startTest();

        System.currentPageReference().getParameters().put('id', trainingEvent.Id);
        skedFullServiceBookingGridController con = new skedFullServiceBookingGridController();
        
        skedFullServiceBookingGridController.getConfigData(trainingEvent.id);
        
        Test.stopTest();
    }

    static testmethod void testSearchContacts(){
        map<string, sObject> mapTestData = skedDataSetup.setupFullServiceTestData();
        Account testAccount = (Account)mapTestData.get('testAccount');
        
        Test.startTest();
        
        skedFullServiceBookingGridController.searchContacts(testAccount.id, 'test');
        
        Test.stopTest();
    }

    static testmethod void testCreateContact(){
        map<string, sObject> mapTestData = skedDataSetup.setupFullServiceTestData();
        Contact testContact = (Contact)mapTestData.get('testContact');
        
        Test.startTest();
        
        skedFullServiceBookingGridController.contactModel testContactModel = new skedFullServiceBookingGridController.contactModel(testContact);
        skedFullServiceBookingGridController.createContact(testContactModel);
        
        Test.stopTest();
    }

    static testmethod void testGetBookingGrid(){
        map<string, sObject> mapTestData = skedDataSetup.setupFullServiceTestData();
        sked__Tag__c tagPickup = (sked__Tag__c)mapTestData.get('tagPickup');
        sked__Region__c sanFranciscoRegion = (sked__Region__c)mapTestData.get('sanFranciscoRegion');
        Training_Events__c trainingEvent = (Training_Events__c)mapTestData.get('trainingEvent1');
        
        string timezoneSidId = UserInfo.getTimeZone().getId();
        Date nextMonthStartDate = system.today().toStartOfMonth().addMonths(1);
        Date startDate = nextMonthStartDate.addDays(7).toStartOfWeek();
        DateTime startTime = DateTime.newInstance(startDate, time.newInstance(0, 0, 0, 0));
        Date nextWeekStartDate = startDate.addDays(7);
        DateTime nextWeekStartTime = DateTime.newInstance(nextWeekStartDate, time.newInstance(0, 0, 0, 0));
        
        skedGoogleApi_Mock mockClass = new skedGoogleApi_Mock();
        mockClass.calloutMethod = 'calculateMultiDistances';
        Test.setMock(HttpCalloutMock.class, mockClass);
        
        Test.startTest();
        
        skedFullServiceBookingGridController.bookingGridQueryModel model = new skedFullServiceBookingGridController.bookingGridQueryModel();

        model.trainingEventId = trainingEvent.id;
        model.regionId = sanFranciscoRegion.Id;
        model.startDateIso = Json.serialize(startDate).replace('"', '');
        model.endDateIso = Json.serialize(nextWeekStartDate).replace('"', '');
        model.startTimeInt = 830;
        model.endTimeInt = 930;
        model.jobDuration = 60;
        model.timeslotStep = 30;
        model.radius = 50;
        model.lat = 37.788400;
        model.lng = -122.447064;
        model.beforeClassDuration = 5;
        model.afterClassDuration = 5;
        model.tagIds = new List<string>();
        model.tagIds.add(tagPickup.Id);

        skedFullServiceBookingGridController.getBookingGrid(model);
        
        skedFullServiceBookingGridController.getResourceData(model);
        
        Test.stopTest();
    }

    static testmethod void testSaveJob(){
        string timezoneSidId = UserInfo.getTimeZone().getId();
        
        Date nextMonthStartDate = system.today().toStartOfMonth().addMonths(1);
        
        Date startDate = nextMonthStartDate.addDays(7).toStartOfWeek();
        DateTime startTime = DateTime.newInstance(startDate, time.newInstance(0, 0, 0, 0));
        
        Date nextWeekStartDate = startDate.addDays(7);
        DateTime nextWeekStartTime = DateTime.newInstance(nextWeekStartDate, time.newInstance(0, 0, 0, 0));
        
        map<string, sObject> mapTestData = skedDataSetup.setupFullServiceTestData();
        Training_Events__c trainingEvent = (Training_Events__c)mapTestData.get('trainingEvent1');
        Course_Catalog__c courseCatalog2 = (Course_Catalog__c)mapTestData.get('courseCatalog2');
        sked__Region__c sanFranciscoRegion = (sked__Region__c)mapTestData.get('sanFranciscoRegion');
        Contact testContact = (Contact)mapTestData.get('testContact');
        sked__Tag__c tagPickup = (sked__Tag__c)mapTestData.get('tagPickup');
        
        Test.startTest();
        
        skedFullServiceBookingGridController.jobSaveModel model = new skedFullServiceBookingGridController.jobSaveModel();
        
        model.trainingEventId = trainingEvent.id;
        model.courseCatalogId = courseCatalog2.id;
        model.selectedDate = Json.serialize(startDate).replace('"', '');
        model.selectedTime = 1000;
        model.classDuration = 180;
        model.breakDuration = 30;
        model.beforeClassDuration = 5;
        model.afterClassDuration = 5;
        model.regionId = sanFranciscoRegion.id;
        model.contactId = testContact.id;
        model.selectedAvEquipments = new List<string>();
        model.test = false;
        model.tagIds = new List<string>();
        model.tagIds.add(tagPickup.Id);
        
        model.address = new skedFullServiceBookingGridController.addressModel();
        model.address.fullAddress = '50 Moraga Ave, San Francisco, CA 94129';
        model.address.lat = 37.787866;
        model.address.lng = -122.441803;
        model.address.city = 'San Francisco';
        model.address.state = 'CA';
        model.address.zip = '94129';
        model.address.territory = '';
        
        model.numberOfBreaks = 1;
        model.numberOfInstructors = 1;
        model.numberOfStudents = 20;
        model.specialInstructions = 'None';

        model.numberOfClasses = 5;

        List<skedFullServiceBookingGridController.jobModel> jobs = new List<skedFullServiceBookingGridController.jobModel>();
        boolean confirm = false;
        skedRemoteResultModel result = skedFullServiceBookingGridController.saveJob(model, jobs, false);
        
        skedFullServiceBookingGridController.populateScheduledJobInfo(trainingEvent.Id);
        
        Test.stopTest();
    }

}