/**
 * Created by jbarker on 2019-07-30.
 */

public with sharing class phss_cc_StoredPaymentUtil {

    @TestVisible private static final String STORED_PAYMENT_LIST_KEY = 'storedPaymentList';
    @TestVisible private static final String STORED_PAYMENT_MAP_KEY = 'storedPaymentMap';

    private static final String STORED_PAYMENT_SFID = 'sfid';
    private static final String STORED_PAYMENT_NAME_KEY = 'name';
    private static final String STORED_PAYMENT_ORIGINAL_PO_AMOUNT = 'originalPOAmount';
    private static final String STORED_PAYMENT_REMAINING_PO_AMOUNT = 'remainingPOAmount';
    private static final String STORED_PAYMENT_PO_START_DATE = 'poStartDate';
    private static final String STORED_PAYMENT_PO_END_DATE = 'poEndDate';
    public static final String STORED_PAYMENT_TYPE_PO = 'po';
    public static final String STORED_PAYMENT_TYPE_CB = 'cb';

    // Response map keys
    private static final String ACCOUNT_TYPE_ON_ACCOUNT_BALANCE = 'cb';


    // Error messages
    private static final String FAILED_TO_FETCH_STORED_PAYMENTS = 'Failed to fetch stored payments.';
    private static final String FAILED_TO_GET_APPLICABLE_CREDIT = 'Failed to get applicable credit.';


    /**
     * @description Retrieves the stored payments for the account.
     *
     * @param opportunitySfid
     *
     * @return
     */
    public static Map<String, Object> fetchStoredPayments(String opportunitySfid) {
        Map<String, Object> fetchStoredPaymentsResponse = new Map<String, Object>();
        try {
            phss_cc_Context.setContext(opportunitySfid);

            List<ccrz__E_StoredPayment__c> listStoredPayments = [
                    SELECT Id, ccrz__DisplayName__c, Original_PO_Amount__c, Remaining_PO_Amount__c, ccrz__StartDate__c, ccrz__EndDate__c
                    FROM ccrz__E_StoredPayment__c
                    WHERE ccrz__Enabled__c = TRUE
                    AND ccrz__AccountType__c = :STORED_PAYMENT_TYPE_PO
                    AND ccrz__Account__c = :phss_cc_Context.currAccountId
                    AND (ccrz__StartDate__c = NULL OR ccrz__StartDate__c <= :Date.today())
                    AND (ccrz__EndDate__c = NULL OR ccrz__EndDate__c >= :Date.today())
                    AND Remaining_PO_Amount__c > 0
            ];

            Map<String, Object> storedPaymentsMap = new Map<String, Object>();
            for (ccrz__E_StoredPayment__c sp : listStoredPayments) {
                Map<String, Object> mapSP = new Map<String, Object>();
                mapSP.put(STORED_PAYMENT_SFID, sp.Id);
                mapSP.put(STORED_PAYMENT_NAME_KEY, sp.ccrz__DisplayName__c);
                mapSP.put(STORED_PAYMENT_ORIGINAL_PO_AMOUNT, sp.Original_PO_Amount__c);
                mapSP.put(STORED_PAYMENT_REMAINING_PO_AMOUNT, sp.Remaining_PO_Amount__c);
                mapSP.put(STORED_PAYMENT_PO_START_DATE, sp.ccrz__StartDate__c);
                mapSP.put(STORED_PAYMENT_PO_END_DATE, sp.ccrz__EndDate__c);

                storedPaymentsMap.put(sp.Id, mapSP);
            }

            fetchStoredPaymentsResponse = new Map<String, Object>{
                    STORED_PAYMENT_LIST_KEY => storedPaymentsMap.keySet(),
                    STORED_PAYMENT_MAP_KEY => storedPaymentsMap
            };

        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_FETCH_STORED_PAYMENTS, e);
        }

        return fetchStoredPaymentsResponse;
    }

    /**
     * @description Returns a list of stored payments for the opportunity
     *
     * @param opportunitySfid
     *
     * @return
     */
    public static List<ccrz__E_StoredPayment__c> fetchOnAccountPayments(String opportunitySfid) {
        List<ccrz__E_StoredPayment__c> listStoredPayments;
        try {
            phss_cc_Context.setContext(opportunitySfid);

            listStoredPayments = [
                    SELECT Id, ccrz__DisplayName__c, Original_PO_Amount__c, Remaining_PO_Amount__c, ccrz__StartDate__c, ccrz__EndDate__c
                    FROM ccrz__E_StoredPayment__c
                    WHERE ccrz__Enabled__c = TRUE
                    AND ccrz__AccountType__c = :ACCOUNT_TYPE_ON_ACCOUNT_BALANCE
                    AND ccrz__Account__c = :phss_cc_Context.currAccountId
                    AND (ccrz__StartDate__c = NULL OR ccrz__StartDate__c <= :Date.today())
                    AND (ccrz__EndDate__c = NULL OR ccrz__EndDate__c >= :Date.today())
                    AND Remaining_PO_Amount__c > 0
            ];

        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_FETCH_STORED_PAYMENTS, e);
        }

        return listStoredPayments;
    }

    /**
     * @description Fetches the remaining amount of credit from the specified stored payments where the stored payment's remaining amount is greater than 0.
     *
     * @param storedPayments
     *
     * @return
     */
    public static List<ccrz__E_StoredPayment__c> getStoredPayments(List<String> identifiers) {
        List<ccrz__E_StoredPayment__c> storedPayments;

        try {
            if (identifiers != null && identifiers.size() > 0) {
                storedPayments = [
                        SELECT
                                Id,
                                ccrz__Account__c,
                                ccrz__ExpMonth__c,
                                ccrz__ExpYear__c,
                                ccrz__PaymentType__c,
                                ccrz__Storefront__c,
                                ccrz__Token__c,
                                Remaining_PO_Amount__c
                        FROM
                                ccrz__E_StoredPayment__c
                        WHERE
                                Id IN :identifiers
                ];
            }

        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_GET_APPLICABLE_CREDIT, e);
        }

        return storedPayments;
    }
}