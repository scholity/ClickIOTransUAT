/**
 * Created by jbarker on 2019-08-06.
 */

@IsTest
public with sharing class phss_cc_OnAccountBalanceControllerTest {

    public static Map<String, Object> testData;
    public static Opportunity testOpportunity;
    public static List<ccrz__E_StoredPayment__c> testStoredPayments;

    /**
     * @description Creates test data
     */
    public static void setupTestData() {
        testData = phss_cc_TestDataFactory.setupAccountAndProducts();
        testOpportunity = phss_cc_TestDataFactory.createInsertTestOpportunity((Account) testData.get(phss_cc_TestDataFactory.TEST_ACCOUNT));
        testStoredPayments = phss_cc_TestDataFactory.createInsertStoredPayment(1, testOpportunity, phss_cc_StoredPaymentUtil.STORED_PAYMENT_TYPE_CB);
    }

    @IsTest
    public static void testFetchStoredPayments() {
        setupTestData();

        Test.startTest();
        List<Object> results = phss_cc_OnAccountBalanceController.fetchStoredPayments(testOpportunity.Id);
        Test.stopTest();

        System.assertNotEquals(null, results);
    }
}