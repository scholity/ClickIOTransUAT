/**
 * Created by bjarmolinski on 2019-06-26.
 */

@isTest
public with sharing class PHSS_PublishCertificates_Test {

    @testSetup
    static void createDate() {

        // custom settings
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

//        // user in case need for Instructor__c
//        User usr = new User(LastName = 'LIVESTON',
//                FirstName='JASON',
//                Alias = 'jliv',
//                Email = 'jason.liveston@asdf.com',
//                Username = 'jason.liveston@asdf.com',
//                ProfileId = profileIdnew.id,
//                ContactId = c.id,
//                TimeZoneSidKey = 'GMT',
//                LanguageLocaleKey = 'en_US',
//                EmailEncodingKey = 'UTF-8',
//                LocaleSidKey = 'en_US'
//        );
//        insert usr;

        // account
        Account a = new Account();
        a.Name='SalesforcetestOrg';
        a.BillingStreet='24 Willie Mays Plaza';
        a.BillingCity='San Francisco';
        a.BillingState='California';
        a.BillingPostalCode='94017';
        a.BillingCountry='USA';
        a.Phone='9934200234';
        insert a;

        redwing__Learning__c learning0 = new redwing__Learning__c();
        learning0.Name = 'Test learning 0';
        learning0.redwing__Published__c = true;
        learning0.RecordTypeId = Schema.SObjectType.redwing__Learning__c.getRecordTypeInfosByName().get('ILT Class').getRecordTypeId();
        insert learning0;

        // ILT class
        Redwing__ILT_Class__c clsRecord = new Redwing__ILT_Class__c();
        clsRecord.Skedulo_Account__c = a.id;
        clsRecord.redwing__End_Date__c = Date.Parse('12/19/2018');
        clsRecord.redwing__End_Time__c= '13:00';
        clsRecord.redwing__Start_Date__c = Date.Parse('12/19/2018');// Assuming Start date = End date
        clsRecord.redwing__Start_Time__c = '12:00';
        clsRecord.Name = 'Test';
        clsRecord.redwing__Learning__c = learning0.Id;
        insert clsRecord;

        // instructor
        redwing__ILT_Instructor__c instructorrecord = new redwing__ILT_Instructor__c();
        instructorrecord.redwing__Instructor__c= UserInfo.getUserId();
        instructorrecord.redwing__ILT_Class__c=clsRecord.id;
        insert instructorrecord;

        // achievement category
        redwing__Achievement_Category__c rac = new redwing__Achievement_Category__c();
        rac.name = 'Skill';
        insert rac;

        // achievement
        redwing__Achievement__c ra = new redwing__Achievement__c();
        ra.redwing__Achievement_Category__c = rac.id;
        ra.redwing__Type__c = 'Certifications';
        ra.redwing__Expiration_Term__c = 1;
        ra.redwing__Expiration_Date__c = Date.today().addMonths(12);
        ra.Description__c = 'Test achievement';
        ra.redwing__Expiration_Term_Basis__c = 'Years';
        insert ra;


        // achievement assignment
        //Create Achievement Assignment
        redwing__Achievement_Assignment__c raa = new redwing__Achievement_Assignment__c();
        raa.ILT_Class__c=clsRecord.id;
        //raa.redwing__Training_Plan_Achievement__c=tpa.Id;
        raa.External_Id__c='someid@asd.com'+clsRecord.id;
        raa.redwing__status__c = 'Acquired';
        raa.Firstname__c = 'John';
        raa.Lastname__c = 'Doe';
        raa.redwing__Achievement__c = ra.Id;
        insert raa;



    }

    @isTest
    static void test1() {

        PHSS_PublishCertificates inst = new PHSS_PublishCertificates();
        inst.getAllCertificates();

    }

    @isTest
    static void test2() {
        PHSS_PublishCertificates inst = new PHSS_PublishCertificates();
        inst.getCertificates();
    }

}