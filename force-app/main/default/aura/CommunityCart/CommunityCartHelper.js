({
    /**
     * @description Shows a toast message to the user.
     * @param header
     * @param message
     * @param type
     */
    showToastMessage: function (header, message, type) {
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            title: header,
            message: message,
            type: type
        });
        toastEvent.fire();
    },

    /**
     * @description Fetches the current cart for the account.
     * @param component
     * @param event
     * @param helper
     */
    getActiveCart: function (component, event, helper) {
        component.set('v.renderComplete', false);
        var opportunitySfid = component.get('v.recordId');
        var action = component.get('c.fetchActiveCart');
        action.setParams({
            opportunitySfid: opportunitySfid
        });
        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === 'SUCCESS') {
                var returnValue = response.getReturnValue();

                if (returnValue != null && returnValue.Error == null) {
                    component.set('v.encryptedCartId', returnValue.encryptedCartId);
                    component.set('v.cartTotal', returnValue.CartTotal);
                    component.set('v.productList', returnValue.productList);
                    component.set('v.productsMap', returnValue.productMap);
                    component.set('v.productQuantityMap', returnValue.productQuantityMap);
                    component.set('v.renderComplete', true);
                } else if (returnValue != null && returnValue.Error != null) {
                    this.showToastMessage('Error Fetching Cart', returnValue.Error, 'Error')
                }
            } else {
                this.showToastMessage('Error Fetching Cart', 'Unable to contact server.', 'Error');
            }
            component.set('v.showSpinner', false);
        });
        component.set('v.showSpinner', true);
        $A.enqueueAction(action);
    },

    /**
     * @description Updates the cart with new quantities.
     * @param component
     * @param event
     * @param helper
     */
    doUpdateCart: function (component, event, helper) {
        var isCartUpdated = component.get('v.isCartUpdated');
        if (!isCartUpdated) {
            this.showToastMessage('Warning', 'There is nothing to update', 'Warning');
            return;
        }
        component.set('v.renderComplete', false);
        var productQuantityMap = component.get('v.productQuantityMap');
        var opportunitySfid = component.get('v.recordId');
        var encryptedCartId = component.get('v.encryptedCartId');
        var action = component.get('c.updateCartProducts');
        action.setParams({
            opportunitySfid: opportunitySfid,
            encryptedCartId: encryptedCartId,
            productQuantityMap: productQuantityMap

        });
        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === 'SUCCESS') {
                var returnValue = response.getReturnValue();
                if (returnValue != null && returnValue.Error == null) {
                    component.set('v.productList', returnValue.productList);
                    component.set('v.productsMap', returnValue.productMap);
                    component.set('v.productQuantityMap', returnValue.productQuantityMap);
                    component.set('v.renderComplete', true);
                    var updateEvent = $A.get('e.c:phss_cc_RefreshComponentEvent');
                    updateEvent.fire();
                    this.showToastMessage('Success', 'Successfully updated the cart.', 'Success')
                }
                else if (returnValue.Error != null) {
                    this.showToastMessage('Error Updating Cart', returnValue.Error, 'Error')
                }
            } else {
                this.showToastMessage('Error Updating Cart', 'Unable to contact server.', 'Error');
            }
            component.set('v.showSpinner', false);
        });
        component.set('v.showSpinner', true);
        $A.enqueueAction(action);
    },

    /**
     * @description Converts the cart to an order using the credit card payment method.
     * @param component
     * @param event
     * @param helper
     */
    doPlaceOrderCC: function (component, event, helper,cyberSourceResponse) {
        component.set('v.renderComplete', false);
        if (cyberSourceResponse === undefined)
            cyberSourceResponse = null;
        var opportunitySfid = component.get('v.recordId');
        var encryptedCartId = component.get('v.encryptedCartId');
        var action = component.get('c.placeOrderOnCartCC');
        action.setParams({
            opportunitySfid: opportunitySfid,
            encryptedCartId: encryptedCartId,
            cyberSourceResponse: cyberSourceResponse,
            storedPayments: null
        });
        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === 'SUCCESS') {
                var returnValue = response.getReturnValue();
                if (returnValue != null && returnValue.Error == null) {
                    if (returnValue.success == true){
                        this.showToastMessage('Success', returnValue.message, 'Success');
                        var updateEvent = $A.get('e.c:phss_cc_RefreshComponentEvent');
                        updateEvent.fire();
                        return;
                    }else {
                        component.set('v.renderComplete', true);
                        this.showToastMessage('Error placing Order', returnValue.message, 'Error')
                    }
                } else if (returnValue != null && returnValue.Error != null) {
                    component.set('v.renderComplete', true);
                    this.showToastMessage('Error Placing Order', returnValue.Error, 'Error')
                } else {
                    component.set('v.renderComplete', true);
                    this.showToastMessage('Error Placing Order', 'Failed to place order. Got null.', 'Error')
                }
            } else {
                this.showToastMessage('Error Placing Order', 'Unable to contact server.', 'Error');
            }
            component.set('v.showSpinner', false);
        });
        component.set('v.showSpinner', true);
        $A.enqueueAction(action);
    },

    /**
     * @description Converts the cart to an order using a PO payment method.
     * @param component
     * @param event
     * @param helper
     */
    doPlaceOrderPO: function (component, event, helper,PODetailsMap) {
        component.set('v.renderComplete', false);
        var opportunitySfid = component.get('v.recordId');
        var encryptedCartId = component.get('v.encryptedCartId');
        var action = component.get('c.placeOrderOnCartPO');
        action.setParams({
            opportunitySfid: opportunitySfid,
            encryptedCartId: encryptedCartId,
            PODetailsMap: PODetailsMap,
            storedPayments: null
        });
        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === 'SUCCESS') {
                var returnValue = response.getReturnValue();
                if (returnValue != null && returnValue.Error == null) {
                    if (returnValue.success == true){
                        this.showToastMessage('Success', returnValue.message, 'Success');
                        var updateEvent = $A.get('e.c:phss_cc_RefreshComponentEvent');
                        updateEvent.fire();
                    }
                } else if (returnValue.Error != null) {
                    component.set('v.renderComplete', true);
                    this.showToastMessage('Error Placing Order', returnValue.Error, 'Error')
                }
            } else {
                this.showToastMessage('Error Placing Order', 'Unable to contact server.', 'Error');
            }
            component.set('v.showSpinner', false);
        });
        component.set('v.showSpinner', true);
        $A.enqueueAction(action);
    },
})