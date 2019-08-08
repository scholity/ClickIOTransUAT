@isTest
private class PHSS_ProcessCertProvisioning_BATCH_TEST {
	private static final Integer NUMBER_OF_RECORDS = 10;

	private enum Status{
		REVOKED, EXPIRED, ACQUIRED
	}

	@TestSetup private static void doSetup(){
		PHSS_Custom_Metadata__mdt defaults = PHSS_TestUtility.getCustomMetadata();
		PHSS_TriggerSettings__c settings = PHSS_TestUtility.createTriggerSettings();
		settings.UserProvisioningDisabled__c = true;
		settings.CertificationProvisioningDisabled__c = true;
		insert settings;
		List<Group> groups = new List<Group>();
		for(PHSS_Custom_Certification_Mapping__mdt ccm: PHSS_TestUtility.getCustomCertificationMapping()){
			groups.add(PHSS_TestUtility.createGroup(ccm.Access_Level__c));
		}
		groups.add(PHSS_TestUtility.createGroup(defaults.Marked_As_Resource_Group_Name__c));
		insert groups;
	}

	@isTest static void run_test() {
		insert PHSS_TestUtility.createBucketAccountSettings(UserInfo.getUserId(), PHSS_TestUtility.getRecordType(PHSS_TestUtility.BUCKET_ACCOUNT_SETTINGS_RECORD_TYPE_NAME).Id);
		PHSS_User_Provisioning__c up = PHSS_TestUtility.createUserProvisioningRecord(true, false, false);
		List<PHSS_Certification_Provisioning__c> cps = new List<PHSS_Certification_Provisioning__c>();
		List<PHSS_Custom_Certification_Mapping__mdt> mapping = PHSS_TestUtility.getCustomCertificationMapping();
		for(Integer i = 0; i < NUMBER_OF_RECORDS; i++){
			cps.add(PHSS_TestUtility.createCertificationProvisioningRecord(up.SABA_Internal_ID__c, Status.REVOKED.name(), mapping.get(0)));
			cps.add(PHSS_TestUtility.createCertificationProvisioningRecord(up.SABA_Internal_ID__c, Status.ACQUIRED.name(), mapping.get(0)));
		}
		Test.startTest();
		PHSS_ProcessCertProvisioning_BATCH.clearRecords = true; // turning on cleanup
		insert up;
		insert cps;
		PHSS_ProcessUserProvisioning_BATCH.run();
		Test.stopTest();
	}
}