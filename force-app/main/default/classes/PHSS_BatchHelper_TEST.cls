@isTest
private class PHSS_BatchHelper_TEST {
	
	@isTest static void buildCronString_test() {
		Test.startTest();
		String result1 = PHSS_BatchHelper.buildCronString();
		String result2 = PHSS_BatchHelper.buildCronString();
		Test.stopTest();
		System.assertNotEquals(null, result1);
		System.assertNotEquals(null, result2);
		System.assertEquals(result1, result2);
	}

	@isTest static void shouldBeEnqueued_test() {
		Test.startTest();
		Boolean result = PHSS_BatchHelper.shouldBeEnqueued(PHSS_BatchHelper_TEST.class.getName());
		Test.stopTest();
		System.assert(result);
	}

	@isTest static void shouldBeScheduled_test() {
		Test.startTest();
		Boolean result = PHSS_BatchHelper.shouldBeScheduled(PHSS_Utility.getRandomString(10));
		Test.stopTest();
		System.assert(result);
	}

	@isTest static void buildString_test() {
		String s1 = PHSS_Utility.getRandomString(10);
		String s2 = '';
		String s3 = PHSS_Utility.getRandomString(10);
		Test.startTest();
		String result = PHSS_BatchHelper.buildString(new Set<String>{s1, s2, s3});
		Test.stopTest();
		System.assertNotEquals('', result);
	}

	@isTest static void getDefaults_test() {
		Test.startTest();
		PHSS_Custom_Metadata__mdt result = PHSS_BatchHelper.getDefaults();
		Test.stopTest();
		System.assertNotEquals(null, result);
	}

	@isTest static void buildSchedulerName_test() {
		String name = PHSS_Utility.getRandomString(10);
		Test.startTest();
		String result = PHSS_BatchHelper.buildSchedulerName(name);
		Test.stopTest();
		System.assertNotEquals(name, result);
	}

	@isTest static void createException_test() {
		Integer index = 1;
		String uniqueId = PHSS_Utility.getRandomString(10);
		String username = PHSS_Utility.getRandomString(10);
		Test.startTest();
		PHSS_BatchHelper.DmlProvisioningException e = PHSS_BatchHelper.createException(new List<Database.Error>());
			e.setIndex(index);
			e.setUniqueId(uniqueId);
			e.setUsername(username);
		Test.stopTest();
		System.assertEquals(index, e.getIndex());
		System.assertEquals(uniqueId, e.getUniqueId());
		System.assertEquals(username, e.getUsername());
	}
}