@isTest
private class TestupdateTrainingEventFacilityAddress
{
    
    @isTest static void TestUpdatetrainingAddress()
    {
      String ADMIN_USER = 'System Administrator';
        
        List<Profile> adminProfile = [Select Id from Profile WHERE Name = :ADMIN_USER];        
        System.assertEquals( 1 , adminProfile .size() , 'These tests require an admin prfile Profile' );
        
        User u1 = new User(FirstName = 'tst_', LastName = 'user1',ProfileId = adminProfile[0].id, Email='standarduser1@testorg.com', 
                           EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', LocaleSidKey='en_US',Alias ='als1', 
                           TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1111@testorg.com');
        insert u1; 
        
        BGST_Profiles__c BGSTProf = new BGST_Profiles__c();
        BGSTProf.Name = 'Owner Profile';
        BGSTProf.Sales_User__c ='ARC BGST Sales User';
        BGSTProf.Sales_Admin__c ='ARC BGST Sales User';
        
        insert BGSTProf;
        
        /*List<AquaticSalesDirector__c> NewAq= new List<AquaticSalesDirector__c>();
        AquaticSalesDirector__c AquaticDir = new AquaticSalesDirector__c();
        AquaticDir.Name = 'ID of Director';
        AquaticDir.ID_of_Director__c ='005d0000000Tvtk';
        NewAq.add(AquaticDir);
        
        AquaticSalesDirector__c AquaticDir1 = new AquaticSalesDirector__c();
        AquaticDir1.Name = 'ID of Record';
        AquaticDir1.ID_of_Director__c ='0122F0000008y3a';
        NewAq.add(AquaticDir1);
        
        insert NewAq;*/

        system.runAs(u1)
        {
        Id rtId = Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('AES').RecordTypeId;
        
        Account Acc=new Account();
        Acc.Name = 'Test Account';
        insert Acc;

        Opportunity opp=new opportunity();
        opp.Name = 'Test Opp';
        opp.AccountId = Acc.id;
        opp.CloseDate = System.today() + 5;
        opp.StageName = 'Approach'; 
        opp.RecordTypeId = rtId;
        insert opp;
                
        
        Test.startTest();
        List<Training_Events__c> TesttrainingEventUpdate = new List<Training_Events__c>();
        Training_Events__c TE1 = new Training_Events__c();
        TE1.Opportunity__c = opp.id;
        insert TE1;
        
        Facility__c Fac1=new Facility__c();
        Fac1.Name = 'Test Facility';
        Fac1.Facility_Address_1__c ='Test Address 1';
        Fac1.Facility_Address_2__c ='Test Address 2';
        Fac1.Facility_City__c = 'Test City';
        Fac1.Facility_State__c = 'AK';
        Fac1.Facility_Zip__c = '582145';
        Fac1.Account__c = Acc.id;
        Fac1.Aquatics_Examiner_Service__c = TE1.id;
        
        insert Fac1;
        Test.stopTest();
    
        }
    }
    
}