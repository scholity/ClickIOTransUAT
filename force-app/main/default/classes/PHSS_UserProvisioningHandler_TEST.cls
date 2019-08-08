@isTest
private class PHSS_UserProvisioningHandler_TEST {
	private static final Integer NUMBER_OF_RECORDS = 10;

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
		//User usr = PHSS_TestUtility.createUser(prof.Id, con.Id, con.SABA_Internal_ID__c, defaults);
		//insert usr;
	}


	@isTest static void afterInsert_test() {
		Profile userProfile = PHSS_TestUtility.getProfile('System Administrator');
		UserRole usrRole = PHSS_TestUtility.getRandomUserRole('Preparedness Health & Safety Services');
		User runningUser = PHSS_TestUtility.createUser(usrRole.Id, userProfile.Id);
		insert runningUser;
		System.runAs(runningUser) {
			PHSS_UserProvisioningHandler_TEST.doSetup();
			List<PHSS_User_Provisioning__c> ups = new List<PHSS_User_Provisioning__c>();
			Set<String> userSabaIds = new Set<String>();
			for(Integer i = 0; i < NUMBER_OF_RECORDS; i++){
				PHSS_User_Provisioning__c up = PHSS_TestUtility.createUserProvisioningRecord(true, false, false);
				ups.add(up);
				userSabaIds.add(up.SABA_Internal_ID__c);
			}
			//User usr = [SELECT Id, SABA_Internal_ID__c FROM User LIMIT 1];
			
			//ups.add(PHSS_TestUtility.createUserProvisioningRecord(usr.SABA_Internal_ID__c, false, true, false));
			PHSS_ProcessUserProvisioning_BATCH.clearRecords = true; // turning on cleanup
			Test.startTest();
			insert ups;
			Test.stopTest();
			//System.assertNotEquals(0, [SELECT Id FROM User WHERE IsActive = true AND SABA_Internal_ID__c IN :userSabaIds].size(), 'Some users should be created');
		}
	}

	@isTest static void cover_rest(){
		Profile userProfile = PHSS_TestUtility.getProfile('System Administrator');
		UserRole usrRole = PHSS_TestUtility.getRandomUserRole('Preparedness Health & Safety Services');
		User runningUser = PHSS_TestUtility.createUser(usrRole.Id, userProfile.Id);
		insert runningUser;

		System.runAs(runningUser) {
			PHSS_UserProvisioningHandler instance = new PHSS_UserProvisioningHandler();
			instance.beforeInsert(new List<SObject>());
			instance.beforeUpdate(new Map<Id, SObject>(), new Map<Id, SObject>());
			instance.beforeDelete(new Map<Id, SObject>());
			instance.afterUpdate(new Map<Id, SObject>(), new Map<Id, SObject>());
			instance.afterDelete(new Map<Id, SObject>());
			instance.afterUndelete(new Map<Id, SObject>());
		}
	}
}