/**
 * Created by jbarker on 2019-08-16.
 */

@IsTest
public with sharing class phss_cc_TransactionPaymentUtilTest {

    private static Account testAccount;
    private static ccrz__E_Order__c testOrder;
    private static ccrz__E_Order__c testCreditOrder;
    private static ccrz__E_Order__c testAppliedCreditOrder;
    private static ccrz__E_TransactionPayment__c testTransactionPayment;
    private static ccrz__E_TransactionPayment__c testAuthTransactionPayment;
    private static ccrz__E_TransactionPayment__c testCaptureTransactionPayment;
    private static ccrz__E_StoredPayment__c testStoredPayment;

    public static void setupTestData() {
        ccrz__E_AccountGroup__c testAccountGroup = phss_cc_TestDataFactory.createInsertTestAccountGroup();
        testAccount = phss_cc_TestDataFactory.createInsertTestAccount(testAccountGroup);

        Map<String, Object> testData = phss_cc_TestDataFactory.createInsertOrderWithCredit(testAccount);
        testOrder = (ccrz__E_Order__c) testData.get(phss_cc_TestDataFactory.TEST_ORDER);
        testCreditOrder = (ccrz__E_Order__c) testData.get(phss_cc_TestDataFactory.TEST_CREDIT_ORDER);
        testAppliedCreditOrder = (ccrz__E_Order__c) testData.get(phss_cc_TestDataFactory.TEST_ORDER_WITH_APPLIED_CREDIT);
        testAuthTransactionPayment = (ccrz__E_TransactionPayment__c) testData.get(phss_cc_TestDataFactory.TEST_AUTH_TRANSACTION_PAYMENT);
        testCaptureTransactionPayment = (ccrz__E_TransactionPayment__c) testData.get(phss_cc_TestDataFactory.TEST_CAPTURE_TRANSACTION_PAYMENT);
        testStoredPayment = (ccrz__E_StoredPayment__c) testData.get(phss_cc_TestDataFactory.TEST_STORED_PAYMENT);

        testTransactionPayment = new ccrz__E_TransactionPayment__c(
                ccrz__StoredPayment__c = testStoredPayment.Id
        );
        insert testTransactionPayment;

        /*

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

         */
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
        System.assert(transactionPayments.size() > 0);
    }

    @IsTest
    public static void testCreateCaptureTransactionPaymentFromAuthTransactionPayment() {
        setupTestData();

        Test.startTest();
        ccrz__E_TransactionPayment__c transactionPayment = phss_cc_TransactionPaymentUtil.createCaptureTransactionPaymentFromAuthTransactionPayment(testAuthTransactionPayment.Id);
        Test.stopTest();

        System.assert(transactionPayment != null);
        System.assertEquals(testAuthTransactionPayment.Id, transactionPayment.ccrz__SourceTransactionPayment__c);
    }

    @IsTest
    public static void testDesignateContactForTransactionPayment() {
        setupTestData();

        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Bucket Account').getRecordTypeId();
        
        Bucket_Account_Settings__c bas = Bucket_Account_Settings__c.getOrgDefaults();
        bas.Bucket_Account_Owner_ID__c = UserInfo.getUserID();
        bas.Bucket_Account_RecordTypeID__c = recordTypeId;
        bas.Default_Bucket_Name__c = 'Bucket Account';
        bas.Maximum_Size_of_Bucket__c = 5000;
        insert bas;

        Contact contact = new Contact(
                AccountId = testAccount.Id,
                FirstName = 'John',
                LastName = 'Doe'
        );
        insert contact;

//        AccountContactRelation relation = new AccountContactRelation(
//                AccountId = account.Id,
//                ContactId = contact.Id,
//                IsDirect = true
//        );
//        insert relation;

        List<RecordType> recordTypes = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account'];
        if (recordTypes != null) {
            System.debug('JASON: Number of record types: ' + recordTypes.size());
            for (RecordType rt : recordTypes) {
                System.debug('JASON: recordType: ' + rt.Name + ' (Id=' + rt.Id + ')');
            }
        } else {
            System.debug('JASON: NO RECORD TYPES FOUND');
        }
        Test.startTest();
        System.debug('JASON: testAuthTransactionPayment: ' + testAuthTransactionPayment);
        phss_cc_TransactionPaymentUtil.designateContactForTransactionPayment(testAuthTransactionPayment);
        Test.stopTest();

        //System.assert(recordTypes != null);
    }
}