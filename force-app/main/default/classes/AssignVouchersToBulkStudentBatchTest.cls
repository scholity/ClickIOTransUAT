@isTest
public with sharing class AssignVouchersToBulkStudentBatchTest
{
    @TestSetup
    static void makeTestData()
    {
        sked__Region__c region = new sked__Region__c();
        region.Name = 'Test Region';
        region.sked__Timezone__c = 'Indian/Coscos';
        insert region;

        sked__Job__c job = new sked__Job__c();
        job.sked__Region__c = region.id;
        job.sked__Duration__c = 314;
        //job.Course_Catalog__c = catalog.id;
        job.End_Date__c = '12/12/2018';
        job.Start_Date__c = '11/11/2018';
        job.Start_Time__c = '16:20';
        job.End_Time__c = '17:20';
        job.sked__Start__c = datetime.newInstance(2019, 9, 15, 12, 30, 0);
        job.sked__Finish__c = datetime.newInstance(2019, 9, 15, 13, 30, 0);
        job.sked__Duration__c = 60;
        job.Job_Month__c = System.Today();
        //job.sked__Location__c = objLocation.Id;
        job.sked__Type__c = 'Community';
        job.Location_Confirmed__c = false; // do not invoke integration logic
        //job.Is_Stacked_Class__c=true;
        //job.Course_Code__c='Test Catalog';
        insert job;

        redwing__Learning__c learning = new redwing__Learning__c();
        learning.Name = 'Test learning';
        learning.redwing__Published__c = true;
        learning.RecordTypeId = Schema.SObjectType.redwing__Learning__c.getRecordTypeInfosByName().get('ILT Event').getRecordTypeId();
        insert learning;

        redwing__Training_Plan__c lPlan2 = new redwing__Training_Plan__c();
        lPlan2.Name = 'Plan2';
        insert lPlan2;

        Redwing__ILT_Class__c clsRecord = new Redwing__ILT_Class__c();
        //clsRecord.Skedulo_Account__c = a.id;
        clsRecord.redwing__End_Date__c = Date.Parse('12/19/2018');
        clsRecord.redwing__End_Time__c= '13:00';
        clsRecord.redwing__Start_Date__c = Date.Parse('12/19/2018');// Assuming Start date = End date
        clsRecord.redwing__Start_Time__c = '12:00';
        clsRecord.Name = 'Test';
        clsRecord.Learning_Plan__c = lPlan2.Id;
        clsRecord.redwing__Learning__c = learning.Id;
        clsRecord.Skedulo_Job_Id__c  = job.Id;
        insert clsRecord;
        
        Voucher__c v = new Voucher__c();
        v.ILT_Class__c = clsRecord.Id;
        insert v;
/*
        redwing__Learning__c l = new redwing__Learning__c();
        l.name = 'Test Learning';
        insert l;

        Voucher__c v2 = new Voucher__c();
        v2.Online_Class__c = l.id;
        insert v2;*/
        
        Student_Bulk_Upload__c student = new Student_Bulk_Upload__c(Student_Email_Address__c = 'test@email.com',
                                                                    Student_First_Name__c    = 'FirstName',
                                                                    Student_Last_Name__c     = 'LastName'
                                                                    );



        insert student;
    }

    static testmethod void testMain()
    {
        Test.startTest();
        AssignVouchersToBulkStudentBatch avts = new AssignVouchersToBulkStudentBatch();
        Database.executeBatch(avts);
        Test.stopTest();

    }

    static testmethod void testgetVoucherForOnlineClass()
    {

        redwing__Learning__c l = new redwing__Learning__c();
        l.name = 'Test Learning';
        insert l;

        Voucher__c v2 = new Voucher__c();
        v2.Online_Class__c = l.id;
        insert v2;

        Test.startTest();
        AssignVouchersToBulkStudentBatch.getVoucherForOnlineClass(l.Id);
        Test.stopTest();

    }

}