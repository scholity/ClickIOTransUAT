/**
 * Created by bjarmolinski on 2019-07-01.
 */

@isTest
public without sharing class PHSS_WalkInStudentController_Test {

    @testSetup
    static void createTestDate() {

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

        // run as to make sure that the user has role assigned - necessary for creation of community users later in the test
        System.runAs(u) {

            Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Bucket Account').getRecordTypeId();

            // Custom settings
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

            List<Switch__c> switches = new List<Switch__c>();
            Switch__c esettings = new Switch__c();
            esettings.Name = 'EmailMessageServiceSwitch';
            esettings.Switch_Description__c = 'some desc';
            esettings.Switch__c = false;
            switches.add(esettings);

            Switch__c caseSwitch = new Switch__c();
            caseSwitch.Name = 'CaseOwnerHistorySwitch';
            caseSwitch.Switch__c = false;
            caseSwitch.Switch_Description__c = 'Using this Switch to turn off the CaseOwnerHistory Object...';
            switches.add(caseSwitch);

            insert switches;

            Validation_Rules__c valRule = Validation_Rules__c.getOrgDefaults();
            valRule.Bypass_Rules__c = true;
            insert valRule;
            // ***


            Account a = new Account();
            a.Name = 'SalesforcetestOrg';
            a.BillingStreet = '24 Willie Mays Plaza';
            a.BillingCity = 'San Francisco';
            a.BillingState = 'California';
            a.BillingPostalCode = '94017';
            a.BillingCountry = 'USA';
            a.Phone = '9934200234';
            insert a;

            Contact con = new Contact();
            con.FirstName = 'Contact';
            con.LastName = 'Test';
            con.Email = 'testCon@gmail.com';
            con.AccountId = a.Id;
            insert con;

            // *** sked__Job__c
            sked__Region__c region = new sked__Region__c();
            region.Name = 'TEST REGION';
            region.sked__Timezone__c = 'US/Eastern';
            insert region;

            sked__Location__c location = new sked__Location__c(Name = 'TEST LOCATION');
            location.sked__GeoLocation__Latitude__s = phss_cc_TestDataFactory.TEST_COMMUNITY_CLASS_SEARCH_LOCATION.latitude;
            location.sked__GeoLocation__Longitude__s = phss_cc_TestDataFactory.TEST_COMMUNITY_CLASS_SEARCH_LOCATION.longitude;
            location.sked__Region__c = region.Id;
            insert location;

            Course_Catalog__c courseCatalog = new Course_Catalog__c(Name = 'TEST COURSE CATALOG');
            insert courseCatalog;

            Date now = Date.today();
            sked__Job__c job = new sked__Job__c();
            job.sked__Location__c = location.Id;
            job.Temp_Location__c = location.Name;
            job.Temp_Course__c = courseCatalog.Name;
            job.Start_Date__c = now.format();
            job.Start_Time__c = '12:00';
            job.End_Date__c = now.format();
            job.End_Time__c = '12:30';
            job.sked__Region__c = region.Id;
            insert job;

            redwing__Learning__c learning = new redwing__Learning__c();
            learning.Name = 'Test learning 0';
            learning.redwing__Published__c = true;
            learning.RecordTypeId = Schema.SObjectType.redwing__Learning__c.getRecordTypeInfosByName().get('ILT Class').getRecordTypeId();
            insert learning;

            redwing__ILT_Location__c loc = new redwing__ILT_Location__c();
            loc.Name = 'test loc';
            loc.redwing__Country__c = 'DE';
            loc.redwing__Address_1__c = 'Kurfurstendamm 194';
            loc.redwing__City__c = 'Berlin';
            loc.Skedulo_Address__c = 'Kurfurstendamm 194, Berlin, DE';
            insert loc;

            redwing__Training_Plan__c lp = new redwing__Training_Plan__c(Name = 'TEST TRAINING PLAN');
            insert lp;

            //Create ILT Class Records
            Redwing__ILT_Class__c clsRecord = new Redwing__ILT_Class__c();
            clsRecord.Skedulo_Account__c = a.id;
            clsRecord.redwing__End_Date__c = Date.Parse('12/19/2018');
            clsRecord.redwing__End_Time__c = '13:00';
            clsRecord.redwing__Start_Date__c = Date.Parse('12/19/2018');// Assuming Start date = End date
            clsRecord.redwing__Start_Time__c = '12:00';
            clsRecord.Name = 'Test';
            clsRecord.redwing__Learning__c = learning.Id;
            clsRecord.Is_Stacked_Class__c = true;
            clsRecord.Skedulo_Parent_Job__c = job.Id;
            clsRecord.Skedulo_Job_Id__c = job.Id;
            clsRecord.redwing__Max_Seats__c = 10;
            clsRecord.redwing__location__c = loc.Id;
            clsRecord.Learning_Plan__c = lp.Id;
            insert clsRecord;

            //Create ILT Session record
            redwing__ILT_Session__c sessionRecord = new redwing__ILT_Session__c();
            sessionRecord.redwing__ILT_Class__c = clsRecord.Id;
            sessionRecord.Skedulo_Account__c = a.id;
            //sessionRecord.Skedulo_Address__c = objLocation.id;
            sessionRecord.redwing__End_Time__c = '20:00';
            sessionRecord.redwing__Date__c = Date.Parse('12/19/2018');
            sessionRecord.redwing__Start_Time__c = '08:00';
            sessionRecord.redwing__Location__c = loc.Id;
            insert sessionRecord;
        }
    }

    @isTest
    static void test1() {

        List<Redwing__ILT_Class__c> classes = [SELECT Id FROM Redwing__ILT_Class__c WHERE Skedulo_Account__r.Name = 'SalesforcetestOrg'];

        Test.startTest();
        PHSS_WalkInStudentController.isCommunityClass(classes[0].Id);
        Test.stopTest();
    }

    @isTest
    static void test2() {

        Test.startTest();
        PHSS_WalkInStudentController.initCaseFormWrapper();
        Test.stopTest();
    }

    @isTest
    static void test3() {

        Contact con = [SELECT Id FROM Contact LIMIT 1];
        // create user to run as in order to make sure the user has a role assigned - essential when creating community users

        User u = new User();
        u.FirstName = 'Some';
        u.LastName = 'User';
        u.Alias = 'smu';
        u.Email = 'some@user.usr';
        u.Username = '232343some@user.de';
        u.ProfileId = [SELECT Id FROM Profile WHERE Name = 'Customer Community User' LIMIT 1].Id;
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';
        u.ContactId = con.Id;
        insert u;


        // create instance of PHSS_CaseFormWrapper and serialize to caseJson variable
        PHSS_CaseFormWrapper cfw = new PHSS_CaseFormWrapper();
        cfw.firstName = 'John';
        cfw.lastName = 'Deere';
        cfw.email = 'jdeer@deer123.com';
        cfw.phone = '01743233234';

        String caseJson = JSON.serialize(cfw);

        List<Redwing__ILT_Class__c> classes = [SELECT Id FROM Redwing__ILT_Class__c WHERE Skedulo_Account__r.Name = 'SalesforcetestOrg'];
        String classId = classes[0].Id;

        Test.startTest();
        // runs as community user
        System.runAs(u) {
            PHSS_WalkInStudentController.createCase(caseJson, classId);
        }
        Test.stopTest();
    }
}