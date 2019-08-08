/*****************************************************************************************************
 
Class    :  TestGarbageAccountBatch
Developer:  Krishna Kollu, Joo Kang Blue Wolf Group LLC
Created  :  Feb 12, 2014
Modified :  May 15, 2014
Objective:  This class is used to test the class GarbageAccountBatch
 
*****************************************************************************************************/ 
@isTest
private class TestGarbageAccountBatch {
    @testSetup static void methodName() {
        Switch__c cohstest = new Switch__c();
            cohstest.Switch__c = true;
            cohstest.name = 'CaseOwnerHistorySwitch';
            insert cohstest;
    }  
    private static testMethod void testBatch()
    {
        TestUtil.setupBucketAccountSettings();
        final String CREATED_DATE_FIELD = 'Red_Cross_PO_expiration_Date__c';
        final List<Date> NEW_DATES = new List<Date> {Date.today()-30, Date.today()};
        final List<Date> OLD_DATES = new List<Date> {Date.today()-31, Date.today()-500};
        
        UnitTest.addData(TestUtil.createAccounts(1000,false)).tag('Account').divide(2) 
                                                  .part('Accounts To Be Untouched') 
                                                  .part('Accounts To Mark For Deletion');
        UnitTest.get('Accounts To Mark For Deletion').divide(2).part('Accounts To Mark For Deletion Without Attachments Or Notes').part('Accounts To Mark For Deletion With Attachments Or Notes');
        UnitTest.get('Accounts To Be Untouched').divide(2).part('Accounts To Be Untouched Without Attachments Or Notes').part('Accounts To Be Untouched With Attachments Or Notes');
        
        UnitTest.get('Accounts To Mark For Deletion Without Attachments Or Notes').tag('Accounts Without Attachments Or Notes');
        UnitTest.get('Accounts To Mark For Deletion With Attachments Or Notes').tag('Accounts With Attachments Or Notes');
        UnitTest.get('Accounts To Be Untouched Without Attachments Or Notes').tag('Accounts Without Attachments Or Notes');
        UnitTest.get('Accounts To Be Untouched With Attachments Or Notes').tag('Accounts With Attachments Or Notes');
        
        UnitTest.get('Accounts With Attachments Or Notes').divide(3).part('Accounts With Attachments And Notes').part('Accounts With Attachments And No Notes').part('Accounts With Notes and No Attachments');
        
        UnitTest.get('Accounts To Be Untouched Without Attachments Or Notes').divide(8).part('Accounts With Tasks').part('Accounts With Events')
                                                          .part('Accounts With Contacts').part('Accounts With Opportunities')
                                                          .part('Accounts With Cases').part('Accounts With Contracts')
                                                          .part('Accounts With Contact Roles').part('New Accounts Without Related Objects');
        UnitTest.get('Accounts To Be Untouched With Attachments Or Notes').divide(8).part('Accounts With Tasks').part('Accounts With Events')
                                                          .part('Accounts With Contacts').part('Accounts With Opportunities')
                                                          .part('Accounts With Cases').part('Accounts With Contracts')
                                                          .part('Accounts With Contact Roles').part('New Accounts Without Related Objects');                                                  
        
        UnitTest.get('Account').minus('New Accounts Without Related Objects').property(CREATED_DATE_FIELD).assignFrom(OLD_DATES);
        UnitTest.get('New Accounts Without Related Objects').property(CREATED_DATE_FIELD).assignFrom(NEW_DATES);
        
        UnitTest.get('Account').insertAll();
        
        UnitTest.forEach('Accounts With Cases').create(1,TestUtil.cases).copyProperty('ID->AccountID');
        UnitTest.get(Case.SObjectType).insertAll();
        UnitTest.forEach('Accounts With Contacts').create(1,TestUtil.contacts).copyProperty('ID->AccountID').tag('Contacts');
        UnitTest.get(Contact.SObjectType).insertAll();
        TestGarbageAccountServices.setupRelatedObjects();
        
        Test.startTest();
            Database.executeBatch(new GarbageAccountBatch(CREATED_DATE_FIELD), 2000);
        Test.stopTest();
        
        List<Account> accountsMarkedForDeletion = [Select ID, Flagged_For_Deletion__c, Has_Only_Attachments_Or_Notes__c From Account Where Flagged_For_Deletion__c = true
                                                   AND ID IN: UnitTest.getIds('Account')];
        
        TestGarbageAccountServices.assertAccountsCorrectlyMarked(accountsMarkedForDeletion);
    } 
}