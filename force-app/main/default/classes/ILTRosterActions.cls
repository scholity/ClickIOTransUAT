/************************************************************************************************************************************************************
** Author: Salesforce Services
** Description: This is a helper class. The purpose of this class is to hold the action details needed in the ILTRosterTriggerHandler class 
************************************************************************************************************************************************************/

public without sharing class ILTRosterActions {
    // Update User field on ILTRosters using Contact field
    public static void updateUserField(List<redwing__ILT_Roster__c> iltRosterList, Set<Id> contactIds) { 
        Map<Id, redwing__ILT_Roster__c> iltRosterMap = new Map<Id,redwing__ILT_Roster__c>();
        for(redwing__ILT_Roster__c iltR: iltRosterList) {
            iltRosterMap.put(iltR.Contact__c,iltR);
        }
        // Query User records with ContactID populated with one of the provided list of Ids
        List<User> users = new List<User>([SELECT Id, ContactID FROM User WHERE ContactID IN:contactIds]);
        for(User u: users) {
            redwing__ILT_Roster__c iltRoster = iltRosterMap.get(u.ContactID);
            if(u.ContactID==iltRoster.Contact__c) {
                iltRoster.redwing__User__c = u.Id;               
            }
        }
    }
    // Update Contact field on ILTRosters using User field
    public static void updateContactField(List<redwing__ILT_Roster__c> iltRosterList, Set<Id> userIds) { 
        Map<Id, redwing__ILT_Roster__c> iltRosterMap = new Map<Id,redwing__ILT_Roster__c>();
        for(redwing__ILT_Roster__c iltR: iltRosterList) {
            iltRosterMap.put(iltR.redwing__User__c,iltR);
        }
        // Query User records with ContactID populated with one of the provided list of Ids
        List<User> users = new List<User>([SELECT Id, ContactID FROM User WHERE Id IN:userIds]);
        for(User u: users) {
            redwing__ILT_Roster__c iltRoster = iltRosterMap.get(u.Id);
            if(u.Id==iltRoster.redwing__User__c) {
                iltRoster.Contact__c = u.ContactID;               
            }
        }
    }  
}