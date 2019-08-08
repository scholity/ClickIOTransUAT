@isTest
private class PHSSProgramMaterialsApexController_TEST {
	@TestSetup private static void doSetup() {
		PHSS_TestUtility.setupContent();
	}

	@isTest static void getMaterialsByProgramApex_test() {
		Test.startTest();
		List<PHSS_Material__C> results = PHSSProgramMaterialsApexController.getMaterialsByProgramApex(null, true);
		Test.stopTest();
		System.assert(results.isEmpty());
	}

	@isTest static void getProgramNameByIDApex_test() {
		Test.startTest();
		String result = PHSSProgramMaterialsApexController.getProgramNameByIDApex(null);
		Test.stopTest();
		System.assertEquals(null, result);
	}

	@isTest static void getProgramDetailsApex_test() {
		Test.startTest();
		PHSS_Program__c result = PHSSProgramMaterialsApexController.getProgramDetailsApex(null);
		Test.stopTest();
		System.assertEquals(null, result);
	}

	@isTest static void getMaterialsByCategoryTypeByProgramApex_test() {
		Test.startTest();
		List<PHSS_Material__C> results = PHSSProgramMaterialsApexController.getMaterialsByCategoryTypeByProgramApex(null, null, null);
		Test.stopTest();
		System.assert(results.isEmpty());
	}

	@isTest static void getMaterialsByTagsOrLibrary_test() {
		Test.startTest();
		List<PHSS_Material__C> results = PHSSProgramMaterialsApexController.getMaterialsByTagsOrLibrary('test', 'video, document', true);
		Test.stopTest();
		System.assert(results.isEmpty());
	}
}