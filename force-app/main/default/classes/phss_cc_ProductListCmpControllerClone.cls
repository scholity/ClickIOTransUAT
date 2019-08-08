/**
 * Created by dgajwani on 9/24/18.
 */

public with sharing class phss_cc_ProductListCmpControllerClone {


    /**
     * @description Fetches the active cart for the opportunity.
     *
     * @param opportunitySfid
     *
     * @return
     */
    @AuraEnabled
    public static Map<String, Object> fetchActiveCartOnProductSearch(String opportunitySfid){
        Map<String, Object> fetchCartResponse;
        try{
            fetchCartResponse = phss_cc_CartUtil.fetchActiveCart(opportunitySfid,false);
        }catch (Exception e){
            fetchCartResponse = phss_cc_Exception.getErrorMessageMap(e.getMessage());
        }
        return fetchCartResponse;
    }

    /**
     * @description Searches and returns products matching the searchString.
     *
     * @param searchString
     *
     * @return
     */
    @AuraEnabled
    public static Map<String, Object> searchProducts(String opportunitySfid,String searchString, String storeFrontName) {
        Map<String, Object> searchResult;
        System.debug('Searchstring valueeee'+searchString);
        System.debug('Oppid valueeee'+opportunitySfid);
        System.debug('storeFrontName valueeee'+storeFrontName);
        phss_cc_Context.STOREFRONT_NAME = storefrontName;
        System.debug('************* STOREFRONT_NAME:'+phss_cc_Context.STOREFRONT_NAME+' prior to try block');
        
        try {
            searchResult = phss_cc_ProductUtil.productSearch(opportunitySfid,searchString);
            phss_cc_Context.STOREFRONT_NAME = 'GeneralStore';            
        } catch (Exception e) {
            searchResult = phss_cc_Exception.getErrorMessageMap(e.getMessage());
            phss_cc_Context.STOREFRONT_NAME = 'GeneralStore';            
        }
        
        System.debug('************* STOREFRONT_NAME:'+phss_cc_Context.STOREFRONT_NAME+' after try block');        
        
        return searchResult;
    }

    /**
     * @description Searches and returns products matching the searchString
     *
     * @param opportunitySfid
     * @param searchString
     * @param storeFrontName
     *
     * @return
     */
    @AuraEnabled
    public static Map<String, Object> searchFilteredProducts(String opportunityId, String searchString, String storefrontName, Map<String, String> filterMap) {
        System.debug('JASON: searchFilteredProducts() opportunityId=' + opportunityId + ' searchString=' + searchString + ' storefrontName=' + storefrontName + ' filterMap=' + filterMap);

        Map<String, Object> searchResult;
        phss_cc_Context.STOREFRONT_NAME = storefrontName;

        try {
            searchResult = phss_cc_ProductUtil.filteredProductSearch(opportunityId, searchString, filterMap);
        } catch (Exception e) {
            searchResult = phss_cc_Exception.getErrorMessageMap(e.getMessage());
        }

        phss_cc_Context.STOREFRONT_NAME = 'GeneralStore';
        return searchResult;
    }

    /**
     * @description Adds the products to the specified cart. If the encrypted cart ID is null, a new cart is created.
     *
     * @param productQuantityMap
     * @param encryptedCartId
     *
     * @return
     */
    @AuraEnabled
    public static Map<String, Object> addProductsToCart(String opportunitySfid, Map<String, Object> productQuantityMap) {
        Map<String, Object> addToCartResult;
        try {
            addToCartResult = phss_cc_CartUtil.addProductsToCart(opportunitySfid,productQuantityMap,false);
        } catch (Exception e) {
            addToCartResult = phss_cc_Exception.getErrorMessageMap(e.getMessage());
        }
        return addToCartResult;
    }
    
    @AuraEnabled
    public static ccrz__E_Cart__c updateStoreFrontofCart(String opportunitySfid) {
        ccrz__E_Cart__c cart = [Select Id,Opportunity__c,Opportunity__r.Source_System__c,ccrz__Storefront__c From ccrz__E_Cart__c Where Opportunity__c = :opportunitySfid And ccrz__ActiveCart__c = true Limit 1];
        if(cart.Opportunity__c != null) {
            if(cart.Opportunity__r.Source_System__c == 'CRE' || cart.Opportunity__r.Source_System__c == 'RBC'){
                //cart.ccrz__Storefront__c = 'CREStore';
            }
            else if(cart.Opportunity__r.Source_System__c == 'CPS'){
                //cart.ccrz__Storefront__c = 'CPS';
            }
        }
        update cart;
        return cart;
    }
}