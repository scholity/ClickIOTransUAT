/************************************************************************************************************************************
** Author: Salesforce Services
** Description: The purpose of this class is to complete the trigger actions with the help of the ContactActions class 
************************************************************************************************************************************/

public without sharing class ContactTriggerHandler {
/*    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    public static boolean IsFromBachJob ;
    public static boolean isFromUploadAPI=false;
    
    public ContactTriggerHandler(boolean isExecuting, integer size) {
        m_isExecuting = isExecuting;
        BatchSize = size;
    } */
    
    public ContactTriggerHandler() {

    }            

/*    public void OnBeforeInsert(List<Contact> newContacts) {
        system.debug('Contact Trigger On Before Insert');
    }
    public void OnAfterInsert(List<Contact> newContacts) {
        system.debug('Contact Trigger On After Insert');
    } */
    public void OnAfterUpdate( List<Contact> newContacts, List<Contact> oldContacts, Map<ID, Contact> newContactMap , Map<ID, Contact> oldContactMap ) {
        system.debug('Contact Trigger On After Update');
        //Map<Id,Contact> tempMap = new Map<Id,Contact>();
        //Set<Id> tempSet = new Set<Id>();
        List<Contact> tempList = new List<Contact>();
        for(Contact c: newContacts) {
            Contact oldContact = oldContactMap.get(c.id);
            if(c.FirstName!=oldContact.FirstName || c.LastName!=oldContact.LastName) {
                System.debug('--*Contact First or Last Name is changed*--');
                System.debug('*Old Contact First and Last Name:' + oldContact.FirstName + ' ' + oldContact.LastName);
                System.debug('*New Contact First and Last Name:' + c.FirstName + ' ' + c.LastName);
                //tempMap.put(c.Id, c);
                //tempSet.add(c.Id);
                tempList.add(c);
            }
        }
        if(!tempList.isEmpty()) {
            ContactActions.updateUser(tempList);
        }
    }
/*    public void OnBeforeUpdate( List<Contact> newContacts, List<Contact> oldContacts, Map<ID, Contact> newContactMap , Map<ID, Contact> oldContactMap ) {
        system.debug('Account Trigger On Before Update');
    }

    @future 
    public static void OnAfterUpdateAsync(Set<ID> newContactIDs) {

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