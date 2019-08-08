@isTest
private class TestCaseTrigger 
{
    public static testMethod void testCaseOwnerHistoryTrigger() 
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
        
        String ADMIN_USER = 'System Administrator';
        List<Profile> adminProfile = [Select Id from Profile WHERE Name = :ADMIN_USER];        
        //System.assertEquals( 1 , adminProfile .size() , 'These tests require an admin prfile Profile' );
        
        User u1 = new User(FirstName = 'tst_', LastName = 'user1',ProfileId = adminProfile[0].id, Email='standarduser1@testorg.com', 
                           EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', LocaleSidKey='en_US',Alias ='als1', 
                           TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1111@testorg.com');
        User u2 = new User(FirstName = 'tst_', LastName = 'user2',ProfileId = adminProfile[0].id, Email='standarduser2@testorg.com', 
                           EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', LocaleSidKey='en_US',Alias ='als2',
                           TimeZoneSidKey='America/Los_Angeles', UserName='standarduser2222@testorg.com');
        insert u1;
        insert u2;                           
                                   
        test.startTest();
        
        System.RunAs(u1)
        {
            Contact con = new Contact(FirstName ='ContactFname', LastName ='ContactLname');
        
            Case cs1 = new Case(OwnerID = u1.id ,ContactId = con.id, Status ='New',Priority ='Medium',
                         Origin = 'Phone',Subject = 'TestCase1',Description ='This is a test Case' );
            Case cs2 = new Case(OwnerID = u1.id ,ContactId = con.id, Status ='New',Priority ='Low',
                         Origin = 'Email',Subject = 'TestCase1',Description ='This is a test Case' );            
            
            List<Case> tstCases = new List<Case>();
            tstcases.add(cs1);
            tstcases.add(cs2);
            insert tstCases;         
            
            List<Case_Owner_History__c> csHistCreated1 = [select Id,Case__c, Handed_Off__c,Received__c from Case_Owner_History__c
                                                         where Case__c = :cs1.Id];
            List<Case_Owner_History__c> csHistCreated2 = [select Id,Case__c, Handed_Off__c,Received__c from Case_Owner_History__c
                                                         where Case__c = :cs2.Id];  
                                                                                                    
            //System.assertEquals (1,csHistCreated1.size());           
            //System.assertEquals (1,csHistCreated2.size());   
            
            Case cs1Date = [Select createddate from Case where id =:cs1.Id];
            Case cs2Date = [Select createddate from Case where id =:cs2.Id];
            
            //System.assertEquals (csHistCreated1[0].Received__c,cs1Date.createddate );                                                                                    
            //System.assertEquals (csHistCreated2[0].Received__c, cs2Date.createddate );                                    
              
            for(Case csupdts:tstcases)
            {
                csupdts.ownerId = u2.Id ;
            }               
            update tstcases ;
            
            List<Case_Owner_History__c> csHistCreated3 = [select Id,Case__c, Handed_Off__c,Received__c from Case_Owner_History__c
                                                         where Case__c = :cs1.Id];
            List<Case_Owner_History__c> csHistCreated4 = [select Id,Case__c, Handed_Off__c,Received__c from Case_Owner_History__c
                                                         where Case__c = :cs2.Id];                                                       
            
            for(Case csupdts:tstcases)
            {
                csupdts.Status = 'Closed';
            }           
               
            update tstcases ;

            delete tstcases ;
            
            List<Case_Owner_History__c> csHistCreated5 = [select Id,Case__c, Handed_Off__c,Received__c from Case_Owner_History__c
                                                         where Case__c = :cs1.Id];
            List<Case_Owner_History__c> csHistCreated6 = [select Id,Case__c, Handed_Off__c,Received__c from Case_Owner_History__c
                                                         where Case__c = :cs2.Id];
                                                         
            //System.assertEquals (0,csHistCreated5.size());           
            //System.assertEquals (0,csHistCreated6.size());       
            
            undelete tstcases;            
            
            List<Case_Owner_History__c> csHistCreated7 = [select Id,Case__c, Handed_Off__c,Received__c from Case_Owner_History__c
                                                         where Case__c = :cs1.Id];
            List<Case_Owner_History__c> csHistCreated8 = [select Id,Case__c, Handed_Off__c,Received__c from Case_Owner_History__c
                                                         where Case__c = :cs2.Id];                                                         
            
        }
        test.stopTest();
    }
    
    public static testMethod void bulkTestCaseOwnerHistoryTrigger()
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
        
        String ADMIN_USER = 'System Administrator';
        List<Profile> adminProfile = [Select Id from Profile WHERE Name = :ADMIN_USER];        
        //System.assertEquals( 1 , adminProfile .size() , 'These tests require an admin prfile Profile' );
        
        User u1 = new User(FirstName = 'tst_', LastName = 'user1',ProfileId = adminProfile[0].id, Email='standarduser1@testorg.com', 
                           EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', LocaleSidKey='en_US',Alias ='als1', 
                           TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1111@testorg.com');
        User u2 = new User(FirstName = 'tst_', LastName = 'user2',ProfileId = adminProfile[0].id, Email='standarduser2@testorg.com', 
                           EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', LocaleSidKey='en_US',Alias ='als2',
                           TimeZoneSidKey='America/Los_Angeles', UserName='standarduser2222@testorg.com');
        insert u1;
        insert u2;                           
                                   
        test.startTest();
        
        System.RunAs(u1)
        {
            Contact con = new Contact(FirstName ='ContactFname', LastName ='ContactLname');
        
            Case cs1 = new Case(OwnerID = u1.id ,ContactId = con.id, Status ='New',Priority ='Medium',
                         Origin = 'Phone',Subject = 'TestCase1',Description ='This is a test Case' );
            Case cs2 = new Case(OwnerID = u2.id ,ContactId = con.id, Status ='New',Priority ='Low',
                         Origin = 'Email',Subject = 'TestCase1',Description ='This is a test Case' );            
        
            List<Case> tstCases = new List<Case>();
            tstcases.add(cs1);
            tstcases.add(cs2);
            
            for(Integer i = 2; i < 200; i++) 
            {
                tstcases.add(new Case(OwnerID = u1.id ,ContactId = con.id, Status ='New',Priority ='Low',
                         Origin = 'Email',Subject = 'TestCase1',Description ='This is a test Case' ));
            } 
            insert tstCases;  
            
            Set<ID> caseIds = new set<ID>();
            for(Case csupdts:tstcases){
                caseIds.add(csupdts.Id);
            }
            
            List<Case_Owner_History__c> csHistCreated1 = [select Id,Case__c, Handed_Off__c,Received__c from Case_Owner_History__c
                                                         where Case__c = :cs1.Id];
            List<Case_Owner_History__c> csHistCreated2 = [select Id,Case__c, Handed_Off__c,Received__c from Case_Owner_History__c
                                                         where Case__c = :cs2.Id];
                                                         
            List<Case_Owner_History__c> csHistCreatedBulk = [select Id,Case__c, Handed_Off__c,Received__c from Case_Owner_History__c
                                                         where Case__c IN :caseIds];  
                                                         
            //System.assertEquals (1,csHistCreated1.size());           
            //System.assertEquals (1,csHistCreated2.size());
            
            //System.assertEquals (200,csHistCreatedBulk.size());   
            
            Case cs1Date = [Select createddate from Case where id =:cs1.Id];
            Case cs2Date = [Select createddate from Case where id =:cs2.Id];
            
            //System.assertEquals (csHistCreated1[0].Received__c,cs1Date.createddate );                                                                                    
            //System.assertEquals (csHistCreated2[0].Received__c, cs2Date.createddate );                                    
                       
            for(Case csupdts:tstcases)
            {
                csupdts.ownerId = u2.Id ;
            }           
            update tstcases ;

            List<Case_Owner_History__c> csHistCreated3 = [select Id,Case__c, Handed_Off__c,Received__c from Case_Owner_History__c
                                                         where Case__c = :cs1.Id];
            List<Case_Owner_History__c> csHistCreated4 = [select Id,Case__c, Handed_Off__c,Received__c from Case_Owner_History__c
                                                         where Case__c = :cs2.Id];
                                                         
            List<Case_Owner_History__c> csHistUpdatedBulk = [select Id,Case__c, Handed_Off__c,Received__c from Case_Owner_History__c
                                                         where Case__c IN :caseIds];
                                                  
            //System.assertEquals (2,csHistCreated3.size());           
            //System.assertEquals (1,csHistCreated4.size());
            
            //System.assertEquals (399,csHistUpdatedBulk.size());                
            
            for(Case csupdts:tstcases)
            {
                csupdts.Status = 'Closed';
            }          
            update tstcases ;

            delete tstcases ;
            
            List<Case_Owner_History__c> csHistCreated5 = [select Id,Case__c, Handed_Off__c,Received__c from Case_Owner_History__c
                                                         where Case__c = :cs1.Id];
            List<Case_Owner_History__c> csHistCreated6 = [select Id,Case__c, Handed_Off__c,Received__c from Case_Owner_History__c
                                                         where Case__c = :cs2.Id]; 
                                                         
            List<Case_Owner_History__c> csHistDeleteBulk = [select Id,Case__c, Handed_Off__c,Received__c from Case_Owner_History__c
                                                         where Case__c IN :caseIds];
            //System.assertEquals (0,csHistCreated5.size());           
            //System.assertEquals (0,csHistCreated6.size()); 
            //System.assertEquals (0,csHistDeleteBulk.size());      
            
            undelete tstcases;            
            
            List<Case_Owner_History__c> csHistCreated7 = [select Id,Case__c, Handed_Off__c,Received__c from Case_Owner_History__c
                                                         where Case__c = :cs1.Id];
            List<Case_Owner_History__c> csHistCreated8 = [select Id,Case__c, Handed_Off__c,Received__c from Case_Owner_History__c
                                                         where Case__c = :cs2.Id];                                                         
            List<Case_Owner_History__c> csHistUnDeleteBulk = [select Id,Case__c, Handed_Off__c,Received__c from Case_Owner_History__c
                                                         where Case__c IN :caseIds];
            
            //System.assertEquals (2,csHistCreated7.size());           
            //System.assertEquals (1,csHistCreated8.size());  
            //System.assertEquals (399,csHistUnDeleteBulk.size());
            
        }
        test.stopTest();
    }
}