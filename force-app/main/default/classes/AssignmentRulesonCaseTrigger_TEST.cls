@isTest
private class AssignmentRulesonCaseTrigger_TEST {
    private static final Integer NUMBER_OF_RECORDS = 200;

    @testSetup private static void setup() {
         Validation_Rules__c supportConfig = new Validation_Rules__c();      
    supportConfig.Bypass_Rules__c = false;
    //supportConfig.Bypass_Custom_Validation__c = true; 
    insert supportConfig;
        insert PHSS_TestUtility.createCaseHistorySwitch(false);
    }

    @isTest private static void trigger_test() {
        List<Case> cases = new List<Case>();
        for(Integer i = 0; i < NUMBER_OF_RECORDS; i++) {
            cases.add(PHSS_TestUtility.createCase());
        }
        Test.startTest();
        insert cases;
        Test.stopTest();
        System.assertNotEquals(0, [SELECT Id FROM Case].size());
        System.assertNotEquals(0, [SELECT Id, SObjectType, QueueId FROM QueueSobject].size());
    }
}