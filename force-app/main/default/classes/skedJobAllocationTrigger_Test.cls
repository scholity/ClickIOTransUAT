@isTest
public class skedJobAllocationTrigger_Test {
    
    @isTest static void MainTest() {
        Map<string, sObject> mapTestData = skedDataSetup.setupFullServiceTestData();
        sked__job__c dispatchjob = (sked__job__c)mapTestData.get('dispatchjob');
        
        dispatchjob.sked__Job_Status__c = skedConstants.JOB_STATUS_READY;
        update dispatchjob;
        
        List<sked__Job_Allocation__c> skedAllocs = [SELECT Id, sked__Status__c
                                                    FROM sked__Job_Allocation__c WHERE sked__Job__c = :dispatchjob.Id];
        for (sked__Job_Allocation__c skedAlloc : skedAllocs) {
            skedAlloc.sked__Status__c = skedConstants.JOB_ALLOCATION_STATUS_CONFIRMED;
        }
        update skedAllocs;
        
        Test.startTest();
        
        for (sked__Job_Allocation__c skedAlloc : skedAllocs) {
            skedAlloc.sked__Status__c = skedConstants.JOB_ALLOCATION_STATUS_DELETED;
        }
        update skedAllocs;
        
        delete skedAllocs;
        
        Test.stopTest();
    }

}