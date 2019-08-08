@isTest
private class TestTriggersskedtoILT {
    static testMethod void myUnitTest(){
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
        
        delete objLocation;
        
    }
    
    static testMethod void unitTest2() {
        sked__Resource__c objResource = new sked__Resource__c();
        objResource.Name = 'Test';
        objResource.sked__Is_Active__c = true;
        objResource.sked__Resource_Type__c = 'Person';
        objResource.sked__Category__c = 'Instructor';
        objResource.sked__User__c = UserInfo.getUserId();
        insert objResource;
        
        objResource.Name = 'Test 1';
        update objResource;
        
        delete objResource;
    }
    
    static testMethod void unitTest3() {
    

        redwing__Learning__c learning = new redwing__Learning__c();
        learning.Name = 'Test learning';
        learning.redwing__Published__c = true;
        learning.RecordTypeId = Schema.SObjectType.redwing__Learning__c.getRecordTypeInfosByName().get('ILT Event').getRecordTypeId();
        insert learning;
    
        redwing__ILT_Event__c ilEvent = new redwing__ILT_Event__c();
        ilEvent.redwing__Learning__c = learning.Id;
        insert ilEvent;
        
        sked__Location__c objLocation = new sked__Location__c();
        
        objLocation.Name = 'Test';
        objLocation.sked__Type__c = 'Community';
        objLocation.sked__Address__c = '401 S Monroe St, Little Rock, AR, 72206';
        insert objLocation;
        
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
        catalog.Name = 'Test Catalog';
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
        
        sked__Job__c job = new sked__Job__c();
        job.sked__Region__c = region.id;
        job.sked__Duration__c = 314;
        job.Course_Catalog__c = catalog.id;
        job.End_Date__c = '12/12/2018';
        job.Start_Date__c = '11/11/2018';
        job.Start_Time__c = '16:20';
        job.End_Time__c = '17:20';
        job.sked__Start__c = datetime.newInstance(2019, 9, 15, 12, 30, 0);
        job.sked__Finish__c = datetime.newInstance(2019, 9, 15, 13, 30, 0);
        job.sked__Duration__c = 60;
        job.Job_Month__c = System.Today();
        job.sked__Location__c = objLocation.Id;
        insert job;
        
        job.sked__Job_Status__c ='Cancelled';
        update job;
    }
}