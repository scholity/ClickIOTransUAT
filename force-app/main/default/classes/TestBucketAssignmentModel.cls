/*****************************************************************************************************
 
Class    :  TestBucketAssignmentModel
Developer:  Krishna Kollu, Joo Kang, Blue Wolf Group LLC
Created  :  April 29, 2014
Modified :  May 15, 2014
Objective:  This class tests BucketAssignmentModel
 
*****************************************************************************************************/ 
@isTest
private class TestBucketAssignmentModel {
	static Bucket_Account_Settings__c orgSettings;

	static void setup()
	{
		List<RecordType> accountRecordTypes =  [Select ID From RecordType Where SObjectType='Account' AND IsActive=TRUE];
		User bucketOwner = TestUtil.createUser('BucketOwner@redcross.org',TestUtil.SYSTEM_ADMINISTRATOR_PROFILE.ID, true, null, 'Bee',  'Bob');
		orgSettings = new Bucket_Account_Settings__c(Bucket_Account_Owner_ID__c=bucketOwner.ID, 
																			 Default_Bucket_Name__c='Default Name',
																			 Maximum_Size_of_Bucket__c = 1000,
																			 Bucket_Account_RecordTypeID__c = accountRecordTypes[0].ID,
																			 SetupOwnerId =UserInfo.getOrganizationId());
		Bucket_Account_Settings__c userException = new Bucket_Account_Settings__c(Bucket_Account_Owner_ID__c=UserInfo.getUserID(), 
																			 Default_Bucket_Name__c='Error',
																			 Maximum_Size_of_Bucket__c = 1,
																			 Bucket_Account_RecordTypeID__c = accountRecordTypes[1].ID,
																			 SetupOwnerId =UserInfo.getUserID());
		
		List<Bucket_Account_Settings__c> bucketAccountSettings = new List<Bucket_Account_Settings__c> {orgSettings,userException};
		insert bucketAccountSettings;
	}

	static testMethod void testNewBucket()	
	{
		setup();

		Test.startTest();
			Account newBucketAccount = BucketAssignmentModel.newBucket();
		Test.stopTest();

		System.assertNotEquals(null,newBucketAccount.ID, 'If a new bucket account needs to be created, it must be committed to the database before contacts can be assigned to it');
		System.assertEquals(orgSettings.Default_Bucket_Name__c,newBucketAccount.Name,'Bucket accounts have a default name specified by the org defaults of the "bucket account settings" custom setting');
		System.assertEquals(orgSettings.Bucket_Account_Owner_ID__c,newBucketAccount.OwnerID,'Bucket accounts must be owned by the user specified by the org defaults of the "bucket account settings" custom setting');
		System.assertEquals(orgSettings.Bucket_Account_RecordTypeID__c, newBucketAccount.RecordTypeID, 'Bucket accounts must have the record type that is specfied by the org defaults of the "bucket account settings" custom setting');
	}

	static testMethod void testGetOpenBucket_BothPotentialBucketAndUsedBucketsEmpty()
	{
		setup();

		ApexQueue potentialBuckets = new ApexQueue();
		ApexQueue usedBuckets = new ApexQueue();

		Test.startTest();
			Account retAccount = BucketAssignmentModel.getOpenBucket(potentialBuckets, usedBuckets);
		Test.stopTest();

		System.assert(potentialBuckets.isEmpty(), 'The size of potential buckets can never increase. If a bucket needs to be created, it will be pushed to usedBuckets');
		System.assertEquals(1,usedBuckets.size(), 'When a new bucket needs to be created, it will be created and pushed to usedBuckets');
		System.assertEquals(retAccount.ID, usedBuckets.back().ID, 'When a new bucket needs to be created, it will be created and pushed to usedBuckets');
		System.assertEquals(orgSettings.Default_Bucket_Name__c,retAccount.Name, 'When a new bucket needs to be created, a bucket account must be created');
		System.assertEquals(1, retAccount.Spots_Taken__c, 'When a new bucket needs to be created so that a contact can be assigned to it, the spots taken summary field will indicate that a contact will be assigned to it');
	}

	static testMethod void testGetOpenBucket_PotentialBucketEmpty_UsedBucketsHasOpenBucket()
	{
		setup();

		List<Account> usedBucketsAccounts = TestUtil.createAccounts(2, true);
		usedBucketsAccounts[0].Spots_Taken__c=orgSettings.Maximum_Size_of_Bucket__c;
		usedBucketsAccounts[1].Spots_Taken__c=orgSettings.Maximum_Size_of_Bucket__c-1;

		ApexQueue potentialBuckets = new ApexQueue();
		ApexQueue usedBuckets = new ApexQueue(usedBucketsAccounts);

		Test.startTest();
			Account retAccount = BucketAssignmentModel.getOpenBucket(potentialBuckets, usedBuckets);
		Test.stopTest();

		System.assert(potentialBuckets.isEmpty(), 'The size of potential buckets can never increase.');
		System.assertEquals(2,usedBuckets.size(), 'The size of used buckets should not increase when there is an open bucket in used buckets');
		System.assertEquals(retAccount.ID, usedBuckets.back().ID, 'The open bucket in usedBuckets must correctly identified');
		System.assertEquals(orgSettings.Maximum_Size_of_Bucket__c,retAccount.Spots_Taken__c, 'When a contact needs to be assigned to an open bucket, the spots taken summary field must be incremented by 1 in anticipation of that assignment');
	}

	static testMethod void testGetOpenBucket_PotentialBucketEmpty_UsedBucketsHasNoOpenBucket()
	{
		setup();

		List<Account> usedBucketsAccounts = TestUtil.createAccounts(2, true);
		usedBucketsAccounts[0].Spots_Taken__c=orgSettings.Maximum_Size_of_Bucket__c;
		usedBucketsAccounts[1].Spots_Taken__c=orgSettings.Maximum_Size_of_Bucket__c;

		ApexQueue potentialBuckets = new ApexQueue();
		ApexQueue usedBuckets = new ApexQueue(usedBucketsAccounts);

		Test.startTest();
			Account retAccount = BucketAssignmentModel.getOpenBucket(potentialBuckets, usedBuckets);
		Test.stopTest();

		System.assert(potentialBuckets.isEmpty(), 'The size of potential buckets can never increase.');
		System.assertEquals(3,usedBuckets.size(), 'The size of used buckets should increase by 1 when a new bucket must be created because all existing buckets are full');
		System.assertEquals(retAccount.ID, usedBuckets.back().ID, 'The open bucket in usedBuckets must correctly identified');
		System.assertEquals(orgSettings.Default_Bucket_Name__c,retAccount.Name, 'When a new bucket needs to be created, a bucket account must be created');
		System.assertEquals(1, retAccount.Spots_Taken__c, 'When a new bucket needs to be created so that a contact can be assigned to it, the spots taken summary field will indicate that a contact will be assigned to it');
	}

	static testMethod void testGetOpenBucket_PotentialBucketHasOpenBucket_UsedBucketsFull()
	{
		setup();

		List<Account> usedBucketsAccounts = TestUtil.createAccounts(1, false);
		usedBucketsAccounts[0].Spots_Taken__c=orgSettings.Maximum_Size_of_Bucket__c;

		List<Account> potentialBucketAccounts = TestUtil.createAccounts(2, false);
		potentialBucketAccounts[0].Spots_Taken__c=orgSettings.Maximum_Size_of_Bucket__c-2;
		potentialBucketAccounts[1].Spots_Taken__c=orgSettings.Maximum_Size_of_Bucket__c-1;

		ApexQueue potentialBuckets = new ApexQueue(potentialBucketAccounts.clone());
		ApexQueue usedBuckets = new ApexQueue(usedBucketsAccounts.clone());

		List<Account> allAccounts = new List<account>();
		allAccounts.addAll(usedBucketsAccounts);
		allAccounts.addAll(potentialBucketAccounts);
		insert allAccounts;

		ID expectedOpenBucket = potentialBucketAccounts[0].ID;
		Decimal expectedNewSizeOfOpenBucket =  potentialBucketAccounts[0].Spots_Taken__c+1;

		Test.startTest();
			Account retAccount = BucketAssignmentModel.getOpenBucket(potentialBuckets, usedBuckets);
		Test.stopTest();

		System.assertEquals(1,potentialBuckets.size(), 'The size of potential buckets should decrease by 1 when a bucket is popped from potential buckets and pushed to usedbuckets. This happens when there are no open buckets in usedBuckets but there is an open bucket in potential buckets');
		System.assertEquals(2,usedBuckets.size(), 'The size of used buckets should increase by 1 when a bucket is popped from potential buckets and pushed to usedbuckets. This happens when there are no open buckets in usedBuckets but there is an open bucket in potential buckets');
		System.assertEquals(expectedOpenBucket, retAccount.ID, 'The open bucket must correctly identified');	
		System.assertEquals(potentialBucketAccounts[1].ID,potentialBuckets.peek().ID, 'The most open account must be correctly popped from the potential buckets queue');
		System.assertEquals(usedBucketsAccounts[0].ID,usedBuckets.peek().ID, 'The most open account must be correctly popped from the potential buckets queue and correctly pushed to the back of the used buckets queue');
		System.assertEquals(retAccount.ID, usedBuckets.back().ID, 'The open bucket must correctly identified and pushed to the usedBuckets queue');
		System.assertEquals(expectedNewSizeOfOpenBucket,retAccount.Spots_Taken__c, 'When a contact needs to be assigned to an open bucket, the spots taken summary field must be incremented by 1 in anticipation of that assignment');
	}

	static testMethod void testGetOpenBucket_PotentialBucketHasOpenBucket_UsedBucketsEmpty()
	{
		setup();

		List<Account> potentialBucketAccounts = TestUtil.createAccounts(2, true);
		potentialBucketAccounts[0].Spots_Taken__c=orgSettings.Maximum_Size_of_Bucket__c-2;
		potentialBucketAccounts[1].Spots_Taken__c=orgSettings.Maximum_Size_of_Bucket__c-1;

		ApexQueue potentialBuckets = new ApexQueue(potentialBucketAccounts);
		ApexQueue usedBuckets = new ApexQueue();

		ID expectedOpenBucket = potentialBucketAccounts[0].ID;
		Decimal expectedNewSizeOfOpenBucket =  potentialBucketAccounts[0].Spots_Taken__c+1;

		Test.startTest();
			Account retAccount = BucketAssignmentModel.getOpenBucket(potentialBuckets, usedBuckets);
		Test.stopTest();

		System.assertEquals(1,potentialBuckets.size(), 'The size of potential buckets should decrease by 1 when a bucket is popped from potential buckets and pushed to usedbuckets. This happens when there are no open buckets in usedBuckets but there is an open bucket in potential buckets');
		System.assertEquals(1,usedBuckets.size(), 'The size of used buckets should increase by 1 when a bucket is popped from potential buckets and pushed to usedbuckets. This happens when there are no open buckets in usedBuckets but there is an open bucket in potential buckets');
		System.assertEquals(expectedOpenBucket, retAccount.ID, 'The open bucket must correctly identified');	
		System.assertEquals(retAccount.ID, usedBuckets.back().ID, 'The open bucket must correctly identified and pushed to the usedBuckets queue');
		System.assertEquals(expectedNewSizeOfOpenBucket,retAccount.Spots_Taken__c, 'When a contact needs to be assigned to an open bucket, the spots taken summary field must be incremented by 1 in anticipation of that assignment');
	}

	static testMethod void testGetOpenBucket_PotentialBucketHasOpenBucket_UsedBucketsOpen()
	{
		setup();

		List<Account> usedBucketsAccounts = TestUtil.createAccounts(2, false);
		usedBucketsAccounts[0].Spots_Taken__c=orgSettings.Maximum_Size_of_Bucket__c;
		usedBucketsAccounts[1].Spots_Taken__c=orgSettings.Maximum_Size_of_Bucket__c-1;

		List<Account> potentialBucketAccounts = TestUtil.createAccounts(2, false);
		potentialBucketAccounts[0].Spots_Taken__c=orgSettings.Maximum_Size_of_Bucket__c-2;
		potentialBucketAccounts[1].Spots_Taken__c=orgSettings.Maximum_Size_of_Bucket__c-1;

		ApexQueue potentialBuckets = new ApexQueue(potentialBucketAccounts.clone());
		ApexQueue usedBuckets = new ApexQueue(usedBucketsAccounts.clone());

		List<Account> allAccounts = new List<account>();
		allAccounts.addAll(usedBucketsAccounts);
		allAccounts.addAll(potentialBucketAccounts);
		insert allAccounts;

		ID expectedOpenBucket = usedBucketsAccounts[1].ID;
		Decimal expectedNewSizeOfOpenBucket =  usedBucketsAccounts[1].Spots_Taken__c+1;

		Test.startTest();
			Account retAccount = BucketAssignmentModel.getOpenBucket(potentialBuckets, usedBuckets);
		Test.stopTest();

		System.assertEquals(2,potentialBuckets.size(), 'The size of potential bucketscan never increase');
		System.assertEquals(2,usedBuckets.size(), 'The size of used buckets should not increase when there is already a used bucket that is open');
		System.assertEquals(expectedOpenBucket, retAccount.ID, 'The open bucket must correctly identified');	
		System.assertEquals(retAccount.ID, usedBuckets.back().ID, 'The open bucket must correctly identified and must remain at the back of the used buckets queue');
		System.assertEquals(expectedNewSizeOfOpenBucket,retAccount.Spots_Taken__c, 'When a contact needs to be assigned to an open bucket, the spots taken summary field must be incremented by 1 in anticipation of that assignment');
	}

	static testMethod void testQueryOpenBuckets() {
		setup();
		Integer TEST_LIMIT = 30;

		List<Account> allBuckets = new List<Account>();
		// 40 not full, 30 full, 10 null, 10 normal accounts
		List<Account> toBeReturned = new List<Account>();
		for (Integer i=0; i<40; i++) 
			toBeReturned.add(TestUtil.createBucketAccount((Integer)orgSettings.Maximum_Size_of_Bucket__c-50+i, orgSettings, false));
		List<Account> notToBeReturned = TestUtil.createBucketAccounts(TEST_LIMIT, (Integer)orgSettings.Maximum_Size_of_Bucket__c, orgSettings, false);
		notToBeReturned.addAll(TestUtil.createBucketAccounts(10, null, orgSettings, false));
		notToBeReturned.addAll(TestUtil.createAccounts(10, false));
		allBuckets.addAll(toBeReturned);
		allBuckets.addAll(notToBeReturned);
		insert allBuckets;

		Test.startTest();
			List<Account> returnedBuckets = BucketAssignmentModel.queryOpenBuckets(TEST_LIMIT);
		Test.stopTest();

		System.assertEquals(TEST_LIMIT, returnedBuckets.size(), 
			'The size of the List returned by the query was not the expected value');
		for (Integer i=0; i<30; i++) {
			System.assertEquals(toBeReturned[i].Id, returnedBuckets[i].Id, 
				'The expected bucket was not found in the right order. Query should return Bucket accounts ordered by Spots_Taken in ascending order');
		}
	}

	static testMethod void testQueryOpenBucketsNoBucketAccounts() {
		setup();
		List<Account> notToBeReturned = TestUtil.createAccounts(10, false);
		insert notToBeReturned;

		Test.startTest();
			List<Account> returnedBuckets = BucketAssignmentModel.queryOpenBuckets(30);
		Test.stopTest();

		System.assertEquals(0, returnedBuckets.size(), 
			'The size of the List returned by the query should be 0 since there are no Bucket Accounts');
	}

	static testMethod void testAssignContacts() {
		// 100 -> 180; 200 contacts; 
		// 200, 200, 80
		setup();
		orgSettings.Maximum_Size_of_Bucket__c = 200;
		update orgSettings;
		Account bucket1 = TestUtil.createBucketAccount((Integer)orgSettings.Maximum_Size_of_Bucket__c-100, orgSettings, true);
		Account bucket2 = TestUtil.createBucketAccount((Integer)orgSettings.Maximum_Size_of_Bucket__c-20, orgSettings, true);

		List<Contact> testContacts = TestUtil.createContacts(200, false);

		Test.startTest();
			BucketAssignmentModel.assignContacts(testContacts);
		Test.stopTest();

		List<Account> threeBucketAccounts = [SELECT Id, Spots_Taken__c FROM Account];
		System.assertEquals(3, threeBucketAccounts.size(), 'There should be three bucket accounts in the DB: 2 that were filled to the max and 1 created by the process');
		for (Account bk : threeBucketAccounts) {
			if (bk.Id == bucket1.Id || bk.Id == bucket2.Id)
				System.assertEquals(orgSettings.Maximum_Size_of_Bucket__c, bk.Spots_Taken__c,
					'All remaining open spots should be filled up before a new bucket is created');
			else
				System.assertEquals(80, bk.Spots_Taken__c,
					'Once the existing buckets are full, the remaining 80 contacts should be assigned to a new bucket');
		}

		Set<Id> threeBucketIds = Pluck.ids(threeBucketAccounts);
		for (Contact c : testContacts) {
			System.assert(threeBucketIds.contains(c.AccountID),
				'All contacts must be in a bucket');
		}
	}
    
    static testMethod void testHandleNewContacts() {
		// 100 -> 180; 200 contacts; 
		// 200, 200, 80
		setup();
		orgSettings.Maximum_Size_of_Bucket__c = 200;
		update orgSettings;
		Account bucket1 = TestUtil.createBucketAccount((Integer)orgSettings.Maximum_Size_of_Bucket__c-100, orgSettings, true);
		Account bucket2 = TestUtil.createBucketAccount((Integer)orgSettings.Maximum_Size_of_Bucket__c-20, orgSettings, true);

		List<Contact> testContacts = TestUtil.createContacts(200, false);

		Test.startTest();
			BucketAssignmentModel.handleNewContacts(testContacts);
		Test.stopTest();
    }
        
    static testMethod void testHandleUndeletedContacts() {
		// 100 -> 180; 200 contacts; 
		// 200, 200, 80
		setup();
		orgSettings.Maximum_Size_of_Bucket__c = 200;
		update orgSettings;
		Account bucket1 = TestUtil.createBucketAccount((Integer)orgSettings.Maximum_Size_of_Bucket__c-100, orgSettings, true);
		Account bucket2 = TestUtil.createBucketAccount((Integer)orgSettings.Maximum_Size_of_Bucket__c-20, orgSettings, true);

		List<Contact> testContacts = TestUtil.createContacts(200, false);

		Test.startTest();
			BucketAssignmentModel.handleUndeletedContacts(testContacts);
		Test.stopTest();
    }
    
    static testMethod void testAllowRetry() {
		// 100 -> 180; 200 contacts; 
		// 200, 200, 80
		setup();
		orgSettings.Maximum_Size_of_Bucket__c = 200;
		update orgSettings;
		Account bucket1 = TestUtil.createBucketAccount((Integer)orgSettings.Maximum_Size_of_Bucket__c-100, orgSettings, true);
		Account bucket2 = TestUtil.createBucketAccount((Integer)orgSettings.Maximum_Size_of_Bucket__c-20, orgSettings, true);

		List<Contact> testContacts = TestUtil.createContacts(200, false);

		Test.startTest();
			BucketAssignmentModel.allowRetry(testContacts);
		Test.stopTest();
    }
    
    static testMethod void testStampTriggerNew() {
		// 100 -> 180; 200 contacts; 
		// 200, 200, 80
		setup();
		orgSettings.Maximum_Size_of_Bucket__c = 200;
		update orgSettings;
		Account bucket1 = TestUtil.createBucketAccount((Integer)orgSettings.Maximum_Size_of_Bucket__c-100, orgSettings, true);
		Account bucket2 = TestUtil.createBucketAccount((Integer)orgSettings.Maximum_Size_of_Bucket__c-20, orgSettings, true);

		List<Contact> testContacts = TestUtil.createContacts(200, false);

		Test.startTest();
			BucketAssignmentModel.stampTriggerNew(testContacts);
		Test.stopTest();
    }
        
    static testMethod void testHandleDeletedContacts() {
		// 100 -> 180; 200 contacts; 
		// 200, 200, 80
		setup();
		orgSettings.Maximum_Size_of_Bucket__c = 200;
		update orgSettings;
		Account bucket1 = TestUtil.createBucketAccount((Integer)orgSettings.Maximum_Size_of_Bucket__c-100, orgSettings, true);
		Account bucket2 = TestUtil.createBucketAccount((Integer)orgSettings.Maximum_Size_of_Bucket__c-20, orgSettings, true);

		List<Contact> testContacts = TestUtil.createContacts(200, false);
        
        Map<ID,Contact> oldContacts = new Map<ID,Contact> ();
        
        for (Contact c : testContacts)
        {
            oldContacts.put(c.Id,c);
        }

		Test.startTest();
			BucketAssignmentModel.handleDeletedContacts(oldContacts);
		Test.stopTest();
    }
    
    static testMethod void testHandleUpdatedContacts() {
		// 100 -> 180; 200 contacts; 
		// 200, 200, 80
		setup();
		orgSettings.Maximum_Size_of_Bucket__c = 200;
		update orgSettings;
		Account bucket1 = TestUtil.createBucketAccount((Integer)orgSettings.Maximum_Size_of_Bucket__c-100, orgSettings, true);
		Account bucket2 = TestUtil.createBucketAccount((Integer)orgSettings.Maximum_Size_of_Bucket__c-20, orgSettings, true);

		List<Contact> testContacts = TestUtil.createContacts(200, false);
        
        Map<ID,Contact> oldContacts = new Map<ID,Contact> ();
        
        for (Contact c : testContacts)
        {
            oldContacts.put(c.Id,c);
        }

		Test.startTest();
			BucketAssignmentModel.handleUpdatedContacts(oldContacts,testContacts);
		Test.stopTest();
    }

	static testMethod void testAssignContactsTo200Buckets() {
		setup();
		orgSettings.Maximum_Size_of_Bucket__c = 200;
		update orgSettings;
		List<Account> testBuckets = TestUtil.createBucketAccounts(200, (Integer)orgSettings.Maximum_Size_of_Bucket__c-1, orgSettings, true);
		List<Contact> testContacts = TestUtil.createContacts(200, false);

		Test.startTest();
			BucketAssignmentModel.assignContacts(testContacts);
		Test.stopTest();

		List<Account> allBucketAccounts = [SELECT Id, Spots_Taken__c FROM Account];
		System.assertEquals(200, allBucketAccounts.size(), 'There should be only 200 bucket accounts in DB that have been incremented');
		for (Account bk : allBucketAccounts) {
			System.assertEquals(orgSettings.Maximum_Size_of_Bucket__c, bk.Spots_Taken__c,
					'All remaining open spots should be filled up before a new bucket is created');
		}
		Set<Id> allBucketIds = Pluck.ids(allBucketAccounts);
		for (Contact c : testContacts) {
			System.assert(allBucketIds.contains(c.AccountID),
				'All contacts must be in a bucket');
		}
	}

	static testMethod void testAssignContactsWithNoContacts() {
		setup();
		orgSettings.Maximum_Size_of_Bucket__c = 200;
		update orgSettings;
		List<Account> testBuckets = TestUtil.createBucketAccounts(200, (Integer)orgSettings.Maximum_Size_of_Bucket__c-1, orgSettings, true);

		Test.startTest();
			BucketAssignmentModel.assignContacts(new List<Contact>());
		Test.stopTest();

		List<Account> allBucketAccounts = [SELECT Id, Spots_Taken__c FROM Account];
		System.assertEquals(200, allBucketAccounts.size(), 'There should be no bucket accounts to update');
		for (Account bk : allBucketAccounts) {
			System.assertEquals((Integer)orgSettings.Maximum_Size_of_Bucket__c-1, bk.Spots_Taken__c,
				'No buckets should be modified');
		}
	}

	static testMethod void testUnassignContacts_EmptyList()
	{
		setup();
		final Integer originalSpotsTaken = (Integer)orgSettings.Maximum_Size_of_Bucket__c;

		UnitTest.addData(TestUtil.createBucketAccounts(50, originalSpotsTaken, orgSettings, true)).tag('Bucket Accounts');

		Test.startTest();
			BucketAssignmentModel.unassignContacts(new List<Contact>());
			System.assertEquals(0,Limits.getQueries(), 'Functionality to deassign contacts from bucket accounts should not query the database for account information when there are no contacts to deassign');
			System.assertEquals(0,Limits.getDMLStatements(), 'Functionality to deassign contacts from bucket accounts will not update the database when there are no contacts to deassign');
		Test.stopTest();
	}
	

	static testMethod void testUnassignContacts()
	{
		setup();
		final Integer originalSpotsTaken = (Integer)orgSettings.Maximum_Size_of_Bucket__c;

		List<Account> testBuckets = TestUtil.createBucketAccounts(50, originalSpotsTaken, orgSettings, true);
		UnitTest.addData(testBuckets).tag('Accounts').divide(2).part('Accounts To Decrement Group Size').part('Accounts To Remain Untouched');

		UnitTest.forEach('Accounts To Decrement Group Size').create(2, TestUtil.contacts).copyProperty('ID->AccountID').tag('Contacts To Unassign From Bucket Accounts');

		Test.startTest();
			BucketAssignmentModel.unassignContacts((List<Contact>)UnitTest.get('Contacts To Unassign From Bucket Accounts').getList());
		Test.stopTest();

		List<Account> modifiedAccounts = [Select Id, Spots_Taken__c From Account Where Spots_Taken__c!=:originalSpotsTaken];

		UnitTest.analyze('Accounts To Decrement Group Size').assertEquivalence(modifiedAccounts,'When contacts are unassigned from bucket accounts, only the bucket account must have their group sizes decremented');
		for(Account acct : modifiedAccounts)
		{
			System.assertEquals(originalSpotsTaken-2, acct.Spots_Taken__c, 'When contacts are unassigned from bucket accounts, the spots taken field on the bucket account must be correctly decremented');
		}


	}

	static testMethod void testGetPrivateContacts()
	{
		UnitTest.createTestData(TestUtil.accounts).many(10).tag('Accounts').insertAll();

		UnitTest.createTestData(TestUtil.contacts).many(200).tag('Contacts').divide(2).part('Private Contacts').part('Contacts With Accounts');
		UnitTest.get('Contacts With Accounts').property('AccountID').assignFrom('Accounts');

		UnitTest.get('Contacts').dummyInsert();

		BucketAssignmentModel bam = new BucketAssignmentModel(null,null);

		Test.startTest();
			List<Contact> results = bam.getPrivateContacts((List<Contact>) UnitTest.get('Contacts').getList());
		Test.stopTest();

		UnitTest.analyze('Private Contacts').assertEquivalence(results,'We must correctly identify which contacts need assignment to bucket accoutns');
	}

	static testMethod void testGetBucketedContacts()
	{
		setup();
		List<Account> testBucketAccounts = TestUtil.createBucketAccounts(10, 5, orgSettings, false);
		UnitTest.createTestData(TestUtil.accounts).many(10).tag('Accounts').tag('Normal Accounts').insertAll();
		UnitTest.addData(testBucketAccounts).tag('Accounts').tag('Bucket Accounts').insertAll();

		UnitTest.createTestData(TestUtil.contacts).many(200).tag('Contacts').divide(2).part('Contacts With Bucket Accounts').part('Contacts With Normal Accounts');
		UnitTest.get('Contacts With Normal Accounts').property('AccountID').assignFrom('Normal Accounts');
		UnitTest.get('Contacts With Bucket Accounts').property('AccountID').assignFrom('Bucket Accounts');

		UnitTest.get('Contacts').dummyInsert();

		BucketAssignmentModel bam = new BucketAssignmentModel(null,UnitTest.get('Contacts').getList());

		Test.startTest();
			List<Contact> results = bam.getBucketedContacts((List<Contact>) UnitTest.get('Contacts').getList());
		Test.stopTest();

		UnitTest.analyze('Contacts With Bucket Accounts').assertEquivalence(results,'We must correctly identify which contacts were/are under a bucket account');
	}

	static testMethod void testGetNormalContacts()
	{
		setup();
		List<Account> testBucketAccounts = TestUtil.createBucketAccounts(10, 5, orgSettings, false);
		UnitTest.createTestData(TestUtil.accounts).many(10).tag('Accounts').tag('Normal Accounts').insertAll();
		UnitTest.addData(testBucketAccounts).tag('Accounts').tag('Bucket Accounts').insertAll();

		UnitTest.createTestData(TestUtil.contacts).many(200).tag('Contacts').divide(3).part('Contacts With Bucket Accounts')
																					  .part('Contacts With Normal Accounts')
																					  .part('Contacts With Null Accounts');
		UnitTest.get('Contacts With Normal Accounts').property('AccountID').assignFrom('Normal Accounts');
		UnitTest.get('Contacts With Bucket Accounts').property('AccountID').assignFrom('Bucket Accounts');
		UnitTest.get('Contacts With Null Accounts').property('AccountID').assign(null);

		UnitTest.get('Contacts').dummyInsert();
		Map<Id, Account> mapOfAllAccounts = new Map<Id, Account>((List<Account>)UnitTest.get('Accounts').getList());
		mapOfAllAccounts.put(null, null);

		// Give access to Account's RecordTypeId of Contacts
		for (Contact c : (List<Contact>)UnitTest.get('Contacts').getList()) 
			c.putSObject('Account', mapOfAllAccounts.get(c.AccountID));

		BucketAssignmentModel bam = new BucketAssignmentModel(null,UnitTest.get('Contacts').getList());

		Test.startTest();
			List<Contact> results = bam.getNormalContacts((List<Contact>) UnitTest.get('Contacts').getList());
		Test.stopTest();

		UnitTest.analyze('Contacts With Normal Accounts').assertEquivalence(results,'We must correctly identify which contacts were/are under a normal account');
	}

	static testMethod void testGetContactsWithModifiedAccount()
	{	
		setup();
		UnitTest.createTestData(TestUtil.accounts).many(10).tag('Accounts').tag('Normal Accounts');
		UnitTest.get('Accounts').divide(2).part('Old Accounts').part('New Accounts');
		UnitTest.get('Accounts').insertAll();

		UnitTest.createTestData(TestUtil.contacts).many(200).tag('Contacts').divide(2).part('Contacts With Changed Accounts')
																					  .part('Contacts With Unchanged Accounts');
		UnitTest.get('Contacts').property('AccountID').assignFrom('Old Accounts');
		UnitTest.get('Contacts').dummyInsert();
		Map<Id, Contact> testOldMap = new Map<Id, Contact>((List<Contact>)UnitTest.get('Contacts').getList().deepClone(true));

		UnitTest.get('Contacts With Changed Accounts').property('AccountID').assignFrom('New Accounts');

		BucketAssignmentModel bam = new BucketAssignmentModel(testOldMap,null);

		Test.startTest();
			List<Contact> results = bam.getContactsWithModifiedAccount(UnitTest.get('Contacts').getList());
		Test.stopTest();

		UnitTest.analyze('Contacts With Changed Accounts').assertEquivalence(results,'We must correctly identify which contacts have modified Accounts');
	}

	static testMethod void testGetContactsPreviouslyUnderNormalAccount()
	{
		setup();
		List<Account> testBucketAccounts = TestUtil.createBucketAccounts(10, 5, orgSettings, false);
		UnitTest.addData(testBucketAccounts).tag('Accounts').tag('Bucket Accounts').insertAll();
		UnitTest.createTestData(TestUtil.accounts).many(10).tag('Accounts').tag('Normal Accounts').insertAll();

		UnitTest.createTestData(TestUtil.contacts).many(200).tag('Contacts With Changed Accounts')
															.divide(3).part('Contacts Previously Under Normal Account')
																	  .part('Contacts Previously Under Bucket Account')
																	  .part('Contacts Previously Under Null Account');
		UnitTest.get('Contacts Previously Under Normal Account').property('AccountID').assignFrom('Normal Accounts').dummyInsert();
		UnitTest.get('Contacts Previously Under Bucket Account').property('AccountID').assignFrom('Bucket Accounts').dummyInsert();
		UnitTest.get('Contacts Previously Under Null Account').dummyInsert();

		Map<Id, Contact> testOldMap = new Map<Id, Contact>((List<Contact>)UnitTest.get('Contacts With Changed Accounts').getList().deepClone(true));

		Account newAccount = TestUtil.createAccount(true);
		UnitTest.get('Contacts With Changed Accounts').property('AccountID').assign(newAccount.Id);

		BucketAssignmentModel bam = new BucketAssignmentModel(testOldMap, UnitTest.get('Contacts With Changed Accounts').getList());

		Test.startTest();
			List<Contact> results = bam.getContactsPreviouslyUnderNormalAccount(UnitTest.get('Contacts With Changed Accounts').getList());
		Test.stopTest();

		UnitTest.analyze('Contacts Previously Under Normal Account').assertEquivalence(results,
			'We must correctly identify which contacts were previously under normal Accounts so that we can either assign them to a bucket or prevent them from being assigned to a bucket account directly');
		for (Contact c : results) 
			System.assertEquals(newAccount.Id, c.AccountID, 'The function should return the updated contact that was previously under a normal account');
	}

	static testMethod void testGetContactsPreviouslyUnderBucketAccount()
	{
		setup();
		List<Account> testBucketAccounts = TestUtil.createBucketAccounts(10, 5, orgSettings, false);
		UnitTest.addData(testBucketAccounts).tag('Accounts').tag('Bucket Accounts').insertAll();
		UnitTest.createTestData(TestUtil.accounts).many(10).tag('Accounts').tag('Normal Accounts').insertAll();

		UnitTest.createTestData(TestUtil.contacts).many(200).tag('Contacts With Changed Accounts')
															.divide(3).part('Contacts Previously Under Normal Account')
																	  .part('Contacts Previously Under Bucket Account')
																	  .part('Contacts Previously Under Null Account');
		UnitTest.get('Contacts Previously Under Normal Account').property('AccountID').assignFrom('Normal Accounts').dummyInsert();
		UnitTest.get('Contacts Previously Under Bucket Account').property('AccountID').assignFrom('Bucket Accounts').dummyInsert();
		UnitTest.get('Contacts Previously Under Null Account').dummyInsert();

		Map<Id, Contact> testOldMap = new Map<Id, Contact>((List<Contact>)UnitTest.get('Contacts With Changed Accounts').getList().deepClone(true));

		Account newAccount = TestUtil.createAccount(true);
		UnitTest.get('Contacts With Changed Accounts').property('AccountID').assign(newAccount.Id);

		BucketAssignmentModel bam = new BucketAssignmentModel(testOldMap, UnitTest.get('Contacts With Changed Accounts').getList());

		Test.startTest();
			List<Contact> results = bam.getContactsPreviouslyUnderBucketAccount(UnitTest.get('Contacts With Changed Accounts').getList());
		Test.stopTest();

		UnitTest.analyze('Contacts Previously Under Bucket Account').assertEquivalence(results,
			'We must correctly identify which contacts were previously under bucket Accounts so that we can either assign them to a bucket or decrement the account that it used to be in');
		for (Contact c : results) 
			System.assertEquals(newAccount.Id, c.AccountID, 'The function should return the updated contact that was previously under a bucket account');
	}

	static testMethod void testChainedFilterTest() {
		setup();
		UnitTest.createTestData(TestUtil.accounts).many(10).tag('Accounts').tag('Normal Accounts');
		UnitTest.get('Normal Accounts').divide(2).part('Normal Account Group 1').part('Normal Account Group 2');
		List<Account> testBucketAccounts = TestUtil.createBucketAccounts(10, 5, orgSettings, false);
		UnitTest.addData(testBucketAccounts).tag('Accounts').tag('Bucket Accounts');
		UnitTest.get('Bucket Accounts').divide(2).part('Bucket Account Group 1').part('Bucket Account Group 2');
		UnitTest.get('Accounts').insertAll(); 

		UnitTest.createTestData(TestUtil.contacts).many(200).tag('All Updated Contacts')
												  .divide(2).part('Contacts With Changed Accounts')
															.part('Contacts With Unchanged Accounts');

		UnitTest.get('Contacts With Unchanged Accounts').property('LastName').assign('Smith');

		UnitTest.get('Contacts With Changed Accounts').divide(3).part('Contacts Previously Under Normal Account')
																.part('Contacts Previously Under Bucket Account')
																.part('Contacts Previously Under Null Account');
		UnitTest.get('Contacts Previously Under Normal Account').property('AccountID').assignFrom('Normal Account Group 1');
		UnitTest.get('Contacts Previously Under Bucket Account').property('AccountID').assignFrom('Bucket Account Group 1');
		UnitTest.get('Contacts Previously Under Null Account').property('AccountID').assign(null);
		UnitTest.get('All Updated Contacts').dummyInsert();

		Map<Id, Contact> testOldMap = new Map<Id, Contact>((List<Contact>)UnitTest.get('All Updated Contacts').getList().deepClone(true));

		UnitTest.get('Contacts With Unchanged Accounts').property('LastName').assign('Appleseed');

		UnitTest.get('Contacts Previously Under Normal Account').divide(3).part('Contacts Normal to Normal')
																		  .part('Contacts Normal to Bucket')
																		  .part('Contacts Normal to Null');
		UnitTest.get('Contacts Previously Under Bucket Account').divide(3).part('Contacts Bucket to Normal')
																		  .part('Contacts Bucket to Bucket')
																		  .part('Contacts Bucket to Null');
		UnitTest.get('Contacts Previously Under Null Account').divide(3).part('Contacts Null to Normal')
																		  .part('Contacts Null to Bucket')
																		  .part('Contacts Null to Null');
		UnitTest.get('Contacts Normal to Normal').tag('Now Normal');
		UnitTest.get('Contacts Normal to Bucket').tag('Now Bucket');
		UnitTest.get('Contacts Normal to Null').tag('Now Null');
		UnitTest.get('Contacts Bucket to Normal').tag('Now Normal');
		UnitTest.get('Contacts Bucket to Bucket').tag('Now Bucket');
		UnitTest.get('Contacts Bucket to Null').tag('Now Null');
		UnitTest.get('Contacts Null to Normal').tag('Now Normal');
		UnitTest.get('Contacts Null to Bucket').tag('Now Bucket');
		UnitTest.get('Contacts Null to Null').tag('Now Null');

		UnitTest.get('Now Normal').property('AccountID').assignFrom('Normal Account Group 2');
		UnitTest.get('Now Bucket').property('AccountID').assignFrom('Bucket Account Group 2');
		UnitTest.get('Now Null').property('AccountID').assign(null);

		List<Contact> newList = UnitTest.get('All Updated Contacts').getList();
		BucketAssignmentModel bam = new BucketAssignmentModel(testOldMap, newList);
		Test.startTest();
			List<Contact> normalToBucket = bam.getBucketedContacts(
												bam.getContactsPreviouslyUnderNormalAccount(
													bam.getContactsWithModifiedAccount(newList)));
			List<Contact> normalToNull   = bam.getPrivateContacts(
												bam.getContactsPreviouslyUnderNormalAccount(
													bam.getContactsWithModifiedAccount(newList)));
			List<Contact> bucketToNormal = bam.getNormalContacts(
												bam.getContactsPreviouslyUnderBucketAccount(
													bam.getContactsWithModifiedAccount(newList)));
			List<Contact> bucketToBucket = bam.getBucketedContacts(
												bam.getContactsPreviouslyUnderBucketAccount(
													bam.getContactsWithModifiedAccount(newList)));
			List<Contact> bucketToNull   = bam.getPrivateContacts(
												bam.getContactsPreviouslyUnderBucketAccount(
													bam.getContactsWithModifiedAccount(newList)));
		Test.stopTest();

		UnitTest.analyze('Contacts Normal to Bucket').assertEquivalence(normalToBucket, 
			'We must correctly identify which contacts were previously assigned to a Normal Account and now assigned to Bucket');
		UnitTest.analyze('Contacts Normal to Null').assertEquivalence(normalToNull, 
			'We must correctly identify which contacts were previously assigned to a Normal Account and now assigned to Null');
		UnitTest.analyze('Contacts Bucket to Normal').assertEquivalence(bucketToNormal, 
			'We must correctly identify which contacts were previously assigned to a Bucket Account and now assigned to Normal');
		UnitTest.analyze('Contacts Bucket to Bucket').assertEquivalence(bucketToBucket, 
			'We must correctly identify which contacts were previously assigned to a Bucket Account and now assigned to Bucket');
		UnitTest.analyze('Contacts Bucket to Null').assertEquivalence(bucketToNull, 
			'We must correctly identify which contacts were previously assigned to a Bucket Account and now assigned to Null');
	}
}