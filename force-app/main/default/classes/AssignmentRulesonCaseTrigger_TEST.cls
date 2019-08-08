@isTest
private class AssignmentRulesonCaseTrigger_TEST {
	private static final Integer NUMBER_OF_RECORDS = 200;

	@testSetup private static void setup() {
		insert PHSS_TestUtility.createCaseHistorySwitch(false);
	}

	@isTest private static void trigger_test() {
		List<Case> cases = new List<Case>();
		for(Integer i = 0; i < NUMBER_OF_RECORDS; i++) {
			cases.add(PHSS_TestUtility.createCase());
		}
		Test.startTest();
		insert cases;
		Test.stopTest();
		System.assertNotEquals(0, [SELECT Id FROM Case].size());
		System.assertNotEquals(0, [SELECT Id, SObjectType, QueueId FROM QueueSobject].size());
	}
}