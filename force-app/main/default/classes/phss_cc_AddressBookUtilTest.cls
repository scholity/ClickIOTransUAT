/**
 * Created by dgajwani on 12/4/18.
 */
@isTest
public with sharing class phss_cc_AddressBookUtilTest {

    public static Map<String, Object> testData;
    public static Opportunity testOpportunity;
    public static ccrz__E_ContactAddr__c testContactAddress;

    public static void setupTestData(){
        testData = phss_cc_TestDataFactory.setupAccountAndProducts();
        testOpportunity = phss_cc_TestDataFactory.createInsertTestOpportunity((Account) testData.get(phss_cc_TestDataFactory.TEST_ACCOUNT));
        testContactAddress = phss_cc_TestDataFactory.createInsertTestContactAddress();
        phss_cc_TestDataFactory.createInsertTestAccountAddressBook((Account) testData.get(phss_cc_TestDataFactory.TEST_ACCOUNT), testContactAddress);
    }

    @isTest
    public static void testFetchAddresses(){

        setupTestData();

        Map<String, Object> fetchAddressesResponse;

        Test.startTest();
        fetchAddressesResponse = phss_cc_AddressBookUtil.fetchAddresses(testOpportunity.Id, '');
        Test.stopTest();

        System.assert(fetchAddressesResponse != null);
        System.assert(fetchAddressesResponse.containsKey(phss_cc_AddressBookUtil.ADDRESS_LIST));
        System.assert(fetchAddressesResponse.containsKey(phss_cc_AddressBookUtil.ADDRESS_MAP));
        System.assert(fetchAddressesResponse.containsKey(phss_cc_AddressBookUtil.ADDRESS_TYPE));
        List<String> fetchedAddressIDList = (List<String>)fetchAddressesResponse.get(phss_cc_AddressBookUtil.ADDRESS_LIST);
        System.assertNotEquals(0,fetchedAddressIDList.size());
    }

    @isTest
    public static void testContactAddressFetch(){

        setupTestData();
        Set<String> testContactAddressIds = new Set<String>{testContactAddress.Id};
        List<Map<String, Object>> contactAddressFetchResponse;

        Test.startTest();
        phss_cc_Context.setContext(testOpportunity.Id);
        contactAddressFetchResponse = phss_cc_AddressBookUtil.contactAddressFetch(testContactAddressIds);
        Test.stopTest();

        System.assert(contactAddressFetchResponse != null);
        System.assertNotEquals(0,contactAddressFetchResponse.size());
    }

}