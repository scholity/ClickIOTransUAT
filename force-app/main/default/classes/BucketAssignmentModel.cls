/*****************************************************************************************************
 
Class    :  BucketAssignmentModel
Developer:  Krishna Kollu, Joo Kang, Blue Wolf Group LLC
Created  :  April 29, 2014
Modified :  June 3, 2014 (latest code change)
Objective:  This class is used to assign/unassign contacts from bucket accounts. 

            Instantiate this class with the old and new versions of contacts so that account  
            data for the specified accounts can be queried and used to determine which contacts 
            should be assigned or unassigned from bucket accounts.
 
*****************************************************************************************************/ 
public with sharing class BucketAssignmentModel {
    public static Boolean firstCall = true;

    private static Set<String> contactFieldsReferencedInTrigger = new Set<String> {'ID','AccountID'};

    private static Bucket_Account_Settings__c bucketAccountSettings {
        get {
            if(bucketAccountSettings==null)
            {
                bucketAccountSettings = Bucket_Account_Settings__c.getOrgDefaults();
            }
            return bucketAccountSettings;
        }
        private set;
    }

    private static Map<ID, Contact> LastTriggerNew {
        get {
            if(LastTriggerNew==null)
                LastTriggerNew = new Map<ID, Contact>();
            return LastTriggerNew;
        }
        set;
    }

    private Map<Id, Contact> oldMap;
    private Map<Id, Account> mapOfAllAccounts;

    public BucketAssignmentModel(Map<Id, Contact> oldMapParam, List<Contact> newList) {
        this.oldMap = oldMapParam;
        this.mapOfAllAccounts = generateMapOfAllAccounts(newList);
    }

    public static Boolean validateCustomSettings(List<Contact> contacts)
    {
        if(bucketAccountSettings.Bucket_Account_Owner_ID__c==null || bucketAccountSettings.Default_Bucket_Name__c==null 
            || bucketAccountSettings.Maximum_Size_of_Bucket__c==null || bucketAccountSettings.Bucket_Account_RecordTypeID__c==null)
        {
            for(Contact c : contacts)
            {
                c.addError(System.Label.No_Bucket_Account_Setings_Validation);
            }
            return false;
        }
        return true;
    }

    /**
     * Queries for RecordTypeID and Spots_Taken__c fields of all Accounts that can possibly be used.
     * This query is done because the model will need the field information for filtering and processing.
     */
    Map<Id, Account> generateMapOfAllAccounts(List<Contact> extra) {
        Set<Id> accountIDs = new Set<Id>();
        if (oldMap != null) 
            accountIDs.addAll(Pluck.ids('AccountId', oldMap.values()));
        if (extra != null)
            accountIDs.addAll(Pluck.ids('AccountId', extra));
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, RecordTypeID, Spots_Taken__c FROM Account WHERE Id in :accountIDs]);
        return accountMap;
    }

    public List<Contact> getOldVersions(List<Contact> newContacts) {
        List<Contact> oldContacts = new List<Contact>();
        for (Contact c : newContacts) 
            oldContacts.add(oldMap.get(c.Id));
        return oldContacts;
    }

    /**
     * Get all contacts that are not associated to accounts
     */
    public List<Contact> getPrivateContacts(List<Contact> contacts)
    {
        List<Contact> privateContacts = new List<Contact>();
        for (Contact c: contacts) {
            if (c.AccountID == null) 
                privateContacts.add(c);
        }
        return privateContacts;
    }

    /**
     * Get all contacts that are in Bucket Accounts
     */
    public List<Contact> getBucketedContacts(List<Contact> contacts)
    {
        List<Contact> bucketedContacts = new List<Contact>();
        for (Contact c: contacts) {
            if (mapOfAllAccounts.get(c.AccountId) != null) {
                if (c.AccountId != null && mapOfAllAccounts.get(c.AccountId).RecordTypeID == bucketAccountSettings.Bucket_Account_RecordTypeID__c) 
                    bucketedContacts.add(c);
            }
        }
        return bucketedContacts;
    }

    /**
     * Get all contacts that are not in Bucket Account and are not private
     */
    public List<Contact> getNormalContacts(List<Contact> contacts) 
    {
        List<Contact> normalContacts = new List<Contact>();
        for (Contact c: contacts) {
            if (mapOfAllAccounts.get(c.AccountId) != null) {
                if (c.AccountId != null && mapOfAllAccounts.get(c.AccountId).RecordTypeID != bucketAccountSettings.Bucket_Account_RecordTypeID__c) 
                    normalContacts.add(c);
            }
        }
        return normalContacts;
    }


    /**
     *  Simple filter function that filters out all Contacts that don't have updated Accounts
     */
    public List<Contact> getContactsWithModifiedAccount(List<Contact> contacts) 
    {
        List<Contact> contactsWithModifiedAccount = new List<Contact>();
        for (Contact c : contacts) {
            if (c.AccountID != oldMap.get(c.Id).AccountID) 
                contactsWithModifiedAccount.add(c);
        }
        return contactsWithModifiedAccount;
    }

    public List<Contact> getContactsPreviouslyUnderNormalAccount(List<Contact> contacts) 
    {
        List<Contact> contactsPreviouslyUnderNormalAccount = new List<Contact>();
        for (Contact c : contacts) {
            if (oldMap.get(c.Id).AccountId != null && mapOfAllAccounts.get(oldMap.get(c.Id).AccountId).RecordTypeID != bucketAccountSettings.Bucket_Account_RecordTypeID__c) 
                contactsPreviouslyUnderNormalAccount.add(c);
        }
        return contactsPreviouslyUnderNormalAccount;
    }

    public List<Contact> getContactsPreviouslyUnderBucketAccount(List<Contact> contacts) 
    {
        List<Contact> contactsPreviouslyUnderBucketAccount = new List<Contact>();
        for (Contact c : contacts) {
            if (oldMap.get(c.Id).AccountId != null && mapOfAllAccounts.get(oldMap.get(c.Id).AccountId).RecordTypeID == bucketAccountSettings.Bucket_Account_RecordTypeID__c) 
                contactsPreviouslyUnderBucketAccount.add(c);
        }
        return contactsPreviouslyUnderBucketAccount;
    }


    /**
      * Assigns contacts to Buckets. Buckets can only lose space.
     */ 
    public static void assignContacts(List<Contact> contactsToAssignBuckets) {
        try
        {
            ApexQueue potentialBuckets = new ApexQueue(queryOpenBuckets(contactsToAssignBuckets.size()));
            ApexQueue usedBuckets = new ApexQueue();

            for(Contact c : contactsToAssignBuckets)
            {
                c.AccountID = getOpenBucket(potentialBuckets, usedBuckets).ID;
            }
            update usedBuckets.getList();
        }
        catch(DMLException dEx)
        {
            addDMLExceptionToAllContacts(dEx,contactsToAssignBuckets);
        }
    }

    public static void addDMLExceptionToAllContacts(DMLException dEx, List<Contact> contactsToAddError)
    {
        for (Integer i = 0; i < dEx.getNumDml(); i++) {
            for(Contact c : contactsToAddError)
            {
                c.addError(dEx.getDmlMessage(i));
            }
        }
    }

    public static void updateContacts(List<Contact> contactsToUpdate, List<Contact> originalContacts)
    {
        try
        {
            update contactsToUpdate;
        }
        catch(DMLException dx)
        {
            addDMLExceptionToAllContacts(dx,originalContacts);
        }
    }

    /**
      * Deassigns contacts from their buckets. Buckets can only gain space.
      * @precondition all contacts in contactsToDeassignFromBuckets must be assigned to a bucket account
     */
    public static void unassignContacts(List<Contact> contactsToDeassignFromBuckets) {
        try
        {
            if (!contactsToDeassignFromBuckets.isEmpty()) {
                Set<Id> idsOfBucketsToRemoveFrom = Pluck.ids('AccountID', contactsToDeassignFromBuckets);
                Map<Id, Account> bucketsToRemoveFrom = 
                    new Map<Id,Account>([SELECT Id, Spots_Taken__c FROM Account WHERE Id in :idsOfBucketsToRemoveFrom]);
                for (Contact c : contactsToDeassignFromBuckets) 
                    bucketsToRemoveFrom.get(c.AccountID).Spots_Taken__c--;
                update bucketsToRemoveFrom.values();
            }
        }
        catch(DMLException dEx)
        {
            addDMLExceptionToAllContacts(dEx,contactsToDeassignFromBuckets);
        }
    }

    public static void addDirectAssignmentErrors(List<Contact> contactsWithErrors) {
        if (!contactsWithErrors.isEmpty()) {
            for (Contact c : contactsWithErrors) {
                c.addError(Label.Direct_Assignment_To_Bucket_Account_Error);
            }
        }
    }

    /**
      * Queries database for Account records of Record Type Bucket Account. 
      * @param maximum Maximum number of buckets returned
      * @throws later
      * @return just enough buckets ordered by number of contacts in bucket, descending. 
      *         No buckets in the returned list are full.
     */
    @TestVisible static List<Account> queryOpenBuckets(Integer max) {
        return [Select ID, Spots_Taken__c From Account Where RecordTypeID =: bucketAccountSettings.Bucket_Account_RecordTypeID__c AND Spots_Taken__c<:bucketAccountSettings.Maximum_Size_of_Bucket__c ORDER BY Spots_Taken__c ASC LIMIT :max];
    }


    /**
     * Return an open bucket that has space for at least one contact
     * If there is an open bucket in usedBuckets, that bucket will be chosen first.
     * If there are no open buckets in usedBuckets, then if there is at least one bucket in potentialBuckets,
     * the bucket with most open slots will be popped from potentialBuckets and pushed to usedBuckets.
     * If there is neither an open bucket in usedBuckets or potentialBuckets, a new bucket will be created
     * and pushed to usedBuckets.
     * The chosen bucket will have its "Spots Taken" incremented by 1.
     * @invariant  potentialBuckets cannot have any full buckets
     * @invariant  potentialBuckets is always sorted in ascending order by "Spots Taken"
     * @invariant  usedBuckets is always sorted in descending order by "Spots Taken". 
     *             At most, there can only be one open bucket on usedBuckets
     * @invariant  At most, there can only be one new bucket Account inserted into the database 
     *             in a single call
     * @return the chosen bucket
     */
    @TestVisible static Account getOpenBucket(ApexQueue potentialBuckets, ApexQueue usedBuckets) {
        if (usedBuckets.isEmpty() || ((Account)usedBuckets.back()).Spots_Taken__c >= bucketAccountSettings.Maximum_Size_of_Bucket__c) {
            if (!potentialBuckets.isEmpty()) {
                usedBuckets.push(potentialBuckets.pop());
            } else {
                usedBuckets.push(newBucket());
            }
        }
        Account openBucket = (Account) (usedBuckets.back());
        openBucket.Spots_Taken__c++;
        return openBucket;
    }

    /**
     * Creates a new Bucket account with Name, OwnerID and RecordTypeID specified by bucketAccountSettings.
     * Should not be called a lot of times. A new bucket should be created only when there are no more open buckets,
     * where a bucket can hold a maximum of 50,000 contacts (as of 5/5/14).
     * @pre bucketAccountSettings must not be null. It must also have Name, OwnerID, and RecordTypeID values.
     * @post new Bucket Account will be DML inserted
     * @return the created bucket Account
     */
    @TestVisible static Account newBucket() {
        Account bucket = new Account();
        bucket.Name = bucketAccountSettings.Default_Bucket_Name__c;
        bucket.OwnerID = bucketAccountSettings.Bucket_Account_Owner_ID__c;
        bucket.RecordTypeID = bucketAccountSettings.Bucket_Account_RecordTypeID__c;
        bucket.Spots_Taken__c = 0;
        insert bucket;
        return bucket;
    }

    public static void handleNewContacts(List<Contact> newContacts)
    {
        if(BucketAssignmentModel.validateCustomSettings(newContacts))
        {
            BucketAssignmentModel.firstCall = false;
            BucketAssignmentModel bam = new BucketAssignmentModel(null, newContacts);
            BucketAssignmentModel.addDirectAssignmentErrors(bam.getBucketedContacts(newContacts));
            BucketAssignmentModel.assignContacts(bam.getPrivateContacts(newContacts));
        }
    }

    public static void handleDeletedContacts(Map<ID,Contact> oldContacts)
    {
        if(BucketAssignmentModel.validateCustomSettings(oldContacts.values()))
            {
                BucketAssignmentModel.firstCall = false;
                BucketAssignmentModel bam = new BucketAssignmentModel(oldContacts, null);
                BucketAssignmentModel.unassignContacts(bam.getBucketedContacts(oldContacts.values()));
                
            }
    }

    public static void handleUndeletedContacts(List<Contact> newContacts)
    {
        if(BucketAssignmentModel.validateCustomSettings(newContacts))
            {
                BucketAssignmentModel.firstCall = false;
                BucketAssignmentModel bam = new BucketAssignmentModel(null, newContacts);
                List<Contact> deltaContacts = new List<Contact>();
                for (Contact c : bam.getBucketedContacts(newContacts)) 
                    deltaContacts.add(new Contact(id=c.Id));
                BucketAssignmentModel.assignContacts(deltaContacts);
                BucketAssignmentModel.updateContacts(deltaContacts,newContacts);
            }
    }

    public static void handleUpdatedContacts(Map<ID, Contact> oldContacts, List<Contact> newContacts)
    {
        if(BucketAssignmentModel.validateCustomSettings(newContacts) && allowRetry(newContacts))
            {
                BucketAssignmentModel.firstCall = false;
                BucketAssignmentModel bam = new BucketAssignmentModel(oldContacts, newContacts);
                List<Contact> contactsWithModifiedAccounts = bam.getContactsWithModifiedAccount(newContacts);

                List<Contact> contactsPreviouslyUnderNormalAccounts = bam.getContactsPreviouslyUnderNormalAccount(contactsWithModifiedAccounts);
                List<Contact> contactsPreviouslyUnderBucketAccounts = bam.getContactsPreviouslyUnderBucketAccount(contactsWithModifiedAccounts);

                List<Contact> contactsToUnassign = bam.getOldVersions(bam.getPrivateContacts(contactsPreviouslyUnderBucketAccounts));
                contactsToUnassign.addAll(bam.getOldVersions(bam.getNormalContacts(contactsPreviouslyUnderBucketAccounts)));
                BucketAssignmentModel.addDirectAssignmentErrors(bam.getBucketedContacts(contactsWithModifiedAccounts));
                BucketAssignmentModel.unassignContacts(contactsToUnassign);
                BucketAssignmentModel.assignContacts(bam.getPrivateContacts(contactsWithModifiedAccounts));
                
                stampTriggerNew(newContacts);
            }
    }

    /*
     * Evaluates if SF is retrying the transaction, and if we need to ignore the recursive boolean
     */
    public static Boolean allowRetry(List<Contact> triggerNew)
    {
        if(BucketAssignmentModel.firstCall)
            return true;

        for(Contact c : triggerNew)
        {
            if(LastTriggerNew.containsKey(c.ID) && LastTriggerNew.get(c.ID).AccountID!=c.AccountID)
            {
                //What the trigger tried to do in the previous transaction did not stick as it must have been rolled back, 
                //consequently allow for a retry. Note code assumes that other apex triggers on contact do not touch accountID
                return true;
            }
        }
        return false;
    }

    public static void stampTriggerNew(List<Contact> triggerNew)
    {
        for (Contact currentTriggerNewContact : triggerNew)
        {
            Contact contactToAdd = new Contact();
            for(String field : contactFieldsReferencedInTrigger)
            {
                if(field!=null)
                    contactToAdd.put(field,currentTriggerNewContact.get(field));
            }
            LastTriggerNew.put(contactToAdd.ID, contactToAdd);
        }
    }
}