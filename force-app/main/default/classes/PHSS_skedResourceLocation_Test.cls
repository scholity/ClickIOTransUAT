@isTest 
public class PHSS_skedResourceLocation_Test {
    @isTest static void TestAddDeleteInstructors() {
        Map<string, sObject> mapTestData1 = skedDataSetup.setupCommonTestData();   
        
        sked__Resource__c instructor1 = (sked__Resource__c)mapTestData1.get('instructor1');
        sked__Resource__c instructor2 = (sked__Resource__c)mapTestData1.get('instructor2');
        
        skedGoogleApi_Mock mockClass = new skedGoogleApi_Mock();
        mockClass.calloutMethod = 'getGeocode';
        Test.setMock(HttpCalloutMock.class, mockClass);      

        Test.startTest();
        
        List<sked__Resource__c> resources = new List<sked__Resource__c>();
        instructor1.sked__Home_Address__c = '75 Rio Robles, San Jose, CA 95134';
        instructor1.sked__Resource_Type__c = 'Person';
        instructor2.sked__Home_Address__c = '75 Rio Robles, Apt 123, San Jose, CA 95134';
        instructor2.sked__Resource_Type__c = 'Person';        
        resources.add(instructor1);
        resources.add(instructor2);
        update resources;
        
        sked__Region__c testRegion = new sked__Region__c();
        testRegion.Name = 'Mid-Atlantic EST';
        testRegion.sked__Timezone__c  = 'US/Eastern';
        testRegion.sked__Country_Code__c  = 'US';
        insert testRegion;
        
        List<sked__Location__c> locations = new List<sked__Location__c>();
        sked__Location__c testLocation1 = new sked__Location__c();
        sked__Location__c testLocation2 = new sked__Location__c();        
        testLocation1.sked__Type__c = 'Community';
        testLocation1.sked__Region__c = testRegion.Id;
        testLocation1.Is_Active__c = true;
        testLocation1.sked__Address__c = '101 S Main, Sacramento, CA 91234 US';
        testLocation2.sked__Type__c = 'Community';
        testLocation2.sked__Region__c = testRegion.Id;
        testLocation2.Is_Active__c = true;
        testLocation2.sked__Address__c = '777 N Lucky St, Suite 200, Los Angeles, CA 95678 US';        
        locations.add(testLocation1);
        locations.add(testLocation2);
        insert locations;
        /*
        sked__Job__c theJob = new sked__Job__c();
        theJob.sked__Start__c = DateTime.Now().AddHours(24);
        theJob.sked__Finish__c = DateTime.Now().AddHours(26);
        theJob.sked__Address__c = '101 S Main, Sacramento, CA 91234 US';
        theJob.After_class_duration__c = 30.0;
        theJob.Before_class_duration__c = 30.0;
        theJob.Break_duration__c = 30.0;
        theJob.Class_Sub_Type__c = 'Base';
        theJob.Confirmed__c = false;
        theJob.Dispatch__c = true;
        theJob.Is_Master_Class__c = false;
        theJob.Is_Stacked_Class__c = false;
        theJob.Job_Month__c = Date.Today();
        theJob.Location_Confirmed__c = false;
        theJob.Number_of_Instructors__c = 1.0;
        theJob.Number_of_Students__c = 12.0;
        theJob.Ready_to_Publish__c = false;
        theJob.sked__Duration__c = 120.0;
        theJob.sked__Job_Status__c = 'Pending Allocation';
        theJob.sked__Location__c = testLocation1.Id;
        theJob.sked__Region__c  = testRegion.Id;
        theJob.sked__Type__c = 'Full Service';
        
        insert theJob;

        redwing__ILT_Class__c theClass = new redwing__ILT_Class__c();
        theClass.Skedulo_Job_Id__c = theJob.Id;   
        insert theClass;
        
        sked__Job_Allocation__c theAllocation = new sked__Job_Allocation__c();
        theAllocation.sked__Status__c = skedConstants.JOB_ALLOCATION_STATUS_CONFIRMED;
        theAllocation.sked__Resource__c = instructor1.Id;
        theAllocation.sked__job__c = theJob.Id;
        insert theAllocation;           
        */
        resources.clear();
        resources.add(instructor2);
        
        Database.DeleteResult[] drList = Database.delete(resources, false);
        
        locations.clear();
        locations.add(testLocation2);
        
        Database.DeleteResult[] locList = Database.delete(locations, false);        
        
        Test.stopTest();
    }
}