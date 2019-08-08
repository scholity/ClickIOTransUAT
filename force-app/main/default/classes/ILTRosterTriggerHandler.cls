/************************************************************************************************************************************
** Author: Salesforce Services
** Description: The purpose of this class is to complete the trigger actions with the help of the ILTRosterActions class 
************************************************************************************************************************************/

public without sharing class ILTRosterTriggerHandler {
/*    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    public static boolean IsFromBachJob ;
    public static boolean isFromUploadAPI=false;
    
    public ILTRosterTriggerHandler(boolean isExecuting, integer size) {
        m_isExecuting = isExecuting;
        BatchSize = size;
    } */
    
    public ILTRosterTriggerHandler() {

    }            

    public void OnBeforeInsert(List<redwing__ILT_Roster__c> newILTRosters) {
        system.debug('ILTRoster Trigger On Before Insert');
        List<redwing__ILT_Roster__c> updateUserField = new List<redwing__ILT_Roster__c>();
        List<redwing__ILT_Roster__c> updateContactField = new List<redwing__ILT_Roster__c>();
        Set<Id> contactIds = new Set<Id>();
        Set<Id> userIds = new Set<Id>();
        for(redwing__ILT_Roster__c iltR: newILTRosters) {
            if(iltR.Contact__c==null && iltR.redwing__User__c!=null) {
                System.debug('--*ILTRoster Contact is empty - populate using user*--');
                System.debug('*New ILTRoster User:' + iltR.redwing__User__c);
                updateContactField.add(iltR);
                userIds.add(iltR.redwing__User__c);
            } else if(iltR.Contact__c!=null && iltR.redwing__User__c==null) {
                System.debug('--*ILTRoster User is empty - populate using contact*--');
                System.debug('*ILTRoster Contact:' + iltR.Contact__c);
                updateUserField.add(iltR);
                contactIds.add(iltR.Contact__c);
            } 
        }
        if(!updateUserField.isEmpty()) {
            ILTRosterActions.updateUserField(updateUserField, contactIds);
        }
        if(!updateContactField.isEmpty()) {
            ILTRosterActions.updateContactField(updateContactField, userIds);
        }
    }
/*    public void OnAfterInsert(List<redwing__ILT_Roster__c> newILTRosters) {
        system.debug('ILTRoster Trigger On After Insert');
    } 
    public void OnAfterUpdate( List<redwing__ILT_Roster__c> newILTRosters, List<redwing__ILT_Roster__c> oldILTRosters, Map<ID, redwing__ILT_Roster__c> newILTRosterMap , Map<ID, redwing__ILT_Roster__c> oldILTRosterMap ) {
        system.debug('ILTRoster Trigger On After Update');
    } */
    public void OnBeforeUpdate( List<redwing__ILT_Roster__c> newILTRosters, List<redwing__ILT_Roster__c> oldILTRosters, Map<ID, redwing__ILT_Roster__c> newILTRosterMap , Map<ID, redwing__ILT_Roster__c> oldILTRosterMap ) {
        system.debug('ILTRoster Trigger On Before Update');
        //Contact field was updated
        List<redwing__ILT_Roster__c> updateUserField = new List<redwing__ILT_Roster__c>();
        List<redwing__ILT_Roster__c> updateContactField = new List<redwing__ILT_Roster__c>();
        Set<Id> contactIds = new Set<Id>();
        Set<Id> userIds = new Set<Id>();
        for(redwing__ILT_Roster__c iltR: newILTRosters) {
            redwing__ILT_Roster__c oldILTRoster = oldILTRosterMap.get(iltR.id);
            if(iltR.Contact__c!=oldILTRoster.Contact__c) {
                System.debug('--*ILTRoster Contact is changed*--');
                System.debug('*Old ILTRoster Contact:' + oldILTRoster.Contact__c);
                System.debug('*New ILTRoster Contact:' + iltR.Contact__c);
                if(iltR.Contact__c!=null) {
                    updateUserField.add(iltR);
                    contactIds.add(iltR.Contact__c);
                } else {
                    iltR.redwing__User__c=null;
                } 
            } else if(iltR.redwing__User__c!=oldILTRoster.redwing__User__c) {
                System.debug('--*ILTRoster User is changed*--');
                System.debug('*Old ILTRoster User:' + oldILTRoster.redwing__User__c);
                System.debug('*New ILTRoster User:' + iltR.redwing__User__c);
                if(iltR.redwing__User__c!=null) {
                    updateContactField.add(iltR);
                    userIds.add(iltR.redwing__User__c);
                } else {             
                    iltR.Contact__c=null;
                }
            }
        }
        if(!updateUserField.isEmpty()) {
            ILTRosterActions.updateUserField(updateUserField, contactIds);
        }
        if(!updateContactField.isEmpty()) {
            ILTRosterActions.updateContactField(updateContactField, userIds);
        }
    }
/*
    @future 
    public static void OnAfterUpdateAsync(Set<ID> newILTRosterIDs) {

    }      
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