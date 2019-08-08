/**
 * Created by bjarmolinski on 2019-07-01.
 */

@isTest
public without sharing class PHSS_VoucherTriggerHandler_Test {

    @testSetup
    static void createTestData() {

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

    }
	
    @isTest
    static void test1() {

        Account a = new Account();
        a.Name = 'SalesforcetestOrg';
        a.BillingStreet = '24 Willie Mays Plaza';
        a.BillingCity = 'San Francisco';
        a.BillingState = 'California';
        a.BillingPostalCode = '94017';
        a.BillingCountry = 'USA';
        a.Phone = '9934200234';
        insert a;

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

        //Create ILT Class Records
        Redwing__ILT_Class__c clsRecord = new Redwing__ILT_Class__c();
        clsRecord.Skedulo_Account__c = a.id;
        clsRecord.redwing__End_Date__c = Date.today().addDays(1);
        clsRecord.redwing__End_Time__c = '13:00';
        clsRecord.redwing__Start_Date__c = Date.today().addDays(1);// Assuming Start date = End date
        clsRecord.redwing__Start_Time__c = '12:00';
        clsRecord.Name = 'Test';
        clsRecord.redwing__Learning__c = learning.Id;
        clsRecord.Is_Stacked_Class__c = true;
        clsRecord.Skedulo_Parent_Job__c = job.Id;
        clsRecord.Skedulo_Job_Id__c = job.Id;
        clsRecord.redwing__Max_Seats__c = 10;
        insert clsRecord;

        // training plan
        redwing__Training_Plan__c lPlan = new redwing__Training_Plan__c();
        lPlan.Name = 'Plan';
        insert lPlan;

        List<Voucher__c> vs = new List<Voucher__c>();
        Voucher__c v1 = new Voucher__c();
        v1.ILT_Class__c = clsRecord.id;
        v1.Learning_Plan__c = lPlan.Id;
        v1.Status__c = 'Claimed';
        vs.add(v1);

        Voucher__c v2 = new Voucher__c();
        v2.ILT_Class__c = clsRecord.id;
        v2.Learning_Plan__c = lPlan.Id;
        v2.Status__c = 'Issued';
        v2.Online_Class__c = learning.Id;
        vs.add(v2);

        Voucher__c v3 = new Voucher__c();
        v3.ILT_Class__c = clsRecord.id;
        v3.Learning_Plan__c = lPlan.Id;
        v3.Status__c = 'Issued';
        vs.add(v3);

        Voucher__c v4 = new Voucher__c();
        v4.ILT_Class__c = clsRecord.id;
        v4.Learning_Plan__c = lPlan.Id;
        v4.Status__c = 'Issued';
        vs.add(v4);

        insert vs;

        v1.Status__c = 'Issued';
        v2.Status__c = 'Void';
        v3.Status__c = 'Claimed';
        v4.Status__c = 'Blocked';

        Test.startTest();
        update vs;
        Test.stopTest();

    }

    @isTest
    static void test2() {

        Account a = new Account();
        a.Name = 'SalesforcetestOrg';
        a.BillingStreet = '24 Willie Mays Plaza';
        a.BillingCity = 'San Francisco';
        a.BillingState = 'California';
        a.BillingPostalCode = '94017';
        a.BillingCountry = 'USA';
        a.Phone = '9934200234';
        insert a;

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

        //Create ILT Class Records
        List<Redwing__ILT_Class__c> classes = new List<Redwing__ILT_Class__c>();
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
        clsRecord.redwing__Max_Seats__c = 0;
        insert clsRecord;

        insert classes;

        // training plan
        redwing__Training_Plan__c lPlan = new redwing__Training_Plan__c();
        lPlan.Name = 'Plan';
        insert lPlan;

        Voucher__c v5 = new Voucher__c();
        v5.ILT_Class__c = clsRecord.id;
        v5.Learning_Plan__c = lPlan.Id;
        v5.Status__c = 'Reserved';
        insert v5;

        v5.Status__c = 'Issued';

        Test.startTest();
        update v5;
        Test.stopTest();
    }
}