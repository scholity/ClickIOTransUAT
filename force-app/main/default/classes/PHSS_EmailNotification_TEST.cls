@isTest
private class PHSS_EmailNotification_TEST {
	@isTest static void send_test() {
		Test.startTest();
		Integer emailbefore = Limits.getEmailInvocations();
		PHSS_EmailNotification.send(PHSS_EmailNotification.Type.User_Provisioning, 0, 0, 0);
		PHSS_EmailNotification.send(PHSS_EmailNotification.Type.Certification_Provisioning, 0, 0, 0);
		Integer emailAfter = Limits.getEmailInvocations();
		Test.stopTest();
		System.assertNotEquals(emailbefore, emailAfter);
	}	
}