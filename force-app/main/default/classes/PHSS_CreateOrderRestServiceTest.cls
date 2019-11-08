@isTest
public class PHSS_CreateOrderRestServiceTest {
    public static Id clsRecordId;

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
        
        ccrz__E_OrderItem__c ccoItems= new ccrz__E_OrderItem__c();
        ccoItems.ccrz__Product__c =product1.Id;
        ccoItems.ccrz__Order__c=cco.id;
        ccoItems.ccrz__Price__c=100;
        ccoItems.ccrz__Quantity__c=100.00;
        ccoItems.ccrz__SubAmount__c=100.00;
        ccoItems.ILT_Class__c=clsRecord.Id;
        insert ccoItems;
        
        ccrz__E_TransactionPayment__c ctp= new ccrz__E_TransactionPayment__c();
        insert ctp;

        voucher__c theVoucher = new voucher__c();
        theVoucher.RCO_Order_Id__c = '3114226';
        theVoucher.ILT_Class__c = clsRecord.Id;
        theVoucher.Learning_Plan__c = lplan2.Id;
        insert theVoucher;

    }
    
    static testMethod void testServiceMandatoryOrderNo()
    {
        Redwing__ILT_Class__c clsrec= [Select id from Redwing__ILT_Class__c where Name =:'Test'];
        
        // Get some code coverage
        CreateOrderWrapper.ppTransactionDtls ppdtl = new CreateOrderWrapper.ppTransactionDtls();
        ppdtl.paypalAuthTransactionID = '123';
        ppdtl.paypalAvsCode = '';
        ppdtl.paypalBillingAgreementAcceptedStatus = '';
        ppdtl.payment_method = '';
        ppdtl.paypalCorrelationId = '';
        ppdtl.isPaypalBillingAddressPresent = false;
        ppdtl.paypalEcSetRequestID = '';
        ppdtl.auth_request_amount = '';
        ppdtl.paypalEcSetRequestToken = '';
        ppdtl.auth_capture_amount = '';
        ppdtl.paypalGetDetailsAddressStatus = '';
        ppdtl.approvalStatus = '';
        ppdtl.paypalGetDetailsCorrelationId = '';
        ppdtl.paypalProtectionEligibility = '';
        ppdtl.paypalProtectionEligibilityType = '';
        ppdtl.paypalPayerStatus = '';
        ppdtl.paypalSetRequestCorrelationID = '';
        ppdtl.paypalPayerLastName = '';
        ppdtl.paypalToken = '';
        ppdtl.paypalPayerID = '';
        ppdtl.paypalTransactionID = '';
        ppdtl.paypalPayerFirstName = '';
        ppdtl.requestId = '';
        ppdtl.paypalPayerEmail = '';
        ppdtl.requestToken = '';
        ppdtl.paypalPayerCountry = '';
        ppdtl.transaction_id = '';
        ppdtl.paypalOrigination = '';
        ppdtl.transaction_modification_time = '';
        ppdtl.paypalGetDetailsTaxAmount = '';
        ppdtl.transaction_time = DateTime.Now();
        ppdtl.paypalGetDetailsPayerStatus = '';

        // Get some more code coverage
        CreateOrderWrapper.poTransactionDtls poDtl = new CreateOrderWrapper.poTransactionDtls();
        poDtl.afsReasonCode = '';
        poDtl.approvalStatus = '';
        poDtl.auth_capture_amount = 0.00;
        poDtl.afsResult = '';
        poDtl.auth_request_amount = '';
        poDtl.afsFactorCode = '';
        
        // Get even more code coverage
    	CreateOrderWrapper.ccTransactionDtls ccDtl = new CreateOrderWrapper.ccTransactionDtls();
        ccDtl.cc_exp_year = 2020;
        ccDtl.avsCode = '';
        ccDtl.cc_exp_month = 0;
        ccDtl.authCode = '';
        ccDtl.cc_holder = '';
        ccDtl.auth_request_amount = '';
        ccDtl.cc_last_four = '';
        ccDtl.auth_capture_amount = 0.00;
        ccDtl.cc_num = '';
        ccDtl.approvalStatus = '';
        ccDtl.dmDecision = '';
        ccDtl.afsResult = '';
        ccDtl.is_cc_expired = false;
        ccDtl.afsReasonCode = '';
        ccDtl.masked_cc_number = '';
        ccDtl.afsFactorCode = '';
        ccDtl.offeringTransactionID = '';
        ccDtl.token = '';
        
        RestRequest req = new RestRequest();
        
        req.addHeader('Content-Type', 'application/json'); // Add a JSON Header as it is validated
        
        req.requestURI = '/services/PHSS/createOrder/';
        
        req.httpMethod = 'POST';

        //String JSONMsg = '{ "order": { "student_info": { "student_first_name": "Test", "student_last_name": "Roster", "student_email": "test@test.com" }, "billing_info": { "first_name": "kkk", "last_name": "kkkk", "address1": "12330 Rolater Rd", "address2": "", "city": "Frisco", "postal_code": "75035", "state_code": "TX", "country_code": "US", "phone": "3103334523", "email": "kkvya2@gmail.com" }, "order_header": { "order_no": "", "currency": "USD", "creation_date": "2018-10-01T00:00:00Z", "external_order_status": "", "created_by": "Customer", "shipping_total": 0, "order_total": 25 }, "order_items": { "products": [ { "product_name": "First Aid Online", "product_id": "a5M5B0000008hwIUAQ", "product_type": "offering", "quantity": 1, "price": 25, "adjusted_tax": 0, "price_adjustment_amount": 25 } ] } }, "action": "createOrder" }';
        String JSONMsg = '{"order":{"student_info":{"student_email":"","student_first_name":"","student_last_name":""},"billing_info":{"first_name":"test","last_name":"test","address1":"1236 N ALMA DR","address2":"","city":"ALLEN","postal_code":"75013-4624","state_code":"TX","country_code":"US","phone":"3104569283","email":"kvyas@pfsweb.com"},"shipping_info":{"first_name":"test","last_name":"test","address1":"1236 N ALMA DR","address2":"","city":"ALLEN","postal_code":"75013-4624","state_code":"TX","country_code":"US","phone":"3104569283"},"order_header":{"created_by":"Customer","creation_date":"2019-01-17T19:21:32.000Z","currency":"USD","external_order_status":"","order_no":"29126401","order_total":17.29,"payment_method":"PayPal","shipping_method":"008 - USPS","shipping_total":7.3,"tax_exempt_flag":"False","tax_total":0},"order_transaction":{"storefront":"Customer","paymentProcessorID":"PAYPAL_EXPRESS","transaction_dtls":{"ccTransactionDtls":[],"ppTransactionDtls":[{"approvalStatus":"100","auth_capture_amount":"17.29","auth_request_amount":"17.29","isPaypalBillingAddressPresent":true,"payment_method":"PayPal","paypalAuthTransactionID":"699776138L097251S","paypalAvsCode":"3","paypalBillingAgreementAcceptedStatus":"0","paypalCorrelationId":"2a2b2ad191e8f","paypalEcSetRequestID":"5477528887426036004010","paypalEcSetRequestToken":"AhirLwSTKO/7zewRf/SqEVGn3WAgTqNPusBAnARnMMmkmVdHpN7QgAAAxAKY","paypalGetDetailsAddressStatus":"Confirmed","paypalGetDetailsCorrelationId":"c626f83d2af84","paypalGetDetailsPayerStatus":"unverified","paypalGetDetailsTaxAmount":"0.00","paypalOrigination":"billing","paypalPayerCountry":"US","paypalPayerEmail":"npinnelli@pfsweb.com","paypalPayerFirstName":"Narasimha","paypalPayerID":"PVUMWXWWJCA5U","paypalPayerLastName":"Pinnelli","paypalPayerStatus":"unverified","paypalProtectionEligibility":"Eligible","paypalProtectionEligibilityType":"ItemNotReceivedEligible,UnauthorizedPaymentEligible","paypalSetRequestCorrelationID":"f5702b61c47ec","paypalToken":"EC-74Y121133H521183J","paypalTransactionID":"0277528243006950514011","requestId":"5477528969776635604108","requestToken":"AhjrLwSTKO/8GNHPI9WoEVGn3WAgTqNPusBIm0gXsGM5hk0kyro9JvaEAAAAzgL1","transaction_id":"O-1SJ76863LG935718J","transaction_modification_time":"2019-01-17T19:21:43.000Z","transaction_time":"2019-01-17T19:21:32.000Z"},{"approvalStatus":"100","auth_capture_amount":"17.29","auth_request_amount":"17.29","isPaypalBillingAddressPresent":true,"payment_method":"PayPal","paypalAuthTransactionID":"799786138L097251S","paypalAvsCode":"3","paypalBillingAgreementAcceptedStatus":"0","paypalCorrelationId":"2a2b2ad191e8f","paypalEcSetRequestID":"5477528887426036004010","paypalEcSetRequestToken":"AhirLwSTKO/7zewRf/SqEVGn3WAgTqNPusBAnARnMMmkmVdHpN7QgAAAxAKY","paypalGetDetailsAddressStatus":"Confirmed","paypalGetDetailsCorrelationId":"c626f83d2af84","paypalGetDetailsPayerStatus":"unverified","paypalGetDetailsTaxAmount":"0.00","paypalOrigination":"billing","paypalPayerCountry":"US","paypalPayerEmail":"npinnelli@pfsweb.com","paypalPayerFirstName":"Narasimha","paypalPayerID":"PVUMWXWWJCA5U","paypalPayerLastName":"Pinnelli","paypalPayerStatus":"unverified","paypalProtectionEligibility":"Eligible","paypalProtectionEligibilityType":"ItemNotReceivedEligible,UnauthorizedPaymentEligible","paypalSetRequestCorrelationID":"f5702b61c47ec","paypalToken":"EC-74Y121133H521183J","paypalTransactionID":"0277528241006350814011","requestId":"5477528969776635604108","requestToken":"AhjrLwSTKO/8GNHPI9WoEVGn3WAgTqNPusBIm0gXsGM5hk0kyro9JvaEAAAAzgL1","transaction_id":"O-1SJ76863LG935719J","transaction_modification_time":"2019-01-17T19:21:43.000Z","transaction_time":"2019-01-17T19:21:32.000Z"}],"poTransactionDtls":[]}},' +
                '"order_items":{"products":[{"adjusted_tax":0,"price":9.99,"price_adjustment_amount":9.99,"pricing_type":"External","product_id":"'+String.valueOf(clsrec.Id)+'","product_name":"Pediatric CPR/AED Review","product_type":"Offering","quantity":1,"type":"Major"}]}},"action":"createOrder"}';
        req.requestBody = Blob.valueof(JSONMsg); // Add JSON Message as a POST
        
        RestResponse res = new RestResponse();
        
        RestContext.request = req;
        
        RestContext.response = res;
        Test.startTest();
        PHSS_CreateOrderRestService.JsonResponse rsw = PHSS_CreateOrderRestService.createOrder();
       // ccrz__E_Order__c createdOrder = [Select id,ccrz__BuyerLastName__c from ccrz__E_Order__c where ccrz__BuyerLastName__c =:'Barton'];
       // System.debug('CreatedOrder last name'+createdOrder.ccrz__BuyerLastName__c); 
        //System.assertEquals('Barton',createdOrder.ccrz__BuyerLastName__c);
       // System.debug('CreateRestorderservice>>>>>>'+rsw);
        Test.stopTest();
    }
    
    static testMethod void testService()
    {
        Redwing__ILT_Class__c clsrec= [Select id from Redwing__ILT_Class__c where Name =:'Test'];
        Contact con = [Select id From Contact];
        
        RestRequest req = new RestRequest();
        
        req.addHeader('Content-Type', 'application/json'); // Add a JSON Header as it is validated
        
        req.requestURI = '/services/PHSS/createOrder/';
        
        req.httpMethod = 'POST';
        
        //String  JSONMsg = '{ "order": { "customer_info": { "customer_no": "' + con.id + '", "customer_first_name": "Test", "customer_last_name": "Roster", "email": "test@test.com" }, "billing_info": { "billing_address": { "first_name": "test first name", "last_name": "test last name", "address1": "test address 1", "address2" : "test address 2", "city": "test city", "postal_code": "411014", "state_code": "200", "country_code": "2434", "phone": "1234567890", "email" : "test@test.com" } }, "order_header": { "order_no": "3114226", "currencyval": "532542", "creation_date": "7/21/2017", "external_order_status": "New", "created_by": "store name", "shipping_total": 0, "order_total" : 0, "authorization_status": "test status", "approvalStatus": "test status" }, "order_item": [{ "product_name": "a5M5B0000008hwIUAQ", "product_id": "test product id", "product_type" : "test type", "quantity": 0, "price": 0, "base_price": 0, "price_adjustment_amount": 0, "adjusted_tax": 0 }] } } ';
        //String JSONMsg = '{ "order": { "Student_info": { "student_first_name": "Test", "student_last_name": "Roster", "student_email": "test@test.com" }, "billing_info": { "first_name": "kkk", "last_name": "kkkk", "address1": "12330 Rolater Rd", "address2": "", "city": "Frisco", "postal_code": "75035", "state_code": "TX", "country_code": "US", "phone": "3103334523", "email": "kkvya2@gmail.com" }, "order_header": { "order_no": "00002501", "currency": "USD", "creation_date": "2018-10-01T00:00:00Z", "external_order_status": "", "created_by": "Customer", "shipping_total": 0, "order_total": 25 }, "order_items": { "products": [ { "product_name": "First Aid Online", "product_id": "a5M5B0000008hwIUAQ", "product_type": "offering", "quantity": 1, "price": 25, "adjusted_tax": 0, "price_adjustment_amount": 25 } ] } }, "action": "createOrder" }';
        String JSONMsg = '{"order":{"student_info":{"student_email":"","student_first_name":"","student_last_name":""},"billing_info":{"first_name":"test","last_name":"test","address1":"1236 N ALMA DR","address2":"","city":"ALLEN","postal_code":"75013-4624","state_code":"TX","country_code":"US","phone":"3104569283","email":"kvyas@pfsweb.com"},"shipping_info":{"first_name":"test","last_name":"test","address1":"1236 N ALMA DR","address2":"","city":"ALLEN","postal_code":"75013-4624","state_code":"TX","country_code":"US","phone":"3104569283"},"order_header":{"created_by":"Customer","creation_date":"2019-01-17T19:21:32.000Z","currency":"USD","external_order_status":"","order_no":"3114226","order_total":17.29,"payment_method":"PayPal","shipping_method":"008 - USPS","shipping_total":7.3,"tax_exempt_flag":"False","tax_total":0},"order_transaction":{"storefront":"Customer","paymentProcessorID":"PAYPAL_EXPRESS","transaction_dtls":{"ccTransactionDtls":[],"ppTransactionDtls":[{"approvalStatus":"100","auth_capture_amount":"17.29","auth_request_amount":"17.29","isPaypalBillingAddressPresent":true,"payment_method":"PayPal","paypalAuthTransactionID":"699776138L097251S","paypalAvsCode":"3","paypalBillingAgreementAcceptedStatus":"0","paypalCorrelationId":"2a2b2ad191e8f","paypalEcSetRequestID":"5477528887426036004010","paypalEcSetRequestToken":"AhirLwSTKO/7zewRf/SqEVGn3WAgTqNPusBAnARnMMmkmVdHpN7QgAAAxAKY","paypalGetDetailsAddressStatus":"Confirmed","paypalGetDetailsCorrelationId":"c626f83d2af84","paypalGetDetailsPayerStatus":"unverified","paypalGetDetailsTaxAmount":"0.00","paypalOrigination":"billing","paypalPayerCountry":"US","paypalPayerEmail":"npinnelli@pfsweb.com","paypalPayerFirstName":"Narasimha","paypalPayerID":"PVUMWXWWJCA5U","paypalPayerLastName":"Pinnelli","paypalPayerStatus":"unverified","paypalProtectionEligibility":"Eligible","paypalProtectionEligibilityType":"ItemNotReceivedEligible,UnauthorizedPaymentEligible","paypalSetRequestCorrelationID":"f5702b61c47ec","paypalToken":"EC-74Y121133H521183J","paypalTransactionID":"0277528243006950514011","requestId":"5477528969776635604108","requestToken":"AhjrLwSTKO/8GNHPI9WoEVGn3WAgTqNPusBIm0gXsGM5hk0kyro9JvaEAAAAzgL1","transaction_id":"O-1SJ76863LG935718J","transaction_modification_time":"2019-01-17T19:21:43.000Z","transaction_time":"2019-01-17T19:21:32.000Z"},{"approvalStatus":"100","auth_capture_amount":"17.29","auth_request_amount":"17.29","isPaypalBillingAddressPresent":true,"payment_method":"PayPal","paypalAuthTransactionID":"799786138L097251S","paypalAvsCode":"3","paypalBillingAgreementAcceptedStatus":"0","paypalCorrelationId":"2a2b2ad191e8f","paypalEcSetRequestID":"5477528887426036004010","paypalEcSetRequestToken":"AhirLwSTKO/7zewRf/SqEVGn3WAgTqNPusBAnARnMMmkmVdHpN7QgAAAxAKY","paypalGetDetailsAddressStatus":"Confirmed","paypalGetDetailsCorrelationId":"c626f83d2af84","paypalGetDetailsPayerStatus":"unverified","paypalGetDetailsTaxAmount":"0.00","paypalOrigination":"billing","paypalPayerCountry":"US","paypalPayerEmail":"npinnelli@pfsweb.com","paypalPayerFirstName":"Narasimha","paypalPayerID":"PVUMWXWWJCA5U","paypalPayerLastName":"Pinnelli","paypalPayerStatus":"unverified","paypalProtectionEligibility":"Eligible","paypalProtectionEligibilityType":"ItemNotReceivedEligible,UnauthorizedPaymentEligible","paypalSetRequestCorrelationID":"f5702b61c47ec","paypalToken":"EC-74Y121133H521183J","paypalTransactionID":"0277528241006350814011","requestId":"5477528969776635604108","requestToken":"AhjrLwSTKO/8GNHPI9WoEVGn3WAgTqNPusBIm0gXsGM5hk0kyro9JvaEAAAAzgL1","transaction_id":"O-1SJ76863LG935719J","transaction_modification_time":"2019-01-17T19:21:43.000Z","transaction_time":"2019-01-17T19:21:32.000Z"}],"poTransactionDtls":[]}},' +
                '"order_items":{"products":[{"adjusted_tax":0,"price":9.99,"price_adjustment_amount":9.99,"pricing_type":"External","product_id":"'+String.valueOf(clsrec.Id)+'","product_name":"Pediatric CPR/AED Review","product_type":"Offering","quantity":1,"type":"Major"}]}},"action":"createOrder"}';
        req.requestBody = Blob.valueof(JSONMsg); // Add JSON Message as a POST
        
        RestResponse res = new RestResponse();
        
        RestContext.request = req;
        
        RestContext.response = res;
        Test.startTest();
        PHSS_CreateOrderRestService.createOrder(); 
        PHSS_CreateOrderRestService.JsonResponse rsw = PHSS_CreateOrderRestService.createOrder(); 
        System.debug('CreateRestorderservice>>>>>>'+rsw);
        Test.stopTest();
    }
    
    static testMethod void testService2()
    {
        Redwing__ILT_Class__c clsrec= [Select id from Redwing__ILT_Class__c where Name =:'Test'];
        Contact con = [Select id From Contact];
        
        RestRequest req = new RestRequest();
        
        req.addHeader('Content-Type', 'application/json'); // Add a JSON Header as it is validated
        
        req.requestURI = '/services/PHSS/createOrder/';
        
        req.httpMethod = 'POST';
        
        //String  JSONMsg = '{ "order": { "customer_info": { "customer_no": "' + con.id + '", "customer_first_name": "Test", "customer_last_name": "Roster", "email": "test@test.com" }, "billing_info": { "billing_address": { "first_name": "test first name", "last_name": "test last name", "address1": "test address 1", "address2" : "test address 2", "city": "test city", "postal_code": "411014", "state_code": "200", "country_code": "2434", "phone": "1234567890", "email" : "test@test.com" } }, "order_header": { "order_no": "3114226", "currencyval": "532542", "creation_date": "7/21/2017", "external_order_status": "New", "created_by": "store name", "shipping_total": 0, "order_total" : 0, "authorization_status": "test status", "approvalStatus": "test status" }, "order_item": [{ "product_name": "a5M5B0000008hwIUAQ", "product_id": "test product id", "product_type" : "test type", "quantity": 0, "price": 0, "base_price": 0, "price_adjustment_amount": 0, "adjusted_tax": 0 }] } } ';
        //String JSONMsg = '{ "order": { "Student_info": { "student_first_name": "Test", "student_last_name": "Roster", "student_email": "test@test.com" }, "billing_info": { "first_name": "kkk", "last_name": "kkkk", "address1": "12330 Rolater Rd", "address2": "", "city": "Frisco", "postal_code": "75035", "state_code": "TX", "country_code": "US", "phone": "3103334523", "email": "kkvya2@gmail.com" }, "order_header": { "order_no": "00002501", "currency": "USD", "creation_date": "2018-10-01T00:00:00Z", "external_order_status": "", "created_by": "Customer", "shipping_total": 0, "order_total": 25 }, "order_items": { "products": [ { "product_name": "First Aid Online", "product_id": "a5M5B0000008hwIUAQ", "product_type": "offering", "quantity": 1, "price": 25, "adjusted_tax": 0, "price_adjustment_amount": 25 } ] } }, "action": "createOrder" }';
        String JSONMsg = '{"order":{"student_info":{"student_email":"","student_first_name":"","student_last_name":""},"billing_info":{"first_name":"kalpan","last_name":"vyas","address1":"500 E Stacy Rd","address2":"","city":"Allen","postal_code":"75002","state_code":"TX","country_code":"US","phone":"3105478852","email":"kkvya1@gmail.com"},"shipping_info":{"first_name":"abcdef","last_name":"abcdef","address1":"1234 Wiltshire Drive","address2":"","city":"Allen","postal_code":"75013","state_code":"TX","country_code":"US","phone":"3102347689"},"order_header":{"created_by":"Customer","creation_date":"2019-01-11T17:04:43.000Z","currency":"USD","external_order_status":"","order_no":"00006001","order_total":340.19,"shipping_method":"008 - USPS","shipping_total":15.9,"tax_exempt_flag":"False","tax_total":0},"order_transaction":{"storefront":"Customer","paymentProcessorID":"CYBERSOURCE_CREDIT","transaction_dtls":{"ccTransactionDtls":[{"afsFactorCode":"F","afsReasonCode":"100","afsResult":"25","approvalStatus":"100","auth_capture_amount":200.77,"auth_request_amount":"340.19","authCode":"888888","avsCode":"F","cc_exp_month":7,"cc_exp_year":2020,"cc_holder":"kalpan vyas","cc_last_four":"1111","cc_num":"************1111","dmDecision":"ACCEPT","is_cc_expired":false,"masked_cc_number":"************1111","offeringTransactionID":"5472262880136085704011","payment_method":"CREDIT_CARD","payment_type":"Visa","requestId":"5472262834416778204008","requestToken":"Ahj//wSTKKbnMDFDZQ1LERLBgwYNmDBjDUafc8SUkAqNPueJKi0gfObYzOGTSTKuj0m9oQwJyZRTc4NONCfptAAAzBjx","token":"9909000234739228","transacrtion_type":"","transaction_id":"5472262880136085704011","transaction_modification_time":"2019-01-11T17:04:48.000Z","transaction_time":"2019-01-11T17:04:43.000Z"}],"ppTransactionDtls":[],"poTransactionDtls":[]}},' +
                '"order_items":{"products":[{"adjusted_tax":0,"price":200.77,"price_adjustment_amount":200.77,"pricing_type":"External","product_id":"'+String.valueOf(clsrec.Id)+'","product_name":"Pediatric CPR/AED Review","product_type":"offering","quantity":1,"type":"Major"},{"adjusted_tax":0,"price":123.52,"price_adjustment_amount":123.52,"pricing_type":"External","product_id":"91052","product_name":"Deluxe 3-Day Emergency Preparedness Kit","product_type":"physical","quantity":1,"type":"Major"}]}},"action":"createOrder"}';
        req.requestBody = Blob.valueof(JSONMsg); // Add JSON Message as a POST
        
        RestResponse res = new RestResponse();
        
        RestContext.request = req;
        
        RestContext.response = res;
        Test.startTest();
        PHSS_CreateOrderRestService.createOrder(); 
        PHSS_CreateOrderRestService.JsonResponse rsw = PHSS_CreateOrderRestService.createOrder();
        
        System.debug('CreateRestorderservice>>>>>>'+rsw);
        Test.stopTest();
    }
    static testMethod void testService3()
    {
        Redwing__ILT_Class__c clsrec= [Select id from Redwing__ILT_Class__c where Name =:'Test'];
        Contact con = [Select id From Contact];
        
        RestRequest req = new RestRequest();
        
        req.addHeader('Content-Type', 'application/json'); // Add a JSON Header as it is validated
        
        req.requestURI = '/services/PHSS/createOrder/';
        
        req.httpMethod = 'POST';
        
        //String  JSONMsg = '{ "order": { "customer_info": { "customer_no": "' + con.id + '", "customer_first_name": "Test", "customer_last_name": "Roster", "email": "test@test.com" }, "billing_info": { "billing_address": { "first_name": "test first name", "last_name": "test last name", "address1": "test address 1", "address2" : "test address 2", "city": "test city", "postal_code": "411014", "state_code": "200", "country_code": "2434", "phone": "1234567890", "email" : "test@test.com" } }, "order_header": { "order_no": "", "currencyval": "532542", "creation_date": "7/21/2017", "external_order_status": "New", "created_by": "store name", "shipping_total": 0, "order_total" : 0, "authorization_status": "test status", "approvalStatus": "test status" }, "order_item": [{ "product_name": "a5M5B0000008hwIUAQ", "product_id": "test product id", "product_type" : "test type", "quantity": 0, "price": 0, "base_price": 0, "price_adjustment_amount": 0, "adjusted_tax": 0 }] } } ';
        //String JSONMsg = '{ "order": { "Student_info": { "student_first_name": "Test", "student_last_name": "Roster", "student_email": "test@test.com" }, "billing_info": { "first_name": "kkk", "last_name": "kkkk", "address1": "12330 Rolater Rd", "address2": "", "city": "Frisco", "postal_code": "75035", "state_code": "TX", "country_code": "US", "phone": "3103334523", "email": "kkvya2@gmail.com" }, "order_header": { "order_no": "", "currency": "USD", "creation_date": "2018-10-01T00:00:00Z", "external_order_status": "", "created_by": "Customer", "shipping_total": 0, "order_total": 25 }, "order_items": { "products": [ { "product_name": "First Aid Online", "product_id": "a5M5B0000008hwIUAQ", "product_type": "offering", "quantity": 1, "price": 25, "adjusted_tax": 0, "price_adjustment_amount": 25 } ] } }, "action": "createOrder" }';
        String JSONMsg = '{"order":{"student_info":{"student_email":"","student_first_name":"","student_last_name":""},"billing_info":{"first_name":"test","last_name":"test","address1":"1236 N ALMA DR","address2":"","city":"ALLEN","postal_code":"75013-4624","state_code":"TX","country_code":"US","phone":"3104569283","email":"kvyas@pfsweb.com"},"shipping_info":{"first_name":"test","last_name":"test","address1":"1236 N ALMA DR","address2":"","city":"ALLEN","postal_code":"75013-4624","state_code":"TX","country_code":"US","phone":"3104569283"},"order_header":{"created_by":"Customer","creation_date":"2019-01-17T19:21:32.000Z","currency":"USD","external_order_status":"","order_no":"","order_total":17.29,"payment_method":"PayPal","shipping_method":"008 - USPS","shipping_total":7.3,"tax_exempt_flag":"False","tax_total":0},"order_transaction":{"storefront":"Customer","paymentProcessorID":"PAYPAL_EXPRESS","transaction_dtls":{"ccTransactionDtls":[],"ppTransactionDtls":[{"approvalStatus":"100","auth_capture_amount":"17.29","auth_request_amount":"17.29","isPaypalBillingAddressPresent":true,"payment_method":"PayPal","paypalAuthTransactionID":"699776138L097251S","paypalAvsCode":"3","paypalBillingAgreementAcceptedStatus":"0","paypalCorrelationId":"2a2b2ad191e8f","paypalEcSetRequestID":"5477528887426036004010","paypalEcSetRequestToken":"AhirLwSTKO/7zewRf/SqEVGn3WAgTqNPusBAnARnMMmkmVdHpN7QgAAAxAKY","paypalGetDetailsAddressStatus":"Confirmed","paypalGetDetailsCorrelationId":"c626f83d2af84","paypalGetDetailsPayerStatus":"unverified","paypalGetDetailsTaxAmount":"0.00","paypalOrigination":"billing","paypalPayerCountry":"US","paypalPayerEmail":"npinnelli@pfsweb.com","paypalPayerFirstName":"Narasimha","paypalPayerID":"PVUMWXWWJCA5U","paypalPayerLastName":"Pinnelli","paypalPayerStatus":"unverified","paypalProtectionEligibility":"Eligible","paypalProtectionEligibilityType":"ItemNotReceivedEligible,UnauthorizedPaymentEligible","paypalSetRequestCorrelationID":"f5702b61c47ec","paypalToken":"EC-74Y121133H521183J","paypalTransactionID":"0277528243006950514011","requestId":"5477528969776635604108","requestToken":"AhjrLwSTKO/8GNHPI9WoEVGn3WAgTqNPusBIm0gXsGM5hk0kyro9JvaEAAAAzgL1","transaction_id":"O-1SJ76863LG935718J","transaction_modification_time":"2019-01-17T19:21:43.000Z","transaction_time":"2019-01-17T19:21:32.000Z"},{"approvalStatus":"100","auth_capture_amount":"17.29","auth_request_amount":"17.29","isPaypalBillingAddressPresent":true,"payment_method":"PayPal","paypalAuthTransactionID":"799786138L097251S","paypalAvsCode":"3","paypalBillingAgreementAcceptedStatus":"0","paypalCorrelationId":"2a2b2ad191e8f","paypalEcSetRequestID":"5477528887426036004010","paypalEcSetRequestToken":"AhirLwSTKO/7zewRf/SqEVGn3WAgTqNPusBAnARnMMmkmVdHpN7QgAAAxAKY","paypalGetDetailsAddressStatus":"Confirmed","paypalGetDetailsCorrelationId":"c626f83d2af84","paypalGetDetailsPayerStatus":"unverified","paypalGetDetailsTaxAmount":"0.00","paypalOrigination":"billing","paypalPayerCountry":"US","paypalPayerEmail":"npinnelli@pfsweb.com","paypalPayerFirstName":"Narasimha","paypalPayerID":"PVUMWXWWJCA5U","paypalPayerLastName":"Pinnelli","paypalPayerStatus":"unverified","paypalProtectionEligibility":"Eligible","paypalProtectionEligibilityType":"ItemNotReceivedEligible,UnauthorizedPaymentEligible","paypalSetRequestCorrelationID":"f5702b61c47ec","paypalToken":"EC-74Y121133H521183J","paypalTransactionID":"0277528241006350814011","requestId":"5477528969776635604108","requestToken":"AhjrLwSTKO/8GNHPI9WoEVGn3WAgTqNPusBIm0gXsGM5hk0kyro9JvaEAAAAzgL1","transaction_id":"O-1SJ76863LG935719J","transaction_modification_time":"2019-01-17T19:21:43.000Z","transaction_time":"2019-01-17T19:21:32.000Z"}],"poTransactionDtls":[]}},' +
                '"order_items":{"products":[{"adjusted_tax":0,"price":9.99,"price_adjustment_amount":9.99,"pricing_type":"External","product_id":"'+String.valueOf(clsrec.Id)+'","product_name":"Pediatric CPR/AED Review","product_type":"Offering","quantity":1,"type":"Major"}]}},"action":"createOrder"}';
        req.requestBody = Blob.valueof(JSONMsg);
        
        RestResponse res = new RestResponse();
        
        RestContext.request = req;
        
        RestContext.response = res;        
        Test.startTest();
       PHSS_CreateOrderRestService.createOrder();
       PHSS_CreateOrderRestService.JsonResponse rsw = PHSS_CreateOrderRestService.createOrder();
        //PHSS_CreateOrderRestService.createPaymentDetail(JSONMsg,);
        Test.stopTest();
    }
    static testMethod void testService4()
    {
        Redwing__ILT_Class__c clsrec= [Select id from Redwing__ILT_Class__c where Name =:'Test'];
        Contact con = [Select id From Contact];
        
        RestRequest req = new RestRequest();
        
        req.addHeader('Content-Type', 'application/json'); // Add a JSON Header as it is validated
        
        req.requestURI = '/services/PHSS/createOrder/';
        
        req.httpMethod = 'POST';
        
        //String  JSONMsg = '{ "order": { "customer_info": { "customer_no": "' + con.id + '", "customer_first_name": "Test", "customer_last_name": "Roster", "email": "test@test.com" }, "billing_info": { "billing_address": { "first_name": "test first name", "last_name": "test last name", "address1": "test address 1", "address2" : "test address 2", "city": "test city", "postal_code": "411014", "state_code": "200", "country_code": "2434", "phone": "1234567890", "email" : "test@test.com" } }, "order_header": { "order_no": "", "currencyval": "532542", "creation_date": "7/21/2017", "external_order_status": "New", "created_by": "store name", "shipping_total": 0, "order_total" : 0, "authorization_status": "test status", "approvalStatus": "test status" }, "order_item": [{ "product_name": "a5M5B0000008hwIUAQ", "product_id": "test product id", "product_type" : "test type", "quantity": 0, "price": 0, "base_price": 0, "price_adjustment_amount": 0, "adjusted_tax": 0 }] } } ';
        //String JSONMsg = '{ "order": { "Student_info": { "student_first_name": "Test", "student_last_name": "Roster", "student_email": "test@test.com" }, "billing_info": { "first_name": "kkk", "last_name": "kkkk", "address1": "12330 Rolater Rd", "address2": "", "city": "Frisco", "postal_code": "75035", "state_code": "TX", "country_code": "US", "phone": "3103334523", "email": "kkvya2@gmail.com" }, "order_header": { "order_no": "", "currency": "USD", "creation_date": "2018-10-01T00:00:00Z", "external_order_status": "", "created_by": "Customer", "shipping_total": 0, "order_total": 25 }, "order_items": { "products": [ { "product_name": "First Aid Online", "product_id": "", "product_type": "offering", "quantity": 1, "price": 25, "adjusted_tax": 0, "price_adjustment_amount": 25 } ] } }, "action": "createOrder" }';
        String JSONMsg = '{"order":{"student_info":{"student_email":"","student_first_name":"","student_last_name":""},"billing_info":{"first_name":"test","last_name":"test","address1":"1236 N ALMA DR","address2":"","city":"ALLEN","postal_code":"75013-4624","state_code":"TX","country_code":"US","phone":"3104569283","email":"kvyas@pfsweb.com"},"shipping_info":{"first_name":"test","last_name":"test","address1":"1236 N ALMA DR","address2":"","city":"ALLEN","postal_code":"75013-4624","state_code":"TX","country_code":"US","phone":"3104569283"},"order_header":{"created_by":"Customer","creation_date":"2019-01-17T19:21:32.000Z","currency":"USD","external_order_status":"","order_no":"","order_total":17.29,"payment_method":"PayPal","shipping_method":"008 - USPS","shipping_total":7.3,"tax_exempt_flag":"False","tax_total":0},"order_transaction":{"storefront":"Customer","paymentProcessorID":"PAYPAL_EXPRESS","transaction_dtls":{"ccTransactionDtls":[],"ppTransactionDtls":[{"approvalStatus":"100","auth_capture_amount":"17.29","auth_request_amount":"17.29","isPaypalBillingAddressPresent":true,"payment_method":"PayPal","paypalAuthTransactionID":"699776138L097251S","paypalAvsCode":"3","paypalBillingAgreementAcceptedStatus":"0","paypalCorrelationId":"2a2b2ad191e8f","paypalEcSetRequestID":"5477528887426036004010","paypalEcSetRequestToken":"AhirLwSTKO/7zewRf/SqEVGn3WAgTqNPusBAnARnMMmkmVdHpN7QgAAAxAKY","paypalGetDetailsAddressStatus":"Confirmed","paypalGetDetailsCorrelationId":"c626f83d2af84","paypalGetDetailsPayerStatus":"unverified","paypalGetDetailsTaxAmount":"0.00","paypalOrigination":"billing","paypalPayerCountry":"US","paypalPayerEmail":"npinnelli@pfsweb.com","paypalPayerFirstName":"Narasimha","paypalPayerID":"PVUMWXWWJCA5U","paypalPayerLastName":"Pinnelli","paypalPayerStatus":"unverified","paypalProtectionEligibility":"Eligible","paypalProtectionEligibilityType":"ItemNotReceivedEligible,UnauthorizedPaymentEligible","paypalSetRequestCorrelationID":"f5702b61c47ec","paypalToken":"EC-74Y121133H521183J","paypalTransactionID":"0277528243006950514011","requestId":"5477528969776635604108","requestToken":"AhjrLwSTKO/8GNHPI9WoEVGn3WAgTqNPusBIm0gXsGM5hk0kyro9JvaEAAAAzgL1","transaction_id":"O-1SJ76863LG935718J","transaction_modification_time":"2019-01-17T19:21:43.000Z","transaction_time":"2019-01-17T19:21:32.000Z"},{"approvalStatus":"100","auth_capture_amount":"17.29","auth_request_amount":"17.29","isPaypalBillingAddressPresent":true,"payment_method":"PayPal","paypalAuthTransactionID":"799786138L097251S","paypalAvsCode":"3","paypalBillingAgreementAcceptedStatus":"0","paypalCorrelationId":"2a2b2ad191e8f","paypalEcSetRequestID":"5477528887426036004010","paypalEcSetRequestToken":"AhirLwSTKO/7zewRf/SqEVGn3WAgTqNPusBAnARnMMmkmVdHpN7QgAAAxAKY","paypalGetDetailsAddressStatus":"Confirmed","paypalGetDetailsCorrelationId":"c626f83d2af84","paypalGetDetailsPayerStatus":"unverified","paypalGetDetailsTaxAmount":"0.00","paypalOrigination":"billing","paypalPayerCountry":"US","paypalPayerEmail":"npinnelli@pfsweb.com","paypalPayerFirstName":"Narasimha","paypalPayerID":"PVUMWXWWJCA5U","paypalPayerLastName":"Pinnelli","paypalPayerStatus":"unverified","paypalProtectionEligibility":"Eligible","paypalProtectionEligibilityType":"ItemNotReceivedEligible,UnauthorizedPaymentEligible","paypalSetRequestCorrelationID":"f5702b61c47ec","paypalToken":"EC-74Y121133H521183J","paypalTransactionID":"0277528241006350814011","requestId":"5477528969776635604108","requestToken":"AhjrLwSTKO/8GNHPI9WoEVGn3WAgTqNPusBIm0gXsGM5hk0kyro9JvaEAAAAzgL1","transaction_id":"O-1SJ76863LG935719J","transaction_modification_time":"2019-01-17T19:21:43.000Z","transaction_time":"2019-01-17T19:21:32.000Z"}],"poTransactionDtls":[]}},' +
                '"order_items":{"products":[]}},"action":"createOrder"}';
        req.requestBody = Blob.valueof(JSONMsg);
        
        RestResponse res = new RestResponse();
        
        RestContext.request = req;
        
        RestContext.response = res;        
        Test.startTest();
       PHSS_CreateOrderRestService.createOrder();
       PHSS_CreateOrderRestService.JsonResponse rsw = PHSS_CreateOrderRestService.createOrder();
        //PHSS_CreateOrderRestService.createPaymentDetail(JSONMsg,);
        Test.stopTest();
    }
}