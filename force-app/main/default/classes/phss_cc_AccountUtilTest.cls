/**
 * Created by jbarker on 2019-10-01.
 */

@IsTest
public with sharing class phss_cc_AccountUtilTest {

    @IsTest
    public static void testFetchAccount() {
        Map<String,Object> testData = phss_cc_TestDataFactory.setupAccountAndProducts(1);
        Account testAccount = (Account) testData.get(phss_cc_TestDataFactory.TEST_ACCOUNT);

        Test.startTest();
        Account result = phss_cc_AccountUtil.fetchAccount(testAccount.Id);
        Test.stopTest();

        System.assertEquals(testAccount.Id, result.Id);
    }

    @IsTest
    public static void testFetchAccountWithException() {
        Boolean exceptionThrown = false;
        Test.startTest();
        try {
            phss_cc_AccountUtil.fetchAccount(null);
        } catch (Exception e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assert(exceptionThrown);
    }

    @IsTest
    public static void testFetchAccountForOpportunity() {
        Map<String,Object> testData = phss_cc_TestDataFactory.setupAccountAndProducts(1);
        Account testAccount = (Account) testData.get(phss_cc_TestDataFactory.TEST_ACCOUNT);
        Opportunity testOpportunity = phss_cc_TestDataFactory.createInsertTestOpportunity(testAccount);

        Test.startTest();
        Account result = phss_cc_AccountUtil.fetchAccountForOpportunity(testOpportunity.Id);
        Test.stopTest();

        System.assertEquals(testAccount.Id, result.Id);
    }

    @IsTest
    public static void testFetchAccountForOpportunityWithException() {
        Boolean exceptionThrown = false;
        Test.startTest();
        try {
            phss_cc_AccountUtil.fetchAccountForOpportunity(null);
        } catch (Exception e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assert(exceptionThrown);
    }
}