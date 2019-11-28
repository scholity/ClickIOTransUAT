/**
 * Created by jbarker on 2019-11-12.
 */

@IsTest
public with sharing class phss_cc_CyberSourceCaptureUtilTest {

    private static ccrz__E_TransactionPayment__c testTransactionPayment;
    private static Fulfillment__c testFulfillment;


    private static void setupTestData() {
        PHSS_TriggerSettings__c settings = PHSS_TriggerSettings__c.getOrgDefaults();
        settings.FulfillmentTriggerDisabled__c = true;
        upsert settings PHSS_TriggerSettings__c.Id;

        Map<String, Object> testData = phss_cc_TestDataFactory.setupAccountAndProducts();
        Account account = (Account) testData.get(phss_cc_TestDataFactory.TEST_ACCOUNT);
        Opportunity opportunity = phss_cc_TestDataFactory.createInsertTestOpportunity(account);

        phss_cc_TestDataFactory.createInsertCartAndCartItems(1, testData, opportunity.Id);

        ccrz__E_Order__c order = new ccrz__E_Order__c(
                NSSCCConnector_SFCC_Order_Number__c = '3114226',
                NSSCCConnector_from_SFCC__c = true,
                ccrz__Account__c = account.Id,
                ccrz__Storefront__c = phss_cc_TestDataFactory.TEST_STOREFRONT
        );
        insert order;

        testTransactionPayment = new ccrz__E_TransactionPayment__c(
                ccrz__Account__c = account.Id,
                ccrz__AccountType__c = phss_cc_TransactionPaymentUtil.CREDIT_CARD_PAYMENT_TYPE,
                ccrz__Amount__c = 10,
                ccrz__CCOrder__c = order.Id,
                ccrz__CurrencyISOCode__c = phss_cc_TestDataFactory.TEST_CURRENCY_CODE,
                ccrz__Token__c = phss_cc_TestDataFactory.TEST_AUTH_TXN_PMT_TOKEN,
                ccrz__TransactionType__c = phss_cc_TransactionPaymentUtil.AUTH_TRANSACTION_TYPE,
                ccrz__TransactionPaymentId__c = '0123456789'
        );
        insert testTransactionPayment;

        testFulfillment = new Fulfillment__c(
                Type__c = 'Invoice',
                Status__c = 'Open',
                Order__c = order.Id,
                CC_Transaction_Payment__c = testTransactionPayment.Id
        );
        insert testFulfillment;
    }


    private static String createMockResponse() {
        Map<String, Object> responseMap = new Map<String, Object>{
                'clientReferenceInformation' => new Map<String, Object> {
                        'code' => 'TP-TEST'
                },
                'id' => '0000000000000000000001',
                'orderInformation' => new Map<String, Object>{
                        'amountDetails' => new Map<String, Object>{
                                'currency' => 'USD',
                                'totalAmount' => (Decimal) 401.54
                        }
                },
                'reconciliationId' => '0000000000000001',
                'status' => 'PENDING',
                'submitTimeUtc' => '2019-11-09T00:11:24Z',
                '_links' => new Map<String, Object> {
                        'refund' => new Map<String, Object>{
                                'href' => '/pts/v2/captures/5732582844156900703003/refunds',
                                'method' => 'POST'
                        },
                        'self' => new Map<String, Object>{
                                'href' => '/pts/v2/captures/0000000000000000000001',
                                'method' => 'GET'
                        },
                        'void' => new Map<String, Object>{
                                'href' => '/pts/v2/captures/0000000000000000000001/voids',
                                'method' => 'POST'
                        }
                }
        };
        return JSON.serialize(responseMap);
    }


    @IsTest
    static void testPrepareForPaymentCapture() {

        setupTestData();

        Test.startTest();
        ccrz__E_TransactionPayment__c capture = phss_cc_CyberSourceCaptureUtil.prepareForPaymentCapture(testFulfillment.Id);
        Test.stopTest();
    }


    @IsTest
    static void testCapturePayment() {

        phss_cc_CyberSourceRestApiUtilTest.setupTestConfigurationSettings(phss_cc_TestDataFactory.TEST_STOREFRONT);

        setupTestData();
        ccrz__E_TransactionPayment__c captureTransactionPayment = phss_cc_CyberSourceCaptureUtil.prepareForPaymentCapture(testFulfillment.Id);

        phss_cc_CyberSourceRestRequestMock mockClass = new phss_cc_CyberSourceRestRequestMock();
        mockClass.responseStr = createMockResponse();
        Test.setMock(HttpCalloutMock.class, mockClass);

        Test.startTest();
        phss_cc_CyberSourceCaptureUtil.capturePayment(testFulfillment.Id);
        Test.stopTest();
    }


    @IsTest
    static void testLogError() {

        setupTestData();

        Test.startTest();
        phss_cc_CyberSourceCaptureUtil.logError(testFulfillment.Id, 'Test Error');
        Test.stopTest();
    }
}