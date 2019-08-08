@isTest
public class skedJobTrigger_Test {
    
    @isTest static void MainTest() {
        Map<string, sObject> mapTestData = skedDataSetup.setupFullServiceTestData();
        sked__job__c pendingAllocationJob = (sked__job__c)mapTestData.get('pendingAllocationJob');
        sked__job__c dispatchjob = (sked__job__c)mapTestData.get('dispatchjob');
        
        skedGoogleApi_Mock mockClass = new skedGoogleApi_Mock();
        mockClass.calloutMethod = 'getGeocode';
        Test.setMock(HttpCalloutMock.class, mockClass);
        
        dispatchjob.sked__Job_Status__c = skedConstants.JOB_STATUS_READY;
        update dispatchjob;
        
        Test.startTest();
        
        pendingAllocationJob.sked__Address__c = '77 Rio Robles, San Jose, CA 95134';
        pendingAllocationJob.Confirmed__c = TRUE;
        update pendingAllocationJob;
        
        dispatchjob.sked__Start__c = dispatchjob.sked__Start__c.addHours(1);
        dispatchjob.sked__Finish__c = dispatchjob.sked__Finish__c.addHours(2);
        dispatchjob.sked__Duration__c = dispatchjob.sked__Duration__c + 60;
        update dispatchjob;
        
        List<sked__job__c> jobs = new List<sked__job__c>();
        pendingAllocationJob.sked__Address__c = '75 Rio Robles, San Jose, CA 95134';
        dispatchjob.sked__Address__c = '75 Rio Robles, San Jose, CA 95134';
        jobs.add(pendingAllocationJob);
        jobs.add(dispatchjob);
        update jobs;
        
        Test.stopTest();
    }
    
}