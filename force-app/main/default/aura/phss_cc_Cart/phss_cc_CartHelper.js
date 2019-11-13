/**
 * Created by dgajwani on 9/27/18.
 */
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
        var action = component.get('c.fetchActiveCartAndItems');
        action.setParams({
            opportunityId: opportunitySfid
        });
        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === 'SUCCESS') {
                var returnValue = response.getReturnValue();
                console.log('returnValue');
                console.log(returnValue);
                console.log(JSON.stringify(returnValue));

                if (returnValue != null && returnValue.Error == null) {
                    component.set('v.encryptedCartId', returnValue.encryptedCartId);
                    component.set('v.cartTotal', returnValue.CartTotal);
                    // component.set('v.productList', returnValue.productList);
                    // component.set('v.productsMap', returnValue.productMap);
                    component.set('v.cartItemList', returnValue.cartItemList);
                    component.set('v.cartItemMap', returnValue.cartItemMap);
                    component.set('v.cartItemQuantityMap', returnValue.cartItemQuantityMap);
                    component.set('v.renderComplete', true);
                    console.log('getActiveCart');
                    console.log(JSON.stringify(returnValue));
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
        console.log('recordId');
        console.log(component.get('v.recordId'));
        console.log('cartItems');
        console.log(JSON.stringify(component.get('v.cartItemQuantityMap')));
        var opportunityId = component.get('v.recordId');
        var cartItemQuantityMap = component.get('v.cartItemQuantityMap');
        var encryptedCartId = component.get('v.encryptedCartId');
        var action = component.get('c.updateCartItemQuantities');
        action.setParams({
            opportunityId: opportunityId,
            encryptedCartId: encryptedCartId,
            cartItemQuantityMap: cartItemQuantityMap
        });
        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === 'SUCCESS') {
                var returnValue = response.getReturnValue();
                if (returnValue != null && returnValue.Error == null) {
                    // component.set('v.productList', returnValue.productList);
                    // component.set('v.productsMap', returnValue.productMap);
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
    doPlaceOrderCC: function (component, event, helper, cyberSourceResponse) {
        component.set('v.renderComplete', false);
        if (cyberSourceResponse === undefined)
            cyberSourceResponse = null;
        var opportunitySfid = component.get('v.recordId');
        var encryptedCartId = component.get('v.encryptedCartId');
        var storedPaymentIDs = helper.getStoredPaymentIDs(component);
        var action = component.get('c.placeOrderOnCartCC');
        action.setParams({
            opportunitySfid: opportunitySfid,
            encryptedCartId: encryptedCartId,
            cyberSourceResponse: cyberSourceResponse,
            storedPayments: storedPaymentIDs
        });
        action.setCallback(this, function (response) {
            var state = response.getState();

            console.log('c.placeOrderOnCartCC returnValue: ' + JSON.stringify(returnValue));
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
    doPlaceOrderPO: function (component, event, helper, PODetailsMap) {
        component.set('v.renderComplete', false);
        var opportunitySfid = component.get('v.recordId');
        var encryptedCartId = component.get('v.encryptedCartId');
        var storedPayments = helper.getStoredPaymentIDs(component);

        var action = component.get('c.placeOrderOnCartPO');
        action.setParams({
            opportunitySfid: opportunitySfid,
            encryptedCartId: encryptedCartId,
            PODetailsMap: PODetailsMap,
            storedPayments: storedPayments
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

    fetchOpportunityApprovalState: function (component) {
        var opportunityId = component.get('v.recordId');
        var action = component.get('c.getOpportunityApprovalStatus');
        action.setParams({ opportunityId: opportunityId });
        action.setCallback(this, function (response) {
            var returnValue = response.getReturnValue();
            if (response.getState() === 'SUCCESS' && returnValue != null) {
                if (returnValue.Error == null) {
                    var allowPaymentSubmission = false;
                    var approvalState = returnValue[opportunityId];
                    if (approvalState === 'No approval required' || approvalState === 'Approved') {
                        allowPaymentSubmission = true;
                    }
                    component.set('v.allowPaymentSubmission', allowPaymentSubmission);
                } else {
                    var errorMessage = returnValue.Error;
                    this.showToastMessage('Error Fetching Data', errorMessage, 'Error');
                }
            } else {
                this.showToastMessage('Error Fetching Data', 'Unable to contact server.', 'Error');
            }
        });
        $A.enqueueAction(action);
    },

    /**
     * @description Converts the cart to an order using ONLY stored payments.
     * @param component
     * @param event
     * @param helper
     * @param PODetailsMap
     */
    doPlaceOrderCB: function (component, event, helper, storedPayments) {
        console.log('phss_cc_Cart.doPlaceOrderCB()');

        component.set('v.renderComplete', false);
        var opportunitySfid = component.get('v.recordId');
        var encryptedCartId = component.get('v.encryptedCartId');
        var action = component.get('c.placeOrderOnCartCB');
        action.setParams({
            opportunitySfid: opportunitySfid,
            encryptedCartId: encryptedCartId,
            storedPayments: storedPayments
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

    /**
     * @description Obtains permission settings for payment tabset
     * @param component
     * @param event
     * @param helper
     */
    getPaymentTabsetPermissions: function(component) {
        var opportunityId = component.get('v.recordId');
        var action = component.get('c.fetchPaymentTabsetPermissions');
        action.setParams({
            opportunityId: opportunityId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === 'SUCCESS') {
                var returnValue = response.getReturnValue();

                if (returnValue != null && returnValue.Error == null) {
                    var allowPaymentByInvoice = returnValue.allowPaymentByInvoice;
                    if (allowPaymentByInvoice != true) {
                        allowPaymentByInvoice = false;
                    }
                    component.set('v.allowPaymentByInvoice', allowPaymentByInvoice);
                } else if (returnValue != null && returnValue.Error != null) {
                    this.showToastMessage('Error Getting Payment Tabset Settings', returnValue.Error, 'Error')
                }
            } else {
                this.showToastMessage('Error Getting Payment Tabset Settings', 'Unable to contact server.', 'Error');
            }
        });
        $A.enqueueAction(action);
    },

    getStoredPaymentIDs: function (component) {
        var storedPayments = component.get('v.storedPayments');
        if (storedPayments != null) {
            var identifiers = [];
            storedPayments.forEach(function(payment) {
                identifiers.push(payment.sfid);
            });
            return identifiers;
        }
        return null;
    }
})