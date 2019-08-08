/************************************************************************************************************************************
** Author: Salesforce Services
** Description: The purpose of this class is to complete the trigger actions with the help of the UserActions class 
************************************************************************************************************************************/

public without sharing class UserTriggerHandler {
    /* private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    public static boolean IsFromBachJob ;
    public static boolean isFromUploadAPI=false;    
    public UserTriggerHandler(boolean isExecuting, integer size) {
        m_isExecuting = isExecuting;
        BatchSize = size;
    } */
    
    public UserTriggerHandler() {} 
    
    public void OnAfterInsert(List<User> newUsers) {
        system.debug('UserTrigger On After Insert');
        // Query the list of profiles that will qualify new permission set assignment
        List<PHSS_Agent_Ordering_Permission_Setting__c> userRoleCustomSettingList = PHSS_Agent_Ordering_Permission_Setting__c.getall().values();
        PermissionSet psToAssign = getPermissionSet();
        // Check that settings isn't empty, if empty, don't do anything
        if(!userRoleCustomSettingList.isEmpty() && psToAssign!=null) {           
            Map<Id,UserRole> userRoleMap = getUserRoleMap(newUsers);
            List<PermissionSetAssignment> psaListToInsert = getPermissionSetAssignments(newUsers, userRoleCustomSettingList, psToAssign, userRoleMap);              
            if(!psaListToInsert.isEmpty()) {
                insert psaListToInsert;
            }
        }
    }
    public void OnAfterUpdate( List<User> newUsers, List<User> oldUsers, Map<ID,User> newUserMap , Map<ID,User> oldUserMap) {
        system.debug('UserTrigger On After Update');
        List<User> potentialToAssignPS = new List<User>();
        for(User u: newUsers) {
            if(u.UserRoleId!=oldUserMap.get(u.Id).UserRoleId) {
                potentialToAssignPS.add(u); 
            }
        }
        if(!potentialToAssignPS.isEmpty()) {
            // Query the list of profiles that will qualify new permission set assignment
            List<PHSS_Agent_Ordering_Permission_Setting__c> userRoleCustomSettingList = PHSS_Agent_Ordering_Permission_Setting__c.getall().values();           
            PermissionSet ps = getPermissionSet();
            // Check that settings isn't empty, if empty, don't do anything
            if(!userRoleCustomSettingList.isEmpty() && ps!=null) {
                Map<Id,UserRole> userRoleMap = getUserRoleMap(potentialToAssignPS);
                List<PermissionSetAssignment> psaListToInsert = new List<PermissionSetAssignment>(); 
                Set<Id> userSet = new Set<Id>();
                Set<Id> userIdsToRemove = new Set<Id>();                
                Map<String,String> userRoleCustomSettingMap = new Map<String,String>();
                for(PHSS_Agent_Ordering_Permission_Setting__c urps: userRoleCustomSettingList) {
                    userRoleCustomSettingMap.put(urps.Role_Name__c,urps.Role_Name__c);
                }
                // Get List to Insert and Remove
                for(User u: potentialToAssignPS) {
                    if(u.UserRoleId!=null && userRoleCustomSettingMap.containsKey(userRoleMap.get(u.UserRoleId).Name)) {
                        psaListToInsert.add(new PermissionSetAssignment(PermissionSetId=ps.Id,AssigneeId=u.Id));
                        userSet.add(u.Id);
                    } else { //Get User Ids to Remove
                        userIdsToRemove.add(u.Id);
                    }
                }
                // Verify that permission set doesn't exist yet, if not then insert
                if(!psaListToInsert.isEmpty()) {
                    List<PermissionSetAssignment> userPSAList = new List<PermissionSetAssignment>([SELECT Id, PermissionSetId, AssigneeId FROM PermissionSetAssignment WHERE AssigneeId IN:userSet AND PermissionSetId=:ps.Id]);
                    for(PermissionSetAssignment upsa : userPSAList) {
                        if(upsa.PermissionSetId==ps.Id) {
                            for(Integer i=0; i<psaListToInsert.size(); i++) {
                                if(upsa.PermissionSetId==psaListToInsert[i].PermissionSetId && upsa.AssigneeId==psaListToInsert[i].AssigneeId) {
                                    psaListToInsert.remove(i);
                                    break;
                                }
                            }
                        }
                    }
                    insert psaListToInsert;
                }
                // Verify that permission set exists, if so, delete
                if(!userIdsToRemove.isEmpty()) {
                    List<PermissionSetAssignment> userPSAList = new List<PermissionSetAssignment>([SELECT Id, PermissionSetId, AssigneeId FROM PermissionSetAssignment WHERE AssigneeId IN:userIdsToRemove AND PermissionSetId=:ps.Id]);
                    if(!userPSAList.isEmpty()) {
                        delete userPSAList;
                    }
                }
            }
        }
    }
    
    public PermissionSet getPermissionSet() {
        List<PermissionSet> psList = new List<PermissionSet>([SELECT Id, Name FROM PermissionSet WHERE Name='PHSS_Agent_Ordering_Permissions']);
        if(!psList.isEmpty()) {
            return psList[0];
        } else {
            return null;
        }
    }
    
    public Map<Id,UserRole> getUserRoleMap(List<User> uList) {
        // Get set of user role ids
        Set<Id> userRoleIds = new Set<Id>();
        for(User u: uList) {
            if(u.UserRoleId!=null) {
                userRoleIds.add(u.UserRoleId);
            }
        }  
        if(!userRoleIds.isEmpty()) {
            // Query role information
            return new Map<Id,UserRole>([SELECT Id,Name FROM UserRole WHERE Id IN:userRoleIds]); 
        } else {
            return new Map<Id,UserRole>();
        }      
    }
    
	public List<PermissionSetAssignment> getPermissionSetAssignments(List<User> uList, List<PHSS_Agent_Ordering_Permission_Setting__c> userRoleCustomSettingList, PermissionSet psToAssign, Map<Id,UserRole> userRoleMap) {
        List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>(); 
        Map<String,String> userRoleCustomSettingMap = new Map<String,String>();
        for(PHSS_Agent_Ordering_Permission_Setting__c urps: userRoleCustomSettingList) {
        	userRoleCustomSettingMap.put(urps.Role_Name__c,urps.Role_Name__c);
        }
        // Check if User has right role to get permission set assigned
        for(User u: uList) {
            if(u.UserRoleId!=null && userRoleCustomSettingMap.containsKey(userRoleMap.get(u.UserRoleId).Name)) {
            	psaList.add(new PermissionSetAssignment(PermissionSetId=psToAssign.Id,AssigneeId=u.Id));
            }
        }
        return psaList;
    }
    
    /* public void OnBeforeInsert(List<User> newUsers) {
        system.debug('User Trigger On Before Insert');
    } */
    /* public void OnBeforeUpdate( List<User> newUsers, List<User> oldUsers, Map<ID, User> newUserMap , Map<ID, User> oldUserMap ) {
        system.debug('User Trigger On Before Update');   
    } */
    /* @future 
    public static void OnAfterUpdateAsync(Set<ID> newUserCertificationIDs) { }      
    public boolean IsTriggerContext {
        get{ return m_isExecuting;}
    }   
    public boolean IsVisualforcePageContext {
        get{ return !IsTriggerContext;}
    } 
    public boolean IsWebServiceContext {
        get{ return !IsTriggerContext;}
    }   
    public boolean IsExecuteAnonymousContext {
        get{ return !IsTriggerContext;}
    } */
}