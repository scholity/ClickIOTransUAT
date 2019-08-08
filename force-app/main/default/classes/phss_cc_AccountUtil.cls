/**
 * Created by jbarker on 2019-04-25.
 */

public with sharing class phss_cc_AccountUtil {

    public static final String PAYMENT_STATUS_GRANTED       = 'Granted';
    public static final String PAYMENT_STATUS_REINSTATED    = 'Reinstated';
    

    private static final String FAILED_TO_FETCH_ACCOUNT = 'Failed to fetch the account.';
    private static final String FAILED_TO_FETCH_ACCOUNT_FOR_OPPORTUNITY = 'Failed to fetch the account related to the opportunity.';


    /**
     * @description Fetches the account
     *
     * @param accountId
     *
     * @return
     */
    public static Account fetchAccount(String accountId) {
        try {
            Account account = [
                    SELECT AccountNumber, Name, Id, Payment_Status__c
                    FROM Account
                    WHERE Id = :accountId
                    LIMIT 1
            ];

            return account;

        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_FETCH_ACCOUNT, e);
        }
    }

    /**
     * @description Fetches the account associated to an opportunity
     *
     * @param opportunityId
     *
     * @return
     */
    public static Account fetchAccountForOpportunity(String opportunityId) {
        try {
            Opportunity opportunity = [
                    SELECT AccountId
                    FROM Opportunity
                    WHERE Id = :opportunityId
                    LIMIT 1
            ];

            String accountId = opportunity.AccountId;
            return fetchAccount(accountId);

        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_FETCH_ACCOUNT_FOR_OPPORTUNITY, e);
        }
    }
}