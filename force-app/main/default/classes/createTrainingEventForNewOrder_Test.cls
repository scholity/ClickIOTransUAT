/**
 * Created by bjarmolinski on 2019-07-02.
 */

@isTest
public without sharing class createTrainingEventForNewOrder_Test {

    // test coverage for createTrainingEventForNewOrder trigger
    // insert and update orders
    // create test settings

    @isTest
    static void test1() {

        PHSS_TriggerSettings__c settings = PHSS_TestUtility.createTriggerSettings();
        settings.UserProvisioningDisabled__c = true;
        settings.CreateTrainingEventForNewOrderDisabled__c = false;
        insert settings;

        Account acc = new Account();
        acc.Name = 'TestAccount';
        acc.BillingStreet = '24 Willie Mays Plaza kryan';
        acc.BillingCity = 'San Fran';
        acc.BillingState = 'Cali';
        acc.BillingPostalCode = '94018';
        acc.BillingCountry = 'US';
        acc.Phone = '9876543219';
        insert acc;

        Order o = new Order();
        o.AccountId = acc.Id;
        o.EffectiveDate = Date.today();
        o.Status = Order.Status.getDescribe().getPicklistValues()[0].getLabel();
        o.NSSCCConnector__SFCC_Order_Total__c = 10;
        insert o;

        o.EffectiveDate = Date.today().addDays(1);
        update o;

    }
}