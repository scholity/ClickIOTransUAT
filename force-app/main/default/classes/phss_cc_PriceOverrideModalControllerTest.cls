/**
 * Created by jbarker on 11/9/18.
 */

@isTest
public with sharing class phss_cc_PriceOverrideModalControllerTest {

    public static Opportunity testOpportunity;
    public static ccrz__E_Product__c testProduct;
    public static List<ccrz__E_Product__c> testProducts;
    public static Map<String, Object> productQuantityMap;
    public static ccrz__E_Cart__c testCart;
    public static Map<String, Object> testData;

    public static void setupTestData() {
        testData = phss_cc_TestDataFactory.setupAccountAndProducts();
        testOpportunity = phss_cc_TestDataFactory.createInsertTestOpportunity((Account) testData.get(phss_cc_TestDataFactory.TEST_ACCOUNT));
        testProducts = (List<ccrz__E_Product__c>) testData.get(phss_cc_TestDataFactory.TEST_PRODUCTS);
        testProduct = testProducts[0];

        List<ccrz__E_Cart__c> testCarts = phss_cc_TestDataFactory.createInsertCartAndCartItems(1, testData, testOpportunity.Id);
        testCart = testCarts[0];
    }

    /**
     * @description
     */
    @IsTest static void testGetCartItem() {

        setupTestData();

        ccrz__E_CartItem__c cartItem = [
                SELECT  Id
                FROM    ccrz__E_CartItem__c
                WHERE   ccrz__Cart__c = :testCart.Id
                LIMIT   1
        ];

        Test.startTest();
        Map<String, Object> results = phss_cc_PriceOverrideModalController.getCartItem(cartItem.Id, testOpportunity.Id);
        Test.stopTest();

        System.assert(results != null);
        System.assert(results.containsKey(phss_cc_PriceOverrideModalController.CART_ITEM_KEY));

        Map<String, Object> cartItemMap = (Map<String, Object>) results.get(phss_cc_PriceOverrideModalController.CART_ITEM_KEY);
        System.assert(cartItemMap != null);
    }

    /**
     * @description Tests overriding the percent discount of a cart item
     */
    @IsTest static void testPercentDiscountOverridePriceForCartItem() {

        setupTestData();

        ccrz__E_CartItem__c testCartItem = getAnyItemInCart(testCart.Id);
        String overrideType = phss_cc_PriceOverrideModalController.PERCENT_DISCOUNT_OVERRIDE_TYPE;

        Decimal overrideValue = 0.5;
        String overrideValueStr = overrideValue.toPlainString();

        Test.startTest();
        Map<String, Object> results = phss_cc_PriceOverrideModalController.overridePriceForCartItem(testCartItem.Id, overrideType, overrideValueStr, null);
        Test.stopTest();

        System.assert(results != null);
        System.assert(results.containsKey(phss_cc_PriceOverrideModalController.CART_ITEM_KEY));

        ccrz__E_CartItem__c cartItem = (ccrz__E_CartItem__c) results.get(phss_cc_PriceOverrideModalController.CART_ITEM_KEY);
        cartItem = fetchCartItem(cartItem.Id);

        System.assert(cartItem.ccrz__PercentDiscount__c == Decimal.valueOf(overrideValueStr));
        System.assert(cartItem.ccrz__PricingType__c == phss_cc_PriceOverrideModalController.EXTERNAL_PRICING_TYPE);
    }

    /**
     * @description Tests overriding the unit price of a cart item
     */
    @IsTest static void testUnitPriceOverridePriceForCartItem() {

        setupTestData();

        ccrz__E_CartItem__c testCartItem = getAnyItemInCart(testCart.Id);
        String overrideType = phss_cc_PriceOverrideModalController.UNIT_PRICE_OVERRIDE_TYPE;

        Decimal overrideValue = testCartItem.ccrz__Price__c * 0.91;
        overrideValue.setScale(2);
        String overrideValueStr = overrideValue.toPlainString();

        Test.startTest();
        Map<String, Object> results = phss_cc_PriceOverrideModalController.overridePriceForCartItem(testCartItem.Id, overrideType, overrideValueStr, null);
        Test.stopTest();

        System.assert(results != null);
        System.assert(results.containsKey(phss_cc_PriceOverrideModalController.CART_ITEM_KEY));

        ccrz__E_CartItem__c cartItem = (ccrz__E_CartItem__c) results.get(phss_cc_PriceOverrideModalController.CART_ITEM_KEY);
        cartItem = fetchCartItem(cartItem.Id);

        System.assert(cartItem.ccrz__Price__c == overrideValue);
        System.assert(cartItem.ccrz__PricingType__c == phss_cc_PriceOverrideModalController.EXTERNAL_PRICING_TYPE);
    }

    private static ccrz__E_CartItem__c fetchCartItem(String cartItemSfid) {
        return [
                SELECT Id, ccrz__Price__c, ccrz__PricingType__c, ccrz__PercentDiscount__c
                FROM ccrz__E_CartItem__c
                WHERE Id = :cartItemSfid
        ];
    }

    private static ccrz__E_CartItem__c getAnyItemInCart(String cartSfid) {
        ccrz__E_CartItem__c cartItem = [
                SELECT  Id,
                        ccrz__Price__c
                FROM    ccrz__E_CartItem__c
                WHERE   ccrz__Cart__c = :cartSfid
                LIMIT   1
        ];
        return cartItem;
    }
    
    public static void CreateTestCoupons(Integer coupons)
    {
        Database.DMLOptions dml = new Database.DMLOptions();        
        dml.DuplicateRuleHeader.allowSave = true;
        
        List<Coupon__c> couponList = new List<Coupon__c>();
        
        for(Integer a = 0; a< coupons; a++)
        {
            couponList.add(new Coupon__c( Start_Date__c 	= Date.today(),
                                    	  End_Date__c		= Date.today().addDays(30),
                                    	  Type__c			= 'Value Off',
                                    	  Value__c			= 10,
                                    	  Display_Name__c 	= 'Testing Coupon'+ String.ValueOf(a),
                                    	  Active__c	 		= true));
        }
        
        database.insert(couponList, dml);
    }
    
    public static final Integer couponsCount  = 5;
    
    @testsetup 
    public static void initializeCouponTestData()
    {
        CreateTestCoupons(couponsCount);
    }
    
    @IsTest
    static void testGetCoupons()
    {
        Test.StartTest();
        	phss_cc_PriceOverrideModalController.GetCoupons();
        Test.StopTest();
    }
    
    @IsTest
    static void testGetCouponsDiscount()
    {
        Coupon__c c = [SELECT Id FROM Coupon__c LIMIT 1];
        
        Test.StartTest();
        	phss_cc_PriceOverrideModalController.getCouponsDiscount(c.Id);
        Test.StopTest();
    }
    
    
    @IsTest
    static void testProcessRemoveCoupon()
    {
        Coupon__c c = [SELECT Id FROM Coupon__c LIMIT 1];
        
        setupTestData();

        ccrz__E_CartItem__c testCartItem = getAnyItemInCart(testCart.Id);
        
        Test.StartTest();
        	phss_cc_PriceOverrideModalController.processRemoveCoupon(testCartItem.Id,c.Id);
        Test.StopTest();
    }
    
}