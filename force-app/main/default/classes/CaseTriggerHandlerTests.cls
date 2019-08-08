@IsTest
private class CaseTriggerHandlerTests 
{
    @IsTest
    private static void test_handler() 
    {
        Case c = [Select Id From Case Limit 1];
        
        c.First_ARC_Response_Date_Time__c = Datetime.newInstance(2018, 1, 2, 9, 30, 0);
        c.First_Response_Time_Minutes__c = null;

        c.Second_Customer_Post_Date_Time__c = Datetime.newInstance(2018, 1, 1, 7, 30, 0);
        c.Second_ARC_Response_Date_Time__c = Datetime.newInstance(2018, 1, 1, 9, 30, 0);
        c.Second_Response_Time_Minutes__c = null;

        c.Third_Customer_Post_Date_Time__c = Datetime.newInstance(2018, 1, 6, 5, 0, 0);
        c.Third_ARC_Response_Date_Time__c = Datetime.newInstance(2018, 1, 6, 23, 0, 0);
        c.Third_Response_Time_Minutes__c = null;

        Test.startTest();
        update c;
        Test.stopTest();

        c = [Select Id,First_Response_Time_Minutes__c,Second_Response_Time_Minutes__c,Third_Response_Time_Minutes__c From Case Limit 1];

        System.assert(c.First_Response_Time_Minutes__c < 0);//hard to test this case with any certainty as the first customer post date is the createdDate
        System.assert(c.Second_Response_Time_Minutes__c == 120);
        System.assert(c.Third_Response_Time_Minutes__c == 750);
    }

    @TestSetup
    private static void setup() 
    {
        //Switch Custom Settings
        Switch__c  sw = new Switch__c ();
        sw.Name = 'CaseOwnerHistorySwitch';
        sw.Switch__c = false;
        sw.Switch_Description__c = 'Test';
        insert sw;
        
        //Validation rule
        Validation_Rules__c valRule = Validation_Rules__c.getOrgDefaults();
        valRule.Bypass_Rules__c = false;
        insert valRule;

        Account a = new Account(
            Name = 'TESTING'
        );
        insert a;

        Id socialCaseRecordTypeId = [SELECT Id From RecordType Where SObjectType = 'Case' And DeveloperName = 'Social_Case' Limit 1][0].Id;
        
        Case c = new Case(
            AccountId = a.Id,
            OwnerId = UserInfo.getUserId(),
            RecordTypeId = socialCaseRecordTypeId
        );
        insert c;
    }
}