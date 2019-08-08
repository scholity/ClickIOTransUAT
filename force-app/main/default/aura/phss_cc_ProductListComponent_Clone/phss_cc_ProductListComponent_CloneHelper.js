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
        //var oppId = component.get("v.OppId"); 
        
        var searchString = component.get('v.searchQuery');
        if (searchString === undefined) {
            // ignore
        }
        else if (searchString.length < 2) {
            this.showToastMessage('Error', 'Enter at least 2 characters for search.', 'Error');
        } else {
            //var opportunitySfid = component.get('v.recordId'); //"0065B00000AqT1yQAF"
            var opportunitySfid = component.get("v.oppId");
            var storeFront = component.get("v.storeFront");
            console.log('storeFront..'+storeFront);
          console.log("***searchstring###" +searchString);
            console.log("***opportunitySfid###" +opportunitySfid);

            var action = this.buildSearchAction(component);
            action.setCallback(this, function (response) {
                var state = response.getState();

                if (state === 'SUCCESS') {
                    var returnValue = response.getReturnValue();
                    
                    console.log(returnValue);
                    
                    if (returnValue != null) {
                        if (returnValue.Error == null) {
                            if (returnValue.productList.length !== 0) {
                                component.set('v.productList', returnValue.productList);
                                component.set('v.productsMap', returnValue.productMap);
                                component.set('v.renderComplete', true);
                            } else {
                                this.showToastMessage('Error', 'Please review your entry to make sure it matches a Course Name that is part of your Authorized Provider/Licensed Training Provider Agreement with the American Red Cross.', 'Error');
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
     * @description Creates a search-related action based on values from the component
     * @param component
     */
    buildSearchAction: function (component) {
        var opportunityId = component.get("v.oppId");
        var storefrontName = component.get("v.storeFront");
        var searchString = component.get("v.searchQuery");
        var action;

        var productSpecs = component.get('v.productSpecs');
        if (productSpecs !== undefined && productSpecs != null && Object.keys(productSpecs).length > 0) {
            action = component.get('c.searchFilteredProducts');
            action.setParams({
               opportunityId: opportunityId,
                searchString: searchString,
                storeFrontName: storefrontName,
                filterMap: productSpecs
            });
        }
        else {
            action = component.get('c.searchProducts');
            action.setParams({
                opportunitySfid: opportunityId,
                searchString: searchString,
                storeFrontName: storefrontName
            });
        }

        return action;
    },

    /**
     * @description Adds the products to the cart.
     * @param component
     * @param event
     * @param helper
     */
    addToCartRequest: function (component, event, helper) {
        //var opportunitySfid = component.get('v.recordId');
        
        var opportunitySfid = component.get('v.oppId');
        console.log("opportunitySfid###"+opportunitySfid);
        var productQuantityMap = component.get('v.productQuantityMap');
        console.log(productQuantityMap);
        var action = component.get('c.addProductsToCart');
        action.setParams({
            opportunitySfid: opportunitySfid, //"0065B00000AqT1yQAF",
            productQuantityMap: productQuantityMap
        });

        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === 'SUCCESS') {
                var returnValue = response.getReturnValue();
                if (returnValue != null && returnValue.Error == null) {
                    component.set('v.encryptedCartId', returnValue.encryptedCartId);
                    
                    console.log(returnValue.productQuantityMap);
                    
                    var action1 = component.get('c.updateStoreFrontofCart');
        			action1.setParams({
                        opportunitySfid: opportunitySfid
                    });
            
                    action1.setCallback(this, function (response) {
                        var state = response.getState();
            
                        if (state === 'SUCCESS') {          
                			var returnValue = response.getReturnValue();
        	            	console.log('storefront updated...'+JSON.stringify(returnValue));
                        }
                        else {
                            this.showToastMessage('Error Adding to Cart', returnValue.Error, 'Error')
                        }
                    });
                    $A.enqueueAction(action1);
                    
                    component.set('v.productQuantityMap', returnValue.productQuantityMap);
                    this.showToastMessage('Success', 'Successfully added products to the cart.', 'Success');
                    component.set('v.searchQuery', component.get("v.CCProductName"));
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
    },

    clearErrorMessage: function (component) {
        var textField = component.find("searchTextField");
        textField.set("v.errors", null);
        $A.util.removeClass(textField, "slds-has-error");
        $A.util.removeClass(textField, "text-field-error");
    },

    displayErrorMessage: function (component, errorMessage) {
        var textField = component.find("searchTextField");
        textField.set("v.errors", [{message: errorMessage}]);
        $A.util.addClass(textField, "slds-has-error");
        $A.util.addClass(textField, "text-field-error");
    }

})