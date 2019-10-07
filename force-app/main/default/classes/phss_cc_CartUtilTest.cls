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
     * @description Tests if a cart is correctly fetched by its encrypted Id.
     */
    @IsTest
    static void testFetchCart() {
        setupTestData();
        List<ccrz__E_Cart__c> carts = phss_cc_TestDataFactory.createInsertCartAndCartItems(1, testData, testOpportunity.Id);
        String encryptedCartId = carts[0].ccrz__EncryptedId__c;

        Test.startTest();
        ccrz__E_Cart__c cart = phss_cc_CartUtil.fetchCart(encryptedCartId);
        Test.stopTest();

        System.assert(cart != null);
        System.assertEquals(encryptedCartId, cart.ccrz__EncryptedId__c);
    }

    /**
     * @description Tests if a cart is correctly fetched by its Id.
     */
    @IsTest
    static void testFetchCartById() {
        setupTestData();
        List<ccrz__E_Cart__c> carts = phss_cc_TestDataFactory.createInsertCartAndCartItems(1, testData, testOpportunity.Id);
        String cartId = carts[0].Id;

        Test.startTest();
        ccrz__E_Cart__c cart = phss_cc_CartUtil.fetchCartById(cartId);
        Test.stopTest();

        System.assert(cart != null);
        System.assertEquals(cartId, cart.Id);
    }

    /**
     * @description Tests if a cart and its items can be fetched by the opportunity Id.
     */
    @IsTest
    static void testFetchActiveCartAndItems() {
        setupTestData();
        List<ccrz__E_Cart__c> carts = phss_cc_TestDataFactory.createInsertCartAndCartItems(1, testData, testOpportunity.Id);
        ccrz__E_Cart__c cart = carts[0];
        cart.ccrz__ActiveCart__c = true;
        update cart;

        Test.startTest();
        Map<String, Object> result = phss_cc_CartUtil.fetchActiveCartAndItems(testOpportunity.Id);
        Test.stopTest();

        System.assert(result != null);
    }

    /**
     * @description Tests if the cart item quantities can be successfully updated
     */
    @IsTest
    static void testUpdateCartItemQuantities() {
        setupTestData();
        ccrz__E_Cart__c cart = phss_cc_TestDataFactory.createInsertCartAndCartItems(1, testData, testOpportunity.Id)[0];
        List<ccrz__E_CartItem__c> cartItems = [SELECT Id, ccrz__Quantity__c FROM ccrz__E_CartItem__c WHERE ccrz__Cart__c = :cart.Id];
        Map<String, Object> cartItemQuantityMap = new Map<String, Object>();
        for (ccrz__E_CartItem__c cartItem : cartItems) {
            cartItemQuantityMap.put(cartItem.Id, cartItem.ccrz__Quantity__c.intValue() + 1);
        }

        Test.startTest();
        Map<String, Object> result = phss_cc_CartUtil.updateCartItemQuantities(testOpportunity.Id, cartItemQuantityMap);
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

    /**
     * @description Tests if the most recently modified open cart can be activated
     */
    @IsTest
    static void testActivateOpenCart() {
        setupTestData();

        ccrz__E_Cart__c cart = new ccrz__E_Cart__c(
                Opportunity__c = testOpportunity.Id,
                ccrz__ActiveCart__c = false,
                ccrz__CartStatus__c = 'Open'
        );
        insert cart;

        Test.startTest();
        ccrz__E_Cart__c testCart = phss_cc_CartUtil.activateOpenCart(testOpportunity.Id);
        Test.stopTest();

        System.assert(testCart != null);
        System.assertEquals(true, testCart.ccrz__ActiveCart__c);
    }
}