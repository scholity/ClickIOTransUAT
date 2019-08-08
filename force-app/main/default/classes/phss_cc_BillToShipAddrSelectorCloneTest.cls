@isTest
public with sharing class phss_cc_BillToShipAddrSelectorCloneTest {

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

        Test.startTest();
        Map<String, Object> fetchAddressesResponse = phss_cc_BillToShipToAddressSelectorClone.fetchAddresses(null,null);
        fetchAddressesResponse = phss_cc_BillToShipToAddressSelectorClone.fetchAddresses(testOpportunity.Id, '');
        Test.stopTest();
    }

    @isTest
    public static void testAddAddressToCart(){

        setupTestData();
        phss_cc_TestDataFactory.createInsertCartAndCartItems(1,testData,testOpportunity.Id);
        ccrz__E_ContactAddr__c testShippingAddress = phss_cc_TestDataFactory.createInsertTestContactAddress();

        Test.startTest();
        Map<String, Object> addAddressToCartResponse = phss_cc_BillToShipToAddressSelectorClone.addAddressToCart(null,null,null);
        addAddressToCartResponse = phss_cc_BillToShipToAddressSelectorClone.addAddressToCart(testOpportunity.Id,'Billing',testShippingAddress.Id);
        Test.stopTest();
    }

    @isTest
    public static void testGetCurrentAddressesFromCart(){

        setupTestData();
        List<ccrz__E_Cart__c> mycarts = phss_cc_TestDataFactory.createInsertCartAndCartItems(1,testData,testOpportunity.Id);
        ccrz__E_ContactAddr__c testShippingAddress = phss_cc_TestDataFactory.createInsertTestContactAddress();
        phss_cc_TestDataFactory.addAddressToCart(mycarts[0],testShippingAddress.Id, 'Shipping');

        Test.startTest();
        Map<String, Object> getCurrentAddressesFromCartResponse = phss_cc_BillToShipToAddressSelectorClone.getCurrentAddressesFromCart(null);
        getCurrentAddressesFromCartResponse = phss_cc_BillToShipToAddressSelectorClone.getCurrentAddressesFromCart(testOpportunity.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void testInitAddrFormWrapper() {
        Test.startTest();
    	PHSS_AddressFormWrapper addrWrap = phss_cc_BillToShipToAddressSelectorClone.initAddrFormWrapper ();
        Test.stopTest();
        System.assert(addrWrap != null);
    }
    
    @isTest
    public static void testSaveNewShippingAddr() {
    	setupTestData();
    	
        String addrJson = '';
        PHSS_AddressFormWrapper addrWrap = new PHSS_AddressFormWrapper();
        addrWrap.firstName = 'test';
        addrWrap.lastName = 'user';
        addrWrap.email = 'testuser@redcross.com';
        addrWrap.phone = '1234567890';
        addrWrap.addressFirstLine = 'test addr1';
        addrWrap.addressSecondLine = 'test addr2';
        addrWrap.city = 'LA';
        addrWrap.state = 'NY';
        addrWrap.country = 'US';
        addrWrap.postalCode = '12345';
        
        addrJson = JSON.serialize(addrWrap);
        
        ccrz__E_ContactAddr__c addr = phss_cc_BillToShipToAddressSelectorClone.saveNewShippingAddr(addrJson,testOpportunity.Id);
        System.assert(addr.Id != null);
    }
	
    @isTest
    public static void testFetchAddressFromAccount() {
    	setupTestData();
     
        // Update account with shipping address
        Account acc = new Account();
        acc.Id = testOpportunity.AccountId;
        acc.ShippingStreet = 'test st';
        acc.ShippingCity = 'LA';
        acc.ShippingState = 'NY';
        acc.ShippingCountry = 'US';
        acc.ShippingPostalCode = '12345';
        update acc;
        Map<String, Object> addrMap = phss_cc_BillToShipToAddressSelectorClone.fetchAddressFromAccount(testOpportunity.Id);
        System.assert(addrMap.get('AddressMap') != null);
    }
}