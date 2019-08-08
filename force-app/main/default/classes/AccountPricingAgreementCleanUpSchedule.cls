global class AccountPricingAgreementCleanUpSchedule  implements schedulable
{	
	global void execute(SchedulableContext sc)
    {
	    AccountPricingAgreementCleanUpBatch b = new AccountPricingAgreementCleanUpBatch();
		Database.executeBatch(b,100);
    }	
    
}