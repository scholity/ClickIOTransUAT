/*******************************************************************
Name  : TestSmartAccountSearchExtension
Author: Appirio Offshore (Urminder Vohra)
Date  : July 19, 2011
 
*************************************************************************/
@isTest
private class TestSmartAccountSearchExtension {

    static testMethod void myUnitTest() {
        ApexPages.StandardController sc;
        createData();
        SmartAccountSearchExtension controller = new SmartAccountSearchExtension(sc);
        controller.accountNameToSeaarch = '00TestAccount0';
       
        controller.requestedPage = '1';
        controller.performSearch();
        
        System.assert(55<=controller.searchCount);
        System.assertEquals(1,controller.showingFrom);
        System.assertEquals(20,controller.showingTo);
        System.assertEquals(3,controller.totalPage);
        System.assertEquals(true,controller.hasNext);
        System.assertEquals(false,controller.hasPrevious);
        
        controller.nextAccountPage();
        System.assertEquals(21,controller.showingFrom);
        System.assertEquals(40,controller.showingTo);
        System.assertEquals(3,controller.totalPage);
        System.assertEquals(true,controller.hasNext);
        System.assertEquals(true,controller.hasPrevious);
        
        controller.previousAccountPage();
        
        controller.requestedPage = '3';
        controller.requestedAccountPage();
        System.assertEquals(41,controller.showingFrom);
        System.assertEquals(55,controller.showingTo);
        System.assertEquals(3,controller.totalPage);
        System.assertEquals(false,controller.hasNext);
        System.assertEquals(true,controller.hasPrevious);
        
        
        controller.sortData();
        controller.cancel();
        
        controller.requestedPage = '5';
        controller.requestedAccountPage();
    }
    static void CreateData() {
       list<Account> accList = new list<Account>();
       for(Integer i=0;i<55;i++) {
           Account acc = new Account();
           acc.Name = '00TestAccount0' + i;
           acc.BillingStreet = '123 Rodeo Dr.';
           acc.BillingCity = 'Beverly Hills';
           acc.BillingState = 'CA';
           acc.BillingPostalCode = '90210';
           //acc.BillingCountry = 'Germany';
           //acc.Region__c = 'Europe';
           //acc.Sub_Region__c = 'Germany';
           //acc.CurrencyIsoCode = 'EUR';  
           accList.add(acc);
       }
       
       insert accList;
    }
}