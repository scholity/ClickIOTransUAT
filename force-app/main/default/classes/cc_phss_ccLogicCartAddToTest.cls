/**
 * Created by jbarker on 2019-11-04.
 */

@IsTest
public with sharing class cc_phss_ccLogicCartAddToTest {

    public static Account testAccount;
    public static Opportunity testOpportunity;
    public static ccrz__E_Product__c testMajorProduct;
    public static ccrz__E_Product__c testMinorClassProduct;
    public static ccrz__E_Product__c testMinorProduct;
    public static ccrz__E_Cart__c testCart;
    public static ccrz__E_CartItem__c testMajorCartItem;
    public static ccrz__E_CartItem__c testMinorClassCartItem;
    public static ccrz__E_CartItem__c testMinorInstructorCartItem;
    public static redwing__ILT_Class__c testTrainingClass;


    public static void setupTestData() {
        Map<String, Object> data = phss_cc_TestDataFactory.setupAccountAndProducts(3);
        testAccount = (Account) data.get(phss_cc_TestDataFactory.TEST_ACCOUNT);

        List<ccrz__E_Product__c> products = (List<ccrz__E_Product__c>) data.get(phss_cc_TestDataFactory.TEST_PRODUCTS);
        testMajorProduct = products[0];
        testMinorClassProduct = products[1];
        testMinorProduct = products[2];

        testMinorClassProduct.ccrz__InventoryType__c = cc_phss_ccLogicCartAddTo.FEE_INVENTORY_TYPE;
        update testMinorClassProduct;

        testOpportunity = phss_cc_TestDataFactory.createInsertTestOpportunity(testAccount);

        ccrz__E_Cart__c testCart = new ccrz__E_Cart__c(
                ccrz__Account__c = testAccount.Id,
                ccrz__CartStatus__c = phss_cc_TestDataFactory.CART_STATUS_OPEN,
                ccrz__CartType__c = phss_cc_TestDataFactory.CART_TYPE,
                ccrz__ActiveCart__c = true,
                ccrz__CurrencyISOCode__c = phss_cc_TestDataFactory.TEST_CURRENCY_CODE,
                ccrz__EncryptedId__c = phss_cc_TestDataFactory.TEST_ENCRYPTED_ID_CART + Crypto.getRandomInteger(),
                ccrz__ValidationStatus__c = phss_cc_TestDataFactory.CART_AUTH_USER_VALIDATED,
                ccrz__User__c = UserInfo.getUserId(),
                ccrz__Storefront__c = phss_cc_TestDataFactory.TEST_STOREFRONT,
                Opportunity__c = testOpportunity.Id
        );
        insert testCart;

        testMajorCartItem = new ccrz__E_CartItem__c(
                ccrz__Product__c = testMajorProduct.Id,
                ccrz__Quantity__c = 2,
                ccrz__OriginalQuantity__c = 2,
                ccrz__SubAmount__c = 100,
                ccrz__Price__c = 50,
                ccrz__OriginalItemPrice__c = 50,
                ccrz__ItemStatus__c = 'Available',
                ccrz__cartItemType__c = cc_phss_ccLogicCartAddTo.MAJOR_CART_ITEM_TYPE,
                ccrz__Cart__c = testCart.Id
        );

        testMinorClassCartItem = new ccrz__E_CartItem__c(
                ccrz__cartItemType__c = cc_phss_ccLogicCartAddTo.MINOR_CART_ITEM_TYPE,
                ccrz__Cart__c = testCart.Id,
                ccrz__ItemStatus__c = 'Available',
                ccrz__OriginalItemPrice__c = 10,
                ccrz__OriginalQuantity__c = 2,
                ccrz__Price__c = 10,
                ccrz__Product__c = testMinorClassProduct.Id,
                ccrz__ProductType__c = cc_phss_ccLogicCartAddTo.PRODUCT_PRODUCT_TYPE,
                ccrz__Quantity__c = 2,
                ccrz__SubAmount__c = 20,
                ccrz__UnitOfMeasure__c = cc_phss_ccLogicCartAddTo.CLASS_UNIT_OF_MEASURE
        );

        testMinorInstructorCartItem = new ccrz__E_CartItem__c(
                ccrz__cartItemType__c = cc_phss_ccLogicCartAddTo.MINOR_CART_ITEM_TYPE,
                ccrz__Cart__c = testCart.Id,
                ccrz__ItemStatus__c = 'Available',
                ccrz__OriginalItemPrice__c = 15,
                ccrz__OriginalQuantity__c = 2,
                ccrz__Price__c = 15,
                ccrz__Product__c = testMinorProduct.Id,
                ccrz__ProductType__c = cc_phss_ccLogicCartAddTo.PRODUCT_PRODUCT_TYPE,
                ccrz__Quantity__c = 2,
                ccrz__SubAmount__c = 30,
                ccrz__UnitOfMeasure__c = cc_phss_ccLogicCartAddTo.INSTRUCTOR_UNIT_OF_MEASURE
        );

        List<ccrz__E_CartItem__c> cartItems = new List<ccrz__E_CartItem__c>{
                testMajorCartItem,
                testMinorClassCartItem,
                testMinorInstructorCartItem
        };
        insert cartItems;
    }

    @IsTest
    public static void testConcludeItemMajorAdd() {

        setupTestData();

        String componentKey = testMinorProduct.Id;
        Decimal studentRatio = Decimal.valueOf('1');

        Map<String, Object> compositeProduct = new Map<String, Object>{
                cc_phss_ccLogicCartAddTo.COMPONENT_KEY => componentKey,
                cc_phss_ccLogicCartAddTo.STUDENT_RATIO_KEY => studentRatio
        };

        List<Map<String, Object>> compositeProducts = new List<Map<String, Object>>{ compositeProduct };

        Map<String, Map<String, Object>> productsMap = new Map<String, Map<String, Object>>{
                testMajorProduct.Id => new Map<String, Object>{ cc_phss_ccLogicCartAddTo.COMPOSITE_PRODUCTS_KEY => compositeProducts },
                testMinorClassProduct.Id => new Map<String, Object>{ cc_phss_ccLogicCartAddTo.COMPOSITE_PRODUCTS_KEY => new Map<String, Object>() },
                testMinorProduct.Id => new Map<String, Object>{ cc_phss_ccLogicCartAddTo.COMPOSITE_PRODUCTS_KEY => new Map<String, Object>() }
        };

        Map<String, Object> inputData = new Map<String, Object>{
                ccrz.ccApiCart.CURR_CARTITEM => testMajorCartItem,
                ccrz.cc_hk_Pricing.PARAM_PRODUCT_MAP => productsMap
        };

        cc_phss_ccLogicCartAddTo cartLogic = new cc_phss_ccLogicCartAddTo();
        cartLogic.concludeItemAdd(inputData);

        System.assert(cc_phss_ccLogicCartAddTo.productStudentRatioMap != null);
        System.assertEquals(studentRatio, cc_phss_ccLogicCartAddTo.productStudentRatioMap.get(componentKey));


        inputData = new Map<String, Object>{
                ccrz.ccApiCart.CURR_CARTITEM => testMinorClassCartItem,
                ccrz.cc_hk_Pricing.PARAM_PRODUCT_MAP => productsMap
        };
        Map<String, Object> retData = cartLogic.concludeItemAdd(inputData);
        ccrz__E_CartItem__c cartItem = (ccrz__E_CartItem__c) retData.get(ccrz.ccApiCart.CURR_CARTITEM);
        System.assertEquals(1, cartItem.ccrz__Quantity__c);
        System.assertEquals(10, cartItem.ccrz__SubAmount__c);

        inputData = new Map<String, Object>{
                ccrz.ccApiCart.CURR_CARTITEM => testMinorInstructorCartItem,
                ccrz.cc_hk_Pricing.PARAM_PRODUCT_MAP => productsMap
        };
        retData = cartLogic.concludeItemAdd(inputData);
        cartItem = (ccrz__E_CartItem__c) retData.get(ccrz.ccApiCart.CURR_CARTITEM);
        System.assertEquals(2, cartItem.ccrz__Quantity__c);
        System.assertEquals(30, cartItem.ccrz__SubAmount__c);
    }


    @IsTest
    public static void testHandlePricing() {

        setupTestData();

        Map<String, Object> learningData = phss_cc_TestDataFactory.createInsertTestLearningObjects();
        testTrainingClass = (redwing__ILT_Class__c) learningData.get(phss_cc_TestDataFactory.TEST_ILT_CLASS);
        testTrainingClass.Price_Override__c = 5;
        update testTrainingClass;

        Map<String, Object> lineData = new Map<String, Object>{
                cc_phss_ccLogicCartAddTo.ILT_CLASS_FIELD => testTrainingClass.Id
        };

        Map<String, Object> inputData = new Map<String, Object>{
                ccrz.ccApiCart.CURR_CARTITEM => testMajorCartItem,
                ccrz.ccApiCart.CURR_LINE_DATA => lineData
        };

        cc_phss_ccLogicCartAddTo cartLogic = new cc_phss_ccLogicCartAddTo();
        Map<String, Object> result = cartLogic.handlePricing(inputData);
        ccrz__E_CartItem__c cartItem = (ccrz__E_CartItem__c) result.get(ccrz.ccApiCart.CURR_CARTITEM);

        System.assertEquals(5, cartItem.ccrz__Price__c);
    }


    @IsTest
    public static void testSetCartItemFields() {

        setupTestData();

        Map<String, Object> learningData = phss_cc_TestDataFactory.createInsertTestLearningObjects();
        testTrainingClass = (redwing__ILT_Class__c) learningData.get(phss_cc_TestDataFactory.TEST_ILT_CLASS);

        Map<String, Object> lineData = new Map<String, Object>{
                cc_phss_ccLogicCartAddTo.ILT_CLASS_FIELD => testTrainingClass.Id
        };

        Map<String, Object> inputData = new Map<String, Object>{
                ccrz.ccApiCart.CURR_CARTITEM => testMajorCartItem,
                ccrz.ccApiCart.CURR_LINE_DATA => lineData
        };

        cc_phss_ccLogicCartAddTo cartLogic = new cc_phss_ccLogicCartAddTo();
        Map<String, Object> result = cartLogic.setCartItemFields(inputData);

        ccrz__E_CartItem__c cartItem = (ccrz__E_CartItem__c) result.get(ccrz.ccApiCart.CURR_CARTITEM);
        System.assertEquals(testTrainingClass.Id, cartItem.ILT_Class__c);
    }

}