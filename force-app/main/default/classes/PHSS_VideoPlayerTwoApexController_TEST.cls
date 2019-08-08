@isTest
private class PHSS_VideoPlayerTwoApexController_TEST {
	@isTest static void getPHSSMaterialDetails_test() {
		Test.startTest();
		List<PHSS_Material__c> results = PHSS_VideoPlayerTwoApexController.getPHSSMaterialDetails(null);
		Test.stopTest();
		System.assertEquals(0, results.size());
	}
}