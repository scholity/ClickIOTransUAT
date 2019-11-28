/**
 * Created by jbarker on 2019-11-07.
 */

@IsTest
public with sharing class phss_cc_CyberSourceRestApiUtilTest {

    private static String TEST_HOST = 'www.test.com';
    private static String TEST_MERCHANT_ID = 'testredcross';
    private static String TEST_PATH = '/pts/v2/captures/{id}/refunds';
    private static String TEST_SECRET_KEY = '9876543210';
    private static String TEST_SERIAL_NUMBER = '0123456789';
    private static String TEST_STOREFRONT = 'Global';


    public static void setupTestConfigurationSettings(String storefront) {
        ccrz__E_ConfigurationModule__c module = new ccrz__E_ConfigurationModule__c(
                ccrz__APIName__c = phss_cc_CyberSourceRestApiUtil.CAPTURE_MODULE_PREFIX,
                Name = 'CyberSource REST'
        );
        insert module;

        ccrz__E_ConfigurationMeta__c meta0 = new ccrz__E_ConfigurationMeta__c(
                ccrz__APIName__c = phss_cc_CyberSourceRestApiUtil.CS_CAPTURE_ENDPOINT_KEY,
                ccrz__ConfigurationModule__c = module.Id,
                ccrz__Description__c = 'CyberSource REST API endpoint for capturing payments',
                ccrz__ExternallySafe__c = false,
                Name = 'Endpoint: Capture'
        );
        ccrz__E_ConfigurationMeta__c meta1 = new ccrz__E_ConfigurationMeta__c(
                ccrz__APIName__c = phss_cc_CyberSourceRestApiUtil.CS_CREDIT_ENDPOINT_KEY,
                ccrz__ConfigurationModule__c = module.Id,
                ccrz__Description__c = 'CyberSource REST API endpoint for submitting refund transactions',
                ccrz__ExternallySafe__c = false,
                Name = 'Endpoint: Refund'
        );
        ccrz__E_ConfigurationMeta__c meta2 = new ccrz__E_ConfigurationMeta__c(
                ccrz__APIName__c = phss_cc_CyberSourceRestApiUtil.CS_MERCHANT_ID_KEY,
                ccrz__ConfigurationModule__c = module.Id,
                ccrz__Description__c = 'CyberSource REST API identifier for merchant',
                ccrz__ExternallySafe__c = false,
                Name = 'Merchant ID'
        );
        ccrz__E_ConfigurationMeta__c meta3 = new ccrz__E_ConfigurationMeta__c(
                ccrz__APIName__c = phss_cc_CyberSourceRestApiUtil.CS_SERIAL_NUMBER_KEY,
                ccrz__ConfigurationModule__c = module.Id,
                ccrz__Description__c = 'CyberSource REST API serial number for shared secret key',
                ccrz__ExternallySafe__c = false,
                Name = 'Serial Number'
        );
        ccrz__E_ConfigurationMeta__c meta4 = new ccrz__E_ConfigurationMeta__c(
                ccrz__APIName__c = phss_cc_CyberSourceRestApiUtil.CS_SECRET_KEY_KEY,
                ccrz__ConfigurationModule__c = module.Id,
                ccrz__Description__c = 'CyberSource REST API shared secret key',
                ccrz__ExternallySafe__c = false,
                Name = 'Shared Secret Key'
        );
        List<SObject> metaList = new List<SObject>{ meta0, meta1, meta2, meta3, meta4 };
        insert metaList;


        ccrz__E_Configuration__c config0 = new ccrz__E_Configuration__c(
                ccrz__ConfigurationMeta__c = meta0.Id,
                ccrz__PageName__c = 'all',
                ccrz__SequencePriority__c = 0,
                ccrz__Storefront__c = storefront,
                ccrz__TextValue__c = 'https://' + TEST_HOST + TEST_PATH,
                Name = storefront + '.all.' + module.ccrz__APIName__c + '.' + meta1.ccrz__APIName__c
        );
        ccrz__E_Configuration__c config1 = new ccrz__E_Configuration__c(
                ccrz__ConfigurationMeta__c = meta1.Id,
                ccrz__PageName__c = 'all',
                ccrz__SequencePriority__c = 0,
                ccrz__Storefront__c = storefront,
                ccrz__TextValue__c = 'https://' + TEST_HOST + TEST_PATH,
                Name = storefront + '.all.' + module.ccrz__APIName__c + '.' + meta1.ccrz__APIName__c
        );
        ccrz__E_Configuration__c config2 = new ccrz__E_Configuration__c(
                ccrz__ConfigurationMeta__c = meta2.Id,
                ccrz__PageName__c = 'all',
                ccrz__SequencePriority__c = 0,
                ccrz__Storefront__c = storefront,
                ccrz__TextValue__c = TEST_MERCHANT_ID,
                Name = storefront + '.all.' + module.ccrz__APIName__c + '.' + meta1.ccrz__APIName__c
        );
        ccrz__E_Configuration__c config3 = new ccrz__E_Configuration__c(
                ccrz__ConfigurationMeta__c = meta3.Id,
                ccrz__PageName__c = 'all',
                ccrz__SequencePriority__c = 0,
                ccrz__Storefront__c = storefront,
                ccrz__TextValue__c = TEST_SERIAL_NUMBER,
                Name = storefront + '.all.' + module.ccrz__APIName__c + '.' + meta1.ccrz__APIName__c
        );
        ccrz__E_Configuration__c config4 = new ccrz__E_Configuration__c(
                ccrz__ConfigurationMeta__c = meta4.Id,
                ccrz__PageName__c = 'all',
                ccrz__SequencePriority__c = 0,
                ccrz__Storefront__c = storefront,
                ccrz__TextValue__c = TEST_SECRET_KEY,
                Name = storefront + '.all.' + module.ccrz__APIName__c + '.' + meta1.ccrz__APIName__c
        );
        List<SObject> configList = new List<SObject>{ config0, config1, config2, config3, config4 };
        insert configList;
    }


    @IsTest
    static void testGetCaptureConfigurationSettings() {

        setupTestConfigurationSettings(TEST_STOREFRONT);

        Map<String,Object> configurationSettings = phss_cc_CyberSourceRestApiUtil.getCaptureConfigurationSettings(TEST_STOREFRONT);
        System.assertEquals(TEST_MERCHANT_ID, configurationSettings.get(phss_cc_CyberSourceRestApiUtil.CONFIG_MERCHANT_ID_KEY));
        System.assertEquals(TEST_SECRET_KEY, configurationSettings.get(phss_cc_CyberSourceRestApiUtil.CONFIG_SECRET_KEY));
        System.assertEquals(TEST_SERIAL_NUMBER, configurationSettings.get(phss_cc_CyberSourceRestApiUtil.CONFIG_SERIAL_NUMBER_KEY));
        System.assertEquals(TEST_HOST, configurationSettings.get(phss_cc_CyberSourceRestApiUtil.CONFIG_HOST_KEY));
        System.assertEquals(TEST_PATH, configurationSettings.get(phss_cc_CyberSourceRestApiUtil.CONFIG_PATH_KEY));
    }


    @IsTest
    static void testGetCreditConfigurationSettings() {

        setupTestConfigurationSettings(TEST_STOREFRONT);

        Map<String,Object> configurationSettings = phss_cc_CyberSourceRestApiUtil.getCreditConfigurationSettings(TEST_STOREFRONT);
        System.assertEquals(TEST_MERCHANT_ID, configurationSettings.get(phss_cc_CyberSourceRestApiUtil.CONFIG_MERCHANT_ID_KEY));
        System.assertEquals(TEST_SECRET_KEY, configurationSettings.get(phss_cc_CyberSourceRestApiUtil.CONFIG_SECRET_KEY));
        System.assertEquals(TEST_SERIAL_NUMBER, configurationSettings.get(phss_cc_CyberSourceRestApiUtil.CONFIG_SERIAL_NUMBER_KEY));
        System.assertEquals(TEST_HOST, configurationSettings.get(phss_cc_CyberSourceRestApiUtil.CONFIG_HOST_KEY));
        System.assertEquals(TEST_PATH, configurationSettings.get(phss_cc_CyberSourceRestApiUtil.CONFIG_PATH_KEY));
    }
}