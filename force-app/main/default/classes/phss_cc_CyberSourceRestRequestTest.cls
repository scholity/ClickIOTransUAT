/**
 * Created by jbarker on 2019-11-07.
 */

@IsTest
public with sharing class phss_cc_CyberSourceRestRequestTest {

    private static final String TEST_HOST = 'http://www.test.com/';
    private static final String TEST_PATH = '/test/{id}/path';
    private static final String TEST_MERCHANT_ID = '0123456789';
    private static final String TEST_SERIAL_NUMBER = '9876543210';
    private static final String TEST_SECRET_KEY = '0000000001';
    private static final Map<String, Object> TEST_MESSAGE_BODY = new Map<String, Object>{ 'TestKey1' => 'TestValue1' };

    private static phss_cc_CyberSourceRestRequest testCyberSourceRequest;


    private static void setupTestData() {
        testCyberSourceRequest = new phss_cc_CyberSourceRestRequest();
        testCyberSourceRequest.host = TEST_HOST;
        testCyberSourceRequest.path = TEST_PATH;
        testCyberSourceRequest.merchantId = TEST_MERCHANT_ID;
        testCyberSourceRequest.serialNumber = TEST_SERIAL_NUMBER;
        testCyberSourceRequest.secretKey = TEST_SECRET_KEY;
        testCyberSourceRequest.messageBody = TEST_MESSAGE_BODY;
    }


    @IsTest
    public static void testCreateHttpRequest() {

        setupTestData();

        try {
            HttpRequest request = testCyberSourceRequest.createHttpRequest();
            System.assertEquals(TEST_MERCHANT_ID, request.getHeader('v-c-merchant-id'));
            System.assertEquals(TEST_HOST, request.getHeader('Host'));

        } catch (Exception e) {
            System.assert(false, 'Exception thrown while creating the HTTP request: ' + e.getMessage());
        }
    }

    @IsTest
    public static void testCreateHttpRequestWithMissingHost() {

        setupTestData();
        testCyberSourceRequest.host = null;
        Boolean didThrowException = false;

        try {
            testCyberSourceRequest.createHttpRequest();

        } catch (Exception e) {
            if (e.getMessage() == phss_cc_CyberSourceRestRequest.MISSING_HOST) {
                didThrowException = true;
            }
        }

        System.assert(didThrowException, 'Failed to throw exception for missing host');
    }

    @IsTest
    public static void testCreateHttpRequestWithMissingPath() {

        setupTestData();
        testCyberSourceRequest.path = null;
        Boolean didThrowException = false;

        try {
            testCyberSourceRequest.createHttpRequest();

        } catch (Exception e) {
            if (e.getMessage() == phss_cc_CyberSourceRestRequest.MISSING_PATH) {
                didThrowException = true;
            }
        }

        System.assert(didThrowException, 'Failed to throw exception for missing path');
    }

    @IsTest
    public static void testCreateHttpRequestWithMissingMerchantId() {

        setupTestData();
        testCyberSourceRequest.merchantId = null;
        Boolean didThrowException = false;

        try {
            testCyberSourceRequest.createHttpRequest();

        } catch (Exception e) {
            if (e.getMessage() == phss_cc_CyberSourceRestRequest.MISSING_MERCHANT_ID) {
                didThrowException = true;
            }
        }

        System.assert(didThrowException, 'Failed to throw exception for missing merchant ID');
    }

    @IsTest
    public static void testCreateHttpRequestWithMissingSerialNumber() {

        setupTestData();
        testCyberSourceRequest.serialNumber = null;
        Boolean didThrowException = false;

        try {
            testCyberSourceRequest.createHttpRequest();

        } catch (Exception e) {
            if (e.getMessage() == phss_cc_CyberSourceRestRequest.MISSING_SERIAL_NUMBER) {
                didThrowException = true;
            }
        }

        System.assert(didThrowException, 'Failed to throw exception for missing serial number');
    }

    @IsTest
    public static void testCreateHttpRequestWithMissingSecretKey() {

        setupTestData();
        testCyberSourceRequest.secretKey = null;
        Boolean didThrowException = false;

        try {
            testCyberSourceRequest.createHttpRequest();

        } catch (Exception e) {
            if (e.getMessage() == phss_cc_CyberSourceRestRequest.MISSING_SECRET_KEY) {
                didThrowException = true;
            }
        }

        System.assert(didThrowException, 'Failed to throw exception for missing secret key');
    }

    @IsTest
    public static void testCreateHttpRequestWithMissingMessageBody() {

        setupTestData();
        testCyberSourceRequest.messageBody = null;
        Boolean didThrowException = false;

        try {
            testCyberSourceRequest.createHttpRequest();

        } catch (Exception e) {
            if (e.getMessage() == phss_cc_CyberSourceRestRequest.MISSING_MESSAGE_BODY) {
                didThrowException = true;
            }
        }

        System.assert(didThrowException, 'Failed to throw exception for missing message body');
    }
}