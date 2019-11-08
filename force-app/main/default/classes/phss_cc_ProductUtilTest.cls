/**
 * Created by dgajwani on 9/24/18.
 */
@isTest
public with sharing class phss_cc_ProductUtilTest {

    private static final String TEST_SEARCH_STRING = 'TEST0';
    public static List<ccrz__E_Product__c> testProducts;
    public static Opportunity testOpportunity;
    public static Map<String, Object> testData;

    /**
     * @description Creates the basic testdata.
     */
    public static void setupTestData() {
        testData = phss_cc_TestDataFactory.setupAccountAndProducts();
        testProducts = (List<ccrz__E_Product__c>)testData.get(phss_cc_TestDataFactory.TEST_PRODUCTS);
        system.debug('testProducts***'+testProducts);
        testOpportunity = phss_cc_TestDataFactory.createInsertTestOpportunity((Account)testData.get(phss_cc_TestDataFactory.TEST_ACCOUNT));
    }

    @isTest
    public static void testProductSearch(){

        setupTestData();
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = testProducts.get(0).Id;

        Test.startTest();
        Test.setFixedSearchResults(fixedSearchResults);
        Map<String, Object> searchResult = phss_cc_ProductUtil.productSearch(testOpportunity.Id,TEST_SEARCH_STRING);

        Test.stopTest();

        System.assertNotEquals(null, searchResult);
        System.assert(searchResult.containsKey(phss_cc_ProductUtil.PRODUCT_LIST_KEY));
        System.assert(searchResult.containsKey(phss_cc_ProductUtil.PRODUCT_MAP_KEY));
        Set<String> productMapFromResult = (Set<String>)searchResult.get(phss_cc_ProductUtil.PRODUCT_LIST_KEY);
        System.assert(productMapFromResult.size() > 0);
    }
    
    @isTest
    public static void testfilteredProductSearch(){
        
        Map<String, String> testMap = new Map<String, String>();

		testMap.put('Test1', 'TestOne');
		testMap.put('Test2', 'TestTwo');

        setupTestData();
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = testProducts.get(0).Id;

        Test.startTest();
        Test.setFixedSearchResults(fixedSearchResults);
        phss_cc_ProductUtil.filteredProductSearch(testOpportunity.Id,TEST_SEARCH_STRING,testMap);
        Test.stopTest();

        
    }

    @IsTest
    public static void testProductSearchExcludingNonOnlineCommCourses() {

        setupTestData();
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = testProducts.get(0).Id;

        Test.startTest();
        Test.setFixedSearchResults(fixedSearchResults);
        Map<String, Object> searchResult = phss_cc_ProductUtil.productSearchExcludingNonOnlineCommCourses(testOpportunity.Id, TEST_SEARCH_STRING);
        Test.stopTest();

        System.assertNotEquals(null, searchResult);
        System.assert(searchResult.containsKey(phss_cc_ProductUtil.PRODUCT_LIST_KEY));
        System.assert(searchResult.containsKey(phss_cc_ProductUtil.PRODUCT_MAP_KEY));
    }

    @isTest
    public static void testgetProductDetailsKeyedToSfidMap(){
        
        Set<String> testSet = new Set<String>();
        
        setupTestData();
        
        for(ccrz__E_Product__c p : testProducts)
        {
            testSet.add(p.Id);
        }
        
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = testProducts.get(0).Id;
        
        Test.startTest();
        Test.setFixedSearchResults(fixedSearchResults);
        phss_cc_ProductUtil.getProductDetailsKeyedToSfidMap(testSet);
        Test.stopTest();

        
    }

    @isTest
    public static void testCompositeProducts() {

        Map<String, Object> testData = phss_cc_TestDataFactory.setupAccountAndProducts();

        // create test data
        List<ccrz__E_Product__c> testProducts = (List<ccrz__E_Product__c>)testData.get(phss_cc_TestDataFactory.TEST_PRODUCTS);

        // get product
        ccrz__E_Product__c product = testProducts[0];

        ccrz__E_Product__c aggregatedPr = new ccrz__E_Product__c(
                Name = 'Test Composite Product',
                ccrz__SKU__c = testProducts[0].ccrz__SKU__c + 'cmp',
                ccrz__ProductStatus__c = phss_cc_TestDataFactory.PRODUCT_STATUS_RELEASED,
                ccrz__ProductType__c = 'Aggregated',
                ccrz__Storefront__c = phss_cc_TestDataFactory.TEST_STOREFRONT,
                ccrz__ShortDesc__c = 'Composite product',
                ccrz__ShortDescRT__c = 'Composite product',
                ccrz__StartDate__c = System.today().addYears(-1),
                ccrz__EndDate__c = System.today().addYears(+1),
                AP_Code__c = '6200',
                FCC__c = '32620',
                OMSProductName__c = '1234'

        );
        insert aggregatedPr;

        ccrz__E_PriceListItem__c priceListItem = new ccrz__E_PriceListItem__c(
                ccrz__Price__c = 0,
                ccrz__Product__c = aggregatedPr.Id,
                ccrz__Pricelist__c = [SELECT Id FROM ccrz__E_PriceList__c LIMIT 1].Id,
                ccrz__StartDate__c = System.today().addYears(-1)
        );
        insert priceListItem;

        ccrz__E_CompositeProduct__c compositePr = new ccrz__E_CompositeProduct__c(
                ccrz__Component__c = testProducts[0].Id,
                ccrz__Composite__c = aggregatedPr.Id,
                ccrz__Quantity__c = 1
        );
        insert compositePr;

        Map<String, Object> componentRMap = new Map<String, Object> {
                aggregatedPr.Id => aggregatedPr
        };

        Map<String, Object> compositeProductMap = new Map<String, Object> {
                'compositeProductsS' => compositePr.Id,
                'component' => product.Id,
                'componentR' => componentRMap
        };

        List<Map<String, Object>> compositeProducts = new List<Map<String, Object>>{compositeProductMap};

        Map<String, Object> prod = new Map<String, Object> {
                'compositeProductsS' => compositeProducts
        };

        Map<String, Object> productMap = new Map<String, Object>{
                product.Id => prod
        };


        Test.startTest();
        phss_cc_ProductUtil.fetchComponentProducts(productMap);
        Test.stopTest();
    }
    
}