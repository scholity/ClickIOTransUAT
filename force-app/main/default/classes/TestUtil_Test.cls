/**
 * Created by bjarmolinski on 2019-06-27.
 */

@isTest
public without sharing class TestUtil_Test {

    @isTest
    static void test1() {

        //TestUtil.createCases(5, true);
    }

    @isTest
    static void test() {
        TestUtil.setupBucketAccountSettings();
    }

    @isTest
    static void test2() {
        Profile p = TestUtil.SYSTEM_ADMINISTRATOR_PROFILE;
    }

    @isTest
    static void test3() {
        RecordType rc = TestUtil.SERVICE_CASES;
    }

    @isTest
    static void test3_1() {
        User u = TestUtil.BGST_USER;
    }

    @isTest
    static void test3_2() {
        RecordType rt = TestUtil.SERVICE_CASES_READ_ONLY;
    }

    @isTest
    static void test4() {
        TestUtil.AccountContactRoleDG tst = new TestUtil.AccountContactRoleDG();
        tst.generateData(2);
    }

    @isTest
    static void test5() {
        //TestUtil.createAccountContactRole(ID accountID, ID contactID, Boolean doInsert);
    }

    @isTest
    static void test6() {
        TestUtil.ContractDG tst = new TestUtil.ContractDG();
        tst.generateData(2);
    }

    @isTest
    static void test7() {
        //TestUtil.createContracts(ID accountID, Integer howMany, Boolean doInsert);
    }

    @isTest
    static void test8() {
        TestUtil.CaseDG tst = new TestUtil.CaseDG();
        tst.generateData(2);
    }

    @isTest
    static void test9() {
        TestUtil.ContactDG tst = new TestUtil.ContactDG();
        tst.generateData(2);
    }

    @isTest
    static void test10() {
        TestUtil.createContacts(2, false);
    }

    @isTest
    static void test11() {
        TestUtil.NoteDG tst = new TestUtil.NoteDG();
        tst.generateData(2);
    }

    @isTest
    static void test12() {
        //TestUtil.createNotes(ID parentID, 2, true);
    }

    @isTest
    static void test13() {
        TestUtil.AttachmentDG tst = new TestUtil.AttachmentDG();
        tst.generateData(2);
    }

    @isTest
    static void test14() {
        //TestUtil.createAttachments(ID parentID, 2, true);
    }

    @isTest
    static void test15() {
        TestUtil.EventDG tst = new TestUtil.EventDG();
        tst.generateData(2);
    }


    @isTest
    static void test16() {
        TestUtil.createEvents(2, true);
    }

    @isTest
    static void test17() {
        TestUtil.TaskDG tst = new TestUtil.TaskDG();
        tst.generateData(2);
    }

    @isTest
    static void test18() {
        TestUtil.createTasks(2, true);
    }

    @isTest
    static void test19() {
        TestUtil.AccountDG tst = new TestUtil.AccountDG();
        tst.generateData(2);
    }

    @isTest
    static void test20() {

        List<RecordType> accountRecordTypes =  [Select ID From RecordType Where SObjectType='Account' AND IsActive=TRUE];
        Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfos()[0].getRecordTypeId();


        Bucket_Account_Settings__c bas = new Bucket_Account_Settings__c(
                Bucket_Account_Owner_ID__c=UserInfo.getUserID(),
                Default_Bucket_Name__c='Default Name',
                Maximum_Size_of_Bucket__c = 1000,
                Bucket_Account_RecordTypeID__c = accRecTypeId,
                SetupOwnerId =UserInfo.getOrganizationId());

        TestUtil.createBucketAccounts(2, 2, bas, false);
    }

    @isTest
    static void test20_1() {

        //List<RecordType> accountRecordTypes =  [Select ID From RecordType Where SObjectType='Account' AND IsActive=TRUE];
        Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfos()[0].getRecordTypeId();

        Bucket_Account_Settings__c bas = new Bucket_Account_Settings__c(
                Bucket_Account_Owner_ID__c=UserInfo.getUserID(),
                Default_Bucket_Name__c='Default Name',
                Maximum_Size_of_Bucket__c = 1000,
                Bucket_Account_RecordTypeID__c = accRecTypeId,
                SetupOwnerId =UserInfo.getOrganizationId());

        TestUtil.createBucketAccount(2, bas, false);
    }

    @isTest
    static void creatUser_Test() {
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
        TestUtil.createUser('asdsa@sdfdsf.com', profileId, false, null, 'Dow', 'Jones');
    }

    @isTest
    static void test21() {
        TestUtil.pageMessageContains('random string');
    }

    @isTest
    static void test22() {
        TestUtil.OpportunityDG tst = new TestUtil.OpportunityDG();
        tst.generateData(2);
    }

    @isTest
    static void test23() {

        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfos()[0].getRecordTypeId();

        Bucket_Account_Settings__c bas = Bucket_Account_Settings__c.getOrgDefaults();
        bas.Bucket_Account_Owner_ID__c = UserInfo.getUserID();
        bas.Bucket_Account_RecordTypeID__c = recordTypeId;
        bas.Default_Bucket_Name__c = 'Bucket Account';
        bas.Maximum_Size_of_Bucket__c = 5000;
        insert bas;

        Account a = TestUtil.createAccount(true);

        Opportunity o1 = TestUtil.createOpportunity(a.Id, 'New', false);
        Opportunity o2 = TestUtil.createBGSTOpportunity(a.Id, 'New',false);

        TestUtil.createOpportunityLineItem(null, null, false);
    }
}