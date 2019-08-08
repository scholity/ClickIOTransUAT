/*****************************************************************************************************
 
Class    :  TestGarbageAccountServices
Developer:  Krishna Kollu, Joo Kang Blue Wolf Group LLC
Created  :  Feb 12, 2014
Modified :  May 15, 2014
Objective:  This class is used to test the class GarbageAccountServices
 
*****************************************************************************************************/ 
@isTest
public class TestGarbageAccountServices {
    

    public static testMethod void testErrorEmails()
    {
        final String emailOne = 'joo@redcross.com';
        final String emailTwo = 'kang@redcross.com';
        List<Error_Emails__c> customSettings = new List<Error_Emails__c>();
        customSettings.add(new Error_Emails__c(Name='Test', Email__c = emailOne));
        customSettings.add(new Error_Emails__c(Name='Test2', Email__c = emailTwo));
        insert customSettings;
        Test.startTest();
            List<String> emails = GarbageAccountServices.errorEmails;
        Test.stopTest();
        
        System.assertEquals(new Set<String>{emailOne,emailTwo}, new Set<String>(emails), 'We expect to correctly load the email address to which we will send an error if the batch fails');
    }
    
    /**
     * This function creates tasks/contact roles/events/opportunities/contracts/attachments/notes for accounts that have the following tags:
     *  'Accounts With Tasks','Accounts With Events','Accounts With Opportunities','Accounts With Contracts', 'Accounts With Contact Roles'
     *  'Accounts With Attachments And Notes', 'Accounts With Attachments And No Notes', 'Accounts With Notes and No Attachments'
    */
    public static void setupRelatedObjects()
    {
        UnitTest.forEach('Accounts With Tasks').create(2,TestUtil.tasks).copyProperty('ID->WhatID');
        UnitTest.get(Task.SObjectType).insertAll();
        UnitTest.forEach('Accounts With Events').create(1,TestUtil.events).copyProperty('ID->WhatID');
        UnitTest.get(Event.SObjectType).insertAll();
        
        UnitTest.forEach('Accounts With Opportunities').create(2,TestUtil.opportunities).copyProperty('ID->AccountID');
        UnitTest.get(Opportunity.SObjectType).insertAll();
        
        UnitTest.forEach('Accounts With Contracts').create(1,TestUtil.contracts).copyProperty('ID->AccountID');
        UnitTest.get(Contract.SObjectType).insertAll();
        UnitTest.forEach('Accounts With Contact Roles').create(2,TestUtil.accountContactRoles).copyProperty('ID->AccountID');
        UnitTest.get(AccountContactRole.SObjectType).property('ContactID').assignFrom('Contacts').insertAll();
        
        UnitTest.get('Accounts With Attachments And Notes').tag('Accounts With Attachments').tag('Accounts With Notes');
        UnitTest.get('Accounts With Attachments And No Notes').tag('Accounts With Attachments');
        UnitTest.get('Accounts With Notes and No Attachments').tag('Accounts With Notes');
        UnitTest.forEach('Accounts With Attachments').create(2,TestUtil.attachments).copyProperty('ID->ParentID');
        UnitTest.forEach('Accounts With Notes').create(1,TestUtil.notes).copyProperty('ID->ParentID');
        UnitTest.get(Attachment.SObjectType).insertAll();
        UnitTest.get(Note.SObjectType).insertAll();
    }
    
    /**
    *   This function performs the following assertions:
    *       1) The scope includes only the accounts with the tag 'Accounts To Mark For Deletion' 
    *       2) The scope includes all the accounts with the tag 'Accounts To Mark For Deletion' 
    *       3) Every account in the scope has been flagged as marked for deletion
    *       4) For any account in the scope with the tag 'Accounts With Attachments Or Notes' and 'Accounts To Mark For Deletion',
    *          that account must be flagged as having only attachments or notes
    */
    public static void assertAccountsCorrectlyMarked(List<Account> scope)
    {
        UnitTest.analyze('Accounts To Mark For Deletion').assertEquivalence(scope, 'We expect to correctly identify which accounts should be marked for deletion');
        for(Account a : scope)
        {
            System.assert(a.Flagged_For_Deletion__c, 'For any account which does not have any task, event, contact, contact roles, opportunities, cases, or contacts, we must flag the account for deletion');
            if(UnitTest.analyze('Accounts With Attachments Or Notes').hasId(a.ID))
            {
                System.assert(a.Has_Only_Attachments_Or_Notes__c, 'For any account which is flagged for deletion and has attachments and/or notes, we must flag the account as having only attachments or notes');
            }
        }
    }
    public static testMethod void testMarkAccountFlags()
    {
        TestUtil.setupBucketAccountSettings();
        UnitTest.createTestData(TestUtil.accounts).many(1000).tag('Account').divide(2)
                                                  .part('Accounts To Be Untouched') 
                                                  .part('Accounts To Mark For Deletion');
        UnitTest.get('Accounts To Mark For Deletion').divide(2).part('Accounts Without Attachments Or Notes').part('Accounts With Attachments Or Notes');
        UnitTest.get('Accounts To Be Untouched').divide(2).part('Accounts To Be Untouched Without Attachments Or Notes').part('Accounts To Be Untouched With Attachments Or Notes');
        UnitTest.get('Accounts To Be Untouched Without Attachments Or Notes').tag('Accounts Without Attachments Or Notes');
        UnitTest.get('Accounts To Be Untouched With Attachments Or Notes').tag('Accounts With Attachments Or Notes');
        
        UnitTest.get('Accounts With Attachments Or Notes').divide(3).part('Accounts With Attachments And Notes').part('Accounts With Attachments And No Notes').part('Accounts With Notes and No Attachments');
        UnitTest.get('Accounts To Be Untouched Without Attachments Or Notes').divide(5).part('Accounts With Tasks').part('Accounts With Events')
                                                          .part('Accounts With Opportunities')
                                                          .part('Accounts With Contracts')
                                                          .part('Accounts With Contact Roles');
        UnitTest.get('Accounts To Be Untouched With Attachments Or Notes').divide(5).part('Accounts With Tasks').part('Accounts With Events')
                                                          .part('Accounts With Opportunities')
                                                          .part('Accounts With Contracts')
                                                          .part('Accounts With Contact Roles');                                               
        
        UnitTest.get('Account').insertAll();
        UnitTest.createTestData(TestUtil.contacts).many(20).tag('Contacts').insertAll();
        
        setupRelatedObjects();
        
        List<Account> accountsQueried = [Select ID, (Select ID From Attachments Limit 1), (Select ID From Notes Limit 1), 
                                                    (Select ID From Tasks Limit 1), (Select ID From Events Limit 1),
                                                    (Select ID From Contracts Limit 1), (Select ID From Opportunities Limit 1), 
                                                    (Select ID From AccountContactRoles Limit 1) From Account
                                                    Where ID IN: UnitTest.getIds('Account')];
        Test.startTest();
            List<Account> retAccounts = GarbageAccountServices.markAccountFlags(accountsQueried);
        Test.stopTest();
        
        assertAccountsCorrectlyMarked(retAccounts);
    }
}