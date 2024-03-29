/**
 * Created by dgajwani on 10/3/18.
 */
@isTest
public with sharing class phss_cc_CartControllerTest {

    private static final String cyberSourceResponseAccept = '{ "utf8": "✓", "transaction_id": "5372068707346357204006", "signed_field_names": "transaction_id,decision,req_access_key,req_profile_id,req_transaction_uuid,req_transaction_type,req_reference_number,req_amount,req_currency,req_locale,req_payment_method,req_ignore_avs,req_override_custom_receipt_page,req_bill_to_forename,req_bill_to_surname,req_bill_to_email,req_bill_to_address_line1,req_bill_to_address_city,req_bill_to_address_state,req_bill_to_address_country,req_bill_to_address_postal_code,req_card_number,req_card_type,req_card_expiry_date,req_merchant_defined_data1,message,reason_code,auth_avs_code,auth_avs_code_raw,auth_response,auth_amount,auth_code,auth_trans_ref_no,auth_time,request_token,payment_token_instrument_identifier_id,payment_token_instrument_identifier_new,payment_token_instrument_identifier_status,payment_token,signed_field_names,signed_date_time", "signed_date_time": "2018-09-17T17:54:30Z", "signature": "5aPWOgD98fmUVmyEKKxeSPNx4yDyWu0rKSbfI1P3y48=", "request_token": "Ahj/7wSTIzht+uRDhLQmESDdm1cNW7hrKmtoMeS3qpcnbxRioClydvFGK6QHyQIkMmkmXoxXbmQwJyZGcNv1yIcJaEwAxhqG", "req_transaction_uuid": "1537206859128", "req_transaction_type": "authorization,create_payment_token", "req_reference_number": "1537206859129", "req_profile_id": "A462C345-9818-4803-84E6-37794D8B3F81", "req_payment_method": "card", "req_override_custom_receipt_page": "https://arc-phss--transdev1--ccrz.cs52.visual.force.com/apex/ccrz__ccBridge?pagekey=CybersourcePostback", "req_merchant_defined_data1": "0065B00000AY0JzQAL", "req_locale": "en-us", "req_ignore_avs": "true", "req_currency": "USD", "req_card_type": "001", "req_card_number": "xxxxxxxxxxxx1111", "req_card_expiry_date": "12-2019", "req_bill_to_surname": "Test", "req_bill_to_forename": "Test", "req_bill_to_email": "Test@test.com", "req_bill_to_address_state": "IL", "req_bill_to_address_postal_code": "12345", "req_bill_to_address_line1": "3450 N Lake Shore Dr", "req_bill_to_address_country": "US", "req_bill_to_address_city": "Chicago", "req_amount": "1.00", "req_access_key": "2f9eac4dfdfc3bb5917f9dd1c68f381b", "reason_code": "100", "payment_token_instrument_identifier_status": "ACTIVE", "payment_token_instrument_identifier_new": "N", "payment_token_instrument_identifier_id": "7010000000025311111", "payment_token": "7615BB8E161D11BEE05341588E0AF0F1", "pagekey": "CybersourcePostback", "message": "Request was processed successfully.", "decision": "ACCEPT", "auth_trans_ref_no": "73585785JM6AGI7U", "auth_time": "2018-09-17T175430Z", "auth_response": "100", "auth_code": "888888", "auth_avs_code_raw": "I1", "auth_avs_code": "X", "auth_amount": "1.00" }';

    public static Opportunity testOpportunity;
    public static Map<String, Object> testData;
    public static List<ccrz__E_Product__c> products;
    public static ccrz__E_Cart__c testCart;
    public static Map<String, Object> productQuantityMap;

    /**
     * @description Creates the basic testdata.
     */
    public static void setupTestData() {
        testData = phss_cc_TestDataFactory.setupAccountAndProducts();
        products = (List<ccrz__E_Product__c>) testData.get(phss_cc_TestDataFactory.TEST_PRODUCTS);
        testOpportunity = phss_cc_TestDataFactory.createInsertTestOpportunity((Account) testData.get(phss_cc_TestDataFactory.TEST_ACCOUNT));
        List<ccrz__E_Cart__c> testCarts = phss_cc_TestDataFactory.createInsertCartAndCartItems(1, testData, testOpportunity.Id);

        //Create productQuantityMap
        productQuantityMap = new Map<String, Object>();
        for (ccrz__E_Product__c product : products) {
            String productSfid = String.valueOf(product.Id);
            productQuantityMap.put(productSfid, 2);
        }

        testCart = testCarts[0];
        phss_cc_TestDataFactory.createInsertStoredPayment(1, testOpportunity);
    }

    @isTest
    public static void testFetchActiveCart() {
        setupTestData();

        Test.startTest();
        Map<String, Object> fetchCartResponse = phss_cc_CartController.fetchActiveCart(null);
        fetchCartResponse = phss_cc_CartController.fetchActiveCart(testOpportunity.Id);
        Test.stopTest();

        System.assertNotEquals(null, fetchCartResponse);
    }

    @isTest
    public static void updateCartProducts() {
        setupTestData();

        Test.startTest();
        Map<String, Object> updateCartProductsResult = phss_cc_CartController.updateCartProducts(null, null);
        updateCartProductsResult = phss_cc_CartController.updateCartProducts(testOpportunity.Id, productQuantityMap);
        Test.stopTest();

        System.assertNotEquals(null, updateCartProductsResult);
    }

    @isTest
    public static void placeOrderOnCartCC() {
        setupTestData();

        Test.startTest();
        Map<String, Object> placeOrderResult = phss_cc_CartController.placeOrderOnCartCC(null, null, null);
        placeOrderResult = phss_cc_CartController.placeOrderOnCartCC(testOpportunity.Id, testCart.ccrz__EncryptedId__c, cyberSourceResponseAccept);
        Test.stopTest();

        System.assertNotEquals(null, placeOrderResult);
    }

    @isTest
    public static void placeOrderOnCartPO() {
        setupTestData();

        Map<String, Object> newPO = new Map<String, Object>{
                phss_cc_OrderUtil.NEW_PO_NAME_KEY => 'Test PO',
                phss_cc_OrderUtil.NEW_PO_AMOUNT_KEY => '1000',
                phss_cc_OrderUtil.NEW_PO_DOSAVE_KEY => true
        };


        Test.startTest();
        Map<String, Object> placeOrderResult = phss_cc_CartController.placeOrderOnCartPO(null, null, null);
        placeOrderResult = phss_cc_CartController.placeOrderOnCartPO(testOpportunity.Id, testCart.ccrz__EncryptedId__c, newPO);
        Test.stopTest();

        System.assertNotEquals(null, placeOrderResult);
    }

    @isTest
    public static void placeOrderOnCartNoPO() {
        setupTestData();

        Test.startTest();
        Map<String, Object> placeOrderResult = phss_cc_CartController.placeOrderOnCartPO(null, null, null);
        placeOrderResult = phss_cc_CartController.placeOrderOnCartPO(testOpportunity.Id, testCart.ccrz__EncryptedId__c, null);
        Test.stopTest();

        System.assertNotEquals(null, placeOrderResult);
    }
}