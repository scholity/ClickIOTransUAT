/**
 * Created by jbarker on 2019-11-07.
 */

public with sharing class phss_cc_CyberSourceRestRequest {

    // Digital signing algorithms
    private static final String DIGEST_ALGORITHM            = 'SHA-256';
    private static final String MAC_ALGORITHM               = 'hmacSHA256';
    private static final String SIGNATURE_ALGORITHM_NAME    = 'HmacSHA256';

    // REST API request header keys
    private static final String HEADER_DIGEST_KEY           = 'digest';
    private static final String HEADER_HOST_KEY             = 'host';
    private static final String HEADER_MERCHANT_KEY         = 'v-c-merchant-id';
    private static final String HEADER_REQUEST_TARGET_KEY   = '(request-target)';

    public String host;
    public String path;
    public String merchantId;
    public String serialNumber;
    public String secretKey;

    public Map<String, Object> messageBody;

    // error messages
    private static final String MISSING_HOST = 'Missing host.';
    private static final String MISSING_MERCHANT_ID = 'Missing merchant identifier.';
    private static final String MISSING_MESSAGE_BODY = 'Missing message body.';
    private static final String MISSING_PATH = 'Missing path.';
    private static final String MISSING_SECRET_KEY = 'Missing secret key.';
    private static final String MISSING_SERIAL_NUMBER = 'Missing serial number.';
    private static final String MISSING_VALUE_FOR_REQUIRED_KEY = 'Missing value for required key';

    

    /**
     * @description Creates a HTTP request against the CyberSource REST API
     *
     * @return
     */
    public HttpRequest createHttpRequest() {

        validateRequestData();

        String message = JSON.serialize(messageBody);
        String digest = generateDigest(message);
        String requestTarget = 'post ' + path;
        String timestamp = Datetime.now().formatGmt('EEE, dd MMM yyyy HH:mm:ss') + ' GMT';


        List<String> keys = new List<String>{ HEADER_HOST_KEY, HEADER_REQUEST_TARGET_KEY, HEADER_DIGEST_KEY, HEADER_MERCHANT_KEY };
        Map<String, Object> properties = new Map<String, Object>{
                HEADER_HOST_KEY => host,
                HEADER_REQUEST_TARGET_KEY => requestTarget,
                HEADER_DIGEST_KEY => digest,
                HEADER_MERCHANT_KEY => merchantId
        };

        String signableData = generateSignableData(keys, properties);
        String signature = generateSignature(signableData);
        String signatureHeader = 'keyid="' + serialNumber + '", algorithm="' + SIGNATURE_ALGORITHM_NAME + '", headers="' + String.join(keys, ' ') + '", signature="' + signature + '"';

        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:CyberSource_REST_API_Endpoint' + path);
        request.setMethod('POST');
        request.setHeader('v-c-merchant-id', merchantId);
        request.setHeader('v-c-date', timestamp);
        request.setHeader('Host', host);
        request.setHeader('Digest', digest);
        request.setHeader('Signature', signatureHeader);
        request.setHeader('Content-Type', 'application/json');
        request.setBody(message);

        return request;
    }


    /**
     * @description Generates a digest of the message to be sent to CyberSource in the header of the request
     *
     * @param message
     *
     * @return
     */
    @TestVisible
    private static String generateDigest(String message) {
        Blob digest = Crypto.generateDigest(DIGEST_ALGORITHM, Blob.valueOf(message));
        return DIGEST_ALGORITHM + '=' + EncodingUtil.base64Encode(digest);
    }


    /**
     * @description Generates a string of data for digitally signing
     *
     * @param keys
     * @param properties
     *
     * @return
     */
    @TestVisible
    private String generateSignableData(List<String> keys, Map<String, Object> properties) {
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


    /**
     * @description Generates a digital signature
     *
     * @param data
     *
     * @return
     */
    @TestVisible
    private String generateSignature(String data) {
        Blob signedData = Crypto.generateMac(MAC_ALGORITHM, Blob.valueOf(data), EncodingUtil.base64Decode(secretKey));
        return EncodingUtil.base64Encode(signedData);
    }


    /**
     * @description Validates the required data for creating a request.
     */
    @TestVisible
    private void validateRequestData() {
        if (String.isBlank(host)) { throw new phss_cc_Exception(MISSING_HOST); }
        if (String.isBlank(path)) { throw new phss_cc_Exception(MISSING_PATH); }
        if (String.isBlank(merchantId)) { throw new phss_cc_Exception(MISSING_MERCHANT_ID); }
        if (String.isBlank(serialNumber)) { throw new phss_cc_Exception(MISSING_SERIAL_NUMBER); }
        if (String.isBlank(secretKey)) { throw new phss_cc_Exception(MISSING_SECRET_KEY); }
        if (messageBody == null || messageBody.keySet().size() == 0) { throw new phss_cc_Exception(MISSING_MESSAGE_BODY); }
    }

}