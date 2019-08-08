@istest
public class sendMailWebCasesTest 
{
    static testMethod void testTriggerSendEmailMessageBilling()
    {   
        Test.startTest();
        
        //Switch Custom Settings
        Switch__c  sw = new Switch__c ();
        sw.Name = 'CaseOwnerHistorySwitch';
        sw.Switch__c = false;
        sw.Switch_Description__c = 'Test';
        insert sw;
        
        Switch__c  sw1 = new Switch__c ();
        sw1.Name = 'EmailMessageServiceSwitch';
        sw1.Switch__c = false;
        sw1.Switch_Description__c = 'Test';
        insert sw1;
        
        //Validation rule
        Validation_Rules__c valRule = Validation_Rules__c.getOrgDefaults();
        valRule.Bypass_Rules__c = false;
        insert valRule;
        
        Id AccrecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Bucket Account').getRecordTypeId();
            
        //Bucket Custom settings
        Bucket_Account_Settings__c bas = Bucket_Account_Settings__c.getOrgDefaults();
        bas.Bucket_Account_Owner_ID__c = UserInfo.getUserID();
        bas.Bucket_Account_RecordTypeID__c = AccrecordTypeId;
        bas.Default_Bucket_Name__c = 'Bucket Account';
        bas.Maximum_Size_of_Bucket__c = 5000;
        insert bas;
        
        Contact con = new Contact();
        con.lastName = 'testing';
        insert con;
        
        Id serviceCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Cases').getRecordTypeId();
        
        Case c1 = new Case(Origin = 'Web to Case');
        c1.recordTypeId = serviceCaseRecordTypeId;
        c1.Type = 'Invoicing';
        c1.Dispute_Issue__c = 'ACH Detail';
        c1.ContactId = con.Id;
        c1.Company_Name__c = 'Test Company';
        c1.Customer_ID__c = 'LMS Code';
        c1.State__c = 'AR';
        insert c1;
    }
    
    static testMethod void testTriggerSendEmailMessage()
    {   
        Test.startTest();
        
        //Switch Custom Settings
        Switch__c  sw = new Switch__c ();
        sw.Name = 'CaseOwnerHistorySwitch';
        sw.Switch__c = false;
        sw.Switch_Description__c = 'Test';
        insert sw;
        
        Switch__c  sw1 = new Switch__c ();
        sw1.Name = 'EmailMessageServiceSwitch';
        sw1.Switch__c = false;
        sw1.Switch_Description__c = 'Test';
        insert sw1;
        
        //Validation rule
        Validation_Rules__c valRule = Validation_Rules__c.getOrgDefaults();
        valRule.Bypass_Rules__c = false;
        insert valRule;
        
        Id AccrecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Bucket Account').getRecordTypeId();
            
        //Bucket Custom settings
        Bucket_Account_Settings__c bas = Bucket_Account_Settings__c.getOrgDefaults();
        bas.Bucket_Account_Owner_ID__c = UserInfo.getUserID();
        bas.Bucket_Account_RecordTypeID__c = AccrecordTypeId;
        bas.Default_Bucket_Name__c = 'Bucket Account';
        bas.Maximum_Size_of_Bucket__c = 5000;
        insert bas;
        
        Id serviceCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Cases').getRecordTypeId();
        
        Case c1 = new Case(Origin = 'Web to Case');
        c1.recordTypeId = serviceCaseRecordTypeId;
        insert c1;
    }
    
    static testMethod void rcspoEmailToPopulateAccount()
    {   
        Test.startTest();
        
        //Switch Custom Settings
        Switch__c  sw = new Switch__c ();
        sw.Name = 'CaseOwnerHistorySwitch';
        sw.Switch__c = false;
        sw.Switch_Description__c = 'Test';
        insert sw;
        
        Switch__c  sw1 = new Switch__c ();
        sw1.Name = 'EmailMessageServiceSwitch';
        sw1.Switch__c = false;
        sw1.Switch_Description__c = 'Test';
        insert sw1;
        
        //Validation rule
        Validation_Rules__c valRule = Validation_Rules__c.getOrgDefaults();
        valRule.Bypass_Rules__c = false;
        insert valRule;
        
        Id AccrecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Bucket Account').getRecordTypeId();
            
        //Bucket Custom settings
        Bucket_Account_Settings__c bas = Bucket_Account_Settings__c.getOrgDefaults();
        bas.Bucket_Account_Owner_ID__c = UserInfo.getUserID();
        bas.Bucket_Account_RecordTypeID__c = AccrecordTypeId;
        bas.Default_Bucket_Name__c = 'Bucket Account';
        bas.Maximum_Size_of_Bucket__c = 5000;
        insert bas;
        
        Id rcspoCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('RCS PO').getRecordTypeId();
        
        Case c1 = new Case(Origin = 'Email');
        c1.recordTypeId = rcspoCaseRecordTypeId;
        c1.SuppliedEmail = 'rcspoTest@gmail.com';
        insert c1;
    }
}