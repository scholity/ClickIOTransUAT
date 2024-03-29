@isTest(SeeAllData=false)
public class PHSS_RegistrationControllerTest {
    
    @isTest static void testProcessPostAvailability(){
        
        generateTestData();
        
        req.requestBody = Blob.valueOf(generateJSON('availability', testITLClass.Id));
        
        RestContext.request = req;
        
        RestContext.response= res;
        
        Test.startTest();
        
        PHSS_RegistrationController.processPost(); //test classroom
        
        req.requestBody = Blob.valueOf(generateJSON('availability', testLearning.Id));
        
        PHSS_RegistrationController.processPost(); //test online
        
        req.requestBody = Blob.valueOf(generateJSON('availability', testAccount.Id));
        
        PHSS_RegistrationController.processPost(); //test not online or classroom
        
        Test.stopTest();
    }
    
    @isTest static void testProcessPostEnroll(){
        
        generateTestData();
        
        req.requestBody = Blob.valueOf(generateJSON('enroll', testITLClass.Id));
        
        RestContext.request = req;
        
        RestContext.response= res;
        
        Test.startTest();
        
        PHSS_RegistrationController.processPost();
        
        Test.stopTest();
    }
    
    @isTest static void testProcessGet(){
        
        generateTestData();
        
        res.responseBody = Blob.valueOf('{"test":"response"}');
        
        Test.startTest();
        
        // PHSS_RegistrationController.processGet();
        
        Test.stopTest();
        
    }
    
    @isTest static void testInnerClasses(){
        
        PHSS_RegistrationController.AvailabilityResponseBody AvailabilityResponseBody = new PHSS_RegistrationController.AvailabilityResponseBody();
        
        system.assertNotEquals(AvailabilityResponseBody.validateCreateOrder, null);
        
        PHSS_RegistrationController.EnrollResponseBody EnrollResponseBody = new PHSS_RegistrationController.EnrollResponseBody();
        
        system.assertNotEquals(EnrollResponseBody.createOrder, null);
        
        PHSS_RegistrationController.ErrorResponseBody ErrorResponseBody = new PHSS_RegistrationController.ErrorResponseBody();
        
        system.assertNotEquals(ErrorResponseBody.status, null);
        
        PHSS_RegistrationController.ValidateCreateOrder ValidateCreateOrder = new PHSS_RegistrationController.ValidateCreateOrder();
        
        system.assertNotEquals(ValidateCreateOrder.status, null);
        
        system.assertNotEquals(ValidateCreateOrder.remainingQuantity, null);
        
        PHSS_RegistrationController.VCOStatus VCOStatus = new PHSS_RegistrationController.VCOStatus();
        
        system.assertNotEquals(VCOStatus.code, null);
        
        system.assertNotEquals(VCOStatus.description, null);
        
        PHSS_RegistrationController.CreateOrder CreateOrder = new PHSS_RegistrationController.CreateOrder();
        
        system.assertNotEquals(CreateOrder.status, null);
        
        system.assertNotEquals(CreateOrder.commerceItems, null);
        
        PHSS_RegistrationController.COCommerceItems COCommerceItems = new PHSS_RegistrationController.COCommerceItems();
        
        system.assertNotEquals(COCommerceItems.orderItemId, null);
        
        system.assertNotEquals(COCommerceItems.commerceItemId, null);
        
        PHSS_RegistrationController.COStatus COStatus = new PHSS_RegistrationController.COStatus();
        
        system.assertNotEquals(COStatus.code, null);
        
        system.assertNotEquals(COStatus.description, null);
        
        PHSS_RegistrationController.StudentItems StudentItems = new PHSS_RegistrationController.StudentItems();
        
        system.assertNotEquals(StudentItems.FirstName, null);
        
        system.assertNotEquals(StudentItems.LastName, null);
        
        system.assertNotEquals(StudentItems.Email, null);
        
        system.assertNotEquals(StudentItems.Phone, null);
        
        system.assertNotEquals(StudentItems.VoucherId, null);
       
    }
            
    private static String generateJSON(String action, String offeringId){
        return ''
            +'{"action":"'+action+'",'
            +'"paymentInformation":"CREDIT_CARD|VISA",'
            +'"customer":{"email":"newredcrosslearner@gmail.com","phone":"3451234567","firstName":"Maxwell","lastName":"Smart"},'
            +'"orderId":"testOrderId",'
            +'"couponId":"Coup09734550",'
            +'"commerceItems":[{"commerceItemId":"PHDEV00022049-1","offeringId":"'+offeringId+'","listPrice":15.00,"discount":10.00, "itemTotal":"5.00"}],'
            +'"unitCode":"30036",'
            +'"offeringId":"'+offeringId+'"}';
    }
    
    private static Redwing__ILT_Class__c testITLClass;
    
    private static Account testAccount;
    
    private static redwing__Learning__c testLearning;
            
    private static RestRequest req;
        
    private static RestResponse res;
    
    private static void generateTestData(){
        
        req = new RestRequest();
        
        res = new RestResponse();
        
        req.requestURI = '/services/apexrest/PHSS/register2';
        
        req.httpMethod = 'POST';
        
        testAccount = new Account(
            Name='SalesforcetestOrg',
            BillingStreet='24 Willie Mays Plaza',
            BillingCity='San Francisco',
            BillingState='California',
            BillingPostalCode='94017',
            BillingCountry='USA',
            Phone='9934200234'
        );
        insert testAccount;
        
        testLearning = new redwing__Learning__c(
            Name = 'testLearning',
            redwing__Published__c = true,
            RecordTypeId = Schema.SObjectType.redwing__Learning__c.getRecordTypeInfosByName().get('ILT Event').getRecordTypeId()
        );
        insert testLearning;
        
        testITLClass = new Redwing__ILT_Class__c(
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
        
        redwing__Training_Plan__c testLearningPlan = new redwing__Training_Plan__c(
            Name = 'testLearningPlan'
        );
        insert testLearningPlan;
        
        redwing__Training_Plan_Section__c testLearningPlanSection = new redwing__Training_Plan_Section__c(
            Name = 'Test Plan Section',
            redwing__Training_Plan__c = testLearningPlan.Id
        );
        insert testLearningPlanSection;

        redwing__Training_Plan_Section_Item__c testLearningPlanSectionItem = new redwing__Training_Plan_Section_Item__c(
            redwing__Learning__c = testLearning.Id,
            redwing__Training_Plan_Section__c = testLearningPlanSection.Id
        );
        insert testLearningPlanSectionItem;
        
        Voucher__c testVoucher = new Voucher__c(
            ILT_Class__c = testITLClass.Id,
            Learning_Plan__c = testLearningPlan.Id,
            Status__c = 'Claimed',
            RCO_Order_Id__c = 'testOrderId'
        );
        
        Voucher__c testVoucher2 = new Voucher__c(
            ILT_Class__c = testITLClass.Id,
            Learning_Plan__c = testLearningPlan.Id,
            Status__c = 'Temp Hold',
            RCO_Order_Id__c = 'testOrderId'
        );
        
        Voucher__c testVoucher3 = new Voucher__c(
            Online_Class__c = testLearning.Id,
            Learning_Plan__c = testLearningPlan.Id,
            Status__c = 'Claimed',
            RCO_Order_Id__c = 'testOrderId'
        );
        insert new List<Voucher__c>{testVoucher, testVoucher2, testVoucher3};
    }

}