/**
 * Created by dgajwani on 9/24/18.
 */

public with sharing class phss_cc_CartUtil {


    private static final String CART_ITEM_QUANTITY_KEY = 'quantity';
    private static final String CART_ITEM_PRICE_KEY = 'price';
    private static final String CART_ITEM_TYPE = 'cartItemType';
    private static final String CART_ITEM_TYPE_MAJOR = 'Major';
    private static final String CART_ITEM_TYPE_MINOR = 'Minor';
    private static final String CART_ITEM_SFID_KEY = 'sfid';
    private static final String CART_ITEM_SUB_AMOUNT_KEY = 'subAmount';
    private static final String CART_ITEM_PRICING_TYPE = 'pricingType';
    private static final String CART_ITEM_PRODUCT_SFID_KEY = 'product';
    private static final String CART_ITEM_PRODUCT_TYPE_KEY = 'productType';
    private static final String CART_ITEM_PRODUCT_TYPE_KIT = 'Kit';
    private static final String CART_ITEM_PARENT_CART_ITEM_KEY = 'parentCartItem';
    private static final String CART_ITEM_ORIGINAL_ITEM_PRICE_KEY = 'originalItemPrice';
    private static final String CART_ITEM_PERCENT_DISCOUNT_KEY = 'percentDiscount';

    private static final String CART_ITEMS_KEY = 'ECartItemsS';
    private static final String CART_TOTAL_AMOUNT_KEY = 'totalAmount';
    private static final String PRODUCT_PRICE_KEY = 'price';
    private static final String MINOR_PRODUCT_QUANTITY_MAP_KEY = 'minorProductQuantityMap';
    private static final String MINOR_PRODUCT_LIST_KEY = 'minorProductList';
    private static final String ADDRESS_TYPE_BILLING = 'Billing';
    private static final String ADDRESS_TYPE_SHIPPING = 'Shipping';
    private static final String ADDRESS_TYPE_KEY = 'AddressType';

    @TestVisible private static final String CART_ENCRYPTED_ID_KEY = 'encryptedCartId';
    @TestVisible private static final String PRODUCT_LIST_KEY = 'productList';
    @TestVisible private static final String PRODUCT_MAP_KEY = 'productMap';
    @TestVisible private static final String PRODUCT_QUANTITY_MAP_KEY = 'productQuantityMap';
    @TestVisible private static final String CART_TOTAL_KEY = 'CartTotal';
    @TestVisible private static final String ADDRESS_LIST = 'AddressList';
    @TestVisible private static final String ADDRESS_MAP = 'AddressMap';
    @TestVisible private static final String SUCCESS_KEY = 'Success';

    private static final String FAILED_TO_CREATE_LINE_ITEMS = 'Failed to create line items.';
    private static final String FAILED_TO_ADD_ITEMS_TO_CART = 'Failed to add items to the cart.';
    private static final String FAILED_TO_CREATE_CART = 'Failed to create a Cart.';
    private static final String FAILED_TO_CREATE_PRODUCT_QUANTITY_MAP = 'Failed to create Product Quantities Map.';
    private static final String FAILED_TO_CREATE_MINOR_PRODUCT_QUANTITY_MAP = 'Failed to create minor Product Quantities Map.';
    private static final String FAILED_TO_FETCH_CART = 'Failed to fetch cart.';
    private static final String FAILED_TO_FETCH_THE_ACTIVE_CART = 'Failed to fetch the active cart.';
    private static final String FAILED_TO_FETCH_PRICE_FROM_CART = 'Failed to fetch price from cart.';
    private static final String FAILED_TO_PARSE_DETAILS_FROM_CART = 'Failed to parse details from Cart.';
    private static final String FAILED_TO_SET_THE_ADDRESS_ON_THE_CART = 'Failed to set the address on the cart.';
    private static final String FAILED_TO_FETCH_THE_CURRENT_ADDRESSES_FROM_THE_CART = 'Failed to fetch the current addresses from the cart.';
    private static final String FAILED_TO_SET_THE_BILLING_ADDRESS_ON_THE_CART = 'Failed to set the Billing Address on the cart.';


    /**
     * @description Creates line items from the productQuanityMap
     * @param productQuantityMap
     * @return
     */
    private static List<Map<String, Object>> createLineItems(Map<String, Object> productQuantityMap) {
        try {
            List<Map<String, Object>> lineData = new List<Map<String, Object>>();

            for (String sfid : productQuantityMap.keySet()) {
                Map<String, Object> lineDataItem = new Map<String, Object>();

                if (Integer.valueOf(productQuantityMap.get(sfid)) > 0) {
                    lineDataItem.put(ccrz.ccApiCart.LINE_DATA_QUANTITY, Integer.valueOf(productQuantityMap.get(sfid)));
                    lineDataItem.put(ccrz.ccApiCart.LINE_DATA_PRODUCT_SFID, sfid);
                    lineData.add(lineDataItem);
                }
            }
            return lineData;
        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_CREATE_LINE_ITEMS);
        }
    }

    /**
     * @description Fetches the relevant cart using the encrypted cart Id.
     *
     * @return
     */
    public static Map<String, Object> cartFetch(String encryptedCartId, Boolean ccApiSizeSkip) {
        Map<String, Object> cartFetchResponse;
        try {
            Map<String, Object> cartFetchRequest = new Map<String, Object>{
                    ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
                    ccrz.ccAPICart.CART_ENCID => encryptedCartId,
                    ccrz.ccApi.SIZING => new Map<String, Object>{
                            ccrz.ccAPICart.ENTITYNAME => new Map<String, Object>{
                                    ccrz.ccAPI.SZ_SKIPTRZ => ccApiSizeSkip,
                                    ccrz.ccAPI.SZ_DATA => ccrz.ccAPI.SZ_XL
                            }
                    }
            };
            cartFetchResponse = ccrz.ccApiCart.fetch(cartFetchRequest);
        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_FETCH_CART);
        }
        return cartFetchResponse;
    }

    /**
     * @description Creates a new cart for the opportunity.
     *
     * @return
     */
    public static String createNewCart() {
        String encryptedCartId = '';
        try {
            Map<String, Object> createCartRequest = new Map<String, Object>{
                    ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION
            };
            Map<String, Object> createCartResponse = ccrz.ccApiCart.create(createCartRequest);
            Boolean isSuccess = (Boolean) createCartResponse.get(ccrz.ccApi.SUCCESS);
            if (isSuccess) {
                encryptedCartId = (String) createCartResponse.get(ccrz.ccApiCart.CART_ENCID);

                ccrz__E_Cart__c cart = [
                        SELECT Id
                        FROM ccrz__E_Cart__c
                        WHERE ccrz__EncryptedId__c = :encryptedCartId
                ];
                cart.Opportunity__c = phss_cc_Context.currOpportunityId;
                cart.ccrz__Account__c = phss_cc_Context.currAccountId;
                upsert cart;
            }
        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_CREATE_CART);
        }
        return encryptedCartId;
    }

    /**
     * @description Adds the line data to the CC Cart. If encryptedCartId is blank, a new cart is first created.
     *
     * @param productQuantityMap
     * @param encryptedCartId
     *
     * @return
     */
    public static Map<String, Object> cartAddTo(List<Map<String, Object>> lineData, String encryptedCartId) {
        try {

            Map<String, Object> inputData = new Map<String, Object>{
                    ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
                    ccrz.ccApiCart.LINE_DATA => lineData,
                    ccrz.ccApiCart.CART_ENCID => encryptedCartId,
                    ccrz.ccAPI.SIZING => new Map<String, Object>{
                            ccrz.ccAPICart.ENTITYNAME => new Map<String, Object>{
                                    ccrz.ccAPI.SZ_REFETCH => true,
                                    ccrz.ccAPI.SZ_DATA => ccrz.ccAPI.SZ_L
                            }
                    }
            };
                System.debug('JASON: storefront=' + phss_cc_Context.STOREFRONT_NAME + '   ccrz.ccApiCart.addTo()');
            return ccrz.ccApiCart.addTo(inputData);
        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_ADD_ITEMS_TO_CART);
        }
    }

    /**
     * @description Creates a CC Cart and returns the added cart items.
     *
     * @return
     */
    public static Map<String, Object> addProductsToCart(String opportunitySfid, Map<String, Object> productQuantityMap, Boolean fetchMinorItems) {
        try {
            phss_cc_Context.setContext(opportunitySfid);
            System.debug('JASON: addProductsToCart() -- opportunitySfid=' + opportunitySfid);
            
            Map<String, Object> addProductsToCartResponse;

            String encryptedCartId;

            if (phss_cc_Context.currCart == null) {
                encryptedCartId = createNewCart();
            } else {
                // Get Active cart and clear all cart items.
                encryptedCartId = phss_cc_Context.currCart.ccrz__EncryptedId__c;
                delete [
                        SELECT Id
                        FROM ccrz__E_CartItem__c
                        WHERE ccrz__Cart__c = :phss_cc_Context.currCart.Id
                ];
            }

            List<Map<String, Object>> lineData = createLineItems(productQuantityMap);
            System.debug('JASON: lineData: ' + lineData);
            Map<String, Object> addToResult = cartAddTo(lineData, encryptedCartId);
            System.debug('JASON: addToResult: ' + addToResult);
            for (String key : addToResult.keySet()) {
                System.debug('JASON: key=' + key + ' value=' + addToResult.get(key));
            }
            addProductsToCartResponse = retrieveLineItemsAndTotalAmountFromCart(addToResult, fetchMinorItems);
            return addProductsToCartResponse;
        } catch (Exception e) {
            throw new phss_cc_Exception(e.getMessage());
        }
    }

    /**
     * @description Create a Map<String,Object> of product quanities keyed to product sfid.
     *
     * @return Map<String,Object> Containing Product SFID and associated quanity on cart.
     */
    public static Map<String, Object> getProductQuantitiesMapFromCart(Map<String, Object> currCart, Map<String, Object> majorCartItemToProductSfid, List<String> productListMajorItems, List<String> fullProductList) {
        try {
            Map<String, Object> productQuantityMap = new Map<String, Object>();

            if (currCart.containsKey(CART_ITEMS_KEY)) {
                List<Map<String, Object>> cartItems = (List<Map<String, Object>>) currCart.get(CART_ITEMS_KEY);
                for (Map<String, Object> cartItem : cartItems) {
                    String productSfid = (String) cartItem.get(CART_ITEM_PRODUCT_SFID_KEY);
                    if ((String) cartItem.get(CART_ITEM_TYPE) == CART_ITEM_TYPE_MAJOR) {
                        Decimal productQuantity = (Decimal) cartItem.get(CART_ITEM_QUANTITY_KEY);
                        productQuantityMap.put(productSfid, productQuantity);

                        String cartItemSfid = (String) cartItem.get(CART_ITEM_SFID_KEY);
                        majorCartItemToProductSfid.put(cartItemSfid, productSfid);
                        productListMajorItems.add(productSfid);
                    }
                    fullProductList.add(productSfid);
                }
            }
            return productQuantityMap;
        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_CREATE_PRODUCT_QUANTITY_MAP);
        }
    }

    /**
     * @description Create a Map<String,Object> of product quanities keyed to product sfid.
     *
     * @return Map<String,Object> Containing Product SFID and associated quanity on cart.
     */
    private static void getMinorLinesFromCart(Map<String, Object> currCart, Map<String, Object> productMap, Map<String, Object> majorCartItemToProductSfid) {
        try {
            if (currCart.containsKey(CART_ITEMS_KEY)) {
                List<Map<String, Object>> cartItems = (List<Map<String, Object>>) currCart.get(CART_ITEMS_KEY);

                for (Map<String, Object> cartItem : cartItems) {

                    if ((String) cartItem.get(CART_ITEM_TYPE) == CART_ITEM_TYPE_MINOR) {

                        // Get the product Sfid and quantity.
                        String productSfid = (String) cartItem.get(CART_ITEM_PRODUCT_SFID_KEY);
                        Decimal productQuantity = (Decimal) cartItem.get(CART_ITEM_QUANTITY_KEY);

                        // Get the parent product for the minor cart item.
                        String parentCartItemSfid = (String) cartItem.get(CART_ITEM_PARENT_CART_ITEM_KEY);
                        String majorCartItemProductSfid = (String) majorCartItemToProductSfid.get(parentCartItemSfid);

                        // Fetch the product details map from the productMap
                        Map<String, Object> productMapDetails = (Map<String, Object>) productMap.get(majorCartItemProductSfid);
                        Map<String, Object> minorProductQuantityMap;

                        // Check if the minorProductQuantityMap exists.
                        if (productMapDetails.containsKey(MINOR_PRODUCT_QUANTITY_MAP_KEY)) {
                            minorProductQuantityMap = (Map<String, Object>) productMapDetails.get(MINOR_PRODUCT_QUANTITY_MAP_KEY);
                        } else {
                            // Map does not exist, create a new map and add the item.
                            minorProductQuantityMap = new Map<String, Object>();
                        }

                        // Add the minor cart item to the minor product quantity map.
                        minorProductQuantityMap.put(productSfid, productQuantity);

                        // Update/Insert the minor product quantity map back into the productMap record.
                        productMapDetails.put(MINOR_PRODUCT_QUANTITY_MAP_KEY, minorProductQuantityMap);
                        productMapDetails.put(MINOR_PRODUCT_LIST_KEY, minorProductQuantityMap.keySet());
                        productMap.put(majorCartItemProductSfid, productMapDetails);
                    }
                }
            }
            System.debug(System.LoggingLevel.DEBUG, 'getMinorLinesFromCart:productMap: ' + JSON.serialize(productMap));
        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_CREATE_MINOR_PRODUCT_QUANTITY_MAP);
        }
    }

    /**
     * @description Updates the price in the product map to that on the cart.
     *
     * @param productMap
     */
    private static void fetchProductPriceFromCart(Map<String, Object> currCart, Map<String, Object> productMap) {
        try {

            if (currCart.containsKey(CART_ITEMS_KEY)) {
                Map<String, Decimal> majorCartItemPriceMap = new Map<String, Decimal>();
                List<Map<String, Object>> cartItems = (List<Map<String, Object>>) currCart.get(CART_ITEMS_KEY);
                for (Map<String, Object> cartItem : cartItems) {

                    if (cartItem.get(CART_ITEM_TYPE) == CART_ITEM_TYPE_MAJOR && cartItem.get(CART_ITEM_PRODUCT_TYPE_KEY) == CART_ITEM_PRODUCT_TYPE_KIT) {
                        String cartItemSfid = (String) cartItem.get(CART_ITEM_SFID_KEY);
                        majorCartItemPriceMap.put(cartItemSfid, 0);
                    }
                    else if (cartItem.get(CART_ITEM_TYPE) == CART_ITEM_TYPE_MINOR) {
                        String cartItemSfid = (String) cartItem.get(CART_ITEM_PARENT_CART_ITEM_KEY);
                        Decimal majorCartItemPrice = (Decimal) majorCartItemPriceMap.get(cartItemSfid);
                        Decimal quantity = (Decimal) cartItem.get(CART_ITEM_QUANTITY_KEY);
                        Decimal price = (Decimal) cartItem.get(CART_ITEM_PRICE_KEY);
                        if (quantity != null && price != null) {
                            majorCartItemPrice += quantity * price;
                            majorCartItemPriceMap.put(cartItemSfid, majorCartItemPrice);
                        }
                    }

                    String productSfid = (String) cartItem.get(CART_ITEM_PRODUCT_SFID_KEY);
                    Decimal productPriceOnCart = (Decimal) cartItem.get(CART_ITEM_PRICE_KEY);

                    Map<String, Object> productDetails = (Map<String, Object>) productMap.get(productSfid);

                    productDetails.put(PRODUCT_PRICE_KEY, productPriceOnCart);
                    productMap.put(productSfid, productDetails);
                }

                for (Map<String, Object> cartItem : cartItems) {
                    String cartItemSfid = (String) cartItem.get(CART_ITEM_SFID_KEY);
                    if (majorCartItemPriceMap.keySet().contains(cartItemSfid)) {
                        String productSfid = (String) cartItem.get(CART_ITEM_PRODUCT_SFID_KEY);
                        Map<String, Object> product = (Map<String, Object>) productMap.get(productSfid);
                        Decimal price = (Decimal) majorCartItemPriceMap.get(cartItemSfid);
                        product.put(PRODUCT_PRICE_KEY, price);
                    }
                }
            }
        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_FETCH_PRICE_FROM_CART);
        }
    }

    /**
     * @description Parses the ccApiCart response.
     *
     * @param cartDetails
     * @param isCart
     *
     * @return
     */
    public static Map<String, Object> retrieveLineItemsAndTotalAmountFromCart(Map<String, Object> cartDetails, Boolean fetchMinorItems) {
        try {
            Decimal cartTotal = 0.00;
            Map<String, Object> productMap = new Map<String, Object>();
            List<String> productListMajorItems = new List<String>();
            List<String> fullProductList = new List<String>();
            Map<String, Object> majorCartItemToProductSfid = new Map<String, Object>();
            Map<String, Object> productQuantityMapFromCart = new Map<String, Object>();

            if (cartDetails.get(ccrz.ccAPICart.CART_OBJLIST) != null) {
                List<Map<String, Object>> returnedCart = (List<Map<String, Object>>) cartDetails.get(ccrz.ccAPICart.CART_OBJLIST);
                Map<String, Object> currCart = (Map<String, Object>) returnedCart[0];
                if (currCart != null) {
                    cartTotal = (Decimal) currCart.get(CART_TOTAL_AMOUNT_KEY);
                    productQuantityMapFromCart = getProductQuantitiesMapFromCart(currCart, majorCartItemToProductSfid, productListMajorItems, fullProductList);
                    productMap = phss_cc_ProductUtil.getProductDetailsKeyedToSfidMap(new Set<String>(fullProductList));
                    addCartItemDetailsToProductMap(currCart, productMap);

                    if (fetchMinorItems) {
                        getMinorLinesFromCart(currCart, productMap, majorCartItemToProductSfid);
                        fetchProductPriceFromCart(currCart, productMap);
                    }
                }

            }
            return new Map<String, Object>{
                    CART_ENCRYPTED_ID_KEY => phss_cc_Context.currCart.ccrz__EncryptedId__c,
                    CART_TOTAL_KEY => cartTotal,
                    PRODUCT_LIST_KEY => productListMajorItems,
                    PRODUCT_QUANTITY_MAP_KEY => productQuantityMapFromCart,
                    PRODUCT_MAP_KEY => productMap
            };
        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_PARSE_DETAILS_FROM_CART);
        }

    }

    /**
     * @description Fetches and returns the cart details for the opportunity.
     *
     * @param opportunitySfid
     *
     * @return
     */
    public static Map<String, Object> fetchActiveCart(String opportunitySfid, Boolean fetchMinorItems) {
        try {
            phss_cc_Context.setContext(opportunitySfid);
            Map<String, Object> fetchCartResponse;

            ccrz__E_Cart__c cart = phss_cc_Context.currCart;

            if (cart != null && !String.isEmpty(cart.ccrz__EncryptedId__c)) {
                String currCartEncId = cart.ccrz__EncryptedId__c;
                Map<String, Object> cartDetails = cartFetch(currCartEncId, false);
                fetchCartResponse = retrieveLineItemsAndTotalAmountFromCart(cartDetails, fetchMinorItems);
            }
            return fetchCartResponse;
        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_FETCH_THE_ACTIVE_CART);
        }
    }

    /**
     * @description Adds information about the cart item to the product map
     *
     * @param cartMap
     * @param productMap
     */
    private static void addCartItemDetailsToProductMap(Map<String, Object> cartMap, Map<String, Object> productMap) {
        if (cartMap.containsKey(CART_ITEMS_KEY)) {
            List<Map<String, Object>> cartItems = (List<Map<String, Object>>) cartMap.get(CART_ITEMS_KEY);
            for (Map<String, Object> cartItem : cartItems) {
                String productSfid = (String) cartItem.get(CART_ITEM_PRODUCT_SFID_KEY);
                Map<String, Object> product = (Map<String, Object>) productMap.get(productSfid);

                String pricingType = (String) cartItem.get(CART_ITEM_PRICING_TYPE);
                if (String.isNotBlank(pricingType)) {
                    product.put(CART_ITEM_PRICING_TYPE, pricingType);
                }

                if (cartItem.get(CART_ITEM_ORIGINAL_ITEM_PRICE_KEY) != null) {
                    Decimal originalItemPrice = (Decimal) cartItem.get(CART_ITEM_ORIGINAL_ITEM_PRICE_KEY);
                    product.put(CART_ITEM_ORIGINAL_ITEM_PRICE_KEY, originalItemPrice.setScale(2));
                }

                if (cartItem.get(CART_ITEM_PERCENT_DISCOUNT_KEY) != null) {
                    Decimal percentDiscount = (Decimal) cartItem.get(CART_ITEM_PERCENT_DISCOUNT_KEY);
                    String percentage = percentDiscount.setScale(0).toPlainString() + '%';
                    product.put(CART_ITEM_PERCENT_DISCOUNT_KEY, percentage);
                }

                if (cartItem.get(CART_ITEM_QUANTITY_KEY) != null) {
                    Decimal quantity = (Decimal) cartItem.get(CART_ITEM_QUANTITY_KEY);
                    product.put(CART_ITEM_QUANTITY_KEY, quantity.setScale(0));
                }

                if (cartItem.get(CART_ITEM_SUB_AMOUNT_KEY) != null) {
                    Decimal subAmount = (Decimal) cartItem.get(CART_ITEM_SUB_AMOUNT_KEY);
                    product.put(CART_ITEM_SUB_AMOUNT_KEY, subAmount.setScale(2));
                }
            }
        }
    }

    /**
     * @description Sets the Bill-To on the cart to a clone of the Billing Address on the account.
     *
     * @param opportunitySfid
     *
     * @return
     */
    public static void addBillingAddressToCart() {
        try {
            ccrz__E_Cart__c currCart = phss_cc_Context.currCart;

            Account currAccount = [
                    SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode
                    FROM Account
                    WHERE Id = :phss_cc_Context.currAccountId
            ];

            // Clone Address
            ccrz__E_ContactAddr__c addressClone = new ccrz__E_ContactAddr__c();
            addressClone.ccrz__FirstName__c = currAccount.Name;
            addressClone.ccrz__AddressFirstline__c = currAccount.BillingStreet;
            addressClone.ccrz__City__c = currAccount.BillingCity;
            addressClone.ccrz__State__c = currAccount.BillingState;
            addressClone.ccrz__Country__c = currAccount.BillingCountry;
            addressClone.ccrz__PostalCode__c = currAccount.BillingPostalCode;
            insert addressClone;


            currCart.ccrz__BillTo__c = addressClone.Id;
            upsert currCart;
        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_SET_THE_BILLING_ADDRESS_ON_THE_CART);
        }
    }

    /**
     * @description Sets the Bill-To/Ship-To Address on the cart to a clone of the selected CC Contact Address.
     *
     * @param opportunitySfid
     *
     * @return
     */
    public static Map<String, Object> addAddressToCart(String opportunitySfid, String addressType, String selectedContactAddressSfid) {
        Boolean success = false;
        try {
            phss_cc_Context.setContext(opportunitySfid);
            ccrz__E_Cart__c currCart = phss_cc_Context.currCart;

            ccrz__E_ContactAddr__c originalAddress = [
                    SELECT Id,
                            ccrz__AddressFirstline__c,
                            ccrz__AddressSecondline__c,
                            ccrz__AddressThirdline__c,
                            ccrz__City__c,
                            ccrz__CompanyName__c,
                            ccrz__Country__c,
                            ccrz__CountryISOCode__c,
                            ccrz__FirstName__c,
                            ccrz__LastName__c,
                            ccrz__MiddleName__c,
                            ccrz__Partner_Id__c,
                            ccrz__PostalCode__c,
                            ccrz__State__c,
                            ccrz__StateISOCode__c
                    FROM ccrz__E_ContactAddr__c
                    WHERE Id = :selectedContactAddressSfid
                    LIMIT 1
            ];

            // Clone Address
            ccrz__E_ContactAddr__c addressClone = new ccrz__E_ContactAddr__c();
            addressClone.ccrz__FirstName__c = originalAddress.ccrz__FirstName__c;
            addressClone.ccrz__MiddleName__c = originalAddress.ccrz__MiddleName__c;
            addressClone.ccrz__LastName__c = originalAddress.ccrz__LastName__c;
            addressClone.ccrz__CompanyName__c = originalAddress.ccrz__CompanyName__c;
            addressClone.ccrz__AddressFirstline__c = originalAddress.ccrz__AddressFirstline__c;
            addressClone.ccrz__AddressSecondline__c = originalAddress.ccrz__AddressSecondline__c;
            addressClone.ccrz__AddressThirdline__c = originalAddress.ccrz__AddressThirdline__c;
            addressClone.ccrz__City__c = originalAddress.ccrz__City__c;
            addressClone.ccrz__State__c = originalAddress.ccrz__State__c;
            addressClone.ccrz__StateISOCode__c = originalAddress.ccrz__StateISOCode__c;
            addressClone.ccrz__Country__c = originalAddress.ccrz__Country__c;
            addressClone.ccrz__CountryISOCode__c = originalAddress.ccrz__CountryISOCode__c;
            addressClone.ccrz__PostalCode__c = originalAddress.ccrz__PostalCode__c;
            addressClone.ccrz__Partner_Id__c = originalAddress.ccrz__Partner_Id__c;
            insert addressClone;

            if (addressType.equals(ADDRESS_TYPE_BILLING)) {
                currCart.ccrz__BillTo__c = addressClone.Id;
            }
            if (addressType.equals(ADDRESS_TYPE_SHIPPING)) {
                currCart.ccrz__ShipTo__c = addressClone.Id;
            }
            upsert currCart;
            success = true;
        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_SET_THE_ADDRESS_ON_THE_CART);
        }
        return new Map<String, Object>{
                SUCCESS_KEY => success
        };
    }

    /**
     * @description Gets the current Bill To and Ship To addresses on the cart.
     *
     * @param opportunitySfid
     *
     * @return
     */
    public static Map<String, Object> getCurrentAddressesFromCart(String opportunitySfid) {
        Map<String, Object> getCurrentAddressesFromCartResponse = new Map<String, Object>();
        try {
            phss_cc_Context.setContext(opportunitySfid);

            ccrz__E_Cart__c currCart = [
                    SELECT Id, ccrz__BillTo__c, ccrz__ShipTo__c
                    FROM ccrz__E_Cart__c
                    WHERE ccrz__EncryptedId__c = :phss_cc_Context.currCart.ccrz__EncryptedId__c
            ];

            if (currCart.ccrz__BillTo__c == null) {
                addBillingAddressToCart();
                currCart = [
                        SELECT Id, ccrz__BillTo__c, ccrz__ShipTo__c
                        FROM ccrz__E_Cart__c
                        WHERE ccrz__EncryptedId__c = :phss_cc_Context.currCart.ccrz__EncryptedId__c
                ];
            }

            Set<String> addressIdsToFetch = new Set<String>{currCart.ccrz__BillTo__c, currCart.ccrz__ShipTo__c};

            List<Map<String, Object>> fetchedAddresses = phss_cc_AddressBookUtil.contactAddressFetch(addressIdsToFetch);

            Map<String, Object> addressMap = phss_cc_AddressBookUtil.getAddressMapKeyedToSfidMap(fetchedAddresses);


            for (String address : addressMap.keySet()) {

                if (address == currCart.ccrz__BillTo__c) {
                    Map<String, Object> myAddress = (Map<String, Object>) addressMap.get(address);
                    myAddress.put(ADDRESS_TYPE_KEY, ADDRESS_TYPE_BILLING);
                }
                if (address == currCart.ccrz__ShipTo__c) {
                    Map<String, Object> myAddress = (Map<String, Object>) addressMap.get(address);
                    myAddress.put(ADDRESS_TYPE_KEY, ADDRESS_TYPE_SHIPPING);
                }
            }
            getCurrentAddressesFromCartResponse.put(ADDRESS_MAP, addressMap);
            getCurrentAddressesFromCartResponse.put(ADDRESS_LIST, new List<String>(addressMap.keySet()));
        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_FETCH_THE_CURRENT_ADDRESSES_FROM_THE_CART);
        }
        return getCurrentAddressesFromCartResponse;
    }
}