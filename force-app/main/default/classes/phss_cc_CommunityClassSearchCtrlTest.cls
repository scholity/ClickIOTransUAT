/**
 * Created by jbarker on 10/23/18.
 */

@isTest
public with sharing class phss_cc_CommunityClassSearchCtrlTest {

    public static Account testAccount;
    public static Map<String, Object> testData;
    public static Opportunity testOpportunity;
    public static ccrz__E_Product__c testProduct;
    public static Geo_Location__c testLocation;
    public static redwing__ILT_Class__c testIltClass;
    public static List<ccrz__E_Product__c> testProducts;

    /**
     * @description Set up for tests
     */
    public static void setup() {

        testData = phss_cc_TestDataFactory.setupAccountAndProducts();

        testAccount = (Account) testData.get(phss_cc_TestDataFactory.TEST_ACCOUNT);
        testOpportunity = phss_cc_TestDataFactory.createInsertTestOpportunity(testAccount);
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

        testProducts = (List<ccrz__E_Product__c>) testData.get(phss_cc_TestDataFactory.TEST_PRODUCTS);
        testProduct = testProducts[0];
        testProduct.ccrz__InventoryType__c = 'COMMUNITY';
        testProduct.LMS_Learning_Plan__c = trainingPlan.Id;
        testProduct.Course_Catalog__c = catalog.Id;
        update testProduct;
        testIltClass = (redwing__ILT_Class__c) learningData.get(phss_cc_TestDataFactory.TEST_ILT_CLASS);

    }

    /**
     * @description Formats a Date as a Javascript date string
     *
     * @param d
     *
     * @return
     */
    private static String formatDateAsYYYYMMDD(Date d) {
        String dateStr;

        if (d != null) {
            dateStr = '' + d.year() + '-' + d.month() + '-' + d.day();
        }

        return dateStr;
    }

    /**
     * @description Tests community class search by city and state
     */
    @isTest static void testClassSearch() {

        setup();

        String testSearchTerm = testProduct.Name;
        String testOpportunityId = testOpportunity.Id;
        String testStartDate = formatDateAsYYYYMMDD(phss_cc_TestDataFactory.TEST_COMMUNITY_CLASS_SEARCH_START_DATE);
        String testEndDate = formatDateAsYYYYMMDD(phss_cc_TestDataFactory.TEST_COMMUNITY_CLASS_SEARCH_END_DATE);
        String testCity = phss_cc_TestDataFactory.TEST_COMMUNITY_CLASS_SEARCH_CITY;
        String testState= phss_cc_TestDataFactory.TEST_COMMUNITY_CLASS_SEARCH_STATE;
        Integer testRange = phss_cc_TestDataFactory.TEST_COMMUNITY_CLASS_SEARCH_RANGE;

        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = testProduct.Id;

        Test.startTest();
        Test.setFixedSearchResults(fixedSearchResults);

        Map<String, Object> result = phss_cc_CommunityClassSearchController.classSearch(testSearchTerm, testOpportunityId, testStartDate, testEndDate, testCity, testState, null, testRange);
        Test.stopTest();

        System.assert(result != null);
    }

    /**
     * @description Tests add to cart
     */
    @isTest
    static void testAddToCart() {

        setup();
        String testOpportunityId = testOpportunity.Id;
        String testIltClassId = testIltClass.Id;
        String testCourseId = testProduct.Id;
        Map<String, Object> items = new Map<String, Object>{
                phss_cc_ClassCartUtil.CLASS_ID_KEY => testIltClassId,
                phss_cc_ClassCartUtil.COURSE_ID_KEY => testCourseId,
                phss_cc_ClassCartUtil.COUNT_KEY => 1
        };
        List<Map<String, Object>> classList = new List<Map<String, Object>>();
        classList.add(items);
        String json = JSON.serialize(classList);
        Test.startTest();
        Map<String, Object> result = phss_cc_CommunityClassSearchController.addClassesToCart(testOpportunityId, json);
        Test.stopTest();
    }

    /**
     * @description Tests evaluate search
     */
    @isTest
    static void testEvaluateSearch() {

        setup();
        String testSearchTerm = testProduct.Name;
        String testOpportunityId = testOpportunity.Id;
        String testIltClassId = testIltClass.Id;

        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = testProduct.Id;

        Test.startTest();
        Test.setFixedSearchResults(fixedSearchResults);
        phss_cc_CommunityClassSearchController.evaluateSearch(testSearchTerm, testIltClassId, testOpportunityId);
        Test.stopTest();
    }
}