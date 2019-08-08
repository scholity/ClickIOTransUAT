/*****************************************************************************************************
Function : Same as UserUtils Class but Without Sharing
*****************************************************************************************************/

public Without sharing class UserUtilsHelper 
{
    /* Get a list of queues that the user is a member of - returns a list of Queue Ids */
    public static List<String> getQueuesUserIsAMemberOf(String userId) 
    {    
        Set<String> queueIdList = new Set<String>();
        List<String> resultList = new List<String>();
        List<String> groupIds = getPublicGroupsUserIsAMemberOf(userId);
        List<String> groupIdsBasedOnUserRole = getQueuesUserRoleIsAMemberOf(userId);
        
        groupIds.add(userId);
        groupIds.addAll(groupIdsBasedOnUserRole);// Add queue Ids based on user's role
        System.debug('$$$ GroupIds: ' + groupIds);
        
        for ( GroupMember item : [SELECT id, groupId 
                                    FROM GroupMember 
                                    WHERE group.type = 'Queue'
                                    AND userOrGroupId IN :groupIds] ) 
        {
            queueIdList.add(item.groupId);
        }
        System.debug('$$$ QueueIds list: ' + queueIdList);
        if (queueIdList != null && !queueIdList.isEmpty()) 
        {
          System.debug('Adding set to List of strings');
          //Adding set to a list so we can get rid of any dup ids
          resultList.addAll(queueIdList);
        }  
        return resultList;
    }
    
    /* Get a list of public groups that the user is a memeber of - returns a list of Group IDs */
    public static List<String> getPublicGroupsUserIsAMemberOf( String userId )
    {
        List<String> groupIdList = new List<String>();
        for ( GroupMember item : [SELECT id, groupId 
                                    FROM GroupMember 
                                   WHERE group.type = 'Regular'
                                    AND userOrGroupId = :userId] ) {
            groupIdList.add(item.groupId);
        }
        return groupIdList;
    }
    
  /*
  Author: Kiril Minev
   Get in which User's role is a member of
    */
    public static List<String> getQueuesUserRoleIsAMemberOf (String userId) 
    {
        List<String> groupIdList = new List<String>();
        try 
        {
            List<User> userRoleList = [SELECT UserRoleId, Id FROM User Where isActive = true and Id = :userId limit 1];
            System.debug('*** User Role List: ' + userRoleList);
            if (userRoleList != null && !userRoleList.isEmpty()) 
            {
                String roleId = userRoleList[0].UserRoleId;
              
                for (Group grp :[SELECT Type, Name, RelatedId, Id 
                      FROM Group 
                      WHERE Type in ('RoleAndSubordinates', 'Role') and RelatedId = :roleId]) 
                {
                    groupIdList.add(grp.Id);
                }
              System.debug('**** groupIdList from roles: ' + groupIdList);
            }
        }
        catch (System.Exception ex) 
        {
        System.debug('Exception in getQueuesUserRoleIsAMemberOf: ' + ex.getMessage());
        ExLog.log(ex);
        }
        return groupIdList;
    }
}