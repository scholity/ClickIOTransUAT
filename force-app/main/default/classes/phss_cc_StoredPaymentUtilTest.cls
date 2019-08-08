/**
 * Created by jbarker on 2019-07-30.
 */

@IsTest
public with sharing class phss_cc_StoredPaymentUtilTest {

    public static Opportunity testOpportunity;
    public static Map<String, Object> testData;
    public static ccrz__E_Cart__c testCart;
    public static Account testAccount;


    /**
     * @description Creates the basic testdata.
     */
    public static void setupTestData() {

        //Validation rule
        Validation_Rules__c valRule = Validation_Rules__c.getOrgDefaults();
        valRule.Bypass_Rules__c = false;
        insert valRule;

        Switch__c cohstest = new Switch__c();
        cohstest.Switch__c = false;
        cohstest.Name = 'CaseOwnerHistorySwitch';
        insert cohstest;

        testData = phss_cc_TestDataFactory.setupAccountAndProducts();
        testAccount = (Account) testData.get(phss_cc_TestDataFactory.TEST_ACCOUNT);
        testOpportunity = phss_cc_TestDataFactory.createInsertTestOpportunity(testAccount);
        List<ccrz__E_Cart__c> testCarts = phss_cc_TestDataFactory.createInsertCartAndCartItems(1, testData, testOpportunity.Id);
        testCart = testCarts[0];
        phss_cc_TestDataFactory.createInsertStoredPayment(1, testOpportunity);
    }

    @IsTest
    public static void testFetchStoredPayments() {

        setupTestData();

        Test.startTest();
        Map<String, Object> fetchStoredPaymentsResponse = phss_cc_StoredPaymentUtil.fetchStoredPayments(testOpportunity.Id);
        Test.stopTest();

        System.assertNotEquals(null, fetchStoredPaymentsResponse);
        System.assert(fetchStoredPaymentsResponse.containsKey(phss_cc_StoredPaymentUtil.STORED_PAYMENT_LIST_KEY));
        System.assert(fetchStoredPaymentsResponse.containsKey(phss_cc_StoredPaymentUtil.STORED_PAYMENT_MAP_KEY));
        Map<String, Object> storedPaymentMap = (Map<String, Object>) fetchStoredPaymentsResponse.get(phss_cc_StoredPaymentUtil.STORED_PAYMENT_MAP_KEY);
        System.assertNotEquals(0, storedPaymentMap.size());
    }

    @IsTest
    public static void testFetchOnAccountPayments() {

        setupTestData();
        List<ccrz__E_StoredPayment__c> createPOs = phss_cc_TestDataFactory.createInsertStoredPayment(1, testOpportunity);

        Test.startTest();
        List<ccrz__E_StoredPayment__c> result = phss_cc_StoredPaymentUtil.fetchOnAccountPayments(testOpportunity.Id);
        Test.stopTest();

        System.debug('' + System.JSON.serialize(result));
        System.assertNotEquals(null, result);
    }

}