@IsTest
public with sharing class RCILTViewerCmpCtrlTest {

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
        //        create assignment
        redwing__Learning_Assignment__c assignment = new redwing__Learning_Assignment__c(
                redwing__Learning__c = learningIltClass.Id,
                redwing__User__c = UserInfo.getUserId()
        );
        insert assignment;
        //        create roster
        redwing__ILT_Roster__c roster = new redwing__ILT_Roster__c(
                redwing__ILT_Class__c = iltClass.Id,
                redwing__User__c = UserInfo.getUserId(),
                redwing__Learning_Assignment__c = assignment.Id
        );
        insert roster;
        //        create ilt event
        redwing__Learning__c learningIltEvent = new redwing__Learning__c(
                Name = 'testILTEventLearning',
                RecordTypeId = Schema.SObjectType.redwing__Learning__c.getRecordTypeInfosByName().get('ILT Event').getRecordTypeId()
        );
        insert learningIltEvent;
        redwing__ILT_Event__c iltEvent = new redwing__ILT_Event__c(
                Name = 'testILTEvent',
                redwing__Learning__c = learningIltEvent.Id
        );
        insert iltEvent;
        redwing__ILT_Event_Class__c eventClass = new redwing__ILT_Event_Class__c(
                redwing__ILT_Event__c = iltEvent.Id,
                redwing__Learning__c = learningIltClass.Id
        );
        insert eventClass;
        //        create plan
        redwing__Training_Plan__c plan = new redwing__Training_Plan__c(
                Name = 'testPlan',
                redwing__Language__c = 'en_US',
                Classroom_Setting__c = 'Online'
        );
        insert plan;
        redwing__Training_Plan_Section__c section = new redwing__Training_Plan_Section__c(
                Name = 'section 1',
                redwing__Training_Plan__c = plan.Id
        );
        insert section;
        redwing__Training_Plan_Section_Item__c item = new redwing__Training_Plan_Section_Item__c(
                redwing__Learning__c = learningIltEvent.Id,
                redwing__Training_Plan_Section__c = section.Id
        );
        insert item;
        //        create certificate
        redwing__Achievement__c cert = new redwing__Achievement__c(
                Name = 'testCert',
                redwing__Type__c = 'Certifications'
        );
        insert cert;
        redwing__Training_Plan_Achievement__c ass = new redwing__Training_Plan_Achievement__c(
                redwing__Training_Plan__c = plan.Id,
                redwing__Achievement__c = cert.Id
        );
        insert ass;
    }

    @IsTest
    public static void getDataTest() {
        redwing__Training_Plan__c plan = [SELECT Id FROM redwing__Training_Plan__c LIMIT 1];
        redwing__ILT_Class__c iltClass = [SELECT Id FROM redwing__ILT_Class__c LIMIT 1];


        Test.startTest();
        RCOnlineCompletionCtrl.ResultData result = RCOnlineCompletionCtrl.getData(String.valueOf(iltClass.Id), String.valueOf(plan.Id));
        Test.stopTest();

        System.assertEquals(RCConstants.ANSWER_STATUS_SUCCESS, result.status);
    }
}