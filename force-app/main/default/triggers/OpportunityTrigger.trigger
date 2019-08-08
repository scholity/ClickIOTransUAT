/**
	* Apex Trigger : OpportunityTrigger
	*	Description : Update Approver for the Opportunity.
	* Created By : Sudhir Kr. Jagetiya
	* Created Date : April 16,2012
	*/
trigger OpportunityTrigger on Opportunity (before update,before insert, after update, after insert) {
	
	if(trigger.IsBefore && (trigger.Isinsert || trigger.IsUpdate))
	{
		OpportunityManagement.beforeInsertUpdate(Trigger.new, Trigger.oldMap);
	}
	
	
	if(trigger.IsAfter && (trigger.Isinsert || trigger.IsUpdate))
	{
		OpportunityTriggerHandler.opportunityAccountUpdate(Trigger.New);
	}
	
	
}