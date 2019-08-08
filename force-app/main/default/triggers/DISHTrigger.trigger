trigger DISHTrigger on Dedicated_Internal_Salesforce_Helpdesk__c (after insert, after update)
{
    if(trigger.IsInsert || trigger.IsUpdate)
    {
        List <Dedicated_Internal_Salesforce_Helpdesk__Share> shareList = new List <Dedicated_Internal_Salesforce_Helpdesk__Share>();
        
        for (Dedicated_Internal_Salesforce_Helpdesk__c dish : trigger.new)
        {   
            if (dish.Requested_By__c != null && dish.Requested_By__c != UserInfo.getUserId())
            {
                Dedicated_Internal_Salesforce_Helpdesk__Share dishShare = new Dedicated_Internal_Salesforce_Helpdesk__Share();
                
                dishShare.ParentId      = dish.Id;
                dishShare.UserOrGroupId = dish.Requested_By__c;
                dishShare.AccessLevel   = 'Edit';
                
                shareList.add(dishShare);
            }           
        }
        
        if(shareList.size() > 0)
        {
            upsert shareList;           
        }               
    }    
}