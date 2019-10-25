/**
 * Created by dgajwani on 9/24/18.
 */

public with sharing class phss_cc_ProductListComponentController {


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
    public static Map<String, Object> searchProducts(String opportunitySfid,String searchString) {
        
        Map<String, Object> searchResult;
        try {
            searchResult = phss_cc_ProductUtil.productSearchExcludingNonOnlineCommCourses(opportunitySfid,searchString);
        
        } catch (Exception e) {
            searchResult = phss_cc_Exception.getErrorMessageMap(e.getMessage());
        }
        
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

}