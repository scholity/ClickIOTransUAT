@isTest
public class phss_cc_VoucherUtilTest {

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

    /**
     * @description Creates the test data associated for the contained test functions
     */
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

    @IsTest
    public static void testReserveVouchersForCartItems() {
        setupTestData();

        Test.startTest();
        List<Voucher__c> result = phss_cc_VoucherUtil.reserveVouchersForCartItems(testClassVoucherMap, testClassCourseMap, testClassCartItemMap, testOpportunity.Id);
        Test.stopTest();

        System.assert(result != null);
        if (result != null) {
            System.assert(result.size() > 0);
            if (result.size() > 0) {
                System.assertEquals(testVoucher.Id, result[0].Id);
            }
        }
    }

    @IsTest
    public static void testRequestVouchersForClasses(){
        setupTestData();

        Map<String, Integer> classQuantityMap = new Map<String, Integer>{ testTrainingClass.Id => 1 };

        Test.startTest();
        Map<String, List<Voucher__c>> result = phss_cc_VoucherUtil.requestVouchersForClasses(classQuantityMap);
        Test.stopTest();

        System.assert(result != null);
    }

    @IsTest
    public static void testRequestVouchersForOpportunity() {
        setupTestData();

        Map<Id, Id> productClassMap = new Map<Id, Id>{ testProduct.Id => testTrainingClass.Id };
        Map<String, Object> productQuantityMap = new Map<String, Object>{ testProduct.Id => Integer.valueOf('1') };

        Test.startTest();
        Map<String, List<Voucher__c>> result = phss_cc_VoucherUtil.requestVouchersForOpportunity(productClassMap, productQuantityMap, testOpportunity.Id);
        Test.stopTest();

        System.assert(result != null);
    }

    @IsTest
    public static void testReserveVouchersForOpportunity() {
        setupTestData();

        Map<Id, Id> productClassMap = new Map<Id, Id>{ testProduct.Id => testTrainingClass.Id };
        Map<String, Object> productQuantityMap = new Map<String, Object>{ testProduct.Id => Integer.valueOf('1') };
        Map<String, List<Voucher__c>> voucherMap = new Map<String, List<Voucher__c>>{ testTrainingClass.Id => new List<Voucher__c>{ testVoucher }};
        Map<String, String> productCartItemMap = new Map<String, String>{ testProduct.Id => testCartItem.Id };

        Boolean didReserveVoucher = false;

        Test.startTest();
        phss_cc_VoucherUtil.reserveVouchersForOpportunity(productClassMap, productQuantityMap, voucherMap, testOpportunity.Id, productCartItemMap);
        for (Voucher__c voucher : [SELECT Status__c FROM Voucher__c WHERE Id = :testVoucher.Id]) {
            List<String> statusList = new List<String>{ phss_cc_VoucherUtil.ISSUED_STATUS, phss_cc_VoucherUtil.TEMP_HOLD_STATUS };
            if (voucher.Status__c != null && statusList.contains(voucher.Status__c)) {
                didReserveVoucher = true;
                break;
            }
        }
        Test.stopTest();

        System.assert(didReserveVoucher);
    }
}