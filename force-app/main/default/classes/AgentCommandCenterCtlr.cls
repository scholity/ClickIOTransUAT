/*****************************************************************************************************
Class    :  AgentCommandCenterCtrl
Author   :
Created  :  April 23, 2013
Last Modified By: Kiril Minev
Reason for Revision: Added follow up date
Last Modified: 11/22/2013

Objective: Class serves the purpose of visual force page controller for the TSC command center popup buttons
         
         Accept Next Case functionality works as follows:    

           1)  User/Agent clicks on the "Next Case Accept" button from the command center
           2)  Code Logic fires off and does the following:
                a) Queries for all cases that are assigned to a queue and checks if the user/agent who clicked on the button is 
                   a member of the queue that the case is assigned too. Also if the Follow_Up_Date_Time__c field is in the future 
                   logic ignore those case records, if Follow_Up_Date_Time__c is present (today) or in the past the case record is qualified to be
                   pulled and re-assigned to the owner

                b) If case(s) are found, the case with the oldest age / greatest Since Last Modified Hours field is returned and the case owner is changed from queue to the user who clicked the button
                 Then a new tab is opened on the console with the case that was just edited
                c) If case(s) are not found. Meaning there are no opened cases that are assigned to a queue to which the user is a member of. 
                A  popup message is displayed informing the user no cases have been found.

Develper Comments:

@Log:   deprecated areCasesAvailable method. added DMLException catch

*****************************************************************************************************/

global with sharing class AgentCommandCenterCtlr 
{
    @RemoteAction
    global static AcceptNextCaseResult acceptNextCase() 
    {
        AcceptNextCaseResult result = new AcceptNextCaseResult();
        String currentUserId = UserInfo.getUserId();    
        List<String> queueIdList = UserUtils.getQueuesUserIsAMemberOf(currentUserId);
        System.debug('Queue List Ids user is a member of: ' + queueIdList);
        
        /* Commented out per Lee and Larry's request we are changing from Hrs Since Last Modified to CreateDate/Open Date
        List<Case> oldestCase = [SELECT id, subject, createdDate, caseNumber,priority,Follow_Up_Date_Time__c
                            FROM Case
                            WHERE isClosed = false AND ownerId in :queueIdList AND
                            (Follow_Up_Date_Time__c <= TODAY OR Follow_Up_Date_Time__c = null)
                            ORDER by priority ASC, Hours_Since_Last_Modified__c DESC
                            LIMIT 1];
                            */
        List<Case> oldestCase = new List<Case>();
        List<Group> WATQueueId = [select Id, Name from Group where Type = 'Queue' And Name = 'Web Assistance Team'];
        if(WATQueueId != null && WATQueueId.size() > 0 && queueIdList.contains(WATQueueId[0].Id))
        {
            System.debug('Inside WAT Queue:');
            oldestCase = [SELECT id, subject, createdDate, caseNumber,priority,Follow_Up_Date_Time__c
                            FROM Case
                            WHERE isClosed = false AND ownerId = : WATQueueId[0].Id AND
                            (Follow_Up_Date_Time__c <= TODAY OR Follow_Up_Date_Time__c = null)
                            ORDER by priority ASC, CreatedDate ASC
                            LIMIT 1];
        }
        else
        {
            oldestCase = [SELECT id, subject, createdDate, caseNumber,priority,Follow_Up_Date_Time__c
                            FROM Case
                            WHERE isClosed = false AND ownerId in :queueIdList AND
                            (Follow_Up_Date_Time__c <= TODAY OR Follow_Up_Date_Time__c = null)
                            ORDER by priority ASC, CreatedDate ASC
                            LIMIT 1];
        }
    
        if (oldestCase.isEmpty())
        {    
            result.didCaseOwnershipChange = false;
        } 
        else 
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
    
    /* DEPRECATED
    global static Boolean areCasesAvailable( List<String> queueList ) {
      Boolean isFound = false;
      Integer numberOfCasesAvailable = [SELECT Count()
                            FROM Case
                            WHERE isClosed = false AND 
                                ownerId in :queueList];  
      if (numberOfCasesAvailable > 0) {
        isFound = true;
      } 
      return isFound;
    }
    */
    
    global class AcceptNextCaseResult 
    {
        public Boolean didCaseOwnershipChange;
        public String caseId;
        public String caseNumber;
        public String exceptionMessage;
        public Boolean hasException = false;
    }
}