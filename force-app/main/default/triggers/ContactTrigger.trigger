/*****************************************************************************************************
 
Trigger  :  ContactTrigger
Developer:  Krishna Kollu, Joo Kang, Blue Wolf Group LLC
Created  :  May 6, 2014
Modified :  June 3, 2014 (latest code change)
Objective:  This trigger does the following:
            1) Assigns incoming contacts to bucket accounts if they have no assigned account.
            2) Keeps track of how many contacts are under a bucket account
            3) Prevents users from manually assigning contacts to bucket accounts. In order for
               a user to designate that a contact is a B2C contact that requires a bucket account,
               the user must set the AccountID of the contact to null
 
*****************************************************************************************************/ 
trigger ContactTrigger on Contact (before insert, before delete, after undelete, before update, after update) {
    if (!PHSS_TriggerSettings__c.getOrgDefaults().ContactTrigger_Disabled__c) {
        if (!PHSS_TriggerSettings__c.getOrgDefaults().ContactTrigger_Bucket_Assign_Disabled__c) {
            if (Trigger.isBefore && Trigger.isInsert) {
                BucketAssignmentModel.handleNewContacts(Trigger.new);
            }
            if (Trigger.isBefore && Trigger.isDelete) {
                BucketAssignmentModel.handleDeletedContacts(Trigger.oldMap);
            }
            if (Trigger.isAfter && Trigger.isUndelete) {
                BucketAssignmentModel.handleUndeletedContacts(Trigger.new);
            }
            if (Trigger.isBefore && Trigger.isUpdate) {
                BucketAssignmentModel.handleUpdatedContacts(Trigger.oldMap, Trigger.new);
            }
        }
        // Added by Alejandra O, Salesforce Services
        ContactTriggerHandler handler = new ContactTriggerHandler();
        if (Trigger.isAfter && Trigger.isUpdate) {
            handler.onAfterUpdate(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
        }
    }
}