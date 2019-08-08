@IsTest
public with sharing class RCILTClassroomAndLocationCmpCtrlTest {

    @TestSetup
    public static void setup() {
        //        create account
        Account acc = new Account();
        acc.Name = 'TestAcc';
        insert acc;
        //        create ilt class
        redwing__Learning__c learningIltClass = new redwing__Learning__c(
                Name = 'testILTClassLearning',
                RecordTypeId = Schema.SObjectType.redwing__Learning__c.getRecordTypeInfosByName().get('ILT Class').getRecordTypeId()
        );
        insert learningIltClass;
        redwing__ILT_Class__c iltClass = new redwing__ILT_Class__c(
                Name = 'testILTClass',
                redwing__Start_Date__c = Date.today(),
                redwing__End_Date__c = Date.today(),
                redwing__Learning__c = learningIltClass.Id,
                Skedulo_Account__c = acc.Id
        );
        insert iltClass;
        //        create instructor
        redwing__ILT_Instructor__c instructor = new redwing__ILT_Instructor__c(
                redwing__Instructor__c = UserInfo.getUserId(),
                redwing__ILT_Class__c = iltClass.Id
        );
        insert instructor;
        //        create ilt event
        redwing__Learning__c learningIltEvent = new redwing__Learning__c(
                Name = 'testILTEventLearning',
                RecordTypeId = Schema.SObjectType.redwing__Learning__c.getRecordTypeInfosByName().get('ILT Event').getRecordTypeId()
        );
        //        create location
        redwing__ILT_Location__c loc = new redwing__ILT_Location__c(
                Name = 'test loc',
                redwing__Country__c = 'BY',
                redwing__Address_1__c = 'sovetskaya 80',
                redwing__City__c = 'Brest'
        );
        insert loc;
        //        create session
        redwing__ILT_Session__c session = new redwing__ILT_Session__c(
                Name = 'session',
                redwing__ILT_Class__c = iltClass.Id,
                redwing__Date__c = Date.today(),
                redwing__Location__c = loc.Id
        );
        insert session;
    }

    @IsTest
    public static void getRecordsTest() {
        redwing__ILT_Class__c iltClass = [SELECT Id FROM redwing__ILT_Class__c LIMIT 1];

        Test.startTest();
        RCILTClassroomAndLocationCmpCtrl.ResultData result = RCILTClassroomAndLocationCmpCtrl.getRecords(String.valueOf(iltClass.Id));
        Test.stopTest();

        System.assertEquals(RCConstants.ANSWER_STATUS_SUCCESS, result.status);
    }
}