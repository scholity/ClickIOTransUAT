/*****************************************************************************************************
 
Class    :  GarbageAccountBatch
Developer:  Krishna Kollu, Joo Kang, Blue Wolf Group LLC
Created  :  Feb 12, 2014
Modified :  March 14, 2014
Objective:  This class is used to mark accounts for deletion and accounts as having only attachments or notes.
 
*****************************************************************************************************/ 
global class GarbageAccountBatch implements Database.Batchable<SObject>, Database.Stateful, Schedulable {
	ErrorHandling.ErrorLog errorLog;
	String createdDateField = 'CreatedDate';
	
	global GarbageAccountBatch() {
		errorLog = new ErrorHandling.ErrorLog();
		createdDateField = 'CreatedDate';
	} 
	
	/**
	 * Use this constructor to mock the createddate field.
	 * @param createdDateField the field to mock the createddate field
	 * Precondition: this field must be a date or datetime field on the account object.
	 */
	global GarbageAccountBatch(String createdDateField)
	{
		errorLog = new ErrorHandling.ErrorLog();
		this.createdDateField = createdDateField;
	}

	global database.Querylocator start(Database.BatchableContext bc)
	{
		
	  	return Database.getQueryLocator('Select ID, (Select ID From Attachments Limit 1), (Select ID From Notes Limit 1),'+ 
	  												'(Select ID From Tasks Limit 1), (Select ID From Events Limit 1),' +
													'(Select ID From Contacts Limit 1), (Select ID From Opportunities Limit 1),' + 
													'(Select ID From Cases Limit 1), (Select ID From Contracts Limit 1),'+
													'(Select ID From AccountContactRoles Limit 1) From Account ' +
													'WHERE ' + createdDateField + ' < LAST_N_DAYS:30 ' +
													'AND ID NOT IN (Select AccountID From Contact Where AccountID!=null) ' +
													'AND ID NOT IN (Select AccountID From Case Where AccountID!=null)');
	} 
	
	global void execute(Database.BatchableContext bc, List<Account> scope)
	{
		try {
	    	SafeDML accountsToUpdate = new SafeUpdate();
	    	accountsToUpdate.queue(GarbageAccountServices.markAccountFlags(scope), errorLog);
	    	accountsToUpdate.doDML(false); 
    	} catch(Exception e)
	  	{
	  		errorLog.trackNonDMLException(e);
	  	}
   	} 
	 
	global void finish(Database.BatchableContext bc)
	{ 
		 if (errorLog.areThereErrors()) {
            errorLog.emailLog(GarbageAccountServices.errorEmails, 'Errors While Identifying Accounts For Deletion: ');
        }
	}
	
	global void execute(SchedulableContext sc)
	{
		Database.executeBatch(new GarbageAccountBatch(),2000);
	}
}