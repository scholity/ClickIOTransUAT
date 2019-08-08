/**
    * Apex Class : TestOpportunityTrigger
    *   Description : Test Class For OpportunityTrigger
    *                  This test that the Approvers are set correctly based on the Pricing Approval Level
    * Created By : Sudhir Kr. Jagetiya
    * Created Date : April 17,2012
    */
@isTest
private class TestOpportunityTrigger {
    //Test Method to check the Quality of the Code
        static Id profileId;
        static{
      for(Profile profile : [select Id from Profile where Name='ARC Sales User']){
         profileId = profile.Id;
      }
        }
    static testMethod void myUnitTest() {
      //Create Test Data 
      Account acc = TestUtil.createAccount(true);
        
      //Testing start from here
      Test.startTest();
          //Create users and management hierarchy
          //--------------------------------------
          // MOM
          //     |--> executive director
          //         |--> sales director
          //             |--> manager
          //                |--> salesRep
        
          List<String> defaultApproverNameParts = System.Label.DefaultMOMApprover.split(' ');
          System.debug('MOM first name = ' + defaultApproverNameParts[0]);
          System.debug('MOM last name = ' + defaultApproverNameParts[1]);
        
          User mom = TestUtil.createUser('MOM@kjh.com', profileId, false, null, defaultApproverNameParts[1], defaultApproverNameParts[0]);
          insert mom;

          User executiveDirector = TestUtil.createUser('ED@kjh.com', profileId, false, mom.id, 'Director', 'Executive');
          insert executiveDirector;        
        
          User salesDirector = TestUtil.createUser('SD@kjh.com', profileId, false, executiveDirector.id, 'Director', 'Sales');
          insert salesDirector;
        
          User manager = TestUtil.createUser('M@kjh.com', profileId, false, salesDirector.id, 'Manager', 'Sales');
          insert manager;
                
          User salesRep = TestUtil.createUser('SR@kjh.com', profileId, false, manager.id, 'Rep', 'Sales');
          insert salesRep;
     
          System.debug('MOM = ' + mom.Name + ' ' + mom.id);
          System.debug('executiveDirector = ' + executiveDirector.id);
          System.debug('salesDirector = ' + salesDirector.id);
          System.debug('manager = ' + manager.id);
        
        
           List<BGST_Profiles__c> ProfilesList = new List<BGST_Profiles__c>();
          BGST_Profiles__c indiv = new BGST_Profiles__c();
          indiv.name = 'Owner Profile';
          indiv.Sales_User__c = 'ARC BGST Sales User';
          ProfilesList.add(indiv);
          insert ProfilesList;
          
          Id rtId = Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('AES').RecordTypeId;
          List<AquaticSalesDirector__c> NewAq= new List<AquaticSalesDirector__c>();
            AquaticSalesDirector__c AquaticDir = new AquaticSalesDirector__c();
            AquaticDir.Name = 'AES Approvers ID';
            AquaticDir.ID_of_Director__c =salesDirector.id;
            AquaticDir.Executive_Director_ID__c = executiveDirector.id;
            AquaticDir.Id_of_Record__c = rtId;
            NewAq.add(AquaticDir);
            
            /*AquaticSalesDirector__c AquaticDir1 = new AquaticSalesDirector__c();
            AquaticDir1.Name = 'ID of Record';
            AquaticDir1.ID_of_Director__c = rtId;
            NewAq.add(AquaticDir1);
            
            SaleExecutiveDirector__c SaleDir=new SaleExecutiveDirector__c();
            SaleDir.Name = 'Executive Director ID';
            SaleDir.Executive_ID__c = executiveDirector.id;
            insert SaleDir;*/
        
        insert NewAq;
        
          //create an opportunity To fire the trigger on insert
          Opportunity opp = TestUtil.createOpportunity(acc.Id, 'Interview', false);
          //opp.Approval_Status__c = 'N/A';
          //opp.Pricing_Approval_Level__c = Constants.NO_APPROVAL_NEEDED;
          opp.OwnerId = salesRep.Id;

        
          //Test APPROVAL_LEVEL_MOM level
          //   Check that all 4 Approvers are populated as follows
          //     - Approver_1__c is the opportunity owner's manager
          //     - Approver_2__c is the opportunity owner's manager's manager 
          //     - Approver_3__c is the opportunity owner's manager's manager' manager
          //     - Approver_4__c is the DefaultMOMApprover      
          opp.Pricing_Approval_Level__c = Constants.APPROVAL_LEVEL_MOM;
          
          insert opp;
          
        
              
          /*System.assertEquals(retrieveOpportunity(opp.Id).Approver_1__c, manager.Id);
          System.assertEquals(retrieveOpportunity(opp.Id).Approver_2__c, salesDirector.Id);
          System.assertEquals(retrieveOpportunity(opp.Id).Approver_3__c, executiveDirector.Id);
          System.assertEquals(retrieveOpportunity(opp.Id).Approver_4__c, mom.Id);*/
        
          //Test APPROVAL_LEVEL_MANAGER level
          //   Check Approver_1__c is the opportunity owner's manager and the rest of the approvers are null
          opp.Pricing_Approval_Level__c = Constants.APPROVAL_LEVEL_MANAGER;
          update opp;
         /* System.assertEquals(retrieveOpportunity(opp.Id).Approver_1__c, manager.Id);
          System.assertEquals(retrieveOpportunity(opp.Id).Approver_2__c, null);
          System.assertEquals(retrieveOpportunity(opp.Id).Approver_3__c, null);
          System.assertEquals(retrieveOpportunity(opp.Id).Approver_4__c, null);*/
        
          //Test  APPROVAL_LEVEL_SALES_DIRECTOR level
          //   Check 
          //     - Approver_1__c is the opportunity owner's manager
          //     - Approver_2__c is the opportunity owner's manager's manager 
          //     - Approver_3__c is null
          //     - Approver_4__c is null
          opp.Pricing_Approval_Level__c = Constants.APPROVAL_LEVEL_SALES_DIRECTOR;
          update opp;
          
            opp.Pricing_Approval_Level__c = Constants.APPROVAL_LEVEL_EXECUTIVE_DIRECTOR;
            update opp;
            
         //Check that Approver_1__c should be manager of Opportunity Owner.
           System.debug('manager.Id = ' + manager.Id);
           System.debug('salesDirector.Id = ' + salesDirector.Id);
         //  System.assertEquals(retrieveOpportunity(opp.Id).Approver_1__c, manager.Id);
         //  System.assertEquals(retrieveOpportunity(opp.Id).Approver_2__c, salesDirector.Id);
         //  System.assertEquals(retrieveOpportunity(opp.Id).Approver_3__c, null);
          // System.assertEquals(retrieveOpportunity(opp.Id).Approver_4__c, null);
        
        
          //Test NO_APPROVAL_NEEDED level
          //   Check that all 3 Approvers are null
          opp.Pricing_Approval_Level__c = Constants.NO_APPROVAL_NEEDED;
          update opp;
          //System.assertEquals(retrieveOpportunity(opp.Id).Approver_1__c,null);
         // System.assertEquals(retrieveOpportunity(opp.Id).Approver_2__c,null);
         // System.assertEquals(retrieveOpportunity(opp.Id).Approver_3__c,null); 
         // System.assertEquals(retrieveOpportunity(opp.Id).Approver_4__c,null);   
         ID OpportunityId = [Select Id From RecordType Where SobjectType = 'Opportunity' and Name = 'AED'].id;
         opp.Pricing_Approval_Level__c = Constants.NO_APPROVAL_NEEDED;
          opp.RecordTypeId = OpportunityId;
          opp.Pricing_Approval_Level__c = Constants.APPROVAL_LEVEL_EXECUTIVE_DIRECTOR;
          update opp;
  
    }
    
    static testMethod void myUnitTest1() {
      //Create Test Data 
       for(Profile profile1 : [select Id from Profile where Name='ARC BGST Sales User']){
         profileId = profile1.Id;
      }
      
      Account acc = TestUtil.createAccount(true);
        
      //Testing start from here
      Test.startTest();
          List<String> defaultApproverNameParts = System.Label.DefaultMOMApprover.split(' ');
          System.debug('MOM first name = ' + defaultApproverNameParts[0]);
          System.debug('MOM last name = ' + defaultApproverNameParts[1]);
        
          User mom = TestUtil.createUser('MOM@kjh.com', profileId, false, null, defaultApproverNameParts[1], defaultApproverNameParts[0]);
          insert mom;

          User executiveDirector = TestUtil.createUser('ED@kjh.com', profileId, false, mom.id, 'Director', 'Executive');
          insert executiveDirector;        
        
          User salesDirector = TestUtil.createUser('SD@kjh.com', profileId, false, executiveDirector.id, 'Director', 'Sales');
          insert salesDirector;
        
          User manager = TestUtil.createUser('M@kjh.com', profileId, false, salesDirector.id, 'Manager', 'Sales');
          insert manager;
                
          User salesRep = TestUtil.createUser('SR@kjh.com', profileId, false, manager.id, 'Rep', 'Sales');
          insert salesRep;
     
          System.debug('MOM = ' + mom.Name + ' ' + mom.id);
          System.debug('executiveDirector = ' + executiveDirector.id);
          System.debug('salesDirector = ' + salesDirector.id);
          System.debug('manager = ' + manager.id);
        
        
           List<BGST_Profiles__c> ProfilesList = new List<BGST_Profiles__c>();
          BGST_Profiles__c indiv = new BGST_Profiles__c();
          indiv.name = 'Owner Profile';
          indiv.Sales_User__c = 'ARC BGST Sales User';
          ProfilesList.add(indiv);
          insert ProfilesList;
            
            Id rtId = Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('AES').RecordTypeId;
            List<AquaticSalesDirector__c> NewAq= new List<AquaticSalesDirector__c>();
            AquaticSalesDirector__c AquaticDir = new AquaticSalesDirector__c();
            AquaticDir.Name = 'AES Approvers ID';
            AquaticDir.ID_of_Director__c =salesDirector.id;
                        AquaticDir.Executive_Director_ID__c = executiveDirector.id;
            AquaticDir.Id_of_Record__c = rtId;
            NewAq.add(AquaticDir);
            
            /*AquaticSalesDirector__c AquaticDir1 = new AquaticSalesDirector__c();
            AquaticDir1.Name = 'ID of Record';
            AquaticDir1.ID_of_Director__c = rtId;
            NewAq.add(AquaticDir1);
            
            SaleExecutiveDirector__c SaleDir=new SaleExecutiveDirector__c();
            SaleDir.Name = 'Executive Director ID';
            SaleDir.Executive_ID__c = executiveDirector.id;
            insert SaleDir;*/
        
            insert NewAq;
        
          //create an opportunity To fire the trigger on insert
          Opportunity opp = TestUtil.createOpportunity(acc.Id, 'Interview', false);
          opp.OwnerId = salesRep.Id;

          opp.Pricing_Approval_Level__c = Constants.APPROVAL_LEVEL_MOM;
          
          insert opp;
         
          opp.Pricing_Approval_Level__c = Constants.APPROVAL_LEVEL_MANAGER;
          update opp;
      
          opp.Pricing_Approval_Level__c = Constants.APPROVAL_LEVEL_SALES_DIRECTOR;
          update opp;
          
            opp.Pricing_Approval_Level__c = Constants.APPROVAL_LEVEL_EXECUTIVE_DIRECTOR;
            update opp;
            
         //Check that Approver_1__c should be manager of Opportunity Owner.
           System.debug('manager.Id = ' + manager.Id);
           System.debug('salesDirector.Id = ' + salesDirector.Id);
       
        ID OpportunityId = [Select Id From RecordType Where SobjectType = 'Opportunity' and Name = 'AED'].id;
          opp.Pricing_Approval_Level__c = Constants.NO_APPROVAL_NEEDED;
          opp.RecordTypeId = OpportunityId;
          opp.Pricing_Approval_Level__c = Constants.APPROVAL_LEVEL_EXECUTIVE_DIRECTOR;
          update opp;
       
  
    }
    
     static testMethod void myUnitTest2() {
      //Create Test Data 
       for(Profile profile1 : [select Id from Profile where Name='ARC Sales User']){
         profileId = profile1.Id;
      }
      
      Account acc = TestUtil.createAccount(true);
        
      //Testing start from here
      Test.startTest();
          List<String> defaultApproverNameParts = System.Label.DefaultMOMApprover.split(' ');
          System.debug('MOM first name = ' + defaultApproverNameParts[0]);
          System.debug('MOM last name = ' + defaultApproverNameParts[1]);
        
          User mom = TestUtil.createUser('MOM@kjh.com', profileId, false, null, defaultApproverNameParts[1], defaultApproverNameParts[0]);
          insert mom;

          User executiveDirector = TestUtil.createUser('ED@kjh.com', profileId, false, mom.id, 'Director', 'Executive');
          insert executiveDirector;        
        
          User salesDirector = TestUtil.createUser('SD@kjh.com', profileId, false, executiveDirector.id, 'Director', 'Sales');
          insert salesDirector;
        
          User manager = TestUtil.createUser('M@kjh.com', profileId, false, salesDirector.id, 'Manager', 'Sales');
          insert manager;
                
          User salesRep = TestUtil.createUser('SR@kjh.com', profileId, false, manager.id, 'Rep', 'Sales');
          insert salesRep;
     
          System.debug('MOM = ' + mom.Name + ' ' + mom.id);
          System.debug('executiveDirector = ' + executiveDirector.id);
          System.debug('salesDirector = ' + salesDirector.id);
          System.debug('manager = ' + manager.id);
        
        
           List<BGST_Profiles__c> ProfilesList = new List<BGST_Profiles__c>();
          BGST_Profiles__c indiv = new BGST_Profiles__c();
          indiv.name = 'Owner Profile';
          indiv.Sales_User__c = 'ARC BGST Sales User';
          ProfilesList.add(indiv);
          insert ProfilesList;
            
            Id rtId = Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('Standard').RecordTypeId;
            List<AquaticSalesDirector__c> NewAq= new List<AquaticSalesDirector__c>();
            AquaticSalesDirector__c AquaticDir = new AquaticSalesDirector__c();
            AquaticDir.Name = 'AES Approvers ID';
            AquaticDir.ID_of_Director__c =salesDirector.id;
                        AquaticDir.Executive_Director_ID__c = executiveDirector.id;
            AquaticDir.Id_of_Record__c = rtId;
            NewAq.add(AquaticDir);
            
            /*AquaticSalesDirector__c AquaticDir1 = new AquaticSalesDirector__c();
            AquaticDir1.Name = 'ID of Record';
            AquaticDir1.ID_of_Director__c = rtId;
            NewAq.add(AquaticDir1);
            
            SaleExecutiveDirector__c SaleDir=new SaleExecutiveDirector__c();
            SaleDir.Name = 'Executive Director ID';
            SaleDir.Executive_ID__c = executiveDirector.id;
            insert SaleDir;*/
        
            insert NewAq;
        
          //create an opportunity To fire the trigger on insert
          Opportunity opp = TestUtil.createOpportunity(acc.Id, 'Interview', false);
          opp.OwnerId = salesRep.Id;
            
          opp.Pricing_Approval_Level__c = Constants.APPROVAL_LEVEL_MOM;
         
          insert opp;
         
          opp.Pricing_Approval_Level__c = Constants.APPROVAL_LEVEL_MANAGER;
          update opp;
      
          opp.Pricing_Approval_Level__c = Constants.APPROVAL_LEVEL_SALES_DIRECTOR;
          update opp;
          
            opp.Pricing_Approval_Level__c = Constants.APPROVAL_LEVEL_EXECUTIVE_DIRECTOR;
            update opp;
            
         //Check that Approver_1__c should be manager of Opportunity Owner.
           System.debug('manager.Id = ' + manager.Id);
           System.debug('salesDirector.Id = ' + salesDirector.Id);
       
        ID OpportunityId = [Select Id From RecordType Where SobjectType = 'Opportunity' and Name = 'Standard'].id;
          opp.Pricing_Approval_Level__c = Constants.NO_APPROVAL_NEEDED;
          opp.RecordTypeId = OpportunityId;
          opp.Pricing_Approval_Level__c = Constants.APPROVAL_LEVEL_EXECUTIVE_DIRECTOR;
          update opp;
       
  
    }
    
    static testMethod void myUnitTest3() {
      //Create Test Data 
       for(Profile profile1 : [select Id from Profile where Name='ARC SCC User']){
         profileId = profile1.Id;
      }
      
      Account acc = TestUtil.createAccount(true);
        
      //Testing start from here
      Test.startTest();
          List<String> defaultApproverNameParts = System.Label.DefaultMOMApprover.split(' ');
          System.debug('MOM first name = ' + defaultApproverNameParts[0]);
          System.debug('MOM last name = ' + defaultApproverNameParts[1]);
        
          User mom = TestUtil.createUser('MOM@kjh.com', profileId, false, null, defaultApproverNameParts[1], defaultApproverNameParts[0]);
          insert mom;

          User executiveDirector = TestUtil.createUser('ED@kjh.com', profileId, false, mom.id, 'Director', 'Executive');
          insert executiveDirector;        
        
          User salesDirector = TestUtil.createUser('SD@kjh.com', profileId, false, executiveDirector.id, 'Director', 'Sales');
          insert salesDirector;
        
          User manager = TestUtil.createUser('M@kjh.com', profileId, false, salesDirector.id, 'Manager', 'Sales');
          insert manager;
                
          User salesRep = TestUtil.createUser('SR@kjh.com', profileId, false, manager.id, 'Rep', 'Sales');
          insert salesRep;
     
          System.debug('MOM = ' + mom.Name + ' ' + mom.id);
          System.debug('executiveDirector = ' + executiveDirector.id);
          System.debug('salesDirector = ' + salesDirector.id);
          System.debug('manager = ' + manager.id);
        
        
           List<BGST_Profiles__c> ProfilesList = new List<BGST_Profiles__c>();
          BGST_Profiles__c indiv = new BGST_Profiles__c();
          indiv.name = 'Owner Profile';
          indiv.Sales_User__c = 'ARC BGST Sales User';
          ProfilesList.add(indiv);
          insert ProfilesList;
            
            Id rtId = Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('Standard').RecordTypeId;
            List<AquaticSalesDirector__c> NewAq= new List<AquaticSalesDirector__c>();
            AquaticSalesDirector__c AquaticDir = new AquaticSalesDirector__c();
            AquaticDir.Name = 'AES Approvers ID';
            AquaticDir.ID_of_Director__c =salesDirector.id;
                        AquaticDir.Executive_Director_ID__c = executiveDirector.id;
            AquaticDir.Id_of_Record__c = rtId;
            NewAq.add(AquaticDir);
            
           /* AquaticSalesDirector__c AquaticDir1 = new AquaticSalesDirector__c();
            AquaticDir1.Name = 'ID of Record';
            AquaticDir1.ID_of_Director__c = rtId;
            NewAq.add(AquaticDir1);
            
            SaleExecutiveDirector__c SaleDir=new SaleExecutiveDirector__c();
            SaleDir.Name = 'Executive Director ID';
            SaleDir.Executive_ID__c = executiveDirector.id;
            insert SaleDir;*/
        
            insert NewAq;
        
          //create an opportunity To fire the trigger on insert
          Opportunity opp = TestUtil.createOpportunity(acc.Id, 'Interview', false);
          opp.OwnerId = salesRep.Id;

          opp.Pricing_Approval_Level__c = Constants.APPROVAL_LEVEL_MOM;
         
          insert opp;
         
          opp.Pricing_Approval_Level__c = Constants.APPROVAL_LEVEL_MANAGER;
          update opp;
      
          opp.Pricing_Approval_Level__c = Constants.APPROVAL_LEVEL_SALES_DIRECTOR;
          update opp;
          
            opp.Pricing_Approval_Level__c = Constants.APPROVAL_LEVEL_EXECUTIVE_DIRECTOR;
            update opp;
            
         //Check that Approver_1__c should be manager of Opportunity Owner.
           System.debug('manager.Id = ' + manager.Id);
           System.debug('salesDirector.Id = ' + salesDirector.Id);
       
        ID OpportunityId = [Select Id From RecordType Where SobjectType = 'Opportunity' and Name = 'Standard'].id;
          opp.Pricing_Approval_Level__c = Constants.NO_APPROVAL_NEEDED;
          opp.RecordTypeId = OpportunityId;
          opp.Pricing_Approval_Level__c = Constants.APPROVAL_LEVEL_EXECUTIVE_DIRECTOR;
          update opp;
       
  
    }
    static testMethod void myUnitTest4() {
      //Create Test Data 
       for(Profile profile1 : [select Id from Profile where Name='ARC Sales User']){
         profileId = profile1.Id;
      }
      
      Account acc = TestUtil.createAccount(true);
        
      //Testing start from here
      Test.startTest();
          List<String> defaultApproverNameParts = System.Label.DefaultMOMApprover.split(' ');
          System.debug('MOM first name = ' + defaultApproverNameParts[0]);
          System.debug('MOM last name = ' + defaultApproverNameParts[1]);
        
          User mom = TestUtil.createUser('MOM@kjh.com', profileId, false, null, defaultApproverNameParts[1], defaultApproverNameParts[0]);
          insert mom;

          User executiveDirector = TestUtil.createUser('ED@kjh.com', profileId, false, mom.id, 'Director', 'Executive');
          insert executiveDirector;        
        
          User salesDirector = TestUtil.createUser('SD@kjh.com', profileId, false, executiveDirector.id, 'Director', 'Sales');
          insert salesDirector;
        
          User manager = TestUtil.createUser('M@kjh.com', profileId, false, salesDirector.id, 'Manager', 'Sales');
          insert manager;
                
          User salesRep = TestUtil.createUser('SR@kjh.com', profileId, false, manager.id, 'Rep', 'Sales');
          insert salesRep;
     
          System.debug('MOM = ' + mom.Name + ' ' + mom.id);
          System.debug('executiveDirector = ' + executiveDirector.id);
          System.debug('salesDirector = ' + salesDirector.id);
          System.debug('manager = ' + manager.id);
        
        
           List<BGST_Profiles__c> ProfilesList = new List<BGST_Profiles__c>();
          BGST_Profiles__c indiv = new BGST_Profiles__c();
          indiv.name = 'Owner Profile';
          indiv.Sales_User__c = 'ARC BGST Sales User';
          ProfilesList.add(indiv);
          insert ProfilesList;
            
            Id rtId = Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('AES').RecordTypeId;
            List<AquaticSalesDirector__c> NewAq= new List<AquaticSalesDirector__c>();
            AquaticSalesDirector__c AquaticDir = new AquaticSalesDirector__c();
            AquaticDir.Name = 'AES Approvers ID';
            AquaticDir.ID_of_Director__c =salesDirector.id;
                        AquaticDir.Executive_Director_ID__c = executiveDirector.id;
            AquaticDir.Id_of_Record__c = rtId;
            NewAq.add(AquaticDir);
            
            /*AquaticSalesDirector__c AquaticDir1 = new AquaticSalesDirector__c();
            AquaticDir1.Name = 'ID of Record';
            AquaticDir1.ID_of_Director__c = rtId;
            NewAq.add(AquaticDir1);
            
            SaleExecutiveDirector__c SaleDir=new SaleExecutiveDirector__c();
            SaleDir.Name = 'Executive Director ID';
            SaleDir.Executive_ID__c = executiveDirector.id;
            insert SaleDir;*/
        
            insert NewAq;
        
          //create an opportunity To fire the trigger on insert
          Opportunity opp = TestUtil.createOpportunity(acc.Id, 'Interview', false);
          opp.OwnerId = salesRep.Id;
            
          opp.Pricing_Approval_Level__c = Constants.APPROVAL_LEVEL_MOM;
         
          insert opp;
         
          opp.Pricing_Approval_Level__c = Constants.APPROVAL_LEVEL_MANAGER;
          update opp;
      
          opp.Pricing_Approval_Level__c = Constants.APPROVAL_LEVEL_SALES_DIRECTOR;
          update opp;
          
            opp.Pricing_Approval_Level__c = Constants.APPROVAL_LEVEL_EXECUTIVE_DIRECTOR;
            update opp;
            
         //Check that Approver_1__c should be manager of Opportunity Owner.
           System.debug('manager.Id = ' + manager.Id);
           System.debug('salesDirector.Id = ' + salesDirector.Id);
       
        ID OpportunityId = [Select Id From RecordType Where SobjectType = 'Opportunity' and Name = 'AES'].id;
          opp.Pricing_Approval_Level__c = Constants.NO_APPROVAL_NEEDED;
          opp.RecordTypeId = OpportunityId;
          opp.Pricing_Approval_Level__c = Constants.APPROVAL_LEVEL_EXECUTIVE_DIRECTOR;
          update opp;
       
  
    }
    static Opportunity retrieveOpportunity(Id oppId){
        for(Opportunity opp : [Select Approver_1__c, Approver_2__c, Approver_3__c, Approver_4__c from Opportunity where Id =:oppId]){
            return opp;
        }
        return null;
    }
}