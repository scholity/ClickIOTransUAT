/**
 * Created by jbarker on 2019-08-26.
 */

({
    doInit: function (component, event, helper) {
        var cartItemId = component.get('v.recordId');
        var cartItems = component.get('v.cartItems');

        if (cartItemId != null && cartItems != null) {
            var cartItem = cartItems[cartItemId];
            component.set('v.cartItem', cartItem);

            if (cartItem.cartItemList == null || cartItem.cartItemList.length == 0) {
                component.set('v.allowsPriceOverride', true);
            }
        }

        component.set('v.renderComplete', true);
    },

    /**
     * @description Event handler for the price override link.
     * @param component
     * @param event
     * @param helper
     */
    handlePriceOverrideClick: function (component, event, helper) {
        var cartItemId = component.get('v.recordId');
        if (cartItemId != null) {
            var showEvent = component.getEvent('showPriceOverrideModal');
            showEvent.setParam('cartItemId', cartItemId);
            showEvent.fire();
        }
    } 

});