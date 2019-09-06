@isTest
private class skedJobToILTClass_Test {


    static testMethod void myUnitTest(){
        // Enable Location Integration
        PHSS_TriggerSettings__c triggerSettings = PHSS_TriggerSettings__c.getOrgDefaults();
        triggerSettings.skedLocationtoILTLocationTriggerDisabled__c = false;
        upsert triggerSettings;        
        
        sked__Location__c objLocation = new sked__Location__c();
        
        objLocation.Name = 'Test';
        objLocation.sked__Type__c = 'Community';
        objLocation.sked__Address__c = '401 S Monroe St, Little Rock, AR, 72206';
        insert objLocation;
        
        objLocation.sked__Address__c = '403 S Monroe St, Little Rock, AR, 72206';
        update objLocation;
        
        objLocation.sked__Address__c = '403, S Monroe St, Little Rock, AR, 72206';
        update objLocation;
        
        objLocation.sked__Address__c = '403, S Monroe St, Little Rock, 77206, AR';
        update objLocation;
        
        objLocation.sked__Address__c = '403, S Monroe St, Little Rock, 77206, 77206';
        update objLocation;
        
        objLocation.sked__Address__c = '403, S Monroe, St, Little Rock, 77206, 77206';
        update objLocation;
        
        objLocation.sked__Address__c = '403, S Monroe, St, Little Rock, 77206, 77206, 77';
        objLocation.Is_Active__c = false;
        update objLocation;
        
        List<redwing__ILT_Location__c> skedlocation = [Select id, name, Skedulo_Location__c from redwing__ILT_Location__c where Skedulo_Location__c =: objLocation.id];
        System.assertEquals(1,skedlocation.size()); // Assert to confirm Ilt location is created
        delete objLocation;
        
    }
    
    static testMethod void unitTest2() {
        // Enable Resource Integration
        PHSS_TriggerSettings__c triggerSettings = PHSS_TriggerSettings__c.getOrgDefaults();
        triggerSettings.skedResourcetoILTInstructTriggerDisabled__c = false;
        upsert triggerSettings;  
              
        sked__Resource__c objResource = new sked__Resource__c();
        objResource.Name = 'Test';
        objResource.sked__Is_Active__c = true;
        objResource.sked__Resource_Type__c = 'Person';
        objResource.sked__Category__c = 'Instructor';
        objResource.sked__User__c = UserInfo.getUserId();
        insert objResource;
        
        objResource.Name = 'Test 1';
        update objResource;
        
        List<redwing__Instructor__c> skedrestest = [Select id, name,Skedulo_Instructor__c,redwing__User__c from redwing__Instructor__c where Skedulo_Instructor__c =: objResource.id];
        System.assertEquals(1,skedrestest.size()); // Assert to confirm redwing__Instructor__c is created
        
        delete objResource;
    }
    
    static testMethod void unitTest3() {
        // Enable Job Integration
        PHSS_TriggerSettings__c triggerSettings = PHSS_TriggerSettings__c.getOrgDefaults();
        triggerSettings.skedJobtoILTClassTriggerDisabled__c = false;
        upsert triggerSettings;        

        redwing__Learning__c learning = new redwing__Learning__c();
        learning.Name = 'Test learning';
        learning.redwing__Published__c = true;
        learning.RecordTypeId = Schema.SObjectType.redwing__Learning__c.getRecordTypeInfosByName().get('ILT Event').getRecordTypeId();
        insert learning;
    
        redwing__ILT_Event__c ilEvent = new redwing__ILT_Event__c();
        ilEvent.redwing__Learning__c = learning.Id;
        insert ilEvent;
        
        redwing__Training_Plan__c lPlan = new redwing__Training_Plan__c();
        lPlan.Name = 'Test Plan';
        insert lPlan;
        
        redwing__Training_Plan_Section__c lPlanSection = new redwing__Training_Plan_Section__c();
        lPlanSection.Name = 'Test Plan Section';
        lPlanSection.redwing__Training_Plan__c = lPlan.Id;
        insert lPlanSection;
        
        redwing__Training_Plan_Section_Item__c lPlanSectionItem = new redwing__Training_Plan_Section_Item__c();
        lPlanSectionItem.redwing__Learning__c = learning.Id;
        lPlanSectionItem.redwing__Training_Plan_Section__c = lPlanSection.Id;
        insert lPlanSectionItem;
        
        Course_Catalog__c catalog = new Course_Catalog__c();
        catalog.Name = 'C12345';
        catalog.Number_of_Students__c = 5;
        catalog.Type__c = 'Community';
        insert catalog;
        
        ccrz__E_Product__c product = new ccrz__E_Product__c();
        product.Name = 'Test Prod';
        product.ccrz__SKU__c = String.ValueOf(System.Now());
        product.ccrz__Quantityperunit__c = 2.0;
        product.ccrz__StartDate__c =  System.Today().addDays(2);
        product.ccrz__EndDate__c = System.Today().addDays(20);
        product.LMS_Learning_Plan__c = lPlan.id;
        product.Course_Catalog__c = catalog.id;
        insert product;

        sked__Region__c region = new sked__Region__c();
        region.Name = 'Test Region';
        region.sked__Timezone__c = 'Indian/Coscos';
        insert region;

        ccrz__E_PriceList__c ccpl= new ccrz__E_PriceList__c();
        ccpl.ccrz__Enabled__c = True;
        ccpl.ccrz__Storefront__c = 'GeneralStore';
        ccpl.Name='ZIP-72206';
        ccpl.ccrz__CurrencyISOCode__c='USD';
        ccpl.ccrz__StartDate__c=date.today();
        ccpl.ccrz__EndDate__c=date.today()+2;
        insert ccpl;

        ccrz__E_PriceListItem__c ccp= new ccrz__E_PriceListItem__c();
        ccp.ccrz__Product__c=product.id;
        ccp.ccrz__Pricelist__c=ccpl.id;
        ccp.ccrz__StartDate__c=date.today();
        ccp.ccrz__EndDate__c=date.today()+2;
        ccp.ccrz__Price__c=100;
        insert ccp;

        sked__Location__c objLocation = new sked__Location__c();
        objLocation.Name = 'Test';
        objLocation.sked__Type__c = 'Community';
        objLocation.sked__Address__c = '401 S Monroe St, Little Rock, AR, 72206';
        objLocation.Is_Active__c = true;
        insert objLocation;

        sked__Resource__c objResource = new sked__Resource__c();
        objResource.Name = 'Test';
        objResource.sked__Is_Active__c = true;
        objResource.sked__Resource_Type__c = 'Person';
        objResource.sked__Category__c = 'Instructor';
        objResource.sked__User__c = UserInfo.getUserId();
        insert objResource;        
        
        sked__Recurring_Schedule__c schedule = new sked__Recurring_Schedule__c();
        insert schedule;        

        List<sked__Job__c> jobList = new List<sked__Job__c>();
        sked__Job__c job = new sked__Job__c();
        job.sked__Region__c = region.id;
        job.Course_Catalog__c = catalog.id;
        job.Start_Date__c = '09/15/2018';        
        job.End_Date__c = '09/15/2018';
        job.Start_Time__c = '12:30';
        job.End_Time__c = '13:30';
        //job.sked__Timezone__c = 'US/Eastern';
        job.sked__Start__c = datetime.newInstance(2018, 9, 15, 12, 30, 0);
        job.sked__Finish__c = datetime.newInstance(2018, 9, 15, 13, 30, 0);
        job.sked__Duration__c = 60;
        job.Job_Month__c = System.Today();
        job.sked__Location__c = objLocation.Id;
        job.sked__Type__c = 'Community';
        job.Location_Confirmed__c = false; // do not invoke integration logic
        job.Is_Master_Class__c=true;
        job.Is_Stacked_Class__c=true;
        job.Course_Code__c='C12345';
        job.sked__Job_Status__c = 'Dispatched';
		job.sked__Recurring_Schedule__c = schedule.Id;          
        jobList.add(job);
        
        sked__Job__c job2 = new sked__Job__c();
        job2.sked__Region__c = region.id;
        job2.Course_Catalog__c = catalog.id;
        job2.Start_Date__c = '09/16/2018';        
        job2.End_Date__c = '09/16/2018';
        job2.Start_Time__c = '12:30';
        job2.End_Time__c = '13:30';
        //job2.sked__Timezone__c = 'US/Eastern';
        job2.sked__Start__c = datetime.newInstance(2018, 9, 16, 12, 30, 0);
        job2.sked__Finish__c = datetime.newInstance(2018, 9, 16, 13, 30, 0);
        job2.sked__Duration__c = 60;
        job2.Job_Month__c = System.Today();
        job2.sked__Location__c = objLocation.Id;
        job2.sked__Type__c = 'Community';
        job2.Location_Confirmed__c = false; // do not invoke integration logic
        job2.Is_Master_Class__c=true;
        job2.Is_Stacked_Class__c=true;
        job2.Course_Code__c='C12345';
        job2.sked__Job_Status__c = 'Dispatched';
		job2.sked__Recurring_Schedule__c = schedule.Id;  
        jobList.add(job2);
        insert jobList;

        sked__Job_Allocation__c allocation = new sked__Job_Allocation__c();
        allocation.sked__Job__c = jobList[0].Id;
        allocation.sked__Resource__c = objResource.Id;
        allocation.sked__Status__c = 'Pending Dispatch';
        insert allocation;                    
        
        List<ccrz__E_PriceListItem__c> priceListItems = [SELECT ccrz__Product__c, ccrz__PriceList__r.ccrz__StartDate__c, ccrz__PriceList__r.ccrz__EndDate__c, 
                                                         ccrz__PriceList__r.Name, ccrz__StartDate__c, ccrz__EndDate__c, ccrz__Price__c
                                                         FROM ccrz__E_PriceListItem__c WHERE ccrz__Product__c =:product.Id AND ccrz__PriceList__r.Name = : CCPL.Name
                                                         AND ccrz__PriceList__r.ccrz__Enabled__c = True AND ccrz__PriceList__r.ccrz__Storefront__c = : ccpl.ccrz__Storefront__c];
        System.debug('pricelistITems'+priceListItems);
        
        //job.Location_Confirmed__c = true; // invoke integration logic to create class and session and ilt instructor     
        //update job; 
        job.sked__Job_Status__c = 'Cancelled'; 
        update job;

        List<redwing__ILT_Class__c> createiltclass = [Select id, name from redwing__ILT_Class__c where Skedulo_Job_Id__c =:job.id];
        System.assertEquals(1,createiltclass.size());  // Assert to confirm ILTClass is created
        
        List<redwing__ILT_Location__c> skedlocation = [Select id, name, Skedulo_Location__c from redwing__ILT_Location__c where Skedulo_Location__c =: objLocation.id];
        System.assertEquals(1,skedlocation.size());
    }

    static testMethod void unitTest4_FullServiceClass() {

        Map<String, Object> data = phss_cc_TestDataFactory.createInsertTestLearningObjects();
        redwing__ILT_Class__c iltClass = (redwing__ILT_Class__c) data.get(phss_cc_TestDataFactory.TEST_ILT_CLASS);

        // FS test data - obtain training event
        Map<String, Object> fsMapData = skedDataSetup.setupFullServiceTestData();
    }
}