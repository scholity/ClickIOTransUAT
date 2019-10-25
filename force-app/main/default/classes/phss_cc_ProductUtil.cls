/**
 * Created by dgajwani on 9/24/18.
 */

public with sharing class phss_cc_ProductUtil {
    private static final String PRODUCT_SFID_KEY = 'sfid';
    private static final String PRODUCT_SFDCNAME_KEY = 'sfdcName';
    private static final String PRODUCT_PRICE_KEY = 'price';
    private static final String PRODUCT_INVENTORY_TYPE_KEY = 'inventoryType';
    private static final String PRODUCT_COMPONENTS_KEY = 'componentProducts';
    private static final String PRODUCT_SPECS_KEY = 'productSpecsS';
    private static final String PRODUCT_SPEC_VALUE_KEY = 'specValue';
    private static final String PRODUCT_COMPONENT_ID_KEY = 'component';
    private static final String PRODUCT_RELATED_COMPONENT_KEY = 'componentR';
    private static final String PRODUCT_COMPOSITES_KEY = 'compositeProductsS';

    // Product values
    private static final String COMMUNITY_INVENTORY_TYPE = 'COMMUNITY';

    // Product Spec names and values
    public static final String CLASS_SPEC_NAME = 'Class';
    public static final String LEARN_TO_SWIM_PRODUCT_SPEC = 'LTS';
    public static final String ONLINE_SPEC_VALUE = 'ONLINE';

    private static final String FAILED_TO_PERFORM_SEARCH_REQUEST = 'Failed to perform search request.';
    private static final String FAILED_TO_GET_PRODUCT_DETAILS = 'Failed to get Product Details.';
    private static final String FAILED_TO_PERFORM_SEARCH = 'Failed to perform search.';
    private static final String FAILED_TO_PERFORM_FILTERED_PRODUCT_SEARCH = 'Failed to perform filtered product search.';
    private static final String FAILED_TO_PERFORM_SEARCH_EXCLUDING_COURSES = 'Failed to perform search excluding online community courses.';
    private static final String FAILED_TO_CREATE_A_PRODUCT_MAP = 'Failed to create a product map.';
    private static final String FAILED_TO_GET_PRODUCTS_MATCHING_SPECS = 'Failed to get products matching product specs.';
    private static final String FAILED_TO_GET_COMPONENT_AND_COMPOSITE_PRODUCTS = 'Failed to get component and composite products.';

    @TestVisible private static final String PRODUCT_LIST_KEY = 'productList';
    @TestVisible private static final String PRODUCT_MAP_KEY = 'productMap';


    /**
     * @description Performs a search to return all products matching the query string.
     *
     * @param query
     */
    public static Set<String> doSearch(String searchString) {
        Set<String> searchResults;
        System.debug('Search string sent'+searchString);
        try {
            Map<String, Object> request = new Map<String, Object>{
                    ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
                    ccrz.ccService.SEARCHSTRING => searchString
            };
            Map<String, Object> response = ccrz.ccAPIProduct.search(request);
            Boolean isSuccess = (Boolean) response.get(ccrz.ccAPI.SUCCESS);
            if (isSuccess) {
                searchResults = (Set<String>) response.get(ccrz.ccService.SEARCHRESULTS);
            }
        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_PERFORM_SEARCH_REQUEST);
        }
        System.debug('result based on search'+searchResults);
        return searchResults;
    }

    /**
     * @description Fetches and adds details of component products to the product map
     *
     * @param productMap
     */
    public static void fetchComponentProducts(Map<String, Object> productMap) {
        Set<String> componentIDs = getComponentIDs(productMap);
        List<Map<String, Object>> componentList = getProductDetails(componentIDs);

        // map component IDs to their data
        Map<String, Object> componentMap = new Map<String, Object>();
        if (componentList != null) {
            for (Map<String, Object> component : componentList) {
                String componentId = (String) component.get(PRODUCT_SFID_KEY);
                if (componentId != null) {
                    componentMap.put(componentId, component);
                }
            }
        }

        for (String productId : productMap.keySet()) {
            Map<String, Object> product = (Map<String, Object>) productMap.get(productId);
            if (product.keySet().contains(PRODUCT_COMPOSITES_KEY)) {
                List<Map<String, Object>> compositeProducts = (List<Map<String, Object>>) product.get(PRODUCT_COMPOSITES_KEY);
                for (Map<String, Object> compositeProductMap : compositeProducts) {
                    String componentId = (String) compositeProductMap.get(PRODUCT_COMPONENT_ID_KEY);
                    if (String.isNotBlank(componentId)) {
                        Map<String, Object> component = (Map<String, Object>) componentMap.get(componentId);
                        Map<String, Object> componentR = (Map<String, Object>) compositeProductMap.get(PRODUCT_RELATED_COMPONENT_KEY);
                        componentR.put(PRODUCT_SFDCNAME_KEY, component.get(PRODUCT_SFDCNAME_KEY));
                        componentR.put(PRODUCT_PRICE_KEY, component.get(PRODUCT_PRICE_KEY));
                        compositeProductMap.put(PRODUCT_RELATED_COMPONENT_KEY, componentR);
                    }
                }
            }
        }
    }

    /**
     * @description Obtains any component IDs from a product map
     *
     * @param productMap
     *
     * @return
     */
    public static Set<String> getComponentIDs(Map<String, Object> productMap) {
        Set<String> componentIDs = new Set<String>();
        if (productMap.keySet().size() > 0) {
            for (String productId : productMap.keySet()) {
                Map<String, Object> product = (Map<String, Object>) productMap.get(productId);
                if (product.keySet().contains(PRODUCT_COMPOSITES_KEY)) {
                    List<Map<String, Object>> compositeProducts = (List<Map<String, Object>>) product.get(PRODUCT_COMPOSITES_KEY);
                    for (Map<String, Object> compositeProductMap : compositeProducts) {
                        String componentId = (String) compositeProductMap.get(PRODUCT_COMPONENT_ID_KEY);
                        if (String.isNotBlank(componentId)) {
                            componentIDs.add(componentId);
                        }
                    }
                }
            }
        }
        return componentIDs;
    }

    /**
     * @description Performs a ccApiProduct.fetch on each of the product IDs to get relevant details.
     *
     * @param productSfids
     *
     * @return
     */
    public static List<Map<String, Object>> getProductDetails(Set<String> productIds) {
        List<Map<String, Object>> productDataList;
        try {
            Map<String, Object> request = new Map<String, Object>{
                    ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
                    ccrz.ccApiProduct.PARAM_INCLUDE_PRICING => true,
                    ccrz.ccAPIProduct.PRODUCTIDLIST => productIds,
                    ccrz.ccApi.SIZING => new Map<String, Object>{
                            ccrz.ccAPIProduct.ENTITYNAME => new Map<String, Object>{
                                    ccrz.ccAPI.SZ_DATA => ccrz.ccAPI.SZ_XL
                            }
                    }
            };

            Map<String, Object> response = ccrz.ccAPIProduct.fetch(request);
            Boolean isSuccess = (Boolean) response.get(ccrz.ccAPI.SUCCESS);
            if (isSuccess) {
                productDataList = (List<Map<String, Object>>) response.get(ccrz.ccAPIProduct.PRODUCTLIST);
                system.debug('productDataList***'+productDataList);
            }
        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_GET_PRODUCT_DETAILS);
        }
        return productDataList;
    }

    /**
     * @description Creates a map of SFID->ProductDetails. This is done for easy rendering in Lightning component.
     *
     * @param productData
     *
     * @return
     */
    public static Map<String, Object> getProductMapKeyedToSfidMap(List<Map<String, Object>> productData) {
        Map<String, Object> productsById;
        try {
            productsById = new Map<String, Object>();
            for (Object obj : productData) {
                Map<String, Object> currProduct = (Map<String, Object>) obj;
                String productSfid = (String) currProduct.get(PRODUCT_SFID_KEY);
                productsById.put(productSfid, currProduct);
            }
        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_CREATE_A_PRODUCT_MAP);
        }
        return productsById;
    }

    /**
     * @description Returns a Map of product Details of all products matching the query string.
     *
     * @param query
     *
     * @return
     */
    public static Map<String, Object> productSearch(String opportunitySfid,String searchString) {
        Map<String, Object> searchResponse;
        List<Map<String, Object>> productData = new List<Map<String, Object>>();
        Map<String, Object> productMap = new Map<String, Object>();

        try {
            phss_cc_Context.setContext(opportunitySfid);
            Set<String> productIds = doSearch(searchString);
            if (productIds.size() > 0) {
                productData = getProductDetails(productIds);
                if (productData!=null && !productData.isEmpty()){
                    productMap = getProductMapKeyedToSfidMap(productData);
                }
                system.debug('***productMap***'+productMap);
            }

            fetchComponentProducts(productMap);

        } catch (Exception e) {
            System.debug('Exception caught in product search: ' + e.getMessage() + ' line: ' + e.getLineNumber() + ' stack trace: ' + e.getStackTraceString());
            throw new phss_cc_Exception(FAILED_TO_PERFORM_SEARCH, e);
        }
        searchResponse = new Map<String, Object>{
                PRODUCT_LIST_KEY => productMap.keySet(),
                PRODUCT_MAP_KEY => productMap
        };
        return searchResponse;
    }

    public static Map<String, Object> filteredProductSearch(String opportunityId, String searchString, Map<String, String> filterMap) {
        try {
            Map<String, Object> productInfo = productSearch(opportunityId, searchString);
            Set<String> productList = (Set<String>) productInfo.get(PRODUCT_LIST_KEY);
            Map<String, Object> productMap = (Map<String, Object>) productInfo.get(PRODUCT_MAP_KEY);

            Set<String> filteredProductIds = productsMatchingSpecs(productList, filterMap);
            Map<String, Object> products = new Map<String, Object>();
            for (String productId : filteredProductIds) {
                Object product = productMap.get(productId);
                products.put(productId, product);
            }
            productInfo = new Map<String, Object>{
                    PRODUCT_LIST_KEY => products.keySet(),
                    PRODUCT_MAP_KEY => products
            };
            return productInfo;
        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_PERFORM_FILTERED_PRODUCT_SEARCH, e);
        }
    }

    /**
     * @description Fetches products, excluding non-online community courses
     *
     * @param opportunityId
     * @param searchString
     *
     * @return
     */
    public static Map<String, Object> productSearchExcludingNonOnlineCommCourses(String opportunityId, String searchString) {
        Map<String, Object> productMap = new Map<String, Object>();

        try {
            phss_cc_Context.setContext(opportunityId);
            Set<String> productIDs = doSearch(searchString);
            if (productIDs.size() > 0) {
                List<Map<String, Object>> productData = getProductDetails(productIDs);
                productMap = excludeNonOnlineCommunityCourses(productData);
                fetchComponentProducts(productMap);
            }

        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_PERFORM_SEARCH_EXCLUDING_COURSES, e);
        }

        Map<String, Object> searchResponse = new Map<String, Object>{
                PRODUCT_LIST_KEY => productMap.keySet(),
                PRODUCT_MAP_KEY => productMap
        };
        return searchResponse;
    }

    /**
     * @description Excludes from the list those products with an inventory type = 'COMMUNITY' and a product
     * spec = 'ONLINE'
     *
     * @param productList
     *
     * @return
     */
    public static Map<String, Object> excludeNonOnlineCommunityCourses(List<Map<String, Object>> productList) {
        Map<String, Object> productMap = new Map<String, Object>();

        for (Map<String, Object> product : productList) {
            String inventoryType = (String) product.get(PRODUCT_INVENTORY_TYPE_KEY);
            if (inventoryType == COMMUNITY_INVENTORY_TYPE) {
                List<Map<String, Object>> productSpecs = (List<Map<String, Object>>) product.get(PRODUCT_SPECS_KEY);
                if (productSpecs != null && productSpecs.size() > 0) {
                    for (Map<String, Object> productSpec : productSpecs) {
                        String specValue = (String) productSpec.get(PRODUCT_SPEC_VALUE_KEY);
                        if (specValue == ONLINE_SPEC_VALUE) {
                        	String productId = (String) product.get(PRODUCT_SFID_KEY);
                        	productMap.put(productId, product);
                            break;
                        }
                    }
                }

            } else {
                String productId = (String) product.get(PRODUCT_SFID_KEY);
                productMap.put(productId, product);
            }
        }

        return productMap;
    }

    public static Set<String> productsMatchingSpecs(Set<String> productIds, Map<String, String> filterMap) {
        try {
            String products = '(\'' + String.join(new List<String>(productIds), '\',\'') + '\')';

            String filter = '';
            for (String name : filterMap.keySet()) {
                String specName = String.escapeSingleQuotes(name);
                String specValue = String.escapeSingleQuotes(filterMap.get(name));
                filter += ' AND (ccrz__Spec__r.Name = \'' + specName + '\' AND ccrz__SpecValue__c = \'' + specValue + '\')';
            }

            String queryString = 'SELECT ccrz__Product__c FROM ccrz__E_ProductSpec__c WHERE ccrz__Product__c IN ' + products + filter;
            List<ccrz__E_ProductSpec__c> productSpecs = Database.query(queryString);
            Set<String> matchingProductIds = new Set<String>();
            for (ccrz__E_ProductSpec__c productSpec : productSpecs) {
                matchingProductIds.add(productSpec.ccrz__Product__c);
            }

            return matchingProductIds;
        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_GET_PRODUCTS_MATCHING_SPECS, e);
        }
    }

    /**
     * @description Return a map of a map of SFID->ProductDetails. This is done for easy rendering in Lightning component.
     *
     * @param productSfids
     *
     * @return
     */
    public static Map<String, Object> getProductDetailsKeyedToSfidMap(Set<String> productIds){
        Map<String, Object> productsById;
        try {
            if (productIds.size() > 0) {
                List<Map<String, Object>> productDetails = getProductDetails(productIds);
                productsById = getProductMapKeyedToSfidMap(productDetails);
            }
        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_PERFORM_SEARCH);
        }
        return productsById;
    }
}