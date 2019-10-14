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
            this.actionDidFinish('getActiveCart', component);
        });
        this.actionDidStart('getActiveCart', component);
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
            this.actionDidStart('doSearch', component);

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
                                component.set('v.selectedProductSpec', null);
                                this.buildProductSpecOptions(component);
                                this.actionDidFinish('doSearch', component);
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
                this.actionDidFinish('doSearch', component);
            });
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
            this.actionDidFinish('addToCart', component);
        });
        this.actionDidStart('addToCart', component);
        $A.enqueueAction(action);
    },

    /**
     * @description Builds the list of available product specs
     * @param component
     */
    buildProductSpecOptions: function (component) {
        var productList = component.get('v.productList');
        var productsMap = component.get('v.productsMap');
        var options = [];

        if (productList != null && Array.isArray(productList)) {
            for (var i = 0; i < productList.length; i++) {
                var productId = productList[i];
                var product = productsMap[productId];
                if (product != null) {
                    var productSpecsList = product['productSpecsS'];
                    if (productSpecsList != null && Array.isArray(productSpecsList)) {
                        for (var j = 0; j < productSpecsList.length; j++) {
                            var productSpecs = productSpecsList[j];
                            var value = productSpecs['specValue'];
                            if (value != null && !options.includes(value)) {
                                options.push(value);
                            }
                        }
                    }
                }
            }
        }
        component.set('v.availableProductSpecs', options.sort());
    },

    /**
     *
     * @param component
     * @param event
     * @param helper
     */
    filterProductList: function (component, event, helper) {
        var products = [];
        var productList = component.get('v.productList');
        var productsMap = component.get('v.productsMap');
        var selectedProductSpec = component.get('v.selectedProductSpec');

        if (selectedProductSpec != null && selectedProductSpec != '') {
            for (var i = 0; i < productList.length; i++) {
                var productId = productList[i];
                var product = productsMap[productId];
                if (product != null) {
                    var productSpecsList = product['productSpecsS'];
                    if (productSpecsList != null && Array.isArray(productSpecsList)) {
                        for (var j = 0; j < productSpecsList.length; j++) {
                            var productSpecs = productSpecsList[j];
                            var value = productSpecs['specValue'];
                            if (value == selectedProductSpec) {
                                products.push(productId);
                                break;
                            }
                        }
                    }
                }
            }
        }

        console.log('resetting filtered product list: ' + products);
        component.set('v.filteredProductList', products);
    },

    actionDidStart: function (actionName, component) {
        var actionsInProgress = component.get('v.actionsInProgress');
        if (actionsInProgress != null && Array.isArray(actionsInProgress)) {
            if (!actionsInProgress.includes(actionName)) {
                actionsInProgress.push(actionName);
            }
        }
        component.set('v.showSpinner', actionsInProgress.length > 0);
    },

    actionDidFinish: function (actionName, component) {
        var actionsInProgress = component.get('v.actionsInProgress');
        if (actionsInProgress != null && Array.isArray(actionsInProgress)) {
            for (var i = 0; i < actionsInProgress.length; i++) {
                if (actionsInProgress[i] == actionName) {
                    actionsInProgress.splice(i, 1);
                }
            }
        }
        component.set('v.showSpinner', actionsInProgress.length > 0);
        console.log('Actions in progress: ' + actionsInProgress);
    }
})