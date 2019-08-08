@istest
public class sendCaseAutoResponseTest 
{
    static testMethod void testTriggerEmailMessage1()
    {   
        Test.startTest();
        
      
        
        //Switch Custom Settings
        Switch__c  sw = new Switch__c ();
        sw.Name = 'CaseOwnerHistorySwitch';
        sw.Switch__c = false;
        sw.Switch_Description__c = 'Test';
        insert sw;
        
        
        AvoidCustomReplay__c cst=new AvoidCustomReplay__c();
        cst.Name='Sam';
        cst.Email__c='sam123@gmail.com';
        
        insert cst;
        
        
        BlockCase__c bc=new BlockCase__c();
        bc.Name='harish';
        bc.Email__c='voice@unit.com';
        insert bc;
        
        Supplied_Email__c eml=new Supplied_Email__c();
        eml.Name='Hmn';
        eml.Email__c='hmn@gm.com';
        insert eml;
        
       
        
        
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
        
        Case c1 = new Case(Origin = 'Email');
        c1.recordTypeId = serviceCaseRecordTypeId;
        insert c1;
        
        EmailMessage em1 = new EmailMessage(ParentId = c1.Id, Subject = 'MAD', FromAddress = 'voicemessage@unityphone.com', ToAddress = 'testing@unityphone.com', Status = '0');
        insert em1;
    }
    
    static testMethod void testTriggerEmailMessage2()
    {   
        Test.startTest();
        AvoidCustomReplay__c cst=new AvoidCustomReplay__c();
        cst.Name='Sam';
        cst.Email__c='sam123@gmail.com';
        
        insert cst;
        
         BlockCase__c bc=new BlockCase__c();
        bc.Name='harish';
        bc.Email__c='voice@unit.com';
        insert bc;
        
        
        
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
        
        Case c1 = new Case(Origin = 'Email');
        c1.recordTypeId = serviceCaseRecordTypeId;
        insert c1;
        
        EmailMessage em1 = new EmailMessage(ParentId = c1.Id, Subject = 'MAD', FromAddress = 'voicemessage@unityphone.com', ToAddress = 'billing@redcross.org', Status = '0');
        insert em1;
    }
    
    static testMethod void testTriggerEmailMessage3()
    {   
        Test.startTest();
        
        
        
        AvoidCustomReplay__c cst=new AvoidCustomReplay__c();
        cst.Name='Sam';
        cst.Email__c='sam123@gmail.com';
        
        insert cst;
        
        BlockCase__c bc=new BlockCase__c();
        bc.Name='harish';
        bc.Email__c='voice@unit.com';
        insert bc;
        
        
        
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
        
        Case c1 = new Case(Origin = 'Email', Subject = 'DELIVERY FAILURE', Description = 'DELIVERY FAILURE');
        c1.recordTypeId = serviceCaseRecordTypeId;
        insert c1;
        
        EmailMessage em1 = new EmailMessage(ParentId = c1.Id, Subject = 'MAD', FromAddress = 'voicemessage@unityphone.com', ToAddress = 'billing@redcross.org', Status = '0');
        insert em1;
    }
    
    static testMethod void testTriggerEmailMessage4()
    {   
        Test.startTest();
        
        
        
        AvoidCustomReplay__c cst=new AvoidCustomReplay__c();
        cst.Name='Sam';
        cst.Email__c='sam123@gmail.com';
        
        insert cst;
        
        BlockCase__c bc=new BlockCase__c();
        bc.Name='harish';
        bc.Email__c='voicemessage@unityphone.com';
        insert bc;
        
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
        
        Case c1 = new Case(Origin = 'Email');
        c1.recordTypeId = serviceCaseRecordTypeId;
       insert c1;
        
       EmailMessage em1 = new EmailMessage(ParentId = c1.Id, Subject = 'MAD', FromAddress = 'voicemessage@unityphone.com', ToAddress = 'billing@redcross.org', Status = '0');
        insert em1;
    }
}