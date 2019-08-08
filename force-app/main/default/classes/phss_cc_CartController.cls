/**
 * Created by dgajwani on 9/27/18.
 */

public with sharing class phss_cc_CartController {

    /**
     * @description Fetches the active cart for the opportunity.
     *
     * @param opportunitySfid
     *
     * @return
     */
    @AuraEnabled
    public static Map<String, Object> fetchActiveCart(String opportunitySfid){
        Map<String, Object> fetchCartResponse;
        
        try{
            fetchCartResponse = phss_cc_CartUtil.fetchActiveCart(opportunitySfid,true);
        }catch (Exception e){
            fetchCartResponse = phss_cc_Exception.getErrorMessageMap(e.getMessage());
        }
        return fetchCartResponse;
    }

    /**
     * @description Adds the products to the specified cart.
     *
     * @param productQuantityMap
     * @param encryptedCartId
     *
     * @return
     */
    @AuraEnabled
    public static Map<String, Object> updateCartProducts(String opportunitySfid, Map<String, Object> productQuantityMap) {
        Map<String, Object> addToCartResult;
        try {
            addToCartResult = phss_cc_CartUtil.addProductsToCart(opportunitySfid,productQuantityMap,true);
        } catch (Exception e) {
            addToCartResult = phss_cc_Exception.getErrorMessageMap(e.getMessage());
        }
        return addToCartResult;
    }

    /**
     * @description Adds the products to the specified cart.
     *
     * @param productQuantityMap
     * @param encryptedCartId
     *
     * @return
     */
    @AuraEnabled
    public static Map<String, Object> placeOrderOnCartCC(String opportunitySfid, String encryptedCartId,String cyberSourceResponse) {
        Map<String, Object> placeOrderResult;
        try {
            placeOrderResult = phss_cc_OrderUtil.placeOrderOnCartCC(opportunitySfid,encryptedCartId,cyberSourceResponse);
        } catch (Exception e) {
            placeOrderResult = phss_cc_Exception.getErrorMessageMap(e.getMessage());
        }
        return placeOrderResult;
    }

    /**
     * @description Adds the products to the specified cart.
     *
     * @param productQuantityMap
     * @param encryptedCartId
     *
     * @return
     */
    @AuraEnabled
    public static Map<String, Object> placeOrderOnCartPO(String opportunitySfid, String encryptedCartId,Map<String, Object> PODetailsMap) {
        Map<String, Object> placeOrderResult;
        try {
            placeOrderResult = phss_cc_OrderUtil.placeOrderOnCartPO(opportunitySfid,encryptedCartId,PODetailsMap);
        } catch (Exception e) {
            placeOrderResult = phss_cc_Exception.getErrorMessageMap(e.getMessage());
        }
        return placeOrderResult;
    }
    
    /*
    //US1512 - Start 
    @AuraEnabled 
    public static Map<String, Object> placeOrderOnCartCB(String opportunitySfid, String encryptedCartId,Map<String, Object> PODetailsMap) {
        Map<String, Object> placeOrderResult;
        try {
            placeOrderResult = phss_cc_OrderUtil.placeOrderOnCartCB(opportunitySfid,encryptedCartId,PODetailsMap);
        } catch (Exception e) {
            placeOrderResult = phss_cc_Exception.getErrorMessageMap(e.getMessage());
        }
        return placeOrderResult;
    }
    */
    //US1512 - End

    @AuraEnabled
    public static Map<String, Object> fetchPaymentTabsetPermissions(String opportunityId) {
        Map<String, Object> permissionsResult;
        try {
            permissionsResult = new Map<String, Object>();

            List<String> validPaymentStatuses = new List<String>{
                    phss_cc_AccountUtil.PAYMENT_STATUS_GRANTED,
                    phss_cc_AccountUtil.PAYMENT_STATUS_REINSTATED
            };

            Account account = phss_cc_AccountUtil.fetchAccountForOpportunity(opportunityId);
            if (account.Payment_Status__c != null && validPaymentStatuses.contains(account.Payment_Status__c)) {
                permissionsResult.put('allowPaymentByInvoice', true);
            }

        } catch (Exception e) {
            permissionsResult = phss_cc_Exception.getErrorMessageMap(e.getMessage());
        }

        return permissionsResult;
    }


    @AuraEnabled
    public static Map<String, Object> getOpportunityApprovalStatus(String opportunityId) {
        try {
            String status = phss_cc_OpportunityUtil.getApprovalState(opportunityId);
            return new Map<String, Object>{ opportunityId => status };

        } catch (Exception e) {
            return phss_cc_Exception.getErrorMessageMap(e.getMessage());
        }
    }
}