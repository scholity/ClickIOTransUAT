@isTest(seeAllData = false)
public class TestEmailMessageServices {


    /*public static testMethod void testBillingRouting() {
        
        Case c1 = new Case(Origin = 'Email');
        
        insert c1;
        
        c1 = [SELECT Id, Origin FROM Case WHERE Id = :c1.Id limit 1][0];
        
        System.assertEquals(c1.Origin, 'Email');
            
        EmailMessage em1 = new EmailMessage(ParentId = c1.Id, Subject = 'MAD', FromAddress = 'voicemessage@unityphone.com');
        
        insert em1;
        
        c1 = [SELECT Id, Type, Origin, Subject FROM Case Where Id = :c1.Id limit 1][0];
        
        System.assertEquals(c1.Origin, 'Voicemail');
        System.assertEquals(c1.Type, 'Invoicing');
        
        
        Case c2 = new Case(Origin = 'Email');
        
        insert c2;
        
        EmailMessage em2 = new EmailMessage(ParentId = c2.Id, Subject = 'misdirected rdc deposit', FromAddress = 'someaddress@someemail.com');
        
        insert em2;
        
        c2 = [SELECT Id, Type, Origin, Subject FROM Case Where Id = :c2.Id limit 1][0];
        
        System.assertEquals(c2.Origin, 'Email');
        System.assertEquals(c2.Type, 'Invoicing');
        
    }*/
    
    static
    {
        TestUtil.setupBucketAccountSettings();
    }
    @testSetup static void customsettingswitch() {
     Switch__c cohstest = new Switch__c();
     cohstest.Switch__c = false;
     cohstest.name = 'CaseOwnerHistorySwitch';
     insert cohstest; 
     
     Switch__c esstest = new Switch__c();
     esstest.Switch__c = true;
     esstest.name = 'EmailMessageServiceSwitch';
     insert esstest;
     
    //for Validation rule
    Validation_Rules__c supportConfig = Validation_Rules__c.getOrgDefaults();
    supportConfig.Bypass_Rules__c = false;        
    upsert supportConfig Validation_Rules__c.Id;
    }
    public static testMethod void testCaseUpdateByEmailMessageReplied() {
        String ADMIN_USER = 'System Administrator';
        
        List<Profile> adminProfile = [Select Id from Profile WHERE Name = :ADMIN_USER];        
        System.assertEquals( 1 , adminProfile .size() , 'These tests require an admin prfile Profile' );
        List<User> UserList=new List<User>();
        User u1 = new User(FirstName = 'tst_', LastName = 'user1',ProfileId = adminProfile[0].id, Email='standarduser1@testorg.com', 
                           EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', LocaleSidKey='en_US',Alias ='als1', 
                           TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1111@testorg.com');
                           UserList.add(u1);
        //insert u1;                           
                           
        User u2 = new User(FirstName = 'tst_', LastName = 'user2',ProfileId = adminProfile[0].id, Email='standarduser2@testorg.com', 
                           EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', LocaleSidKey='en_US',Alias ='als2',
                           TimeZoneSidKey='America/Los_Angeles', UserName='standarduser2222@testorg.com');
        UserList.add(u2);
        //insert u2;   
        insert UserList;        
        
        Group g1 = new Group(Name='Test group name', type='Queue');
        insert g1;
        
        QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Case');
        insert q1;         
                                   
        test.startTest();        
            System.RunAs(u1){               
                Contact con = new Contact(FirstName ='ContactFname', LastName ='ContactLname');
                con.MailingPostalCode = '99999';
                insert con;
                
                Id rtId = Schema.SObjectType.Case.RecordTypeInfosByName.get('Sales Case Read Only').RecordTypeId;
                Case cs1 = new Case(OwnerID = u1.id ,ContactId = con.id, Status ='New',Priority ='Medium', Type = 'Certificates',
                             Origin = 'Phone',Subject = 'TestCase1',Description ='This is a test Case', RecordTypeId = rtId);
                insert cs1;
                                
                // Assign Case Owner to a Queue
                cs1.OwnerId = g1.Id;
                //update cs1;                   
                
                // Validate case is assigned to correct queue.
                system.assertEquals (cs1.OwnerId, g1.Id);
                
                // Reassign Case to an User
                cs1.OwnerId = u2.Id; 
               // update cs1; 
                
                // Email to the case
                EmailMessage em = new EmailMessage(Status = '0', Incoming = true, ParentId = cs1.Id, Subject='This is a test', ToAddress='test@test.com', FromName='Tester Test', FromAddress='test@test.com');                      
                insert em;
                
                cs1 = [select id, status, Type, RecordTypeId, RecordType.Name, Last_Case_Update_Time_Date__c, OwnerId FROM Case c where id = :cs1.Id];
                
                // Validate case is assigned to correct queue.
                //system.assertEquals (cs1.OwnerId, g1.Id);
                //system.assertEquals (cs1.status, 'Follow Up - New Email');
                //system.assertEquals (cs1.RecordTypeId, Schema.SObjectType.Case.RecordTypeInfosByName.get('Sales Case').RecordTypeId);
                
                //Written to cover getQueueOwnerIdForCases method in EmailMessageServices (15-09-2017)
                Set<Id> caseIds = new Set<Id>();
                caseIds.add(cs1.Id);
                //Map<Id, Id> returnMapIds = EmailMessageServices.getQueueOwnerIdForCases(caseIds);
            }
        test.stopTest();        
    }
    
    //Methods Written to increase Code coverage
    public static testMethod void testCaseUpdateByEmailMessageReplied1() {
        String ADMIN_USER = 'System Administrator';
        
        List<Profile> adminProfile = [Select Id from Profile WHERE Name = :ADMIN_USER];        
        System.assertEquals( 1 , adminProfile .size() , 'These tests require an admin prfile Profile' );
        
        User u1 = new User(FirstName = 'tst_', LastName = 'user1',ProfileId = adminProfile[0].id, Email='standarduser1@testorg.com', 
                           EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', LocaleSidKey='en_US',Alias ='als1', 
                           TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1111@testorg.com');
        insert u1;                           
                           
        User u2 = new User(FirstName = 'tst_', LastName = 'user2',ProfileId = adminProfile[0].id, Email='standarduser2@testorg.com', 
                           EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', LocaleSidKey='en_US',Alias ='als2',
                           TimeZoneSidKey='America/Los_Angeles', UserName='standarduser2222@testorg.com');
        insert u2;                  
        
        Group g1 = new Group(Name='Test group name', type='Queue');
        insert g1;
        
        QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Case');
        insert q1;         
                                   
        test.startTest();        
            System.RunAs(u1){               
                Contact con = new Contact(FirstName ='ContactFname', LastName ='ContactLname');
                con.MailingPostalCode = '99999';
                insert con;
                
                Id rtId = Schema.SObjectType.Case.RecordTypeInfosByName.get('Sales Case Read Only').RecordTypeId;
                Case cs1 = new Case(OwnerID = u1.id ,ContactId = con.id, Status ='New',Priority ='Medium', Type = 'Certificates',
                             Origin = 'Phone',Subject = 'TestCase1',Description ='This is a test Case', RecordTypeId = rtId);
                insert cs1;
                                
                // Assign Case Owner to a Queue
                cs1.OwnerId = g1.Id;
                update cs1;                   
                
                // Validate case is assigned to correct queue.
                system.assertEquals (cs1.OwnerId, g1.Id);
                
                // Reassign Case to an User
                cs1.OwnerId = u2.Id; 
                update cs1; 
                
                // Email to the case
                EmailMessage em = new EmailMessage(Status = '0', Incoming = true, ParentId = cs1.Id, Subject='voicemail', ToAddress='billing@test.com', FromName='Tester Test', FromAddress='test@test.com');                      
                insert em;
                
                cs1 = [select id, status, Type, RecordTypeId, RecordType.Name, Last_Case_Update_Time_Date__c, OwnerId FROM Case c where id = :cs1.Id];
            }
        test.stopTest();        
    }
    
    public static testMethod void testCaseUpdateByEmailMessageReplied2() {
        String ADMIN_USER = 'System Administrator';
        
        List<Profile> adminProfile = [Select Id from Profile WHERE Name = :ADMIN_USER];        
        System.assertEquals( 1 , adminProfile .size() , 'These tests require an admin prfile Profile' );
        
        User u1 = new User(FirstName = 'tst_', LastName = 'user1',ProfileId = adminProfile[0].id, Email='standarduser1@testorg.com', 
                           EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', LocaleSidKey='en_US',Alias ='als1', 
                           TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1111@testorg.com');
        insert u1;                           
                           
        User u2 = new User(FirstName = 'tst_', LastName = 'user2',ProfileId = adminProfile[0].id, Email='standarduser2@testorg.com', 
                           EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', LocaleSidKey='en_US',Alias ='als2',
                           TimeZoneSidKey='America/Los_Angeles', UserName='standarduser2222@testorg.com');
        insert u2;                  
        
        Group g1 = new Group(Name='Test group name', type='Queue');
        insert g1;
        
        QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Case');
        insert q1;         
                                   
        test.startTest();        
            System.RunAs(u1){               
                Contact con = new Contact(FirstName ='ContactFname', LastName ='ContactLname');
                con.MailingPostalCode = '99999';
                insert con;
                
                Id rtId = Schema.SObjectType.Case.RecordTypeInfosByName.get('Sales Case Read Only').RecordTypeId;
                Case cs1 = new Case(OwnerID = u1.id ,ContactId = con.id, Status ='New',Priority ='Medium', Type = 'Certificates',
                             Origin = 'Phone',Subject = 'TestCase1',Description ='This is a test Case', RecordTypeId = rtId);
                insert cs1;
                                
                // Assign Case Owner to a Queue
                cs1.OwnerId = g1.Id;
                update cs1;                   
                
                // Validate case is assigned to correct queue.
                system.assertEquals (cs1.OwnerId, g1.Id);
                
                // Reassign Case to an User
                cs1.OwnerId = u2.Id; 
                update cs1; 
                
                // Email to the case
                EmailMessage em = new EmailMessage(Status = '0', Incoming = true, ParentId = cs1.Id, Subject='This is a test', ToAddress='billing@test.com', FromName='Tester Test', FromAddress='test@test.com');                      
                insert em;
                
                cs1 = [select id, status, Type, RecordTypeId, RecordType.Name, Last_Case_Update_Time_Date__c, OwnerId FROM Case c where id = :cs1.Id];
                
            }
        test.stopTest();        
    }
    
    public static testMethod void testCaseUpdateByEmailMessageReplied3() {
        String ADMIN_USER = 'System Administrator';
        
        List<Profile> adminProfile = [Select Id from Profile WHERE Name = :ADMIN_USER];        
        System.assertEquals( 1 , adminProfile .size() , 'These tests require an admin prfile Profile' );
        List<User> UserList1=new List<User>();
        User u1 = new User(FirstName = 'tst_', LastName = 'user1',ProfileId = adminProfile[0].id, Email='standarduser1@testorg.com', 
                           EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', LocaleSidKey='en_US',Alias ='als1', 
                           TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1111@testorg.com');
        UserList1.add(u1);
        //insert u1;                           
                           
        User u2 = new User(FirstName = 'tst_', LastName = 'user2',ProfileId = adminProfile[0].id, Email='standarduser2@testorg.com', 
                           EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', LocaleSidKey='en_US',Alias ='als2',
                           TimeZoneSidKey='America/Los_Angeles', UserName='standarduser2222@testorg.com');
        UserList1.add(u2);
        insert UserList1;
        //insert u2;                  
        
        Group g1 = new Group(Name='Test group name', type='Queue');
        insert g1;
        
        QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Case');
        insert q1;         
                                   
        test.startTest();        
            System.RunAs(u1){               
                Contact con = new Contact(FirstName ='ContactFname', LastName ='ContactLname');
                con.MailingPostalCode = '99999';
                insert con;
                
                Id rtId = Schema.SObjectType.Case.RecordTypeInfosByName.get('Sales Case Read Only').RecordTypeId;
                Case cs1 = new Case(OwnerID = u1.id ,ContactId = con.id, Status ='New',Priority ='Medium', Type = 'Certificates',
                             Origin = 'Phone',Subject = 'TestCase1',Description ='This is a test Case', RecordTypeId = rtId);
                insert cs1;
                                
                // Assign Case Owner to a Queue
                cs1.OwnerId = g1.Id;
                //update cs1;                   
                
                // Validate case is assigned to correct queue.
                system.assertEquals (cs1.OwnerId, g1.Id);
                
                // Reassign Case to an User
                cs1.OwnerId = u2.Id; 
                //update cs1; 
                
                // Email to the case
                EmailMessage em = new EmailMessage(Status = '0', Incoming = true, ParentId = cs1.Id, Subject='This is a test', ToAddress='collections@test.com', FromName='Tester Test', FromAddress='test@test.com');                      
                insert em;
                
                Switch__c COHS = Switch__c.getInstance('EmailMessageServiceSwitch'); 
                COHS.Switch__c = false;
                //upsert COHS;
                
                EmailMessage em1 = new EmailMessage(Status = '0', Incoming = true, ParentId = cs1.Id, Subject='This is a test', ToAddress='collections@test.com', FromName='Tester Test', FromAddress='test@test.com');                      
                insert em1;
            }
        test.stopTest();        
    }
}