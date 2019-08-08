/*
* This class is being called from Opportunity Trigger
*
* The purpose of this class is to update Is_Pricing_Agreement__c = 'Yes' field on Account
* if any of related  opportunity is closed won and Pricing_Agreement__c = 'Yes'
* and Closed_Won_Date__c is within 3 years
*
*/

public without sharing class OpportunityTriggerHandler {
	
	public static void opportunityAccountUpdate(List<Opportunity> oppList)
	{
		// Set of Account Ids related to Opportunity
		Set<Id> accIds = new Set<Id>();
		
		//Iterate over List of Opportunity coming form Trigger.New
		for(Opportunity opp : oppList)
		{
			accIds.add(opp.AccountId);
		}
		
		DateTime val = DateTime.now().addMonths(-36);
		
		
		//Use Account set to find the list of opportunities on each Account		
		List<Account> accounts = [SELECT Id,
										 
										(SELECT Id,
												Pricing_Agreement__c,
												StageName
										   FROM	Opportunities
										  WHERE Closed_Won_Date__c >= :val
										    AND StageName = 'Closed Won'
										    AND Pricing_Agreement__c = 'Yes'
										  LIMIT 1)					   
									    
								    FROM Account
								   WHERE Id IN: accIds];
		
		//Create a list of Accounts to update
		List<Account> accountsToUpdate = new List<Account>();
		
		//Iterate over Accounts and update Is_Pricing_Agreement__c on Account based upon Opportunity Pricing_Agreement__c 
		for(Account acc : accounts)
		{	
			if(acc.Opportunities.size() > 0)
			{
				acc.Is_Pricing_Agreement__c = 'Yes';
				accountsToUpdate.add(acc);
			}
			else
			{
				acc.Is_Pricing_Agreement__c = 'No';
				accountsToUpdate.add(acc);
			}
		}
		
		//If accountsToUpdate list is not empty update the Accounts
		if(accountsToUpdate.size() > 0)
		{
			update accountsToUpdate;
		}		
	}
}