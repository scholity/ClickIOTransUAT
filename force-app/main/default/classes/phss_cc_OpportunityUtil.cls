/**
 * Created by jbarker on 2019-06-21.
 */

public with sharing class phss_cc_OpportunityUtil {

    // Approval Levels
    @TestVisible private static final String NO_APPROVAL_NEEDED_LEVEL = 'No Approval Needed';

    // Approval Statuses
    @TestVisible private static final String APPROVED_STATUS = 'Approved';
    @TestVisible private static final String REJECTED_STATUS = 'Rejected';
    @TestVisible private static final String SUBMIT_FOR_APPROVAL_STATUS = 'Submit for Approval';

    // Approval States
    @TestVisible private static final String APPROVED_STATE = 'Approved';
    @TestVisible private static final String NO_APPROVAL_REQUIRED_STATE = 'No approval required';
    @TestVisible private static final String REQUIRES_APPROVAL_STATE = 'Requires approval';
    @TestVisible private static final String REJECTED_STATE = 'Rejected';

    // Error messages
    private static final String FAILED_TO_GET_APPROVAL_STATUS = 'Failed to get approval status.';


    /**
     * @description Returns an approval state for a specific opportunity
     *
     * @param opportunityId
     *
     * @return
     */
    @AuraEnabled
    public static String getApprovalState(String opportunityId) {
        String state = REQUIRES_APPROVAL_STATE;
        try {
            Opportunity opportunity = [
                    SELECT Id, Approval_Status__c, Pricing_Approval_Level__c
                    FROM Opportunity
                    WHERE Id = :opportunityId
            ];

            if (opportunity != null) {
                if (opportunity.Pricing_Approval_Level__c == NO_APPROVAL_NEEDED_LEVEL) {
                    state = NO_APPROVAL_REQUIRED_STATE;

                } else if (opportunity.Approval_Status__c == APPROVED_STATUS) {
                    state = APPROVED_STATE;

                } else if (opportunity.Approval_Status__c == SUBMIT_FOR_APPROVAL_STATUS) {
                    state = REQUIRES_APPROVAL_STATE;

                } else if (opportunity.Approval_Status__c == REJECTED_STATUS) {
                    state = REJECTED_STATE;

                }
            }

        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_GET_APPROVAL_STATUS, e);
        }

        return state;
    }
}