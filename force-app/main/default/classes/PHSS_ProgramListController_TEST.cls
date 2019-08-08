@isTest
private class PHSS_ProgramListController_TEST {
	private static final Integer NUMBER_OF_RECORDS = 200;

	@TestSetup private static void doSetup() {
		List<PHSS_Program__c> programs = new List<PHSS_Program__c>();
		for(Integer i = 0; i < NUMBER_OF_RECORDS; i++) {
			programs.add(PHSS_TestUtility.createProgram(true, true));
			programs.add(PHSS_TestUtility.createProgram(true, false));
			programs.add(PHSS_TestUtility.createProgram(false, true));
			programs.add(PHSS_TestUtility.createProgram(false, false));
		}
		insert programs;

	}

	@isTest private static void getAllPrograms_test() {
		Test.startTest();
		List<PHSS_Program__c> results = PHSS_ProgramListController.getAllPrograms();
		Test.stopTest();
		System.assertEquals(2 * NUMBER_OF_RECORDS, results.size());
	}

	@isTest private static void getFeaturedPrograms_test() {
		Test.startTest();
		List<PHSS_Program__c> results = PHSS_ProgramListController.getFeaturedPrograms();
		Test.stopTest();
		System.assertEquals(NUMBER_OF_RECORDS, results.size());
	}
}