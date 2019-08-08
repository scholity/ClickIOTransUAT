/**
 * Created by dgajwani on 10/1/18.
 */

public with sharing class phss_cc_PurchaseOrderController {

    /**
     * @description Fetches the stored payments for the account.
     *
     * @param opportunitySfid
     *
     * @return
     */
    @AuraEnabled
    public static Map<String, Object> fetchStoredPayments(String opportunitySfid){
        Map<String, Object> fetchStoredPaymentsResponse = new Map<String, Object> ();
        try {
            fetchStoredPaymentsResponse = phss_cc_StoredPaymentUtil.fetchStoredPayments(opportunitySfid);
        } catch (Exception e) {
            fetchStoredPaymentsResponse = phss_cc_Exception.getErrorMessageMap(e.getMessage());
        }
        return fetchStoredPaymentsResponse;
    }


}