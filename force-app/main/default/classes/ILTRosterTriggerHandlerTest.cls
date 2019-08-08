/************************************************************************************************************************************
** Author: Salesforce Services
** Description: Tests for ILTRosterTriggerHandler and ILTRosterActions 
************************************************************************************************************************************/

@isTest
private class ILTRosterTriggerHandlerTest {

    @testSetup static void setup() {
        // Create portal account owner
        User portalAccountOwner = new User(
            UserRoleId = [Select Id From UserRole Where PortalType = 'None' LIMIT 1].Id,
            ProfileId = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1].Id,
            LastName = 'last22',
            Email = 'test2222@testingARC.com',
            Username = 'test2222@testingARC.com' + System.currentTimeMillis(),
            CompanyName = 'ARC22',
            Title = 'title22',
            Alias = 'test22',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8', 
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert portalAccountOwner; 
        
        Bucket_Account_Settings__c bas = new Bucket_Account_Settings__c();
        bas.Bucket_Account_Owner_ID__c ='005d0000001WOeV';
        bas.Bucket_Account_RecordTypeID__c = '012d000000098Wt';
        bas.Default_Bucket_Name__c = 'Bucket Account';
        bas.Maximum_Size_of_Bucket__c = 5000;
        System.runAs(portalAccountOwner) {
        insert bas;  
        // Create an Account
        Account newAccount = new Account(Name='Bucket Account', OwnerId=UserInfo.getUserId());
        insert newAccount;        
        // Create Contacts
        List<Contact> testContacts = new List<Contact>();
        for(Integer i=0;i<2;i++) {
            testContacts.add(new Contact(FirstName='First1 ' + i, LastName='Last1 ' + i, AccountId=newAccount.Id));
        }
        insert testContacts;             
        }
        // Create user
        Contact c = [SELECT Id, FirstName, LastName FROM Contact WHERE FirstName='First1 0' LIMIT 1];           
        User user1 = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name='Learner Community Profile'].Id,
            LastName = 'last11',
            Email = 'test1111@testingARC.com',
            Username = 'test1111@testingARC.com' + System.currentTimeMillis(),
            CompanyName = 'ARC11',
            Title = 'title11',
            Alias = 'test11',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8', 
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ContactId = c.Id           
        );    
        insert user1;
    }
    
    // Test ILTRoster Before Insert, Before Update
    // Scenario: ILTRoster is created, with contact, no user included
    static testMethod void createILTRoster_createUpdate_withContact() {
        // Create ILTRoster
        User portalAccountOwner = [SELECT Id FROM User WHERE Email='test2222@testingARC.com' LIMIT 1];
        User portalUser = [SELECT Id FROM User WHERE Email='test1111@testingARC.com' LIMIT 1];
        Contact c = [SELECT Id FROM Contact WHERE FirstName='First1 0' LIMIT 1];
        redwing__Learning_Assignment__c la = new redwing__Learning_Assignment__c();
        insert la;
        redwing__ILT_Roster__c roster = new redwing__ILT_Roster__c(Contact__c=c.Id, redwing__Learning_Assignment__c=la.Id);
        System.runAs(portalAccountOwner) {
        insert roster;
        }
        
        // Get ILTRoster
        redwing__ILT_Roster__c r1 = [SELECT Id, Contact__c, redwing__User__c FROM redwing__ILT_Roster__c WHERE Id=:roster.Id LIMIT 1];
        System.assertEquals(r1.redwing__User__c, portalUser.Id);
    }
    
    // Test ILTRoster Before Insert, Before Update
    // Scenario: ILTRoster is created, with user, no contact included
    // Scenario2: ILTRoster is updated, with user, user doesn't have contact
    static testMethod void createILTRoster_createUpdate_withUser() {
        // Get Contact, create ILTRoster
        User portalAccountOwner = [SELECT Id FROM User WHERE Email='test2222@testingARC.com' LIMIT 1];
        User portalUser = [SELECT Id FROM User WHERE Email='test1111@testingARC.com' LIMIT 1];
        Contact c = [SELECT Id FROM Contact WHERE FirstName='First1 0' LIMIT 1];
        redwing__Learning_Assignment__c la = new redwing__Learning_Assignment__c();
        insert la;
        redwing__ILT_Roster__c roster = new redwing__ILT_Roster__c(redwing__User__c=portalUser.Id, redwing__Learning_Assignment__c=la.Id);
        System.runAs(portalAccountOwner) {
        insert roster;
        }
        
        // Get ILTRoster and update Contact field
        redwing__ILT_Roster__c r1 = [SELECT Id, Contact__c, redwing__User__c FROM redwing__ILT_Roster__c WHERE Id=:roster.Id LIMIT 1];
        System.assertEquals(r1.Contact__c,c.Id);
        r1.redwing__User__c = portalAccountOwner.Id;
        System.runAs(portalAccountOwner) {
        update r1;
        }
        redwing__ILT_Roster__c r2 = [SELECT Id, Contact__c, redwing__User__c FROM redwing__ILT_Roster__c WHERE Id=:roster.Id LIMIT 1];
        System.assertEquals(r2.Contact__c, null);
    }
       
}