/**
 * Created by dgajwani on 9/24/18.
 */
@isTest
public with sharing class phss_cc_ProductListComponentCtrlTest {

    private static final String TEST_SEARCH_STRING = 'TEST0';
    public static Opportunity testOpportunity;
    public static Map<String, Object> testData;
    public static List<ccrz__E_Product__c> products;
    public static Map<String, Object> productQuantityMap;

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

    @isTest static void testFetchActiveCartOnProductSearch() {
        setupTestData();
        phss_cc_TestDataFactory.createInsertCartAndCartItems(1,testData,testOpportunity.Id);

        Test.startTest();
        Map<String, Object> fetchActiveCartOnProductSearch = phss_cc_ProductListComponentController.fetchActiveCartOnProductSearch(testOpportunity.Id);
        fetchActiveCartOnProductSearch = phss_cc_ProductListComponentController.fetchActiveCartOnProductSearch(testOpportunity.Id);
        Test.stopTest();

        System.assertNotEquals(null, fetchActiveCartOnProductSearch);

    }

    @isTest static void testProductSearch() {
        setupTestData();

        Test.startTest();
        Map<String, Object> searchProductsResponse = phss_cc_ProductListComponentController.searchProducts(null, TEST_SEARCH_STRING);
        searchProductsResponse = phss_cc_ProductListComponentController.searchProducts(testOpportunity.Id, TEST_SEARCH_STRING);
        Test.stopTest();

        System.assertNotEquals(null, searchProductsResponse);

    }

    @isTest static void testAddToCart() {
        setupTestData();

        Id [] fixedSearchResults = new Id[1];
        fixedSearchResults[0] = products.get(0).Id;

        Test.startTest();
        Test.setFixedSearchResults(fixedSearchResults);
        Map<String, Object>addProductsToCartResponse = phss_cc_ProductListComponentController.addProductsToCart(null, productQuantityMap);
        addProductsToCartResponse = phss_cc_ProductListComponentController.addProductsToCart(testOpportunity.Id, productQuantityMap);
        Test.stopTest();

        System.assertNotEquals(null, addProductsToCartResponse);
    }
}