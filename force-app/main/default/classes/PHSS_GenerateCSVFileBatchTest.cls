/************************************************************************************************************************************
** Author: Salesforce Services
** Description: Tests for PHSS_GenerateCSVFileBatch and PHSS_GenerateCSVFileBatchScheduler
************************************************************************************************************************************/

@isTest(SeeAllData=false)
public class PHSS_GenerateCSVFileBatchTest {
    
    @isTest static void testExecuteBatch(){
        
        generateTestData();
        
        Test.startTest();
        
        database.executeBatch(new PHSS_GenerateCSVFileBatch(), 100);
        
        sendCSVToCFS.generateCSV();
        
        Test.stopTest();
    }
    
    @isTest static void testExecuteBatch2(){
        
        generateTestData2();
        
        Test.startTest();
        
        database.executeBatch(new PHSS_GenerateCSVFileBatch(), 100);
        
        sendCSVToCFS.generateCSV();
        
        Test.stopTest();
    }
    
    private static void generateTestData(){
        
        Switch__c switchCustomSetting = new Switch__c(
            Name = 'EmailMessageServiceSwitch',
            Switch__c = false
        );
        insert switchCustomSetting;
        
        Id recordTypeId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Bucket Account').getRecordTypeId();
        
        Bucket_Account_Settings__c bas = Bucket_Account_Settings__c.getOrgDefaults();
        bas.Bucket_Account_Owner_ID__c = UserInfo.getUserID();
        bas.Bucket_Account_RecordTypeID__c = recordTypeId1;
        bas.Default_Bucket_Name__c = 'Bucket Account';
        bas.Maximum_Size_of_Bucket__c = 5000;
        insert bas;
        
        Account testAccount = new Account(
            Name='SalesforcetestOrg',
            BillingStreet='24 Willie Mays Plaza',
            BillingCity='San Francisco',
            BillingState='California',
            BillingPostalCode='94017',
            BillingCountry='USA',
            Phone='9934200234'
        );
        insert testAccount;
        
        Contact c = new Contact(FirstName = 'Test',
                                LastName = 'Contact',
                                Phone = '9998887777',
                                Email = 'teset@tst.com',
                                AccountId = testAccount.Id);
        insert c;
        
        Account acc = new Account(Id = testAccount.Id, Billing_Contact__c = c.Id);
        update acc;
        
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('RCS PO').getRecordTypeId();
        
        Case testCase = new Case(
            RecordTypeId=recordTypeId,
            Status='PO On-Hold CFS',
            Sent_to_CFS__c=false,             
            AccountId=testAccount.Id, 
            Billing_Contact_Email__c='sanford.trudi@jobcorps.org', 
            Billing_Contact_Phone__c='4124418698', 
            Billing_Address_1__c='7175 HIGHLAND DRIVE', 
            Billing_City__c='PITTSBURGH', 
            Billing_State__c='PA', 
            Billing_Zip__c='15206', 
            Billing_Country_Name__c='USA', 
            Billing_Country_Code__c='US', 
            Billing_Contact_Last_Name__c='SANFORD', 
            Billing_Contact_First_Name__c='TRUDI', 
            Shipping_Contact_First_Name__c='TRUDI', 
            Shipping_Contact_Last_Name__c='SANFORD', 
            Terms__c='NET 30', 
            IsNewRecord__c='Yes', 
            Invoice_delivery_Email__c='sanford.trudi@jobcorps.org', 
            Company_Name__c='PITTSBURGH JOB CORPS CENTER', 
            Usage__c='BILL TO', 
            Shipping_Address_1__c='7175 HIGHLAND DRIVE', 
            Shipping_State__c='PA', 
            Shipping_City__c='PITTSBURGH', 
            Shipping_Zip__c='15206', 
            Shipping_Country_Name__c='USA', 
            Shipping_Country_Code__c='US', 
            Customer_First_name__c='TRUDI', 
            Customer_Last_name__c='SANFORD', 
            Shipping_Contact_Phone__c='4124418698', 
            External_LOGIN_EMAIL__c='sanford.trudi@jobcorps.org', 
            PO_Number__c='PO0002039', 
            PO_Amount__c=2484.70, 
            /*
            PO_Start_Date__c=2018-11-17T05:00:00z, 
            PO_End_Date__c=2019-12-21T14:51:43z, 
            */
            Site_Name1__c='PITTSBURGH');
        
        redwing__Learning__c testLearning = new redwing__Learning__c(
            Name = 'testLearning',
            redwing__Published__c = true,
            RecordTypeId = Schema.SObjectType.redwing__Learning__c.getRecordTypeInfosByName().get('ILT Event').getRecordTypeId()
        );
        insert testLearning;
        
        Redwing__ILT_Class__c testITLClass = new Redwing__ILT_Class__c(
            Skedulo_Account__c = testAccount.Id,
            redwing__End_Date__c = Date.Parse('12/19/2018'),
            redwing__End_Time__c= '13:00',
            redwing__Start_Date__c = Date.Parse('12/19/2018'),
            redwing__Start_Time__c = '12:00',
            Name = 'testITLClass',
            Request_Type__c='Community',
            redwing__Learning__c = testLearning.Id
        );
        insert testITLClass;
        
        redwing__ILT_Instructor__c testInstructor = new redwing__ILT_Instructor__c(
            redwing__Instructor__c = UserInfo.getUserId(),
            redwing__ILT_Class__c = testITLClass.id,
            redwing__Primary__c = true
        );
        
        redwing__ILT_Instructor__c testInstructor2 = new redwing__ILT_Instructor__c(
            redwing__Instructor__c = UserInfo.getUserId(),
            redwing__ILT_Class__c = testITLClass.id,
            redwing__Primary__c = false
        );
        insert new List<redwing__ILT_Instructor__c>{testInstructor, testInstructor2};
            
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
            LMS_Learning_Plan__c = testLearningPlan.id
        );
        insert testProduct;
        
        ccrz__E_TransactionPayment__c testTransactionPayment = new ccrz__E_TransactionPayment__c(ccrz__AccountType__c = 'po');
        insert testTransactionPayment;
        
        ccrz__E_Order__c testOrder = new ccrz__E_Order__c(
            NSSCCConnector_SFCC_Order_Number__c = '3114226',
            NSSCCConnector_from_SFCC__c = true,
            ccrz__Account__c = testAccount.Id
        );
        insert testOrder;
        
        ccrz__E_OrderItem__c testOrderItem = new ccrz__E_OrderItem__c(
            ccrz__Product__c = testProduct.Id,
            Payment_Category__c = '',
            ccrz__Order__c = testOrder.id,
            ccrz__Price__c=100,
            ccrz__Quantity__c=100.00,
            ccrz__SubAmount__c=100.00,
            ILT_Class__c = testITLClass.Id
        );
        insert testOrderItem;
        
        Fulfillment__c testFulfillment = new Fulfillment__c(
            Type__c='Invoice',
            Status__c='Open',
            Order__c = testOrder.Id,
            CC_Transaction_Payment__c= testTransactionPayment.Id
        );
        insert testFulfillment;
        
        Fulfillment_Item__c testFulfillmentItem1 = new Fulfillment_Item__c(
            Type__c = 'Training',
            Status__c ='Ready',
            Fulfillment__c = testFulfillment.Id,
            Order__c = testOrder.Id,
            Order_Item__c = testOrderItem.Id,
            CC_Product__c = testProduct.Id,
            ILT_Class__c = testITLClass.Id,
            Quantity__c = 1,
            Supplemental_Information__c = 'Test123'
        );
        
        Fulfillment_Item__c testFulfillmentItem2 = new Fulfillment_Item__c(
            Type__c = 'Training',
            Status__c = 'Ready',
            Fulfillment__c = testFulfillment.Id,
            Order__c = testOrder.Id,
            Order_Item__c = testOrderItem.Id,
            CC_Product__c = testProduct.Id
        );
        insert new List<Fulfillment_Item__c>{testFulfillmentItem1, testFulfillmentItem2};
        
            List<Fulfillment_Item__c> ffItemList1 = [SELECT Id, Product_SKU__c, AP_Code__c FROM Fulfillment_Item__c];
            
    }
    
    private static void generateTestData2(){
        
        Switch__c switchCustomSetting = new Switch__c(
            Name = 'EmailMessageServiceSwitch',
            Switch__c = false
        );
        insert switchCustomSetting;
        
        Account testAccount = new Account(
            Name='SalesforcetestOrg',
            BillingStreet='',
            BillingCity='',
            BillingState='',
            BillingPostalCode='',
            BillingCountry='',
            Phone='',
            Special_Invoicing__c = 'DO NOT MAIL'
        );
        insert testAccount;
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('RCS PO').getRecordTypeId();
        
        Case testCase = new Case(
            RecordTypeId=recordTypeId,
            Status='PO On-Hold CFS',
            Sent_to_CFS__c=false,             
            AccountId=testAccount.Id, 
            Billing_Contact_Email__c='sanford.trudi@jobcorps.org', 
            Billing_Contact_Phone__c='4124418698', 
            Billing_Address_1__c='7175 HIGHLAND DRIVE', 
            Billing_City__c='PITTSBURGH', 
            Billing_State__c='PA', 
            Billing_Zip__c='15206', 
            Billing_Country_Name__c='USA', 
            Billing_Country_Code__c='US', 
            Billing_Contact_Last_Name__c='SANFORD', 
            Billing_Contact_First_Name__c='TRUDI', 
            Shipping_Contact_First_Name__c='TRUDI', 
            Shipping_Contact_Last_Name__c='SANFORD', 
            Terms__c='NET 30', 
            IsNewRecord__c='Yes', 
            Invoice_delivery_Email__c='sanford.trudi@jobcorps.org', 
            Company_Name__c='PITTSBURGH JOB CORPS CENTER', 
            Usage__c='BILL TO', 
            Shipping_Address_1__c='7175 HIGHLAND DRIVE', 
            Shipping_State__c='PA', 
            Shipping_City__c='PITTSBURGH', 
            Shipping_Zip__c='15206', 
            Shipping_Country_Name__c='USA', 
            Shipping_Country_Code__c='US', 
            Customer_First_name__c='TRUDI', 
            Customer_Last_name__c='SANFORD', 
            Shipping_Contact_Phone__c='4124418698', 
            External_LOGIN_EMAIL__c='sanford.trudi@jobcorps.org', 
            PO_Number__c='PO0002039', 
            PO_Amount__c=2484.70, 
            /*
            PO_Start_Date__c=2018-11-17T05:00:00z, 
            PO_End_Date__c=2019-12-21T14:51:43z, 
            */
            Site_Name1__c='PITTSBURGH');
        
        redwing__Learning__c testLearning = new redwing__Learning__c(
            Name = 'testLearning',
            redwing__Published__c = true,
            RecordTypeId = Schema.SObjectType.redwing__Learning__c.getRecordTypeInfosByName().get('ILT Event').getRecordTypeId()
        );
        insert testLearning;
        
        Redwing__ILT_Class__c testITLClass = new Redwing__ILT_Class__c(
            Skedulo_Account__c = testAccount.Id,
            redwing__End_Date__c = Date.Parse('12/19/2018'),
            redwing__End_Time__c= '13:00',
            redwing__Start_Date__c = Date.Parse('12/19/2018'),
            redwing__Start_Time__c = '12:00',
            Name = 'testITLClass',
            Request_Type__c='Community',
            redwing__Learning__c = testLearning.Id
        );
        insert testITLClass;
        
        redwing__ILT_Instructor__c testInstructor = new redwing__ILT_Instructor__c(
            redwing__Instructor__c = UserInfo.getUserId(),
            redwing__ILT_Class__c = testITLClass.id,
            redwing__Primary__c = true
        );
        
        redwing__ILT_Instructor__c testInstructor2 = new redwing__ILT_Instructor__c(
            redwing__Instructor__c = UserInfo.getUserId(),
            redwing__ILT_Class__c = testITLClass.id,
            redwing__Primary__c = false
        );
        insert new List<redwing__ILT_Instructor__c>{testInstructor, testInstructor2};
            
            redwing__Training_Plan__c testLearningPlan = new redwing__Training_Plan__c(
                Name = 'testLearningPlan'
            );
        insert testLearningPlan;
        
        ccrz__E_Category__c ccCategory = new ccrz__E_Category__c ();
        ccCategory.Name = 'NAT Training';
        ccCategory.ccrz__Sequence__c = 500;
        ccCategory.ccrz__StartDate__c = System.Today();
        ccCategory.ccrz__EndDate__c = System.Today().addDays(20);
        ccCategory.ccrz__CategoryID__c = 'Test';
        insert ccCategory;
        
        ccrz__E_Product__c testProduct = new ccrz__E_Product__c(
            Name = 'Test Prod',
            ccrz__SKU__c = String.ValueOf(System.Now()),
            ccrz__Quantityperunit__c = 2.0,
            ccrz__StartDate__c =  System.Today().addDays(2),
            ccrz__EndDate__c = System.Today().addDays(20),
            LMS_Learning_Plan__c = testLearningPlan.id,
            CC_Category__c = ccCategory.Id,
            AP_Code__c = '6243',
            ccrz__InventoryType__c = 'COURSE',
            ccrz__ProductType__c = 'KIT'
        );
        insert testProduct;
        
        
        
        
        ccrz__E_TransactionPayment__c testTransactionPayment = new ccrz__E_TransactionPayment__c(ccrz__AccountType__c = 'po');
        insert testTransactionPayment;
        
        ccrz__E_Order__c testOrder = new ccrz__E_Order__c(
            NSSCCConnector_SFCC_Order_Number__c = '3114226',
            NSSCCConnector_from_SFCC__c = true,
            ccrz__Account__c = testAccount.Id
        );
        insert testOrder;
        
        ccrz__E_OrderItem__c testOrderItem = new ccrz__E_OrderItem__c(
            ccrz__Product__c = testProduct.Id,
            ccrz__Order__c = testOrder.id,
            ccrz__Price__c=100,
            ccrz__Quantity__c=100.00,
            ccrz__SubAmount__c=100.00,
            ILT_Class__c = testITLClass.Id
        );
        insert testOrderItem;
        
        Fulfillment__c testFulfillment = new Fulfillment__c(
            Type__c='Invoice',
            Status__c='Open',
            Order__c = testOrder.Id,
            CC_Transaction_Payment__c= testTransactionPayment.Id
        );
        insert testFulfillment;
        
        Fulfillment_Item__c testFulfillmentItem1 = new Fulfillment_Item__c(
            Type__c = 'Training',
            Status__c ='Ready',
            Fulfillment__c = testFulfillment.Id,
            Order__c = testOrder.Id,
            Order_Item__c = testOrderItem.Id,
            CC_Product__c = testProduct.Id,
            ILT_Class__c = testITLClass.Id,
            Quantity__c = 1,
            Supplemental_Information__c = 'Test123'
        );
        
        Fulfillment_Item__c testFulfillmentItem2 = new Fulfillment_Item__c(
            Type__c = 'Training',
            Status__c = 'Ready',
            Fulfillment__c = testFulfillment.Id,
            Order__c = testOrder.Id,
            Order_Item__c = testOrderItem.Id,
            CC_Product__c = testProduct.Id
        );
        insert new List<Fulfillment_Item__c>{testFulfillmentItem1, testFulfillmentItem2};
        
        List<Fulfillment_Item__c> ffItemList = [SELECT Id, Product_SKU__c, AP_Code__c FROM Fulfillment_Item__c];
    }
    
    /*
    @testSetup static void setup() {
        // Create portal account owner
        User accountOwner = new User(
            UserRoleId = [Select Id From UserRole Where PortalType = 'None' LIMIT 1].Id,
            ProfileId = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1].Id,
            FirstName = 'first999',
            LastName = 'last999',
            Email = 'test999@testingARC.com',
            Username = 'test999@testingARC.com' + System.currentTimeMillis(),
            CompanyName = 'ARC999',
            Title = 'title999',
            Alias = 'test999',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8', 
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert accountOwner; 
        
        Bucket_Account_Settings__c bas = new Bucket_Account_Settings__c();
        bas.Bucket_Account_Owner_ID__c ='005d0000001WOeV';
        bas.Bucket_Account_RecordTypeID__c = '012d000000098Wt';
        bas.Default_Bucket_Name__c = 'Bucket Account';
        bas.Maximum_Size_of_Bucket__c = 5000;
        System.runAs(accountOwner) {
            insert bas;  
            testData = phss_cc_TestDataFactory.setupAccountAndProducts();
            products = (List<ccrz__E_Product__c>) testData.get(phss_cc_TestDataFactory.TEST_PRODUCTS);
            Account testAccount = (Account) testData.get(phss_cc_TestDataFactory.TEST_ACCOUNT);
            testOpportunity = phss_cc_TestDataFactory.createInsertTestOpportunity(testAccount);
            List<ccrz__E_Cart__c> testCarts = phss_cc_TestDataFactory.createInsertCartAndCartItems(1, testData, testOpportunity.Id);
            Map<String,Object> testLearningData = phss_cc_TestDataFactory.createInsertTestLearningObjects();
            redwing__ILT_Class__c testILTClass = (redwing__ILT_Class__c) testLearningData.get(phss_cc_TestDataFactory.TEST_ILT_CLASS);
    
            testCart = testCarts[0];
            phss_cc_TestDataFactory.createInsertStoredPayment(1, testOpportunity);
            Map<String, Object> newPO = new Map<String, Object>{
                phss_cc_OrderUtil.NEW_PO_NAME_KEY => 'Test PO',
                phss_cc_OrderUtil.NEW_PO_AMOUNT_KEY => '1000',
                //phss_cc_OrderUtil.NEW_PO_START_DATE_KEY => String.valueOf(Date.today()),
                //phss_cc_OrderUtil.NEW_PO_END_DATE_KEY => String.valueOf(Date.today()+5),
                phss_cc_OrderUtil.NEW_PO_DOSAVE_KEY => true
            };
            Map<String, Object> placeOrderResult = phss_cc_CartController.placeOrderOnCartPO(testOpportunity.Id, testCart.ccrz__EncryptedId__c, newPO);
            Map<String, Object> placeOrderResultExistingPO = phss_cc_OrderUtil.placeOrderOnCartPO(testOpportunity.Id, testCart.ccrz__EncryptedId__c, newPO);
            List<ccrz__E_Order__c> orderList = new List<ccrz__E_Order__c>([SELECT Id FROM ccrz__E_Order__c]);
            List<ccrz__E_OrderItem__c> orderItemList = new List<ccrz__E_OrderItem__c>([SELECT Id FROM ccrz__E_OrderItem__c WHERE ccrz__Order__r.Id =:orderList[0].Id]); 
            for(ccrz__E_Order__c o: orderList) {
                o.ccrz__PONumber__c = '0123456789';
            }
            //update orderList;
            List<ccrz__E_TransactionPayment__c> tpay = new List<ccrz__E_TransactionPayment__c>([SELECT Id FROM ccrz__E_TransactionPayment__c WHERE ccrz__CCOrder__c=:orderList[0].Id]);
            for(ccrz__E_OrderItem__c oi: orderItemList) {
                oi.ILT_Class__c = testILTClass.Id;
                oi.Payment_Category__c = '';
                oi.Unit_Code__c = '00000';
                oi.TS_LOC__c = '0000';
            }
            update orderItemList;
            // Create Instructor
            redwing__ILT_Instructor__c instructor = new redwing__ILT_Instructor__c();
            instructor.redwing__ILT_Class__c=testILTClass.Id;
            instructor.redwing__Instructor__c=accountOwner.Id;
            instructor.redwing__Primary__c=true;
            insert instructor;            
            // Create Fulfillment
            Fulfillment__c f = new Fulfillment__c(Type__c='Invoice',Status__c='Open',Order__c=orderList[0].Id,CC_Transaction_Payment__c=tpay[0].Id);
            insert f;
            // Create Fulfillment Item
            List<Fulfillment_Item__c> fiList = new List<Fulfillment_Item__c>();
            fiList.add(new Fulfillment_Item__c(Type__c='Training',Status__c='Ready',Fulfillment__c=f.Id,Order__c=orderList[0].Id,Order_Item__c=orderItemList[0].Id,CC_Product__c=products[0].Id,ILT_Class__c=testILTClass.Id,Quantity__c=1,Supplemental_Information__c='Test123'));            
            fiList.add(new Fulfillment_Item__c(Type__c='Training',Status__c='Ready',Fulfillment__c=f.Id,Order__c=orderList[0].Id,Order_Item__c=orderItemList[0].Id,CC_Product__c=products[0].Id));
            insert fiList;
            // Create Billing Contact
            Contact testContact = new Contact(FirstName='FirstName1', LastName='LastName1',AccountId=testAccount.Id, Phone='111-222-5555', Email='test@email.com');
            insert testContact;
            // Update Account
            testAccount.SABA_LMS_Code__c = '0123456789';
            testAccount.Payment_Terms__c = 'NET 30';
            testAccount.Special_Invoicing__c = 'DO NOT MAIL';
            testAccount.Saba_Id__c = '0123456789';
            testAccount.Billing_Contact__c = testContact.Id;
            update testAccount;
        }   
    }
    
    static testMethod void testScheduledJob() {
        Test.startTest();     
        PHSS_GenerateCSVFileBatch csvFileBatch = new PHSS_GenerateCSVFileBatch();
        Id batchId = Database.executeBatch(csvFileBatch,100);
        Test.stopTest();
    } 
*/

}