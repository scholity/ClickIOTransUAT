@isTest
private class PHSS_CaseHandler_TEST {
    private static final Integer NUMBER_OF_RECORDS = 200;

    @testSetup private static void setup() {
        insert PHSS_TestUtility.createCaseHistorySwitch(false);
        Validation_Rules__c supportConfig = new Validation_Rules__c();      
    supportConfig.Bypass_Rules__c = false;
    //supportConfig.Bypass_Custom_Validation__c = true; 
    insert supportConfig;
    }

    @isTest static void afterInsert() {
        List<Case> cases = new List<Case>();
        String picklistValue = new List<String>(PHSS_TestUtility.getPicklistValues('Case', 'Question_type__c').keySet()).get(0);
        for(Integer i = 0; i < NUMBER_OF_RECORDS; i++) {
            cases.add(PHSS_TestUtility.createCase(picklistValue));
        }
        Test.startTest();
        insert cases;
        Test.stopTest();
        Set<Id> caseIds = new Map<Id, Case>(cases).keySet();
        System.assertNotEquals(0, [SELECT Id FROM Case WHERE Id IN :caseIds].size());
    }
    
    @isTest static void cover_rest(){
        PHSS_CaseHandler instance = new PHSS_CaseHandler();
        instance.beforeInsert(new List<SObject>());
        instance.beforeUpdate(new Map<Id, SObject>(), new Map<Id, SObject>());
        instance.beforeDelete(new Map<Id, SObject>());
        instance.afterUpdate(new Map<Id, SObject>(), new Map<Id, SObject>());
        instance.afterDelete(new Map<Id, SObject>());
        instance.afterUndelete(new Map<Id, SObject>());
    }
}