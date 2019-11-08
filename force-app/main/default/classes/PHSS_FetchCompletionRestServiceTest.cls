@isTest
public class PHSS_FetchCompletionRestServiceTest {
    
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
        
        Account a1 = new Account();
        a1.Name='SalesforcetestOrgacc';
        a1.DM_External_Id__c ='SalesforcetestOrgtestacc@test.com';
        a1.BillingStreet='24 Willie Mays Plaza';
        a1.BillingCity='San Francisco';
        a1.BillingState='California';
        a1.BillingPostalCode='94018';
        a1.BillingCountry='USA';
        a1.Phone='9934200244'; 
        insert a1;
        
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

        redwing__Training_Plan__c theLearningPlan = new redwing__Training_Plan__c();
        theLearningPlan.Name = 'The Learning Plan';
        theLearningPlan.Classroom_Setting__c = 'Classroom';
        insert theLearningPlan;

        redwing__Learning__c learning = new redwing__Learning__c();
        learning.Name = 'Test learning';
        learning.redwing__Published__c = true;
        learning.RecordTypeId = Schema.SObjectType.redwing__Learning__c.getRecordTypeInfosByName().get('ILT Event').getRecordTypeId();
        insert learning;
        
        redwing__Learning__c learningiltclass = new redwing__Learning__c();
        learningiltclass.Name = 'Test learning';
        learningiltclass.redwing__Published__c = true;
        learningiltclass.RecordTypeId = Schema.SObjectType.redwing__Learning__c.getRecordTypeInfosByName().get('ILT Class').getRecordTypeId();
        insert learningiltclass;
        
        redwing__Learning_Assignment__c obj_la = new redwing__Learning_Assignment__c();
        obj_la.redwing__Learning__c=learning.id;
        obj_la.redwing__Evaluation_Result__c = 'Successful';
        obj_la.redwing__Evaluation_Score__c = 100;
        obj_la.Grade_Reason__c = '';
        obj_la.Grade_Additional_Info__c = '';
        obj_la.redwing__Progress__c = 'Completed';
        obj_la.redwing__Progress_Percentage__c = 100;
        obj_la.redwing__Completed_On__c = System.today();
        obj_la.RCO_Order_Id__c = '1234';
        insert obj_la;
        
        redwing__Learning_Assignment__c obj_lailtclass = new redwing__Learning_Assignment__c();
        obj_lailtclass.redwing__Learning__c=learningiltclass.id;
        obj_lailtclass.redwing__Training_Plan__c = theLearningPlan.Id;
        obj_lailtclass.redwing__Evaluation_Result__c = 'Successful';
        obj_lailtclass.redwing__Evaluation_Score__c = 100;
        obj_lailtclass.Grade_Reason__c = '';
        obj_lailtclass.Grade_Additional_Info__c = '';
        obj_lailtclass.redwing__Progress__c = 'Completed';
        obj_lailtclass.redwing__Progress_Percentage__c = 100;
        obj_lailtclass.redwing__Completed_On__c = System.today();
        obj_lailtclass.RCO_Order_Id__c = '1244';
        insert obj_lailtclass;

        Redwing__ILT_Class__c clsRecord = new Redwing__ILT_Class__c();
        clsRecord.Skedulo_Account__c = a.id;
        clsRecord.redwing__End_Date__c = Date.Parse('12/19/2018');
        clsRecord.redwing__End_Time__c= '13:00';
        clsRecord.redwing__Start_Date__c = Date.Parse('12/19/2018');// Assuming Start date = End date
        clsRecord.redwing__Start_Time__c = '12:00';
        clsRecord.Name = 'Test';
        clsRecord.redwing__Learning__c = learning.Id;
        clsRecord.Learning_Plan__c = theLearningPlan.Id;
        insert clsRecord;

        Redwing__ILT_Class__c clsRecordnew = new Redwing__ILT_Class__c();
        clsRecordnew.Skedulo_Account__c = a1.id;
        clsRecordnew.redwing__End_Date__c = Date.Parse('12/19/2018');
        clsRecordnew.redwing__End_Time__c= '13:00';
        clsRecordnew.redwing__Start_Date__c = Date.Parse('12/19/2018');// Assuming Start date = End date
        clsRecordnew.redwing__Start_Time__c = '12:00';
        clsRecordnew.Name = 'TestILTClass';
        clsRecordnew.redwing__Learning__c = learningiltclass.Id;
        clsRecordnew.Learning_Plan__c = theLearningPlan.Id;
        insert clsRecordnew;

        voucher__c theVoucher = new voucher__c();
        theVoucher.RCO_Order_Id__c = '1244';
        theVoucher.ILT_Class__c = clsRecordnew.Id;
        theVoucher.Account__c = a1.Id;
        theVoucher.Learning_Plan__c = theLearningPlan.Id;
        insert theVoucher;

    }
    
    static testMethod void RequiredDataMissingtestService()
    {
        Redwing__ILT_Class__c clsrec= [Select id from Redwing__ILT_Class__c where Name =:'Test'];
        RestRequest req = new RestRequest();
        
        req.addHeader('Content-Type', 'application/json'); // Add a JSON Header as it is validated
        
        req.requestURI = '/services/PHSS/fetchCompletion/';
        
        req.httpMethod = 'POST';
        
        String  JSONMsg = '{ "orderID": "", "classID":"'+clsrec.id+'", "action": "fetchCompletion" }';
        req.requestBody = Blob.valueof(JSONMsg); // Add JSON Message as a POST
        
        RestResponse res = new RestResponse();
        
        RestContext.request = req;
        
        RestContext.response = res;
        Test.startTest();
        PHSS_FetchCompletionRestService.fetchCompletionResponse respo = PHSS_FetchCompletionRestService.fetchCompletion(); 
        System.assertEquals('One of the required fields is missing',respo.FetchCompletion.status.description);
        Test.stopTest();
    }
    
    static testMethod void NoRecordFoundtestService()
    {
        Redwing__ILT_Class__c clsrec= [Select id from Redwing__ILT_Class__c where Name =:'Test'];
        RestRequest req = new RestRequest();
        
        req.addHeader('Content-Type', 'application/json'); // Add a JSON Header as it is validated
        
        req.requestURI = '/services/PHSS/fetchCompletion/';
        
        req.httpMethod = 'POST';
        
        String  JSONMsg = '{ "orderID": "12345", "classID":"'+clsrec.id+'", "action": "fetchCompletion" }';
        req.requestBody = Blob.valueof(JSONMsg); // Add JSON Message as a POST
        
        RestResponse res = new RestResponse();
        
        RestContext.request = req;
        
        RestContext.response = res;
        Test.startTest();
        PHSS_FetchCompletionRestService.fetchCompletionResponse respo = PHSS_FetchCompletionRestService.fetchCompletion();
        System.assertEquals('No related voucher or learning plan record found',respo.FetchCompletion.status.description);
        Test.stopTest();
    }
    
    static testMethod void testService()
    {
        Redwing__ILT_Class__c clsrec= [Select id from Redwing__ILT_Class__c where Name =:'Test'];
        RestRequest req = new RestRequest();
        
        req.addHeader('Content-Type', 'application/json'); // Add a JSON Header as it is validated
        
        req.requestURI = '/services/PHSS/fetchCompletion/';
        
        req.httpMethod = 'POST';
        
        String  JSONMsg = '{ "orderID": "1234", "classID":"'+clsrec.id+'", "action": "fetchCompletion" }';
        req.requestBody = Blob.valueof(JSONMsg); // Add JSON Message as a POST
        
        RestResponse res = new RestResponse();
        
        RestContext.request = req;
        
        RestContext.response = res;

        Test.startTest();
        PHSS_FetchCompletionRestService.fetchCompletionResponse respo = PHSS_FetchCompletionRestService.fetchCompletion(); 

        System.debug('RestContext>>>>>>>>>>'+respo);
        System.assertEquals('No related voucher or learning plan record found',respo.FetchCompletion.status.description);
        
        Test.stopTest();
    }
    
    static testMethod void testServicedwithlearningrect()
    {
        Redwing__ILT_Class__c clsrec= [Select id from Redwing__ILT_Class__c where Name =:'TestILTClass'];
        RestRequest req = new RestRequest();
        
        req.addHeader('Content-Type', 'application/json'); // Add a JSON Header as it is validated
        
        req.requestURI = '/services/PHSS/fetchCompletion/';
        
        req.httpMethod = 'POST';
        
        String  JSONMsg = '{ "orderID": "1244", "classID":"'+clsrec.id+'", "action": "fetchCompletion" }';
        req.requestBody = Blob.valueof(JSONMsg); // Add JSON Message as a POST
        
        RestResponse res = new RestResponse();
        
        RestContext.request = req;
        
        RestContext.response = res;

        Test.startTest();
        PHSS_FetchCompletionRestService.fetchCompletionResponse respo = PHSS_FetchCompletionRestService.fetchCompletion(); 
        System.assertEquals('Completion data fetch Successful.',respo.FetchCompletion.status.description);
        Test.stopTest();
    }
    
    static testMethod void testService1()
    {
        Redwing__ILT_Class__c clsrec= [Select id from Redwing__ILT_Class__c where Name =:'TestILTClass'];
        RestRequest req = new RestRequest();
        
        req.addHeader('Content-Type', 'application/json'); // Add a JSON Header as it is validated
        
        req.requestURI = '/services/PHSS/fetchCompletion/';
        
        req.httpMethod = 'POST';
        
        String  JSONMsg = '{ "orderID": "1234", "classID":"'+clsrec.id+'", "action": "fetchCompletion" }';
        req.requestBody = Blob.valueof(JSONMsg); // Add JSON Message as a POST
        
        RestResponse res = new RestResponse();
        
        RestContext.request = req;
        
        RestContext.response = res;

        Test.startTest();
        PHSS_FetchCompletionRestService.fetchCompletionResponse respo = PHSS_FetchCompletionRestService.fetchCompletion();
        System.assertEquals('No related voucher or learning plan record found',respo.FetchCompletion.status.description);
        Test.stopTest();
    }
}