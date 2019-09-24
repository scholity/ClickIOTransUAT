public class phss_cc_PriceOverrideModalController {

    public static final String CART_ITEM_KEY                    = 'cartItem';

    
    private static final String CART_ITEMS_KEY                  = 'ECartItemsS';
    private static final String PRODUCT_ID_KEY                  = 'product';
    private static final String SFID_KEY                        = 'sfid';

    public static final String PERCENT_DISCOUNT_OVERRIDE_TYPE   = 'percentDiscount';
    public static final String UNIT_PRICE_OVERRIDE_TYPE         = 'unitPrice';
    public static final String EXTERNAL_PRICING_TYPE            = 'external';

    private static final String CART_ITEM_ADJUSTMENT_AMOUNT     = 'adjustmentAmount';
    private static final String CART_ITEM_ID                    = 'cartItemSfid';
    private static final String CART_ITEM_ITEM_TOTAL            = 'itemTotal';
    private static final String CART_ITEM_ORIGINAL_ITEM_PRICE   = 'originalItemPrice';
    private static final String CART_ITEM_PERCENT_DISCOUNT      = 'percentDiscount';
    private static final String CART_ITEM_PRICE                 = 'price';
    private static final String CART_ITEM_PRICING_TYPE          = 'pricingType';
    private static final String CART_ITEM_QUANTITY              = 'quantity';
    private static final String CART_ITEM_SUB_AMOUNT            = 'subAmount';
    private static final String PRODUCT_ID                      = 'productSfid';
    private static final String PRODUCT_NAME                    = 'productName';
    private static final String PRODUCT_SKU                     = 'productSKU';

    private static final String FAILED_TO_GET_CART_ITEM = 'Failed to get the cart item.';
    private static final String FAILED_TO_OVERRIDE_PRICE_OF_CART_ITEM   = 'Failed to override price of cart item.';
    private static final String MISSING_REQUIRED_DATA_FOR_OVERRIDING_PRICE_OF_CART_ITEM = 'Missing required data for overriding price of cart item.';
    private static final String MISSING_REQUIRED_DATA_FOR_REMOVING_COUPON_OF_CART_ITEM = 'Missing required data for removing coupon of cart item.';


    /**
     * @description Gets the cart item for a specified product ID and opportunity ID
     *
     * @param productSfid
     * @param opportunitySfid
     *
     * @return
     */
    @AuraEnabled
    public static Map<String, Object> getCartItem(String cartItemId, String opportunitySfid) {

        Map<String, Object> result = new Map<String, Object>();

        try {
            phss_cc_Context.setContext(opportunitySfid);

            ccrz__E_CartItem__c cartItem = phss_cc_CartItemUtil.getCartItem(cartItemId);
            if (cartItem != null) {
                Map<String, Object> cartItemMap = buildCartItemMap(cartItem);
                result.put(CART_ITEM_KEY, cartItemMap);
            }

//            ccrz__E_Cart__c cart = phss_cc_Context.currCart;
//
//            if (cart != null && String.isNotBlank(cart.ccrz__EncryptedId__c)) {
//                Map<String, Object> cartDetails = phss_cc_CartUtil.cartFetch(cart.ccrz__EncryptedId__c, false);
//                List<Map<String, Object>> cartItems = getItemsFromCartDetails(cartDetails);
//                for (Map<String, Object> cartItemDetails : cartItems) {
//                    if (cartItemDetails.get(PRODUCT_ID_KEY) == productSfid) {
//                        String cartItemSfid = (String) cartItemDetails.get(SFID_KEY);
//                        ccrz__E_CartItem__c cartItem = cartItemFetch(cartItemSfid);
//                        Map<String, Object> item = buildCartItemMap(cartItem);
//                        system.debug('item^^^'+item);
//                        if (item != null) {
//                            result.put(CART_ITEM_KEY, item);
//                            break;
//                        }
//                    }
//                }
//            }

        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_GET_CART_ITEM, e);
        }

        return result;
    }
    
    @AuraEnabled 
    public static List<Coupon__c> getCoupons ()
    {
        Date today = Date.today();
        
        List<Coupon__c> couponList = [SELECT Id,
                                      		 Name,
                                      		 Start_Date__c,
                                      		 End_Date__c, Type__c,
                                      		 Value__c,
                                      		 Display_Name__c
                                      	FROM Coupon__c
                                       WHERE Active__c = true
                                         AND Start_Date__c <= today
                                         AND End_Date__c   >= today
                                    ORDER BY Display_Name__c ASC NULLS LAST];

        return couponList;
    }
    @AuraEnabled 
    public static List<Coupon__c> getCouponsDiscount (String couponId)
    {
        List<Coupon__c> couponList = [SELECT Id,
                                      		 Name,
                                      		 Start_Date__c,
                                      		 End_Date__c,
                                      		 Type__c,
                                      		 Value__c, 
                                      		 Display_Name__c 
                                      	FROM Coupon__c
                                       WHERE Id =: couponId];

        return couponList;
    }

    /**
     * @description Builds a map of the data from cart item
     *
     * @param cartItem
     *
     * @return
     */
    private static Map<String, Object> buildCartItemMap(ccrz__E_CartItem__c cartItem) {

        Map<String, Object> item = null;
        if (cartItem != null) {
            item = new Map<String, Object>();
            item.put(CART_ITEM_ADJUSTMENT_AMOUNT, cartItem.ccrz__AdjustmentAmount__c);
            item.put(CART_ITEM_ID, cartItem.Id);
            item.put(CART_ITEM_ITEM_TOTAL, cartItem.ccrz__ItemTotal__c);
            item.put(CART_ITEM_ORIGINAL_ITEM_PRICE, cartItem.ccrz__OriginalItemPrice__c);
            item.put(CART_ITEM_PRICE, cartItem.ccrz__Price__c);
            item.put(CART_ITEM_PRICING_TYPE, cartItem.ccrz__PricingType__c);
            item.put(CART_ITEM_QUANTITY, cartItem.ccrz__Quantity__c);
            item.put(PRODUCT_ID, cartItem.ccrz__Product__r.Id);
            item.put(PRODUCT_NAME, cartItem.ccrz__Product__r.Name);
            item.put(PRODUCT_SKU, cartItem.ccrz__Product__r.ccrz__SKU__c);
            item.put(CART_ITEM_SUB_AMOUNT, cartItem.ccrz__SubAmount__c);
            item.put('Coupon', cartItem.Coupon__c);
            item.put('CouponName', cartItem.Coupon__r.Display_Name__c );

            if (cartItem.ccrz__PercentDiscount__c != null) {
                // For display purposes, format percent discount as XX.X (round to nearest tenth)
                item.put(CART_ITEM_PERCENT_DISCOUNT, cartItem.ccrz__PercentDiscount__c.setScale(1));
            }
        }

        return item;
    }

//    /**
//     * @description Fetches the cart item specified by its ID
//     *
//     * @param identifier
//     *
//     * @return
//     */
//    private static ccrz__E_CartItem__c cartItemFetch(String identifier) {
//        ccrz__E_CartItem__c cartItem;
//
//        try {
//            cartItem = [
//                    SELECT Id,
//                            ccrz__AdjustmentAmount__c,
//                            ccrz__ItemTotal__c,
//                            ccrz__OriginalItemPrice__c,
//                            ccrz__Price__c,
//                            ccrz__PricingType__c,
//                            ccrz__PercentDiscount__c,
//                            ccrz__Quantity__c,
//                            ccrz__Product__r.Id,
//                            ccrz__Product__r.Name,
//                            ccrz__Product__r.ccrz__SKU__c,
//                            ccrz__SubAmount__c,
//                			Coupon__c,
//                			Coupon__r.Display_Name__c
//                    FROM ccrz__E_CartItem__c
//                    WHERE Id = :identifier
//            ];
//
//        } catch (Exception e) {
//            throw new phss_cc_Exception(FAILED_TO_GET_CART_ITEM, e);
//        }
//
//        return cartItem;
//    }

//    /**
//     * @description Returns a list of cart items
//     *
//     * @param cartDetails
//     *
//     * @return
//     */
//    private static List<Map<String, Object>> getItemsFromCartDetails(Map<String, Object> cartDetails) {
//
//        List<Map<String, Object>> cartItems = new List<Map<String, Object>>();
//
//        if (cartDetails.containsKey(ccrz.ccApiCart.CART_OBJLIST)) {
//            List<Map<String, Object>> cartDetailsList = (List<Map<String, Object>>) cartDetails.get(ccrz.ccApiCart.CART_OBJLIST);
//            for (Map<String, Object> cartDetail : cartDetailsList) {
//                List<Map<String, Object>> cartItemList = (List<Map<String, Object>>) cartDetail.get(CART_ITEMS_KEY);
//                if (cartItemList != null && cartItemList.size() > 0) {
//                    cartItems.addAll(cartItemList);
//                }
//            }
//        }
//
//        return cartItems;
//    }

    /**
     * @description Overrides the price of a cart item.
     *
     * @param cartItemSfid
     * @param overrideType
     * @param overrideValue
     *
     * @return
     */
    @AuraEnabled
    public static Map<String, Object> overridePriceForCartItem(String cartItemSfid, String overrideType, String overrideValue, String couponId) {

        Map<String, Object> result = new Map<String, Object>();

        if (String.isBlank(cartItemSfid) || String.isBlank(overrideType) || overrideValue == null) {
            throw new phss_cc_Exception(MISSING_REQUIRED_DATA_FOR_OVERRIDING_PRICE_OF_CART_ITEM);
        }

        try {
            ccrz__E_CartItem__c cartItem = phss_cc_CartItemUtil.getCartItem(cartItemSfid);
            if (cartItem != null) {
                if (overrideType == UNIT_PRICE_OVERRIDE_TYPE) {
                    Decimal price = Decimal.valueOf(overrideValue);
                    price.setScale(2);
                    cartItem.ccrz__Price__c = price;
                    cartItem.ccrz__AdjustmentAmount__c = cartItem.ccrz__OriginalItemPrice__c - cartItem.ccrz__Price__c;

                    Double d = (cartItem.ccrz__AdjustmentAmount__c / cartItem.ccrz__OriginalItemPrice__c) * 100.0;
                    Decimal discount = Decimal.valueOf(d);
                    discount.setScale(2);
                    cartItem.ccrz__PercentDiscount__c = discount;
                }
                else if (overrideType == PERCENT_DISCOUNT_OVERRIDE_TYPE) {
                    Decimal discount = Decimal.valueOf(overrideValue);
                    cartItem.ccrz__PercentDiscount__c = discount;

                    Double d = cartItem.ccrz__OriginalItemPrice__c * (1 - (cartItem.ccrz__PercentDiscount__c / 100.0));
                    Decimal price = Decimal.valueOf(d);
                    price.setScale(2);
                    cartItem.ccrz__Price__c = price;
                    cartItem.ccrz__AdjustmentAmount__c = cartItem.ccrz__OriginalItemPrice__c - cartItem.ccrz__Price__c;
                }
                cartItem.ccrz__SubAmount__c = cartItem.ccrz__Price__c * cartItem.ccrz__Quantity__c - cartItem.ccrz__AdjustmentAmount__c;
                cartItem.ccrz__PricingType__c = EXTERNAL_PRICING_TYPE;
                cartItem.Coupon__c = couponId;
                if(couponId != null && couponId != '')
                {
                    cartItem.Coupon_Used__c = true;
                }
                else
                {
                    cartItem.Coupon_Used__c = false;
                }
                update cartItem;

                result.put(CART_ITEM_KEY, cartItem);
            }

        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_OVERRIDE_PRICE_OF_CART_ITEM);
        }

        return result;
    }
    
    
    @AuraEnabled
    public static Map<String, Object> processRemoveCoupon(String cartItemSfid, String couponId)
    {
        Map<String, Object> result = new Map<String, Object>();

        if (String.isBlank(cartItemSfid)) {
            throw new phss_cc_Exception(MISSING_REQUIRED_DATA_FOR_REMOVING_COUPON_OF_CART_ITEM);
        }

        try
        {
            ccrz__E_CartItem__c cartItem = phss_cc_CartItemUtil.getCartItem(cartItemSfid);
            
            if (cartItem != null)
            {
                decimal qty 						= cartItem.ccrz__Quantity__c;
                decimal oItemPrice 					= cartItem.ccrz__OriginalItemPrice__c;
                decimal subAmount 					= oItemPrice * qty;
                
                cartItem.ccrz__Price__c				= oItemPrice;
                cartItem.ccrz__SubAmount__c 		= subAmount;
                cartItem.ccrz__AdjustmentAmount__c 	= null;
                cartItem.Coupon__c 					= null;
                cartItem.ccrz__PercentDiscount__c 	= null;
                cartItem.ccrz__PricingType__c 		= 'auto';
                cartItem.Coupon_Used__c		 		= false;
                
                update cartItem;

                result.put(CART_ITEM_KEY, cartItem);
            }

        }
        catch (Exception e)
        {
            throw new phss_cc_Exception(FAILED_TO_OVERRIDE_PRICE_OF_CART_ITEM);
        }

        return result;
    }
}