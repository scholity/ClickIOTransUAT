/**
 * Created by jbarker on 2019-08-27.
 */

@IsTest
public with sharing class phss_cc_CartItemUtilTest {

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
    @IsTest
    static void testGetCartItem() {

        setupTestData();

        ccrz__E_CartItem__c cartItem = [
                SELECT  Id
                FROM    ccrz__E_CartItem__c
                WHERE   ccrz__Cart__c = :testCart.Id
                LIMIT   1
        ];

        Test.startTest();
        ccrz__E_CartItem__c result = phss_cc_CartItemUtil.getCartItem(cartItem.Id);
        Test.stopTest();

        System.assert(result != null);
    }

    /**
     * @description Tests a fetch with no cart item ID.
     */
    @IsTest
    static void testGetCartItemWithNullId() {
        ccrz__E_CartItem__c cartItem = phss_cc_CartItemUtil.getCartItem(null);
        System.assert(cartItem == null);
    }

}