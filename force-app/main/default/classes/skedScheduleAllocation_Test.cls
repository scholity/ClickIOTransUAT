@isTest
public class skedScheduleAllocation_Test {
    
    static testmethod void testGetConfig() {
        Map<string, sObject> mapTestData = skedDataSetup.setupScheduleAllocationTestData();
        Training_Events__c trainingEvent = (Training_Events__c)mapTestData.get('trainingEvent1');
        sked__Job__c pendingDispatchJob1 = (sked__Job__c)mapTestData.get('pendingDispatchJob1');
        sked__Resource__c instructor2 = (sked__Resource__c)mapTestData.get('instructor2');
        
        Test.startTest();
        
        skedScheduleAllocationController con1 = new skedScheduleAllocationController(new skedFullServiceBookingGridController());
        skedScheduleAllocationController con2 = new skedScheduleAllocationController(new skedCommunitySchedulingController());
        skedScheduleAllocationController con3 = new skedScheduleAllocationController(new skedCepSchedulingController());
        skedScheduleAllocationController con4 = new skedScheduleAllocationController(new skedNatSchedulingController());
        skedScheduleAllocationController con5 = new skedScheduleAllocationController();
        
        skedScheduleAllocationController.getAllocationConfigData(trainingEvent.Id);
        skedScheduleAllocationController.getAllocationConfigData(pendingDispatchJob1.Id);
        
        Test.stopTest();
    }
    
    static testmethod void testJobAllocation() {
        Map<string, sObject> mapTestData = skedDataSetup.setupScheduleAllocationTestData();
        Training_Events__c trainingEvent = (Training_Events__c)mapTestData.get('trainingEvent1');
        sked__Resource__c instructor1 = (sked__Resource__c)mapTestData.get('instructor1');
        sked__Job__c pendingDispatchJob1 = (sked__Job__c)mapTestData.get('pendingDispatchJob1');
        
        skedGeoservicesApi_Mock mockClass = new skedGeoservicesApi_Mock();
        mockClass.calloutMethod = 'calculateMultiDistances';
        Test.setMock(HttpCalloutMock.class, mockClass);
        
        Test.startTest();
        
        skedRemoteResultModel result = skedScheduleAllocationController.getScheduleAllocationModel(pendingDispatchJob1.Id);
        system.debug('#result#' + result);
        
        Test.stopTest();
    }

    static testmethod void testTrainingEventAllocation() {
        Map<string, sObject> mapTestData = skedDataSetup.setupScheduleAllocationTestData();
        Training_Events__c trainingEvent = (Training_Events__c)mapTestData.get('trainingEvent1');
        sked__Resource__c instructor1 = (sked__Resource__c)mapTestData.get('instructor1');
        
        skedGeoservicesApi_Mock mockClass = new skedGeoservicesApi_Mock();
        mockClass.calloutMethod = 'calculateMultiDistances';
        Test.setMock(HttpCalloutMock.class, mockClass);
        
        Test.startTest();
        
        skedRemoteResultModel result = skedScheduleAllocationController.getScheduleAllocationModel(trainingEvent.Id);
        skedScheduleAllocationController.scheduleAllocationModel model = (skedScheduleAllocationController.scheduleAllocationModel)result.data;
        system.debug('#result#' + result);
        for (skedScheduleAllocationController.jobModel job : model.jobs) {
            for (skedModels.jobAllocation jobAllocation : job.allocations) {
                jobAllocation.action = 'update';
            }
            job.teamLeadResourceId = instructor1.Id;
            skedModels.jobAllocation newAllocation = new skedModels.jobAllocation();
            newAllocation.action = 'create';
            newAllocation.jobId = job.id;
            newAllocation.resourceId = instructor1.Id;
            job.allocations.add(newAllocation);
        }
        result = skedScheduleAllocationController.saveAllocations(model.jobs, false);
        system.debug('#result#' + result);
        
        Test.stopTest();
    }

    static testmethod void testTrainingEventAllocation_notify() {
        Map<string, sObject> mapTestData = skedDataSetup.setupScheduleAllocationTestData();
        Training_Events__c trainingEvent = (Training_Events__c)mapTestData.get('trainingEvent1');
        sked__Resource__c instructor1 = (sked__Resource__c)mapTestData.get('instructor1');
        
        skedGeoservicesApi_Mock mockClass = new skedGeoservicesApi_Mock();
        mockClass.calloutMethod = 'calculateMultiDistances';
        Test.setMock(HttpCalloutMock.class, mockClass);
        
        Test.startTest();
        
        skedRemoteResultModel result = skedScheduleAllocationController.getScheduleAllocationModel(trainingEvent.Id);
        skedScheduleAllocationController.scheduleAllocationModel model = (skedScheduleAllocationController.scheduleAllocationModel)result.data;
        
        for (skedScheduleAllocationController.jobModel job : model.jobs) {
            for (skedModels.jobAllocation jobAllocation : job.allocations) {
                jobAllocation.action = 'delete';
            }
        }
        skedScheduleAllocationController.jobModel firstJob = model.jobs.get(0);
        firstJob.teamLeadResourceId = instructor1.Id;
        skedModels.jobAllocation newAllocation = new skedModels.jobAllocation();
        newAllocation.action = 'create';
        newAllocation.jobId = firstJob.id;
        newAllocation.resourceId = instructor1.Id;
        firstJob.allocations.add(newAllocation);
        skedScheduleAllocationController.saveAllocations(model.jobs, true);
        
        Test.stopTest();
    }
    
}