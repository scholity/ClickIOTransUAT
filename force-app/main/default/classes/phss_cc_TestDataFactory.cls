/**
 * Created by dgajwani on 9/20/18.
 */
 
@isTest
public with sharing class phss_cc_TestDataFactory {

    public static final String TEST_EMAIL = 'na@na.com';
    public static final String TEST_CITY = 'Chicago';
    public static final String TEST_COUNTRY = 'US';
    public static final String TEST_ZIPCODE = '12345';
    public static final String TEST_STATE = 'IL';
    public static final String TEST_STREET = '123 N St';
    public static final String TEST_ACC_FIRSTNAME = 'Test';
    public static final String TEST_ACC_LASTNAME = 'Account';
    public static final String TEST_STOREFRONT = 'GeneralStore';
    public static final String TEST_CURRENCY_CODE = 'USD';
    private static final String TEST_OPPORTUNITY = 'Test Opportunity';

    public static final String VISA = 'Visa';
    public static final String AMERICAN_EXPRESS = 'American Express';
    public static final String MASTER_CARD = 'Mastercard';
    public static final String DISCOVER = 'Discover';

    // CyberSource Payment Type Codes
    public static final String PAYMENT_TYPE_VISA = '001';
    public static final String PAYMENT_TYPE_MASTERCARD = '002';
    public static final String PAYMENT_TYPE_AMERICAN_EXPRESS = '003';
    public static final String PAYMENT_TYPE_DISCOVER = '004';

    public static final List<String> TEST_PAYMENT_TYPES = new List<String>{
            '001', '002', '003', '004'
    };

    public static final String TEST_SECRET_1 = 'ad3089e1c54d4c5cb3aa3878a38071e50648eadc372d4909821bca08911b546638b6873b6a614ac68e1a4ed9cb49e495b892d9f7114a461392b1b5fb4e188';
    public static final String TEST_SECRET_2 = '28f64e28e42da1d4973b29781b7d56ed6918f5ce70fb65b4dacb3ca389fff3cff3dc791530366cc417baff1d0856fdbbc6337e91e6cfef24ec095437978cb98f200';
    public static final String TEST_ACCESS_KEY = 'accesskey';
    public static final String TEST_URL_TOKEN_CREATE = 'https://testsecureacceptance.cybersource.com/silent/pay';
    public static final String TEST_PROFILE = 'profile';
    public static final String TEST_SECRET = TEST_SECRET_1 + TEST_SECRET_2;

    public static final String PRODUCT_TYPE_PRODUCT = 'Product';
    public static final String PRODUCT_STATUS_RELEASED = 'Released';

    public static final String TEST_ACCOUNT_GROUP = 'TestAccountGroup';
    public static final String TEST_ACCOUNT = 'TestAccount';
    public static final String TEST_BILLING_CONTACT = 'TestBillingContact';
    public static final String TEST_PRODUCTS = 'TestProducts';
    public static final String TEST_PRICELIST = 'TestPriceList';
    public static final String TEST_ORDER = 'TestOrder';
    public static final String TEST_CREDIT_ORDER = 'TestCreditOrder';
    public static final String TEST_ORDER_WITH_APPLIED_CREDIT = 'TestOrderWithAppliedCredit';
    public static final String TEST_AUTH_TRANSACTION_PAYMENT = 'TestAuthTransactionPayment';
    public static final String TEST_CAPTURE_TRANSACTION_PAYMENT = 'TestCaptureTransactionPayment';
    public static final String TEST_CREDIT_BALANCE_TRANSACTION_PAYMENT = 'TestCreditBalanceTransactionPayment';
    public static final String TEST_REFUND_TRANSACTION_PAYMENT = 'TestRefundTransactionPayment';
    public static final String TEST_STORED_PAYMENT = 'TestStoredPayment';
    public static final String TEST_ENCRYPTED_ID_CART = 'encid-';
    public static final String CART_AUTH_USER_VALIDATED = 'CartAuthUserValidated';
    public static final String CART_STATUS_OPEN = 'Open';
    public static final String CART_TYPE = 'Cart';

    // Learning-related keys
    public static final String TEST_ILT_CLASS = 'TestILTClass';
    public static final String TEST_ILT_EVENT = 'TestILTEvent';
    public static final String TEST_LEARNING = 'TestLearning';
    public static final String TEST_TRAINING_PLAN = 'TestTrainingPlan';
    public static final String TEST_TRAINING_PLAN_SECTION = 'TestTrainingPlanSection';
    public static final String TEST_TRAINING_PLAN_SECTION_ITEM = 'TestTrainingPlanSectionItem';
    public static final String TEST_SKEDULO_JOB = 'TestSkeduloJob';
    public static final String TEST_VOUCHER = 'TestVoucher';

    // Test data for Community Class Search
    public static final Location TEST_COMMUNITY_CLASS_SEARCH_LOCATION = Location.newInstance(37.7843234, -122.40069);
    public static final String TEST_COMMUNITY_CLASS_SEARCH_CITY = 'San Francisco';
    public static final String TEST_COMMUNITY_CLASS_SEARCH_STATE = 'California';
    public static final String TEST_COMMUNITY_CLASS_SEARCH_STATE_ABBREV = 'CA';
    public static final String TEST_COMMUNITY_CLASS_SEARCH_POSTAL_CODE = '94105';
    public static final String TEST_COMMUNITY_CLASS_SEARCH_COUNTRY_CODE = 'US';
    public static final Integer TEST_COMMUNITY_CLASS_SEARCH_RANGE = 25;
    public static final Date TEST_COMMUNITY_CLASS_SEARCH_START_DATE = Date.today().addDays(-1);
    public static final Date TEST_COMMUNITY_CLASS_SEARCH_END_DATE = Date.today().addDays(1);

    // Test data for transaction payments
    public static final String TEST_AUTH_TXN_PMT_TOKEN = 'testTokenForAuthTransactionPayment';

    /**
     * @description Setups a test storefront.
     */
    public static void initCCSettings() {
        ccrz.cc_util_Reflection.createStorefrontSetting(TEST_STOREFRONT);
        Map<String, Map<String, Object>> ccSettings = new Map<String, Map<String, Object>>{
                ccrz.ccApiTestData.LOGIC_SETTINGS => new Map<String, Object>{
                        TEST_STOREFRONT => new Map<String, Object>{
                                'ccLogicAccountGetCurrent' => 'c.phss_cc_ccLogicAccountGetCurrent'
                        }
                }
        };
        ccrz.ccApiTestData.setupData(ccSettings);
    }

    /**
     * @description Returns a test Account.
     *
     * @return
     */
    public static Opportunity createInsertTestOpportunity(Account acc) {
        //Need this custom setting to create an opportunity.
        List<BGST_Profiles__c> ProfilesList = new List<BGST_Profiles__c>();
        BGST_Profiles__c indiv = new BGST_Profiles__c(name = 'Owner Profile',
                Sales_User__c = 'ARC BGST Sales User');
        ProfilesList.add(indiv);
        insert ProfilesList;

        RecordType rt = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'Order_Opportunity'];
        Opportunity testOpportunity = new Opportunity(
                Name = TEST_OPPORTUNITY,
                CloseDate = System.today(),
                StageName = 'Closed Won',
                Type = 'New Business - FS',
                AccountId = acc.Id,
                RecordType = rt
        );
        insert testOpportunity;
        return testOpportunity;
    }


    public static Contract createInsertTestContract(Account account, Opportunity opportunity) {
        Integer contractTerm = 24;      // 24 months
        Date startDate = Date.today();

        Contract contract = new Contract(
                Account__c = account.Id,
                AccountId = account.Id,
                StartDate = startDate,
                ContractTerm = contractTerm,
                Opportunity__c = opportunity.Id
        );

        insert contract;
        return contract;
    }


        /**
         * @description Returns a test Account.
         *
         * @return
         */
    public static Account createInsertTestAccount(ccrz__E_AccountGroup__c accountGroup) {
        Account testAcc = new Account(
                Name = TEST_ACC_FIRSTNAME + ' ' + TEST_ACC_LASTNAME,
                BillingCity = TEST_CITY,
                BillingCountry = TEST_COUNTRY,
                BillingPostalCode = TEST_ZIPCODE,
                BillingState = TEST_STATE,
                BillingStreet = TEST_STREET,
                ccrz__E_AccountGroup__c = accountGroup.Id
        );
        insert testAcc;
        return testAcc;
    }

    public static Contact createInsertTestBillingContact(Account account) {
        List<RecordType> accountRecordTypes =  [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND IsActive = TRUE];
        Bucket_Account_Settings__c orgSettings = new Bucket_Account_Settings__c(Bucket_Account_Owner_ID__c = UserInfo.getUserId(),
                Default_Bucket_Name__c='Default Name',
                Maximum_Size_of_Bucket__c = 1000,
                Bucket_Account_RecordTypeID__c = accountRecordTypes[0].Id,
                SetupOwnerId = UserInfo.getOrganizationId());
//        Bucket_Account_Settings__c userException = new Bucket_Account_Settings__c(Bucket_Account_Owner_ID__c = UserInfo.getUserID(),
//                Default_Bucket_Name__c='Error',
//                Maximum_Size_of_Bucket__c = 1,
//                Bucket_Account_RecordTypeID__c = accountRecordTypes[1].Id,
//                SetupOwnerId =UserInfo.getUserID());

        List<Bucket_Account_Settings__c> bucketAccountSettings = new List<Bucket_Account_Settings__c> { orgSettings };
        insert bucketAccountSettings;

        Contact testContact = new Contact(
                AccountId = account.Id,
                FirstName = TEST_ACC_FIRSTNAME,
                LastName = TEST_ACC_LASTNAME,
                Email = TEST_EMAIL
        );
        insert testContact;

        account.Billing_Contact__c = testContact.Id;
        update account;

        return testContact;
    }

    /**
     * @description Creates a test account group.
     *
     * @return
     */
    public static ccrz__E_AccountGroup__c createInsertTestAccountGroup() {
        ccrz__E_AccountGroup__c accGroup = new ccrz__E_AccountGroup__c(
                Name = 'Default Account Group',
                ccrz__PriceListSelectionMethod__c = 'Best Price'
        );
        insert accGroup;
        return accGroup;
    }

    /**
     * @description Creates and Returns the specified number of CC products.
     *
     * @param size
     *
     * @return
     */
    public static List<ccrz__E_Product__c> createInsertTestProducts(Integer size) {
        String sku = 'TEST';
        List<ccrz__E_Product__c> products = new List<ccrz__E_Product__c>();

        for (Integer i = 0; i < size; i++) {
            ccrz__E_Product__c product = new ccrz__E_Product__c(
                    Name = sku + i,
                    ccrz__SKU__c = sku + i,
                    ccrz__ProductStatus__c = PRODUCT_STATUS_RELEASED,
                    ccrz__ProductType__c = PRODUCT_TYPE_PRODUCT,
                    ccrz__Storefront__c = TEST_STOREFRONT,
                    ccrz__ShortDesc__c = sku,
                    ccrz__ShortDescRT__c = sku,
                    ccrz__StartDate__c = System.today().addYears(-1),
                    ccrz__EndDate__c = System.today().addYears(+1),
                    AP_Code__c = '6200',
                    FCC__c = '32620',
                    OMSProductName__c = '1234'
            );
            products.add(product);
        }

        insert products;
        return products;
    }

    /**
     * @description Creates and returns a test price list.
     *
     * @return
     */
    public static ccrz__E_PriceList__c createInsertTestPricelist() {
        ccrz__E_PriceList__c priceList = new ccrz__E_PriceList__c(
                Name = 'Test Price List',
                ccrz__CurrencyISOCode__c = TEST_CURRENCY_CODE,
                ccrz__Enabled__c = true,
                ccrz__Storefront__c = TEST_STOREFRONT,
                ccrz__StartDate__c = System.today().addYears(-1)
        );
        insert priceList;
        return priceList;
    }

    /**
     * @description Creates and returns a test CC Contact Address.
     *
     * @return
     */
    public static ccrz__E_ContactAddr__c createInsertTestContactAddress(){
        // Test Contact Address
        ccrz__E_ContactAddr__c testAddress = new ccrz__E_ContactAddr__c();
        testAddress.ccrz__FirstName__c = 'Test';
        testAddress.ccrz__LastName__c = 'Test';

        testAddress.ccrz__AddressFirstline__c = 'test Street';
        testAddress.ccrz__City__c = 'test city';
        testAddress.ccrz__State__c = 'test state';
        testAddress.ccrz__StateISOCode__c = 'test State';
        testAddress.ccrz__Country__c = 'test country';
        testAddress.ccrz__CountryISOCode__c = 'US';
        testAddress.ccrz__PostalCode__c = '99999';
        testAddress.ccrz__Partner_Id__c = '12345';
        insert testAddress;
        return testAddress;
    }

    /**
     * @description Creates and inserts a test CC Account Address Book.
     *
     * @param testAccount
     * @param testContactAddress
     *
     * @return
     */
    public static ccrz__E_AccountAddressBook__c createInsertTestAccountAddressBook(Account testAccount, ccrz__E_ContactAddr__c testContactAddress){
        ccrz__E_AccountAddressBook__c testAccountAddressBook = new ccrz__E_AccountAddressBook__c();
        testAccountAddressBook.ccrz__AccountId__c = testAccount.Id;
        testAccountAddressBook.ccrz__E_ContactAddress__c = testContactAddress.Id;
        testAccountAddressBook.ccrz__AddressType__c = 'Billing';
        insert testAccountAddressBook;
        return testAccountAddressBook;
    }

    /**
     * @description Sets the Bill-To/Ship-To addresses on the cart.
     *
     * @param contactAddressId
     * @param addressType
     */
    public static void addAddressToCart(ccrz__E_Cart__c cart, String contactAddressId, String addressType){
        if (addressType == 'Billing') {
            cart.ccrz__BillTo__c = contactAddressId;
        }
        if (addressType == 'Shipping') {
            cart.ccrz__ShipTo__c = contactAddressId;
        }
        upsert cart;
    }


    /**
     * @description Associates the pricelist to an account group.
     *
     * @param accountGroup
     * @param priceList
     *
     * @return
     */
    public static ccrz__E_AccountGroupPriceList__c createInsertTestAccountGroupPriceList(ccrz__E_AccountGroup__c accountGroup, ccrz__E_PriceList__c priceList) {
        ccrz__E_AccountGroupPriceList__c accountGroupPriceList = new ccrz__E_AccountGroupPriceList__c(
                ccrz__AccountGroup__c = accountGroup.Id,
                ccrz__Pricelist__c = priceList.Id,
                ccrz__StartDate__c = System.today().addYears(-1),
                ccrz__Enable__c = true

        );
        insert accountGroupPriceList;
        return accountGroupPriceList;
    }

    /**
     * @description Creates and inserts price list items.
     *
     * @param products
     * @param pricelist
     */
    public static void createInsertPriceListItems(List<ccrz__E_Product__c> products, ccrz__E_PriceList__c pricelist) {

        List<ccrz__E_PriceListItem__c> items = new List<ccrz__E_PriceListItem__c>();

        for (ccrz__E_Product__c product : products) {
            ccrz__E_PriceListItem__c priceListItem = new ccrz__E_PriceListItem__c(
                    ccrz__Price__c = 50,
                    ccrz__Product__c = product.Id,
                    ccrz__Pricelist__c = pricelist.Id,
                    ccrz__StartDate__c = System.today().addYears(-1)
            );
            items.add(priceListItem);

        }
        insert items;
    }

    /**
     * @description Creates a storedPayment on the account of the opportunity.
     *
     * @param products
     * @param pricelist
     */
    public static List<ccrz__E_StoredPayment__c> createInsertStoredPayment(Integer count, Opportunity testOpportunity) {
        return createInsertStoredPayment(count, testOpportunity, phss_cc_StoredPaymentUtil.STORED_PAYMENT_TYPE_PO);
    }

    /**
     * @description Creates 'count' stored payments on the account of the opportunity with the specified account type.
     *
     * @param count
     * @param testOpportunity
     * @param accountType
     *
     * @return
     */
    public static List<ccrz__E_StoredPayment__c> createInsertStoredPayment(Integer count, Opportunity testOpportunity, String accountType) {

        List<ccrz__E_StoredPayment__c> sps = new List<ccrz__E_StoredPayment__c>();

        for (Integer i = 0; i < count; i++) {
            ccrz__E_StoredPayment__c sp = new ccrz__E_StoredPayment__c();
            sp.ccrz__AccountType__c = accountType;
            sp.Original_PO_Amount__c = 1000;
            sp.Remaining_PO_Amount__c = 1000;
            sp.ccrz__DisplayName__c = 'Test ' + accountType.toUpperCase() + ' ' + i;
            sp.ccrz__Account__c = testOpportunity.AccountId;
            sp.ccrz__Enabled__c = true;
            sp.ccrz__Storefront__c = TEST_STOREFRONT;

            sps.add(sp);
        }
        insert sps;
        return sps;
    }

    /**
     * @description Creates orders with transaction payments and a stored payment
     *
     * @param account
     *
     * @return
     */
    public static Map<String, Object> createInsertOrderWithCredit(Account account) {
        ccrz__E_Order__c order = new ccrz__E_Order__c(
                ccrz__Account__c = account.Id,
                NSSCCConnector_SFCC_Order_Number__c = '3114226',
                NSSCCConnector_from_SFCC__c = true
        );
        insert order;

        ccrz__E_TransactionPayment__c authTransactionPayment = new ccrz__E_TransactionPayment__c(
                ccrz__Account__c = account.Id,
                ccrz__AccountType__c = phss_cc_OrderUtil.ACCOUNT_TYPE_CREDIT_CARD,
                ccrz__CCOrder__c = order.Id,
                ccrz__Token__c = TEST_AUTH_TXN_PMT_TOKEN,
                ccrz__TransactionType__c = phss_cc_TransactionPaymentUtil.AUTH_TRANSACTION_TYPE
        );
        insert authTransactionPayment;

        ccrz__E_TransactionPayment__c captureTransactionPayment = new ccrz__E_TransactionPayment__c(
                ccrz__Account__c = account.Id,
                ccrz__AccountType__c = phss_cc_OrderUtil.ACCOUNT_TYPE_CREDIT_CARD,
                ccrz__CCOrder__c = order.Id,
                ccrz__Token__c = 'testToken',
                ccrz__SourceTransactionPayment__c = authTransactionPayment.Id,
                ccrz__TransactionType__c = phss_cc_TransactionPaymentUtil.CAPTURE_TRANSACTION_TYPE
        );
        insert captureTransactionPayment;

        ccrz__E_Order__c creditOrder = new ccrz__E_Order__c(
                ccrz__Account__c = account.Id,
                ccrz__OrderId__c = order.Id,
                NSSCCConnector_SFCC_Order_Number__c = '3114227',
                NSSCCConnector_from_SFCC__c = true
        );
        insert creditOrder;

        ccrz__E_StoredPayment__c storedPayment = new ccrz__E_StoredPayment__c(
                ccrz__AccountType__c = phss_cc_OrderUtil.ACCOUNT_TYPE_CREDIT_BALANCE,
                Original_PO_Amount__c = 150.0,
                Remaining_PO_Amount__c = 150.0
        );
        insert storedPayment;

        ccrz__E_TransactionPayment__c creditTransactionPayment = new ccrz__E_TransactionPayment__c(
                ccrz__Account__c = account.Id,
                ccrz__AccountType__c = phss_cc_OrderUtil.ACCOUNT_TYPE_CREDIT_BALANCE,
                ccrz__CCOrder__c = creditOrder.Id,
                ccrz__ParentTransactionPayment__c = authTransactionPayment.Id,
                ccrz__StoredPayment__c = storedPayment.Id,
                ccrz__Token__c = 'testToken'
        );
        insert creditTransactionPayment;

        ccrz__E_Order__c appliedCreditOrder = new ccrz__E_Order__c(
                ccrz__Account__c = account.Id,
                NSSCCConnector_SFCC_Order_Number__c = '3114228',
                NSSCCConnector_from_SFCC__c = true
        );
        insert appliedCreditOrder;

        ccrz__E_TransactionPayment__c refundTransactionPayment = new ccrz__E_TransactionPayment__c(
                ccrz__Account__c = account.Id,
                ccrz__AccountType__c = phss_cc_OrderUtil.ACCOUNT_TYPE_CREDIT_CARD,
                ccrz__CCOrder__c = appliedCreditOrder.Id,
                ccrz__Comments__c = phss_cc_OrderUtil.REFUND_COMMENT + storedPayment.Id,
                ccrz__Token__c = 'testToken'
        );
        insert refundTransactionPayment;

        Map<String, Object> outputMap = new Map<String, Object>{
                TEST_ORDER => order,
                TEST_CREDIT_ORDER => creditOrder,
                TEST_ORDER_WITH_APPLIED_CREDIT => appliedCreditOrder,
                TEST_AUTH_TRANSACTION_PAYMENT => authTransactionPayment,
                TEST_CAPTURE_TRANSACTION_PAYMENT => captureTransactionPayment,
                TEST_CREDIT_BALANCE_TRANSACTION_PAYMENT => creditTransactionPayment,
                TEST_REFUND_TRANSACTION_PAYMENT => refundTransactionPayment,
                TEST_STORED_PAYMENT => storedPayment
        };
        return outputMap;
    }

    /**
     * @description Creates Account, Account group, Users, PriceLists, Products, PriceListItems.
     *
     * @return
     */
    public static Map<String, Object> setupAccountAndProducts() {
        return setupAccountAndProducts(4);
    }


    /**
     * @description Creates Account, Account group, Users, PriceLists, Products, PriceListItems.
     *
     * @return
     */
    public static Map<String, Object> setupAccountAndProducts(Integer productCount) {

        initCCSettings();
        setCyberSourceConfig();
        enableWalleting();

        //Account/Contact/User details
        ccrz__E_AccountGroup__c accountGroup = createInsertTestAccountGroup();
        Account account = createInsertTestAccount(accountGroup);
        Contact billingContact = createInsertTestBillingContact(account);

        //PriceLists
        ccrz__E_PriceList__c pricelist = createInsertTestPricelist();
        createInsertTestAccountGroupPriceList(accountGroup, pricelist);

        //Products and PriceListItems
        List<ccrz__E_Product__c> products = createInsertTestProducts(productCount);
        createInsertPriceListItems(products, pricelist);

        ccrz.cc_CallContext.currAccountId = account.Id;
        ccrz.cc_CallContext.currAccount = account;
        ccrz.cc_CallContext.effAccountGroup = accountGroup;
        ccrz.cc_CallContext.entAccountGroup = accountGroup;
        ccrz.cc_CallContext.currUserId = UserInfo.getUserId();
        ccrz.cc_CallContext.storefront = TEST_STOREFRONT;
        ccrz.cc_CallContext.userCurrency = TEST_CURRENCY_CODE;
        ccrz.cc_CallContext.userLocale = 'en_US';

        Map<String, Object> outputMap = new Map<String, Object>();

        outputMap.put(TEST_ACCOUNT_GROUP, accountGroup);
        outputMap.put(TEST_ACCOUNT, account);
        outputMap.put(TEST_BILLING_CONTACT, billingContact);
        outputMap.put(TEST_PRODUCTS, products);
        outputMap.put(TEST_PRICELIST, pricelist);

        return outputMap;
    }

    /**
     * @description Creates carts and adds cart items and returns the carts.
     *
     * @param testData
     *
     * @return
     */
    public static List<ccrz__E_Cart__c> createInsertCartAndCartItems(Integer numberOfCarts, Map<String, Object> testData, String opportunityId) {

        List<ccrz__E_Cart__c> testCarts = new List<ccrz__E_Cart__c>();

        for (Integer i = 0; i < numberOfCarts; i++) {

            ccrz__E_Cart__c myCart = new ccrz__E_Cart__c(
                    ccrz__Account__c = ((Account) testData.get(TEST_ACCOUNT)).Id,
                    ccrz__CartStatus__c = CART_STATUS_OPEN,
                    ccrz__CartType__c = CART_TYPE,
                    ccrz__ActiveCart__c = true,
                    ccrz__CurrencyISOCode__c = TEST_CURRENCY_CODE,
                    ccrz__EncryptedId__c = TEST_ENCRYPTED_ID_CART + Crypto.getRandomInteger(),
                    ccrz__ValidationStatus__c = CART_AUTH_USER_VALIDATED,
                    ccrz__User__c = UserInfo.getUserId(),
                    ccrz__Storefront__c = TEST_STOREFRONT,
                    Opportunity__c = opportunityId
            );
            testCarts.add(myCart);
        }


        insert testCarts;


        List<ccrz__E_CartItem__c> cartItems = new List<ccrz__E_CartItem__c>();

        for (ccrz__E_Cart__c cart : testCarts) {
            for (ccrz__E_Product__c product : (List<ccrz__E_Product__c>) testData.get(TEST_PRODUCTS)) {

                ccrz__E_CartItem__c cartItem = new ccrz__E_CartItem__c();
                cartItem.ccrz__Product__c = product.Id;
                cartItem.ccrz__Quantity__c = 2;
                cartItem.ccrz__OriginalQuantity__c = 2;
                cartItem.ccrz__SubAmount__c = 100;
                cartItem.ccrz__Price__c = 50;
                cartItem.ccrz__OriginalItemPrice__c = 50;
                cartItem.ccrz__ItemStatus__c = 'Available';
                cartItem.ccrz__cartItemType__c = 'Major';
                cartItem.ccrz__Cart__c = cart.Id;

                cartItems.add(cartItem);
            }
        }

        insert cartItems;

        return testCarts;
    }

    /**
     * @description Creates training data and Skedulo job-related data
     *
     * @param product
     *
     * @return
     */
    public static Map<String, Object> createInsertTestLearningObjects() {

        Map<String, Object> data = createInsertTestTrainingPlan();
        Map<String, Object> jobData = createInsertTestSkeduloJob((redwing__ILT_Event__c) data.get(TEST_ILT_EVENT));
        data.putAll(jobData);
        return data;
    }

    /**
     * @description Creates a training plan, a section, a section item, and an ILT event
     *
     * @param product
     */
    public static Map<String, Object> createInsertTestTrainingPlan() {
        Id recordTypeId = Schema.SObjectType.redwing__Learning__c.getRecordTypeInfosByName().get('ILT Event').getRecordTypeId();

        // Learning A
        redwing__Learning__c learning = new redwing__Learning__c(Name = 'TEST LEARNING');
        learning.RecordTypeId = recordTypeId;
        insert learning;

        redwing__Learning_Version__c version = new redwing__Learning_Version__c();
        version.redwing__Learning__c = learning.Id;
        version.redwing__Version__c = 1;
        version.redwing__Type__c = 'Published';
        insert version;

        learning.redwing__Current_Published_Version__c = version.Id;
        learning.redwing__Published__c = true;
        update learning;

        redwing__Training_Plan__c trainingPlan = new redwing__Training_Plan__c(Name = 'TEST TRAINING PLAN');
        insert trainingPlan;

        redwing__Training_Plan_Section__c trainingPlanSection = new redwing__Training_Plan_Section__c(Name = 'TEST TRAINING PLAN SECTION');
        trainingPlanSection.redwing__Training_Plan__c = trainingPlan.Id;
        insert trainingPlanSection;

        redwing__Training_Plan_Section_Item__c trainingPlanSectionItem = new redwing__Training_Plan_Section_Item__c();
        trainingPlanSectionItem.redwing__Training_Plan_Section__c = trainingPlanSection.Id;
        trainingPlanSectionItem.redwing__Learning__c = learning.Id;
        insert trainingPlanSectionItem;

        redwing__ILT_Event__c event = new redwing__ILT_Event__c(Name = 'TEST ILT EVENT');
        event.redwing__Learning__c = learning.Id;
        insert event;

        Map<String, Object> data = new Map<String, Object>{
                TEST_LEARNING => learning,
                TEST_TRAINING_PLAN => trainingPlan,
                TEST_TRAINING_PLAN_SECTION => trainingPlanSection,
                TEST_TRAINING_PLAN_SECTION_ITEM => trainingPlanSectionItem,
                TEST_ILT_EVENT => event
        };

        return data;
    }

    /**
     * @description Creates a Skedulo job and corresponding ILT class
     *
     * @param event
     *
     * @return
     */
    public static Map<String, Object> createInsertTestSkeduloJob(redwing__ILT_Event__c event) {

        Id iltRecordTypeId = Schema.SObjectType.redwing__Learning__c.getRecordTypeInfosByName().get('ILT Class').getRecordTypeId();

        // Learning B
        redwing__Learning__c learning = new redwing__Learning__c(Name = 'TEST LEARNING 2');
        learning.RecordTypeId = iltRecordTypeId;
        insert learning;

        redwing__Learning_Version__c version = new redwing__Learning_Version__c();
        version.redwing__Learning__c = learning.Id;
        version.redwing__Version__c = 1;
        version.redwing__Type__c = 'Published';
        insert version;

        redwing__ILT_Event_Class__c eventClass = new redwing__ILT_Event_Class__c();
        eventClass.redwing__ILT_Event__c = event.Id;
        eventClass.redwing__Learning__c = learning.Id;
        insert eventClass;

        sked__Region__c region = new sked__Region__c();
        region.Name = 'TEST REGION';
        region.sked__Timezone__c = 'US/Eastern';
        insert region;

        sked__Location__c location = new sked__Location__c(Name = 'TEST LOCATION');
        location.sked__GeoLocation__Latitude__s = TEST_COMMUNITY_CLASS_SEARCH_LOCATION.latitude;
        location.sked__GeoLocation__Longitude__s = TEST_COMMUNITY_CLASS_SEARCH_LOCATION.longitude;
        location.sked__Region__c = region.Id;
        insert location;

        Course_Catalog__c courseCatalog = new Course_Catalog__c(Name = 'TEST COURSE CATALOG');
        insert courseCatalog;

        Date now = Date.today();
        sked__Job__c job = new sked__Job__c();
        job.sked__Location__c = location.Id;
        job.Temp_Location__c = location.Name;
        job.Temp_Course__c = courseCatalog.Name;
        job.Start_Date__c = now.format();
        job.Start_Time__c = '12:00';
        job.End_Date__c = now.format();
        job.End_Time__c = '12:30';
        job.sked__Region__c = region.Id;
        insert job;

        redwing__ILT_Class__c iltClass = new redwing__ILT_Class__c();
        iltClass.redwing__Learning__c = learning.Id;
        iltClass.Skedulo_Job_Id_External__c = job.Id;
        iltClass.redwing__Start_Date__c = now;
        iltClass.redwing__End_Date__c = now;
        insert iltClass;

        Voucher__c voucher = new Voucher__c();
        voucher.ILT_Class__c = iltClass.Id;
        voucher.Status__c = 'Issued';
        insert voucher;

        Map<String, Object> data = new Map<String, Object>{
                TEST_ILT_CLASS => iltClass,
                TEST_SKEDULO_JOB => job,
                TEST_VOUCHER => voucher
        };

        return data;
    }

    /**
     * @description Creates a geo location
     *
     * @return
     */
    public static Geo_Location__c createInsertTestGeoLocation() {
        Geo_Location__c location = new Geo_Location__c();
        location.Coordinates__Latitude__s = TEST_COMMUNITY_CLASS_SEARCH_LOCATION.latitude;
        location.Coordinates__Longitude__s = TEST_COMMUNITY_CLASS_SEARCH_LOCATION.longitude;
        location.City__c = TEST_COMMUNITY_CLASS_SEARCH_CITY;
        location.State__c = TEST_COMMUNITY_CLASS_SEARCH_STATE;
        location.State_Abbreviation__c = TEST_COMMUNITY_CLASS_SEARCH_STATE_ABBREV;
        location.Postal_Code__c = TEST_COMMUNITY_CLASS_SEARCH_POSTAL_CODE;
        location.Country_Code__c = TEST_COMMUNITY_CLASS_SEARCH_COUNTRY_CODE;
        insert location;

        return location;
    }

    public static Case createInsertTestCase(Account testAccount, Contact billingContact, Contact shippingContact) {
        System.debug('JASON: getting recordTypeId');
        Id caseRecordTypeId = Schema.SObjectType.Case.RecordTypeInfosByName.get('Service Case Read Only').RecordTypeId;
        System.debug('JASON: recordTypeId=' + caseRecordTypeId);

        Switch__c  sw = new Switch__c ();
        sw.Name = 'CaseOwnerHistorySwitch';
        sw.Switch__c = false;
        sw.Switch_Description__c = 'Test';
        insert sw;
        System.debug('JASON: switch inserted: ' + sw);

        //for Validation rule
        Validation_Rules__c supportConfig = Validation_Rules__c.getOrgDefaults();
        supportConfig.Bypass_Rules__c = false;
        upsert supportConfig Validation_Rules__c.Id;
        System.debug('JASON: supportConfig=' + supportConfig);

        try {
            Case testCase = new Case(
                    ContactId = billingContact.Id,
                    Status = 'New',
                    Priority = 'Medium',
                    Type = 'Certificates',
                    Origin = 'Phone',
                    Subject = 'TestCase1',
                    Description = 'This is a test Case',
                    RecordTypeId = caseRecordTypeId
            );
            insert testCase;
            return testCase;

        } catch (Exception e) {
            System.debug('JASON: exception caught: ' + e.getMessage() + ' lineNumber=' + e.getLineNumber() + ' stackTrace=' + e.getStackTraceString());
            throw e;
        }
    }

    /**
     * @description Enables walleting on the storefront.
     */
    public static void enableWalleting() {
        Map<String, Object> wlt = new Map<String, Object>{
                'Name' => 'My Wallet', 'APIName' => 'wlt'
        };
        List<Map<String, Object>> wltMeta = new List<Map<String, Object>>();
        wltMeta.add(new Map<String, Object>{
                'Name' => 'Enabled',
                'Description' => 'Set to TRUE if My Wallet is enabled',
                'APIName' => 'enabled',
                'ExternallySafe' => true,
                'Configurations' => new List<Map<String, Object>>{
                        new Map<String, Object>{
                                'TextValue' => 'TRUE',
                                'Storefront' => TEST_STOREFRONT,
                                'PageName' => 'all',
                                'Name' => 'GeneralStore.all.wlt.enabled'
                        }
                }
        });

        wltMeta.add(new Map<String, Object>{
                'Name' => 'Payments',
                'APIName' => 'pmts',
                'Description' => 'Acceptable payment types for My Wallet add new payment.',
                'ExternallySafe' => false,
                'Configurations' => new List<Map<String, Object>>{
                        new Map<String, Object>{
                                'TextValue' => 'po',
                                'Storefront' => TEST_STOREFRONT,
                                'PageName' => 'all',
                                'Name' => 'GeneralStore.all.wlt.pmts'
                        }
                }
        });

        wlt.put('ConfigurationMetas', wltMeta);
        ccrz.ccApiConfig.setBulk(new Map<String, Object>{
                ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION, ccrz.ccApiConfig.CONFIG_JSON => JSON.serialize(new List<Object>{
                        wlt
                })
        });
    }

    /**
     * @description Inserts Cybersource configuration settings module.
     */
    public static void setCyberSourceConfig() {
        Map<String, Object> pgcs = new Map<String, Object>{
                'Name' => 'CyberSource', 'APIName' => 'pgcs'
        };
        List<Map<String, Object>> pgcsMeta = new List<Map<String, Object>>();
        pgcsMeta.add(new Map<String, Object>{
                'Name' => 'Payment Types',
                'Description' => 'Payment Types',
                'APIName' => 'paymenttypes',
                'ExternallySafe' => false,
                'Configurations' => new List<Map<String, Object>>{
                        new Map<String, Object>{
                                'TextValue' => string.join(TEST_PAYMENT_TYPES, ','),
                                'Storefront' => 'Global',
                                'PageName' => 'all',
                                'Name' => 'Global.all.pgcs.' + 'paymenttypes'
                        }
                }
        });
        pgcsMeta.add(new Map<String, Object>{
                'Name' => 'Secret 1',
                'Description' => 'Secret 1',
                'APIName' => 'secret1',
                'ExternallySafe' => false,
                'Configurations' => new List<Map<String, Object>>{
                        new Map<String, Object>{
                                'TextValue' => TEST_SECRET_1,
                                'Storefront' => 'Global',
                                'PageName' => 'all',
                                'Name' => 'Global.all.pgcs.' + 'secret1'
                        }
                }
        });
        pgcsMeta.add(new Map<String, Object>{
                'Name' => 'Secret 2',
                'Description' => 'Secret 2',
                'APIName' => 'secret2',
                'ExternallySafe' => false,
                'Configurations' => new List<Map<String, Object>>{
                        new Map<String, Object>{
                                'TextValue' => TEST_SECRET_2,
                                'Storefront' => 'Global',
                                'PageName' => 'all',
                                'Name' => 'Global.all.pgcs.' + 'secret2'
                        }
                }
        });
        pgcsMeta.add(new Map<String, Object>{
                'Name' => 'accesskey',
                'Description' => 'accesskey',
                'APIName' => 'accesskey',
                'ExternallySafe' => false,
                'Configurations' => new List<Map<String, Object>>{
                        new Map<String, Object>{
                                'TextValue' => TEST_ACCESS_KEY,
                                'Storefront' => 'Global',
                                'PageName' => 'all',
                                'Name' => 'Global.all.pgcs.' + 'accesskey'
                        }
                }
        });
        pgcsMeta.add(new Map<String, Object>{
                'Name' => 'Profile',
                'Description' => 'Profile',
                'APIName' => 'profile',
                'ExternallySafe' => false,
                'Configurations' => new List<Map<String, Object>>{
                        new Map<String, Object>{
                                'TextValue' => TEST_PROFILE,
                                'Storefront' => 'Global',
                                'PageName' => 'all',
                                'Name' => 'Global.all.pgcs.' + 'profile'
                        }
                }
        });
        pgcsMeta.add(new Map<String, Object>{
                'Name' => 'urltokencreate',
                'Description' => 'urltokencreate',
                'APIName' => 'urltokencreate',
                'ExternallySafe' => false,
                'Configurations' => new List<Map<String, Object>>{
                        new Map<String, Object>{
                                'TextValue' => TEST_URL_TOKEN_CREATE,
                                'Storefront' => 'Global',
                                'PageName' => 'all',
                                'Name' => 'Global.all.pgcs.' + 'urltokencreate'
                        }
                }
        });
        pgcs.put('ConfigurationMetas', pgcsMeta);
        ccrz.ccApiConfig.setBulk(new Map<String, Object>{
                ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION, ccrz.ccApiConfig.CONFIG_JSON => JSON.serialize(new List<Object>{
                        pgcs
                })
        });
    }
}