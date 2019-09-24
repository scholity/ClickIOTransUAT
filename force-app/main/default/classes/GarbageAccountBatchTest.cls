/*****************************************************************************************************
 
Class    :  GarbageAccountBatchTest
Developer:  Sudhir.
Created  :  Aug 14, 2019
Modified :  Aug 14, 2019
Objective:  This class is used to test the class GarbageAccountBatch
 
*****************************************************************************************************/ 
@isTest
private class GarbageAccountBatchTest {
    @testSetup static void methodName() {
        Switch__c cohstest = new Switch__c();
            cohstest.Switch__c = true;
            cohstest.name = 'CaseOwnerHistorySwitch';
            insert cohstest;
            
            //for Custom Setting
            Bucket_Account_Settings__c supportConfig = Bucket_Account_Settings__c.getOrgDefaults();
            supportConfig.Bucket_Account_Owner_ID__c = '005d0000001WOeV'; 
            supportConfig.Bucket_Account_RecordTypeID__c = '012d000000098Wt';
            supportConfig.Default_Bucket_Name__c = 'Bucket Account';
            supportConfig.Maximum_Size_of_Bucket__c =   5000;       
            insert supportConfig;
                                  
            //Datetime yesterday = Datetime.now().addDays(-500);
            
                
            /*List<Account> AccList=new List<Account>();
            List<Contact> ConList=new List<Contact>();
            List<Attachment> AttList =new List<Attachment>();
            List<Note> NotesList=new List<Note>();
            List<Task> TasksList=new List<Task>();
            List<Event> EventsList=new List<Event>();
            List<Opportunity> OppList=new List<Opportunity>();
            List<Case> CaseList=new List<Case>();
            List<AccountContactRole> AcconList=new List<AccountContactRole>();
            List<Contract> ContraList=new List<Contract>();
            
            for(Integer i=1;i<10;i++)
            {
                AccList.add(new Account(Name = 'Test'+i));
            }
            insert AccList;
            
            Integer j=1;
            for(Account Acc:AccList)
            {
                Test.setCreatedDate(Acc.Id, yesterday);
                ConList.add(new Contact(FirstName = 'Test'+j,LastName = 'Contact',accountId =Acc.Id));
                //AttList.add(new Attachment(Name = 'fileName',ParentId=Acc.Id));
                OppList.add(new Opportunity(Name = 'Test'+j,accountId =Acc.Id,Type = 'Retail',StageName='Approch',CloseDate=system.today()+2));
                //CaseList.add(new Case(Type = 'Aquatics'+j,Case_Sub_Type__c = 'Lifeguarding',accountId =Acc.Id));
                j++;
            }*/
            Account Accs = new Account(Name = 'Test');
            insert Accs;
            Datetime yesterday = Datetime.now().addDays(-500);
            Test.setCreatedDate(Accs.Id, yesterday);
            Contact Cons = new Contact(FirstName = 'Test',LastName = 'Contact',accountId =Accs.Id);
            insert Cons;
            Case Casess=new Case();
            /*Casess.Type = 'Aquatics';
            Casess.Case_Sub_Type__c = 'Lifeguarding';
            Casess.ContactId = Cons.Id;
            Casess.AccountId = Cons.AccountId;
            insert Casess;*/
    }  
    private static testMethod void testBatch()
    {
        Test.startTest();
        GarbageAccountBatch GbAcc=new GarbageAccountBatch();
           Id BatchId = Database.executeBatch(GbAcc);
        Test.stopTest();
 
    } 
    /*private static testMethod void testBatc1()
    {
        final String CREATED_DATE_FIELD = String.valueof(Date.today()-30);
        Test.startTest();
           Id BatchId1 = Database.executeBatch(new GarbageAccountBatch(CREATED_DATE_FIELD), 50);
        Test.stopTest();
 
    } */
}