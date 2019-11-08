@isTest(SeeAllData=false)
public class phss_cc_FulfillmentUtilTest {
	
    @isTest static void testCapturePayment(){
        
        generateTestData();
        
        phss_cc_FulfillmentUtil.capturePayment(null); //hit return lines
        
        phss_cc_FulfillmentUtil.capturePayment(testFulfillment);
    }
    
    @isTest static void testCompleteFulfillment(){
        
        generateTestData();
        
        Fulfillment__c completedFulfillment = phss_cc_FulfillmentUtil.completeFulfillment(testFulfillment.Id, testAuthTransactionPayment.Id);

        system.assertEquals(completedFulfillment.Id, testFulfillment.Id);
    }
    
    @isTest static void testCompleteAuthTransactionPayment(){
        
        generateTestData();
        
        ccrz__E_TransactionPayment__c completedPayment = phss_cc_FulfillmentUtil.completeAuthTransactionPayment(testAuthTransactionPayment.Id, phss_cc_FulfillmentUtil.createInvoiceForPayment(testAuthTransactionPayment.Id).Id);
    }
    
    @isTest static void testFinalizePayment(){
        
        generateTestData();
        
        phss_cc_FulfillmentUtil.finalizePayment(testAuthTransactionPayment.Id, testCaptureTransactionPayment.Id, testFulfillment.Id, new Map<String, Object>{'test' => 'test'});
    }
    
    @isTest static void testGetRecords(){
        
        generateTestData();
        
        system.assertEquals(testFulfillment.Id, phss_cc_FulfillmentUtil.fetchFulfillment(testFulfillment.Id).Id);
        
        system.assertEquals(testFulfillmentItem1.Id, phss_cc_FulfillmentUtil.getFulfillmentItems(testFulfillment.Id)[0].Id);
        
        system.assertEquals(testOrderItem.Id, phss_cc_FulfillmentUtil.getItemsForOrder(testOrder.Id)[0].Id);
        
        system.assertEquals(testAuthTransactionPayment.Id, phss_cc_FulfillmentUtil.getTransactionPayment(testAuthTransactionPayment.Id).Id);
        
        system.assertEquals(testAuthTransactionPayment.Id, phss_cc_FulfillmentUtil.getTransactionPaymentForOrder(testOrder.Id).Id);
        
        system.assertEquals(testAuthTransactionPayment.Id, phss_cc_FulfillmentUtil.getTransactionPaymentForOrder(testOrder.Id).Id);
        
        try{
            phss_cc_FulfillmentUtil.parseDatetime(system.now().format('yyyy-MM-dd\'T\'HH:mm:ss'));
        }
        catch(exception ex){
            //need to figure out how the expected DT string is formatted to assert
        }
    }
    
    private static Fulfillment__c testFulfillment;
    
    private static Fulfillment_Item__c testFulfillmentItem1;
    
    private static ccrz__E_TransactionPayment__c testAuthTransactionPayment;
    private static ccrz__E_TransactionPayment__c testCaptureTransactionPayment;
    
    private static ccrz__E_Order__c testOrder;
    
    private static ccrz__E_OrderItem__c testOrderItem;
    
    private static void generateTestData(){
        
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

        System.debug('JASON: creating test opportunity');
        Opportunity testOpportunity = phss_cc_TestDataFactory.createInsertTestOpportunity(testAccount);
        System.debug('JASON: creating test contract');
        Contract testContract = phss_cc_TestDataFactory.createInsertTestContract(testAccount, testOpportunity);
        System.debug('JASON: finished created test contract');

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
        
        testAuthTransactionPayment = new ccrz__E_TransactionPayment__c(
                ccrz__Account__c = testAccount.Id,
                ccrz__CCOrder__c = testOrder.Id,
                ccrz__AccountType__c = phss_cc_TransactionPaymentUtil.CREDIT_CARD_PAYMENT_TYPE,
                ccrz__Amount__c = 1,
                ccrz__TransactionType__c = phss_cc_TransactionPaymentUtil.AUTH_TRANSACTION_TYPE
        );
        insert testAuthTransactionPayment;

        testCaptureTransactionPayment = new ccrz__E_TransactionPayment__c(
                ccrz__Account__c = testAccount.Id,
                ccrz__CCOrder__c = testOrder.Id,
                ccrz__AccountType__c = phss_cc_TransactionPaymentUtil.CREDIT_CARD_PAYMENT_TYPE,
                ccrz__Amount__c = 1,
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
    
}