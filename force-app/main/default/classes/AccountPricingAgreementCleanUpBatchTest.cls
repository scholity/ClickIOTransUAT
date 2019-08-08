@isTest 
private class AccountPricingAgreementCleanUpBatchTest {
	
	public static final Integer accountCount            = 1;
    public static final Integer oppsOnEachAccount       = 2;

    @testsetup 
    public static void initializeClassTestData()
    {
        OpportunityTriggerHandlerTest.CreateTestAccountsAndOpportunities(accountCount, oppsOnEachAccount);
    }
    
    static testMethod void TestBasicOperation() 
    {
        List<Opportunity> oppList = new List<Opportunity> ();
        
        for (Opportunity opp : [SELECT Id FROM Opportunity])
        {
        	opp.StageName				= 'Closed Won';
        	opp.Pricing_Agreement__c 	= 'Yes';        	
        	
        	oppList.add(opp);
        }
        
        update oppList;       
        
        List<Opportunity> opps 			= [SELECT Id FROM Opportunity WHERE Id IN : oppList];
        
        List<Opportunity> oppToUpdate 	= new List<Opportunity>();
        
        for(Opportunity o : opps)
        {
        	o.Closed_Won_Date__c 		= Datetime.now().addMonths(-40);
        	
        	oppToUpdate.add(o);
        }
        
        update oppToUpdate;
        
        Test.StartTest();
        
        	AccountPricingAgreementCleanUpBatch batch = new AccountPricingAgreementCleanUpBatch(); 
			Database.executeBatch(batch);
			
        Test.StopTest();
        
        List<Account> act = [SELECT Id, Is_Pricing_Agreement__c FROM Account];
        
        for(Account a : act)
        {
        	system.assertEquals(a.Is_Pricing_Agreement__c, 'No');        	
        }
        
    }
    
    static testMethod void testOpportunityClosedWonWithIn()
    {
    	List<Opportunity> oppList = new List<Opportunity> ();
        
        for (Opportunity opp : [SELECT Id FROM Opportunity])
        {
        	
        	opp.StageName				= 'Closed Won';
        	opp.Pricing_Agreement__c 	= 'Yes';        	
        	
        	oppList.add(opp);
        	
        }
        
        update oppList;
        
        List<Account> testAccounts 	= new List<Account>();
        
        List<Account> actUpdate 	= [SELECT Id, Is_Pricing_Agreement__c FROM Account];
        
        Test.StartTest();
        
        	AccountPricingAgreementCleanUpBatch batch = new AccountPricingAgreementCleanUpBatch(); 
			Database.executeBatch(batch);
			
        Test.StopTest();
        
        List<Account> act = [SELECT Id, Is_Pricing_Agreement__c FROM Account];
        
        for(Account a : act)
        {
        	system.assertEquals(a.Is_Pricing_Agreement__c, 'Yes');
        }
    	    	
    }
    
    @isTest 
    public static void testSchedule()
	{
		String CRON_EXP = '0 0 0 15 3 ? 2022';
		Test.startTest();
		System.schedule('ScheduleApexClassTest', CRON_EXP, new AccountPricingAgreementCleanUpSchedule());
		Test.stopTest();
	}
    
    
}