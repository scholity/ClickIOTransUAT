/**
 * Created by jbarker on 2019-08-16.
 */

@IsTest
public with sharing class phss_cc_TransactionPaymentUtilTest {

    private static ccrz__E_TransactionPayment__c testTransactionPayment;
    private static ccrz__E_TransactionPayment__c testAuthTransactionPayment;
    private static ccrz__E_TransactionPayment__c testCaptureTransactionPayment;
    private static ccrz__E_StoredPayment__c testStoredPayment;

    public static void setupTestData() {
        testAuthTransactionPayment = new ccrz__E_TransactionPayment__c(
                ccrz__TransactionType__c = phss_cc_TransactionPaymentUtil.AUTH_TRANSACTION_TYPE
        );
        insert testAuthTransactionPayment;

        testCaptureTransactionPayment = new ccrz__E_TransactionPayment__c(
                ccrz__TransactionType__c = phss_cc_TransactionPaymentUtil.CAPTURE_TRANSACTION_TYPE
        );
        insert testCaptureTransactionPayment;

        testStoredPayment = new ccrz__E_StoredPayment__c();
        insert testStoredPayment;

        testTransactionPayment = new ccrz__E_TransactionPayment__c(
                ccrz__StoredPayment__c = testStoredPayment.Id
        );
        insert testTransactionPayment;
    }

    @IsTest
    public static void testIsAuthTransaction() {
        setupTestData();
        System.assertEquals(true, phss_cc_TransactionPaymentUtil.isAuthTransaction(testAuthTransactionPayment));
        System.assertEquals(false, phss_cc_TransactionPaymentUtil.isAuthTransaction(testCaptureTransactionPayment));
    }

    @IsTest
    public static void testIsCaptureTransaction() {
        setupTestData();
        System.assertEquals(true, phss_cc_TransactionPaymentUtil.isCaptureTransaction(testCaptureTransactionPayment));
        System.assertEquals(false, phss_cc_TransactionPaymentUtil.isCaptureTransaction(testAuthTransactionPayment));
    }

    @IsTest
    public static void testFetchTransactionPayment() {
        setupTestData();

        Test.startTest();
        ccrz__E_TransactionPayment__c authTxnPmt = phss_cc_TransactionPaymentUtil.fetchTransactionPayment(testAuthTransactionPayment.Id);
        ccrz__E_TransactionPayment__c captureTxnPmt = phss_cc_TransactionPaymentUtil.fetchTransactionPayment(testCaptureTransactionPayment.Id);
        Test.stopTest();

        System.assert(authTxnPmt != null);
        System.assertEquals(testAuthTransactionPayment.ccrz__TransactionType__c, authTxnPmt.ccrz__TransactionType__c);
        System.assert(captureTxnPmt != null);
        System.assertEquals(testCaptureTransactionPayment.ccrz__TransactionType__c, captureTxnPmt.ccrz__TransactionType__c);
    }

    @IsTest
    public static void testGetTransactionPaymentsForStoredPayment() {
        setupTestData();

        Test.startTest();
        List<ccrz__E_TransactionPayment__c> transactionPayments = phss_cc_TransactionPaymentUtil.getTransactionPaymentsForStoredPayment(testStoredPayment.Id);
        Test.stopTest();

        System.assert(transactionPayments != null);
        System.assert(transactionPayments.size() == 1);
        System.assertEquals(testTransactionPayment.Id, transactionPayments[0].Id);
    }

    @IsTest
    public static void testCreateCaptureTransactionPaymentFromAuthTransactionPayment() {
        ccrz__E_TransactionPayment__c testAuthTransactionPayment = new ccrz__E_TransactionPayment__c(
                ccrz__TransactionType__c = phss_cc_TransactionPaymentUtil.AUTH_TRANSACTION_TYPE
        );
        insert testAuthTransactionPayment;

        Test.startTest();
        ccrz__E_TransactionPayment__c transactionPayment = phss_cc_TransactionPaymentUtil.createCaptureTransactionPaymentFromAuthTransactionPayment(testAuthTransactionPayment.Id);
        Test.stopTest();

        System.assert(transactionPayment != null);
        System.assertEquals(testAuthTransactionPayment.Id, transactionPayment.ccrz__SourceTransactionPayment__c);
    }
}