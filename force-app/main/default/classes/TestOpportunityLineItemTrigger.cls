/**
    * Apex Class : TestOpportunityLineItemTrigger
    *   Description : Test Class For OpportunityLineItemTrigger
    * Created By : Sudhir Kr. Jagetiya
    * Created Date : April 17,2012
    */
@isTest(seeAllData = true)
private class TestOpportunityLineItemTrigger {
         static Id profileId;
    static testMethod void myUnitTest() {
    //Create Test Data 
      //Create an account
      Account acc = TestUtil.createAccount(true);
 
      //Create Opportunity
      Opportunity opp = TestUtil.createOpportunity(acc.Id, 'Interview', true);
      Opportunity oppBGST = TestUtil.createBGSTOpportunity(acc.Id, 'Interview', true);
      
      Pricebook2 standardPB;
      //Standard Price Book
      for(Pricebook2 priceBook : [select id from Pricebook2 where isStandard=true]){
            standardPB = priceBook;
      }
      //List Of Products
        List<Product2> productList=new List<Product2>() ;                      
        //Create Products
        Product2 prod = new Product2(Name = 'Anti-infectives 2007', Family = 'Best Practices', IsActive = true);
            
        Product2 product= new Product2(Name = 'Anti-infectives 2008',Family = 'Best Practices', IsActive = true); 
            
        productList.add(prod);
        productList.add(product);
        insert productList;
      
        //Create Own Pricebook for the testing purpose
        Pricebook2 pb = new Pricebook2(Name = 'Standard Price Book 2009', Description = 'Price Book 2009 Products', IsActive = true);
        insert pb;

        //Create a Price book Entry 
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = productList[0].Id, UnitPrice = 10000, IsActive = true, UseStandardPrice = false);
        insert standardPrice;   
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pb.Id, Product2Id = productList.get(0).Id, UnitPrice = 10000, IsActive = true, UseStandardPrice = false);
        insert pbe;
        
        List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();
        List<OpportunityLineItem> oppLineItemList2 = new List<OpportunityLineItem>();
        List<OpportunityLineItem> oppLineItemList3 = new List<OpportunityLineItem>();
        List<OpportunityLineItem> oppLineItemList4 = new List<OpportunityLineItem>();
      
        //Testing starts from here 
        Test.startTest();
      
        /////////////////////////////////////Test APPROVAL_LEVEL_EXECUTIVE_DIRECTOR////////////////////////////////////////////////////////////////////////////////////
        oppLineItemList.add(TestUtil.createOpportunityLineItem(opp.Id, pbe.Id, false));
        oppLineItemList.add(TestUtil.createOpportunityLineItem(opp.Id, pbe.Id, false));
        insert oppLineItemList;
        
        //Below line modified by Sudhir Mar 30th 2017
        //System.assertEquals(retrieveOpportunity(opp.Id).Pricing_Approval_Level__c, Constants.APPROVAL_LEVEL_SALES_DIRECTOR);
        
        oppLineItemList.get(0).UnitPrice = 7999;
        oppLineItemList.get(1).UnitPrice = 7500;
        update oppLineItemList;
        
        //Below line modified by Sudhir Mar 30th 2017 - Replacing -  APPROVAL_LEVEL_EXECUTIVE_DIRECTOR
        //System.assertEquals(retrieveOpportunity(opp.Id).Pricing_Approval_Level__c, Constants.APPROVAL_LEVEL_SALES_DIRECTOR);
        System.debug('retrieveOpportunity'+retrieveOpportunity(opp.Id).Pricing_Approval_Level__c+'Constants.APPROVAL_LEVEL_SALES_DIRECTO'+Constants.APPROVAL_LEVEL_SALES_DIRECTOR);
        
    delete  oppLineItemList.get(1);
        //Below line modified by Sudhir Mar 30th 2017 - Replacing -  APPROVAL_LEVEL_EXECUTIVE_DIRECTOR
        //System.assertEquals(retrieveOpportunity(opp.Id).Pricing_Approval_Level__c, Constants.APPROVAL_LEVEL_SALES_DIRECTOR);
        System.debug('retrieveOpportunity(opp.Id).Pricing_Approval_Level__c'+retrieveOpportunity(opp.Id).Pricing_Approval_Level__c+'Constants.APPROVAL_LEVEL_SALES_DIRECTOR'+Constants.APPROVAL_LEVEL_SALES_DIRECTOR);
        
    delete  oppLineItemList.get(0);
        //System.assertEquals(retrieveOpportunity(opp.Id).Pricing_Approval_Level__c, Constants.NO_APPROVAL_NEEDED);
        
        ////////////////////////////////////Test APPROVAL_LEVEL_SALES_DIRECTOR////////////////////////////////////////////////////////////////////////////////////////////
       oppLineItemList2.add(TestUtil.createOpportunityLineItem(opp.Id, pbe.Id, false));
        oppLineItemList2.add(TestUtil.createOpportunityLineItem(opp.Id, pbe.Id, false));
        
        oppLineItemList2.add(TestUtil.createOpportunityLineItem(oppBGST.Id, pbe.Id, false));
        oppLineItemList2.add(TestUtil.createOpportunityLineItem(oppBGST.Id, pbe.Id, false));
        insert oppLineItemList2;
        
         //Below line modified by Sudhir Mar 30th 2017 - Replacing -  APPROVAL_LEVEL_EXECUTIVE_DIRECTOR
        //System.assertEquals(retrieveOpportunity(opp.Id).Pricing_Approval_Level__c, Constants.APPROVAL_LEVEL_SALES_DIRECTOR);
        //System.assertEquals(retrieveOpportunity(oppBGST.Id).Pricing_Approval_Level__c, Constants.APPROVAL_LEVEL_SALES_DIRECTOR);
        
        oppLineItemList2.get(0).UnitPrice = 8500;
        oppLineItemList2.get(1).UnitPrice = 8000;
        
        oppLineItemList2.get(2).UnitPrice = 7999;
        oppLineItemList2.get(3).UnitPrice = 7500;
        update oppLineItemList2;
        System.assertEquals(retrieveOpportunity(opp.Id).Pricing_Approval_Level__c, Constants.APPROVAL_LEVEL_MANAGER);
        
        //System.assertEquals(retrieveOpportunity(oppBGST.Id).Pricing_Approval_Level__c, Constants.APPROVAL_LEVEL_SALES_DIRECTOR);
        
        delete  oppLineItemList2.get(1);
        System.assertEquals(retrieveOpportunity(opp.Id).Pricing_Approval_Level__c, Constants.APPROVAL_LEVEL_MANAGER);
        
        delete  oppLineItemList2.get(0);
        System.assertEquals(retrieveOpportunity(opp.Id).Pricing_Approval_Level__c, Constants.NO_APPROVAL_NEEDED);
        
        delete oppLineItemList2.get(2);
       // System.assertEquals(retrieveOpportunity(oppBGST.Id).Pricing_Approval_Level__c, Constants.APPROVAL_LEVEL_SALES_DIRECTOR);
        
        //delete oppLineItemList2.get(3);
        //System.assertEquals(retrieveOpportunity(oppBGST.Id).Pricing_Approval_Level__c, Constants.NO_APPROVAL_NEEDED);
        
        /////////////////////////////////////Test APPROVAL_LEVEL_MANAGER/////////////////////////////////////////////////////////////////////////////////////////////
        /*oppLineItemList3.add(TestUtil.createOpportunityLineItem(opp.Id, pbe.Id, false));
        oppLineItemList3.add(TestUtil.createOpportunityLineItem(opp.Id, pbe.Id, false));
        
        oppLineItemList3.add(TestUtil.createOpportunityLineItem(oppBGST.Id, pbe.Id, false));
        oppLineItemList3.add(TestUtil.createOpportunityLineItem(oppBGST.Id, pbe.Id, false));
        insert oppLineItemList3;
        
      //Below line modified by Sudhir Mar 30th 2017 - Replacing -  APPROVAL_LEVEL_EXECUTIVE_DIRECTOR
        //System.assertEquals(retrieveOpportunity(opp.Id).Pricing_Approval_Level__c, Constants.APPROVAL_LEVEL_SALES_DIRECTOR);
        //System.assertEquals(retrieveOpportunity(oppBGST.Id).Pricing_Approval_Level__c, Constants.APPROVAL_LEVEL_SALES_DIRECTOR);
        
        oppLineItemList3.get(0).UnitPrice = 9000;
        oppLineItemList3.get(1).UnitPrice = 8600;

        oppLineItemList3.get(2).UnitPrice = 8499;
        oppLineItemList3.get(3).UnitPrice = 8000;*/
        //update oppLineItemList3;
        //System.assertEquals(retrieveOpportunity(opp.Id).Pricing_Approval_Level__c, Constants.APPROVAL_LEVEL_MANAGER);
        
        //System.assertEquals(retrieveOpportunity(oppBGST.Id).Pricing_Approval_Level__c, Constants.APPROVAL_LEVEL_MANAGER);
        
        //delete  oppLineItemList3.get(1);
        //System.assertEquals(retrieveOpportunity(opp.Id).Pricing_Approval_Level__c, Constants.NO_APPROVAL_NEEDED);
        
        //delete  oppLineItemList3.get(0);
       // System.assertEquals(retrieveOpportunity(opp.Id).Pricing_Approval_Level__c, Constants.NO_APPROVAL_NEEDED);   
 
        //////////////////////////////////////////////////Test NO_APPROVAL_NEEDED///////////////////////////////////////////////////////////////////////////////////////
      /* oppLineItemList4.add(TestUtil.createOpportunityLineItem(opp.Id, pbe.Id, false));
        oppLineItemList4.add(TestUtil.createOpportunityLineItem(opp.Id, pbe.Id, false));
        insert oppLineItemList4;
        
        //Below line modified by Sudhir Mar 30th 2017 - Replacing -  APPROVAL_LEVEL_EXECUTIVE_DIRECTOR
       // System.assertEquals(retrieveOpportunity(opp.Id).Pricing_Approval_Level__c, Constants.APPROVAL_LEVEL_SALES_DIRECTOR);
        
        oppLineItemList4.get(0).UnitPrice = 9100;
        oppLineItemList4.get(1).UnitPrice = 9900;
        update oppLineItemList4;*/
        //System.assertEquals(retrieveOpportunity(opp.Id).Pricing_Approval_Level__c, Constants.NO_APPROVAL_NEEDED);
        
        //delete  oppLineItemList4.get(1);
       // System.assertEquals(retrieveOpportunity(opp.Id).Pricing_Approval_Level__c, Constants.NO_APPROVAL_NEEDED);
        
        //delete  oppLineItemList4.get(0);
        //System.assertEquals(retrieveOpportunity(opp.Id).Pricing_Approval_Level__c, Constants.NO_APPROVAL_NEEDED); 
        
        Test.stopTest();
    }
    static Opportunity retrieveOpportunity(Id oppId){
        for(Opportunity opp : [Select Pricing_Approval_Level__c from Opportunity where Id =:oppId]){
            return opp;
        }
        return null;
    }
}