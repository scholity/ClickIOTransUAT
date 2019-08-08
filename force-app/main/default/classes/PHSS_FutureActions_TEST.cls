@isTest
private class PHSS_FutureActions_TEST {
	@isTest private static void removeGroupMembership_test() {
		Test.startTest();
		PHSS_FutureActions.removeGroupMembership(null);
		Test.stopTest();
	}

	@isTest private static void deactivateUsers_test() {
		Account acc = PHSS_TestUtility.createAccount();
		insert acc;
		Test.startTest();
		PHSS_FutureActions.deactivateUsers(new Set<Id>{UserInfo.getUserId()}, new Map<Id, String>{UserInfo.getUserId() => 'test'});
		Test.stopTest();
	}
}