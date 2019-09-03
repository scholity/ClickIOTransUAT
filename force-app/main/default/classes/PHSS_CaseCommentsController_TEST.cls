@isTest
private class PHSS_CaseCommentsController_TEST {
  private static final Integer NUMBER_OF_RECORDS = 100;
  private static final Integer CHUNCK_SIZE = 10;

  @TestSetup private static void doSetup() {
    //used to bypass validation rules on case object                
    Validation_Rules__c supportConfig = new Validation_Rules__c();      
    supportConfig.Bypass_Rules__c = false;
    //supportConfig.Bypass_Custom_Validation__c = true; 
    insert supportConfig;
    insert PHSS_TestUtility.createCaseHistorySwitch(false);
    Case c = PHSS_TestUtility.createCase();
    insert c;
    List<CaseComment> caseComments = new List<CaseComment>();
    for(Integer i=0; i<NUMBER_OF_RECORDS; i++) {
      caseComments.add(PHSS_TestUtility.createCaseComment(c.Id));
    }
    insert caseComments;
  }

  private static Case getCase() {
    return [SELECT Id FROM Case LIMIT 1];
  }

  @isTest static void getCaseComments_test() {
    Id caseId = getCase().Id;
    Test.startTest();
    List<PHSS_CaseCommentsController.CaseCommentWrapper> results = PHSS_CaseCommentsController.getCaseComments(caseId, CHUNCK_SIZE);
    Test.stopTest();
    System.assertEquals(CHUNCK_SIZE, results.size());
  }

  @isTest static void getAllCaseComments_test() {
    Id caseId = getCase().Id;
    Test.startTest();
    List<PHSS_CaseCommentsController.CaseCommentWrapper> results = PHSS_CaseCommentsController.getAllCaseComments(caseId);
    Test.stopTest();
    System.assertEquals(NUMBER_OF_RECORDS, results.size());
  }

  @isTest static void deleteComment_test() {
    Id caseId = getCase().Id;
    List<PHSS_CaseCommentsController.CaseCommentWrapper> comments = PHSS_CaseCommentsController.getCaseComments(caseId, CHUNCK_SIZE);
    Test.startTest();
    Boolean result = PHSS_CaseCommentsController.deleteComment(comments.get(0).commentId);
    Test.stopTest();
    System.assert(result);
    System.assertEquals(NUMBER_OF_RECORDS - 1, PHSS_CaseCommentsController.getAllCaseComments(caseId).size());
  }

  @isTest static void updateComment_test() {
    Id caseId = getCase().Id;
    List<PHSS_CaseCommentsController.CaseCommentWrapper> comments = PHSS_CaseCommentsController.getCaseComments(caseId, CHUNCK_SIZE);
    Test.startTest();
    Boolean result = PHSS_CaseCommentsController.updateComment(comments.get(0).commentId, PHSS_Utility.getRandomString(10));
    Test.stopTest();
    System.assert(result);
  }

  @isTest static void createComment_test() {
    Id caseId = getCase().Id;
    Test.startTest();
    Boolean result = PHSS_CaseCommentsController.createComment(PHSS_Utility.getRandomString(10), caseId);
    Test.stopTest();
    System.assert(result);
    System.assertEquals(NUMBER_OF_RECORDS + 1, PHSS_CaseCommentsController.getAllCaseComments(caseId).size());
  }
}