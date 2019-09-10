@isTest
private class SDRelatedListDocumentsTest {
	@isTest(seeAllData=true)
    private static void testSDRelatedListDocuments() {
        Opportunity testOpp = [SELECT Account.Id FROM Opportunity LIMIT 1];
        Test.setCurrentPage(Page.SDRelatedListDocuments);
        ApexPages.currentPage().getParameters().put('parentId', String.valueOf(testOpp.Account.Id));
		ApexPages.currentPage().getParameters().put('childObjName', 'Opportunity');
		ApexPages.currentPage().getParameters().put('lookupFieldName', 'Account');
		ApexPages.currentPage().getParameters().put('doclist', '');
		ApexPages.currentPage().getParameters().put('sendEmail', '0');
        
        SDRelatedListDocumentsController sdrldc = new SDRelatedListDocumentsController();
        sdrldc.createSDocJobs();
        Boolean tmp = sdrldc.jobsAreCompleted;
        sdrldc.returnToParentRecord();
        sdrldc.emailDocuments();
    }
}