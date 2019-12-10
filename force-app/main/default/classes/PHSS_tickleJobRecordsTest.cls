@isTest
private class PHSS_tickleJobRecordsTest {

    static testMethod void myUnitTest() {

        sked__Location__c objLocation = new sked__Location__c();
        objLocation.Name = 'Test';
        objLocation.sked__Type__c = 'Community';
        objLocation.sked__Address__c = '401 S Monroe St, Little Rock, AR, 72206';
        insert objLocation;

        Course_Catalog__c catalog = new Course_Catalog__c();
        catalog.Name = 'C12345';
        catalog.Number_of_Students__c = 5;
        catalog.Type__c = 'Community';
        insert catalog;

        sked__Region__c region = new sked__Region__c();
        region.Name = 'Test Region';
        region.sked__Timezone__c = 'Indian/Coscos';
        insert region;

        List<sked__Job__c> jobList = new List<sked__Job__c>();
        sked__Job__c job = new sked__Job__c();
        job.sked__Region__c = region.id;
        job.Course_Catalog__c = catalog.id;
        job.Start_Date__c = '12/15/2019';
        job.End_Date__c = '12/15/2019';
        job.Start_Time__c = '12:30';
        job.End_Time__c = '13:30';
        //job.sked__Timezone__c = 'US/Eastern';
        job.sked__Start__c = datetime.newInstance(2019, 12, 15, 12, 30, 0);
        job.sked__Finish__c = datetime.newInstance(2019, 12, 15, 13, 30, 0);
        job.sked__Duration__c = 60;
        job.Job_Month__c = System.Today();
        job.sked__Location__c = objLocation.Id;
        job.sked__Type__c = 'Community';
        job.Location_Confirmed__c = true; // do not invoke integration logic
        job.Is_Master_Class__c = true;
        job.Is_Stacked_Class__c = true;
        job.Course_Code__c = 'C12345';
        job.sked__Job_Status__c = 'Dispatched';
        //job.sked__Recurring_Schedule__c = schedule.Id;
        jobList.add(job);

        sked__Job__c job2 = new sked__Job__c();
        job2.sked__Region__c = region.id;
        job2.Course_Catalog__c = catalog.id;
        job2.Start_Date__c = '12/16/2019';
        job2.End_Date__c = '12/16/2019';
        job2.Start_Time__c = '12:30';
        job2.End_Time__c = '13:30';
        //job2.sked__Timezone__c = 'US/Eastern';
        job2.sked__Start__c = datetime.newInstance(2019, 12, 16, 12, 30, 0);
        job2.sked__Finish__c = datetime.newInstance(2019, 12, 16, 13, 30, 0);
        job2.sked__Duration__c = 60;
        job2.Job_Month__c = System.Today();
        job2.sked__Location__c = objLocation.Id;
        job2.sked__Type__c = 'Community';
        job2.Location_Confirmed__c = true; // do not invoke integration logic
        job2.Is_Master_Class__c = true;
        job2.Is_Stacked_Class__c = true;
        job2.Course_Code__c = 'C12345';
        job2.sked__Job_Status__c = 'Dispatched';
        //job2.sked__Recurring_Schedule__c = schedule.Id;
        jobList.add(job2);
        insert jobList;

        Test.startTest();
        PHSS_tickleJobRecords bp = new PHSS_tickleJobRecords();
        Database.executeBatch(bp, 20);

        Test.stopTest();
    }
}