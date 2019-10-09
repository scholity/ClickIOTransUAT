@isTest
private class CancelOrderItemControllerTest
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
        
        List<BGST_Profiles__c> ProfilesLists = new List<BGST_Profiles__c>();
        BGST_Profiles__c indivl = new BGST_Profiles__c();
        indivl.name = 'Owner Profile';
        indivl.Sales_User__c = 'ARC BGST Sales User';
        ProfilesLists.add(indivl);
        insert ProfilesLists;
        
		Switch__c esettings = new Switch__c();
        esettings.Name = 'EmailMessageServiceSwitch';
        esettings.Switch_Description__c = 'some desc';
        esettings.Switch__c = false;
        insert esettings;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.AccountId = a.Id;
        opp.StageName = 'Approach';
        opp.CloseDate = date.today();
        opp.Pricing_Approval_Level__c = 'Manager';
        insert opp;
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'SalesforcetestOrg';
        con.Email = 'test@test.com';
        con.AccountId = a.id;
        con.NSSCCConnector__Contact_Status__c = 'Created';
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
        cco.Opportunity_Order__c = opp.Id;  
        insert cco;
        
        ccrz__E_Order__c cco1 =new ccrz__E_Order__c();
        cco1.NSSCCConnector_SFCC_Order_Number__c ='3114227';
        cco1.NSSCCConnector_from_SFCC__c=true;
        cco1.Opportunity_Order__c = opp.Id;
        insert cco1;
        
        ccrz__E_Order__c ccoChild =new ccrz__E_Order__c();
        ccoChild.NSSCCConnector_SFCC_Order_Number__c ='3114229';
        ccoChild.NSSCCConnector_from_SFCC__c=true;
        ccoChild.ccrz__Order__c  = cco.Id;
        ccoChild.Is_Return_Order__c  = true;
        ccoChild.Opportunity_Order__c = opp.Id;
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
        
        ccrz__E_TransactionPayment__c ctp= new ccrz__E_TransactionPayment__c();
        insert ctp;

    }
    
    @isTest
    static void testGetOrderItemDetail() 
    {
        List<ccrz__E_OrderItem__c> initOrderItem = [SELECT	Id FROM ccrz__E_OrderItem__c];

        Test.startTest();
        	CancelOrderItemController.getOrderItemDetail(initOrderItem[0].Id);
        Test.stopTest();
    }
    
    @isTest
    static void testGetCreditedOrderItemDetail()
    {
        List<ccrz__E_OrderItem__c> initOrderItem1 = [SELECT Id FROM ccrz__E_OrderItem__c];
        
        Test.startTest();
        	CancelOrderItemController.getCreditedOrderItemDetail(initOrderItem1[0].Id);
        Test.stopTest();
    }
    
    @isTest
    static void testGetCreditedOrderItemCount()
    {
        List<ccrz__E_OrderItem__c> initOrderItem2 = [SELECT Id FROM ccrz__E_OrderItem__c];
        
        Test.startTest();
        	CancelOrderItemController.getCreditedOrderItemCount(initOrderItem2[0].Id);
        Test.stopTest();
    }
    
    @isTest
    static void testCancelOI()
    {
        
        List<ccrz__E_OrderItem__c> initOrderItem3 = [SELECT Id, ccrz__OrderItemStatus__c FROM ccrz__E_OrderItem__c];
        
        Test.startTest();
        	CancelOrderItemController.cancelOI(initOrderItem3[0].Id, 'Course Cancelation', 'Bad Weather', '');
        Test.stopTest();
    }
    
    @isTest
    static void testRefundOI()
    {
        
        List<ccrz__E_OrderItem__c> initOrderItem4 = [SELECT Id, ccrz__OrderItemStatus__c FROM ccrz__E_OrderItem__c WHERE ccrz__Quantity__c = 1];
        
        Test.startTest();
        	CancelOrderItemController.refundOI(initOrderItem4[0].Id, 'Course Cancelation', 'Bad Weather', '', 1 , '10', false, false);
        Test.stopTest();
    }
    
    @isTest
    static void testRefundOI1()
    {
        
        List<ccrz__E_OrderItem__c> initOrderItem4 = [SELECT Id, ccrz__OrderItemStatus__c FROM ccrz__E_OrderItem__c WHERE ccrz__Quantity__c = 1];
        
        ccrz__E_Product__c product2 = new ccrz__E_Product__c();
        product2.Name = 'Test Prod';
        product2.ccrz__SKU__c = 'CMCANCELFEE';
        product2.ccrz__Quantityperunit__c = 2.0;
        product2.ccrz__StartDate__c =  System.Today().addDays(2);
        product2.ccrz__EndDate__c = System.Today().addDays(20);
        insert product2;
        
        Test.startTest();
        	CancelOrderItemController.refundOI(initOrderItem4[0].Id, 'Course Cancelation', 'Bad Weather', '', 1 , '10', false, true);
        Test.stopTest();
    }
    
    
    @isTest
    static void testReplaceOI()
    {
        
        List<ccrz__E_OrderItem__c> initOrderItem4 = [SELECT Id, ccrz__OrderItemStatus__c FROM ccrz__E_OrderItem__c WHERE ccrz__Quantity__c = 2];
        
        Test.startTest();
        	CancelOrderItemController.replaceOI(initOrderItem4[0].Id, 'Course Cancelation', 'Bad Weather', '', 1);
        Test.stopTest();
    }
    
    
    @isTest
    static void testgetILTClassInfomation()
    {
        List<ccrz__E_OrderItem__c> initOrderItem4 = [SELECT Id, ccrz__OrderItemStatus__c FROM ccrz__E_OrderItem__c];
        
        Test.startTest();
        	CancelOrderItemController.getILTClassInfomation(initOrderItem4[0].Id);
        Test.stopTest();
    }    
        
    
    @isTest 
    static void testDecimalToBinary ()
    {
        Test.startTest();
        	CancelOrderItemController.decimalToBinary(2);
        Test.stopTest();
    }
    
    @isTest
    static void testGetDependentMap()
    {
        ccrz__E_OrderItem__c ccOrderItem = new ccrz__E_OrderItem__c ();
        
        Test.startTest();
        	CancelOrderItemController.getDependentMap(ccOrderItem, 'Adjustment_Types__c', 'Reason_Codes__c');
        Test.stopTest();
    }
    
    @isTest
    static void testDropSlectedStudents()
    {
        Account a = new Account();
        a.Name='SalesforcetestOrg';
        a.BillingStreet='24 Willie Mays Plaza';
        a.BillingCity='San Francisco';
        a.BillingState='California';
        a.BillingPostalCode='94017';
        a.BillingCountry='USA';
        a.Phone='9934200234'; 
        insert a;

        // Learning
        redwing__Learning__c learning = new redwing__Learning__c();
        learning.Name = 'Test learning';
        learning.redwing__Published__c = true;
        learning.RecordTypeId = Schema.SObjectType.redwing__Learning__c.getRecordTypeInfosByName().get('Media').getRecordTypeId();
        insert learning;
        
        // Object Location
        sked__Location__c objLocation = new sked__Location__c();
        objLocation.Name = 'Test';
        objLocation.sked__Type__c = 'Community';
        objLocation.sked__Address__c = '401 S Monroe St, Little Rock, AR, 72206';
        insert objLocation;

        // Learning Plan
        redwing__Training_Plan__c lPlan = new redwing__Training_Plan__c();
        lPlan.Name = 'Test Plan';
        insert lPlan;
        
        //Create ILT Class Record
        Redwing__ILT_Class__c clsRecord = new Redwing__ILT_Class__c();
        clsRecord.Skedulo_Account__c = a.id;
        clsRecord.redwing__End_Date__c = Date.Parse('12/19/2018');
        clsRecord.redwing__End_Time__c= '13:00';
        clsRecord.redwing__Start_Date__c = Date.Parse('12/19/2018');// Assuming Start date = End date
        clsRecord.redwing__Start_Time__c = '12:00';
        clsRecord.Name = 'Test';
        clsRecord.redwing__Learning__c = learning.Id;
        insert clsRecord;

        //Create ILT Session record
        redwing__ILT_Session__c sessionRecord = new redwing__ILT_Session__c();
        sessionRecord.redwing__ILT_Class__c = clsRecord.Id;
        sessionRecord.Skedulo_Account__c = a.id;
        sessionRecord.Skedulo_Address__c = objLocation.id;
        sessionRecord.redwing__End_Time__c = '13:00';
        sessionRecord.redwing__Date__c = Date.Parse('12/19/2018');
        sessionRecord.redwing__Start_Time__c = '12:00';
        insert sessionRecord; 

        // Learning Plan Assignment
        redwing__Training_Plan_Assignment__c planAssignment = new redwing__Training_Plan_Assignment__c();
        planAssignment.redwing__Training_Plan__c = lPlan.id; // Retrieved learning plan id based on the course selected in page 1
        planAssignment.redwing__User__c = UserInfo.getUserId();
        planAssignment.External_Id__c = 'priyalakshmi.pp@gmail.com';
        insert planAssignment;

        // Learning Assignment
        redwing__Learning_Assignment__c learningAssignment = new redwing__Learning_Assignment__c();
        learningAssignment.redwing__Learning__c = learning.id; // 
        learningAssignment.External_Id__c = 'priyalakshmi.pp@gmail.com'; 
        learningAssignment.redwing__Training_Plan__c = lPlan.Id;
        insert learningAssignment;
		
        redwing__Learning_Assignment__c learningAssignmentupdate = new redwing__Learning_Assignment__c();
        learningAssignmentupdate.id=learningAssignment.id;
        learningAssignmentupdate.redwing__Evaluation_Result__c = 'Passed';
        learningAssignmentupdate.Grade_Reason__c = 'Reason 2'; // Retrieve learning id from page 1
        learningAssignmentupdate.Grade_Additional_Info__c = 'Reason 2'; 
        update learningAssignmentupdate;
        
        // Achievement Category
        redwing__Achievement_Category__c rac = new redwing__Achievement_Category__c();
        rac.name = 'Skill';
        insert rac;
        
        // Achievement
        redwing__Achievement__c ra = new redwing__Achievement__c();
        ra.redwing__Achievement_Category__c = rac.id;
        insert ra;
        
        // Learning Plan Acheivement
        redwing__Training_Plan_Achievement__c  planAchievement = new redwing__Training_Plan_Achievement__c();
        planAchievement.redwing__Training_Plan__c = lplan.id;
        planAchievement.redwing__Achievement__c = ra.id;
        insert planAchievement;
            
        // Achievement Assignment
        redwing__Achievement_Assignment__c achieveAssign = new redwing__Achievement_Assignment__c();
        achieveAssign.redwing__User__c = UserInfo.getUserId();
        achieveAssign.redwing__Training_Plan_Achievement__c = planAchievement.Id;
        insert achieveAssign;
        
        //Creating Roster Record
        redwing__ILT_Roster__c objRoster = new redwing__ILT_Roster__c();
        objRoster.redwing__ILT_Class__c = clsRecord.id;
        objRoster.redwing__ILT_Session__c = sessionRecord.id;
        objRoster.redwing__User__c = planAssignment.redwing__User__c;
        objRoster.redwing__Learning_Assignment__c = learningAssignmentupdate.id;
        insert objRoster;
        
        Voucher__c  v = new Voucher__c();
        v.User__c = UserInfo.getUserId();
        v.ILT_Class__c = clsRecord.id;
        v.Learning_Plan__c = lPlan.Id;
        v.Status__c = 'Claimed';
        insert v;

        List<Id> rosterIds = new List<Id>();
        rosterIds.add(objRoster.Id);
        
        Test.startTest();
        	CancelOrderItemController.cancelEnrollment(rosterIds);
        Test.stopTest();

    }
    
    @isTest
    static void testdropSlectedStudents1()
    {
        Voucher__c  v = new Voucher__c();
        v.Status__c = 'Issued';
        insert v;
        
        Test.startTest();
        
        	CancelOrderItemController.VoucherWrapper newWrapper = new CancelOrderItemController.VoucherWrapper();
        
                newWrapper.isSelected = true;
                newWrapper.voucherId = v.Id;
                newWrapper.voucherClaim = v.Status__c;
        
        	CancelOrderItemController.dropSlectedStudents('');
        Test.stopTest();
    }
    
    @isTest
    static void testPicklistEntryWrapper()
    {
        Test.startTest();
        	CancelOrderItemController.PicklistEntryWrapper newPickListWrapper = new CancelOrderItemController.PicklistEntryWrapper();
        
            newPickListWrapper.activ		= '';
            newPickListWrapper.defaultValue = '';
            newPickListWrapper.label = '';
            newPickListWrapper.value = '';
            newPickListWrapper.validFor = '';
        Test.stopTest();
    }    
        
    @isTest
    static void testGetVouchers()
    {
        List<ccrz__E_OrderItem__c> initOrderItem5 = [SELECT Id, ccrz__OrderItemStatus__c FROM ccrz__E_OrderItem__c];
        
        Voucher__c  v = new Voucher__c();
        v.Status__c = 'Issued';
        v.CC_Order_Item__c = initOrderItem5[0].Id;
        insert v;
        
        Test.startTest();
        CancelOrderItemController.VoucherWrapper newWrapper = new CancelOrderItemController.VoucherWrapper();
        CancelOrderItemController.getVouchers(initOrderItem5[0].Id);
        Test.stopTest();
    }
    
}