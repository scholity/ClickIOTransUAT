/**
 * Created by dgajwani on 9/28/18.
 */

public with sharing class phss_cc_CyberSourceUtil {

    // CyberSource Payment types
    private static final String VISA = 'Visa';
    private static final String AMERICAN_EXPRESS = 'American Express';
    private static final String MASTER_CARD = 'Mastercard';
    private static final String DISCOVER = 'Discover';

    // CyberSource Payment Type Codes
    private static final String PAYMENT_TYPE_VISA = '001';
    private static final String PAYMENT_TYPE_MASTERCARD = '002';
    private static final String PAYMENT_TYPE_AMERICAN_EXPRESS = '003';
    private static final String PAYMENT_TYPE_DISCOVER = '004';

    // CyberSource transaction types
    private static final String TRANSACTION_TYPE_CAPTURE = 'sale';

    // CyberSource response values
    private static final String SUCCESS_REASON_CODE = '100';

    // Form Data
    private static final String CART_ENCID_KEY = 'cartEncId';
    private static final String UTC_DATE_KEY = 'utcDate';
    private static final String TRANSACTION_ID_KEY = 'transactionId';
    private static final String CURRENCY_CODE_KEY = 'currencyCode';
    private static final String REFERENCE_NUMBER_KEY = 'referenceNumber';
    private static final String LOCALE_KEY = 'locale';
    private static final String TRANSACTION_TYPE_KEY = 'transactionType';
    private static final String AMOUNT_KEY = 'amount';
    private static final String RETURN_URL_KEY = 'returnURL';
    private static final String POST_URL_KEY = 'postURL';
    private static final String PROFILE_ID_KEY = 'profileId';
    private static final String ACCESS_KEY_MAPKEY = 'accessKey';
    private static final String PAYMENT_METHOD_KEY = 'paymentMethod';
    private static final String IGNORE_AVS_KEY = 'ignoreAvs';
    private static final String UNSIGNED_FIELDS_KEY = 'unsignedFields';
    private static final String FIRST_NAME_KEY = 'firstName';
    private static final String LAST_NAME_KEY = 'lastName';
    private static final String EMAIL_KEY = 'email';
    private static final String PHONE_NUMBER_KEY = 'phone';
    private static final String ACCOUNT_IDENTIFIER = 'accountId';
    private static final String ACCOUNT_CREATED_DATE = 'accountCreatedDate';
    private static final String ACCOUNT_LAST_MODIFIED_DATE = 'accountLastModifiedDate';
    private static final String BOOLEAN_TRUE = 'true';
    private static final String SIGNED_FIELDS_KEY = 'signedFields';
    private static final String STREET_KEY = 'street';
    private static final String CITY_KEY = 'city';
    private static final String STATE_KEY = 'state';
    private static final String COUNTRY_KEY = 'country';
    private static final String ZIPCODE_KEY = 'zipcode';
    private static final String PAYMENT_TYPES_KEY = 'paymentTypes';
    private static final String iFRAME_URL_KEY = 'iframeURL';
    private static final String IP_ADDRESS_KEY = 'ipAddr';

    // CyberSource Response Keys
    public static final String CYBER_SOURCE_AUTH_TIME_KEY = 'auth_time';
    public static final String CYBER_SOURCE_AUTH_AMOUNT_KEY = 'auth_amount';
    public static final String CYBER_SOURCE_REQ_AMOUNT_KEY = 'req_amount';
    public static final String CYBER_SOURCE_REQ_CARD_TYPE_KEY = 'req_card_type';
    public static final String CYBER_SOURCE_REQ_PAYMENT_TOKEN_KEY = 'req_payment_token';
    public static final String CYBER_SOURCE_REQUEST_TOKEN_KEY = 'request_token';
    public static final String CYBER_SOURCE_TRANSACTION_ID_KEY = 'transaction_id';
    public static final String CYBER_SOURCE_REASON_CODE_KEY = 'reason_code';
    public static final String CYBER_SOURCE_MESSAGE_KEY = 'message';

    // CyberSource Config Keys
    private static final String CYBER_SOURCE_CONFIG_TOKEN_URL_KEY = 'pgcs.urltokencreate';
    private static final String CYBER_SOURCE_CONFIG_TEST_URL = 'https://testsecureacceptance.cybersource.com/silent/pay';
    private static final String CYBER_SOURCE_CONFIG_AUTH_AMOUNT_KEY = 'pgcs.authamount';
    private static final String CYBER_SOURCE_CONFIG_ACCESSKEY_KEY = 'pgcs.accesskey';
    private static final String CYBER_SOURCE_CONFIG_PROFILE_ID_KEY = 'pgcs.profile';
    private static final String CYBER_SOURCE_CONFIG_SECRET_1_KEY = 'pgcs.secret1';
    private static final String CYBER_SOURCE_CONFIG_SECRET_2_KEY = 'pgcs.secret2';
    private static final String CYBER_SOURCE_CONFIG_PAYMENT_TYPES_KEY = 'pgcs.paymenttypes';

    //Misc
    private static final String NA_EMAIL = 'NA@NA.com';
    private static final String SALESFORCE_CLASSIC_DOMAIN = '.my.salesforce.com';
    private static final String VISUAL_FORCE_DOMAIN = '.visual.force.com';
    private static final String LIGHTNING_DOMAIN_NAME = '.lightning.force.com';
    private static final String CYBER_SOURCE_RESPONSE_SIGNED_FIELD_NAMES_KEY = 'signed_field_names';
    private static final String CYBER_SOURCE_RESPONSE_SIGNATURE_KEY = 'signature';
    private static final String FAILED_TO_CREDIT_TRANSACTION_PAYMENT = 'Failed to credit transaction payment';
    public static final String FAILED_TO_VERIFY_CYBERSOURCE_RESPONSE_SIGNATURE = 'Failed to verify Cybersource response signature.';
    private static final String FAILED_TO_VERIFY_CYBERSOURCE_PAYMENT_CAPTURE_RESPONSE = 'Failed to verify payment capture response';
    private static final String FAILED_TO_CAPTURE_PAYMENT_WITH_REASON_CODE = 'Failed to capture payment.';

    //CyberSource Config Settings.
    @TestVisible private static String ACCESS_KEY;
    @TestVisible private static String SECRET;
    @TestVisible private static String PROFILE_ID;
    @TestVisible private static String POST_URL;
    @TestVisible private static String RETURN_URL;
    @TestVisible private static String iFRAME_URL;
    @TestVisible private static String AUTH_AMOUNT;
    @TestVisible private static Map<String, Object> PAYMENT_TYPES;

    //FORM data Defaults
    private static final String DEFAULT_AUTH_AMOUNT = '1.00';
    private static final String DEFAULT_LOCALE = 'en-us';
    private static final String DEFAULT_CURRENCY_CODE = 'USD';
    private static final String ALGORITHM_NAME = 'hmacSHA256';
    private static final String TRANSACTION_TYPE_AUTH_AND_TOKEN = 'authorization,create_payment_token';
    private static final String PAYMENT_METHOD = 'card';
    private static final String UNSIGNED_FIELDS = 'bill_to_forename,bill_to_surname,bill_to_email,bill_to_address_line1,bill_to_address_city,bill_to_address_country,bill_to_address_state,bill_to_address_postal_code,bill_to_phone,card_number,card_expiry_date,card_cvn,card_type';

    // Cart Data
    @TestVisible private static String CART_ENC_ID;
    @TestVisible private static String STOREFRONT;
    @TestVisible private static String ACCT_ID;
    @TestVisible private static String ACCT_CREATED_DATE;
    @TestVisible private static String ACCT_LAST_MODIFIED_DATE;
    @TestVisible private static String IP_ADDRESS;
    @TestVisible private static String BILLING_CONTACT_FIRST_NAME;
    @TestVisible private static String BILLING_CONTACT_LAST_NAME;
    @TestVisible private static String BILLING_CONTACT_PHONE;
    @TestVisible private static String BILLING_CONTACT_EMAIL;
    @TestVisible private static String BILLING_STREET;
    @TestVisible private static String BILLING_CITY;
    @TestVisible private static String BILLING_STATE;
    @TestVisible private static String BILLING_COUNTRY;
    @TestVisible private static String BILLING_POSTAL_CODE;
    @TestVisible private static Decimal CART_TOTAL_AMOUNT;

    // Payment Capture
    public static final String PAYMENT_CAPTURE_RESPONSE = 'payment capture response';
    public static final String PAYMENT_CAPTURE_STATUS = 'payment capture status';
    public static final String PAYMENT_CAPTURE_SUCCEEDED = 'succeeded';
    public static final String PAYMENT_CAPTURE_FAILED = 'failed';
    public static final String REQUEST_STATUS = 'request status';
    public static final String REQUEST_STATUS_CODE = 'request status code';

    /**
     * Given a module and storefront return configuration store
     *
     * @param module
     * @param storefront
     *
     * @return
     */
    public static Map<String, Object> getConfigurations(final String module, final String storefront) {
        Map<String, Object> configs = new Map<String, Object>();
        final Map<String, Object> input = new Map<String, Object>{
                ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
                ccrz.ccAPIConfig.STORE_NAME => storefront,
                ccrz.ccAPIConfig.CONFIG_MODULE => module
        };
        if (String.isBlank(module)) {
            input.remove(ccrz.ccAPIConfig.CONFIG_MODULE);
        }

        final Map<String, Object> result = ccrz.ccAPIConfig.fetch(input);
        if (null != result && result.containsKey(ccrz.ccApi.SUCCESS) && (true == (Boolean) result.get(ccrz.ccApi.SUCCESS))) {
            configs = (Map<String, Object>) result.get(ccrz.ccAPIConfig.CONFIGURATIONS);
        }
        return configs;
    }

    /**
     * @description Returns the URL used to make the POST request to CyberSource
     *
     * @param storefront
     *
     * @return
     */
    public static void getCyberSourceConfigSettings(String storefront) {
        final Map<String, Object> configs = getConfigurations('pgcs', storefront);

        // URL to POST the form data to.
        POST_URL = (String) configs.get(CYBER_SOURCE_CONFIG_TOKEN_URL_KEY);
        if (String.isBlank(POST_URL)) {
            POST_URL = CYBER_SOURCE_CONFIG_TEST_URL;
        }

        // Community Url
        String userType = UserInfo.getUserType();
        Network myNetwork = [SELECT Id FROM Network WHERE Name ='Red Cross Learning Center'];
        String loginUrl = Network.getLoginUrl(myNetwork.Id);
        String commUrl = loginUrl.substringBefore('/s/');
            
        if(userType != 'Standard') {
        	String vfPageUrl = Page.phss_cc_CyberSourceCCProcessorIframeForm.getUrl();
            iFRAME_URL = commUrl + vfPageUrl.substringAfter('/apex');
        }
        else {
        	iFRAME_URL = Url.getSalesforceBaseUrl().toExternalForm() + Page.phss_cc_CyberSourceCCProcessorIframeForm.getUrl();
            iFRAME_URL = iFRAME_URL.replaceFirst('[.]', '--c.');  //TODO: This is a hack. This will be fixed in Spring 2019.
            iFRAME_URL = iFRAME_URL.replaceFirst(SALESFORCE_CLASSIC_DOMAIN, VISUAL_FORCE_DOMAIN);
        }
        
        if(userType != 'Standard') {
        	String vfPageUrl = Page.phss_cc_CyberSourceCCProcessorPostBack.getUrl();
            RETURN_URL = commUrl + vfPageUrl.substringAfter('/apex');
        }
        else {
            RETURN_URL = Url.getSalesforceBaseUrl().toExternalForm() + Page.phss_cc_CyberSourceCCProcessorPostBack.getUrl();
            RETURN_URL = RETURN_URL.replaceFirst('[.]', '--c.');  //TODO: This is a hack. This will be fixed in Spring 2019.
            RETURN_URL = RETURN_URL.replaceFirst(SALESFORCE_CLASSIC_DOMAIN, VISUAL_FORCE_DOMAIN);
        }
        
        // Access Key/Profile ID/ Secret/Auth Amount
        ACCESS_KEY = (String) configs.get(CYBER_SOURCE_CONFIG_ACCESSKEY_KEY);
        PROFILE_ID = (String) configs.get(CYBER_SOURCE_CONFIG_PROFILE_ID_KEY);
        SECRET = (String) configs.get(CYBER_SOURCE_CONFIG_SECRET_1_KEY) + (String) configs.get(CYBER_SOURCE_CONFIG_SECRET_2_KEY);

        // Absolute/Percentage amount
        String amountStr = (String) configs.get(CYBER_SOURCE_CONFIG_AUTH_AMOUNT_KEY);
        if (String.isBlank(amountStr)) {
            amountStr = DEFAULT_AUTH_AMOUNT;
        } else {
            String percentChar = '%';
            if (amountStr.endsWith(percentChar) && CART_TOTAL_AMOUNT != null) {
                Decimal percentage = Decimal.valueOf(amountStr.removeEnd(percentChar)) / 100.0;
                amountStr = String.valueOf((CART_TOTAL_AMOUNT * percentage).setScale(2));
            }
        }
        AUTH_AMOUNT = amountStr;

        //Payment Types
        String paymentTypesString = (String) configs.get(CYBER_SOURCE_CONFIG_PAYMENT_TYPES_KEY);
        PAYMENT_TYPES = translateCardTypes(paymentTypesString);
    }

    /**
     * @description Translates the card type to their corresponding names.
     *
     * @param cardType
     *
     * @return
     */
    public static Map<String, Object> translateCardTypes(String cardTypes) {
        Map<String, Object> translatedPaymentTypes = new Map<String, Object>();
        List<String> cardTypesSplit = cardTypes.split(',');

        for (String cardType : cardTypesSplit) {
            if (cardType == PAYMENT_TYPE_VISA) {
                translatedPaymentTypes.put(PAYMENT_TYPE_VISA, VISA);
            } else if (cardType == PAYMENT_TYPE_MASTERCARD) {
                translatedPaymentTypes.put(PAYMENT_TYPE_MASTERCARD, MASTER_CARD);
            } else if (cardType == PAYMENT_TYPE_AMERICAN_EXPRESS) {
                translatedPaymentTypes.put(PAYMENT_TYPE_AMERICAN_EXPRESS, AMERICAN_EXPRESS);
            } else if (cardType == PAYMENT_TYPE_DISCOVER) {
                translatedPaymentTypes.put(PAYMENT_TYPE_DISCOVER, DISCOVER);
            }
        }
        return translatedPaymentTypes;
    }

    /**
     * @description Fetch the account billing data associated to the cart ID.
     *
     * @param cartId
     *
     * @return
     */
    public static void getAccountAndCartData(String currOpportunitySfid) {
        // Fetch contact information from Cart.
        ccrz__E_Cart__c currCart = [
                SELECT
                        ccrz__Account__c,
                        ccrz__Account__r.Billing_Contact__r.FirstName,
                        ccrz__Account__r.Billing_Contact__r.LastName,
                        ccrz__Account__r.Billing_Contact__r.Email,
                        ccrz__Account__r.Billing_Contact__r.Phone,
                        ccrz__Account__r.BillingCity,
                        ccrz__Account__r.BillingCountry,
                        ccrz__Account__r.BillingPostalCode,
                        ccrz__Account__r.BillingState,
                        ccrz__Account__r.BillingStreet,
                        ccrz__Account__r.CreatedDate,
                        ccrz__Account__r.LastModifiedDate,
                        ccrz__Storefront__c,
                        ccrz__TotalAmount__c,
                        ccrz__EncryptedId__c
                FROM ccrz__E_Cart__c
                WHERE Opportunity__c = :currOpportunitySfid AND ccrz__ActiveCart__c = true
        ];

        CART_ENC_ID = currCart.ccrz__EncryptedId__c;
        STOREFRONT = currCart.ccrz__Storefront__c;
        ACCT_ID = currCart.ccrz__Account__c;
        ACCT_CREATED_DATE = currCart.ccrz__Account__r.CreatedDate.format('yyyy-MM-dd hh:mm:ss');
        ACCT_LAST_MODIFIED_DATE = currCart.ccrz__Account__r.LastModifiedDate.format('yyyy-MM-dd hh:mm:ss');
        BILLING_CONTACT_FIRST_NAME = currCart.ccrz__Account__r.Billing_Contact__r.FirstName;
        BILLING_CONTACT_LAST_NAME = currCart.ccrz__Account__r.Billing_Contact__r.LastName;
        BILLING_CONTACT_EMAIL = currCart.ccrz__Account__r.Billing_Contact__r.Email;
        BILLING_CONTACT_PHONE = currCart.ccrz__Account__r.Billing_Contact__r.Phone;
        BILLING_STREET = currCart.ccrz__Account__r.BillingStreet;
        BILLING_CITY = currCart.ccrz__Account__r.BillingCity;
        BILLING_STATE = currCart.ccrz__Account__r.BillingState;
        BILLING_COUNTRY = currCart.ccrz__Account__r.BillingCountry;
        BILLING_POSTAL_CODE = currCart.ccrz__Account__r.BillingPostalCode;
        CART_TOTAL_AMOUNT = currCart.ccrz__TotalAmount__c;

    }

    /**
     * @description Returns the URL to be used to post the cybersource response to the lightning component
     *
     * @param storefront
     *
     * @return
     */
    public static String getLightningURLToPOSTCyberSourceResponse() {
        // Community Url
        String userType = UserInfo.getUserType();
        Network myNetwork = [SELECT Id FROM Network WHERE Name ='Red Cross Learning Center'];
        String loginUrl = Network.getLoginUrl(myNetwork.Id);
        String commUrl = loginUrl.substringBefore('/s/');
        
        String baseURL;
        
        if(userType != 'Standard') {
            baseURL = commUrl;
        }
        else {
        	baseURL = Url.getSalesforceBaseUrl().toExternalForm();    
        }
        
        if (Test.isRunningTest()) {
            baseURL = 'https://testInstance--c.visual.force.com';
        }

        //Convert to lightning.
        // TODO: This is a hack. This will be fixed in Spring 2019.
        String lightningURL;
        if(userType != 'Standard') {
            lightningURL = baseURL;
        }
        else {
        	lightningURL = baseURL.substring(0, baseURL.indexOf('--c')) + LIGHTNING_DOMAIN_NAME;    
        }
        return lightningURL;
    }

    /**
     * @description Builds the form data required to make a POST to CyberSource
     *
     * @param storefrontName
     * @param currCartId
     *
     * @return
     */
    public static Map<String, Object> buildCyberSourceFormData(String currOpportunitySfid) {

        getAccountAndCartData(currOpportunitySfid);
        getCyberSourceConfigSettings(STOREFRONT);
        getUserIPAddress();

        Map<String, Object> cybersourceHostedPageData = new Map<String, Object>{
                CART_ENCID_KEY => CART_ENC_ID,
                UTC_DATE_KEY => Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'GMT'),
                TRANSACTION_ID_KEY => String.valueOf(System.currentTimeMillis()),
                CURRENCY_CODE_KEY => DEFAULT_CURRENCY_CODE,
                REFERENCE_NUMBER_KEY => String.valueOf(System.currentTimeMillis()),
                LOCALE_KEY => DEFAULT_LOCALE,
                TRANSACTION_TYPE_KEY => TRANSACTION_TYPE_AUTH_AND_TOKEN,
                AMOUNT_KEY => AUTH_AMOUNT,
                RETURN_URL_KEY => RETURN_URL,
                POST_URL_KEY => POST_URL,
                iFRAME_URL_KEY => iFRAME_URL,
                PAYMENT_TYPES_KEY => PAYMENT_TYPES,
                PROFILE_ID_KEY => PROFILE_ID,
                ACCESS_KEY_MAPKEY => ACCESS_KEY,
                PAYMENT_METHOD_KEY => PAYMENT_METHOD,
                IGNORE_AVS_KEY => BOOLEAN_TRUE,
                UNSIGNED_FIELDS_KEY => UNSIGNED_FIELDS,
                FIRST_NAME_KEY => BILLING_CONTACT_FIRST_NAME,
                LAST_NAME_KEY => BILLING_CONTACT_LAST_NAME,
                EMAIL_KEY => BILLING_CONTACT_EMAIL,
                PHONE_NUMBER_KEY => BILLING_CONTACT_PHONE,
                ACCOUNT_IDENTIFIER => ACCT_ID,
                ACCOUNT_CREATED_DATE => ACCT_CREATED_DATE,
                ACCOUNT_LAST_MODIFIED_DATE => ACCT_LAST_MODIFIED_DATE,
                STREET_KEY => BILLING_STREET,
                CITY_KEY => BILLING_CITY,
                STATE_KEY => BILLING_STATE,
                COUNTRY_KEY => BILLING_COUNTRY,
                ZIPCODE_KEY => BILLING_POSTAL_CODE,
                IP_ADDRESS_KEY => IP_ADDRESS
        };

        populateSignatureData(cybersourceHostedPageData);
        return cybersourceHostedPageData;
    }

    /**
     * @description Populates the signedItems field by creating a concatenated string of comma seperated key=value pairs of all the signed fields. Also populates the signedData by signing the signedItems string using the specified algorithm.
     *
     * @param cybersourceHostedPageData
     */
    private static void populateSignatureData(Map<String, Object> cybersourceHostedPageData) {

        cybersourceHostedPageData.put(SIGNED_FIELDS_KEY, 'access_key,profile_id,transaction_uuid,transaction_type,reference_number,signed_date_time,currency,amount,payment_method,locale,merchant_defined_data1,merchant_defined_data33,merchant_defined_data38,merchant_defined_data39,merchant_defined_data40,ignore_avs,unsigned_field_names,signed_field_names,override_custom_receipt_page');
        String signedItemString = 'access_key=' + ACCESS_KEY
                + ',profile_id=' + PROFILE_ID
                + ',transaction_uuid=' + cybersourceHostedPageData.get(TRANSACTION_ID_KEY)
                + ',transaction_type=' + TRANSACTION_TYPE_AUTH_AND_TOKEN
                + ',reference_number=' + cybersourceHostedPageData.get('referenceNumber')
                + ',signed_date_time=' + cybersourceHostedPageData.get('utcDate')
                + ',currency=' + DEFAULT_CURRENCY_CODE
                + ',amount=' + AUTH_AMOUNT
                + ',payment_method=' + PAYMENT_METHOD
                + ',locale=' + DEFAULT_LOCALE
                + ',merchant_defined_data1=' + CART_ENC_ID
                + ',merchant_defined_data33=' + IP_ADDRESS
                + ',merchant_defined_data38=' + ACCT_ID
                + ',merchant_defined_data39=' + ACCT_CREATED_DATE
                + ',merchant_defined_data40=' + ACCT_LAST_MODIFIED_DATE
                + ',ignore_avs=' + cybersourceHostedPageData.get(IGNORE_AVS_KEY)
                + ',unsigned_field_names=' + UNSIGNED_FIELDS
                + ',signed_field_names=' + cybersourceHostedPageData.get(SIGNED_FIELDS_KEY)
                + ',override_custom_receipt_page=' + RETURN_URL;

        cybersourceHostedPageData.put('signedItems', signedItemString);
        cybersourceHostedPageData.put('signedData', generateSignature(signedItemString, SECRET));
    }

    /**
     * @description Verifies the signature in the cybersource response to detect tampering.
     *
     * @param cyberSourceResponseMap
     * @param storefront
     *
     * @return
     */
    public static Boolean verifyCyberSourceResponseSignature(String currOpportunitySfid, String cyberSourceResponseString) {
        try {
            phss_cc_Context.setContext(currOpportunitySfid);
            getCyberSourceConfigSettings(phss_cc_Context.STOREFRONT_NAME);
            Map<String, Object> cyberSourceResponseMap = (Map<String, Object>) JSON.deserializeUntyped(cyberSourceResponseString);
            String signableData = buildSignableData(cyberSourceResponseMap);
            String responseSignature = (String) cyberSourceResponseMap.get(CYBER_SOURCE_RESPONSE_SIGNATURE_KEY);
            String generatedSignature = generateSignature(signableData, SECRET);

            return responseSignature.equals(generatedSignature);
        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_VERIFY_CYBERSOURCE_RESPONSE_SIGNATURE);
        }
    }


    /**
     * @description Signs the data using the specified algorithm.
     *
     * @param signedItems
     * @param secretKey
     *
     * @return
     */
    private static String generateSignature(String signedItems, String secretKey) {
        Blob generateMessageAuthCode = Crypto.generateMac(ALGORITHM_NAME, Blob.valueOf(signedItems), Blob.valueOf(secretKey));
        return EncodingUtil.base64Encode(generateMessageAuthCode);
    }


    /**
     * @description Captures payment for a specific transaction payment
     *
     * @param transactionPaymentId
     * @param amount
     *
     * @return
     */
    @Future (Callout=true)
    public static void capturePayment(String fulfillmentId, String authTransactionPaymentId, String captureTransactionPaymentId) {
        try {
            ccrz__E_TransactionPayment__c authTxnPmt = phss_cc_TransactionPaymentUtil.fetchTransactionPayment(authTransactionPaymentId);
            ccrz__E_TransactionPayment__c captureTxnPmt = phss_cc_TransactionPaymentUtil.fetchTransactionPayment(captureTransactionPaymentId);
            ccrz__E_Order__c order = fetchOrder(authTxnPmt.ccrz__CCOrder__c);
            ccrz__E_Cart__c cart = fetchCart(order.ccrz__OriginatedCart__c);

            getCyberSourceConfigSettings(cart.ccrz__Storefront__c);
            Map<String, Object> captureData = buildCaptureData(authTxnPmt.ccrz__Token__c, captureTxnPmt.Name, captureTxnPmt.ccrz__Amount__c);
            Map<String, Object> captureResult = requestPaymentCapture(captureData);

            String status = (String) captureResult.get(PAYMENT_CAPTURE_STATUS);
            if (status == PAYMENT_CAPTURE_SUCCEEDED) {
                Dom.Document response = (Dom.Document) captureResult.get(PAYMENT_CAPTURE_RESPONSE);
                Dom.XmlNode html = response.getRootElement();
                Map<String, String> responseMap = getFormDataFromHTML(html);

                Boolean isResponseValid = verifyPaymentCaptureResponse(responseMap);
                if (isResponseValid) {
                    String reasonCode = responseMap.get(CYBER_SOURCE_REASON_CODE_KEY);
                    if (reasonCode == SUCCESS_REASON_CODE) {
                        phss_cc_FulfillmentUtil.finalizePayment(authTxnPmt.Id, captureTxnPmt.Id, fulfillmentId, responseMap);
                    }
                    else {
                        String message = (String) responseMap.get(CYBER_SOURCE_MESSAGE_KEY);
                        if (message == null) {
                            message = FAILED_TO_CAPTURE_PAYMENT_WITH_REASON_CODE + ' [reason_code=' + reasonCode + ']';
                        }

                        throw new phss_cc_Exception(message);
                    }
                }
                else {
                    throw new phss_cc_Exception('Failed to capture payment because of mismatching signatures (fulfillment=' + fulfillmentId + ', AUTH=' + authTransactionPaymentId + ', CAPTURE=' + captureTransactionPaymentId + ')');
                }

            } else if (status == PAYMENT_CAPTURE_FAILED) {
                String requestStatus = (String) captureResult.get(REQUEST_STATUS);
                Integer requestStatusCode = (Integer) captureResult.get(REQUEST_STATUS_CODE);
                throw new phss_cc_Exception(requestStatus + ' [code=' + requestStatusCode + ']');
            }

        } catch (Exception e) {
            System.debug('Failed to capture payment: ' + e.getMessage());
        }
    }


    /**
     * @description Builds a map of data related to capturing a payment
     *
     * @param paymentToken
     * @param amount
     *
     * @return
     */
    @testVisible
    private static Map<String, Object> buildCaptureData(String paymentToken, String referenceNumber, Decimal amount) {

        String signedFieldNames = 'access_key,amount,bill_trans_ref_no,currency,ignore_avs,locale,payment_method,payment_token,profile_id,reference_number,signed_date_time,signed_field_names,transaction_type,transaction_uuid';
        String dateStr = Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'GMT');
        String millisecondsStr = String.valueOf(System.currentTimeMillis());
        String dataStr = 'access_key=' + ACCESS_KEY
                + ',amount=' + amount
                + ',bill_trans_ref_no=' + referenceNumber
                + ',currency=' + DEFAULT_CURRENCY_CODE
                + ',ignore_avs=' + BOOLEAN_TRUE
                + ',locale=' + DEFAULT_LOCALE
                + ',payment_method=' + PAYMENT_METHOD
                + ',payment_token=' + paymentToken
                + ',profile_id=' + PROFILE_ID
                + ',reference_number=' + referenceNumber
                + ',signed_date_time=' + dateStr
                + ',signed_field_names=' + signedFieldNames
                + ',transaction_type=' + TRANSACTION_TYPE_CAPTURE
                + ',transaction_uuid=' + millisecondsStr
        ;

        Map<String, Object> dataMap = new Map<String, Object>{
                'access_key' => ACCESS_KEY,
                'bill_trans_ref_no' => referenceNumber,
                'amount' => amount,
                'currency' => DEFAULT_CURRENCY_CODE,
                'ignore_avs' => BOOLEAN_TRUE,
                'locale' => DEFAULT_LOCALE,
                'payment_method' => PAYMENT_METHOD,
                'payment_token' => paymentToken,
                'profile_id' => PROFILE_ID,
                'reference_number' => referenceNumber,
                'signature' => generateSignature(dataStr, SECRET),
                'signed_date_time' => dateStr,
                'signed_field_names' => signedFieldNames,
                'transaction_type' => TRANSACTION_TYPE_CAPTURE,
                'transaction_uuid' => millisecondsStr
        };

        return dataMap;
    }


    /**
     * @description Fetches the cart for its identifier
     *
     * @param cartId
     *
     * @return
     */
    @testVisible
    private static ccrz__E_Cart__c fetchCart(String cartId) {
        ccrz__E_Cart__c cart = [
                SELECT Id, ccrz__Storefront__c
                FROM ccrz__E_Cart__c
                WHERE Id = :cartId
        ];
        return cart;
    }


    /**
     * @description Fetches the order for its identifier
     *
     * @param orderId
     *
     * @return
     */
    @testVisible
    private static ccrz__E_Order__c fetchOrder(String orderId) {
        ccrz__E_Order__c order = [
                SELECT Id, ccrz__OriginatedCart__c
                FROM ccrz__E_Order__c
                WHERE Id = :orderId
        ];
        return order;
    }

	@testVisible
    private static ccrz__E_TransactionPayment__c fetchTransactionPaymentForToken(String token) {
        ccrz__E_TransactionPayment__c transactionPayment = [
                SELECT Id
                FROM ccrz__E_TransactionPayment__c
                WHERE ccrz__Token__c = :token
        ];

        if (transactionPayment != null) {
            return phss_cc_TransactionPaymentUtil.fetchTransactionPayment(transactionPayment.Id);
        }

        return null;
    }


    /**
     * @description Submits request for payment capture
     *
     * @param captureData
     */
    @testVisible
    private static Map<String, Object> requestPaymentCapture(Map<String, Object> captureData) {

        Map<String, Object> result = new Map<String, Object>();
        String body = buildPaymentCaptureRequestBody(captureData);

        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:CyberSource_Secure_Acceptance/silent/pay');
        request.setMethod('POST');
        request.setBody(body);

        HttpResponse response = new HttpResponse();

        try {
            Http http = new Http();
            response = http.send(request);

            if (response.getStatusCode() == 200) {
                result.put(PAYMENT_CAPTURE_STATUS, PAYMENT_CAPTURE_SUCCEEDED);
                result.put(PAYMENT_CAPTURE_RESPONSE, response.getBodyDocument());
            } else {
                result.put(PAYMENT_CAPTURE_STATUS, PAYMENT_CAPTURE_FAILED);
                result.put(REQUEST_STATUS, response.getStatus());
                result.put(REQUEST_STATUS_CODE, response.getStatusCode());
            }

        } catch (Exception e) {
            throw new phss_cc_Exception('Failed to request payment capture', e);
        }

        return result;
    }


    /**
     * @description Builds the body for payment capture request
     *
     * @param captureData
     *
     * @return
     */
    @testVisible
    private static String buildPaymentCaptureRequestBody(Map<String, Object> captureData) {

        String body = '';
        for (String key : captureData.keySet()) {
            Object obj = captureData.get(key);

            if (String.isNotBlank(body)) {
                body = body + '&';
            }

            body = body + key + '=';

            if (obj instanceof Decimal) {
                body = body + EncodingUtil.urlEncode(String.valueOf((Decimal) obj), 'UTF-8');
            } else if (obj instanceof Boolean) {
                Boolean b = (Boolean) obj;
                String boolStr = 'false';
                if (b == false) {
                    boolStr = 'false';
                }
                body = body + boolStr;
            } else if (obj instanceof String) {
                body = body + EncodingUtil.urlEncode((String) obj, 'UTF-8');
            } else {
                body = body + EncodingUtil.urlDecode(String.valueOf(obj), 'UTF-8');
            }
        }

        return body;
    }

	@testVisible
    private static String buildSignableData(Map<String, Object> signableData) {
        String names = (String) signableData.get(CYBER_SOURCE_RESPONSE_SIGNED_FIELD_NAMES_KEY);
        List<String> nameList = names.split(',');
        String signableString = '';
        for (String name : nameList) {
            signableString += name + '=' + (String) signableData.get(name) + ',';
        }
        signableString = signableString.removeEnd(',');     // Remove the trailing ','
        return signableString;
    }

    @TestVisible
    private static Map<String, String> getFormDataFromHTML(Dom.XmlNode html) {
        Map<String, String> formData = new Map<String, String>();

        try {
            Dom.XmlNode body = html.getChildElement('body', null);
            Dom.XmlNode form = body.getChildElement('form', null);
            List<Dom.XmlNode> fields = form.getChildren();
            for (Dom.XmlNode field : fields) {
                if (field.getName() == 'input') {
                    String name = field.getAttributeValue('name', null);
                    String value = field.getAttributeValue('value', null);
                    if (String.isNotEmpty(name) && String.isNotEmpty(value)) {
                        formData.put(name, value);
                    }
                }
            }

        } catch (Exception e) {
            System.debug('JASON: exception caught: ' + e.getMessage());
        }

        return formData;
    }

	@testVisible
    private static Boolean verifyPaymentCaptureResponse(Map<String, String> responseMap) {
        try {
            String paymentToken = (String) responseMap.get(CYBER_SOURCE_REQ_PAYMENT_TOKEN_KEY);
            ccrz__E_TransactionPayment__c transactionPayment = fetchTransactionPaymentForToken(paymentToken);
            String opportunityId = transactionPayment.ccrz__CCOrder__r.Opportunity_Order__c;
            phss_cc_Context.setContext(opportunityId);
            getCyberSourceConfigSettings(phss_cc_Context.STOREFRONT_NAME);

            String signableData = buildSignableData(responseMap);
            String responseSignature = (String) responseMap.get(CYBER_SOURCE_RESPONSE_SIGNATURE_KEY);
            String generatedSignature = generateSignature(signableData, SECRET);

            return responseSignature.equals(generatedSignature);

        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_VERIFY_CYBERSOURCE_PAYMENT_CAPTURE_RESPONSE, e);
        }
    }

    @testVisible
    private static void getUserIPAddress() {
        try {
            AuthSession session = [
                    SELECT Id, SourceIp
                    FROM AuthSession
                    WHERE UsersId = :UserInfo.getUserId()
                    ORDER BY CreatedDate DESC LIMIT 1
            ];

            if (session != null) {
                IP_ADDRESS = session.SourceIp;
                return;
            }

        } catch (Exception e) {
            System.debug('Failed to get Source IP from AuthSession: ' + e.getMessage());
        }

        IP_ADDRESS = null;
    }
}