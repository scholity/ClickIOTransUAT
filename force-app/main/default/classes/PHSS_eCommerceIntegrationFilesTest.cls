@isTest
private class PHSS_eCommerceIntegrationFilesTest {

    @testSetup
    private static void createTestData() {

        phss_cc_TestDataFactory.initCCSettings();
        //phss_cc_TestDataFactory.createInsertTestTrainingPlan();
        ccrz__E_AccountGroup__c accountGroup = phss_cc_TestDataFactory.createInsertTestAccountGroup();
        Account acc = phss_cc_TestDataFactory.createInsertTestAccount(accountGroup);
        phss_cc_TestDataFactory.createInsertTestOpportunity(acc);
        phss_cc_TestDataFactory.createInsertTestProducts(3);
        phss_cc_TestDataFactory.createInsertTestPricelist();
        phss_cc_TestDataFactory.createInsertTestContactAddress();


        // create records for activeOnlineClasses
        Map<String, Object>  learningObjects = phss_cc_TestDataFactory.createInsertTestLearningObjects();
        redwing__Training_Plan__c trainingPlan = (redwing__Training_Plan__c) learningObjects.get(phss_cc_TestDataFactory.TEST_TRAINING_PLAN);
        trainingPlan.Classroom_Setting__c = 'Online';
        trainingPlan.redwing__Status__c = 'Active';
        update trainingPlan;

        redwing__Learning__c learning = (redwing__Learning__c) learningObjects.get(phss_cc_TestDataFactory.TEST_LEARNING);
        learning.RecordTypeId = Schema.SObjectType.redwing__Learning__c.getRecordTypeInfosByName().get('Media').getRecordTypeId();
        update learning;

        // create location record for class
        redwing__ILT_Location__c theLocation = new redwing__ILT_Location__c();
        

        theLocation.Name = 'My Location';
        theLocation.redwing__Address_1__c   = '101 S Main';
        theLocation.redwing__Address_2__c   = '';
        theLocation.redwing__City__c        = 'Anywhere';
        theLocation.redwing__State__c       = 'NY';
        theLocation.redwing__Postal_Code__c = '10012';
        theLocation.redwing__Country__c     = 'US'; 
        insert theLocation;

        String startTime = '12:00';//String.valueOf(Datetime.now().addHours(1).time()).left(5);
        String endTime = '15:00';//String.valueOf(Datetime.now().addHours(3).time()).left(5);
        
        // create records for activeCommunityClasses
        redwing__ILT_Event__c event = (redwing__ILT_Event__c) learningObjects.get(phss_cc_TestDataFactory.TEST_ILT_EVENT);
        Map<String, Object> skeduloObjects = phss_cc_TestDataFactory.createInsertTestSkeduloJob(event);
        redwing__ILT_Class__c iltClass = (redwing__ILT_Class__c) skeduloObjects.get(phss_cc_TestDataFactory.TEST_ILT_CLASS);
        iltClass.Request_Type__c = 'Community';
        iltClass.Skedulo_Job_Status__c  = 'Pending Allocation';
        iltClass.redwing__Location__c = theLocation.Id;
        iltClass.Skedulo_Job_Active__c = true;
        iltClass.Site_Postal_Code__c = '10012';
        iltClass.redwing__Start_Time__c = startTime;
        iltClass.redwing__End_Time__c = endTime;
        iltClass.redwing__Start_Date__c = Date.today();
        iltClass.redwing__End_Date__c = Date.today().addDays(1);
        update iltClass;

        redwing__ILT_Session__c iltSession = new redwing__ILT_Session__c(
                redwing__ILT_Class__c = iltClass.Id,
                redwing__Date__c = Date.today(),
                redwing__Start_Time__c = startTime,
                redwing__End_Time__c = endTime,
            	redwing__Location__c = theLocation.Id
        );
        insert iltSession;

    }
    
    @isTest
    private static void getCommunityClassesTest() {
    	redwing__Training_Plan__c lPlan = new redwing__Training_Plan__c();
        lPlan.Name = 'Test Plan';
        lPlan.redwing__Status__c = 'Active';
        lPlan.redwing__Start_Date__c = System.today();
        lPlan.redwing__End_Date__c = System.today();
        insert lPlan;
        

        Test.startTest();
        PHSS_eCommerceIntegrationFiles inst = new PHSS_eCommerceIntegrationFiles();
        inst.getAllCommunityClasses();
        Test.stopTest();
    }    
}