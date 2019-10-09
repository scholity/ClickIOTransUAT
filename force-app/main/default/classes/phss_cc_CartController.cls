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
     * @description Fetches the active cart and related cart items for the opportunity
     *
     * @param opportunityId
     *
     * @return
     */
    @AuraEnabled
    public static Map<String, Object> fetchActiveCartAndItems(String opportunityId) {
        Map<String, Object> fetchCartResponse;
        try {
            fetchCartResponse = phss_cc_CartUtil.fetchActiveCartAndItems(opportunityId);
        } catch (Exception e) {
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
            Map<Id, Id> productClassIdMap = getProductClassIdMap(opportunitySfid);

            System.debug('productClassIdMap: ' + productClassIdMap);

            // Request available vouchers BEFORE creating cart line items.
            Map<String, List<Voucher__c>> voucherMap = phss_cc_VoucherUtil.requestVouchersForOpportunity(productClassIdMap, productQuantityMap, opportunitySfid);

            addToCartResult = phss_cc_CartUtil.addProductsToCart(opportunitySfid,productQuantityMap,true);

            Map<String, String> productCartItemMap = getProductCartItemMap(opportunitySfid, productClassIdMap);

            phss_cc_VoucherUtil.reserveVouchersForOpportunity(productClassIdMap, productQuantityMap, voucherMap, opportunitySfid, productCartItemMap);

        } catch (Exception e) {
            addToCartResult = phss_cc_Exception.getErrorMessageMap(e.getMessage());
        }
        return addToCartResult;
    }

    @AuraEnabled
    public static Map<String, Object> updateCartItemQuantities(String opportunityId, Map<String, Object> cartItemQuantityMap) {
        Map<String, Object> result;

        try {
            Map<Id, Id> productClassIdMap = getProductClassIdMap(opportunityId);
            Map<String, Object> productQuantityMap = buildProductQuantityMap(cartItemQuantityMap);
            Map<String, List<Voucher__c>> voucherMap = phss_cc_VoucherUtil.requestVouchersForOpportunity(productClassIdMap, productQuantityMap, opportunityId);

            result = phss_cc_CartUtil.updateCartItemQuantities(opportunityId, cartItemQuantityMap);

            Map<String, String> productCartItemMap = getProductCartItemMap(opportunityId, productClassIdMap);
            phss_cc_VoucherUtil.reserveVouchersForOpportunity(productClassIdMap, productQuantityMap, voucherMap, opportunityId, productCartItemMap);

        } catch (Exception e) {
            result = phss_cc_Exception.getErrorMessageMap(e.getMessage());
        }

        return result;
    }

    private static Map<String, Object> buildProductQuantityMap(Map<String, Object> cartItemQuantityMap) {
        Map<String, Integer> productQuantityMap = new Map<String, Integer>();
        if (cartItemQuantityMap.size() > 0) {
            List<ccrz__E_CartItem__c> cartItems = [
                    SELECT
                            Id,
                            ccrz__Product__c
                    FROM
                            ccrz__E_CartItem__c
                    WHERE
                            Id IN :cartItemQuantityMap.keySet()
            ];
            for (ccrz__E_CartItem__c cartItem : cartItems) {
                String productId = cartItem.ccrz__Product__c;
                if (String.isNotEmpty(productId)) {
                    Integer quantity = Integer.valueOf(cartItemQuantityMap.get(cartItem.Id));
                    if (productQuantityMap.containsKey(productId)) {
                        quantity += productQuantityMap.get(productId);
                    }
                    productQuantityMap.put(productId, quantity);
                }
            }
        }

        return productQuantityMap;
    }

    private static Map<String, String> getProductCartItemMap(String opportunitySfid, Map<Id, Id> productClassIdMap) {
        Map<String, String> productCartItemMap = new Map<String, String>();
        List<ccrz__E_CartItem__c> updateCartItemList = new List<ccrz__E_CartItem__c>();
        List<ccrz__E_CartItem__c> cartItemList = [
                SELECT Id, ccrz__Cart__r.Opportunity__c, ccrz__Product__c, ILT_Class__c
                FROM ccrz__E_CartItem__c
                WHERE ccrz__Cart__r.Opportunity__c = :opportunitySfid
        ];
        System.debug('cartItemList: ' + cartItemList);
        for (ccrz__E_CartItem__c theCartItem : cartItemList) {
            System.debug('cartItem: ' + theCartItem);
            Id cartItemProductId = theCartItem.ccrz__Product__c;
            if (productClassIdMap.containsKey(cartItemProductId)) {
                ccrz__E_CartItem__c updateCartItem = new ccrz__E_CartItem__c();
                updateCartItem.Id = theCartItem.Id;
                updateCartItem.ILT_Class__c = productClassIdMap.get(cartItemProductId);
                updateCartItemList.add(updateCartItem);
                productCartItemMap.put(cartItemProductId, theCartItem.Id);
            }
        }
        System.debug('updateCartItemList: ' + updateCartItemList);
        if (updateCartItemList.size() > 0) {
            upsert updateCartItemList;
        }
        return productCartItemMap;
    }

    private static Map<Id, Id> getProductClassIdMap(String opportunitySfid) {
        Map<Id, Id> productClassIdMap = new Map<Id, Id>();
        for (ccrz__E_CartItem__c theCartItem : [
                SELECT Id, ccrz__Cart__r.Opportunity__c, ccrz__Product__c, ILT_Class__c
                FROM ccrz__E_CartItem__c
                WHERE ccrz__Cart__r.Opportunity__c = :opportunitySfid
        ]) {
            if (String.isNotBlank(theCartItem.ccrz__Product__c) && String.isNotBlank(theCartItem.ILT_Class__c)) {
                productClassIdMap.put(theCartItem.ccrz__Product__c, theCartItem.ILT_Class__c);
            }
        }
        return productClassIdMap;
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
    public static Map<String, Object> placeOrderOnCartCC(String opportunitySfid, String encryptedCartId, String cyberSourceResponse, List<String> storedPayments) {
        
        Map<String, Object> placeOrderResult;
        try {
            placeOrderResult = phss_cc_OrderUtil.placeOrderOnCartCC(opportunitySfid, encryptedCartId, cyberSourceResponse, storedPayments);
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
    public static Map<String, Object> placeOrderOnCartPO(String opportunitySfid, String encryptedCartId, Map<String, Object> PODetailsMap) {
        Map<String, Object> placeOrderResult;
        try {
            placeOrderResult = phss_cc_OrderUtil.placeOrderOnCartPO(opportunitySfid, encryptedCartId, PODetailsMap);
        } catch (Exception e) {
            placeOrderResult = phss_cc_Exception.getErrorMessageMap(e.getMessage());
        }
        return placeOrderResult;
    }

    /**
     * @description Places an order using ONLY stored payments.
     *
     * @param opportunitySfid
     * @param encryptedCartId
     * @param storedPayments
     *
     * @return
     */
    @AuraEnabled
    public static Map<String, Object> placeOrderOnCartCB(String opportunitySfid, String encryptedCartId, List<String> storedPayments) {
        Map<String, Object> placeOrderResult;
        try {
            placeOrderResult = phss_cc_OrderUtil.placeOrderOnCartCB(opportunitySfid, encryptedCartId, storedPayments);
        } catch (Exception e) {
            placeOrderResult = phss_cc_Exception.getErrorMessageMap(e.getMessage());
        }
        return placeOrderResult;
    }

    @AuraEnabled
    public static Map<String, Object> fetchPaymentTabsetPermissions(String opportunityId) {
        Map<String, Object> permissionsResult;
        try {
            phss_cc_Context.setContext(opportunityId);

            Boolean isValidStatus = false;
            Boolean isValidStorefront = false;

            List<String> validPaymentStatuses = new List<String>{
                    phss_cc_AccountUtil.PAYMENT_STATUS_GRANTED,
                    phss_cc_AccountUtil.PAYMENT_STATUS_REINSTATED
            };

            Account account = phss_cc_AccountUtil.fetchAccountForOpportunity(opportunityId); 
            if (account.Preferred_Payment_type__c == 'Invoice') {
                if (account.Payment_Status__c != null && validPaymentStatuses.contains(account.Payment_Status__c)) {
                    isValidStatus = true;
                }
            }

            isValidStorefront = (phss_cc_Context.STOREFRONT_NAME != 'CPS');

            permissionsResult = new Map<String, Object>();
            permissionsResult.put('allowPaymentByInvoice', (isValidStatus && isValidStorefront));

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