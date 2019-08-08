@isTest
private class TestSurveyService 
{
    @testSetup static void methodName() 
    {
        Switch__c cohstest = new Switch__c();
        cohstest.Switch__c = false;
        cohstest.name = 'CaseOwnerHistorySwitch';
        insert cohstest;
    }     
    static
    {
        TestUtil.setupBucketAccountSettings();
    }
    
    static testMethod void testMethodCreate()
    {
        //for Validation rule
        Validation_Rules__c supportConfig = Validation_Rules__c.getOrgDefaults();
        supportConfig.Bypass_Rules__c = false;        
        upsert supportConfig Validation_Rules__c.Id; 
        
        Account acc1 = new Account(Name = 'Acc1');
        
        insert acc1;
        
        Contact ct1 = new Contact(FirstName = 'Test', LastName = 'Test2', AccountId = acc1.Id);
        insert ct1;
        
        Case c = new Case(ContactId = ct1.Id, AccountId = acc1.Id);
        
        insert c;
        
        ReportCard__c rCard1  = new ReportCard__c(Case__c = c.Id, Account__c = acc1.Id, Contact__c = ct1.Id);
        
        insert rCard1;
        
        Map<Id, ReportCard__c> newMap = new Map<Id, ReportCard__c>();
        newMap.put(rCard1.Id, rCard1);
        
        SurveyService.addCaseOwnerToReportCard(newMap);
    }

    static testMethod void testUpdateContactSurveySentTimestamp() 
    {
        
    }
    
    private static Map<Id, Case> createTestData(){
        
        Map<Id, Case> casesMap = new Map<Id, Case>();
        
        Contact ct1 = new Contact(FirstName = 'Test', LastName = 'Contact 1', Email = 'somewhere@123testsomewhere.com');
        
        insert ct1;
        
        Case c1 = new Case(ContactId = ct1.Id, Subject = 'Test Case 1', Description = 'Test Case Description');
        
        insert c1;
        
        return casesMap;
    }
    
    static testMethod void testMethodUpdate()
    {
        String ADMIN_USER = 'System Administrator';
        List<Profile> adminProfile = [Select Id from Profile WHERE Name = :ADMIN_USER];      
      
        User u1 = new User(FirstName = 'tst_', LastName = 'user1',ProfileId = adminProfile[0].id, Email='standarduser1@testorg.com', 
                         EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', LocaleSidKey='en_US',Alias ='als1', 
                         TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1111@testorg.com');
        insert u1;
                    
        User u2 = new User(FirstName = 'tst_', LastName = 'user2',ProfileId = adminProfile[0].id, Email='standarduser2@testorg.com', 
                         EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', LocaleSidKey='en_US',Alias ='als2',
                         TimeZoneSidKey='America/Los_Angeles', UserName='standarduser2222@testorg.com');
        insert u2;
        
        system.runAs(u1)
        {
            
            //for Validation rule
            Validation_Rules__c supportConfig = Validation_Rules__c.getOrgDefaults();
            supportConfig.Bypass_Rules__c = false;        
            upsert supportConfig Validation_Rules__c.Id; 
            
            //Custom settings ETL_Configuration__c
            ETL_Configuration__c etlConfig = ETL_Configuration__c.getInstance(UserInfo.getOrganizationId());
            etlConfig.Is_ETL_User__c = false;
            upsert etlConfig;
            
            //Custom settings Survey_Settings__c
            Survey_Settings__c surveySettings = Survey_Settings__c.getInstance(UserInfo.getOrganizationId());
            surveySettings.Hours_Threshold__c = 20;
            surveySettings.Is_Closed_Case_Survey_Active__c = true;
            upsert surveySettings;
            
            Account acc1 = new Account(Name = 'Acc1');
            
            insert acc1;
            
            Contact ct1 = new Contact(FirstName = 'Test', LastName = 'Test2', AccountId = acc1.Id, OwnerID = u1.id);
            insert ct1;
            
            Case c = new Case(ContactId = ct1.Id, AccountId = acc1.Id);
            
            insert c;
            
            ReportCard__c rCard1  = new ReportCard__c(Case__c = c.Id, Account__c = acc1.Id, Contact__c = ct1.Id);
            
            insert rCard1;
            
            c.OwnerID = u2.id;
            update c;
            Map<Id, Case> oldMapCase = new Map<Id, Case>();
            oldMapCase.put(c.Id, c);
            
            c.AccountId = acc1.Id;
            c.Status = 'Closed';
            c.Survey_Sent_API__c = 'Sent';
            update c;
            
            Map<Id, ReportCard__c> newMap = new Map<Id, ReportCard__c>();
            newMap.put(rCard1.Id, rCard1);
            
            Map<Id, Case> newMapCase = new Map<Id, Case>();
            newMapCase.put(c.Id, c);
            
            SurveyService.updateSurveyReponse(newMap);
            SurveyService.updateContactSurveySentTimestamp(newMapCase, oldMapCase);
        }
    }
    
    static testMethod void testMethodDelete()
    {
        //for Validation rule
        Validation_Rules__c supportConfig = Validation_Rules__c.getOrgDefaults();
        supportConfig.Bypass_Rules__c = false;        
        upsert supportConfig Validation_Rules__c.Id;
        
        Account acc1 = new Account(Name = 'Acc1');
        
        insert acc1;
        
        Contact ct1 = new Contact(FirstName = 'Test', LastName = 'Test2', AccountId = acc1.Id);
        insert ct1;
        
        Case c = new Case(ContactId = ct1.Id, AccountId = acc1.Id);
        
        insert c;
        
        ReportCard__c rCard1  = new ReportCard__c(Case__c = c.Id, Account__c = acc1.Id, Contact__c = ct1.Id);
        
        insert rCard1;
        
        Switch__c COHS = Switch__c.getInstance('CaseOwnerHistorySwitch');
        COHS.Switch__c  = true;
        update COHS;
        
        delete c;
        
        undelete c;
    }
}