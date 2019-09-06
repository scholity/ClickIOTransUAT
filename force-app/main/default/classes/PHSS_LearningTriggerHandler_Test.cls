/**
 * Created by scholity on 2019-09-03.
 */

@isTest
public without sharing class PHSS_LearningTriggerHandler_Test {

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
        
        // Create Learning record (Media)
        redwing__Learning__c learning = new redwing__Learning__c();
        learning.Name = 'Test Learning 123';
        learning.redwing__Published__c = true;
        learning.RecordTypeId = Schema.SObjectType.redwing__Learning__c.getRecordTypeInfosByName().get('Media').getRecordTypeId();
		insert learning;
        
        // training plan
        redwing__Training_Plan__c lplan = new redwing__Training_Plan__c();
        lplan.Name = 'Learning Plan 1';
        insert lplan;
        
        // training plan section
        redwing__Training_Plan_Section__c lplansection = new redwing__Training_Plan_Section__c();
        lplansection.Name = 'Learning Plan 1 Section 1';
        lplansection.redwing__Training_Plan__c = lplan.Id;
        insert lplansection;
        
        // training plan section item
        redwing__Training_Plan_Section_Item__c lplansectionitem = new redwing__Training_Plan_Section_Item__c();
        lplansectionitem.redwing__Training_Plan_Section__c = lplansection.Id;
        lplansectionitem.redwing__Learning__c  = learning.Id;
        insert lplansectionitem;

        Test.startTest();
        redwing__Learning__c learningUpdate = new redwing__Learning__c();
        learningUpdate.Id = learning.Id;
        learningUpdate.Name = 'Test Learning 456'; // Change name to force update
        update learningUpdate;        
        Test.stopTest();
        
        //Validate
        List<Id> learningIds = new List<Id>{learning.Id};
        List<Voucher__c> vouchers = [SELECT Id FROM Voucher__c WHERE Online_Class__c IN :learningIds];
        System.assertEquals(vouchers.size(), 10);


    }
}