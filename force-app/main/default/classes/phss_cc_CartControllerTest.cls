/**
 * Created by dgajwani on 10/3/18.
 */
@isTest
public with sharing class phss_cc_CartControllerTest {

    private static final String cyberSourceResponseAccept = '{ "utf8": "✓", "transaction_id": "5372068707346357204006", "signed_field_names": "transaction_id,decision,req_access_key,req_profile_id,req_transaction_uuid,req_transaction_type,req_reference_number,req_amount,req_currency,req_locale,req_payment_method,req_ignore_avs,req_override_custom_receipt_page,req_bill_to_forename,req_bill_to_surname,req_bill_to_email,req_bill_to_address_line1,req_bill_to_address_city,req_bill_to_address_state,req_bill_to_address_country,req_bill_to_address_postal_code,req_card_number,req_card_type,req_card_expiry_date,req_merchant_defined_data1,message,reason_code,auth_avs_code,auth_avs_code_raw,auth_response,auth_amount,auth_code,auth_trans_ref_no,auth_time,request_token,payment_token_instrument_identifier_id,payment_token_instrument_identifier_new,payment_token_instrument_identifier_status,payment_token,signed_field_names,signed_date_time", "signed_date_time": "2018-09-17T17:54:30Z", "signature": "5aPWOgD98fmUVmyEKKxeSPNx4yDyWu0rKSbfI1P3y48=", "request_token": "Ahj/7wSTIzht+uRDhLQmESDdm1cNW7hrKmtoMeS3qpcnbxRioClydvFGK6QHyQIkMmkmXoxXbmQwJyZGcNv1yIcJaEwAxhqG", "req_transaction_uuid": "1537206859128", "req_transaction_type": "authorization,create_payment_token", "req_reference_number": "1537206859129", "req_profile_id": "A462C345-9818-4803-84E6-37794D8B3F81", "req_payment_method": "card", "req_override_custom_receipt_page": "https://arc-phss--transdev1--ccrz.cs52.visual.force.com/apex/ccrz__ccBridge?pagekey=CybersourcePostback", "req_merchant_defined_data1": "0065B00000AY0JzQAL", "req_locale": "en-us", "req_ignore_avs": "true", "req_currency": "USD", "req_card_type": "001", "req_card_number": "xxxxxxxxxxxx1111", "req_card_expiry_date": "12-2019", "req_bill_to_surname": "Test", "req_bill_to_forename": "Test", "req_bill_to_email": "Test@test.com", "req_bill_to_address_state": "IL", "req_bill_to_address_postal_code": "12345", "req_bill_to_address_line1": "3450 N Lake Shore Dr", "req_bill_to_address_country": "US", "req_bill_to_address_city": "Chicago", "req_amount": "1.00", "req_access_key": "2f9eac4dfdfc3bb5917f9dd1c68f381b", "reason_code": "100", "payment_token_instrument_identifier_status": "ACTIVE", "payment_token_instrument_identifier_new": "N", "payment_token_instrument_identifier_id": "7010000000025311111", "payment_token": "7615BB8E161D11BEE05341588E0AF0F1", "pagekey": "CybersourcePostback", "message": "Request was processed successfully.", "decision": "ACCEPT", "auth_trans_ref_no": "73585785JM6AGI7U", "auth_time": "2018-09-17T175430Z", "auth_response": "100", "auth_code": "888888", "auth_avs_code_raw": "I1", "auth_avs_code": "X", "auth_amount": "1.00" }';

    public static Opportunity testOpportunity;
    public static Map<String, Object> testData;
    public static List<ccrz__E_Product__c> testProducts;
    public static ccrz__E_Cart__c testCart;
    public static List<ccrz__E_StoredPayment__c> testStoredPayments;
    public static Map<String, Object> productQuantityMap;

    public static Account testAccount;
    public static Geo_Location__c testLocation;
    public static redwing__ILT_Class__c testIltClass;
    public static ccrz__E_Product__c testProduct;
    public static ccrz__E_CartItem__c testCartItem;

    /**
     * @description Creates the basic testdata.
     */
    public static void setupTestData() {
        testData = phss_cc_TestDataFactory.setupAccountAndProducts(1);
        testAccount = (Account) testData.get(phss_cc_TestDataFactory.TEST_ACCOUNT);
        testProducts = (List<ccrz__E_Product__c>) testData.get(phss_cc_TestDataFactory.TEST_PRODUCTS);
        testProduct = testProducts[0];
        testOpportunity = phss_cc_TestDataFactory.createInsertTestOpportunity((Account) testData.get(phss_cc_TestDataFactory.TEST_ACCOUNT));
        List<ccrz__E_Cart__c> testCarts = phss_cc_TestDataFactory.createInsertCartAndCartItems(1, testData, testOpportunity.Id);

        productQuantityMap = new Map<String, Object>();
        for (ccrz__E_Product__c product : testProducts) {
            String productSfid = String.valueOf(product.Id);
            productQuantityMap.put(productSfid, 1);
        }

        testCart = testCarts[0];
        testStoredPayments = phss_cc_TestDataFactory.createInsertStoredPayment(1, testOpportunity);
    }

    public static void setupAdditional() {

        testLocation = phss_cc_TestDataFactory.createInsertTestGeoLocation();

        Map<String, Object> learningData = phss_cc_TestDataFactory.createInsertTestLearningObjects();
        redwing__Training_Plan__c trainingPlan = (redwing__Training_Plan__c) learningData.get(phss_cc_TestDataFactory.TEST_TRAINING_PLAN);
        trainingPlan.Classroom_Setting__c = 'Online';
        trainingPlan.redwing__Status__c = 'Active';
        update trainingPlan;

        Course_Catalog__c catalog = new Course_Catalog__c();
        catalog.Name = 'Test Catalog';
        catalog.Number_of_Students__c = 5;
        insert catalog;

        sked__Job__c job = (sked__Job__c) learningData.get(phss_cc_TestDataFactory.TEST_SKEDULO_JOB);
        job.Temp_Course__c = catalog.Name;

        testProduct.ccrz__InventoryType__c = 'COMMUNITY';
        testProduct.LMS_Learning_Plan__c = trainingPlan.Id;
        testProduct.Course_Catalog__c = catalog.Id;
        update testProduct;
        testIltClass = (redwing__ILT_Class__c) learningData.get(phss_cc_TestDataFactory.TEST_ILT_CLASS);

        testCart.Opportunity__c = testOpportunity.Id;
        update testCart;

        List<ccrz__E_CartItem__c> cartItems = [
                SELECT
                        Id,
                        ccrz__Product__c,
                        ILT_Class__c
                FROM
                        ccrz__E_CartItem__c
                WHERE
                        ccrz__Cart__r.Opportunity__c = :testOpportunity.Id
        ];
        for (ccrz__E_CartItem__c cartItem : cartItems) {
            cartItem.ccrz__Product__c = testProduct.Id;
            cartItem.ILT_Class__c = testIltClass.Id;
            testCartItem = cartItem;
        }

        update cartItems;

        List<Voucher__c> vs = new List<Voucher__c>();
        Voucher__c v1 = new Voucher__c();
        v1.ILT_Class__c = testIltClass.id;
        v1.Learning_Plan__c = trainingPlan.Id;
        v1.CC_Product__c = testProduct.Id;
        v1.Status__c = 'Temp Hold';
        vs.add(v1);

        /*
        
        Voucher__c v2 = new Voucher__c();
        v2.ILT_Class__c = testIltClass.id;
        v2.Learning_Plan__c = trainingPlan.Id;
        v2.Status__c = 'Temp Hold';
        vs.add(v2);

        Voucher__c v3 = new Voucher__c();
        v3.ILT_Class__c = testIltClass.id;
        v3.Learning_Plan__c = trainingPlan.Id;
        v3.Status__c = 'Issued';
        vs.add(v3);

         */

        Voucher__c v4 = new Voucher__c();
        v4.ILT_Class__c = testIltClass.id;
        v4.Learning_Plan__c = trainingPlan.Id;
        v4.Status__c = 'Issued';
        vs.add(v4);

        insert vs;

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

        Map<String, Object> updateCartProductsResult = phss_cc_CartController.updateCartProducts(testOpportunity.Id, productQuantityMap);
        for (ccrz__E_Product__c product : testProducts) {
            String productSfid = String.valueOf(product.Id);
            productQuantityMap.put(productSfid, 2);
        }
        Test.stopTest();

        System.assertNotEquals(null, updateCartProductsResult);
    }

    @isTest
    public static void updateCartProductsWithAddingVouchers() {
        setupTestData();
        setupAdditional();

        Test.startTest();

        Map<String, Object> updateCartProductsResult = phss_cc_CartController.updateCartProducts(testOpportunity.Id, productQuantityMap);

        for (ccrz__E_Product__c product : testProducts) {
            String productSfid = String.valueOf(product.Id);
            productQuantityMap.put(productSfid, 3);
        }
        updateCartProductsResult = phss_cc_CartController.updateCartProducts(testOpportunity.Id, productQuantityMap);

        Test.stopTest();

        System.assertNotEquals(null, updateCartProductsResult);
    }

    @isTest
    public static void updateCartProductsWithSubtractingVouchers() {
        setupTestData();
        setupAdditional();

        Test.startTest();

        Map<String, Object> updateCartProductsResult = phss_cc_CartController.updateCartProducts(testOpportunity.Id, productQuantityMap);

        for (ccrz__E_Product__c product : testProducts) {
            String productSfid = String.valueOf(product.Id);
            productQuantityMap.put(productSfid, 1);
        }
        updateCartProductsResult = phss_cc_CartController.updateCartProducts(testOpportunity.Id, productQuantityMap);
        Test.stopTest();

        System.assertNotEquals(null, updateCartProductsResult);
    }

    @isTest
    public static void placeOrderOnCartCC() {
        setupTestData();
        /*

        Test.startTest();
        Map<String, Object> placeOrderResult = phss_cc_CartController.placeOrderOnCartCC(null, null, null);
        placeOrderResult = phss_cc_CartController.placeOrderOnCartCC(testOpportunity.Id, testCart.ccrz__EncryptedId__c, cyberSourceResponseAccept);
        Test.stopTest();

        System.assertNotEquals(null, placeOrderResult);*/
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

    @isTest
    public static void placeOrderOnCartCB() {
        setupTestData();

        List<String> storedPaymentIDs = new List<String>();
        for (ccrz__E_StoredPayment__c storedPayment : testStoredPayments) {
            storedPaymentIDs.add(storedPayment.Id);
        }

        Test.startTest();
        Map<String, Object> placeOrderResult = phss_cc_CartController.placeOrderOnCartCB(null, null, null);
        placeOrderResult = phss_cc_CartController.placeOrderOnCartCB(testOpportunity.Id, testCart.ccrz__EncryptedId__c, storedPaymentIDs);
        Test.stopTest();

        System.assertNotEquals(null, placeOrderResult);
    }

    @isTest
    public static void testGetOpportunityApprovalStatus() {
        setupTestData();
        Test.startTest();
        phss_cc_CartController.getOpportunityApprovalStatus (testOpportunity.Id);
        Test.stopTest();
    }

    @IsTest
    public static void testFetchActiveCartAndItems() {
        setupTestData();
        testCart.ccrz__ActiveCart__c = true;
        update testCart;

        Test.startTest();
        Map<String, Object> result = phss_cc_CartController.fetchActiveCartAndItems(testOpportunity.Id);
        Test.stopTest();

        System.assert(result != null);
    }

    @IsTest
    public static void testUpdateCartItemQuantities() {
        setupTestData();
        testCart.ccrz__ActiveCart__c = true;
        update testCart;

        List<ccrz__E_CartItem__c> cartItems = [SELECT Id, ccrz__Quantity__c FROM ccrz__E_CartItem__c WHERE ccrz__Cart__c = :testCart.Id];
        Map<String, Object> cartItemQuantityMap = new Map<String, Object>();
        for (ccrz__E_CartItem__c cartItem : cartItems) {
            cartItemQuantityMap.put(cartItem.Id, cartItem.ccrz__Quantity__c.intValue() + 1);
        }

        Test.startTest();
        Map<String, Object> result = phss_cc_CartController.updateCartItemQuantities(testOpportunity.Id, cartItemQuantityMap);
        Test.stopTest();

        System.assert(result != null);
        if (result != null) {
            Integer inputTotal = 0;
            for (String cartItemId : cartItemQuantityMap.keySet()) {
                inputTotal += (Integer) cartItemQuantityMap.get(cartItemId);
            }

            Map<String, Object> quantityMap = (Map<String, Object>) result.get(phss_cc_CartUtil.CART_ITEM_QUANTITY_MAP_KEY);
            Integer resultTotal = 0;
            for (String cartItemId : quantityMap.keySet()) {
                resultTotal += ((Decimal) quantityMap.get(cartItemId)).intValue();
            }

            System.assertEquals(inputTotal, resultTotal);
        }
    }
    
    @isTest
    public static void testfetchPaymentTabsetPermissions() {
        setupTestData();
        Test.startTest();
        phss_cc_CartController.fetchPaymentTabsetPermissions (testOpportunity.Id);
        Test.stopTest();
    }
}