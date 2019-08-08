@isTest
public class skedSkeduloApiManager_Test {
    
    static testmethod void TestDispatchJobAllocationApi() {
        Map<string, sObject> mapTestData = skedDataSetup.setupFullServiceTestData();
        sked__Resource__c instructor1 = (sked__Resource__c)mapTestData.get('instructor1');
        sked__Job__c pendingDispatchjob = (sked__Job__c)mapTestData.get('pendingDispatchjob');
        
        Set<Id> jobIds = new Set<Id>();
        jobIds.add(pendingDispatchjob.Id);
        
        Test.startTest();
        Map<Id, sked__Job_Allocation__c> mapAllocation = new Map<Id, sked__Job_Allocation__c>([SELECT Id 
                                                                                               FROM sked__Job_Allocation__c 
                                                                                               WHERE sked__Job__c IN :jobIds]);
                
        skedSkeduloApiManager_MockTest mockClass = new skedSkeduloApiManager_MockTest();
        mockClass.resourceId = instructor1.Id;
        Test.setMock(HttpCalloutMock.class, mockClass);
        
        mockClass.calloutMethod = 'dispatch';
        skedSkeduloApiManager.dispatchJobAllocations(mapAllocation.keySet());
        
        mockClass.calloutMethod = 'dispatch_error';
        skedSkeduloApiManager.dispatchJobAllocations(mapAllocation.keySet());
        
        Test.stopTest();
    }

    static testmethod void TestDispatchJobApi() {
        Map<string, sObject> mapTestData = skedDataSetup.setupFullServiceTestData();
        sked__Resource__c instructor1 = (sked__Resource__c)mapTestData.get('instructor1');
        sked__Job__c pendingDispatchjob = (sked__Job__c)mapTestData.get('pendingDispatchjob');
        
        Set<Id> jobIds = new Set<Id>();
        jobIds.add(pendingDispatchjob.Id);
        
        Test.startTest();
        Map<Id, sked__Job__c> mapJob = new Map<Id, sked__Job__c>([SELECT Id FROM sked__Job__c]);
                
        skedSkeduloApiManager_MockTest mockClass = new skedSkeduloApiManager_MockTest();
        mockClass.resourceId = instructor1.Id;
        Test.setMock(HttpCalloutMock.class, mockClass);
        
        mockClass.calloutMethod = 'dispatch';
        skedSkeduloApiManager.dispatchJobs(mapJob.keySet());
        
        mockClass.calloutMethod = 'dispatch_error';
        skedSkeduloApiManager.dispatchJobs(mapJob.keySet());
        
        mockClass.calloutMethod = 'dispatch_error_salesforce_side';
        skedSkeduloApiManager.dispatchJobs(jobIds);
        
        Test.stopTest();
    }

    static testmethod void TestDispatchJobApiError1() {
        Map<string, sObject> mapTestData = skedDataSetup.setupFullServiceTestData();
        sked__Resource__c instructor1 = (sked__Resource__c)mapTestData.get('instructor1');
        sked__Job__c pendingDispatchjob = (sked__Job__c)mapTestData.get('pendingDispatchjob');
        
        Set<Id> jobIds = new Set<Id>();
        jobIds.add(pendingDispatchjob.Id);
        
        Test.startTest();
                
        skedSkeduloApiManager_MockTest mockClass = new skedSkeduloApiManager_MockTest();
        mockClass.resourceId = instructor1.Id;
        Test.setMock(HttpCalloutMock.class, mockClass);
        
        mockClass.calloutMethod = 'dispatch_error';
        skedSkeduloApiManager.dispatchJobs(jobIds);
        
        Test.stopTest();
    }

    static testmethod void TestDispatchJobApiError2() {
        Map<string, sObject> mapTestData = skedDataSetup.setupFullServiceTestData();
        sked__Resource__c instructor1 = (sked__Resource__c)mapTestData.get('instructor1');
        sked__Job__c pendingDispatchjob = (sked__Job__c)mapTestData.get('pendingDispatchjob');
        
        Set<Id> jobIds = new Set<Id>();
        jobIds.add(pendingDispatchjob.Id);
        
        Test.startTest();       
        
        skedSkeduloApiManager_MockTest mockClass = new skedSkeduloApiManager_MockTest();
        mockClass.resourceId = instructor1.Id;
        Test.setMock(HttpCalloutMock.class, mockClass);
        
        mockClass.calloutMethod = 'dispatch_error_salesforce_side';
        skedSkeduloApiManager.dispatchJobs(jobIds);
        
        Test.stopTest();
    }
    
    //Below test are for code coverage of skedSkeduloApiData
    static testmethod void TestSkedSkeduloApiData(){
        try {
            throw new skedCalloutException(400, 'error', 'response');
        }
        catch (skedCalloutException ex) {
            
        }
        
        skedSkeduloApiData.dispatchJobData response = new skedSkeduloApiData.dispatchJobData();
        System.debug(response.jobId);
        System.debug(response.resourceId);
        System.debug(response.dts);
        System.debug(response.protocol);
        System.debug(response.referenceId);
    }
    
}