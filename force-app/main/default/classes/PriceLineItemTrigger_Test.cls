/**
 * Created by bjarmolinski on 2019-07-02.
 */

@isTest
public without sharing class PriceLineItemTrigger_Test {
    // update price line items
    // create custom settings PHSS_TriggerSettings__c
    // create and update ccrz__E_PriceListItem__c

    @isTest
    static void test1() {

        PHSS_TriggerSettings__c settings = PHSS_TestUtility.createTriggerSettings();
        settings.UserProvisioningDisabled__c = true;
        insert settings;

        List<ccrz__E_Product__c> eProducts = phss_cc_TestDataFactory.createInsertTestProducts(1);
        ccrz__E_PriceList__c ePriceList = phss_cc_TestDataFactory.createInsertTestPricelist();

        phss_cc_TestDataFactory.createInsertPriceListItems(eProducts, ePriceList);

        List<ccrz__E_PriceListItem__c> lineItems = [SELECT Id, Name, Cost_Price__c FROM ccrz__E_PriceListItem__c ];
        System.debug(lineItems);

        Test.startTest();
        for (ccrz__E_PriceListItem__c e : lineItems) {
            e.Cost_Price__c = 1;
        }
        update lineItems;
        Test.stopTest();

        System.assertNotEquals(null, lineItems[0].Cost_Price__c);

    }
}