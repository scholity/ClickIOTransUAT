@isTest
private class PHSS_ProcessUserProvisioning_BATCH_TEST {
	
	@isTest static void doContactUpsert_test() {
		List<Contact> contacts = new List<Contact>{
			new Contact(),
			new Contact()
		};
		Boolean isException = false;
		PHSS_BatchHelper.DmlProvisioningException exc = null;
		Test.startTest();
		try {
			PHSS_ProcessUserProvisioning_BATCH.doContactUpsert(contacts);
		} catch(PHSS_BatchHelper.DmlProvisioningException e) {
			isException = true;
			exc = e;
		}
		System.assert(isException);
		System.assertNotEquals(null, exc);
		System.assertNotEquals(null, exc.getIndex());
		System.assertEquals(null, exc.getUniqueId());
		System.assertEquals(null, exc.getUserName());
	}

	@isTest static void doUserUpdate_test() {
		List<User> users = new List<User>{
			new User(),
			new User()
		};
		Boolean isException = false;
		PHSS_BatchHelper.DmlProvisioningException exc = null;
		Test.startTest();
		try {
			PHSS_ProcessUserProvisioning_BATCH.doUserUpdate(users);
		} catch(PHSS_BatchHelper.DmlProvisioningException e) {
			isException = true;
			exc = e;
		}
		System.assert(isException);
		System.assertNotEquals(null, exc);
		System.assertNotEquals(null, exc.getIndex());
		System.assertEquals(null, exc.getUniqueId());
		System.assertEquals(null, exc.getUserName());
	}

	@isTest static void doUserInsert_test() {
		List<User> users = new List<User>{
			new User(),
			new User()
		};
		Boolean isException = false;
		PHSS_BatchHelper.DmlProvisioningException exc = null;
		Test.startTest();
		try {
			PHSS_ProcessUserProvisioning_BATCH.doUserInsert(users);
		} catch(PHSS_BatchHelper.DmlProvisioningException e) {
			isException = true;
			exc = e;
		}
		System.assert(isException);
		System.assertNotEquals(null, exc);
		System.assertNotEquals(null, exc.getIndex());
		System.assertEquals(null, exc.getUniqueId());
		System.assertEquals(null, exc.getUserName());
	}

	private static void doSetup(){
		insert PHSS_TestUtility.createTriggerSettings();
		insert PHSS_TestUtility.createBucketAccountSettings(UserInfo.getUserId(), PHSS_TestUtility.getRecordType(PHSS_TestUtility.BUCKET_ACCOUNT_SETTINGS_RECORD_TYPE_NAME).Id);
		PHSS_Custom_Metadata__mdt defaults = PHSS_TestUtility.getCustomMetadata();
		insert PHSS_TestUtility.createGroup(defaults.Marked_As_Resource_Group_Name__c);
		Profile prof = PHSS_TestUtility.getProfile(defaults.ProfileName__c);
		Account acc = PHSS_TestUtility.createAccount();
		insert acc;
		Contact con = PHSS_TestUtility.createContact(acc.Id);
		Contact conWithoutUser = PHSS_TestUtility.createContact(acc.Id);
		insert new List<Contact>{con, conWithoutUser};
	}

	@isTest private static void schedule_test() {
		PHSS_ProcessUserProvisioning_BATCH_TEST.doSetup();
		Test.startTest();
		PHSS_ProcessUserProvisioning_BATCH.schedule();
		Test.stopTest();
	}
}