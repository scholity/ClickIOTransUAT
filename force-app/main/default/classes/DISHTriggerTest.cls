@isTest 
private class DISHTriggerTest
{
	static testmethod void testDishTrigger()
	{
		Dedicated_Internal_Salesforce_Helpdesk__c testDish = new Dedicated_Internal_Salesforce_Helpdesk__c();
		
		User runningUser 	= getTestuser1();
		
		User requestedById 	= [SELECT Id FROM User WHERE Profile.Name = 'ARC BGST Sales User' AND IsActive = true LIMIT 1];
		
		User userToDatvId 	= [SELECT Id FROM User WHERE Profile.Name = 'ARC BGST Sales User' AND IsActive = true AND Id != :requestedById.Id LIMIT 1];
		
		system.runAs (runningUser)
		{
			testDish.Requested_By__c 		= requestedById.Id;
			testDish.User_to_Deactivate__c 	= userToDatvId.Id;
			
			Test.StartTest();
			insert testDish;
			Test.StopTest();
			
			List<Dedicated_Internal_Salesforce_Helpdesk__Share> dishShare = [SELECT ParentId FROM Dedicated_Internal_Salesforce_Helpdesk__Share LIMIT 1];
			
			system.assertEquals(dishShare[0].ParentId, testDish.Id);
						
		}
	}
	
	public static User getTestuser1()
    {
        Profile pId = [SELECT Id FROM Profile WHERE Name = 'ARC BGST Sales Admin' LIMIT 1];
        
        User u1 = new User(Alias 			= 'jja', 
                          Email				= 'test@redcross.org', 
                          FirstName			= 'Test',
						  LastName			= 'User', 
                          TimeZoneSidKey 	= 'America/Los_Angeles', 
                          UserName 			= 'dishuser@redcross.org',
                          ProfileID 		= pId.Id,
                          LocaleSidKey		= 'en_US', 
                          EmailEncodingKey	= 'UTF-8', 
                          LanguageLocaleKey = 'en_US');
        return u1;
    }
}