/**
 * Created by jbarker on 2019-11-06.
 */

public with sharing class phss_cc_CyberSourceRestApiUtil {

    private static final String CAPTURE_MODULE_PREFIX       = 'pgcsc';
    private static final String CREDIT_MODULE_PREFIX        = 'pgcsc';

    // CyberSource configuration setting names
    private static final String CS_CAPTURE_ENDPOINT_KEY     = 'urlcapture';
    private static final String CS_CREDIT_ENDPOINT_KEY      = 'urlrefund';
    private static final String CS_MERCHANT_ID_KEY          = 'merchantidentifier';
    private static final String CS_SERIAL_NUMBER_KEY        = 'serialnumber';
    private static final String CS_SECRET_KEY_KEY           = 'secretkey';

    public static final String URL_ID_PLACEHOLDER           = '{id}';

    // Configuration settings keys
    public static final String CONFIG_HOST_KEY              = 'host';
    public static final String CONFIG_PATH_KEY              = 'path';
    public static final String CONFIG_MERCHANT_ID_KEY       = 'merchantId';
    public static final String CONFIG_SERIAL_NUMBER_KEY     = 'serialNumber';
    public static final String CONFIG_SECRET_KEY            = 'secretKey';

    // error messages
    private static final String MALFORMED_ENDPOINT_URL = 'Malformed URL for CyberSource REST API Endpoint.';
    private static final String MISSING_ENDPOINT_URL = 'Missing value for CyberSource REST API Endpoint.';
    private static final String MISSING_HOST = 'Missing host.';
    private static final String MISSING_MERCHANT_ID = 'Missing value for CyberSource REST API Merchant Identifier';
    private static final String MISSING_SECRET_KEY = 'Missing value for CyberSource REST API Secret Key.';
    private static final String MISSING_SERIAL_NUMBER = 'Missing value for CyberSource REST API Serial Number.';
    private static final String MISSING_URL_ID_PLACEHOLDER = 'Missing ID placeholder in URL for CyberSource REST API.';
    private static final String MISSING_URL_PATH = 'Missing URL path.';

    

    /**
     * @description Returns the configuration settings for a CyberSource REST API capture request
     *
     * @param storefront
     *
     * @return
     */
    public static Map<String, Object> getCaptureConfigurationSettings(final String storefront) {

        Map<String, Object> settings = getBaseConfigurationSettings(CAPTURE_MODULE_PREFIX, storefront);

        String captureURL = (String) settings.get(configurationKey(CAPTURE_MODULE_PREFIX, CS_CAPTURE_ENDPOINT_KEY));
        if (String.isBlank(captureURL)) {
            throw new phss_cc_Exception(MISSING_ENDPOINT_URL);
        }
        String protocol = 'https://';
        if (!captureURL.startsWithIgnoreCase(protocol)) {
            throw new phss_cc_Exception(MALFORMED_ENDPOINT_URL);
        }
        captureURL = captureURL.removeStartIgnoreCase(protocol);
        String[] components = captureURL.split('/', 2);
        if (components.size() != 2) {
            throw new phss_cc_Exception(MALFORMED_ENDPOINT_URL);
        }
        String host = components[0];
        if (String.isBlank(host)) {
            throw new phss_cc_Exception(MISSING_HOST);
        }
        String path = components[1];
        if (String.isBlank(path)) {
            throw new phss_cc_Exception(MISSING_URL_PATH);
        }
        if (!path.contains(URL_ID_PLACEHOLDER)) {
            throw new phss_cc_Exception(MISSING_URL_ID_PLACEHOLDER);
        }
        path = '/' + path;      // Restore '/' that was removed from split() above.


        return new Map<String, Object>{
                CONFIG_MERCHANT_ID_KEY => settings.get(configurationKey(CAPTURE_MODULE_PREFIX, CS_MERCHANT_ID_KEY)),
                CONFIG_SERIAL_NUMBER_KEY => settings.get(configurationKey(CAPTURE_MODULE_PREFIX, CS_SERIAL_NUMBER_KEY)),
                CONFIG_SECRET_KEY => settings.get(configurationKey(CAPTURE_MODULE_PREFIX, CS_SECRET_KEY_KEY)),
                CONFIG_HOST_KEY => host,
                CONFIG_PATH_KEY => path
        };
    }


    /**
     * @description Returns the configuration settings for a CyberSource REST API credit request
     *
     * @param storefront
     *
     * @return
     */
    public static Map<String, Object> getCreditConfigurationSettings(final String storefront) {

        Map<String, Object> settings = getBaseConfigurationSettings(CREDIT_MODULE_PREFIX, storefront);

        String creditURL = (String) settings.get(configurationKey(CREDIT_MODULE_PREFIX, CS_CREDIT_ENDPOINT_KEY));
        if (String.isBlank(creditURL)) {
            throw new phss_cc_Exception(MISSING_ENDPOINT_URL);
        }
        String protocol = 'https://';
        if (!creditURL.startsWithIgnoreCase(protocol)) {
            throw new phss_cc_Exception(MALFORMED_ENDPOINT_URL);
        }
        creditURL = creditURL.removeStartIgnoreCase(protocol);
        String[] components = creditURL.split('/', 2);
        if (components.size() != 2) {
            throw new phss_cc_Exception(MALFORMED_ENDPOINT_URL);
        }
        String host = components[0];
        if (String.isBlank(host)) {
            throw new phss_cc_Exception(MISSING_HOST);
        }
        String path = components[1];
        if (String.isBlank(path)) {
            throw new phss_cc_Exception(MISSING_URL_PATH);
        }
        if (!path.contains(URL_ID_PLACEHOLDER)) {
            throw new phss_cc_Exception(MISSING_URL_ID_PLACEHOLDER);
        }
        path = '/' + path;      // Restore '/' that was removed from split() above.


        return new Map<String, Object>{
                CONFIG_MERCHANT_ID_KEY => settings.get(configurationKey(CREDIT_MODULE_PREFIX, CS_MERCHANT_ID_KEY)),
                CONFIG_SERIAL_NUMBER_KEY => settings.get(configurationKey(CREDIT_MODULE_PREFIX, CS_SERIAL_NUMBER_KEY)),
                CONFIG_SECRET_KEY => settings.get(configurationKey(CREDIT_MODULE_PREFIX, CS_SECRET_KEY_KEY)),
                CONFIG_HOST_KEY => host,
                CONFIG_PATH_KEY => path
        };
    }


    /**
     * @description Returns the common configuration settings for a CyberSource REST API request
     *
     * @param module
     * @param storefront
     *
     * @return
     */
    private static Map<String, Object> getBaseConfigurationSettings(final String module, final String storefront) {

        Map<String, Object> settings = loadConfigurationSettings(module, storefront);

        String merchantId = (String) settings.get(configurationKey(module, CS_MERCHANT_ID_KEY));
        if (String.isBlank(merchantId)) {
            throw new phss_cc_Exception(MISSING_MERCHANT_ID);
        }

        String serialNumber = (String) settings.get(configurationKey(module, CS_SERIAL_NUMBER_KEY));
        if (String.isBlank(serialNumber)) {
            throw new phss_cc_Exception(MISSING_SERIAL_NUMBER);
        }

        String secretKey = (String) settings.get(configurationKey(module, CS_SECRET_KEY_KEY));
        if (String.isBlank(secretKey)) {
            throw new phss_cc_Exception(MISSING_SECRET_KEY);
        }

        return settings;
    }


    /**
     * @description Fetches the configuration settings for a specified module and storefront
     *
     * @param module
     * @param storefront
     *
     * @return
     */
    private static Map<String, Object> loadConfigurationSettings(final String module, final String storefront) {
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
     * @description Creates a configuration setting key based on the module prefix and setting name
     *
     * @param module
     * @param setting
     *
     * @return
     */
    private static String configurationKey(String module, String setting) {
        return module + '.' + setting;
    }

}