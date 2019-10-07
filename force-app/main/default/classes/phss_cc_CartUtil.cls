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

    public static final String CART_ITEM_LIST = 'cartItemList';
    public static final String CART_ITEM_MAP = 'cartItemMap';
    public static final String CART_ITEM_QUANTITY_MAP_KEY = 'cartItemQuantityMap';
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
    private static final String FAILED_TO_CREATE_LINE_ITEMS_WITH_CART_ITEM_QUANTITY_MAP = 'Failed to create line items with cart item quantity map.';
    private static final String FAILED_TO_ADD_ITEMS_TO_CART = 'Failed to add items to the cart.';
    private static final String FAILED_TO_CREATE_CART = 'Failed to create a Cart.';
    private static final String FAILED_TO_CREATE_PRODUCT_QUANTITY_MAP = 'Failed to create Product Quantities Map.';
    private static final String FAILED_TO_CREATE_MINOR_PRODUCT_QUANTITY_MAP = 'Failed to create minor Product Quantities Map.';
    private static final String FAILED_TO_FETCH_CART = 'Failed to fetch cart.';
    private static final String FAILED_TO_FETCH_CART_BY_ID = 'Failed to fetch cart by ID.';
    private static final String FAILED_TO_FETCH_THE_ACTIVE_CART = 'Failed to fetch the active cart.';
    private static final String FAILED_TO_FETCH_THE_ACTIVE_CART_ITEMS = 'Failed to fetch the active cart items.';
    private static final String FAILED_TO_FETCH_THE_ACTIVE_CART_AND_ITEMS = 'Failed to fetch the active cart and items.';
    private static final String FAILED_TO_FETCH_PRICE_FROM_CART = 'Failed to fetch price from cart.';
    private static final String FAILED_TO_PARSE_DETAILS_FROM_CART = 'Failed to parse details from Cart.';
    private static final String FAILED_TO_SET_THE_ADDRESS_ON_THE_CART = 'Failed to set the address on the cart.';
    private static final String FAILED_TO_FETCH_THE_CURRENT_ADDRESSES_FROM_THE_CART = 'Failed to fetch the current addresses from the cart.';
    private static final String FAILED_TO_SET_THE_BILLING_ADDRESS_ON_THE_CART = 'Failed to set the Billing Address on the cart.';
    private static final String FAILED_TO_UPDATE_CART_ITEM_QUANTITIES = 'Failed to update cart item quantities.';


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
       // Map<String, Object> cartFetchResponse;
       Map<String, Object> cartFetchResponse = new Map<String, Object>();
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
     * @description Fetches the first cart identified by the specified encrypted cart ID
     *
     * @param encryptedCartId
     *
     * @return
     */
    public static ccrz__E_Cart__c fetchCart(String encryptedCartId) {
        ccrz__E_Cart__c cart;

        Map<String, Object> result = phss_cc_CartUtil.cartFetch(encryptedCartId, true);
        List<ccrz__E_Cart__c> carts = (List<ccrz__E_Cart__c>) result.get(ccrz.ccApiCart.CART_OBJLIST);
        if (carts != null && carts.size() > 0) {
            cart = carts[0];
        }

        return cart;
    }

    /**
     * @description Fetches the cart identified by the specified cart ID
     *
     * @param cartId
     *
     * @return
     */
    public static ccrz__E_Cart__c fetchCartById(String cartId) {
        ccrz__E_Cart__c cart;

        if (cartId == null) {
            return null;
        }

        Id identifier = Id.valueOf(cartId);

        try {
            cart = [
                    SELECT
                            ccrz__Account__c,
                            ccrz__ActiveCart__c,
                            ccrz__AdjustmentAmount__c,
                            ccrz__AdjustmentReason__c,
                            ccrz__AnonymousId__c,
                            ccrz__BillTo__c,
                            ccrz__BuyerCompanyName__c,
                            ccrz__BuyerEmail__c,
                            ccrz__BuyerFirstName__c,
                            ccrz__BuyerLastName__c,
                            ccrz__BuyerMobilePhone__c,
                            ccrz__BuyerPhone__c,
                            ccrz__CartId__c,
                            ccrz__CartStatus__c,
                            ccrz__CartType__c,
                            ccrz__CCEmailAddress__c,
                            ccrz__Contact__c,
                            ccrz__ContractId__c,
                            ccrz__CurrencyISOCode__c,
                            ccrz__EffectiveAccountID__c,
                            ccrz__EncryptedId__c,
                            ccrz__Name__c,
                            ccrz__Note__c,
                            ccrz__PaymentMethod__c,
                            ccrz__PONumber__c,
                            ccrz__RequestDate__c,
                            ccrz__SessionId__c,
                            ccrz__ShipAmount__c,
                            ccrz__ShipComplete__c,
                            ccrz__ShipDiscountAmount__c,
                            ccrz__ShipMethod__c,
                            ccrz__ShipStructure__c,
                            ccrz__ShipTo__c,
                            ccrz__Storefront__c,
                            ccrz__SubtotalAmount__c,
                            ccrz__TaxAmount__c,
                            ccrz__TaxExemptFlag__c,
                            ccrz__TaxSubTotalAmount__c,
                            ccrz__TotalAmount__c,
                            ccrz__TotalDiscount__c,
                            ccrz__TotalQuantity__c,
                            ccrz__TotalSurcharge__c,
                            ccrz__User__c,
                            ccrz__ValidationStatus__c,
                            Highest_Cart_Discount__c,
                            Id,
                            Name,
                            Opportunity__c
                    FROM
                            ccrz__E_Cart__c
                    WHERE
                            Id = :identifier
            ];

        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_FETCH_CART_BY_ID, e);
        }

        return cart;
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
     * @description Attempts to activate the open cart, if necessary
     *
     * @param opportunityId
     *
     * @return
     */
    public static ccrz__E_Cart__c activateOpenCart(String opportunityId) {
        ccrz__E_Cart__c cart = null;

        try {
            Id id = Id.valueOf(opportunityId);
            List<ccrz__E_Cart__c> openCarts = [
                    SELECT
                            Id,
                            ccrz__Account__c,
                            ccrz__ActiveCart__c,
                            ccrz__EncryptedId__c
                    FROM
                            ccrz__E_Cart__c
                    WHERE
                            Opportunity__c = :id
                            AND ccrz__CartStatus__c = 'Open'
                    ORDER BY
                            ccrz__ActiveCart__c DESC,
                            LastModifiedDate DESC
            ];
            if (openCarts != null && openCarts.size() > 0) {
                ccrz__E_Cart__c firstCart = openCarts[0];
                if (firstCart.ccrz__ActiveCart__c == false) {
                    firstCart.ccrz__ActiveCart__c = true;
                    update firstCart;
                    cart = firstCart;
                }
            }
        } catch (Exception e) {
            // ignore exception
        }

        return cart;
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
            Map<String, Object> addToResult = cartAddTo(lineData, encryptedCartId);
            addProductsToCartResponse = retrieveLineItemsAndTotalAmountFromCart(addToResult, fetchMinorItems);
            return addProductsToCartResponse;
        } catch (Exception e) {
            throw new phss_cc_Exception(e.getMessage());
        }
    }

    /**
     * @description Updates the quantity of the cart items
     *
     * @param opportunityId
     * @param cartItemQuantityMap
     *
     * @return
     */
    public static Map<String, Object> updateCartItemQuantities(String opportunityId, Map<String, Object> cartItemQuantityMap) {
        Map<String, Object> result = new Map<String, Object>();

        try {
            phss_cc_Context.setContext(opportunityId);

            if (phss_cc_Context.currCart != null) {
                List<Map<String, Object>> lineData = createLineItemsWithCartItemQuantityMap(cartItemQuantityMap);

                if (phss_cc_Context.currCart.Id != null) {
                    delete [SELECT Id FROM ccrz__E_CartItem__c WHERE ccrz__Cart__c = :phss_cc_Context.currCart.Id];
                }

                if (lineData.size() > 0 && phss_cc_Context.currCart.ccrz__EncryptedId__c != null) {
                    Map<String, Object> cartAddToResult = cartAddTo(lineData, phss_cc_Context.currCart.ccrz__EncryptedId__c);
                    result.putAll(cartAddToResult);
                }

                Map<String, Object> fetchResult = fetchCartItems(phss_cc_Context.currCart.Id);
                result.putAll(fetchResult);
            }

        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_UPDATE_CART_ITEM_QUANTITIES);
        }

        return result;
    }

    private static List<Map<String, Object>> createLineItemsWithCartItemQuantityMap(Map<String, Object> cartItemQuantityMap) {
        List<Map<String, Object>> lineData = new List<Map<String, Object>>();

        if (cartItemQuantityMap != null && cartItemQuantityMap.size() > 0) {
            try {
                List<ccrz__E_CartItem__c> cartItems = phss_cc_CartItemUtil.getCartItems(cartItemQuantityMap.keySet());
                for (ccrz__E_CartItem__c cartItem : cartItems) {
                    if (cartItem.ccrz__cartItemType__c != 'Major') {
                        continue;
                    }

                    Integer quantity = Integer.valueOf(cartItemQuantityMap.get(cartItem.Id));
                    if (quantity == 0) {
                        continue;
                    }

                    Map<String, Object> lineDataItem = new Map<String, Object>();
                    lineDataItem.put(ccrz.ccApiCart.LINE_DATA_PRODUCT_SFID, cartItem.ccrz__Product__c);
                    lineDataItem.put(ccrz.ccApiCart.LINE_DATA_QUANTITY, quantity);
                    if (cartItem.ILT_Class__c != null) {
                        lineDataItem.put(phss_cc_ClassCartUtil.ILT_CLASS_FIELD, cartItem.ILT_Class__c);
                    }
                    lineData.add(lineDataItem);
                }

            } catch (Exception e) {
                throw new phss_cc_Exception(FAILED_TO_CREATE_LINE_ITEMS_WITH_CART_ITEM_QUANTITY_MAP, e);
            }
        }

        return lineData;
    }

    /**
     * @description Create a Map<String,Object> of product quantities keyed to product sfid.
     *
     * @return Map<String,Object> Containing Product SFID and associated quantity on cart.
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
			system.debug(fetchMinorItems+'@@@@@'+cartDetails);
            System.debug('Inside ta>>>');
            Decimal cartTotal = 0.00;
            Map<String, Object> productMap = new Map<String, Object>();
            List<String> productListMajorItems = new List<String>();
            List<String> fullProductList = new List<String>();
            Map<String, Object> majorCartItemToProductSfid = new Map<String, Object>();
            Map<String, Object> productQuantityMapFromCart = new Map<String, Object>();

            if (cartDetails.get(ccrz.ccAPICart.CART_OBJLIST) != null) {
                System.debug('CART_OBJLIST not null');
                List<Map<String, Object>> returnedCart = (List<Map<String, Object>>) cartDetails.get(ccrz.ccAPICart.CART_OBJLIST);
                Map<String, Object> currCart = (Map<String, Object>) returnedCart[0];
                if (currCart != null) {
                    System.debug('Cart not null');
                    cartTotal = (Decimal) currCart.get(CART_TOTAL_AMOUNT_KEY);
                    productQuantityMapFromCart = getProductQuantitiesMapFromCart(currCart, majorCartItemToProductSfid, productListMajorItems, fullProductList);
                    productMap = phss_cc_ProductUtil.getProductDetailsKeyedToSfidMap(new Set<String>(fullProductList));
                    addCartItemDetailsToProductMap(currCart, productMap);
					System.debug('addcartitemdetailstoproductmap>>'+productMap+cartTotal+productQuantityMapFromCart);
                    if (fetchMinorItems) {
                        System.debug('Inside fetch minor items');
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

                Map<String, Object> cartItems = fetchCartItems(phss_cc_Context.currCart.Id);
                if (cartItems != null && cartItems.size() > 0) {
                    fetchCartResponse.putAll(cartItems);
                }
            }
            return fetchCartResponse;
        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_FETCH_THE_ACTIVE_CART);
        }
    }

    /**
     * @description
     *
     * @param opportunityId
     *
     * @return
     */
    public static Map<String, Object> fetchActiveCartAndItems(String opportunityId) {
        Map<String, Object> response;

        try {
            phss_cc_Context.setContext(opportunityId);

            if (phss_cc_Context.currCart != null && String.isNotEmpty(phss_cc_Context.currCart.Id)) {
                ccrz__E_Cart__c cart = fetchCartById(phss_cc_Context.currCart.Id);
                response = fetchCartItems(cart.Id);
                response.put(CART_TOTAL_KEY, cart.ccrz__TotalAmount__c);
                response.put(CART_ENCRYPTED_ID_KEY, cart.ccrz__EncryptedId__c);
            }

        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_FETCH_THE_ACTIVE_CART_AND_ITEMS, e);
        }

        return response;
    }

    /**
     * @description Fetches the cart items from the active cart associated with the specified opportunity
     *
     * @param opportunityId
     *
     * @return
     */
    public static Map<String, Object> fetchCartItems(String cartId) {

        Map<String, Object> cartItemMap = new Map<String, Object>();
        Map<String, Decimal> cartItemQtyMap = new Map<String, Decimal>();

        try {
            if (String.isNotEmpty(cartId)) {
                List<ccrz__E_CartItem__c> cartItems = [
                        SELECT
                                Id,
                                ccrz__ItemTotal__c,
                                ccrz__OriginalItemPrice__c,
                                ccrz__OriginalQuantity__c,
                                ccrz__ParentCartItem__c,
                                ccrz__PercentDiscount__c,
                                ccrz__Price__c,
                                ccrz__PricingType__c,
                                ccrz__Product__c,
                                ccrz__Product__r.Name,
                                ccrz__Product__r.ccrz__SKU__c,
                                ccrz__ProductType__c,
                                ccrz__Quantity__c,
                                ccrz__SubAmount__c,
                                ccrz__UnitOfMeasure__c,
                                Coupon__c,
                                ILT_Class__c
                        FROM
                                ccrz__E_CartItem__c
                        WHERE
                                ccrz__Cart__c = :cartId
                        ORDER BY
                                ccrz__ParentCartItem__c NULLS FIRST,
                                Id
                ];
                if (cartItems != null) {
                    for (ccrz__E_CartItem__c cartItem : cartItems) {
                        if (cartItem.ccrz__ParentCartItem__c != null) {
                            Map<String, Object> parentCartItem = (Map<String, Object>) cartItemMap.get(cartItem.ccrz__ParentCartItem__c);
                            if (parentCartItem != null) {
                                Map<String, Object> minorCartItems = (Map<String, Object>) parentCartItem.get(CART_ITEM_MAP);
                                if (minorCartItems == null) {
                                    minorCartItems = new Map<String, Object>();
                                    parentCartItem.put(CART_ITEM_MAP, minorCartItems);
                                }
                                
                                Map<String, Object> itemMap = new Map<String, Object>(cartItem.getPopulatedFieldsAsMap());
                                minorCartItems.put(cartItem.Id, itemMap);
                                parentCartItem.put(CART_ITEM_LIST, minorCartItems.keySet());
                            }

                        } else {
                            Map<String, Object> itemMap = new Map<String, Object>(cartItem.getPopulatedFieldsAsMap());
                            cartItemMap.put(cartItem.Id, itemMap);
                        }

                        cartItemQtyMap.put(cartItem.Id, cartItem.ccrz__Quantity__c);
                    }
                }
            }

        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_FETCH_THE_ACTIVE_CART_ITEMS, e);
        }

        Map<String, Object> m = new Map<String, Object>{
                CART_ITEM_LIST => cartItemMap.keySet(),
                CART_ITEM_MAP => cartItemMap,
                CART_ITEM_QUANTITY_MAP_KEY => cartItemQtyMap
        };
        return m;
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