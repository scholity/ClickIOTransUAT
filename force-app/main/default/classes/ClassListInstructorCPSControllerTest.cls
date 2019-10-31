@isTest
public without sharing class ClassListInstructorCPSControllerTest 
{
    @testSetup
    static void createTestData()
    {
        User u = new User();
        u.FirstName = 'Admin';
        u.LastName = 'User';
        u.Alias = 'admu';
        u.Email = 'admin@user.usr';
        u.Username = '232343admin@user.de';
        u.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
        u.UserRoleId = [Select Id From UserRole Where PortalType = 'None' LIMIT 1].Id;
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';
        insert u;
        
        System.runAs(u) {
            // create custom settings
            Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Bucket Account').getRecordTypeId();
            
            //Bucket Custom settings
            Bucket_Account_Settings__c bas = Bucket_Account_Settings__c.getOrgDefaults();
            bas.Bucket_Account_Owner_ID__c = UserInfo.getUserID();
            bas.Bucket_Account_RecordTypeID__c = recordTypeId;
            bas.Default_Bucket_Name__c = 'Bucket Account';
            bas.Maximum_Size_of_Bucket__c = 5000;
            insert bas;
            
            List<BGST_Profiles__c> ProfilesLists = new List<BGST_Profiles__c>();
            BGST_Profiles__c indivl = new BGST_Profiles__c();
            indivl.name = 'Owner Profile';
            indivl.Sales_User__c = 'ARC BGST Sales User';
            ProfilesLists.add(indivl);
            insert ProfilesLists;
            
            Switch__c esettings = new Switch__c();
            esettings.Name = 'EmailMessageServiceSwitch';
            esettings.Switch_Description__c = 'some desc';
            esettings.Switch__c = false;
            insert esettings;
            
            Account acc = new Account();
            acc.Name = 'TestAccount';
            acc.BillingStreet = '24 Willie Mays Plaza kryan';
            acc.BillingCity = 'San Fran';
            acc.BillingState = 'Cali';
            acc.BillingPostalCode = '94018';
            acc.BillingCountry = 'US';
            acc.Phone = '9876543219';
            acc.OwnerId = u.Id;
            insert acc;
            
            Contact con = new Contact();
            con.FirstName = 'Contact';
            con.LastName = 'Test';
            con.Email = 'testCon@gmail.com';
            con.AccountId = acc.Id;
            insert con;
        }
    }
    
    @isTest
    static void test_getPicklistValues() 
    {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        
        User u = new User();
        u.FirstName = 'Some';
        u.LastName = 'User';
        u.Alias = 'smu';
        u.Email = 'some@user.usr';
        u.Username = '232343some@user.de';
        u.ProfileId = [SELECT Id FROM Profile WHERE Name = 'CloudCraze Customer Community User' LIMIT 1].Id;
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';
        u.ContactId = con.Id;
        insert u;
        
        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        
        System.runAs(u) {
            List<Object> objs = ClassListInstructorCPSController.getPicklistValues('Account', accId);
            System.debug(objs);
        }
    }
    
    @isTest
    static void test_getClasses()
    {
        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        User u = [SELECT Id FROM User WHERE UserName = '232343admin@user.de' LIMIT 1];
        
        // create redwing__Learning
        redwing__Learning__c learning = new redwing__Learning__c();
        learning.Name = 'Test learning';
        learning.redwing__Published__c = true;
        learning.RecordTypeId = Schema.SObjectType.redwing__Learning__c.getRecordTypeInfosByName().get('ILT Class').getRecordTypeId();
        insert learning;
        
        redwing__ILT_Location__c loc = new redwing__ILT_Location__c();
        loc.redwing__City__c = 'Berlin';
        loc.redwing__Address_1__c = 'Kurfurstendamm 194';
        loc.redwing__Country__c = 'Germany';
        loc.redwing__State__c = 'Berlin';
        loc.redwing__Postal_Code__c = '10707';
        insert loc;
        
        //Create ILT Class Record
        Redwing__ILT_Class__c clsRecord = new Redwing__ILT_Class__c();
        clsRecord.Skedulo_Account__c = accId;
        clsRecord.redwing__End_Date__c = system.today() + 6;
        clsRecord.redwing__End_Time__c = '13:00';
        clsRecord.redwing__Start_Date__c = system.today() + 2;// Assuming Start date = End date
        clsRecord.redwing__Start_Time__c = '12:00';
        clsRecord.Name = 'Test';
        clsRecord.Request_Type__c = 'CPS';
        clsRecord.redwing__Learning__c = learning.Id;
        clsRecord.Skedulo_Account__c = accId;
        clsRecord.redwing__Location__c = loc.Id;
        
        insert clsRecord;
        
        System.runAs(u) 
        {
            ClassListInstructorCPSController.getClasses(0, 10, accId, '', '', '');
        }
    }
}