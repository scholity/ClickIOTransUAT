@IsTest
public class SubmitCaseControllertest {
    
    @IsTest(seeAllData=false)
    public static void test1()
    {
        String dateString = String.valueof(Datetime.now()).replace(' ', '').replace(':', '').replace('-', '');
        String orgId = UserInfo.getOrganizationId();
        Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));
        String uniqueName = orgId + dateString + randomInt;
        String receiveOpenCaseConfirmation='yes' ;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        
        User u = new User(Alias = 'standt', 
                          Email = 'standarduser@testorg.com', 
                          EmailEncodingKey = 'UTF-8', 
                          LastName = 'Testing', 
                          LanguageLocaleKey = 'en_US', 
                          LocaleSidKey = 'en_US', 
                          TimeZoneSidKey = 'America/Los_Angeles', 
                          ProfileId = p.Id,
                          Username = uniqueName + '@test' + orgId + '.org'); 
        insert u;
        
        Validation_Rules__c supportConfig = Validation_Rules__c.getOrgDefaults();
        
        supportConfig.Bypass_Rules__c = true;  
        insert supportConfig;
        update supportConfig;
        
        
        //Invoicing_Case_RecordType__c inv = new Invoicing_Case_RecordType__c();
        //insert inv;
        Account a = new Account();
        a.Name='test';
        insert a;
        contact con = new contact();
        con.AccountID= a.id;
        // insert con;
        Id RecordTypeIdContact = Schema.SObjectType.Case.getRecordTypeInfosByName().get('RCS PO').getRecordTypeId();
        
        Switch__c s= new Switch__c();
        s.Switch__c=false;
        s.Name='CaseOwnerHistorySwitch';
        insert s;
        Invoicing_Case_RecordType__c custtset=new Invoicing_Case_RecordType__c();
        custtset.Invoicing_Case_RecordType_Id__c = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Invoicing Case').getRecordTypeId();
        insert custtset;
       Invoicing_Case_RecordType__c CustomSet = [Select id,Invoicing_Case_RecordType_Id__c from Invoicing_Case_RecordType__c LIMIT 1] ;
        Case c = new Case();
        c.Question_Type__c='RCS PO';
        c.Status='New';
        c.State__c='AK';
        c.Origin='Phone';
        //c.ContactId=con.id;
        c.Accountid=a.id;
         
        c.RecordTypeId = CustomSet.Invoicing_Case_RecordType_Id__c;
        
        //Sandbox Invoice Record Type ID
       // c.RecordTypeId = '0122F0000008y7IQAQ';
        
        //Production Invoice Record Type ID
        //c.RecordTypeId = '0122F0000008y7IQAQ';
        
        insert c;
        
        
        List<SelectOption> options=new List<SelectOption>();
        
        
        Test.startTest();
        SubmitCaseController su =new SubmitCaseController();
        su.receiveOpenCaseConfirmation='yes';
        su.receiveOpenCaseConfirmation='NO';
        su.customerReceivesNotificaitonOptions=options;
        su.stateOptions=options;
        su.webRequestTypeOptions=options;
        su.isReceiveOpenCaseNotificaiton();
       
       //Sandbox Invoice Record Type ID
       su.InvoiceRecordTypeId = CustomSet.Invoicing_Case_RecordType_Id__c;
       
        //Production Invoice Record Type ID
       //su.InvoiceRecordTypeId= '0122F0000008y7IQAQ';
        
        su.submitCase();
       su.uploadAttachment(c.Id);
        
        Test.stopTest();
    }
    
    @IsTest(seeAllData=false)
    public static void test2()
    {
        String dateString = String.valueof(Datetime.now()).replace(' ', '').replace(':', '').replace('-', '');
        String orgId = UserInfo.getOrganizationId();
        Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));
        String uniqueName = orgId + dateString + randomInt;
        String receiveOpenCaseConfirmation='NO' ;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        
        User u = new User(Alias = 'standt', 
                          Email = 'standarduser@testorg.com', 
                          EmailEncodingKey = 'UTF-8', 
                          LastName = 'Testing', 
                          LanguageLocaleKey = 'en_US', 
                          LocaleSidKey = 'en_US', 
                          TimeZoneSidKey = 'America/Los_Angeles', 
                          ProfileId = p.Id,
                          Username = uniqueName + '@test' + orgId + '.org'); 
        insert u;
        
        Validation_Rules__c supportConfig = Validation_Rules__c.getOrgDefaults();
        
        Test.startTest();
        
        SubmitCaseController su =new SubmitCaseController();
        
        List<SelectOption> options = new List<SelectOption>();
        options = su.customerReceivesNotificaitonOptions;
        options = su.webRequestTypeOptions;
        options = su.stateOptions;
        
        Test.stopTest();
    }
    
    
    
}