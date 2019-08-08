/*****************************************************************************************************
 
Class    :  GarbageAccountServices
Developer:  Krishna Kollu, Joo Kang, Blue Wolf Group LLC
Created  :  Feb 12, 2014
Modified :  March 14, 2014
Objective:  This class is used to mark accounts for deletion and accounts as having only attachments or notes.
 
*****************************************************************************************************/ 
public with sharing class GarbageAccountServices {
	
	/**
	 *  Specifies where to send error emails if there is a failure. Draw
	 *  values from the custom setting Error Emails
	 */
	public static List<String> errorEmails {
		get {
			List<String> retMap = new List<String>();
			for(Error_Emails__c e : Error_Emails__c.getAll().values())
			{
				retMap.add(e.Email__c);
			}
			return retMap;
		}
		private set;
	}
	
	/** For the given accounts, if the account should be considered for deletion, check the
	 *  Flagged for Deletion checkbox. Moreover, if the account should be considered for deletion
	 *  and moreover the account has attachments or notes, then also check the 'Has Only Attachments Or Notes' checkbox.
	 *
	 *  Criteria for being considered for deletion:
	 *  	1) There are no tasks, events, contacts, contact roles, opportunities, cases or contracts
	 *		   directly associated to the account.
	 *
	 *	@param scope The accounts to examine and modify if they meet the given criteria. The accounts are assumed to
	 				 not have any cases or contacts.
	 *  @precondition The scope must include accounts with the relevant task, event, contact, contact role,
	 *				  and opportunity objects included.
	 *			  
	 *  @return only accounts to be considered for deletion
	 *
	**/
	public static List<Account> markAccountFlags(List<Account> scope)
	{
		List<Account> accountsFlagged = new List<account>();
		for (Account act : scope) {
			if (act.Tasks.isEmpty() && act.Events.isEmpty() &&
			    act.AccountContactRoles.isEmpty() && act.Opportunities.isEmpty() 
			    && act.Contracts.isEmpty()) { 
				act.Flagged_For_Deletion__c = true;
				if (!act.Attachments.isEmpty() || !act.Notes.isEmpty())
					act.Has_Only_Attachments_Or_Notes__c = true;
				accountsFlagged.add(act);
			}
		}
		
		return accountsFlagged;
	}
	
	
}