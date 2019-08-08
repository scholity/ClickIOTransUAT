/************************************************************************************************************************************************************
** Author: Salesforce Services
** Description: This is a helper class. The purpose of this class is to hold the action details needed in the ContactTriggerHandler class 
************************************************************************************************************************************************************/

public without sharing class ContactActions {
    // Update User First and Last name for Contacts in list based on ContactId field.
    // Contacts in list are those with updated First and/or Last name
    public static void updateUser(List<Contact> updatedContactList) { 
        Map<Id,Contact> updatedContactMap = new Map<Id,Contact>();
        Set<Id> updatedContactIds = new Set<Id>();
        for(Contact c: updatedContactList) {
            updatedContactMap.put(c.Id, c);
            updatedContactIds.add(c.Id);
        }      
        // Users to update
        List<User> usersToUpdate = new List<User>();       
        // Query User records with ContactID populated with one of the provided list of Ids
        List<User> users = new List<User>([SELECT Id, ContactID, FirstName, LastName FROM User WHERE ContactID IN:updatedContactIds]);
        for(User u: users) {
            Contact c = updatedContactMap.get(u.ContactID);
            If(c!=null) {
                u.FirstName = c.FirstName;
                u.LastName = c.LastName;
                usersToUpdate.add(u);
            }
        }
        if(!usersToUpdate.isEmpty()) {
            update usersToUpdate;
        }
    }
}