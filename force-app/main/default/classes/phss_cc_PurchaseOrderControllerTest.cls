/**
 * Created by dgajwani on 10/3/18.
 */
@isTest
public with sharing class phss_cc_PurchaseOrderControllerTest {

    public static Opportunity testOpportunity;
    public static Map<String, Object> testData;

    /**
     * @description Creates the basic testdata.
     */
    public static void setupTestData() {
        testData = phss_cc_TestDataFactory.setupAccountAndProducts();
        testOpportunity = phss_cc_TestDataFactory.createInsertTestOpportunity((Account) testData.get(phss_cc_TestDataFactory.TEST_ACCOUNT));
    }

    @isTest
    public static void testFetchStoredPayments() {

        setupTestData();

        Test.startTest();
        Map<String, Object> fetchStoredPaymentsResponse = phss_cc_PurchaseOrderController.fetchStoredPayments(null);
        fetchStoredPaymentsResponse = phss_cc_PurchaseOrderController.fetchStoredPayments(testOpportunity.Id);
        Test.stopTest();

        System.assertNotEquals(null, fetchStoredPaymentsResponse);
    }

}