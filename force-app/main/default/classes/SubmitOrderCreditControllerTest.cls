@isTest
public class SubmitOrderCreditControllerTest
{
    @testSetup 
    public static void initTestData()
    {
        Account a = new Account();
        a.Name='SalesforcetestOrg';
        a.DM_External_Id__c ='SalesforcetestOrgtest@test.com';
        a.BillingStreet='24 Willie Mays Plaza';
        a.BillingCity='San Francisco';
        a.BillingState='California';
        a.BillingPostalCode='94017';
        a.BillingCountry='USA';
        a.Phone='9934200234'; 
        insert a;
        
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Bucket Account').getRecordTypeId();
        
        //Bucket Custom settings
        Bucket_Account_Settings__c bas = Bucket_Account_Settings__c.getOrgDefaults();
        bas.Bucket_Account_Owner_ID__c = UserInfo.getUserID();
        bas.Bucket_Account_RecordTypeID__c = recordTypeId;
        bas.Default_Bucket_Name__c = 'Bucket Account';
        bas.Maximum_Size_of_Bucket__c = 5000;
        insert bas;
        
        Contact con = new Contact();
        con.FirstName = '';
        con.LastName = 'SalesforcetestOrg';
        con.Email = 'test@test.com';
        con.AccountId = a.id;
        insert con;
        
        redwing__Learning__c learning = new redwing__Learning__c();
        learning.Name = 'Test learning';
        learning.redwing__Published__c = true;
        learning.RecordTypeId = Schema.SObjectType.redwing__Learning__c.getRecordTypeInfosByName().get('ILT Event').getRecordTypeId();
        insert learning;
        
        //Create Learning Plan
        redwing__Training_Plan__c lPlan2 = new redwing__Training_Plan__c();
        lPlan2.Name = 'Plan2';
        insert lPlan2;
        
        // Create Product
        
        ccrz__E_Product__c product1 = new ccrz__E_Product__c();
        product1.Name = 'Test Prod';
        product1.ccrz__SKU__c = String.ValueOf(System.Now());
        product1.ccrz__Quantityperunit__c = 2.0;
        product1.ccrz__StartDate__c =  System.Today().addDays(2);
        product1.ccrz__EndDate__c = System.Today().addDays(20);
        product1.LMS_Learning_Plan__c = lPlan2.id;
        insert product1;
        
        //Create ILTClassRecord
        Redwing__ILT_Class__c clsRecord = new Redwing__ILT_Class__c();
        clsRecord.Skedulo_Account__c = a.id;
        clsRecord.redwing__End_Date__c = Date.Parse('12/19/2018');
        clsRecord.redwing__End_Time__c= '13:00';
        clsRecord.redwing__Start_Date__c = Date.Parse('12/19/2018');// Assuming Start date = End date
        clsRecord.redwing__Start_Time__c = '12:00';
        clsRecord.Name = 'Test';
        clsRecord.Learning_Plan__c = lPlan2.Id;
        clsRecord.redwing__Learning__c = learning.Id;
        insert clsRecord;
        
        //create ccOrder
        ccrz__E_Order__c cco=new ccrz__E_Order__c();
        cco.NSSCCConnector_SFCC_Order_Number__c ='3114226';
        cco.NSSCCConnector_from_SFCC__c=true;
        insert cco;
        
        ccrz__E_Order__c cco1 =new ccrz__E_Order__c();
        cco1.NSSCCConnector_SFCC_Order_Number__c ='3114227';
        cco1.NSSCCConnector_from_SFCC__c=true;
        insert cco1;
        
        ccrz__E_Order__c ccoChild =new ccrz__E_Order__c();
        ccoChild.NSSCCConnector_SFCC_Order_Number__c ='3114229';
        ccoChild.NSSCCConnector_from_SFCC__c=true;
        ccoChild.ccrz__Order__c  = cco.Id;
        ccoChild.Is_Return_Order__c  = true;
        insert ccoChild;
        
        ccrz__E_OrderItem__c ccoItems= new ccrz__E_OrderItem__c();
        ccoItems.ccrz__Product__c =product1.Id;
        ccoItems.ccrz__Order__c=cco.id;
        ccoItems.ccrz__Price__c=100;
        ccoItems.ccrz__Quantity__c=2.00;
        ccoItems.ccrz__SubAmount__c=100.00;
        ccoItems.ILT_Class__c=clsRecord.Id;
        ccoItems.ccrz__OrderItemStatus__c = 'Shipped';
        insert ccoItems;
        
        ccrz__E_OrderItem__c ccoItems1 = new ccrz__E_OrderItem__c();
        ccoItems1.ccrz__Product__c =product1.Id;
        ccoItems1.ccrz__Order__c=cco1.id;
        ccoItems1.ccrz__Price__c=100;
        ccoItems1.ccrz__Quantity__c= 1.00;
        ccoItems1.ccrz__SubAmount__c=100.00;
        ccoItems1.ILT_Class__c=clsRecord.Id;
        ccoItems1.ccrz__OrderItemStatus__c = 'Shipped';
        insert ccoItems1;
        
        ccrz__E_OrderItem__c ccoItems2 = new ccrz__E_OrderItem__c();
        ccoItems2.ccrz__Product__c =product1.Id;
        ccoItems2.ccrz__Order__c=ccoChild.id;
        ccoItems2.ccrz__Price__c=100;
        ccoItems2.ccrz__Quantity__c=100.00;
        ccoItems2.ccrz__SubAmount__c=100.00;
        ccoItems2.ILT_Class__c=clsRecord.Id;
        ccoItems2.ccrz__ParentOrderItem__c  = ccoItems.Id;
        ccoItems2.Is_Return__c = true;
        //ccoItems2.ccrz__OrderItemStatus__c = 'Shipped';
        insert ccoItems2;
        
        ccrz__E_TransactionPayment__c ctp= new ccrz__E_TransactionPayment__c(ccrz__CCOrder__c = cco.Id, ccrz__AccountType__c  = 'cc');
        insert ctp;

    }
    
    static testmethod void testgetOnAccountBoolean()
    {
        
        List<ccrz__E_Order__c> ccOrder = [SELECT  Id, ccrz__Order__c FROM ccrz__E_Order__c WHERE NSSCCConnector_SFCC_Order_Number__c ='3114229'];
 
		test.startTest();
        	SubmitOrderCreditController.getOnAccountBoolean(ccOrder[0].Id);
        test.stopTest();
    }
    
    static testmethod void testSubmitOrderCredit()
    {
        
        List<ccrz__E_Order__c> ccOrder = [SELECT  Id, ccrz__Order__c FROM ccrz__E_Order__c WHERE NSSCCConnector_SFCC_Order_Number__c ='3114229'];
 
		test.startTest();
        	SubmitOrderCreditController.submitOrderCredit(ccOrder[0].Id,true);
        test.stopTest();
    }
    
    

}