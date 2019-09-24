/**
 * Created by jbarker on 2019-08-27.
 */

public with sharing class phss_cc_CartItemUtil {

    // error messages
    private static final String FAILED_TO_FETCH_CART_ITEM = 'Failed to fetch the cart item.';
    private static final String FAILED_TO_FETCH_CART_ITEMS = 'Failed to fetch the cart items.';

    /**
     * @description Returns the cart item for the specified cart item identifier
     *
     * @param cartItemId
     *
     * @return
     */
    public static ccrz__E_CartItem__c getCartItem(String cartItemId) {

        if (cartItemId == null) {
            return null;
        }

        Id identifier = Id.valueOf(cartItemId);

        try {
            ccrz__E_CartItem__c cartItem = [
                    SELECT
                            ccrz__AdjustmentAmount__c,
                            ccrz__Cart__c,
                            ccrz__CartItemId__c,
                            ccrz__cartItemType__c,
                            ccrz__Category__c,
                            ccrz__Coupon__c,
                            ccrz__Is_Subscription_Selected__c,
                            ccrz__ItemStatus__c,
                            ccrz__ItemTotal__c,
                            ccrz__OriginalItemPrice__c,
                            ccrz__OriginalQuantity__c,
                            ccrz__ParentCartItem__c,
                            ccrz__ParentProduct__c,
                            ccrz__PercentDiscount__c,
                            ccrz__Price__c,
                            ccrz__PricingType__c,
                            ccrz__Product__c,
                            ccrz__Product__r.Name,
                            ccrz__Product__r.ccrz__SKU__c,
                            ccrz__ProductType__c,
                            ccrz__Quantity__c,
                            ccrz__RequestDate__c,
                            ccrz__StoreID__c,
                            ccrz__SubAmount__c,
                            ccrz__UnitOfMeasure__c,
                            Coupon__c,
                            Coupon__r.Display_Name__c,
                            Coupon_Used__c,
                            Id,
                            ILT_Class__c,
                            Name
                    FROM
                            ccrz__E_CartItem__c
                    WHERE
                            Id = :identifier
            ];
            return cartItem;

        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_FETCH_CART_ITEM, e);
        }
    }

    /**
     * @description Returns the cart items for the specified cart identifier
     *
     * @param cartId
     *
     * @return
     */
    public static List<ccrz__E_CartItem__c> getCartItems(Set<String> cartItemIdentifiers) {
        if (cartItemIdentifiers == null) {
            return null;
        }

        try {
            List<ccrz__E_CartItem__c> cartItems = [
                    SELECT
                            ccrz__AdjustmentAmount__c,
                            ccrz__Cart__c,
                            ccrz__CartItemId__c,
                            ccrz__cartItemType__c,
                            ccrz__Category__c,
                            ccrz__Coupon__c,
                            ccrz__Is_Subscription_Selected__c,
                            ccrz__ItemStatus__c,
                            ccrz__ItemTotal__c,
                            ccrz__OriginalItemPrice__c,
                            ccrz__OriginalQuantity__c,
                            ccrz__ParentCartItem__c,
                            ccrz__ParentProduct__c,
                            ccrz__PercentDiscount__c,
                            ccrz__Price__c,
                            ccrz__PricingType__c,
                            ccrz__Product__c,
                            ccrz__Product__r.Name,
                            ccrz__Product__r.ccrz__SKU__c,
                            ccrz__ProductType__c,
                            ccrz__Quantity__c,
                            ccrz__RequestDate__c,
                            ccrz__StoreID__c,
                            ccrz__SubAmount__c,
                            ccrz__UnitOfMeasure__c,
                            Coupon__c,
                            Coupon__r.Display_Name__c,
                            Coupon_Used__c,
                            Id,
                            ILT_Class__c,
                            Name
                    FROM
                            ccrz__E_CartItem__c
                    WHERE
                            Id IN :cartItemIdentifiers
            ];
            return cartItems;

        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_FETCH_CART_ITEMS, e);
        }
    }
}