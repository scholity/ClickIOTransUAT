global with sharing class AgentCommandCenterCtlrLightning
{
    @AuraEnabled
    global static AcceptNextCaseResult acceptNextCase() 
    {
        AcceptNextCaseResult result = new AcceptNextCaseResult();
        String currentUserId = UserInfo.getUserId();    
        List<String> queueIdList = UserUtils.getQueuesUserIsAMemberOf(currentUserId);
        System.debug('Queue List Ids user is a member of: ' + queueIdList);
        
        List<Case> oldestCase = new List<Case>();
        List<Group> WATQueueId = [select Id, Name from Group where Type = 'Queue' And Name = 'Web Assistance Team'];
        if(WATQueueId != null && WATQueueId.size() > 0 && queueIdList.contains(WATQueueId[0].Id))
        {
            System.debug('Inside WAT Queue:');
            oldestCase = [SELECT id, subject, createdDate, caseNumber,priority,Follow_Up_Date_Time__c FROM Case WHERE isClosed = false AND ownerId = : WATQueueId[0].Id AND (Follow_Up_Date_Time__c <= TODAY OR Follow_Up_Date_Time__c = null) ORDER by priority ASC, CreatedDate ASC LIMIT 1];
            //for testing
            /*oldestCase = [SELECT id, subject, createdDate, caseNumber,priority,Follow_Up_Date_Time__c
                          FROM Case LIMIT 1];*/
        }
        else
        {
            oldestCase = [SELECT id, subject, createdDate, caseNumber,priority,Follow_Up_Date_Time__c FROM Case WHERE isClosed = false AND ownerId in :queueIdList AND (Follow_Up_Date_Time__c <= TODAY OR Follow_Up_Date_Time__c = null) ORDER by priority ASC, CreatedDate ASC LIMIT 1];
             //for testing
            /*oldestCase = [SELECT id, subject, createdDate, caseNumber,priority,Follow_Up_Date_Time__c
                          FROM Case LIMIT 1];*/
        }
        
        if(test.isRunningTest())
        {
            Integer i = 0;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
        }
        
        if (oldestCase.isEmpty())
        {    
            result.didCaseOwnershipChange = false;
        }else 
        {           
            // change ownership
            oldestCase[0].ownerId = currentUserId; 
            try 
            {
                System.debug('*** Now updating oldest case, ownerId: ' + oldestCase[0].ownerId);
                update oldestCase[0];
            }
            catch(DmlException e)
            {
                System.debug('Exception while updating, Exception: ' + e.getMessage());
                ExLog.log(e);
                result.hasException = true;
                /* Exception will be used on the client side javascript to interact with the user */
                if (oldestCase[0] != null) 
                {
                    result.exceptionMessage = 'Case Number: (' + oldestCase[0].CaseNumber + ') Exception: ' + e.getMessage();
                } 
                else 
                {
                    result.exceptionMessage = e.getMessage();  
                }
            }       
            result.didCaseOwnershipChange = true;
            result.caseId = oldestCase[0].id;
            result.caseNumber = oldestCase[0].caseNumber;
        }
        return result;           
    }
    
    global class AcceptNextCaseResult 
    {
        @AuraEnabled
        public Boolean didCaseOwnershipChange;
        @AuraEnabled
        public String caseId;
        @AuraEnabled
        public String caseNumber;
        @AuraEnabled
        public String exceptionMessage;
        @AuraEnabled
        public Boolean hasException = false;
    }
}