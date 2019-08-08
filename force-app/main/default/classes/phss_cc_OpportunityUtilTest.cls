/**
 * Created by jbarker on 2019-06-21.
 */

@isTest
public with sharing class phss_cc_OpportunityUtilTest {


    private static Opportunity opportunity;


    private static void setup() {
        ccrz__E_AccountGroup__c grp = phss_cc_TestDataFactory.createInsertTestAccountGroup();
        Account account = phss_cc_TestDataFactory.createInsertTestAccount(grp);
        opportunity = phss_cc_TestDataFactory.createInsertTestOpportunity(account);
    }


    private static void setupOpportunityWithApprovalLevelAndStatus(String level, String status) {
        setup();
        opportunity.StageName = 'Approach';
        opportunity.Pricing_Approval_Level__c = level;
        opportunity.Approval_Status__c = status;
        update opportunity;
    }


    @isTest
    public static void testGetApprovalStateEqualsNoApprovalRequiredLevel() {
        setupOpportunityWithApprovalLevelAndStatus('No Approval Needed', 'N/A');

        Test.startTest();
        String approvalState = phss_cc_OpportunityUtil.getApprovalState(opportunity.Id);
        Test.stopTest();

        System.assertEquals(phss_cc_OpportunityUtil.NO_APPROVAL_REQUIRED_STATE, approvalState);
    }


    @isTest
    public static void testGetApprovalStateEqualsApprovedStatus() {
        setupOpportunityWithApprovalLevelAndStatus('Manager', 'Approved');

        Test.startTest();
        String approvalState = phss_cc_OpportunityUtil.getApprovalState(opportunity.Id);
        Test.stopTest();

        System.assertEquals('Approved', approvalState);
    }


    @isTest
    public static void testGetApprovalStateEqualsRequiresApprovalStatus() {
        setupOpportunityWithApprovalLevelAndStatus('Manager', 'Submit for Approval');

        Test.startTest();
        String approvalState = phss_cc_OpportunityUtil.getApprovalState(opportunity.Id);
        Test.stopTest();

        System.assertEquals('Requires approval', approvalState);
    }


    @isTest
    public static void testGetApprovalStateEqualsRejectedStatus() {
        setupOpportunityWithApprovalLevelAndStatus('Manager', 'Rejected');

        Test.startTest();
        String approvalState = phss_cc_OpportunityUtil.getApprovalState(opportunity.Id);
        Test.stopTest();

        System.assertEquals('Rejected', approvalState);
    }
}