/************************************************************************************************************************************
** Author: Salesforce Services
** Description: Tests for CCOrderItemTriggerHandler and PHSS_GenerateCSVFileBatchScheduler
************************************************************************************************************************************/

@isTest
public class CCOrderItemTriggerHandlerTest {
	
    public static Opportunity testOpportunity;
    public static Map<String, Object> testData;
    public static List<ccrz__E_Product__c> products;
    public static ccrz__E_Cart__c testCart;

    @testSetup static void setup() {
        Bucket_Account_Settings__c bas = new Bucket_Account_Settings__c();
        bas.Bucket_Account_Owner_ID__c ='005d0000001WOeV';
        bas.Bucket_Account_RecordTypeID__c = '012d000000098Wt';
        bas.Default_Bucket_Name__c = 'Bucket Account';
        bas.Maximum_Size_of_Bucket__c = 5000;
		insert bas; 
            
		GL_Unit_Code__c unitCode = new GL_Unit_Code__c();
        unitCode.Name = '01234';
        unitCode.Unit_Code__c = '01234';
        unitCode.TS_LOC__c = '0123';
        insert unitCode;
            
		Geo_Location__c geoLocation = new Geo_Location__c();            
        geoLocation.City__c = 'San Francisco';
        geoLocation.State__c = 'California';
        geoLocation.State_Abbreviation__c = 'CA';
        geoLocation.Postal_Code__c = '99999';
        geoLocation.Country_Code__c = 'US';
        geoLocation.Coordinates__Latitude__s = 1.234;
        geoLocation.Coordinates__Longitude__s = 1.333;
        geoLocation.GL_Unit_Code__c = unitCode.Id;
        insert geoLocation;	
    }
    
    static testMethod void matchingPostalCode() {
        testData = phss_cc_TestDataFactory.setupAccountAndProducts();
        products = (List<ccrz__E_Product__c>) testData.get(phss_cc_TestDataFactory.TEST_PRODUCTS);
        Account testAccount = (Account) testData.get(phss_cc_TestDataFactory.TEST_ACCOUNT);
        testAccount.BillingPostalCode = '99999';
        update testAccount;
        testOpportunity = phss_cc_TestDataFactory.createInsertTestOpportunity(testAccount);
        List<ccrz__E_Cart__c> testCarts = phss_cc_TestDataFactory.createInsertCartAndCartItems(1, testData, testOpportunity.Id);
        testCart = testCarts[0];
        phss_cc_TestDataFactory.createInsertStoredPayment(1, testOpportunity);
        Test.startTest();  
        Map<String, Object> newPO = new Map<String, Object>{
        	phss_cc_OrderUtil.NEW_PO_NAME_KEY => 'Test PO',
            phss_cc_OrderUtil.NEW_PO_AMOUNT_KEY => '1000',
            //phss_cc_OrderUtil.NEW_PO_START_DATE_KEY => String.valueOf(Date.today()),
            //phss_cc_OrderUtil.NEW_PO_END_DATE_KEY => String.valueOf(Date.today()+5),
            phss_cc_OrderUtil.NEW_PO_DOSAVE_KEY => true
      	};
        Map<String, Object> placeOrderResult = phss_cc_CartController.placeOrderOnCartPO(testOpportunity.Id, testCart.ccrz__EncryptedId__c, newPO);
        Map<String, Object> placeOrderResultExistingPO = phss_cc_OrderUtil.placeOrderOnCartPO(testOpportunity.Id, testCart.ccrz__EncryptedId__c, newPO);
        Test.stopTest();
    }
    static testMethod void withProduct() {
        ccrz__E_ContactAddr__c shipTo = new ccrz__E_ContactAddr__c();
        shipTo.ccrz__AddressFirstline__c = '1 Main St';
        shipTo.ccrz__City__c = 'San Francisco';
        shipTo.ccrz__PostalCode__c = '12345';
        insert shipTo;
        testData = phss_cc_TestDataFactory.setupAccountAndProducts();
        products = (List<ccrz__E_Product__c>) testData.get(phss_cc_TestDataFactory.TEST_PRODUCTS);
        ccrz__E_Product__c prod = products[0];
        prod.ccrz__InventoryType__c='STANDARD';
        update prod;
        testOpportunity = phss_cc_TestDataFactory.createInsertTestOpportunity((Account) testData.get(phss_cc_TestDataFactory.TEST_ACCOUNT));
        List<ccrz__E_Cart__c> testCarts = phss_cc_TestDataFactory.createInsertCartAndCartItems(1, testData, testOpportunity.Id);
        testCart = testCarts[0];
        testCart.ccrz__ShipTo__c = shipTo.Id;
        update testCart;
        phss_cc_TestDataFactory.createInsertStoredPayment(1, testOpportunity);  
        Test.startTest(); 
        Map<String, Object> newPO = new Map<String, Object>{
        	phss_cc_OrderUtil.NEW_PO_NAME_KEY => 'Test PO',
            phss_cc_OrderUtil.NEW_PO_AMOUNT_KEY => '1000',
            //phss_cc_OrderUtil.NEW_PO_START_DATE_KEY => String.valueOf(Date.today()),
            //phss_cc_OrderUtil.NEW_PO_END_DATE_KEY => String.valueOf(Date.today()+5),
            phss_cc_OrderUtil.NEW_PO_DOSAVE_KEY => true
      	};
        Map<String, Object> placeOrderResult = phss_cc_CartController.placeOrderOnCartPO(testOpportunity.Id, testCart.ccrz__EncryptedId__c, newPO);
        Map<String, Object> placeOrderResultExistingPO = phss_cc_OrderUtil.placeOrderOnCartPO(testOpportunity.Id, testCart.ccrz__EncryptedId__c, newPO);
        Test.stopTest();
    }
    static testMethod void withClass() {
        testData = phss_cc_TestDataFactory.setupAccountAndProducts();
        products = (List<ccrz__E_Product__c>) testData.get(phss_cc_TestDataFactory.TEST_PRODUCTS);
        ccrz__E_Product__c prod = products[0];
        prod.ccrz__InventoryType__c='COURSE';
        update prod;
        testOpportunity = phss_cc_TestDataFactory.createInsertTestOpportunity((Account) testData.get(phss_cc_TestDataFactory.TEST_ACCOUNT));
        List<ccrz__E_Cart__c> testCarts = phss_cc_TestDataFactory.createInsertCartAndCartItems(1, testData, testOpportunity.Id);
        testCart = testCarts[0];
        phss_cc_TestDataFactory.createInsertStoredPayment(1, testOpportunity);
        Test.startTest();        
        Map<String, Object> newPO = new Map<String, Object>{
        	phss_cc_OrderUtil.NEW_PO_NAME_KEY => 'Test PO',
            phss_cc_OrderUtil.NEW_PO_AMOUNT_KEY => '1000',
           // phss_cc_OrderUtil.NEW_PO_START_DATE_KEY => String.valueOf(Date.today()),
            //phss_cc_OrderUtil.NEW_PO_END_DATE_KEY => String.valueOf(Date.today()+5),
            phss_cc_OrderUtil.NEW_PO_DOSAVE_KEY => true
      	};
        Map<String, Object> placeOrderResult = phss_cc_CartController.placeOrderOnCartPO(testOpportunity.Id, testCart.ccrz__EncryptedId__c, newPO);
        Map<String, Object> placeOrderResultExistingPO = phss_cc_OrderUtil.placeOrderOnCartPO(testOpportunity.Id, testCart.ccrz__EncryptedId__c, newPO);
        Test.stopTest();
    }
}