/**
 * Created by jbarker on 2019-03-08.
 */

public with sharing class phss_cc_CyberSourceCreditUtil {

    // CC Module and Settings keys
    private static final String CS_MODULE_NAME          = 'pgcsc';
    private static final String CS_REFUND_ENDPOINT_KEY  = CS_MODULE_NAME + '.urlrefund';
    private static final String CS_MERCHANT_ID_KEY      = CS_MODULE_NAME + '.merchantidentifier';
    private static final String CS_SERIAL_NUMBER_KEY    = CS_MODULE_NAME + '.serialnumber';
    private static final String CS_SECRET_KEY_KEY       = CS_MODULE_NAME + '.secretkey';

    @TestVisible private static String HOST;
    @TestVisible private static String PATH;
    @TestVisible private static String MERCHANT_ID;
    @TestVisible private static String SERIAL_NUMBER;
    @TestVisible private static String SECRET_KEY;

    // Header keys
    private static final String DIGEST_KEY = 'digest';
    private static final String HOST_KEY = 'host';
    private static final String MERCHANT_KEY = 'v-c-merchant-id';
    private static final String REQUEST_TARGET_KEY = '(request-target)';

    // Algorithms
    private static final String DIGEST_ALGORITHM = 'SHA-256';
    private static final String MAC_ALGORITHM = 'hmacSHA256';
    private static final String SIGNATURE_ALGORITHM_NAME = 'HmacSHA256';

    // Object Map keys
    @TestVisible private static final String CURRENCY_CODE_KEY = 'currencyCode';
    private static final String ORDER_KEY = 'order';
    private static final String STOREFRONT_KEY = 'storefront';
    @TestVisible private static final String TRANSACTION_PAYMENT_AMOUNT_KEY = 'transactionPaymentAmount';
    private static final String TRANSACTION_PAYMENT_ID_KEY = 'transactionPaymentId';
    @TestVisible private static final String TRANSACTION_PAYMENT_NAME_KEY = 'transactionPaymentName';
    @TestVisible private static final String TRANSACTION_REFERENCE_ID_KEY = 'transactionReferenceId';
    @TestVisible private static final String TRANSACTION_TIMESTAMP_KEY = 'transactionTimestamp';

    private static final String TRANS_REF_ID_PLACEHOLDER = '{id}';

    private static final Integer HTTP_STATUS_CODE_CREATED = 201;

    // Response keys
    @TestVisible private static final String REFUND_AMOUNT_DETAILS_KEY = 'refundAmountDetails';
    @TestVisible private static final String REFUND_AMOUNT_KEY = 'refundAmount';
    @TestVisible private static final String TRANSACTION_ID_KEY = 'id';
    @TestVisible private static final String SUBMIT_TIME_UTC_KEY = 'submitTimeUtc';

    // Error messages
    private static final String FAILED_TO_FETCH_FULFILLMENT = 'Failed to fetch fulfillment.';
    private static final String FAILED_TO_FETCH_FULFILLMENT_ORDER_STOREFRONT = 'Failed to fetch the storefront from the fulfillment order.';
    private static final String FAILED_TO_GET_FULFILLMENT_DATA = 'Failed to get the fulfillment data.';
    private static final String FAILED_TO_GET_TRANSACTION_PAYMENT_DATA = 'Failed to get transaction payment data.';
    private static final String FAILED_TO_LOAD_CYBER_SOURCE_CONFIGS = 'Failed to load configurations.';
    private static final String FAILED_TO_SAVE_REFUND_CAPTURE_RESPONSE = 'Failed to save refund capture response.';
    private static final String INVALID_TRANSACTION_PAYMENT_AMOUNT = 'Invalid transaction payment amount';
    private static final String MALFORMED_REFUND_ENDPOINT_URL = 'Malformed URL for CyberSource REST API Endpoint: Refund.';
    private static final String MISSING_CURRENCY_CODE = 'Missing currency code.';
    private static final String MISSING_HOST = 'Missing host.';
    private static final String MISSING_MERCHANT_ID = 'Missing value for CyberSource REST API Merchant Identifier';
    private static final String MISSING_PARENT_TRANSACTION_PAYMENT = 'Missing parent transaction payment';
    private static final String MISSING_REFUND_ENDPOINT = 'Missing value for CyberSource REST API Endpoint: Refund.';
    private static final String MISSING_SECRET_KEY = 'Missing value for CyberSource REST API Secret Key.';
    private static final String MISSING_SERIAL_NUMBER = 'Missing value for CyberSource REST API Serial Number.';
    private static final String MISSING_TRANSACTION_PAYMENT_AMOUNT = 'Missing transaction payment amount.';
    private static final String MISSING_TRANSACTION_PAYMENT_ID = 'Missing transaction payment identifier';
    private static final String MISSING_TRANSACTION_PAYMENT_NAME = 'Missing transaction payment name.';
    private static final String MISSING_TRANSACTION_REFERENCE_ID = 'Missing transaction reference identifier.';
    private static final String MISSING_TRANS_REF_ID_PLACEHOLDER = 'Missing placeholder for transaction reference identifier.';
    private static final String MISSING_URL_PATH = 'Missing URL path.';
    private static final String MISSING_VALUE_FOR_REQUIRED_KEY = 'Missing value for required key';
    private static final String UNEXPECTED_REFUND_CAPTURE_RESPONSE = 'Unexpected refund capture response';


    @Future (Callout=true)
    public static void creditFulfillment(String fulfillmentId) {

        try {
            Map<String, Object> objectMap = new Map<String, Object>();
            getFulfillmentData(fulfillmentId, objectMap);

            String orderId = (String) objectMap.get(ORDER_KEY);
            getTransactionPaymentDataForOrder(orderId, objectMap);

            String storefront = (String) objectMap.get(STOREFRONT_KEY);
            loadCyberSourceConfigurations(storefront);

            HttpRequest request = buildRefundRequest(objectMap);
            try {
                Http http = new Http();
                HttpResponse response = http.send(request);
                if (response.getStatusCode() == HTTP_STATUS_CODE_CREATED) {
                    Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                    String transactionPaymentId = (String) objectMap.get(TRANSACTION_PAYMENT_ID_KEY);
                    saveRefundCapture(data, transactionPaymentId);
                    phss_cc_FulfillmentUtil.completeFulfillment(fulfillmentId, null);
                }
                else {
                    System.debug('UNEXPECTED RESPONSE: ' + response.getStatusCode() + ' ' + response.getStatus());
                    System.debug('response headers');
                    List<String> headers = response.getHeaderKeys();
                    for (String header : headers) {
                        System.debug(header + '=' + response.getHeader(header));
                    }
                    System.debug('response body: ' + response.getBody());
                    throw new phss_cc_Exception(UNEXPECTED_REFUND_CAPTURE_RESPONSE);
                }

            } catch (Exception e) {
                System.debug('Exception caught: ' + e.getMessage());
            }

        } catch (Exception e) {
            System.debug('Exception caught: ' + e.getMessage());
            throw e;
        }
    }

	@testVisible
    private static void saveRefundCapture(Map<String, Object> data, String sourceTransactionPaymentId) {
        try {
            Map<String, Object> refundAmountDetails = (Map<String, Object>) data.get(REFUND_AMOUNT_DETAILS_KEY);
            Decimal refundAmount = Decimal.valueOf((String) refundAmountDetails.get(REFUND_AMOUNT_KEY));

            ccrz__E_TransactionPayment__c authTxn = phss_cc_TransactionPaymentUtil.fetchTransactionPayment(sourceTransactionPaymentId);
            ccrz__E_TransactionPayment__c captureTxn = new ccrz__E_TransactionPayment__c();
            captureTxn.ccrz__Account__c = authTxn.ccrz__Account__c;
            captureTxn.ccrz__AccountType__c = authTxn.ccrz__AccountType__c;
            captureTxn.ccrz__Amount__c = authTxn.ccrz__Amount__c;
            captureTxn.ccrz__CCOrder__c = authTxn.ccrz__CCOrder__c;
            captureTxn.ccrz__InvoiceAppliedFor__c = authTxn.ccrz__InvoiceAppliedFor__c;
            captureTxn.ccrz__PaymentType__c = authTxn.ccrz__PaymentType__c;
            captureTxn.ccrz__RequestAmount__c = refundAmount;
            captureTxn.ccrz__SourceTransactionPayment__c = authTxn.Id;
            captureTxn.ccrz__Storefront__c = authTxn.ccrz__Storefront__c;
            captureTxn.ccrz__TransactionPaymentId__c = (String) data.get(TRANSACTION_ID_KEY);
            captureTxn.ccrz__TransactionTS__c = DatetimeUtil.parse((String) data.get(SUBMIT_TIME_UTC_KEY), DatetimeUtil.format.YYYY_MM_DDTHH_MM_SSZ);
            captureTxn.ccrz__TransactionType__c = phss_cc_TransactionPaymentUtil.CAPTURE_TRANSACTION_TYPE;

            insert captureTxn;
		
        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_SAVE_REFUND_CAPTURE_RESPONSE, e);
        }
    }


    private static Fulfillment__c fetchFulfillment(String fulfillmentId) {
        return [
                SELECT Id,
                        Order__r.ccrz__Storefront__c,
                        CC_Transaction_Payment__c,
                        CC_Transaction_Payment__r.ccrz__Amount__c,
                        CC_Transaction_Payment__r.ccrz__CurrencyISOCode__c,
                        CC_Transaction_Payment__r.ccrz__ParentTransactionPayment__r.ccrz__CCOrder__c
                FROM Fulfillment__c
                WHERE Id = :fulfillmentId
        ];
    }


    /**
     * @description Obtains transaction payment name and reference Id from transaction payments related to an order
     *
     * The Name of the AUTH transaction is fetched. The Transaction Reference Id from the CAPTURE is fetched. Both are
     * REQUIRED for creating a CyberSource Credit request.
     *
     * @param orderId
     * @param objectMap
     */
    @TestVisible
    private static void getTransactionPaymentDataForOrder(String orderId, Map<String, Object> objectMap) {
        try {
            List<ccrz__E_TransactionPayment__c> transactionPayments = [
                    SELECT Id, ccrz__TransactionPaymentId__c, ccrz__TransactionType__c, Name
                    FROM ccrz__E_TransactionPayment__c
                    WHERE ccrz__CCOrder__c = :orderId
            ];

            for (ccrz__E_TransactionPayment__c tp : transactionPayments) {
                if (phss_cc_TransactionPaymentUtil.isAuthTransaction(tp)) {
                    objectMap.put(TRANSACTION_PAYMENT_NAME_KEY, tp.Name);
                }
                else if (phss_cc_TransactionPaymentUtil.isCaptureTransaction(tp)) {
                    objectMap.put(TRANSACTION_REFERENCE_ID_KEY, tp.ccrz__TransactionPaymentId__c);
                }
            }

            if (String.isBlank((String) objectMap.get(TRANSACTION_PAYMENT_NAME_KEY))) {
                throw new phss_cc_Exception(MISSING_TRANSACTION_PAYMENT_NAME);
            }
            if (String.isBlank((String) objectMap.get(TRANSACTION_REFERENCE_ID_KEY))) {
                throw new phss_cc_Exception(MISSING_TRANSACTION_REFERENCE_ID);
            }

        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_GET_TRANSACTION_PAYMENT_DATA, e);
        }
    }


    @TestVisible
    private static void getFulfillmentData(String fulfillmentId, Map<String, Object> objectMap) {
        try {
            Fulfillment__c fulfillment = fetchFulfillment(fulfillmentId);
            if (fulfillment == null) {
                throw new phss_cc_Exception(FAILED_TO_FETCH_FULFILLMENT);
            }
            if (String.isBlank(fulfillment.Order__r.ccrz__Storefront__c)) {
                throw new phss_cc_Exception(FAILED_TO_FETCH_FULFILLMENT_ORDER_STOREFRONT);
            }
            if (String.isBlank(fulfillment.CC_Transaction_Payment__c)) {
                throw new phss_cc_Exception(MISSING_TRANSACTION_PAYMENT_ID);
            }
            if (fulfillment.CC_Transaction_Payment__r.ccrz__Amount__c == null) {
                throw new phss_cc_Exception(MISSING_TRANSACTION_PAYMENT_AMOUNT);
            }
            if (fulfillment.CC_Transaction_Payment__r.ccrz__Amount__c >= 0) {
                throw new phss_cc_Exception(INVALID_TRANSACTION_PAYMENT_AMOUNT + ': ' + fulfillment.CC_Transaction_Payment__r.ccrz__Amount__c);
            }
            if (String.isBlank(fulfillment.CC_Transaction_Payment__r.ccrz__CurrencyISOCode__c)) {
                throw new phss_cc_Exception(MISSING_CURRENCY_CODE);
            }
            if (String.isBlank(fulfillment.CC_Transaction_Payment__r.ccrz__ParentTransactionPayment__r.ccrz__CCOrder__c)) {
                throw new phss_cc_Exception(MISSING_PARENT_TRANSACTION_PAYMENT);
            }

            objectMap.put(STOREFRONT_KEY, fulfillment.Order__r.ccrz__Storefront__c);
            objectMap.put(TRANSACTION_PAYMENT_ID_KEY, fulfillment.CC_Transaction_Payment__c);
            objectMap.put(TRANSACTION_PAYMENT_AMOUNT_KEY, fulfillment.CC_Transaction_Payment__r.ccrz__Amount__c);
            objectMap.put(CURRENCY_CODE_KEY, fulfillment.CC_Transaction_Payment__r.ccrz__CurrencyISOCode__c);
            objectMap.put(ORDER_KEY, fulfillment.CC_Transaction_Payment__r.ccrz__ParentTransactionPayment__r.ccrz__CCOrder__c);

        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_GET_FULFILLMENT_DATA, e);
        }
    }


    @TestVisible
    private static void loadCyberSourceConfigurations(String storefront) {
        try {
            Map<String, Object> configs = phss_cc_CyberSourceUtil.getConfigurations(CS_MODULE_NAME, storefront);

            // Endpoint: Refund
            String refundURL = (String) configs.get(CS_REFUND_ENDPOINT_KEY);
            if (String.isBlank(refundURL)) {
                throw new phss_cc_Exception(MISSING_REFUND_ENDPOINT);
            }
            String protocol = 'https://';
            if (!refundURL.startsWithIgnoreCase(protocol)) {
                throw new phss_cc_Exception(MALFORMED_REFUND_ENDPOINT_URL);
            }
            refundURL = refundURL.removeStartIgnoreCase(protocol);
            String[] components = refundURL.split('/', 2);
            if (components.size() != 2) {
                throw new phss_cc_Exception(MALFORMED_REFUND_ENDPOINT_URL);
            }

            HOST = components[0];
            if (String.isBlank(HOST)) {
                throw new phss_cc_Exception(MISSING_HOST);
            }

            PATH = components[1];
            if (String.isBlank(PATH)) {
                throw new phss_cc_Exception(MISSING_URL_PATH);
            }
            if (!PATH.contains(TRANS_REF_ID_PLACEHOLDER)) {
                throw new phss_cc_Exception(MISSING_TRANS_REF_ID_PLACEHOLDER);
            }
            PATH = '/' + PATH;      // Restore '/' that was removed from split() above.



            // Merchant ID
            MERCHANT_ID = (String) configs.get(CS_MERCHANT_ID_KEY);
            if (String.isBlank(MERCHANT_ID)) {
                throw new phss_cc_Exception(MISSING_MERCHANT_ID);
            }

            // Serial Number
            SERIAL_NUMBER = (String) configs.get(CS_SERIAL_NUMBER_KEY);
            if (String.isBlank(SERIAL_NUMBER)) {
                throw new phss_cc_Exception(MISSING_SERIAL_NUMBER);
            }

            // Secret Key
            SECRET_KEY = (String) configs.get(CS_SECRET_KEY_KEY);
            if (String.isBlank(SECRET_KEY)) {
                throw new phss_cc_Exception(MISSING_SECRET_KEY);
            }

        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_LOAD_CYBER_SOURCE_CONFIGS, e);
        }
    }


    @TestVisible
    private static HttpRequest buildRefundRequest(Map<String, Object> objectMap) {

        String txnPmtName = (String) objectMap.get(TRANSACTION_PAYMENT_NAME_KEY);
        String currencyCode = (String) objectMap.get(CURRENCY_CODE_KEY);

        Decimal txnAmount = (Decimal) objectMap.get(TRANSACTION_PAYMENT_AMOUNT_KEY);
        txnAmount = txnAmount * -1;     // REVERSE THE SIGN to make the amount a positive number

        Map<String, Object> messageContent = createMessageBody(txnPmtName, txnAmount, currencyCode);
        String message = JSON.serialize(messageContent);
        String digest = generateDigest(message);


        String requestId = (String) objectMap.get(TRANSACTION_REFERENCE_ID_KEY);
        PATH = PATH.replace(TRANS_REF_ID_PLACEHOLDER, requestId);

        String requestTarget = 'post ' + PATH;

        String timestamp = (String) objectMap.get(TRANSACTION_TIMESTAMP_KEY);
        if (String.isBlank(timestamp)) {
            timestamp = Datetime.now().formatGmt('EEE, dd MMM yyyy HH:mm:ss') + ' GMT';
        }

        List<String> keys = new List<String>{HOST_KEY, REQUEST_TARGET_KEY, DIGEST_KEY, MERCHANT_KEY};
        Map<String, Object> properties = new Map<String, Object>{
                HOST_KEY => HOST,
                REQUEST_TARGET_KEY => requestTarget,
                DIGEST_KEY => digest,
                MERCHANT_KEY => MERCHANT_ID
        };

        String signableData = generateSignableData(keys, properties);
        String signature = generateSignature(signableData);
        String signatureHeader = 'keyid="' + SERIAL_NUMBER + '", algorithm="' + SIGNATURE_ALGORITHM_NAME + '", headers="' + String.join(keys, ' ') + '", signature="' + signature + '"';

        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:CyberSource_REST_API_Endpoint' + PATH);
        request.setMethod('POST');
        request.setHeader('v-c-merchant-id', MERCHANT_ID);
        request.setHeader('v-c-date', timestamp);
        request.setHeader('Host', HOST);
        request.setHeader('Digest', digest);
        request.setHeader('Signature', signatureHeader);
        request.setHeader('Content-Type', 'application/json');
        request.setBody(message);

        return request;
    }


    @TestVisible
    private static String generateSignableData(List<String> keys, Map<String, Object> properties) {
        List<String> kvPairs = new List<String>();
        for (String key : keys) {
            if (properties.keySet().contains(key)) {
                kvPairs.add(key + ': ' + properties.get(key));
            }
            else {
                throw new phss_cc_Exception(MISSING_VALUE_FOR_REQUIRED_KEY + ': key=' + key);
            }
        }
        return String.join(kvPairs, '\n');
    }


    @TestVisible
    private static String generateSignature(String data) {
        Blob signedData = Crypto.generateMac(MAC_ALGORITHM, Blob.valueOf(data), EncodingUtil.base64Decode(SECRET_KEY));
        return EncodingUtil.base64Encode(signedData);
    }


    @TestVisible
    private static String generateDigest(String message) {
        Blob digest = Crypto.generateDigest(DIGEST_ALGORITHM, Blob.valueOf(message));
        return DIGEST_ALGORITHM + '=' + EncodingUtil.base64Encode(digest);
    }


    @TestVisible
    private static Map<String, Object> createMessageBody(String transactionPaymentName, Decimal amount, String currencyCode) {
        Map<String, Object> messageBody = new Map<String, Object>{
                'clientReferenceInformation' => new Map<String, String>{
                        'code' => transactionPaymentName
                },
                'orderInformation' => new Map<String, Object>{
                        'amountDetails' => new Map<String, Object>{
                                'totalAmount' => amount,
                                'currency' => currencyCode
                        }
                }
        };

        return messageBody;
    }
}