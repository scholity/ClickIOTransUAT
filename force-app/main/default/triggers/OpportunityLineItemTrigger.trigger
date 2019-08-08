/**
	* Apex Trigger : OpportunityLineItemTrigger
	*	Description : Update Price Approver Level for Opportunity.
	* Created By : Sudhir Kr. Jagetiya
	* Created Date : April 16,2012
	*/
trigger OpportunityLineItemTrigger on OpportunityLineItem (after delete, after insert, 
after update) {
	OpportunityLineItemManagement.afterInsertUpdateDelete(Trigger.newMap, Trigger.oldMap);
}