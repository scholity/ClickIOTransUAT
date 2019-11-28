/**
 * Created by jbarker on 2019-11-06.
 */

public with sharing class phss_cc_CyberSourceCaptureUtil {

    // Object Map keys
    @TestVisible private static final String CURRENCY_CODE_KEY = 'currencyCode';
    private static final String ORDER_KEY = 'order';
    private static final String STOREFRONT_KEY = 'storefront';
    @TestVisible private static final String AUTH_TRANSACTION_PAYMENT_ID_KEY = 'authorizationTransactionPaymentId';
    @TestVisible private static final String CAPTURE_TRANSACTION_PAYMENT_ID_KEY = 'captureTransactionPaymentId';
    @TestVisible private static final String TRANSACTION_PAYMENT_AMOUNT_KEY = 'transactionPaymentAmount';
    @TestVisible private static final String TRANSACTION_PAYMENT_NAME_KEY = 'transactionPaymentName';
    @TestVisible private static final String TRANSACTION_REFERENCE_ID_KEY = 'transactionReferenceId';
    @TestVisible private static final String TRANSACTION_TIMESTAMP_KEY = 'transactionTimestamp';

    private static final Integer HTTP_STATUS_CODE_CREATED = 201;
    private static final Integer HTTP_STATUS_CODE_INVALID_REQUEST = 400;
    private static final Integer HTTP_STATUS_CODE_UNEXPECTED_ERROR_OR_TIMEOUT = 502;

    // Response keys
    @TestVisible private static final String REFUND_AMOUNT_DETAILS_KEY = 'refundAmountDetails';
    @TestVisible private static final String REFUND_AMOUNT_KEY = 'refundAmount';
    @TestVisible private static final String TRANSACTION_ID_KEY = 'id';
    @TestVisible private static final String SUBMIT_TIME_UTC_KEY = 'submitTimeUtc';

    // Error messages
    private static final String FAILED_TO_PREPARE_CAPTURE_TRANSACTION_PAYMENT = 'Failed to prepare capture transaction payment.';
    private static final String FAILED_TO_FETCH_FULFILLMENT = 'Failed to fetch fulfillment.';
    private static final String FAILED_TO_FETCH_FULFILLMENT_ORDER_STOREFRONT = 'Failed to fetch the storefront from the fulfillment order.';
    private static final String FAILED_TO_FETCH_CAPTURE_TRANSACTION_PAYMENT = 'Failed to fetch the capture transaction payment.';
    private static final String FAILED_TO_GET_FULFILLMENT_DATA = 'Failed to get the fulfillment data.';
    private static final String FAILED_TO_GET_CAPTURE_TRANSACTION_PAYMENT_ID = 'Failed to get capture transaction payment.';
    private static final String FAILED_TO_GET_TRANSACTION_PAYMENT_DATA = 'Failed to get transaction payment data.';
    private static final String FAILED_TO_GET_TRANSACTION_PAYMENT_DATA_FOR_CAPTURE_REQUEST = 'Failed to get transaction payment data for capture request.';
    private static final String FAILED_TO_INITIALIZE_REFUND_TRANSACTION_PAYMENT = 'Failed to initialize refund transaction payment.';
    private static final String FAILED_TO_LOAD_CYBER_SOURCE_CONFIGS = 'Failed to load configurations.';
    private static final String FAILED_TO_SAVE_REFUND_CAPTURE_RESPONSE = 'Failed to save refund capture response.';
    private static final String INVALID_TRANSACTION_PAYMENT_AMOUNT = 'Invalid transaction payment amount';
    private static final String MISSING_AMOUNT = 'Missing amount.';
    private static final String MISSING_CURRENCY_CODE = 'Missing currency code.';
    private static final String MISSING_PARENT_TRANSACTION_PAYMENT = 'Missing parent transaction payment';
    private static final String MISSING_STOREFRONT = 'Missing storefront.';
    private static final String MISSING_TRANSACTION_PAYMENT_AMOUNT = 'Missing transaction payment amount.';
    private static final String MISSING_TRANSACTION_PAYMENT_ID = 'Missing transaction payment identifier';
    private static final String MISSING_TRANSACTION_PAYMENT_NAME = 'Missing transaction payment name.';
    private static final String MISSING_TRANSACTION_REFERENCE_ID = 'Missing transaction reference identifier.';
    private static final String UNEXPECTED_REFUND_CAPTURE_RESPONSE = 'Unexpected refund capture response';



    @Future (Callout=true)
    public static void capturePayment(String fulfillmentId) {

        try {
            Map<String, Object> data = getTransactionPaymentDataForCaptureRequest(fulfillmentId);

            String storefront = (String) data.get(STOREFRONT_KEY);
            Map<String, Object> settings = phss_cc_CyberSourceRestApiUtil.getCaptureConfigurationSettings(storefront);
            phss_cc_CyberSourceRestRequest cyberSource = createCyberSourceRestRequest(data, settings);

            HttpRequest request = cyberSource.createHttpRequest();
            Http http = new Http();
            HttpResponse response = http.send(request);
            Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

            /*

            'responseBody' keys and values

            clientReferenceInformation: {code=TP-0000002698}
            id: 						5732582844156900703003
            orderInformation: 			{amountDetails={currency=USD, totalAmount=401.54}}
            reconciliationId: 			71177833F2D6CRQH
            status: 					PENDING
            submitTimeUtc: 				2019-11-09T00:11:24Z
            _links: 					{refund={href=/pts/v2/captures/5732582844156900703003/refunds, method=POST}, self={href=/pts/v2/captures/5732582844156900703003, method=GET}, void={href=/pts/v2/captures/5732582844156900703003/voids, method=POST}}

             */

            if (response.getStatusCode() == HTTP_STATUS_CODE_CREATED) {

                Map<String, Object> orderInformation = (Map<String, Object>) responseBody.get('orderInformation');
                Map<String, Object> amountDetails = (Map<String, Object>) orderInformation.get('amountDetails');
                String totalAmount = (String) amountDetails.get('totalAmount');

                String authTransactionPaymentId = (String) data.get(AUTH_TRANSACTION_PAYMENT_ID_KEY);
                String captureTransactionPaymentId = (String) data.get(CAPTURE_TRANSACTION_PAYMENT_ID_KEY);
                String externalCaptureTxnPmtId = (String) responseBody.get(TRANSACTION_ID_KEY);

                String submitTimeUTC = (String) responseBody.get(SUBMIT_TIME_UTC_KEY);

                phss_cc_FulfillmentUtil.finalizePayment(fulfillmentId, authTransactionPaymentId, captureTransactionPaymentId, externalCaptureTxnPmtId, Decimal.valueOf(totalAmount), submitTimeUTC);

            } else if (response.getStatusCode() == HTTP_STATUS_CODE_INVALID_REQUEST) {
                logError(fulfillmentId, 'status code for CyberSource CAPTURE: ' + response.getStatusCode());
            } else if (response.getStatusCode() == HTTP_STATUS_CODE_UNEXPECTED_ERROR_OR_TIMEOUT) {
                logError(fulfillmentId, 'status code for CyberSource CAPTURE: ' + response.getStatusCode());
            } else {
                logError(fulfillmentId, 'unknown status code for CyberSource CAPTURE: ' + response.getStatusCode() + '  response: ' + response.getBody());
            }

        } catch (Exception e) {
            logError(fulfillmentId, 'exception caught during CyberSource CAPTURE: ' + e.getMessage());
            System.debug('exception caught during CyberSource CAPTURE: ' + e.getMessage());
        }
    }

    @TestVisible
    private static Integration_Error_Log__c logError(String fulfillmentId, String description) {
        Fulfillment__c fulfillment = phss_cc_FulfillmentUtil.getFulfillment(fulfillmentId);
        Integration_Error_Log__c log = new Integration_Error_Log__c(
                Error_Details__c = 'Fulfillment__c.Id=' + fulfillmentId + ': ' + description,
                Status__c = 'Open'
        );
        insert log;
        return log;
    }

    /**
     * @description Prepares transaction payment records for capturing a payment
     *
     * @param fulfillmentId
     */
    public static ccrz__E_TransactionPayment__c prepareForPaymentCapture(String fulfillmentId) {

        ccrz__E_TransactionPayment__c captureTransactionPayment;

        try {

            ccrz__E_TransactionPayment__c authTransactionPayment = phss_cc_TransactionPaymentUtil.getTransactionPaymentForFulfillment(fulfillmentId);
            if (authTransactionPayment != null
                    && authTransactionPayment.ccrz__AccountType__c == phss_cc_TransactionPaymentUtil.CREDIT_CARD_PAYMENT_TYPE
                    && authTransactionPayment.ccrz__Amount__c > 0)
            {
                String accountId = authTransactionPayment.ccrz__Account__c;
                Boolean isIndividualAccount = phss_cc_AccountUtil.isIndividualAccount(accountId);
                if (isIndividualAccount) {
                    phss_cc_TransactionPaymentUtil.designateContactForTransactionPayment(authTransactionPayment);
                }

                captureTransactionPayment = phss_cc_TransactionPaymentUtil.createCaptureTransactionPaymentFromAuthTransactionPayment(authTransactionPayment.Id);
            }

        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_PREPARE_CAPTURE_TRANSACTION_PAYMENT, e);
        }

        return captureTransactionPayment;
    }


    // --  private functions ----------------------------------------------------------------------


    /**
     * @description
     *
     * @param data
     * @param settings
     *
     * @return
     */
    @TestVisible
    private static phss_cc_CyberSourceRestRequest createCyberSourceRestRequest(Map<String, Object> data, Map<String, Object> settings) {
        phss_cc_CyberSourceRestRequest request = new phss_cc_CyberSourceRestRequest();

        String path = (String) settings.get(phss_cc_CyberSourceRestApiUtil.CONFIG_PATH_KEY);
        String transactionId = (String) data.get(TRANSACTION_REFERENCE_ID_KEY);
        path = path.replace(phss_cc_CyberSourceRestApiUtil.URL_ID_PLACEHOLDER, transactionId);

        Decimal amount = (Decimal) data.get(TRANSACTION_PAYMENT_AMOUNT_KEY);
        String currencyCode = (String) data.get(CURRENCY_CODE_KEY);
        String transactionPaymentName = (String) data.get(TRANSACTION_PAYMENT_NAME_KEY);

        request.host = (String) settings.get(phss_cc_CyberSourceRestApiUtil.CONFIG_HOST_KEY);
        request.path = path;
        request.merchantId = (String) settings.get(phss_cc_CyberSourceRestApiUtil.CONFIG_MERCHANT_ID_KEY);
        request.serialNumber = (String) settings.get(phss_cc_CyberSourceRestApiUtil.CONFIG_SERIAL_NUMBER_KEY);
        request.secretKey = (String) settings.get(phss_cc_CyberSourceRestApiUtil.CONFIG_SECRET_KEY);
        request.messageBody = createMessageBody(transactionPaymentName, amount, currencyCode);

        return request;
    }


    /**
     * @description Creates a message body for a CyberSource REST capture request
     *
     * @param transactionPaymentName
     * @param amount
     * @param currencyCode
     *
     * @return
     */
    @TestVisible
    private static Map<String, Object> createMessageBody(String transactionPaymentName, Decimal amount, String currencyCode) {
        Map<String, Object> messageBody = new Map<String, Object>{
                'clientReferenceInformation' => new Map<String, String>{
                        'code' => transactionPaymentName
                },
                'processingInformation' => new Map<String, String>{
                        'reconciliationId' => transactionPaymentName.replaceAll('-', '')        // remove dash (-) per DE2025
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


    /**
     * @description Fetches the transaction payment data necessary for a CyberSource REST capture request
     *
     * @param fulfillmentId
     *
     * @return
     */
    @TestVisible
    private static Map<String, Object> getTransactionPaymentDataForCaptureRequest(String fulfillmentId) {

        Map<String, Object> data = new Map<String, Object>();

        try {

            // fetch data from AUTH transaction payment
            Id identifier = Id.valueOf(fulfillmentId);
            List<Fulfillment__c> fulfillments = [
                    SELECT
                            CC_Transaction_Payment__c,
                            CC_Transaction_Payment__r.ccrz__Amount__c,
                            CC_Transaction_Payment__r.ccrz__CurrencyISOCode__c,
                            CC_Transaction_Payment__r.ccrz__TransactionPaymentId__c,
                            Order__r.ccrz__Storefront__c
                    FROM
                            Fulfillment__c
                    WHERE
                            Id = :identifier
                    ORDER BY
                            CreatedDate DESC
            ];

            if (fulfillments == null || fulfillments.size() == 0) {
                throw new phss_cc_Exception(FAILED_TO_FETCH_FULFILLMENT);
            }

            Fulfillment__c fulfillment = fulfillments[0];
            if (fulfillment.CC_Transaction_Payment__r == null || fulfillment.CC_Transaction_Payment__r.ccrz__Amount__c == null) {
                throw new phss_cc_Exception(MISSING_AMOUNT);
            }
            if (fulfillment.CC_Transaction_Payment__r == null || fulfillment.CC_Transaction_Payment__r.ccrz__CurrencyISOCode__c == null) {
                throw new phss_cc_Exception(MISSING_CURRENCY_CODE);
            }
            if (fulfillment.CC_Transaction_Payment__r == null || fulfillment.CC_Transaction_Payment__r.ccrz__TransactionPaymentId__c == null) {
                throw new phss_cc_Exception(MISSING_TRANSACTION_PAYMENT_ID);
            }
            if (fulfillment.Order__r == null || fulfillment.Order__r.ccrz__Storefront__c == null) {
                throw new phss_cc_Exception(MISSING_STOREFRONT);
            }
            data.put(AUTH_TRANSACTION_PAYMENT_ID_KEY, fulfillment.CC_Transaction_Payment__c);
            data.put(TRANSACTION_PAYMENT_AMOUNT_KEY, fulfillment.CC_Transaction_Payment__r.ccrz__Amount__c);
            data.put(CURRENCY_CODE_KEY, fulfillment.CC_Transaction_Payment__r.ccrz__CurrencyISOCode__c);
            data.put(TRANSACTION_REFERENCE_ID_KEY, fulfillment.CC_Transaction_Payment__r.ccrz__TransactionPaymentId__c);
            data.put(STOREFRONT_KEY, fulfillment.Order__r.ccrz__Storefront__c);


            // fetch data from CAPTURE transaction payment
            identifier = fulfillment.CC_Transaction_Payment__c;
            List<ccrz__E_TransactionPayment__c> payments = [
                    SELECT
                            Id,
                            Name
                    FROM
                            ccrz__E_TransactionPayment__c
                    WHERE
                            ccrz__SourceTransactionPayment__c = :identifier
                            AND ccrz__TransactionType__c = :phss_cc_TransactionPaymentUtil.CAPTURE_TRANSACTION_TYPE
            ];

            if (payments == null || payments.size() == 0) {
                throw new phss_cc_Exception(FAILED_TO_FETCH_CAPTURE_TRANSACTION_PAYMENT);
            }

            ccrz__E_TransactionPayment__c payment = payments[0];
            if (String.isBlank(payment.Name)) {
                throw new phss_cc_Exception(MISSING_TRANSACTION_PAYMENT_NAME);
            }
            data.put(CAPTURE_TRANSACTION_PAYMENT_ID_KEY, payment.Id);
            data.put(TRANSACTION_PAYMENT_NAME_KEY, payment.Name);

        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_GET_TRANSACTION_PAYMENT_DATA_FOR_CAPTURE_REQUEST, e);
        }

        return data;
    }
}