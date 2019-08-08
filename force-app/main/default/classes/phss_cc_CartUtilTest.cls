/**
 * Created by dgajwani on 9/24/18.
 */
@isTest
public with sharing class phss_cc_CartUtilTest {

    private static final String CART_ENCRYPTED_ID_KEY = 'encryptedCartId';

    public static Opportunity testOpportunity;
    public static List<ccrz__E_Product__c> products;
    public static Map<String, Object> productQuantityMap;
    public static Map<String, Object> testData;

    /**
     * @description Creates the basic testdata.
     */
    public static void setupTestData() {
        testData = phss_cc_TestDataFactory.setupAccountAndProducts();
        products = (List<ccrz__E_Product__c>) testData.get(phss_cc_TestDataFactory.TEST_PRODUCTS);
        testOpportunity = phss_cc_TestDataFactory.createInsertTestOpportunity((Account) testData.get(phss_cc_TestDataFactory.TEST_ACCOUNT));

        //Create productQuantityMap
        productQuantityMap = new Map<String, Object>();
        for (ccrz__E_Product__c product : products) {
            String productSfid = String.valueOf(product.Id);
            productQuantityMap.put(productSfid, 2);
        }
    }

    /**
     * @description Tests if a CC Cart is correctly created from createCart() when there isnt an active cart for the buyer.
     */
    @IsTest static void testAddToNewCart() {

        setupTestData();

        Map<String, Object> createCartResponse;

        Test.startTest();
        createCartResponse = phss_cc_CartUtil.addProductsToCart(testOpportunity.Id, productQuantityMap,false);
        Test.stopTest();

        System.assert(createCartResponse != null);
        System.assert(createCartResponse.containsKey(CART_ENCRYPTED_ID_KEY));

        // Check if Cart was created in the DB.
        String encryptedCartId = (String) createCartResponse.get(CART_ENCRYPTED_ID_KEY);
        List<ccrz__E_Cart__c> currCartSOQL = [SELECT Id,ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__EncryptedId__c = :encryptedCartId];
        System.assertNotEquals(currCartSOQL.size(), 0);
        System.assertEquals(encryptedCartId, currCartSOQL[0].ccrz__EncryptedId__c);

        // Check if the right number of cart items are created.
        Id cartId = currCartSOQL[0].Id;
        List<ccrz__E_CartItem__c> currCartItemsSOQL = [SELECT Id FROM ccrz__E_CartItem__c WHERE ccrz__Cart__c = :cartId];
        System.assertEquals(productQuantityMap.size(), currCartItemsSOQL.size());
    }

    /**
     * @description Tests if a CC Cart is correctly created from createCart() when there is an active cart for the buyer.
     */
    @IsTest static void testAddToExistingCart() {

        setupTestData();

        Map<String, Object> createCartResponse;

        Test.startTest();

        Map<String, Object> existingCartResponse = phss_cc_CartUtil.addProductsToCart(testOpportunity.Id, productQuantityMap,false);

        // Test to add cart Items to an existing cart.
        createCartResponse = phss_cc_CartUtil.addProductsToCart(testOpportunity.Id, productQuantityMap,false);

        Test.stopTest();

        System.assert(createCartResponse != null);
        System.assert(createCartResponse.containsKey(CART_ENCRYPTED_ID_KEY));

        // Check if Cart was created in the DB.
        String encryptedCartId = (String) createCartResponse.get(CART_ENCRYPTED_ID_KEY);
        List<ccrz__E_Cart__c> currCartSOQL = [SELECT Id,ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__EncryptedId__c = :encryptedCartId];
        System.assertNotEquals(currCartSOQL.size(), 0);
        System.assertEquals(encryptedCartId, currCartSOQL[0].ccrz__EncryptedId__c);

        // Check if the right number of cart items are created.
        Id cartId = currCartSOQL[0].Id;
        List<ccrz__E_CartItem__c> currCartItemsSOQL = [SELECT Id FROM ccrz__E_CartItem__c WHERE ccrz__Cart__c = :cartId];
        System.assertEquals(productQuantityMap.size(), currCartItemsSOQL.size());
    }

    /**
     * @description Tests if the active cart was correctly fetched.
     */
    @IsTest static void testFetchActiveCart() {

        setupTestData();
        phss_cc_TestDataFactory.createInsertCartAndCartItems(1,testData,testOpportunity.Id);

        Test.startTest();
        Map<String, Object> fetchActiveCartResponse = phss_cc_CartUtil.fetchActiveCart(testOpportunity.Id,true);
        Test.stopTest();

        System.assert(fetchActiveCartResponse != null);
        System.assert(fetchActiveCartResponse.containsKey(phss_cc_CartUtil.CART_ENCRYPTED_ID_KEY));
        System.assert(fetchActiveCartResponse.containsKey(phss_cc_CartUtil.PRODUCT_LIST_KEY));
        System.assert(fetchActiveCartResponse.containsKey(phss_cc_CartUtil.PRODUCT_MAP_KEY));
        System.assert(fetchActiveCartResponse.containsKey(phss_cc_CartUtil.PRODUCT_QUANTITY_MAP_KEY));
        System.assert(fetchActiveCartResponse.containsKey(phss_cc_CartUtil.CART_TOTAL_KEY));

    }

    /**
     * @description Tests if the correct addresses are fetched from cart.
     */
    @IsTest static void testGetCurrentAddressesFromCart() {

        setupTestData();
        List<ccrz__E_Cart__c> mycarts = phss_cc_TestDataFactory.createInsertCartAndCartItems(1,testData,testOpportunity.Id);
        ccrz__E_ContactAddr__c testShippingAddress = phss_cc_TestDataFactory.createInsertTestContactAddress();
        phss_cc_TestDataFactory.addAddressToCart(mycarts[0],testShippingAddress.Id, 'Shipping');

        Test.startTest();
        Map<String, Object> fetchActiveCartResponse = phss_cc_CartUtil.getCurrentAddressesFromCart(testOpportunity.Id);
        Test.stopTest();

        System.assert(fetchActiveCartResponse != null);
        System.assert(fetchActiveCartResponse.containsKey(phss_cc_CartUtil.ADDRESS_LIST));
        System.assert(fetchActiveCartResponse.containsKey(phss_cc_CartUtil.ADDRESS_MAP));
        Map<String,Object> addressMap = (Map<String,Object>)fetchActiveCartResponse.get(phss_cc_CartUtil.ADDRESS_MAP);
        System.assertNotEquals(0, addressMap.size());
    }

    /**
     * @description Tests if the correct addresses are fetched from cart.
     */
    @IsTest static void testAddAddressToCart() {

        setupTestData();
        phss_cc_TestDataFactory.createInsertCartAndCartItems(1,testData,testOpportunity.Id);
        ccrz__E_ContactAddr__c testShippingAddress = phss_cc_TestDataFactory.createInsertTestContactAddress();

        Test.startTest();
        Map<String, Object> addAddressToCartResponse = phss_cc_CartUtil.addAddressToCart(testOpportunity.Id, 'Shipping', testShippingAddress.Id);
        Test.stopTest();

        System.assert(addAddressToCartResponse != null);
        System.assert(addAddressToCartResponse.containsKey(phss_cc_CartUtil.SUCCESS_KEY));
    }

}