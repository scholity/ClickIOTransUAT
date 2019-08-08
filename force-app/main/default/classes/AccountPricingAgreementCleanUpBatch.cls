public without sharing class AccountPricingAgreementCleanUpBatch implements database.Batchable<SObject> {
	
	public Database.QueryLocator Start(Database.BatchableContext bc)
    {
        String queryString = 'SELECT Id FROM Account WHERE Is_Pricing_Agreement__c = \'Yes\'';
        
        return Database.getQueryLocator(queryString);
    }
    
    public void Execute(Database.BatchableContext bc, List<Account> scope )
    {
    	system.debug('This scope: '+scope);
    	
    	Set<Id> accountIds = new Set<Id>();
    	
    	for (Account act : scope)
    	{
    		accountIds.add(act.Id);
    	}
    	
    	List<Account> accounts = 	[SELECT Id,
    	
											(SELECT Id,
													Pricing_Agreement__c,
													StageName,
													Closed_Won_Date__c
											   FROM	Opportunities
											  WHERE Pricing_Agreement__c = 'Yes'
											    AND StageName 			 = 'Closed Won'
										   ORDER BY	Closed_Won_Date__c DESC NULLS LAST)
										   
									   FROM	Account
									  WHERE Id IN : accountIds
									    AND Is_Pricing_Agreement__c = 'Yes'];
    	
    	List<Account> accountsToUpdate = new List<Account>();
    	
    	DateTime dtVal = DateTime.now().addMonths(-36);
    	
    	system.debug('***dtVal***'+dtVal);
    	
    	for(Account acc : accounts)
    	{
    		if(acc.Opportunities.size() > 0)
    		{
    			system.debug('***acc.Opportunities[0].Closed_Won_Date__c***'+acc.Opportunities[0].Closed_Won_Date__c);
    			
    			if(acc.Opportunities[0].Closed_Won_Date__c < dtVal)
    			{
    				acc.Is_Pricing_Agreement__c = 'No';
    				accountsToUpdate.add(acc);
    			}    			
    		}
    		
    	}
    	
    	
    	if(accountsToUpdate.size() > 0)
    	{
    		update accountsToUpdate;
    	}
    	
    }
    
    public void Finish(Database.BatchableContext bc)
    {
        
    }
}