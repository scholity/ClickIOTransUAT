/**
 * Created by dgajwani on 10/2/18.
 */
@IsTest
public with sharing class phss_cc_OrderUtilTest {

    private static final String cyberSourceResponseDecline = '{"utf8":"✓","transaction_id":"5374710283216712204006","signed_field_names":"transaction_id,decision,req_access_key,req_profile_id,req_transaction_uuid,req_transaction_type,req_reference_number,req_amount,req_currency,req_locale,req_payment_method,req_ignore_avs,req_override_custom_receipt_page,req_bill_to_forename,req_bill_to_surname,req_bill_to_email,req_bill_to_address_line1,req_bill_to_address_city,req_bill_to_address_state,req_bill_to_address_country,req_bill_to_address_postal_code,req_card_number,req_card_type,req_card_expiry_date,req_merchant_defined_data1,message,reason_code,auth_avs_code,auth_avs_code_raw,auth_response,request_token,signed_field_names,signed_date_time","signed_date_time":"2018-09-20T19:17:08Z","signature":"KdlTzWH+zm8S7Jl4Ej+7Xp/1aMwUd8eJPQCu5Ls1+NM=","request_token":"Ahj77wSTI10WviZrRX7mEUt9XwnFEBS31fCcUdIJe5WQI6ZekmXoxXbmQgJyZGui18TNaK/cwAAA8gpT","req_transaction_uuid":"1537471022972","req_transaction_type":"authorization,create_payment_token","req_reference_number":"1537471022972","req_profile_id":"A462C345-9818-4803-84E6-37794D8B3F81","req_payment_method":"card","req_override_custom_receipt_page":"https://arc-phss--TransDev1--c.cs52.visual.force.com/apex/cc_lx_cybersourceccprocessorpostback","req_merchant_defined_data1":"a4O5B0000004ObiUAE","req_locale":"en-us","req_ignore_avs":"true","req_currency":"USD","req_card_type":"001","req_card_number":"xxxxxxxxxxxx1111","req_card_expiry_date":"12-2019","req_bill_to_surname":"Inc","req_bill_to_forename":"Hilton","req_bill_to_email":"NA@NA.com","req_bill_to_address_state":"MA","req_bill_to_address_postal_code":"02154","req_bill_to_address_line1":"1 Main St","req_bill_to_address_country":"US","req_bill_to_address_city":"Boston","req_amount":"2531.00","req_access_key":"2f9eac4dfdfc3bb5917f9dd1c68f381b","reason_code":"211","message":"We encountered a Paymentech problem: Reason: CVV2/VAK Failure.","decision":"DECLINE","auth_response":"531","auth_avs_code_raw":"I1","auth_avs_code":"X"}';
    private static final String cyberSourceResponseAccept = '{ "utf8": "✓", "transaction_id": "5372068707346357204006", "signed_field_names": "transaction_id,decision,req_access_key,req_profile_id,req_transaction_uuid,req_transaction_type,req_reference_number,req_amount,req_currency,req_locale,req_payment_method,req_ignore_avs,req_override_custom_receipt_page,req_bill_to_forename,req_bill_to_surname,req_bill_to_email,req_bill_to_address_line1,req_bill_to_address_city,req_bill_to_address_state,req_bill_to_address_country,req_bill_to_address_postal_code,req_card_number,req_card_type,req_card_expiry_date,req_merchant_defined_data1,message,reason_code,auth_avs_code,auth_avs_code_raw,auth_response,auth_amount,auth_code,auth_trans_ref_no,auth_time,request_token,payment_token_instrument_identifier_id,payment_token_instrument_identifier_new,payment_token_instrument_identifier_status,payment_token,signed_field_names,signed_date_time", "signed_date_time": "2018-09-17T17:54:30Z", "signature": "5aPWOgD98fmUVmyEKKxeSPNx4yDyWu0rKSbfI1P3y48=", "request_token": "Ahj/7wSTIzht+uRDhLQmESDdm1cNW7hrKmtoMeS3qpcnbxRioClydvFGK6QHyQIkMmkmXoxXbmQwJyZGcNv1yIcJaEwAxhqG", "req_transaction_uuid": "1537206859128", "req_transaction_type": "authorization,create_payment_token", "req_reference_number": "1537206859129", "req_profile_id": "A462C345-9818-4803-84E6-37794D8B3F81", "req_payment_method": "card", "req_override_custom_receipt_page": "https://arc-phss--transdev1--ccrz.cs52.visual.force.com/apex/ccrz__ccBridge?pagekey=CybersourcePostback", "req_merchant_defined_data1": "0065B00000AY0JzQAL", "req_locale": "en-us", "req_ignore_avs": "true", "req_currency": "USD", "req_card_type": "001", "req_card_number": "xxxxxxxxxxxx1111", "req_card_expiry_date": "12-2019", "req_bill_to_surname": "Test", "req_bill_to_forename": "Test", "req_bill_to_email": "Test@test.com", "req_bill_to_address_state": "IL", "req_bill_to_address_postal_code": "12345", "req_bill_to_address_line1": "3450 N Lake Shore Dr", "req_bill_to_address_country": "US", "req_bill_to_address_city": "Chicago", "req_amount": "1.00", "req_access_key": "2f9eac4dfdfc3bb5917f9dd1c68f381b", "reason_code": "100", "payment_token_instrument_identifier_status": "ACTIVE", "payment_token_instrument_identifier_new": "N", "payment_token_instrument_identifier_id": "7010000000025311111", "payment_token": "7615BB8E161D11BEE05341588E0AF0F1", "pagekey": "CybersourcePostback", "message": "Request was processed successfully.", "decision": "ACCEPT", "auth_trans_ref_no": "73585785JM6AGI7U", "auth_time": "2018-09-17T175430Z", "auth_response": "100", "auth_code": "888888", "auth_avs_code_raw": "I1", "auth_avs_code": "X", "auth_amount": "1.00" }';

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


    /**
     * @description Creates the basic testdata.
     */
    public static void setupTestData() {
        setupTestData(phss_cc_StoredPaymentUtil.STORED_PAYMENT_TYPE_PO);
    }

    public static void setupTestData(String accountType) {

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
        testStoredPayments = phss_cc_TestDataFactory.createInsertStoredPayment(1, testOpportunity, accountType);
    }

    public static void setupTestDataForOrders() {
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
    public static void testPlaceOrderOnCartCCAccept() {

        setupTestData();

        Test.startTest();

        Map<String, Object> placeOrderResultAccept = phss_cc_OrderUtil.placeOrderOnCartCC(testOpportunity.Id, testCart.ccrz__EncryptedId__c, cyberSourceResponseAccept, null);

        Test.stopTest();

        System.assertNotEquals(null, placeOrderResultAccept);
        System.assert(placeOrderResultAccept.containsKey(phss_cc_OrderUtil.ORDER_ID));
        System.assertNotEquals(null, placeOrderResultAccept.get(phss_cc_OrderUtil.ORDER_ID));
        System.assert(placeOrderResultAccept.containsKey(phss_cc_OrderUtil.RETURN_MESSAGE));
        System.assertNotEquals(null, placeOrderResultAccept.get(phss_cc_OrderUtil.RETURN_MESSAGE));
    }

    @IsTest
    public static void testPlaceOrderOnCartCCDecline() {

        setupTestData();

        Test.startTest();

        Map<String, Object> placeOrderResultDecline = phss_cc_OrderUtil.placeOrderOnCartCC(testOpportunity.Id, testCart.ccrz__EncryptedId__c, cyberSourceResponseDecline, null);

        Test.stopTest();

        System.assertNotEquals(null, placeOrderResultDecline);
        System.assert(placeOrderResultDecline.containsKey(phss_cc_OrderUtil.SUCCESS_KEY));
        System.assertNotEquals(null, placeOrderResultDecline.get(phss_cc_OrderUtil.SUCCESS_KEY));
        System.assert(placeOrderResultDecline.containsKey(phss_cc_OrderUtil.RETURN_MESSAGE));
        System.assertNotEquals(null, placeOrderResultDecline.get(phss_cc_OrderUtil.RETURN_MESSAGE));
    }

    @IsTest
    public static void testPlaceOrderOnCartPOExisting() {
        setupTestData();
        List<ccrz__E_StoredPayment__c> createPOs = phss_cc_TestDataFactory.createInsertStoredPayment(1, testOpportunity);
        ccrz__E_StoredPayment__c myPO = createPOs[0];

        Map<String, Object> existingPO = new Map<String, Object>{
                phss_cc_OrderUtil.NEW_PO_SFID_KEY => myPO.Id,
                phss_cc_OrderUtil.UPDATE_PO_KEY => false,
                phss_cc_OrderUtil.UPDATED_PO_AMOUNT_KEY => '0'
        };

        Test.startTest();

        Map<String, Object> placeOrderResultExistingPO = phss_cc_OrderUtil.placeOrderOnCartPO(testOpportunity.Id, testCart.ccrz__EncryptedId__c, existingPO);
        Test.stopTest();

        System.assertNotEquals(null, placeOrderResultExistingPO);
        System.assert(placeOrderResultExistingPO.containsKey(phss_cc_OrderUtil.ORDER_ID));
        System.assertNotEquals(null, placeOrderResultExistingPO.get(phss_cc_OrderUtil.ORDER_ID));
        System.assert(placeOrderResultExistingPO.containsKey(phss_cc_OrderUtil.RETURN_MESSAGE));
        System.assertNotEquals(null, placeOrderResultExistingPO.get(phss_cc_OrderUtil.RETURN_MESSAGE));
    }

    @IsTest
    public static void testPlaceOrderOnCartPONoPO() {
        setupTestData();

        Test.startTest();
        Map<String, Object> placeOrderResultExistingPO = phss_cc_OrderUtil.placeOrderOnCartPO(testOpportunity.Id, testCart.ccrz__EncryptedId__c, null);
        Test.stopTest();

        System.assertNotEquals(null, placeOrderResultExistingPO);
        System.assert(placeOrderResultExistingPO.containsKey(phss_cc_OrderUtil.ORDER_ID));
        System.assertNotEquals(null, placeOrderResultExistingPO.get(phss_cc_OrderUtil.ORDER_ID));
        System.assert(placeOrderResultExistingPO.containsKey(phss_cc_OrderUtil.RETURN_MESSAGE));
        System.assertNotEquals(null, placeOrderResultExistingPO.get(phss_cc_OrderUtil.RETURN_MESSAGE));
    }

    @IsTest
    public static void testPlaceOrderOnCartPONew() {
        setupTestData();

        Map<String, Object> newPO = new Map<String, Object>{
                phss_cc_OrderUtil.NEW_PO_NAME_KEY => 'Test PO',
                phss_cc_OrderUtil.NEW_PO_AMOUNT_KEY => '1000',
                phss_cc_OrderUtil.NEW_PO_DOSAVE_KEY => true,
                phss_cc_OrderUtil.NEW_PO_START_DATE_KEY => '2019_06_28',
                phss_cc_OrderUtil.NEW_PO_END_DATE_KEY => '2019_06_29'

        };

        Test.startTest();
        Map<String, Object> placeOrderResultNewPO = phss_cc_OrderUtil.placeOrderOnCartPO(testOpportunity.Id, testCart.ccrz__EncryptedId__c, newPO);
        Test.stopTest();

        System.assertNotEquals(null, placeOrderResultNewPO);
        System.assert(placeOrderResultNewPO.containsKey(phss_cc_OrderUtil.ORDER_ID));
        System.assertNotEquals(null, placeOrderResultNewPO.get(phss_cc_OrderUtil.ORDER_ID));
        System.assert(placeOrderResultNewPO.containsKey(phss_cc_OrderUtil.RETURN_MESSAGE));
        System.assertNotEquals(null, placeOrderResultNewPO.get(phss_cc_OrderUtil.RETURN_MESSAGE));

        List<ccrz__E_StoredPayment__c> countOfStoredPayments = [
                SELECT Id
                FROM ccrz__E_StoredPayment__c
        ];
        System.assertEquals(2,countOfStoredPayments.size());
    }

    @IsTest
    public static void testPlaceOrderOnCartPOUpdatePO() {
        setupTestData();
        List<ccrz__E_StoredPayment__c> createPOs = phss_cc_TestDataFactory.createInsertStoredPayment(1, testOpportunity);
        ccrz__E_StoredPayment__c myPO = createPOs[0];

        Map<String, Object> newPO = new Map<String, Object>{
                phss_cc_OrderUtil.NEW_PO_SFID_KEY => myPO.Id,
                phss_cc_OrderUtil.UPDATE_PO_KEY => true,
                phss_cc_OrderUtil.UPDATED_PO_AMOUNT_KEY => '900'
        };

        Test.startTest();
        Map<String, Object> result = phss_cc_OrderUtil.placeOrderOnCartPO(testOpportunity.Id, testCart.ccrz__EncryptedId__c, newPO);
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assert(result.containsKey(phss_cc_OrderUtil.ORDER_ID));
        System.assertNotEquals(null, result.get(phss_cc_OrderUtil.ORDER_ID));
        System.assert(result.containsKey(phss_cc_OrderUtil.RETURN_MESSAGE));
        System.assertNotEquals(null, result.get(phss_cc_OrderUtil.RETURN_MESSAGE));

    }

    @IsTest
    public static void testPlaceOrderOnCartCB() {
        setupTestData(phss_cc_StoredPaymentUtil.STORED_PAYMENT_TYPE_CB);
        setupTestDataForOrders();

        List<String> storedPaymentIDs = new List<String>{ testCreditBalanceStoredPayment.Id };

        Test.startTest();
        Map<String, Object> result = phss_cc_OrderUtil.placeOrderOnCartCB(testOpportunity.Id, testCart.ccrz__EncryptedId__c, storedPaymentIDs);
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assert(result.containsKey(phss_cc_OrderUtil.ORDER_ID));
        System.assertNotEquals(null, result.get(phss_cc_OrderUtil.ORDER_ID));
        System.assert(result.containsKey(phss_cc_OrderUtil.RETURN_MESSAGE));
        System.assertNotEquals(null, result.get(phss_cc_OrderUtil.RETURN_MESSAGE));
    }

    @IsTest
    public static void testPlaceOrderOnCartCBWithMultipleStoredPayments() {
        setupTestData(phss_cc_StoredPaymentUtil.STORED_PAYMENT_TYPE_CB);
        setupTestDataForOrders();

        List<String> storedPaymentIDs = new List<String>();
        for (ccrz__E_StoredPayment__c storedPayment : testStoredPayments) {
            storedPaymentIDs.add(storedPayment.Id);
        }

        Test.startTest();
        Map<String, Object> result = phss_cc_OrderUtil.placeOrderOnCartCB(testOpportunity.Id, testCart.ccrz__EncryptedId__c, storedPaymentIDs);
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assert(result.containsKey(phss_cc_OrderUtil.ORDER_ID));
        System.assertNotEquals(null, result.get(phss_cc_OrderUtil.ORDER_ID));
        System.assert(result.containsKey(phss_cc_OrderUtil.RETURN_MESSAGE));
        System.assertNotEquals(null, result.get(phss_cc_OrderUtil.RETURN_MESSAGE));
    }

    @IsTest
    public static void testPlaceOrderOnCartCBNoStoredPayments() {
        setupTestData(phss_cc_StoredPaymentUtil.STORED_PAYMENT_TYPE_CB);

        List<String> storedPaymentIdList = new List<String>();
        for (ccrz__E_StoredPayment__c storedPayment : testStoredPayments) {
            storedPaymentIdList.add(storedPayment.Id);
        }

        Test.startTest();
        Map<String, Object> result = phss_cc_OrderUtil.placeOrderOnCartCB(testOpportunity.Id, testCart.ccrz__EncryptedId__c, storedPaymentIdList);
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assert(result.containsKey(phss_cc_OrderUtil.ORDER_ID));
        System.assertNotEquals(null, result.get(phss_cc_OrderUtil.ORDER_ID));
        System.assert(result.containsKey(phss_cc_OrderUtil.RETURN_MESSAGE));
        System.assertNotEquals(null, result.get(phss_cc_OrderUtil.RETURN_MESSAGE));
    }

    @IsTest
    public static void testCreateDataForNoPurchaseOrder() {

        setupTestData();

        Test.startTest();

        Map<String, Object> result = phss_cc_OrderUtil.createDataForNoPurchaseOrder(testCart.ccrz__EncryptedId__c);
        Test.stopTest();

        System.debug('' + System.JSON.serialize(result));
        System.assertNotEquals(null, result);
        System.assert(result.containsKey(phss_cc_OrderUtil.CART_AMOUNT_KEY));
        System.assertNotEquals(null, result.get(phss_cc_OrderUtil.CART_AMOUNT_KEY));
        System.assertEquals(false, result.get(phss_cc_OrderUtil.STORED_PAYMENT_SAVE_AS_STORED_PAYMENT));
    }

    @IsTest
    public static void testFindPaymentDeclineReason() {

        setupTestData();
        Map<String, Object> params = new Map<String, Object>{
                phss_cc_OrderUtil.CYBER_SOURCE_AUTH_RESPONSE_CODE_KEY => phss_cc_OrderUtil.CYBER_SOURCE_ERROR_INSUFFICIENT_FUNDS
        };

        Test.startTest();

        Map<String, Object> result = phss_cc_OrderUtil.findPaymentDeclineReason(params);
        params.put(phss_cc_OrderUtil.CYBER_SOURCE_AUTH_RESPONSE_CODE_KEY, phss_cc_OrderUtil.CYBER_SOURCE_ERROR_INVALID_ADDRESS);
        result = phss_cc_OrderUtil.findPaymentDeclineReason(params);
        params.put(phss_cc_OrderUtil.CYBER_SOURCE_AUTH_RESPONSE_CODE_KEY, phss_cc_OrderUtil.CYBER_SOURCE_ERROR_INVALID_EXPIRATION_DATE);
        result = phss_cc_OrderUtil.findPaymentDeclineReason(params);
        params.put(phss_cc_OrderUtil.CYBER_SOURCE_AUTH_RESPONSE_CODE_KEY, '');

        Test.stopTest();

        System.debug('' + System.JSON.serialize(result));
        System.assertNotEquals(null, result);
        System.assert(result.containsKey(phss_cc_OrderUtil.RETURN_MESSAGE));
        System.assertNotEquals(null, result.get(phss_cc_OrderUtil.RETURN_MESSAGE));
    }

    @IsTest
    public static void testCreateNoPOTransactionPaymentForOrder() {
        setupTestData();
        String orderId = '123456';

        //TODO: May need to create the order with phss_cc_OrderUtil.placeOrderOnCartPO
        ccrz__E_Order__c testOrder = new ccrz__E_Order__c(
                NSSCCConnector_SFCC_Order_Number__c = orderId,
                NSSCCConnector_from_SFCC__c = true,
                ccrz__Account__c = testAccount.Id,
                ccrz__Storefront__c = 'CREStore',
                Opportunity_Order__c = testOpportunity.Id,
                ccrz__CurrencyISOCode__c = 'USD'
        );
        insert testOrder;

        Test.startTest();
        phss_cc_OrderUtil.createNoPOTransactionPaymentForOrder(null);
        phss_cc_OrderUtil.createNoPOTransactionPaymentForOrder(testOrder.Id);
        Test.stopTest();

    }

    @IsTest
    public static void testAssignCaseContactToOrder() {
        testData = phss_cc_TestDataFactory.setupAccountAndProducts();
        testContact = (Contact) testData.get(phss_cc_TestDataFactory.TEST_BILLING_CONTACT);
        testAccount = (Account) testData.get(phss_cc_TestDataFactory.TEST_ACCOUNT);

        testCase = phss_cc_TestDataFactory.createInsertTestCase(testAccount, testContact, testContact);
        testOpportunity = phss_cc_TestDataFactory.createInsertTestOpportunity(testAccount);
        testOpportunity.Case__c = testCase.Id;
        update testOpportunity;

        testOrder = new ccrz__E_Order__c(
                ccrz__Account__c = testAccount.Id,
                NSSCCConnector_SFCC_Order_Number__c = '3114226',
                NSSCCConnector_from_SFCC__c = true,
                Opportunity_Order__c = testOpportunity.Id
        );
        insert testOrder;


        System.debug('JASON: testOrder has been inserted.');

        Test.startTest();
        phss_cc_OrderUtil.assignCaseContactToOrder(testOrder.Id);
        Test.stopTest();

        ccrz__E_Order__c order = [
                SELECT  Opportunity_Order__r.Case__r.ContactId,
                        ccrz__Contact__c
                FROM    ccrz__E_Order__c
                WHERE   Id = :testOrder.Id
        ];

        System.assertEquals(testContact.Id, order.ccrz__Contact__c);
    }

    @IsTest
    public static void testGetOriginalOrderForStoredPayment() {
        setupTestData(phss_cc_StoredPaymentUtil.STORED_PAYMENT_TYPE_CB);
        setupTestDataForOrders();

        Test.startTest();
        String orderId = phss_cc_OrderUtil.getOriginalOrderForStoredPayment(testCreditBalanceStoredPayment.Id);
        Test.stopTest();

        String expectedOrderId = '' + testOrder.Id;
        System.assertEquals(expectedOrderId, orderId);
    }
}