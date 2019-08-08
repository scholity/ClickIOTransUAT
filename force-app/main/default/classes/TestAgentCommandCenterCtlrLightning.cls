@isTest
private class TestAgentCommandCenterCtlrLightning 
{ 
    @testSetup static void methodName() 
    {
        Switch__c cohstest = new Switch__c();
        cohstest.Switch__c = false;
        cohstest.name = 'CaseOwnerHistorySwitch';
        insert cohstest;
        
        Validation_Rules__c vr = new Validation_Rules__c();
        vr.Bypass_Rules__c = false;
        insert vr;
    }     
        
    static testMethod void testAcceptNextCase() 
    {
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];
        Id adminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
        
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
            AgentCommandCenterCtlrLightning.AcceptNextCaseResult result = new AgentCommandCenterCtlrLightning.AcceptNextCaseResult();
            result = AgentCommandCenterCtlrLightning.acceptNextCase(); 
        }
    }
    
    static testMethod void testAcceptNextCaseNegative() 
    {
        // test accept next case with no cases in the queue
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];
        Id adminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
        
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
            AgentCommandCenterCtlrLightning.AcceptNextCaseResult result = new AgentCommandCenterCtlrLightning.AcceptNextCaseResult();
            result = AgentCommandCenterCtlrLightning.acceptNextCase(); 
        }
    }
    
    /*
    * If case Folow_Up_Date_Time__c is in future case should not bet re-assigned
    */
    
    
    private static List<Case> createCases (Integer numberToCreate, String caseOwnerId, Integer followUpDateFutureDays) 
    {
        List<Case> cases = new List<Case>();
        for (Integer i = 0; i<numberToCreate; i++) 
        {
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

    private static List<Case> createCases (Integer numberToCreate, String caseOwnerId)
    {
        return createCases(numberToCreate, caseOwnerId, -1);
    }
    
    private static User createUser ( String uname, Id managerId, Id adminProfileId ) 
    {
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
        testUser.ManagerId = managerId;
        INSERT testUser;
        return testUser;
    }
}