/**
 * Created by dgajwani on 9/24/18.
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
        var opportunitySfid = component.get('v.recordId');
        var action = component.get('c.fetchActiveCartOnProductSearch');
        action.setParams({
            opportunitySfid: opportunitySfid
        });
        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === 'SUCCESS') {
                var returnValue = response.getReturnValue();

                if (returnValue != null && returnValue.Error == null) {
                    component.set('v.encryptedCartId', returnValue.encryptedCartId);
                    component.set('v.productQuantityMap', returnValue.productQuantityMap);
                } else if (returnValue != null && returnValue.Error != null) {
                    this.showToastMessage('Error Fetching Active Cart', returnValue.Error, 'Error')
                }
            } else {
                this.showToastMessage('Error Fetching Active Cart', 'Unable to contact server.', 'Error');
            }
            component.set('v.showSpinner', false);
        });
        component.set('v.showSpinner', true);
        $A.enqueueAction(action);
    },

    /**
     * @description Requests a search for products matching the searchString.
     * @param component
     * @param event
     * @param helper
     */
    doSearch: function (component, event, helper) {
        component.set('v.renderComplete', false);
        var searchString = component.get('v.searchQuery');
        if (searchString === undefined || searchString == null) {
            return;
        }
        else if (searchString.length < 2) {
            this.showToastMessage('Error', 'Enter at least 2 characters for search.', 'Error');
        } else {
            var opportunitySfid = component.get('v.recordId');
            var action = component.get('c.searchProducts');
            action.setParams({
                opportunitySfid: opportunitySfid,
                searchString: searchString
            });

            action.setCallback(this, function (response) {
                var state = response.getState();

                if (state === 'SUCCESS') {
                    var returnValue = response.getReturnValue();
                    if (returnValue != null) {
                        if (returnValue.Error == null) {
                            if (returnValue.productList.length !== 0) {
                                component.set('v.productList', returnValue.productList);
                                component.set('v.productsMap', returnValue.productMap);
                                component.set('v.renderComplete', true);
                            } else {
                                this.showToastMessage('Error', 'No Products found.', 'Error');
                            }
                        } else {
                            this.showToastMessage('Error Fetching Products', returnValue.Error, 'Error');
                        }
                    }
                } else {
                    this.showToastMessage('Error Fetching Products', 'Unable to contact server.', 'Error');
                }
                component.set('v.showSpinner', false);
            });
            component.set('v.showSpinner', true);
            $A.enqueueAction(action);
        }
    },

    /**
     * @description Adds the products to the cart.
     * @param component
     * @param event
     * @param helper
     */
    addToCartRequest: function (component, event, helper) {
        var opportunitySfid = component.get('v.recordId');
        var productQuantityMap = component.get('v.productQuantityMap');
        var action = component.get('c.addProductsToCart');
        action.setParams({
            opportunitySfid: opportunitySfid,
            productQuantityMap: productQuantityMap
        });

        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === 'SUCCESS') {
                var returnValue = response.getReturnValue();
                if (returnValue != null && returnValue.Error == null) {
                    component.set('v.encryptedCartId', returnValue.encryptedCartId);
                    component.set('v.productQuantityMap', returnValue.productQuantityMap);
                    this.showToastMessage('Success', 'Successfully added products to the cart.', 'Success');
                    component.set('v.searchQuery', '');
                    var updateEvent = $A.get('e.c:phss_cc_RefreshComponentEvent');
                    updateEvent.fire();
                    component.set('v.renderComplete', false);
                }
                else {
                    if (returnValue.Error != null) {
                        this.showToastMessage('Error Adding to Cart', returnValue.Error, 'Error')
                    }
                }
            } else {
                this.showToastMessage('Error Adding to Cart', 'Unable to contact server.', 'Error');
            }
            component.set('v.showSpinner', false);
        });
        component.set('v.showSpinner', true);
        $A.enqueueAction(action);
    }
})