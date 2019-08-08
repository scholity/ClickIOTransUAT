/**
 * Created by dgajwani on 9/19/18.
 */

public with sharing class cc_lx_CyberSourceUtil {

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

    // Form Data
    private static final String CART_SFID_KEY = 'cartSFId';
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
    private static final String BOOLEAN_TRUE = 'true';
    private static final String SIGNED_FIELDS_KEY = 'signedFields';
    private static final String STREET_KEY = 'street';
    private static final String CITY_KEY = 'city';
    private static final String STATE_KEY = 'state';
    private static final String COUNTRY_KEY = 'country';
    private static final String ZIPCODE_KEY = 'zipcode';
    private static final String PAYMENT_TYPES_KEY = 'paymentTypes';
    private static final String iFRAME_URL_KEY = 'iframeURL';

    // CyberSource Config Keys
    private static final String CYBER_SOURCE_CONFIG_TOKEN_URL_KEY = 'pgcs.urltokencreate';
    private static final String CYBER_SOURCE_CONFIG_TEST_URL = 'https://testsecureacceptance.cybersource.com/silent/pay';
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
    private static final String CYBER_SOURCE_RESPONSE_SIGNED_FEILD_NAMES_KEY = 'signed_field_names';
    private static final String CYBER_SOURCE_RESPONSE_SIGNATURE_KEY = 'signature';

    //CyberSource Config Settings.
    @TestVisible private static String ACCESS_KEY;
    @TestVisible private static String SECRET;
    @TestVisible private static String PROFILE_ID;
    @TestVisible private static String POST_URL;
    @TestVisible private static String RETURN_URL;
    @TestVisible private static String iFRAME_URL;
    @TestVisible private static Map<String, Object> PAYMENT_TYPES;

    //FORM data Defaults
    private static final String AUTH_AMOUNT = '1.00';
    private static final String DEFAULT_LOCALE = 'en-us';
    private static final String DEFAULT_CURRENCY_CODE = 'USD';
    private static final String ALGORITHM_NAME = 'hmacSHA256';
    private static final String TRANSACTION_TYPE_AUTH_AND_TOKEN = 'authorization,create_payment_token';
    private static final String PAYMENT_METHOD = 'card';
    private static final String UNSIGNED_FIELDS = 'bill_to_forename,bill_to_surname,bill_to_email,bill_to_address_line1,bill_to_address_city,bill_to_address_country,bill_to_address_state,bill_to_address_postal_code,card_number,card_expiry_date,card_cvn,card_type';

    // Account Data
    @TestVisible private static String STOREFRONT;
    @TestVisible private static String ACC_FIRST_NAME;
    @TestVisible private static String ACC_LAST_NAME;
    @TestVisible private static String ACC_BILLING_EMAIL;
    @TestVisible private static String BILLING_STREET;
    @TestVisible private static String BILLING_CITY;
    @TestVisible private static String BILLING_STATE;
    @TestVisible private static String BILLING_COUNTRY;
    @TestVisible private static String BILLING_POSTAL_CODE;

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
        final Map<String, Object> configs = cc_lx_CyberSourceUtil.getConfigurations('pgcs', storefront);

        // URL to POST the form data to.
        POST_URL = (String) configs.get(CYBER_SOURCE_CONFIG_TOKEN_URL_KEY);
        if (String.isBlank(POST_URL)) {
            POST_URL = CYBER_SOURCE_CONFIG_TEST_URL;
        }

        iFRAME_URL = Url.getSalesforceBaseUrl().toExternalForm() + Page.cc_lx_CyberSourceCCProcessorIframeForm.getUrl();
        iFRAME_URL = iFRAME_URL.replaceFirst('[.]', '--c.');  //TODO: This is a hack. This will be fixed in Spring 2019.
        iFRAME_URL = iFRAME_URL.replaceFirst(SALESFORCE_CLASSIC_DOMAIN, VISUAL_FORCE_DOMAIN);

        RETURN_URL = Url.getSalesforceBaseUrl().toExternalForm() + Page.cc_lx_CyberSourceCCProcessorPostBack.getUrl();
        RETURN_URL = RETURN_URL.replaceFirst('[.]', '--c.');  //TODO: This is a hack. This will be fixed in Spring 2019.
        RETURN_URL = RETURN_URL.replaceFirst(SALESFORCE_CLASSIC_DOMAIN, VISUAL_FORCE_DOMAIN);

        // Access Key/Profile ID/ Secret
        ACCESS_KEY = (String) configs.get(CYBER_SOURCE_CONFIG_ACCESSKEY_KEY);
        PROFILE_ID = (String) configs.get(CYBER_SOURCE_CONFIG_PROFILE_ID_KEY);
        SECRET = (String) configs.get(CYBER_SOURCE_CONFIG_SECRET_1_KEY) + (String) configs.get(CYBER_SOURCE_CONFIG_SECRET_2_KEY);

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
    public static void getAccountAndCartData(String cartId) {
        // Fetch contact information from Cart.
        ccrz__E_Cart__c currCart = [
                SELECT
                        ccrz__Account__r.Name,
                        ccrz__Account__r.Billing_Contact_email__c,
                        ccrz__Account__r.BillingCity,
                        ccrz__Account__r.BillingCountry,
                        ccrz__Account__r.BillingPostalCode,
                        ccrz__Account__r.BillingState,
                        ccrz__Account__r.BillingStreet,
                        ccrz__Storefront__c
                FROM ccrz__E_Cart__c
                WHERE Id = :cartId
        ];

        // Split Name to FirstName and LastName.
        String AccFirstName = currCart.ccrz__Account__r.Name;
        String AccLastName = NA_EMAIL;
        if (currCart.ccrz__Account__r.Name.contains(' ')) {
            String[] name = currCart.ccrz__Account__r.Name.split(' ');
            AccFirstName = name[0];
            AccLastName = name[1];
        }

        String AccBillingEmail = NA_EMAIL;
        // Set Email to NA if null.
        if (currCart.ccrz__Account__r.Billing_Contact_email__c != null && String.isEmpty(currCart.ccrz__Account__r.Billing_Contact_email__c)) {
            AccBillingEmail = currCart.ccrz__Account__r.Billing_Contact_email__c;
        }

        STOREFRONT = currCart.ccrz__Storefront__c;
        ACC_FIRST_NAME = AccFirstName;
        ACC_LAST_NAME = AccLastName;
        ACC_BILLING_EMAIL = AccBillingEmail;
        BILLING_STREET = currCart.ccrz__Account__r.BillingStreet;
        BILLING_CITY = currCart.ccrz__Account__r.BillingCity;
        BILLING_STATE = currCart.ccrz__Account__r.BillingState;
        BILLING_COUNTRY = currCart.ccrz__Account__r.BillingCountry;
        BILLING_POSTAL_CODE = currCart.ccrz__Account__r.BillingPostalCode;

    }

    /**
     * @description Returns the URL to be used to post the cybersource response to the lightning component
     *
     * @param storefront
     *
     * @return
     */
    public static String getLightningURLToPOSTCyberSourceResponse() {
        String baseURL = Url.getSalesforceBaseUrl().toExternalForm();

        if (Test.isRunningTest()) {
            baseURL = 'https://testInstance--c.visual.force.com';
        }

        //Convert to lightning.
        // TODO: This is a hack. This will be fixed in Spring 2019.
        String lightningURL = baseURL.substring(0, baseURL.indexOf('--c')) + LIGHTNING_DOMAIN_NAME;
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
    public static Map<String, Object> buildCyberSourceFormData(String currCartId) {

        getAccountAndCartData(currCartId);
        getCyberSourceConfigSettings(STOREFRONT);

        Map<String, Object> cybersourceHostedPageData = new Map<String, Object>{
                CART_SFID_KEY => currCartId,
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
                FIRST_NAME_KEY => ACC_FIRST_NAME,
                LAST_NAME_KEY => ACC_LAST_NAME,
                EMAIL_KEY => ACC_BILLING_EMAIL,
                STREET_KEY => BILLING_STREET,
                CITY_KEY => BILLING_CITY,
                STATE_KEY => BILLING_STATE,
                COUNTRY_KEY => BILLING_COUNTRY,
                ZIPCODE_KEY => BILLING_POSTAL_CODE
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

        cybersourceHostedPageData.put(SIGNED_FIELDS_KEY, 'access_key,profile_id,transaction_uuid,transaction_type,reference_number,signed_date_time,currency,amount,payment_method,locale,merchant_defined_data1,ignore_avs,unsigned_field_names,signed_field_names,override_custom_receipt_page');
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
                + ',merchant_defined_data1=' + cybersourceHostedPageData.get(CART_SFID_KEY)
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
    public static Boolean verifyCyberSourceResponseSignature(Map<String, Object> cyberSourceResponseMap, String storefront) {
        if (SECRET == null || String.isEmpty(SECRET)) {
            getCyberSourceConfigSettings(storefront);
        }

        String signedFields = (String) cyberSourceResponseMap.get(CYBER_SOURCE_RESPONSE_SIGNED_FEILD_NAMES_KEY);
        List<String> signedFieldsSplit = signedFields.split(',');
        String signedItemString = '';
        for (String field : signedFieldsSplit) {
            signedItemString += field + '=' + (String) cyberSourceResponseMap.get(field) + ',';
        }

        signedItemString = signedItemString.removeEnd(','); // Remove the trailing ,

        String responseSignature = (String) cyberSourceResponseMap.get(CYBER_SOURCE_RESPONSE_SIGNATURE_KEY);
        String generatedSignature = generateSignature(signedItemString, SECRET);
        return responseSignature.equals(generatedSignature);
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
}