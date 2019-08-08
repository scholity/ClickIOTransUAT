/************************************************************************************************************************************
** Author: Salesforce Services
** Description: Tests for AccountTriggerHandler
************************************************************************************************************************************/

@isTest
public class AccountTriggerHandlerTest {
    public static Map<String, Object> testData;
    public static Account testAccount;
    @testSetup static void setup() {
		       
    }
    // Scenario: More than 40 characters in one line
    static testMethod void testMethod1() {
        Test.startTest();
        testData = phss_cc_TestDataFactory.setupAccountAndProducts(); 
		testAccount = (Account) testData.get(phss_cc_TestDataFactory.TEST_ACCOUNT);
        testAccount.BillingStreet = '0123456789012345678901234567890123456789aa';
        try {
            if(Test.isRunningTest()) {
                // Cause DMLException
                update testAccount;
            }        
        } catch (DMLException ex) {
            // Existing exception handling.        
        }
        Test.stopTest();
    } 
    // Scenario: More than 40 characters in first of two lines
    static testMethod void testMethod2() {
        Test.startTest(); 
        testData = phss_cc_TestDataFactory.setupAccountAndProducts(); 
		testAccount = (Account) testData.get(phss_cc_TestDataFactory.TEST_ACCOUNT);
        testAccount.BillingStreet = '0123456789012345678901234567890123456789aa' + '\n' + '0123456789';
        try {
            if(Test.isRunningTest()) {
                // Cause DMLException
                update testAccount;
            }        
        } catch (DMLException ex) {
            // Existing exception handling.        
        }
        Test.stopTest();
    } 
    // Scenario: More than 40 characters in two lines
    static testMethod void testMethod3() {
        Test.startTest();   
        testData = phss_cc_TestDataFactory.setupAccountAndProducts(); 
		testAccount = (Account) testData.get(phss_cc_TestDataFactory.TEST_ACCOUNT);
        testAccount.BillingStreet = '0123456789012345678901234567890123456789aa' + '\n' + '0123456789012345678901234567890123456789aa';
        try {
            if(Test.isRunningTest()) {
                // Cause DMLException
                update testAccount;
            }        
        } catch (DMLException ex) {
            // Existing exception handling.        
        }
        Test.stopTest();
    } 
    // Scenario: More than two lines
    static testMethod void testMethod4() {
        Test.startTest();
        testData = phss_cc_TestDataFactory.setupAccountAndProducts(); 
		testAccount = (Account) testData.get(phss_cc_TestDataFactory.TEST_ACCOUNT);
        testAccount.BillingStreet = '01234' + '\n' + '01234' + '\n' + '01234';
        try {
            if(Test.isRunningTest()) {
                // Cause DMLException
                update testAccount;
            }        
        } catch (DMLException ex) {
            // Existing exception handling.        
        }
        Test.stopTest();
    } 
    
}