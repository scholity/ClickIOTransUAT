@isTest
public class TestGetFeedbackSurveytrigger
{
    @testSetup static void ClassData()
    {
        Switch__c cohstest = new Switch__c();
        cohstest.Switch__c = false;
        cohstest.name = 'EmailMessageServiceSwitch';
        insert cohstest; 
     
        Bucket_Account_Settings__c BucketAcc= new Bucket_Account_Settings__c();
        BucketAcc.Bucket_Account_Owner_ID__c = '005d0000001WOeV';
        BucketAcc.Bucket_Account_RecordTypeID__c = '012d000000098Wt';
        BucketAcc.Maximum_Size_of_Bucket__c = 5000;
        BucketAcc.Default_Bucket_Name__c = 'Bucket Account';
        insert BucketAcc;
        
        Account Acc=new Account(Name='Test Account',OwnerId=UserInfo.getUserId());
        insert Acc;
        
        Contact Con = new Contact(FirstName = 'Test111', LastName = 'Contact', Email ='sfdcsudhir1@gmail.com',AccountId=Acc.id);
        insert Con;
        
        redwing__Learning__c Learn=new redwing__Learning__c();
        Learn.Name='Test';
        insert Learn;
        
        ccrz__E_Product__c Prod=new ccrz__E_Product__c();
        Prod.Name = 'Test Product';
        Prod.ccrz__SKU__c = 'Test SKU';
        Prod.ccrz__Quantityperunit__c = 1;
        Prod.ccrz__StartDate__c = date.today();
        Prod.ccrz__EndDate__c = date.today()+365;
        insert Prod;
        
        ccrz__E_Spec__c CCspec=new ccrz__E_Spec__c();
        CCspec.Name = 'Survey';
        insert CCspec;
        
        List<ccrz__E_ProductSpec__c> ProductSpec=new List<ccrz__E_ProductSpec__c>();
        
        ccrz__E_ProductSpec__c ProdSpec=new ccrz__E_ProductSpec__c(ccrz__SpecValue__c = 'Base',ccrz__Product__c =Prod.id, ccrz__Spec__c=CCspec.id);
        ccrz__E_ProductSpec__c ProdSpec1=new ccrz__E_ProductSpec__c(ccrz__SpecValue__c = 'Instructor',ccrz__Product__c =Prod.id, ccrz__Spec__c=CCspec.id);
        ccrz__E_ProductSpec__c ProdSpec2=new ccrz__E_ProductSpec__c(ccrz__SpecValue__c = 'Instructor Trainer',ccrz__Product__c =Prod.id, ccrz__Spec__c=CCspec.id);
        
        ProductSpec.add(ProdSpec);
        ProductSpec.add(ProdSpec1);
        ProductSpec.add(ProdSpec2);
        insert ProductSpec;

        redwing__ILT_Class__c IltClass=new redwing__ILT_Class__c();
        IltClass.Name = 'Test Class';
        IltClass.redwing__Learning__c = Learn.id;
        IltClass.redwing__Start_Date__c = date.today();
        IltClass.redwing__End_Date__c=date.today()+10;
        IltClass.Cloud_Craze_Product__c = Prod.id;
        insert IltClass;
        
        redwing__Learning_Assignment__c learnAss=new redwing__Learning_Assignment__c();
        insert learnAss;
        
        redwing__ILT_Roster__c ILTRoast=new redwing__ILT_Roster__c(Contact__c = Con.id,redwing__Learning_Assignment__c = learnAss.id);
        insert ILTRoast;

    }
    public static testMethod void FeedbackSurvey()
    {
        redwing__ILT_Class__c ILClass=[select id from redwing__ILT_Class__c where Name = 'Test Class' LIMIT 1];
        Contact c = [SELECT Id, FirstName, LastName FROM Contact WHERE FirstName='Test111' LIMIT 1];

        redwing__ILT_Roster__c UpdateRoast=[select id,Contact__c from redwing__ILT_Roster__c where Contact__c =: c.id];
        UpdateRoast.redwing__ILT_Class__c = ILClass.id;
        update UpdateRoast;

        Test.startTest();
        ILClass.Class_Closed_Date__c = datetime.now();
        update ILClass; 
        Test.stopTest();
    }
}