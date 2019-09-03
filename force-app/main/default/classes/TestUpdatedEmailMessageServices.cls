@isTest
private class TestUpdatedEmailMessageServices {
 
  
  @testSetup static void customsettingswitch() {
     //Initiallizing all teh Custom Settings.
     Switch__c cohstest = new Switch__c();
     cohstest.Switch__c = false;
     cohstest.name = 'CaseOwnerHistorySwitch';
     insert cohstest; 
     
     Switch__c esstest = new Switch__c();
     esstest.Switch__c = false;
     esstest.name = 'EmailMessageServiceSwitch';
     insert esstest;
     
     //for Validation rule
      Validation_Rules__c supportConfig = Validation_Rules__c.getOrgDefaults();
      supportConfig.Bypass_Rules__c = true;        
      insert supportConfig;
      
      Account acc = new Account();
      acc.name = 'Bucket Account';
      insert acc;
      
     

      List<Contact> ListOfCon = new List<Contact>();
      Contact con1 = new Contact(FirstName ='ContactFname', LastName ='ContactLname', email = 'test@testusercon.com', MailingPostalCode = '99999');
      ListOfCon.add(con1);  
      insert ListOfCon;
      Id rtId1 = Schema.SObjectType.Case.RecordTypeInfosByName.get('Service Case Read Only').RecordTypeId;
      Id rtId2 = Schema.SObjectType.Case.RecordTypeInfosByName.get('Service Cases').RecordTypeId;
      Case cs1 = new Case(OwnerID = UserInfo.getUserId() ,ContactId = con1.id, Status ='closed',Priority ='Medium', Type = 'Certificates',
                          Origin = 'Phone',Subject = 'TestCase1',Description ='This is a test Case', RecordTypeId = rtId1);
      insert cs1;
     List<EmailMessageServiceQueues__c> EmlQueueCSList = new List<EmailMessageServiceQueues__c>();
     
     
     /*EmailMessageServiceQueues__c EmlQueueCS2 = new EmailMessageServiceQueues__c();    
     EmlQueueCS2.Queue_Id__c = '00G55000000O1Tt';
     EmlQueueCS2.IRT__c = false;
     EmlQueueCS2.Name = 'Retail Collections';
     EmlQueueCSList.add(EmlQueueCS2);*/
     
     EmailMessageServiceQueues__c EmlQueueCS3 = new EmailMessageServiceQueues__c();    
     EmlQueueCS3.Queue_Id__c = '00Gd0000000UJPx';
     EmlQueueCS3.IRT__c = true;
     EmlQueueCS3.Name = 'Collections';
     EmlQueueCSList.add(EmlQueueCS3);
     
     EmailMessageServiceQueues__c EmlQueueCS4 = new EmailMessageServiceQueues__c();    
     EmlQueueCS4.Queue_Id__c = '00Gd0000002b0Oy';
     EmlQueueCS4.IRT__c = true;
     EmlQueueCS4.Name = 'Invoice Escalations';
     EmlQueueCSList.add(EmlQueueCS4);
     
     
     EmailMessageServiceQueues__c EmlQueueCS5 = new EmailMessageServiceQueues__c();    
     EmlQueueCS5.Queue_Id__c = '00Gd0000000SdP7';
     EmlQueueCS5.IRT__c = false;
     EmlQueueCS5.Name = 'General Customer';
     EmlQueueCSList.add(EmlQueueCS5);
     insert EmlQueueCSList;
  }
  
  
  static
  {
    TestUtil.setupBucketAccountSettings();
  }
  
  public static testMethod void testClosedCaseUpdateByEmailMessageReplied() {
      
      String ADMIN_USER = 'System Administrator';
        
      List<Profile> adminProfile = [Select Id from Profile WHERE Name = :ADMIN_USER];        
      System.assertEquals( 1 , adminProfile .size() , 'These tests require an admin prfile Profile' );
        
      List<User> LstOfUsers = new List<User>();
      User u1 = new User(FirstName = 'tst_', LastName = 'user1',ProfileId = adminProfile[0].id, Email='standarduser1@testorg.com', 
                         EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', LocaleSidKey='en_US',Alias ='als1', 
                         TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1111@testorg.com');
      LstOfUsers.add(u1);                           
                    
      User u2 = new User(FirstName = 'tst_', LastName = 'user2',ProfileId = adminProfile[0].id, Email='standarduser2@testorg.com', 
                         EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', LocaleSidKey='en_US',Alias ='als2',
                         TimeZoneSidKey='America/Los_Angeles', UserName='standarduser2222@testorg.com');
      LstOfUsers.add(u2);
      User u3 = new User(FirstName = 'tst_', LastName = 'user3',ProfileId = adminProfile[0].id, Email='standarduser2@testorg.com', 
                         EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', LocaleSidKey='en_US',Alias ='als3',
                         TimeZoneSidKey='America/Los_Angeles', UserName='standarduser3333@testorg.com');
      LstOfUsers.add(u3);
      
      User u4 = new User(FirstName = 'tst_', LastName = 'user4',ProfileId = adminProfile[0].id, Email='standarduser2@testorg.com', 
                         EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', LocaleSidKey='en_US',Alias ='als4',
                         TimeZoneSidKey='America/Los_Angeles', UserName='standarduser4444@testorg.com');
      LstOfUsers.add(u4);
      
      insert LstOfUsers;   

      List<Group> LstOfGroups = new List<Group>();
      Group g1 = new Group(Name='Business Operations', type='Queue');
      LstOfGroups.add(g1);
            
      Group g2 = new Group(Name='Collections', type='Queue');
      LstOfGroups.add(g2);
      
      Group g3 = new Group(Name='Finance COE/Billing', type='Queue');
      LstOfGroups.add(g3);
      
      Group g4 = new Group(Name='Retail Collections', type='Queue');
      LstOfGroups.add(g4);
      
      Group g5 = new Group(Name='Finance COE - Ready to Close', type='Queue');
      LstOfGroups.add(g5);
      insert LstOfGroups;
      
      List<GroupMember> LstOfGroupMembers = new List<GroupMember>();
      GroupMember gm1 = new GroupMember(groupid = g1.id, UserOrGroupId = u1.id);
      LstOfGroupMembers.add(gm1);
      
      GroupMember gm2 = new GroupMember(groupid = g2.id, UserOrGroupId = u2.id);
      LstOfGroupMembers.add(gm2);
      
      GroupMember gm3 = new GroupMember(groupid = g3.id, UserOrGroupId = u3.id);
      LstOfGroupMembers.add(gm3);
      
      GroupMember gm4 = new GroupMember(groupid = g4.id, UserOrGroupId = u4.id);
      LstOfGroupMembers.add(gm4);
      
      GroupMember gm5 = new GroupMember(groupid = g5.id, UserOrGroupId = u4.id);
      LstOfGroupMembers.add(gm5);
      
      insert LstOfGroupMembers;
  
      
      
      test.startTest();   
    
      //Billing Test
      System.RunAs(u1){ 
      List<EmailMessageServiceQueues__c> EmaList=new List<EmailMessageServiceQueues__c>();
      EmailMessageServiceQueues__c EmlQueueCS1 = new EmailMessageServiceQueues__c();    
      EmlQueueCS1.Queue_Id__c = g3.id;
      EmlQueueCS1.IRT__c = true;
      EmlQueueCS1.Name = 'Finance COE/Billing';
      EmaList.add(EmlQueueCS1);
      EmailMessageServiceQueues__c EmlQueueCS2 = new EmailMessageServiceQueues__c();    
      EmlQueueCS2.Queue_Id__c = g5.id ;
      EmlQueueCS2.IRT__c = true;
      EmlQueueCS2.Name = 'Finance COE - Ready to Close';
      EmaList.add(EmlQueueCS2);
      insert EmaList;            
      Case cs1=[select id,RecordTypeId from Case where type = 'Certificates'];
      Id rtId1 = Schema.SObjectType.Case.RecordTypeInfosByName.get('Service Case Read Only').RecordTypeId;
      Id rtId2 = Schema.SObjectType.Case.RecordTypeInfosByName.get('Service Cases').RecordTypeId;
      system.assertEquals (rtId1,cs1.RecordTypeId);
          
      // Email to the case
      EmailMessage em = new EmailMessage(Status = '0', Incoming = true, ParentId = cs1.Id, Subject='Voicemail - This is a test', ToAddress='billing@test.com', FromName='ContactFname ContactLname', FromAddress='test@testusercon.com');                      
      system.assertEquals ('billing@test.com',em.ToAddress);
      insert em; 
      
      EmailMessage em1 = new EmailMessage(Status = '0', Incoming = true, ParentId = cs1.Id, Subject='aquatics - This is a test', ToAddress='billing@test.com', FromName='ContactFname ContactLname', FromAddress='test@testusercon.com');                      
      system.assertEquals ('billing@test.com',em1.ToAddress);
      insert em1;     
      delete em1;
      
     // EmailMessage em3 = new EmailMessage(Status = '0', Incoming = true, ParentId = cs1.Id, Subject='This is a test', ToAddress='billing@test.com', FromName='ContactFname ContactLname', FromAddress='test@testusercon.com');                      
     // system.assertEquals ('billing@test.com',em3.ToAddress);
     // insert em3;
      
      cs1.OwnerId = u3.id;
      update cs1;
     
     // EmailMessage em2 = new EmailMessage(Status = '0', Incoming = true, ParentId = cs1.Id, Subject='This is a test', ToAddress='billing@test.com', FromName='ContactFname ContactLname', FromAddress='test@testusercon.com');                      
     // system.assertEquals ('billing@test.com',em2.ToAddress);
     // insert em2;
      }
      
      //Collection Test
       
      System.RunAs(u1){ 
      EmailMessageServiceQueues__c EmlQueueCS1 = new EmailMessageServiceQueues__c();    
      EmlQueueCS1.Queue_Id__c = g2.id;
      EmlQueueCS1.IRT__c = true;
      EmlQueueCS1.Name = 'Collections';
      insert EmlQueueCS1;        
      Case cs1=[select id,RecordTypeId from Case where type = 'Certificates'];
      Id rtId1 = Schema.SObjectType.Case.RecordTypeInfosByName.get('Service Case Read Only').RecordTypeId;
      Id rtId2 = Schema.SObjectType.Case.RecordTypeInfosByName.get('Service Cases').RecordTypeId;
      system.assertEquals (rtId1,cs1.RecordTypeId);
          
      // Email to the case
      EmailMessage em = new EmailMessage(Status = '0', Incoming = true, ParentId = cs1.Id, Subject='Voicemail - This is a test', ToAddress='phsscollections@test.com', FromName='ContactFname ContactLname', FromAddress='test@testusercon.com');                      
      system.assertEquals ('phsscollections@test.com',em.ToAddress);
      insert em; 
      
      EmailMessage em1 = new EmailMessage(Status = '0', Incoming = true, ParentId = cs1.Id, Subject='aquatics - This is a test', ToAddress='retailcollections@test.com', FromName='ContactFname ContactLname', FromAddress='test@testusercon.com');                      
      system.assertEquals ('retailcollections@test.com',em1.ToAddress);
      insert em1;     
      delete em1;      
      delete em;
      
      EmailMessage em4 = new EmailMessage(Status = '0', Incoming = true, ParentId = cs1.Id, Subject='aquatics - This is a test', ToAddress='adjustment@test.com', FromName='ContactFname ContactLname', FromAddress='test@testusercon.com');                      
      system.assertEquals ('adjustment@test.com',em4.ToAddress);
      insert em4;
      delete em4;
      
      EmailMessage em6 = new EmailMessage(Status = '0', Incoming = true, ParentId = cs1.Id, Subject='aquatics - This is a test', ToAddress='others@test.com', FromName='ContactFname ContactLname', FromAddress='test@testusercon.com');                      
      system.assertEquals ('others@test.com',em6.ToAddress);
      insert em6;
      
      EmailMessage em3 = new EmailMessage(Status = '0', Incoming = true, ParentId = cs1.Id, Subject='This is a test', ToAddress='phsscollections@test.com', FromName='ContactFname ContactLname', FromAddress='test@testusercon.com');                      
      system.assertEquals ('phsscollections@test.com',em3.ToAddress);
      insert em3;
      
      /*cs1.OwnerId = u2.id;
      update cs1;*/
     
      EmailMessage em2 = new EmailMessage(Status = '0', Incoming = true, ParentId = cs1.Id, Subject='This is a test', ToAddress='phsscollections@test.com', FromName='ContactFname ContactLname', FromAddress='test@testusercon.com');                      
      system.assertEquals ('phsscollections@test.com',em2.ToAddress);
      insert em2;
      
      cs1.OwnerId = u3.id;
      cs1.Latest_Queue_Owner__c = g3.id;
      update cs1;
      
      EmailMessage em5 = new EmailMessage(Status = '0', Incoming = true, ParentId = cs1.Id, Subject='aquatics - This is a test', ToAddress='adjustment@test.com', FromName='ContactFname ContactLname', FromAddress='test@testusercon.com');                      
      system.assertEquals ('adjustment@test.com',em5.ToAddress);
      insert em5;
      
      EmailMessage em7 = new EmailMessage(Status = '0', Incoming = true, ParentId = cs1.Id, Subject='aquatics - This is a test', ToAddress='others@test.com', FromName='ContactFname ContactLname', FromAddress='test@testusercon.com');                      
      system.assertEquals ('others@test.com',em7.ToAddress);
      insert em7;
      
      test.stopTest();   
      } 

      System.RunAs(u1){ 
      EmailMessageServiceQueues__c EmlQueueCS1 = new EmailMessageServiceQueues__c();    
      EmlQueueCS1.Queue_Id__c = g4.id;
      EmlQueueCS1.IRT__c = true;
      EmlQueueCS1.Name = 'Retail Collections';
      insert EmlQueueCS1;           
      Case cs1=[select id,RecordTypeId from Case where type = 'Certificates'];
      Id rtId1 = Schema.SObjectType.Case.RecordTypeInfosByName.get('Service Case Read Only').RecordTypeId;
      Id rtId2 = Schema.SObjectType.Case.RecordTypeInfosByName.get('Service Cases').RecordTypeId;
      system.assertEquals (rtId1,cs1.RecordTypeId);
          
      // Email to the case
      EmailMessage em = new EmailMessage(Status = '0', Incoming = true, ParentId = cs1.Id, Subject='Voicemail - This is a test', ToAddress='billing@test.com', FromName='ContactFname ContactLname', FromAddress='test@testusercon.com');                      
      system.assertEquals ('billing@test.com',em.ToAddress);
      insert em; 
      
      EmailMessage em1 = new EmailMessage(Status = '0', Incoming = true, ParentId = cs1.Id, Subject='aquatics - This is a test', ToAddress='billing@test.com', FromName='ContactFname ContactLname', FromAddress='test@testusercon.com');                      
      system.assertEquals ('billing@test.com',em1.ToAddress);
      insert em1;     
      delete em1;
      
     // EmailMessage em3 = new EmailMessage(Status = '0', Incoming = true, ParentId = cs1.Id, Subject='This is a test', ToAddress='billing@test.com', FromName='ContactFname ContactLname', FromAddress='test@testusercon.com');                      
     // system.assertEquals ('billing@test.com',em3.ToAddress);
     // insert em3;
      
      cs1.OwnerId = u4.id;
      update cs1;
     
     // EmailMessage em2 = new EmailMessage(Status = '0', Incoming = true, ParentId = cs1.Id, Subject='This is a test', ToAddress='billing@test.com', FromName='ContactFname ContactLname', FromAddress='test@testusercon.com');                      
     // system.assertEquals ('billing@test.com',em2.ToAddress);
     // insert em2;
      }   
      }
}