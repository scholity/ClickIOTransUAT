/**
 * Created by jbarker on 2019-08-08.
 */

@IsTest
public with sharing class phss_cc_hk_OrderTest {

    private static Map<String, Object> testData;
    private static Account testAccount;
    private static Opportunity testOpportunity;
    private static ccrz__E_Cart__c testCart;
    private static List<ccrz__E_CartItem__c> testCartItems;
    private static ccrz__E_Order__c testOrder;
    private static List<ccrz__E_OrderItem__c> testOrderItems;
    private static List<ccrz__E_Product__c> testProducts;
    private static List<Voucher__c> testVouchers;
    private static Map<String, Object> testInputData;


    public static void setupTestData() {
        testData = phss_cc_TestDataFactory.setupAccountAndProducts();
        testAccount = (Account) testData.get(phss_cc_TestDataFactory.TEST_ACCOUNT);
        testOpportunity = phss_cc_TestDataFactory.createInsertTestOpportunity(testAccount);
        testProducts = (List<ccrz__E_Product__c>) testData.get(phss_cc_TestDataFactory.TEST_PRODUCTS);
        testCart = phss_cc_TestDataFactory.createInsertCartAndCartItems(1, testData, testOpportunity.Id)[0];

        testCartItems = [
                SELECT  ccrz__Product__r.ccrz__SKU__c,
                        ILT_Class__c,
                        ccrz__Coupon__c
                FROM    ccrz__E_CartItem__c
                WHERE   ccrz__Cart__c = :testCart.Id
        ];

        testVouchers = new List<Voucher__c>();
        for (ccrz__E_CartItem__c item : testCartItems) {
            Voucher__c voucher = new Voucher__c(CC_Cart_Item__c = item.Id);
            testVouchers.add(voucher);
        }
        insert testVouchers;

        testOrder = new ccrz__E_Order__c(
                NSSCCConnector_SFCC_Order_Number__c = '3114226',
                NSSCCConnector_from_SFCC__c = true,
                ccrz__Account__c = testAccount.Id
        );
        insert testOrder;

        testOrderItems = new List<ccrz__E_OrderItem__c>();
        for (ccrz__E_CartItem__c item : testCartItems) {
            ccrz__E_OrderItem__c orderItem = new ccrz__E_OrderItem__c(
                    ccrz__Product__c = testProducts[0].Id,
                    ccrz__Order__c = testOrder.Id,
                    ccrz__Price__c = 100,
                    ccrz__Quantity__c = 100.00,
                    ccrz__SubAmount__c = 100.00
            );
            testOrderItems.add(orderItem);
        }
        insert testOrderItems;

        testInputData = new Map<String, Object> {
                ccrz.cc_hk_Order.PARAM_CART_ITEMS => testCartItems,
                ccrz.cc_hk_Order.PARAM_ORDER => testOrder,
                ccrz.cc_hk_Order.PARAM_ORDER_ITEMS => testOrderItems,
                ccrz.cc_hk_Order.PARAM_PLACE_STEP => ccrz.cc_hk_Order.STEP_CREATE_ORDER_ITEMS_POST
        };
    }

    @IsTest
    public static void testPlace() {
        setupTestData();

        Test.startTest();
        phss_cc_hk_Order ccOrder = new phss_cc_hk_Order();
        Map<String, Object> result = ccOrder.place(testInputData);
        Test.stopTest();

        System.assertNotEquals(null, result);
    }
}