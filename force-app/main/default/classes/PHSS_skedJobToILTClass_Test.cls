@isTest
private class PHSS_skedJobToILTClass_Test {
    @isTest static void testRecurringClass(){
        sked__Location__c objLocation = new sked__Location__c();
        
        objLocation.Name = 'Test Location';
        objLocation.sked__Type__c = 'Community';
        objLocation.Is_Active__c = true;        
        objLocation.sked__Address__c = '401 S Monroe St, Little Rock, AR, 72206';
        insert objLocation;

        sked__Resource__c objResource = new sked__Resource__c();
        objResource.Name = 'Test Resource';
        objResource.sked__Is_Active__c = true;
        objResource.sked__Resource_Type__c = 'Person';
        objResource.sked__Category__c = 'Instructor';
        objResource.sked__User__c = UserInfo.getUserId();
        insert objResource;

        redwing__Learning__c learning = new redwing__Learning__c();
        learning.Name = 'Test learning';
        learning.redwing__Published__c = true;
        learning.RecordTypeId = Schema.SObjectType.redwing__Learning__c.getRecordTypeInfosByName().get('ILT Event').getRecordTypeId();
        insert learning;
    
        redwing__ILT_Event__c iltEvent = new redwing__ILT_Event__c();
        iltEvent.redwing__Learning__c = learning.Id;
        insert iltEvent;
        
        redwing__Training_Plan__c lPlan = new redwing__Training_Plan__c();
        lPlan.Name = 'Test Learning Plan';
        insert lPlan;
        
        redwing__Training_Plan_Section__c lPlanSection = new redwing__Training_Plan_Section__c();
        lPlanSection.Name = 'Test Learning Plan Section';
        lPlanSection.redwing__Training_Plan__c = lPlan.Id;
        insert lPlanSection;
        
        redwing__Training_Plan_Section_Item__c lPlanSectionItem = new redwing__Training_Plan_Section_Item__c();
        lPlanSectionItem.redwing__Learning__c = learning.Id;
        lPlanSectionItem.redwing__Training_Plan_Section__c = lPlanSection.Id;
        insert lPlanSectionItem;
        
        Course_Catalog__c catalog = new Course_Catalog__c();
        catalog.Name = 'Code101';
		catalog.Number_of_Instructors__c = 1;
        catalog.Number_of_Students__c = 12;
        catalog.Ratio_to_Instructor__c = '1:12';
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
        
        sked__Recurring_Schedule__c schedule = new sked__Recurring_Schedule__c();
        insert schedule;
        
        List<sked__Job__c> newJobs = new List<sked__Job__c>();
        List<sked__Job_Allocation__c> newAllocations = new List<sked__Job_Allocation__c>();
        sked__Job__c job = new sked__Job__c();
        job.sked__Region__c = region.id;
        job.sked__Duration__c = 314;
        job.Course_Catalog__c = catalog.id;
        job.End_Date__c = '12/12/2018';
        job.Start_Date__c = '12/12/2018';
        job.Start_Time__c = '16:20';
        job.End_Time__c = '17:20';
        job.sked__Start__c = datetime.newInstance(2019, 12, 12, 16, 20, 0);
        job.sked__Finish__c = datetime.newInstance(2019, 12, 12, 17, 20, 0);
        job.sked__Duration__c = 60;
        job.Number_of_Instructors__c = 1;
        job.sked__Location__c = objLocation.Id;
        job.sked__Recurring_Schedule__c = schedule.Id;
        newJobs.add(job);

        sked__Job__c job2 = new sked__Job__c();
        job2.sked__Region__c = region.id;
        job2.sked__Duration__c = 314;
        job2.Course_Catalog__c = catalog.id;
        job2.End_Date__c = '12/13/2018';
        job2.Start_Date__c = '12/13/2018';
        job2.Start_Time__c = '16:20';
        job2.End_Time__c = '17:20';
        job2.sked__Start__c = datetime.newInstance(2019, 12, 13, 16, 20, 0);
        job2.sked__Finish__c = datetime.newInstance(2019, 12, 13, 17, 20, 0);
        job2.sked__Duration__c = 60;
        job2.Number_of_Instructors__c = 1;        
        job2.sked__Location__c = objLocation.Id;        
        job2.sked__Recurring_Schedule__c = schedule.Id;
        newJobs.add(job2);  
        
        sked__Job__c job3 = new sked__Job__c();
        job3.sked__Region__c = region.id;
        job3.sked__Duration__c = 314;
        job3.End_Date__c = '12/14/2018';
        job3.Start_Date__c = '12/14/2018';
        job3.Start_Time__c = '16:20';
        job3.End_Time__c = '17:20';
        job3.sked__Start__c = datetime.newInstance(2019, 12, 14, 16, 20, 0);
        job3.sked__Finish__c = datetime.newInstance(2019, 12, 14, 17, 20, 0);
        job3.sked__Duration__c = 60;
        job3.Number_of_Instructors__c = 1;        
        job3.sked__Location__c = objLocation.Id;           
        job3.Is_Master_Class__c = true;
        job3.Is_Stacked_Class__c = true;  
        job3.Course_Code__c = 'Code101';        
        newJobs.add(job3);     
        
        sked__Job__c job4 = new sked__Job__c();
        job4.sked__Region__c = region.id;
        job4.sked__Duration__c = 314;
        job4.End_Date__c = '12/14/2018';
        job4.Start_Date__c = '12/14/2018';
        job4.Start_Time__c = '16:20';
        job4.End_Time__c = '17:20';
        job4.sked__Start__c = datetime.newInstance(2019, 12, 14, 16, 20, 0);
        job4.sked__Finish__c = datetime.newInstance(2019, 12, 14, 17, 20, 0);
        job4.sked__Duration__c = 60;
        job4.Number_of_Instructors__c = 1;        
        job4.sked__Location__c = objLocation.Id;          
        job4.Is_Master_Class__c = false;
        job4.Is_Stacked_Class__c = true;
        job4.sked__Parent__c = job3.Id; 
        job4.Course_Code__c = 'Code101';
        newJobs.add(job4);        
        Database.insert(newJobs);
    
        sked__Job_Allocation__c theAllocation = new sked__Job_Allocation__c();
        theAllocation.sked__Status__c = skedConstants.JOB_ALLOCATION_STATUS_CONFIRMED;
        theAllocation.sked__Resource__c = objResource.Id;
        theAllocation.sked__job__c = job.Id;
        newAllocations.add(theAllocation);  
        
        sked__Job_Allocation__c theAllocation2 = theAllocation.clone(false);
        theAllocation2.sked__job__c = job2.Id;
        newAllocations.add(theAllocation2);     
        
        sked__Job_Allocation__c theAllocation3 = theAllocation.clone(false);
        theAllocation3.sked__job__c = job3.Id;
        newAllocations.add(theAllocation3);    
        Database.insert(newAllocations);
        
        job2.sked__Job_Status__c = 'Cancelled';
        update job2;
        
        theAllocation3.sked__Status__c = 'Deleted';
        update theAllocation3;
        
    }
}