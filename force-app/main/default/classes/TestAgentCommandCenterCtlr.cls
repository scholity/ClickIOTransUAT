@isTest


private class TestAgentCommandCenterCtlr {
      
@testSetup static void methodName() {
    Switch__c cohstest = new Switch__c();
        cohstest.Switch__c = true;
        cohstest.name = 'CaseOwnerHistorySwitch';
        insert cohstest;
}     
        
      static testMethod void testAcceptNextCase() {
        
        
        User adminUser = [SELECT Id FROM User WHERE Profile.Name ='System Administrator' AND isActive = true LIMIT 1];
        Id adminProfileId = [SELECT Id FROM Profile WHERE Name ='System Administrator' LIMIT 1].Id;
        
        // Add a user        
        User user1 = createUser('test3225', adminUser.id, adminProfileId);
        
        // Create a queue
        Group group1 = new Group (
            type='Queue',
            name='Test Queue 1'
        );
        INSERT group1;
        
        QueueSObject queueSObject1 = new QueueSObject(
            SObjectType='Case',
            QueueId = group1.id
        );
        INSERT queueSObject1;
        
        
        // Add user to queue
        GroupMember groupMember1 = new GroupMember(
            groupId = group1.id,
            userOrGroupID = user1.id  // user id
        );
        
        INSERT groupMember1;
        
        // Create several cases
        
        System.debug('**** group id: ' + group1.id);
        
        
        System.runAs(user1) {
            List<Case> casesCreated = createCases(2, group1.id);
            
            AgentCommandCenterCtlr.AcceptNextCaseResult result = new AgentCommandCenterCtlr.AcceptNextCaseResult();
            result = AgentCommandCenterCtlr.acceptNextCase(); 
            System.AssertEquals(result.didCaseOwnershipChange, true);
        }
   
    }



    static testMethod void testAcceptNextCaseNegative() {
        
        
        // test accept next case with no cases in the queue
        
        User adminUser = [SELECT Id FROM User WHERE Profile.Name ='System Administrator' AND isActive = true LIMIT 1];
        Id adminProfileId = [SELECT Id FROM Profile WHERE Name ='System Administrator' LIMIT 1].Id;
        
        // Add a user        
        User user1 = createUser('test5553', adminUser.id, adminProfileId);
        
        // Create a queue
        Group group1 = new Group (
            type='Queue',
            name='Test Queue 1'
        );
        INSERT group1;
        
        QueueSObject queueSObject1 = new QueueSObject(
            SObjectType='Case',
            QueueId = group1.id
        );
        INSERT queueSObject1;
        
        
        // Add user to queue
        GroupMember groupMember1 = new GroupMember(
            groupId = group1.id,
            userOrGroupID = user1.id  // user id
        );
        
        INSERT groupMember1;
        
        System.runAs(user1) {
            // do not add any cases to the queue 
                    
            AgentCommandCenterCtlr.AcceptNextCaseResult result = new AgentCommandCenterCtlr.AcceptNextCaseResult();
            result = AgentCommandCenterCtlr.acceptNextCase(); 
            System.AssertEquals(result.didCaseOwnershipChange, false);
            
        }
   
    }
    
    /*
    *   Make sure test cases data is created with expected attributes
    */
    static testMethod void testCaseCreationMethods() {
        
        
        User adminUser = [SELECT Id FROM User WHERE Profile.Name ='System Administrator' AND isActive = true LIMIT 1];
        Id adminProfileId = [SELECT Id FROM Profile WHERE Name ='System Administrator' LIMIT 1].Id;
        
        // Add a user        
        User user1 = createUser('test5553', adminUser.id, adminProfileId);
        
        // Create a queue
        Group group1 = new Group (
            type='Queue',
            name='Test Queue 1'
        );
        INSERT group1;
        
        QueueSObject queueSObject1 = new QueueSObject(
            SObjectType='Case',
            QueueId = group1.id
        );
        
        insert queueSObject1;
        
         // Add user to queue
        GroupMember groupMember1 = new GroupMember(
            groupId = group1.id,
            userOrGroupID = user1.id  // user id
        );
        
        insert groupMember1;
        
        Test.startTest();
        /* Create cases without Follow_Up_Date_Time__c field */
        List<Case> cases = createCases(2, group1.id);
        System.assertEquals(cases.size(), 2);
        
        for (Case c :cases) {
            System.assertEquals(c.Follow_Up_Date_Time__c, null);
        }
        
        /* Create cases with future Follow_Up_Date_Time_Field__c */
        cases = null;
        cases = createCases(2, group1.id, 3);// Follow_Up_Date_Time__c will be 3 days from today
        System.assertEquals(cases.size(), 2);
        for (Case c :cases) {
            System.assertEquals(c.Follow_Up_Date_Time__c, Date.today() + 3);
        }
        
        /* Create cases with future Follow_Up_Date_Time_Field__c 0 */
        cases = null;
        cases = createCases(2, group1.id, 0);// Follow_Up_Date_Time__c should be today
        System.assertEquals(cases.size(), 2);
        
        for (Case c :cases) {
            System.assertEquals(c.Follow_Up_Date_Time__c, Date.today());
        }
        
        Test.stopTest();
    }
    
    /*
    * If case Folow_Up_Date_Time__c is in future case should not bet re-assigned
    */
    static testMethod void testAcceptNextCaseWithFutureFollowUpDate() {
        
         
        User adminUser = [SELECT Id FROM User WHERE Profile.Name ='System Administrator' AND isActive = true LIMIT 1];
        Id adminProfileId = [SELECT Id FROM Profile WHERE Name ='System Administrator' LIMIT 1].Id;
        
        // Add a user        
        User user1 = createUser('test5553', adminUser.id, adminProfileId);
        
        // Create a queue
        Group group1 = new Group (
            type='Queue',
            name='Test Queue 1'
        );
        INSERT group1;
        
        QueueSObject queueSObject1 = new QueueSObject(
            SObjectType='Case',
            QueueId = group1.id
        );
        
        insert queueSObject1;
        
         // Add user to queue
        GroupMember groupMember1 = new GroupMember(
            groupId = group1.id,
            userOrGroupID = user1.id  // user id
        );
        
        insert groupMember1;
        
        
        System.runAs(user1){
            
            
            List<Case> cases = createCases(3, group1.id, 3);
            Map<Id, Case> casesMap = new Map<Id, Case>();
        
            System.assertEquals(cases.size(), 3);
            
            /* When case(s) have future follow up date accept new case method should ignore those cases */
            AgentCommandCenterCtlr.AcceptNextCaseResult result = new AgentCommandCenterCtlr.AcceptNextCaseResult();
            result = AgentCommandCenterCtlr.acceptNextCase(); 
            
            System.assertEquals(result.didCaseOwnershipChange, false);
            System.assertEquals(result.caseId, null);
            
            /* Change Follow_Up_Date_Time__c field to today and retest */
            for (Case c :cases) {
                c.Follow_Up_Date_Time__c = Date.today();
            }
            
            update cases;
            
            result = null;
            result = new AgentCommandCenterCtlr.AcceptNextCaseResult();
            result = AgentCommandCenterCtlr.acceptNextCase(); 
            
            System.assertEquals(result.didCaseOwnershipChange, true);
            System.assertNotEquals(result.caseId, null);
            
            /* Change Follow_Up_Date_Time__c field to yesterday and retest */
            for (Case c :cases) {
                c.Follow_Up_Date_Time__c = Date.today() - 1;//yesterday
            }
            
            update cases;
            
            result = null;
            result = new AgentCommandCenterCtlr.AcceptNextCaseResult();
            result = AgentCommandCenterCtlr.acceptNextCase(); 
            
            System.assertEquals(result.didCaseOwnershipChange, true);
            System.assertNotEquals(result.caseId, null);
            
        }
        
    }

    
    private static List<Case> createCases (Integer numberToCreate, String caseOwnerId, Integer followUpDateFutureDays) {
        
        
        List<Case> cases = new List<Case>();
        
        for (Integer i = 0; i<numberToCreate; i++) {
            
            Case newCase = new Case(
                subject = 'Case subject ' + i,
                ownerId = caseOwnerId
            );
            
            if (followUpDateFutureDays > -1) {
                newCase.Follow_Up_Date_Time__c = (Date.today() + followUpDateFutureDays);       
            }
            
            cases.add(newCase); 
        }
        //Test.startTest();
        insert cases; 
        //Test.stopTest();
        
        return cases;
        
    }

    private static List<Case> createCases (Integer numberToCreate, String caseOwnerId) {
        
        return createCases(numberToCreate, caseOwnerId, -1);
    }
    

    private static User createUser ( String uname, Id managerId, Id adminProfileId ) {
        User testUser = new User();
        testUser.LastName = uname ;
        testUser.Alias = uname;
        testUser.Email = uname +'@testcc.com';
        testUser.Username = uname +'@testcc.com';
        testUser.CommunityNickname = 'cctest'+ uname;
        testUser.TimeZoneSidKey = 'America/New_York';
        testUser.LocaleSidKey = 'en_US';
        testUser.EmailEncodingKey = 'ISO-8859-1';
        testUser.ProfileId = adminProfileId;
        testUser.LanguageLocaleKey = 'en_US';
        testUser.IsActive = true;
        //This field must be unique
        //testUser.External_ID_Employee_Number__c = 'a99999';
        testUser.ManagerId = managerId;
       // testUser.License_Billing_Area__c = 'US Enterprise';
        
        INSERT testUser;
        return testUser;
    }


}