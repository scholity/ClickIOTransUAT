@isTest
private class PHSS_Logger_TEST {
	private static final String MESSAGE = 'test';

	@isTest static void logErrors_test() {
		List<PHSS_Logger.Log> logs = new List<PHSS_Logger.Log>();
		Contact con = new Contact();
		Test.startTest();
		logs.add(PHSS_Logger.createLog().setMessage(PHSS_Logger_TEST.MESSAGE));
		try {
			insert con;
		} catch(Exception e) {
			logs.add(PHSS_Logger.createLog().setException(e).setRecord(con));
		}
		List<SObject> records = PHSS_Logger.logErrors(logs);
		Test.stopTest();
		List<PHSS_Error_Logger__c> errors = [SELECT Id, Message__c, Stack_Trace__c FROM PHSS_Error_Logger__c];
		System.assertEquals(2, errors.size());
		System.assertEquals(1, records.size());
	}
}