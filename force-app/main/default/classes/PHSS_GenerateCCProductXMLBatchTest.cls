@isTest
public class PHSS_GenerateCCProductXMLBatchTest {
    
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
        
        ccrz__E_Product__c product = new ccrz__E_Product__c();
        product.Name = 'Test Prod';
        product.ccrz__SKU__c = String.ValueOf(System.Now());
        product.ccrz__Quantityperunit__c = 2.0;
        product.ccrz__StartDate__c =  System.Today().addDays(2);
        product.ccrz__EndDate__c = System.Today().addDays(20);
        product.ccrz__InventoryType__c = 'STANDARD';
        insert product;
    }
    
    static testMethod void testBatch()
	{
        Test.startTest();
        Id batchJobId = Database.executeBatch(new PHSS_GenerateCCProductXMLBatch(false), 200);
        Test.stopTest();
    }

}