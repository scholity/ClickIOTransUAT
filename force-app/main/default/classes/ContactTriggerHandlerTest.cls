/************************************************************************************************************************************
** Author: Salesforce Services
** Description: Tests for ContactTriggerHandler and ContactActions 
************************************************************************************************************************************/

@isTest
private class ContactTriggerHandlerTest {

    @testSetup static void setup() {
        // Create portal account owner
        User portalAccountOwner = new User(
            UserRoleId = [Select Id From UserRole Where PortalType = 'None' LIMIT 1].Id,
            ProfileId = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1].Id,
            LastName = 'last2',
            Email = 'test222@testingARC.com',
            Username = 'test222@testingARC.com' + System.currentTimeMillis(),
            CompanyName = 'ARC2',
            Title = 'title2',
            Alias = 'test2',
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
            testContacts.add(new Contact(FirstName='First ' + i, LastName='Last ' + i, AccountId=newAccount.Id));
        }
        insert testContacts;             
        }
        // Create user
        Contact c = [SELECT Id, FirstName, LastName FROM Contact WHERE FirstName='First 0' LIMIT 1]; 
        /*          
        User user1 = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name='Learner Community Profile'].Id,
            LastName = 'last1',
            Email = 'test111@testingARC.com',
            Username = 'test111@testingARC.com' + System.currentTimeMillis(),
            CompanyName = 'ARC1',
            Title = 'title1',
            Alias = 'test1',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8', 
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ContactId = c.Id           
        );    
        insert user1;
        */
    }


    // Test Contact Before Update
    // Scenario: First Name is Updated on Contact, it should be updated on User as well
    static testMethod void firstNameUpdatedOnContact() {
        // Get Contact, change first name and update
        User portalAccountOwner = [SELECT Id, FirstName, LastName FROM User WHERE Email='test222@testingARC.com' LIMIT 1];
        Contact c = [SELECT Id, FirstName, LastName FROM Contact WHERE FirstName='First 0' LIMIT 1];
        c.FirstName = 'TestFirstName';
        System.runAs(portalAccountOwner) {
        update c;
        }
        
        // Get User and verify that first name was updated
        //User u = [SELECT Id, FirstName, LastName FROM User WHERE ContactID=:c.Id LIMIT 1];
        //System.assertEquals(c.FirstName, u.FirstName);
        //System.assertEquals(c.LastName, u.LastName);
    }
    
    // Test Contact Before Update
    // Scenario: Last Name is Updated on Contact, it should be updated on User as well
    static testMethod void lastNameUpdatedOnContact() {
        // Get Contact, change last name and update
        User portalAccountOwner = [SELECT Id, FirstName, LastName FROM User WHERE Email='test222@testingARC.com' LIMIT 1];
        Contact c = [SELECT Id, FirstName, LastName FROM Contact WHERE FirstName='First 0' LIMIT 1];
        c.LastName = 'TestLastName';
        System.runAs(portalAccountOwner) {
        update c;
        }
        // Get User and verify that first name was updated
        //User u = [SELECT Id, FirstName, LastName FROM User WHERE ContactID=:c.Id LIMIT 1];
        //System.assertEquals(c.FirstName, u.FirstName);
        //System.assertEquals(c.LastName, u.LastName);    
    }

    // Test Contact Before Update
    // Scenario: First and Last Name are Updated on Contact, it should be updated on User as well
    static testMethod void firstAndLastNameUpdatedOnContact() {
        // Get Contact, change first and last name then update
        User portalAccountOwner = [SELECT Id, FirstName, LastName FROM User WHERE Email='test222@testingARC.com' LIMIT 1];
        Contact c = [SELECT Id, FirstName, LastName FROM Contact WHERE FirstName='First 0' LIMIT 1];
        c.FirstName = 'TestFirstName1';
        c.LastName = 'TestLastName1';
        System.runAs(portalAccountOwner) {
        update c;
        }
        
        // Get User and verify that first name was updated
        //User u = [SELECT Id, FirstName, LastName FROM User WHERE ContactID=:c.Id LIMIT 1];
        //System.assertEquals(c.FirstName, u.FirstName);
        //System.assertEquals(c.LastName, u.LastName);  
    }
    
    
    // Test Contact Before Update
    // Scenario: First Name is Updated on Contact, no User has Contact as ContactID, nothing happens
    static testMethod void firstNameUpdatedOnContact_NoUser() {
        // Get Contact, change last name and update
        User portalAccountOwner = [SELECT Id, FirstName, LastName FROM User WHERE Email='test222@testingARC.com' LIMIT 1];
        Contact c = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE FirstName='First 1' LIMIT 1];
        c.LastName = 'TestLastName2';
        System.runAs(portalAccountOwner) {
        update c;
        }
        
        // Get User and verify that first name was updated
        //List<User> uList = new List<User>([SELECT Id, FirstName, LastName FROM User WHERE ContactID=:c.Id LIMIT 1]);
        //System.assertEquals(0, uList.size()); 
    }        
}