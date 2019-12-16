@isTest
public class ProfileUpdateTest
{
    
    /*@testSetup 
    public static void initTestData()
    {
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SB Organization Account').getRecordTypeId();
        
        Account a = new Account();
        a.Name='SalesforcetestOrg';
        a.DM_External_Id__c ='SalesforcetestOrgtest@test.com';
        a.BillingStreet='24 Willie Mays Plaza';
        a.BillingCity='San Francisco';
        a.BillingState='California';
        a.BillingPostalCode='94017';
        a.BillingCountry='USA';
        a.Phone='9934200234';
        a.recordTypeId = recordTypeId;
        insert a;
        
        //Bucket Custom settings
        Bucket_Account_Settings__c bas = Bucket_Account_Settings__c.getOrgDefaults();
        bas.Bucket_Account_Owner_ID__c = UserInfo.getUserID();
        bas.Bucket_Account_RecordTypeID__c = recordTypeId;
        bas.Default_Bucket_Name__c = 'Bucket Account';
        bas.Maximum_Size_of_Bucket__c = 5000;
        insert bas;
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'SalesforcetestOrg';
        con.Email = 'test@test.com';
        con.AccountId = a.id;
        con.NSSCCConnector__Contact_Status__c = 'Created';
        insert con;
        
        User u = new User();
        u.FirstName = 'Admin';
        u.LastName = 'User';
        u.Alias = 'admu';
        u.Email = 'admin@user.usr';
        u.Username = '232343admin@user.de';
        u.ProfileId = [SELECT Id FROM Profile WHERE Name = 'SB PHSS-IC-Community Plus Login' LIMIT 1].Id;
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';
        u.contactId = con.Id;
        insert u;
        
    }*/
    
    static testMethod void testProfileUpdate ()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name     = 'SB PHSS-IC-Community Plus Login' LIMIT 1];
        User u 	  = [SELECT Id FROM User    WHERE IsActive = true AND ContactId != null AND Profile.Name != 'SB PHSS-IC-Community Plus Login' LIMIT 1];
        
        test.startTest();
        	ProfileUpdate.updateProfile(p.Id, u.Id);
        test.stopTest();
        
    }

}