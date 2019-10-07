/**
 * Created by jbarker on 2019-03-26.
 */

@isTest
public with sharing class phss_cc_CyberSourceCreditUtilTest {

    private static final Decimal testAmount = 0.01;
    private static final String testCurrencyCode = 'USD';
    private static final String testTxnPmtName = 'TP-01';
    private static final String testTxnRequestId = '1234567890';
    private static final String testStorefront = 'Global';
    private static final String testHost = 'apitest.cybersource.com';
    private static final String testPath = '/pts/v2/captures/{id}/refunds';
    private static final String testHTTPMethod = 'POST';
    private static final String testMerchantId = 'testredcross';
    private static final String testSerialNumber = 'a02df902-bc07-4ed2-bae6-2118f9700d8b';
    private static final String testSecretKey = 'A3klGt9qKaZxxzc0SEx9QuXlIqFTKTpeMScZLypJoLY=';

    private static String testTimestamp;
    
    private static Fulfillment__c testFulfillment;
    
    private static Fulfillment_Item__c testFulfillmentItem1;

    private static ccrz__E_TransactionPayment__c testAuthTransactionPayment;
    private static ccrz__E_TransactionPayment__c testCaptureTransactionPayment;

    private static ccrz__E_Order__c testOrder;
    
    private static ccrz__E_OrderItem__c testOrderItem;

    @TestSetup
    public static void setup() {
        ccrz__E_ConfigurationModule__c module = new ccrz__E_ConfigurationModule__c(ccrz__APIName__c = 'pgcsc', Name = 'CyberSource Credit');
        insert module;

        
        ccrz__E_ConfigurationMeta__c meta1 = new ccrz__E_ConfigurationMeta__c(
                ccrz__APIName__c = 'urlrefund',
                ccrz__ConfigurationModule__c = module.Id,
                ccrz__Description__c = 'CyberSource REST API endpoint for submitting refund transactions',
                ccrz__ExternallySafe__c = false,
                Name = 'Endpoint: Refund'
        );
        ccrz__E_ConfigurationMeta__c meta2 = new ccrz__E_ConfigurationMeta__c(
                ccrz__APIName__c = 'merchantidentifier',
                ccrz__ConfigurationModule__c = module.Id,
                ccrz__Description__c = 'CyberSource REST API identifier for merchant',
                ccrz__ExternallySafe__c = false,
                Name = 'Merchant ID'
        );
        ccrz__E_ConfigurationMeta__c meta3 = new ccrz__E_ConfigurationMeta__c(
                ccrz__APIName__c = 'serialnumber',
                ccrz__ConfigurationModule__c = module.Id,
                ccrz__Description__c = 'CyberSource REST API serial number for shared secret key',
                ccrz__ExternallySafe__c = false,
                Name = 'Serial Number'
        );
        ccrz__E_ConfigurationMeta__c meta4 = new ccrz__E_ConfigurationMeta__c(
                ccrz__APIName__c = 'secretkey',
                ccrz__ConfigurationModule__c = module.Id,
                ccrz__Description__c = 'CyberSource REST API shared secret key',
                ccrz__ExternallySafe__c = false,
                Name = 'Shared Secret Key'
        );
        List<SObject> metaList = new List<SObject>{ meta1, meta2, meta3, meta4 };
        insert metaList;


        ccrz__E_Configuration__c config1 = new ccrz__E_Configuration__c(
                ccrz__ConfigurationMeta__c = meta1.Id,
                ccrz__PageName__c = 'all',
                ccrz__SequencePriority__c = 0,
                ccrz__Storefront__c = testStorefront,
                ccrz__TextValue__c = 'https://' + testHost + testPath,
                Name = testStorefront + '.all.' + module.ccrz__APIName__c + '.' + meta1.ccrz__APIName__c
        );
        ccrz__E_Configuration__c config2 = new ccrz__E_Configuration__c(
                ccrz__ConfigurationMeta__c = meta2.Id,
                ccrz__PageName__c = 'all',
                ccrz__SequencePriority__c = 0,
                ccrz__Storefront__c = testStorefront,
                ccrz__TextValue__c = testMerchantId,
                Name = testStorefront + '.all.' + module.ccrz__APIName__c + '.' + meta1.ccrz__APIName__c
        );
        ccrz__E_Configuration__c config3 = new ccrz__E_Configuration__c(
                ccrz__ConfigurationMeta__c = meta3.Id,
                ccrz__PageName__c = 'all',
                ccrz__SequencePriority__c = 0,
                ccrz__Storefront__c = testStorefront,
                ccrz__TextValue__c = testSerialNumber,
                Name = testStorefront + '.all.' + module.ccrz__APIName__c + '.' + meta1.ccrz__APIName__c
        );
        ccrz__E_Configuration__c config4 = new ccrz__E_Configuration__c(
                ccrz__ConfigurationMeta__c = meta4.Id,
                ccrz__PageName__c = 'all',
                ccrz__SequencePriority__c = 0,
                ccrz__Storefront__c = testStorefront,
                ccrz__TextValue__c = testSecretKey,
                Name = testStorefront + '.all.' + module.ccrz__APIName__c + '.' + meta1.ccrz__APIName__c
        );
        List<SObject> configList = new List<SObject>{ config1, config2, config3, config4 };
        insert configList;
    }
    
    private static void generateTestData(){
        //this needs to be combined with the setup() method       
        Account testAccount = new Account(
            Name='SalesforcetestOrg',
            BillingStreet='24 Willie Mays Plaza',
            BillingCity='San Francisco',
            BillingState='California',
            BillingPostalCode='94017',
            BillingCountry='USA',
            Phone='9934200234',
            SABA_LMS_Code__c = 'someval',
            SABA_Org_Type__c = 'AP'
        );
        insert testAccount;
        
        Opportunity testOpportunity = phss_cc_TestDataFactory.createInsertTestOpportunity(testAccount);
        
        redwing__Learning__c testLearning = new redwing__Learning__c(
            Name = 'testLearning',
            redwing__Published__c = true,
            RecordTypeId = Schema.SObjectType.redwing__Learning__c.getRecordTypeInfosByName().get('ILT Event').getRecordTypeId()
        );
        insert testLearning;
        
        redwing__Training_Plan__c testLearningPlan = new redwing__Training_Plan__c(
            Name = 'testLearningPlan'
        );
        insert testLearningPlan;
        
        ccrz__E_Product__c testProduct = new ccrz__E_Product__c(
            Name = 'Test Prod',
            ccrz__SKU__c = String.ValueOf(System.Now()),
            ccrz__Quantityperunit__c = 2.0,
            ccrz__StartDate__c =  System.Today().addDays(2),
            ccrz__EndDate__c = System.Today().addDays(20),
            LMS_Learning_Plan__c = testLearningPlan.id,
            Product_3__c = 'LG',
            Product_2__c = 'BST',
            Product_1__c = 'BST'
        );
        insert testProduct;
        
        Training_Events__c testTrainingEvent = new Training_Events__c(
            Account__c = testAccount.Id,
        	Training_Location_State__c = 'CO',
            Opportunity__c = testOpportunity.Id,
            Scheduling_Status__c = 'Open'
        );
        insert testTrainingEvent;
        
        Redwing__ILT_Class__c testITLClass = new Redwing__ILT_Class__c(
            Skedulo_Account__c = testAccount.Id,
            redwing__End_Date__c = Date.Parse('12/19/2018'),
            redwing__End_Time__c= '13:00',
            redwing__Start_Date__c = Date.Parse('12/19/2018'),
            redwing__Start_Time__c = '12:00',
            Name = 'testITLClass',
            Request_Type__c='Community',
            redwing__Learning__c = testLearning.Id,
            Skedulo_Training_Event__c = testTrainingEvent.Id
        );
        insert testITLClass;
        
        testOrder = new ccrz__E_Order__c(
            NSSCCConnector_SFCC_Order_Number__c = '3114226',
            NSSCCConnector_from_SFCC__c = true,
            ccrz__Account__c = testAccount.Id,
            ccrz__Storefront__c = 'CREStore',
            Opportunity_Order__c = testOpportunity.Id
        );
        insert testOrder;
        
         testOrderItem = new ccrz__E_OrderItem__c(
            ccrz__Product__c = testProduct.Id,
            ccrz__Order__c = testOrder.id,
            ccrz__Price__c=100,
            ccrz__Quantity__c=100.00,
            ccrz__SubAmount__c=100.00,
            ILT_Class__c = testITLClass.Id
        );
        insert testOrderItem;
        
        ccrz__E_TransactionPayment__c testParentTransactionPayment = new ccrz__E_TransactionPayment__c(
        	ccrz__CCOrder__c = testOrder.Id,
            ccrz__AccountType__c = phss_cc_TransactionPaymentUtil.CREDIT_CARD_PAYMENT_TYPE,
            ccrz__Amount__c = 1,
            ccrz__CurrencyISOCode__c = 'USD',
            ccrz__TransactionPaymentId__c = 'test123',
            ccrz__TransactionType__c = phss_cc_TransactionPaymentUtil.AUTH_TRANSACTION_TYPE
        );
        insert testParentTransactionPayment;
        
        testAuthTransactionPayment = new ccrz__E_TransactionPayment__c(
        	ccrz__CCOrder__c = testOrder.Id,
            ccrz__AccountType__c = phss_cc_TransactionPaymentUtil.CREDIT_CARD_PAYMENT_TYPE,
            ccrz__Amount__c = -1,
            ccrz__CurrencyISOCode__c = 'USD',
            ccrz__ParentTransactionPayment__c = testParentTransactionPayment.Id,
            ccrz__TransactionPaymentId__c = 'test321',
            ccrz__TransactionType__c = phss_cc_TransactionPaymentUtil.AUTH_TRANSACTION_TYPE
        );
        insert testAuthTransactionPayment;
        
        testCaptureTransactionPayment = new ccrz__E_TransactionPayment__c(
        	ccrz__CCOrder__c = testOrder.Id,
            ccrz__AccountType__c = phss_cc_TransactionPaymentUtil.CREDIT_CARD_PAYMENT_TYPE,
            ccrz__Amount__c = -1,
            ccrz__CurrencyISOCode__c = 'USD',
            ccrz__SourceTransactionPayment__c = testAuthTransactionPayment.Id,
            ccrz__TransactionPaymentId__c = '123test',
            ccrz__TransactionType__c = phss_cc_TransactionPaymentUtil.CAPTURE_TRANSACTION_TYPE
        );
        insert testCaptureTransactionPayment;
        
        testFulfillment = new Fulfillment__c(
            Type__c='Invoice',
            Status__c='Open',
            Order__c = testOrder.Id,
            CC_Transaction_Payment__c= testAuthTransactionPayment.Id
        );
        insert testFulfillment;
        
        testFulfillmentItem1 = new Fulfillment_Item__c(
            Type__c = 'Training',
            Status__c ='Ready',
            Fulfillment__c = testFulfillment.Id,
            Order__c = testOrder.Id,
            Order_Item__c = testOrderItem.Id,
            CC_Product__c = testProduct.Id,
            ILT_Class__c = testITLClass.Id,
            Quantity__c = 1,
            Supplemental_Information__c = 'Test123',
            Fulfillment_Date__c = Date.today(),
            Transaction_Date__c = Date.today()
        );
        insert testFulfillmentItem1;
    }


    private static void prepareCyberSourceUtil() {
        phss_cc_CyberSourceCreditUtil.loadCyberSourceConfigurations(testStorefront);
        testTimestamp = Datetime.now().formatGmt('EEE, dd MMM yyyy HH:mm:ss') + 'GMT';
    }


    @isTest
    public static void testLoadCyberSourceConfigurations() {
        prepareCyberSourceUtil();

        phss_cc_CyberSourceCreditUtil.loadCyberSourceConfigurations(testStorefront);
        System.assertEquals(testHost, phss_cc_CyberSourceCreditUtil.HOST);
        System.assertEquals(testPath, phss_cc_CyberSourceCreditUtil.PATH);
        System.assertEquals(testMerchantId, phss_cc_CyberSourceCreditUtil.MERCHANT_ID);
        System.assertEquals(testSerialNumber, phss_cc_CyberSourceCreditUtil.SERIAL_NUMBER);
        System.assertEquals(testSecretKey, phss_cc_CyberSourceCreditUtil.SECRET_KEY);
    }

    @isTest
    public static void testBuildRefundRequest() {
        prepareCyberSourceUtil();

        Map<String, Object> objectMap = new Map<String, Object>();
        objectMap.put(phss_cc_CyberSourceCreditUtil.TRANSACTION_PAYMENT_NAME_KEY, testTxnPmtName);
        objectMap.put(phss_cc_CyberSourceCreditUtil.CURRENCY_CODE_KEY, testCurrencyCode);
        objectMap.put(phss_cc_CyberSourceCreditUtil.TRANSACTION_PAYMENT_AMOUNT_KEY, testAmount);
        objectMap.put(phss_cc_CyberSourceCreditUtil.TRANSACTION_REFERENCE_ID_KEY, testTxnRequestId);
        objectMap.put(phss_cc_CyberSourceCreditUtil.TRANSACTION_TIMESTAMP_KEY, testTimestamp);

        HttpRequest request = phss_cc_CyberSourceCreditUtil.buildRefundRequest(objectMap);
        System.assertEquals(testHTTPMethod, request.getMethod());
        System.assertEquals(testMerchantId, request.getHeader('v-c-merchant-id'));
        System.assertEquals(testTimestamp, request.getHeader('v-c-date'));
        System.assertEquals(testHost, request.getHeader('Host'));
        System.assertEquals('application/json', request.getHeader('Content-Type'));
        System.assert(request.getHeader('Digest') != null);
        System.assert(request.getHeader('Signature') != null);
    }

    @isTest
    public static void testGenerateSignableData() {
        List<String> keys = new List<String>{ 't0', 't1', 't2' };
        Map<String, Object> kvMap = new Map<String, Object>{ 't0' => '0', 't1' => '1', 't2' => '2' };
        String dataStr = phss_cc_CyberSourceCreditUtil.generateSignableData(keys, kvMap);
        System.assertEquals('t0: 0\nt1: 1\nt2: 2', dataStr);
    }

    @isTest
    public static void testGenerateSignature() {
        prepareCyberSourceUtil();
        String signature = phss_cc_CyberSourceCreditUtil.generateSignature('abcdefghijklmnopqrstuvwxyz0123456789');
        System.assertEquals('L2knFELVmXiIHkFYmYDkluBh4LqvmnrlcBM1Rp90nW4=', signature);
    }

    @isTest
    public static void testGenerateDigest() {
        String digest = phss_cc_CyberSourceCreditUtil.generateDigest('abcdefghijklmnopqrstuvwxyz0123456789');
        System.assertEquals('SHA-256=AR/CmU450lEUFUD4emkJKz8iqGdn9yg95+7ts4l77fY=', digest);
    }

    @isTest
    public static void testCreateMessageBody() {
        Map<String, Object> messageBody = phss_cc_CyberSourceCreditUtil.createMessageBody(testTxnPmtName, testAmount, testCurrencyCode);

        Map<String, Object> clientRefInfo = (Map<String, Object>) messageBody.get('clientReferenceInformation');
        System.assertEquals(testTxnPmtName, clientRefInfo.get('code'));

        Map<String, Object> orderInfo = (Map<String, Object>) messageBody.get('orderInformation');
        Map<String, Object> amountDetails = (Map<String, Object>) orderInfo.get('amountDetails');
        System.assertEquals(testCurrencyCode, amountDetails.get('currency'));
        System.assertEquals(testAmount, amountDetails.get('totalAmount'));
    }
    
    @isTest static void testGetFulfillmentData(){
        
        generateTestData();
        
        Map<String, Object> objectMap = new Map<String, Object>();
        objectMap.put(phss_cc_CyberSourceCreditUtil.TRANSACTION_PAYMENT_NAME_KEY, testTxnPmtName);
        objectMap.put(phss_cc_CyberSourceCreditUtil.CURRENCY_CODE_KEY, testCurrencyCode);
        objectMap.put(phss_cc_CyberSourceCreditUtil.TRANSACTION_PAYMENT_AMOUNT_KEY, testAmount);
        objectMap.put(phss_cc_CyberSourceCreditUtil.TRANSACTION_REFERENCE_ID_KEY, testTxnRequestId);
        objectMap.put(phss_cc_CyberSourceCreditUtil.TRANSACTION_TIMESTAMP_KEY, testTimestamp);
        
        phss_cc_CyberSourceCreditUtil.getFulfillmentData(testFulfillment.Id, objectMap);
    }

    @IsTest
    static void testSaveRefundCapture() {
        
        PHSS_TriggerSettings__c settings = PHSS_TriggerSettings__c.getOrgDefaults();
        settings.FulfillmentTriggerDisabled__c = true;
        upsert settings PHSS_TriggerSettings__c.Id;
        
        generateTestData();
        
        Map<String, Object> objectMap = new Map<String, Object>();
        objectMap.put(phss_cc_CyberSourceCreditUtil.TRANSACTION_PAYMENT_NAME_KEY, testTxnPmtName);
        objectMap.put(phss_cc_CyberSourceCreditUtil.CURRENCY_CODE_KEY, testCurrencyCode);
        objectMap.put(phss_cc_CyberSourceCreditUtil.TRANSACTION_PAYMENT_AMOUNT_KEY, testAmount);
        objectMap.put(phss_cc_CyberSourceCreditUtil.TRANSACTION_REFERENCE_ID_KEY, testTxnRequestId);
        objectMap.put(phss_cc_CyberSourceCreditUtil.TRANSACTION_TIMESTAMP_KEY, testTimestamp);
        
        Map<String, Object> refundAmountDetails = new Map<String, Object>{
            phss_cc_CyberSourceCreditUtil.REFUND_AMOUNT_KEY => '1.0'
        };
            
        objectMap.put(phss_cc_CyberSourceCreditUtil.REFUND_AMOUNT_DETAILS_KEY, refundAmountDetails);
        objectMap.put(phss_cc_CyberSourceCreditUtil.SUBMIT_TIME_UTC_KEY, String.valueOf(system.Now()));
        
        Test.startTest();
        phss_cc_CyberSourceCreditUtil.saveRefundCapture(objectMap, testAuthTransactionPayment.Id, testCaptureTransactionPayment.Id);
        Test.stopTest();

    }
}