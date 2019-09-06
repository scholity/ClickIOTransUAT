@isTest
public class phss_cc_VoucherUtilTestSJC {
    /**
     * @description Creates the test data associated for the contained test functions
     */
    
    private static Account testAccount;
    private static Opportunity testOpportunity;
    private static ccrz__E_CartItem__c testCartItem;
    private static ccrz__E_Product__c testProduct;
    private static redwing__ILT_Class__c testTrainingClass;
    private static Voucher__c testVoucher;
    private static Map<String, String> testClassCartItemMap;
    private static Map<String, String> testClassCourseMap;
    private static Map<String, Integer> testClassQuantityMap;
    private static Map<String, List<Voucher__c>> testClassVoucherMap;
    
    
    private static void setupTestData() {
        Map<String, Object> testData = phss_cc_TestDataFactory.setupAccountAndProducts(1);
        testAccount = (Account) testData.get(phss_cc_TestDataFactory.TEST_ACCOUNT);

        List<ccrz__E_Product__c> products = (List<ccrz__E_Product__c>) testData.get(phss_cc_TestDataFactory.TEST_PRODUCTS);
        testProduct = products[0];

        testOpportunity = phss_cc_TestDataFactory.createInsertTestOpportunity(testAccount);

        List<ccrz__E_Cart__c> carts = phss_cc_TestDataFactory.createInsertCartAndCartItems(1, testData, testOpportunity.Id);
        ccrz__E_Cart__c cart = carts[0];
        List<ccrz__E_CartItem__c> cartItems = [SELECT Id FROM ccrz__E_CartItem__c WHERE ccrz__Cart__c = :cart.Id];
        testCartItem = cartItems[0];

        testData = phss_cc_TestDataFactory.createInsertTestLearningObjects();
        testTrainingClass = (redwing__ILT_Class__c) testData.get(phss_cc_TestDataFactory.TEST_ILT_CLASS);
        testVoucher = (Voucher__c) testData.get(phss_cc_TestDataFactory.TEST_VOUCHER);

        // build maps
        testClassQuantityMap = new Map<String, Integer>{ testTrainingClass.Id => 1 };
        testClassVoucherMap = new Map<String, List<Voucher__c>>{ testTrainingClass.Id => new List<Voucher__c>{ testVoucher } };
        testClassCourseMap = new Map<String, String>{ testTrainingClass.Id => testProduct.Id };
        testClassCartItemMap = new Map<String, String>{ testTrainingClass.Id => testCartItem.Id };
    }
    
    static testMethod void myUnitTest(){


        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Bucket Account').getRecordTypeId();

        //Bucket Custom settings
        Bucket_Account_Settings__c bas = Bucket_Account_Settings__c.getOrgDefaults();
        bas.Bucket_Account_Owner_ID__c = UserInfo.getUserID();
        bas.Bucket_Account_RecordTypeID__c = recordTypeId;
        bas.Default_Bucket_Name__c = 'Bucket Account';
        bas.Maximum_Size_of_Bucket__c = 5000;
        insert bas;

        Account acc = new Account();
        acc.Name = 'TestAccount';
        acc.BillingStreet = '24 Willie Mays Plaza kryan';
        acc.BillingCity = 'San Fran';
        acc.BillingState = 'Cali';
        acc.BillingPostalCode = '94018';
        acc.BillingCountry = 'US';
        acc.Phone = '9876543219';
        insert acc;

        Contact con = new Contact();
        con.FirstName = 'Contact';
        con.LastName = 'Test';
        con.Email = 'testCon@gmail.com';
        con.Account = acc;
        insert con;

        //Opportunity Creation
        List<BGST_Profiles__c> ProfilesLists = new List<BGST_Profiles__c>();
        BGST_Profiles__c indivl = new BGST_Profiles__c();
        indivl.name = 'Owner Profile';
        indivl.Sales_User__c = 'ARC BGST Sales User';
        ProfilesLists.add(indivl);
        insert ProfilesLists;

        //create an opportunity To fire the trigger on insert
        Opportunity opp1 = TestUtil.createOpportunity(acc.Id, 'Interview', false);
        opp1.Pricing_Approval_Level__c = Constants.APPROVAL_LEVEL_MOM;
        insert opp1;

        redwing__Learning__c learning = new redwing__Learning__c();
        learning.Name = 'Test learning';
        learning.redwing__Published__c = true;
        learning.RecordTypeId = Schema.SObjectType.redwing__Learning__c.getRecordTypeInfosByName().get('ILT Event').getRecordTypeId();
        insert learning;

        redwing__Learning__c learning2 = new redwing__Learning__c();
        learning.Name = 'Test learning 2';
        learning.redwing__Published__c = true;
        learning.RecordTypeId = Schema.SObjectType.redwing__Learning__c.getRecordTypeInfosByName().get('ILT Event').getRecordTypeId();
        insert learning2;

        redwing__ILT_Event__c ilEvent = new redwing__ILT_Event__c();
        ilEvent.redwing__Learning__c = learning.Id;
        insert ilEvent;

        sked__Location__c objLocation = new sked__Location__c();

        objLocation.Name = 'Test';
        objLocation.sked__Type__c = 'Community';
        objLocation.sked__Address__c = '401 S Monroe St, Little Rock, AR, 72206';
        insert objLocation;

        redwing__Training_Plan__c lPlan = new redwing__Training_Plan__c();
        lPlan.Name = 'Test Plan';
        insert lPlan;

        redwing__Training_Plan_Section__c lPlanSection = new redwing__Training_Plan_Section__c();
        lPlanSection.Name = 'Test Plan Section';
        lPlanSection.redwing__Training_Plan__c = lPlan.Id;
        insert lPlanSection;

        redwing__Training_Plan_Section_Item__c lPlanSectionItem = new redwing__Training_Plan_Section_Item__c();
        lPlanSectionItem.redwing__Learning__c = learning.Id;
        lPlanSectionItem.redwing__Training_Plan_Section__c = lPlanSection.Id;
        insert lPlanSectionItem;

        sked__Region__c region = new sked__Region__c();
        region.Name = 'Test Region';
        region.sked__Timezone__c = 'Indian/Coscos';
        insert region;

        //Create ILT Class Record
        Redwing__ILT_Class__c clsRecord = new Redwing__ILT_Class__c();
        clsRecord.Skedulo_Account__c = acc.id;
        clsRecord.redwing__End_Date__c = Date.Parse('12/19/2018');
        clsRecord.redwing__End_Time__c= '13:00';
        clsRecord.redwing__Start_Date__c = Date.Parse('12/19/2018');// Assuming Start date = End date
        clsRecord.redwing__Start_Time__c = '12:00';
        clsRecord.Name = 'Test';
        clsRecord.redwing__Learning__c = learning.Id;
        insert clsRecord;

        Voucher__c  v = new Voucher__c();
        v.ILT_Class__c = clsRecord.id;
        v.Learning_Plan__c = lPlan.Id;
        v.Status__c = 'Issued';
        insert v;
        Voucher__c  v2 = new Voucher__c();        
        v2.ILT_Class__c = clsRecord.id;
        v2.Learning_Plan__c = lPlan.Id;
        v2.Status__c = 'Issued';
        insert v2;    
        Voucher__c  v3 = new Voucher__c();        
        v3.ILT_Class__c = clsRecord.id;
        v3.Learning_Plan__c = lPlan.Id;
        v3.Status__c = 'Issued';
        insert v3;  
        Voucher__c  v4 = new Voucher__c();        
        v4.ILT_Class__c = clsRecord.id;
        v4.Learning_Plan__c = lPlan.Id;
        v4.Status__c = 'Issued';
        insert v4;          

        ccrz__E_Product__c product1 = new ccrz__E_Product__c();
        product1.Name = 'Test Prod';
        product1.ccrz__SKU__c = String.ValueOf(System.Now());
        product1.ccrz__Quantityperunit__c = 2.0;
        product1.ccrz__StartDate__c = System.Today().addDays(2);
        product1.ccrz__EndDate__c = System.Today().addDays(20);
        product1.LMS_Learning_Plan__c = lPlan.id;
        insert product1;
        
        Map<String, List<Voucher__c>> mapClassIdVoucherList = new Map<String, List<Voucher__c>>();
        Map<String, List<Voucher__c>> voucherMap = new Map<String, List<Voucher__c>>();        
        Map<String, Integer> classIdQtyMap = new Map<String, Integer>();
        Map<Id, Id> productClassIdMap = new Map<Id, Id>();
        Map<String, Object> productQuantityMap = new Map<String, Integer>();
        List<Voucher__c> voucherList = new List<Voucher__c>();
        Map<String, String> productCartItemMap = new Map<String,String>();
        
        classIdQtyMap.put((String)clsRecord.Id, 1);
        productClassIdMap.put(product1.Id, clsRecord.Id);
        productQuantityMap.put((String)product1.Id, 1);
        voucherList.add(v3);
        voucherList.add(v4);
        voucherMap.put((String)clsRecord.Id, voucherList);
        productCartItemMap.put((String)product1.Id, null);
        
        mapClassIdVoucherList = phss_cc_VoucherUtil.requestVouchersForClasses(classIdQtyMap);
        mapClassIdVoucherList = phss_cc_VoucherUtil.requestVouchersForOpportunity(productClassIdMap, productQuantityMap, (String)opp1.Id);
  		phss_cc_VoucherUtil.reserveVouchersForOpportunity(productClassIdMap, productQuantityMap, voucherMap, (String)opp1.Id, productCartItemMap);
        
		setupTestData();
       
        List<Voucher__c> result = phss_cc_VoucherUtil.reserveVouchersForCartItems(testClassVoucherMap, testClassCourseMap, testClassCartItemMap, testOpportunity.Id);
      

        System.assert(result != null);
        if (result != null) {
            System.assert(result.size() > 0);
            if (result.size() > 0) {
                System.assertEquals(testVoucher.Id, result[0].Id);
            }
        }
    }
}