/*****************************************************************************************************
 
Class    :  TestContactTrigger
Developer:  Krishna Kollu, Joo Kang, Blue Wolf Group LLC
Created  :  May 6, 2014
Modified :  June 3, 2014 (latest code change)
Objective:  This class tests the contact trigger
 
*****************************************************************************************************/ 
@isTest
private class TestContactTrigger {
    static Bucket_Account_Settings__c orgSettings;
    static RecordType normalRecordType;
    static void setup()
    {
        List<RecordType> accountRecordTypes =  [Select ID From RecordType Where SObjectType='Account' AND IsActive=TRUE];
        User bucketOwner = TestUtil.createUser('BucketOwner@redcross.org',TestUtil.SYSTEM_ADMINISTRATOR_PROFILE.ID, true, null, 'Bee',  'Bob');
        orgSettings = new Bucket_Account_Settings__c(Bucket_Account_Owner_ID__c=bucketOwner.ID, 
                                                                             Default_Bucket_Name__c='Default Name',
                                                                             Maximum_Size_of_Bucket__c = 200,
                                                                             Bucket_Account_RecordTypeID__c = accountRecordTypes[0].ID,
                                                                             SetupOwnerId =UserInfo.getOrganizationId());
        normalRecordType = accountRecordTypes[1];                                                  
        insert orgSettings;
    }

     static testMethod void testPartialSuccessUpdate()
    {
        setup();

        UnitTest.createTestData(TestUtil.contacts).many(4).insertAll(); //This will create a bucket account
        BucketAssignmentModel.firstCall = true;

        Account bucketAccount = [Select ID, Spots_Taken__c From Account Limit 1];
        UnitTest.createTestData(TestUtil.accounts).single().property('RecordTypeID').assign(normalRecordType.ID).tag('Normal Account').insertAll();
        UnitTest.forEach('Normal Account').create(153,TestUtil.contacts).copyProperty('ID->AccountId').tag('Normal Contact');
    
        BucketAssignmentModel.firstCall = true;
        UnitTest.get('Normal Contact').insertAll();
        

        Test.startTest();
            UnitTest.get('Normal Contact').divide(3).part('Contact to Remain Untouched')
                                                    .part('Contact To Assign To Null Account')
                                                    .part('Contact To Directly Assign To Bucket Account');
            UnitTest.get('Contact To Assign To Null Account').assign('AccountID',null);
            UnitTest.get('Contact To Directly Assign To Bucket Account').assign('AccountID',bucketAccount.ID);
            
            BucketAssignmentModel.firstCall = true;
            Database.update(UnitTest.get('Normal Contact').getList(),false);
        Test.stopTest();

        Decimal expectedContactsInBuckets = bucketAccount.Spots_Taken__c + UnitTest.get('Contact To Assign To Null Account').getList().size();

        List<Contact> contactsRequeried = [Select ID, AccountID From Contact Where ID IN: UnitTest.getIds('Normal Contact')];
        for(Contact c : contactsRequeried)
        {
            if(UnitTest.analyze('Contact To Assign To Null Account').hasId(c.ID))
            {
                System.assertEquals(bucketAccount.ID,c.AccountID, 'If a contact\'s account ID was set to null, it must be moved to a bucket account');
            }
            else if(UnitTest.analyze('Contact To Directly Assign To Bucket Account').hasId(c.ID))
            {
                System.assertNotEquals(bucketAccount.ID,c.AccountID, 'If a contact\'s account ID was set to a bucket account, there must be an error and that must be rolled back');
            }
            else if(UnitTest.analyze('Contact to Remain Untouched').hasId(c.ID))
            {
                 System.assertNotEquals(bucketAccount.ID,c.AccountID, 'If a contact\'s account ID was not touched, the trigger should not assign it to a bucket account');
            }
        }

        List<Account> bucketAccounts = [Select ID, Spots_Taken__c From Account Where Spots_Taken__c>0];
        System.assertEquals(1,bucketAccounts.size(),'There should only be one bucket account if there is enough space to add all contacts needing assignemnt to that one bucket');
        System.assertEquals(expectedContactsInBuckets,bucketAccounts[0].Spots_Taken__c,'Each bucket should record the correct number of contacts');
    }

    static testMethod void testError_WhenCustomSettingsNotThere()
    {
        Test.startTest();
            try
            {
                UnitTest.createTestData(TestUtil.contacts).many(10).insertAll();
            }
            catch(DMLException dex)
            {
                System.assert(dex.getMessage().contains(System.Label.No_Bucket_Account_Setings_Validation),'If the custom settings are not defined, then there must be an error'); 
            }
        Test.stopTest();    
    }

    static testMethod void updateB2CContact_NormalToBucket()
    {
        setup();
        UnitTest.createTestData(TestUtil.contacts).many(10).insertAll(); //This will create a bucket account

        Account bucketAccountID = [Select ID, Spots_Taken__c From Account Limit 1];

        UnitTest.createTestData(TestUtil.accounts).many(2).property('RecordTypeID').assign(normalRecordType.ID).tag('Normal Account').insertAll();
        UnitTest.forEach('Normal Account').create(100,TestUtil.contacts).copyProperty('ID->AccountId').tag('Normal Contact');

        BucketAssignmentModel.firstCall = true;
        UnitTest.get('Normal Contact').insertAll();

        Test.startTest();
            UnitTest.get('Normal Contact').getList()[0].put('AccountID',bucketAccountID.Id);
            try {
                BucketAssignmentModel.firstCall = true;
                update UnitTest.get('Normal Contact').getList();
                System.assert(false, 'A user cannot manually assign a normal contact to a bucket account. The contact must be set to a null account so that the trigger can manage which buckets will have contacts');
            } catch (DmlException dex) {
                System.assert(dex.getMessage().contains(System.Label.Direct_Assignment_To_Bucket_Account_Error), 
                    'A user cannot manually assign a normal contact to a bucket account. The contact must be set to a null account so that the trigger can manage which buckets will have contacts');
            }
        Test.stopTest();
    }

    static testMethod void updateB2CContact_BucketToBucket()
    {

        setup();
        UnitTest.createTestData(TestUtil.contacts).many(200).tag('Contacts For Bucket A').insertAll(); //This will create a bucket account
        ID bucketAID = [Select ID From Account Limit 1].ID;
        BucketAssignmentModel.firstCall = true;
        UnitTest.createTestData(TestUtil.contacts).many(200).tag('Contacts For Bucket B').insertAll(); //This will create a bucket account
        
        Test.startTest();
            UnitTest.get('Contacts For Bucket B').getList()[0].put('AccountID',bucketAID); 
            try {
                BucketAssignmentModel.firstCall = true;
                update UnitTest.get('Contacts For Bucket B').getList();
                System.assert(false, 'A user cannot manually assign a normal contact to a bucket account. The contact must be set to a null account so that the trigger can manage which buckets will have contacts');
            } catch (DmlException dex) {
                System.assert(dex.getMessage().contains(System.Label.Direct_Assignment_To_Bucket_Account_Error), 
                    'A user cannot manually assign a normal contact to a bucket account. The contact must be set to a null account so that the trigger can manage which buckets will have contacts');
            }
        Test.stopTest();
    }

    static testMethod void updateB2CContactsTriggerTest()
    {
        setup();
        
        UnitTest.createTestData(TestUtil.contacts).many((Integer) orgSettings.Maximum_Size_of_Bucket__c).tag('Contacts For Bucket A').tag('Contacts In Original Buckets').insertAll();
        BucketAssignmentModel.firstCall = true;
        UnitTest.createTestData(TestUtil.contacts).many((Integer) orgSettings.Maximum_Size_of_Bucket__c).tag('Contacts For Bucket B').tag('Contacts In Original Buckets').insertAll();
        BucketAssignmentModel.firstCall = true;
        UnitTest.createTestData(TestUtil.contacts).many((Integer) orgSettings.Maximum_Size_of_Bucket__c).tag('Contacts For Bucket C').tag('Contacts In Original Buckets').insertAll();
        BucketAssignmentModel.firstCall = true;
        UnitTest.createTestData(TestUtil.contacts).many((Integer) orgSettings.Maximum_Size_of_Bucket__c/2).tag('Contacts For Bucket D').tag('Contacts In Original Buckets').insertAll();
        
        UnitTest.addData([Select ID From Account]).tag('Accounts').tag('Existing Bucket Account');
        
        UnitTest.createTestData(TestUtil.accounts).many(10).tag('Accounts').tag('Normal Accounts').property('RecordTypeID').assign(normalRecordType.ID).insertAll();
        UnitTest.get('Normal Accounts').divide(2).part('Normal Account Group 1').part('Normal Account Group 2');
        
        UnitTest.forEach('Normal Account Group 1').create(20,TestUtil.contacts).copyProperty('ID->AccountID').tag('Normal Contacts');
        
        BucketAssignmentModel.firstCall = true;
        UnitTest.get('Normal Contacts').insertAll();
        
        UnitTest.get('Normal Contacts').divide(2).part('Normal To Normal').part('Normal To Null');
        UnitTest.get('Contacts For Bucket A').divide(10).part('Bucket A To Null').part('Bucket A To Normal').part('Bucket A To Bucket A');
        UnitTest.get('Contacts For Bucket C').divide(10).part('Bucket C To Null').part('Bucket C To Normal');
        
        UnitTest.get('Bucket A To Bucket A').tag('Contact To Update');
        UnitTest.get('Normal To Normal').tag('Contact To Assign Normal Account').tag('Contact To Update');
        UnitTest.get('Normal To Null').tag('Contact To Assign Null Account').tag('Contact To Update');
        UnitTest.get('Bucket A To Null').tag('Contact To Assign Null Account').tag('Contact To Update');
        UnitTest.get('Bucket A To Normal').tag('Contact To Assign Normal Account').tag('Contact To Update');
        UnitTest.get('Bucket C To Null').tag('Contact To Assign Null Account').tag('Contact To Update');
        UnitTest.get('Bucket C To Normal').tag('Contact To Assign Normal Account').tag('Contact To Update');
        
        UnitTest.get('Contact To Assign Normal Account').property('AccountID').assignFrom('Normal Account Group 2');
        UnitTest.get('Contact To Assign Null Account').property('AccountID').assign(null);
        
        Test.startTest();
            BucketAssignmentModel.firstCall = true;
            UnitTest.get('Contact To Update').updateAll();
        Test.stopTest();
        
        Integer originalNumberOfContactsInBuckets = UnitTest.get('Contacts In Original Buckets').getList().size();
        Integer expectedContactsInBuckets = originalNumberOfContactsInBuckets - UnitTest.get('Bucket A To Normal').getList().size() - UnitTest.get('Bucket C To Normal').getList().size() 
                                            +  UnitTest.get('Normal To Null').getList().size();

                                            //System.assert(false, expectedContactsInBuckets);
                                                    
        List<Account> bucketsInSystem = [SELECT Id, Spots_Taken__c, (Select ID From Contacts) FROM Account 
                                        WHERE RecordTypeId = :orgSettings.Bucket_Account_RecordTypeID__c
                                        ORDER BY Spots_Taken__c ASC];

        System.assertEquals(4, bucketsInSystem.size(), 'Bucket accounts should not be created unless there is no room on an existing bucket account. ');
        
        Integer actualB2CContacts = 0;
        for(Integer i = 0; i < bucketsInSystem.size(); i++)
        {
            Account bucket = bucketsInSystem[i];
            System.assertEquals(bucket.contacts.size(), bucket.Spots_Taken__c, 'The spots taken on any bucket account must reflect how many B2C contacts are under the account');
            actualB2CContacts+=bucket.contacts.size();
        }
        
        System.assertEquals(expectedContactsInBuckets,actualB2CContacts, 'When contacts are updated, underlying triggers must correct identify which contacts must be assigned to/unassigned from bucket accounts, and update bucket accounts to maintain an accurate count of B2C contacts');
        
        List<Account> normalAccountsWithSpotsTaken = [Select ID From Account WHERE RecordTypeId != :orgSettings.Bucket_Account_RecordTypeID__c AND Spots_Taken__c!=null];
        System.assertEquals(0,normalAccountsWithSpotsTaken.size(), 'There must be no normal accounts with spots taken');
    }

    static testMethod void insertB2CContactDirectlyOnBucket()
    {
        setup();
        UnitTest.createTestData(TestUtil.contacts).many(10).insertAll(); //This will create a bucket account

        Account bucketAccountID = [Select ID, Spots_Taken__c From Account Limit 1];

        UnitTest.createTestData(TestUtil.contacts).many(10).tag('Contacts To Directly Assign To Bucket Account');

        Test.startTest();
            UnitTest.get('Contacts To Directly Assign To Bucket Account').property('AccountID').assign(bucketAccountID.Id);
            try {
                BucketAssignmentModel.firstCall = true;
                insert UnitTest.get('Contacts To Directly Assign To Bucket Account').getList();
                System.assert(false, 'A user cannot manually assign a contact to a bucket account. The contact must be set to a null account so that the trigger can manage which buckets will have contacts');
            } catch (DmlException dex) {
                System.assert(dex.getMessage().contains(System.Label.Direct_Assignment_To_Bucket_Account_Error), 
                    'A user cannot manually assign a contact to a bucket account. The contact must be set to a null account so that the trigger can manage which buckets will have contacts');
            }
        Test.stopTest();
    }

    static testMethod void insertB2CContactsTriggerTest_NoExistingBucket() {
        setup();
        UnitTest.createTestData(TestUtil.accounts).many(10).tag('Accounts').property('RecordTypeID').assign(normalRecordType.ID).insertAll();
        UnitTest.createTestData(TestUtil.contacts).many(200).tag('Contacts').divide(2).part('Contacts That Need Buckets').part('Contacts That Dont');
        UnitTest.get('Contacts That Need Buckets').property('AccountID').assign(null);
        UnitTest.get('Contacts That Dont').property('AccountID').assignFrom('Accounts');

        Test.startTest();
            insert UnitTest.get('Contacts').getList();
        Test.stopTest();

        List<Account> oneNewBucket = [SELECT Id, Spots_Taken__c FROM Account 
                                        WHERE RecordTypeId = :orgSettings.Bucket_Account_RecordTypeID__c];
        System.assertEquals(1, oneNewBucket.size(), 
            'Only one bucket should be created because there were no buckets to begin with');
        System.assertEquals(100, oneNewBucket[0].Spots_Taken__c,
            'The newly created bucket should have 100 spots taken because there are 100 private contacts being inserted');
        List<Contact> bucketedContacts = [SELECT Id FROM Contact WHERE AccountID = :oneNewBucket[0].Id];
        UnitTest.analyze('Contacts That Need Buckets').assertEquivalence(bucketedContacts,
            'Contacts were not properly assigned to buckets');
    }

    static testMethod void insertB2CContactsTriggerTest_ExistingBucket() {
        setup();
        UnitTest.createTestData(TestUtil.accounts).many(10).tag('Accounts').property('RecordTypeID').assign(normalRecordType.ID).insertAll();
        UnitTest.createTestData(TestUtil.contacts).many(199).tag('Contacts').property('AccountID').assign(null);
        insert UnitTest.get('Contacts').getList();
        // There should be one Bucket Account with one more spot left

        UnitTest.createTestData(TestUtil.contacts).many(10).tag('More Contacts').property('AccountID').assign(null);
        
        Test.startTest();
            BucketAssignmentModel.firstCall = true;
            insert UnitTest.get('More Contacts').getList();
        Test.stopTest();

        List<Account> twoNewBuckets = [SELECT Id, Spots_Taken__c FROM Account 
                                        WHERE RecordTypeId = :orgSettings.Bucket_Account_RecordTypeID__c
                                        ORDER BY Spots_Taken__c ASC];
        System.assertEquals(2, twoNewBuckets.size(), 
            'Only two buckets should exist because there was one bucket to begin with, and then one more was created');
        System.assertEquals(9, twoNewBuckets[0].Spots_Taken__c,
            'The newly created bucket should have 9 spots taken because there were 10 private contacts inserted, and 1/10 was assigned to the existing bucket');
        System.assertEquals(orgSettings.Maximum_Size_of_Bucket__c, twoNewBuckets[1].Spots_Taken__c,
            'The existing bucket should have 200 spots taken because there were 10 private contacts inserted, from which 1 was assigned to the existing bucket');
        List<Contact> bucketedContacts = [SELECT Id, AccountID FROM Contact];
        Map<Id, List<sObject>> bucketedContactsByBucket = GroupBy.ids('AccountID', bucketedContacts);
        System.assertEquals(200, bucketedContactsByBucket.get(twoNewBuckets[1].Id).size(),
            'There should be 200 contacts assigned to existing bucket');
        System.assertEquals(9, bucketedContactsByBucket.get(twoNewBuckets[0].Id).size(),
            'There should be 9 contacts assigned to the new bucket');
    }

    static testMethod void deleteB2CContactsTriggerTest()
    {
        setup();

        UnitTest.createTestData(TestUtil.contacts).many(200).tag('Contacts For Bucket A').insertAll();
        BucketAssignmentModel.firstCall = true;
        UnitTest.createTestData(TestUtil.contacts).many(200).tag('Contacts For Bucket B').insertAll();
        BucketAssignmentModel.firstCall = true;
        UnitTest.createTestData(TestUtil.contacts).many(80).tag('Contacts For Bucket C').insertAll();
        BucketAssignmentModel.firstCall = true;

        UnitTest.addData([Select ID From Account]).tag('Existing Bucket Accounts');

        UnitTest.createTestData(TestUtil.accounts).many(10).tag('Accounts').property('RecordTypeID').assign(normalRecordType.ID).insertAll();
        UnitTest.createTestData(TestUtil.contacts).many(80).tag('Other Contact').property('AccountID').assignFrom('Accounts');
        BucketAssignmentModel.firstCall = true;
        insert UnitTest.get('Other Contact').getList();

        UnitTest.get('Contacts For Bucket A').divide(2).part('Contacts To Delete For Bucket A').part('Contacts To Persist For Bucket A');
        UnitTest.get('Contacts For Bucket C').divide(2).part('Contacts To Delete For Bucket C').part('Contacts To Persist For Bucket C');
        UnitTest.get('Other Contact').divide(2).part('Other Contact To Delete').part('Other Contact To Persist'); 

        UnitTest.get('Contacts To Delete For Bucket A').tag('Contact To Delete');
        UnitTest.get('Contacts To Delete For Bucket C').tag('Contact To Delete');
        UnitTest.get('Other Contact To Delete').tag('Contact To Delete');

        Test.startTest();
            BucketAssignmentModel.firstCall = true;
            delete UnitTest.get('Contact To Delete').getList();
        Test.stopTest();

        List<Account> accountsWithSpotsTaken = [Select ID, Spots_Taken__c From Account Where Spots_Taken__c!=null ORDER BY Spots_Taken__c ASC];
        UnitTest.analyze('Existing Bucket Accounts').assertEquivalence(accountsWithSpotsTaken,'The only accounts with spots taken must be bucket accounts');

        System.assertEquals(UnitTest.get('Contacts To Persist For Bucket C').getList().size(), accountsWithSpotsTaken[0].Spots_Taken__c, 'When contacts are deleted from buckets accounts, the affected bucket accounts must have the correct number of spots taken');
        System.assertEquals(UnitTest.get('Contacts To Persist For Bucket A').getList().size(), accountsWithSpotsTaken[1].Spots_Taken__c, 'When contacts are deleted from buckets accounts, the affected bucket accounts must have the correct number of spots taken');
        System.assertEquals(UnitTest.get('Contacts For Bucket B').getList().size(), accountsWithSpotsTaken[2].Spots_Taken__c, 'When contacts are deleted, only the bucket accounts associated to the contacts will be decremented. Other bucket accounts will remain unaffected');
    }

    static testMethod void undeleteB2CContactsTriggerTest()
    {
        setup();

        UnitTest.createTestData(TestUtil.contacts).many(200).tag('Bucketed Contacts').insertAll();

        UnitTest.addData([Select ID From Account]).tag('Existing Bucket Account');

        UnitTest.createTestData(TestUtil.accounts).many(10).tag('Accounts').property('RecordTypeID').assign(normalRecordType.ID).insertAll();
        UnitTest.createTestData(TestUtil.contacts).many(80).tag('Contacts').tag('Other Contact').property('AccountID').assignFrom('Accounts');
        insert UnitTest.get('Other Contact').getList();

        UnitTest.get('Bucketed Contacts').divide(2).part('Bucketed Contacts To Delete').part('Bucketed Contacts To Persist');
        BucketAssignmentModel.firstCall = true;
        delete UnitTest.get('Bucketed Contacts To Delete').getList();
        // At this point, existing bucket account is half full

        UnitTest.createTestData(TestUtil.contacts).many(60).tag('More Bucketed Contacts').property('AccountID').assign(null);
        BucketAssignmentModel.firstCall = true;
        insert UnitTest.get('More Bucketed Contacts').getList();
        // At this point, existing bucket accouns has 160/200 filled

        UnitTest.get('Bucketed Contacts To Delete').tag('Bucketed Contacts To Undelete'); 
        Test.startTest();
            BucketAssignmentModel.firstCall = true;
            undelete UnitTest.get('Bucketed Contacts To Undelete').getList(); // size: 100
        Test.stopTest();

        List<Account> accountsWithSpotsTaken = [Select ID, Spots_Taken__c From Account Where Spots_Taken__c!=null ORDER BY Spots_Taken__c ASC];
        System.assertEquals(2, accountsWithSpotsTaken.size(), 
            'Inserting contacts between a delete and an undelete should cause the undelete to fill up other buckets OR create a new one');
        System.assertEquals((Integer)orgSettings.Maximum_Size_of_Bucket__c, accountsWithSpotsTaken[1].Spots_Taken__c,
            'Undeleting b2c contacts should assign those contacts to existing buckets first');
        System.assertEquals(60, accountsWithSpotsTaken[0].Spots_Taken__c,
            'Undeleting b2c contacts should assign those contacts to existing buckets first and then fill up other buckets OR, in this case, create a new one');
        List<Contact> bucketedContacts = [SELECT Id, AccountID FROM Contact WHERE Account.RecordTypeId = :orgSettings.Bucket_Account_RecordTypeID__c];
        Map<Id, List<sObject>> bucketedContactsByBucket = GroupBy.ids('AccountID', bucketedContacts);
        System.assertEquals((Integer)orgSettings.Maximum_Size_of_Bucket__c, bucketedContactsByBucket.get(accountsWithSpotsTaken[1].Id).size(),
            'There should be 200 contacts assigned to existing bucket');
        System.assertEquals(60, bucketedContactsByBucket.get(accountsWithSpotsTaken[0].Id).size(),
            'There should be 60 contacts assigned to the new bucket');
    }
}