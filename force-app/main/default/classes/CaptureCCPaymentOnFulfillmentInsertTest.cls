/**
 * Created by jbarker on 2019-10-07.
 */

@IsTest
public with sharing class CaptureCCPaymentOnFulfillmentInsertTest {

    public static Case testCase;
    public static Contact testContact;
    public static Opportunity testOpportunity;
    public static Map<String, Object> testData;
    public static ccrz__E_Cart__c testCart;
    public static Account testAccount;
    public static List<ccrz__E_StoredPayment__c> testStoredPayments;
    public static ccrz__E_Order__c testOrder;
    public static ccrz__E_Order__c testCreditOrder;
    public static ccrz__E_Order__c testRefundOrder;
    public static ccrz__E_TransactionPayment__c testAuthTxnPmt;
    public static ccrz__E_TransactionPayment__c testCaptureTxnPmt;
    public static ccrz__E_TransactionPayment__c testCreditTxnPmt;
    public static ccrz__E_TransactionPayment__c testRefundTxnPmt;
    public static ccrz__E_StoredPayment__c testCreditBalanceStoredPayment;

    public static void setupTestData() {
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
        testStoredPayments = phss_cc_TestDataFactory.createInsertStoredPayment(1, testOpportunity, phss_cc_StoredPaymentUtil.STORED_PAYMENT_TYPE_PO);

        Map<String, Object> testOrderData = phss_cc_TestDataFactory.createInsertOrderWithCredit(testAccount);
        testOrder = (ccrz__E_Order__c) testOrderData.get(phss_cc_TestDataFactory.TEST_ORDER);
        testCreditOrder = (ccrz__E_Order__c) testOrderData.get(phss_cc_TestDataFactory.TEST_CREDIT_ORDER);
        testRefundOrder = (ccrz__E_Order__c) testOrderData.get(phss_cc_TestDataFactory.TEST_ORDER_WITH_APPLIED_CREDIT);
        testAuthTxnPmt = (ccrz__E_TransactionPayment__c) testOrderData.get(phss_cc_TestDataFactory.TEST_AUTH_TRANSACTION_PAYMENT);
        testCaptureTxnPmt = (ccrz__E_TransactionPayment__c) testOrderData.get(phss_cc_TestDataFactory.TEST_CAPTURE_TRANSACTION_PAYMENT);
        testCreditTxnPmt = (ccrz__E_TransactionPayment__c) testOrderData.get(phss_cc_TestDataFactory.TEST_CREDIT_BALANCE_TRANSACTION_PAYMENT);
        testRefundTxnPmt = (ccrz__E_TransactionPayment__c) testOrderData.get(phss_cc_TestDataFactory.TEST_REFUND_TRANSACTION_PAYMENT);
        testCreditBalanceStoredPayment = (ccrz__E_StoredPayment__c) testOrderData.get(phss_cc_TestDataFactory.TEST_STORED_PAYMENT);
    }

    @IsTest
    static void testFulfillmentInsertForPurchase() {

        setupTestData();

        testAuthTxnPmt.ccrz__Amount__c = 1;
        update testAuthTxnPmt;

        Fulfillment__c fulfillment = new Fulfillment__c(
                Order__c = testOrder.Id,
                CC_Transaction_Payment__c = testAuthTxnPmt.Id
        );

        Test.startTest();
        Database.SaveResult result = Database.insert(fulfillment);
        Test.stopTest();

        System.assert(result.isSuccess());
    }
}