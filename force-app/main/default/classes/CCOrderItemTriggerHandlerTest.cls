/************************************************************************************************************************************
** Author: Salesforce Services
** Description: Tests for CCOrderItemTriggerHandler and PHSS_GenerateCSVFileBatchScheduler
************************************************************************************************************************************/

@isTest
public class CCOrderItemTriggerHandlerTest {

    public static Account testAccount;
    public static Opportunity testOpportunity;
    public static ccrz__E_Product__c testProduct;
    public static ccrz__E_Cart__c testCart;
    public static List<ccrz__E_StoredPayment__c> testStoredPayments;

    public static void setupTestData() {

        //Validation rule
        Validation_Rules__c valRule = Validation_Rules__c.getOrgDefaults();
        valRule.Bypass_Rules__c = false;
        insert valRule;

        Switch__c cohstest = new Switch__c();
        cohstest.Switch__c = false;
        cohstest.Name = 'CaseOwnerHistorySwitch';
        insert cohstest;

        Map<String, Object> testData = phss_cc_TestDataFactory.setupAccountAndProducts();

        testAccount = (Account) testData.get(phss_cc_TestDataFactory.TEST_ACCOUNT);
        testAccount.BillingPostalCode = '99999';
        update testAccount;

        List<ccrz__E_Product__c> products = (List<ccrz__E_Product__c>) testData.get(phss_cc_TestDataFactory.TEST_PRODUCTS);
        testProduct = products[0];

        testOpportunity = phss_cc_TestDataFactory.createInsertTestOpportunity(testAccount);

        List<ccrz__E_Cart__c> carts = phss_cc_TestDataFactory.createInsertCartAndCartItems(1, testData, testOpportunity.Id);
        testCart = carts[0];

        testStoredPayments = phss_cc_TestDataFactory.createInsertStoredPayment(1, testOpportunity);
    }

    @IsTest
    static void testOnBeforeInsertAndUpdate() {
        setupTestData();

        Map<String, Object> newPO = new Map<String, Object>{
            phss_cc_OrderUtil.NEW_PO_NAME_KEY => 'Test PO',
            phss_cc_OrderUtil.NEW_PO_AMOUNT_KEY => '1000',
            phss_cc_OrderUtil.NEW_PO_DOSAVE_KEY => true,
            phss_cc_OrderUtil.NEW_PO_START_DATE_KEY => '2019_06_28',
            phss_cc_OrderUtil.NEW_PO_END_DATE_KEY => '2019_06_29'
        };

        Test.startTest();
        Map<String, Object> placeOrderResult = phss_cc_CartController.placeOrderOnCartPO(testOpportunity.Id, testCart.ccrz__EncryptedId__c, newPO);
        Test.stopTest();
    }

    @IsTest
    public static void testGetPaymentPostalCodeForOrder() {
        setupTestData();

        String testPostalCode = '01234';
        testCart.Payment_Postal_Code__c = testPostalCode;
        update testCart;

        Map<String, Object> newPO = new Map<String, Object>{
                phss_cc_OrderUtil.NEW_PO_NAME_KEY => 'Test PO',
                phss_cc_OrderUtil.NEW_PO_AMOUNT_KEY => '1000',
                phss_cc_OrderUtil.NEW_PO_DOSAVE_KEY => true,
                phss_cc_OrderUtil.NEW_PO_START_DATE_KEY => '2019_06_28',
                phss_cc_OrderUtil.NEW_PO_END_DATE_KEY => '2019_06_29'
        };

        Test.startTest();
        Map<String, Object> result = phss_cc_CartController.placeOrderOnCartPO(testOpportunity.Id, testCart.ccrz__EncryptedId__c, newPO);
        String orderId = (String) result.get(phss_cc_OrderUtil.ORDER_ID);
        CCOrderItemTriggerHandler handler = new CCOrderItemTriggerHandler();
        String postalCode = handler.getPaymentPostalCodeForOrder(orderId);
        Test.stopTest();

        System.assertEquals(testPostalCode, postalCode);
    }
}