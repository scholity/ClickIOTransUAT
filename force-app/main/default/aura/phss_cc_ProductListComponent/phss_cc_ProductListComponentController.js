/**
 * Created by dgajwani on 9/24/18.
 */
({
    /**
     * @description Init method to get the current cart for the account.
     * @param component
     * @param event
     * @param helper
     */
    doInit : function (component, event, helper) {
        helper.getActiveCart(component);

        var readyEvent = $A.get('e.c:phss_cc_ProductSearchReadyEvent');
        setTimeout(function() { readyEvent.fire(); }, 100);
    },

    /**
     * @description Requests a search for products matching the searchString.
     * @param component
     * @param event
     * @param helper
     */
    onSearch: function (component, event, helper) {
        component.set('v.availableProductSpecs', []);
        helper.doSearch(component);
    },

    /**
     * @description Refreshes the component after an order is placed. Clears the productQuantityMap.
     * @param component
     * @param event
     * @param helper
     */
    handleRefreshComponentEvent : function (component, event, helper){
        component.set('v.productQuantityMap',new Map());
        helper.getActiveCart(component);
    },

    handleProductSearchEvent : function (component, event, helper) {
        var searchTerm = event.getParam('searchTerm');
        component.set('v.searchQuery', searchTerm);
        helper.doSearch(component, event, helper);
    },

    /**
     * @description Event Handler to update product count increment on the front end.
     * @param component
     * @param event
     * @param helper
     */
    productCountIncrement: function (component, event, helper) {
        var productQuantityMap = component.get('v.productQuantityMap');
        var productSfid = event.getParam('productSfid');
        if (isNaN(productQuantityMap[productSfid])) {
            productQuantityMap[productSfid] = 1;
        }
        else {
            productQuantityMap[productSfid] = Number(productQuantityMap[productSfid]) + 1;
        }

        component.set('v.productQuantityMap', productQuantityMap);
    },

    /**
     * @description Event Handler to update product count increment on the front end.
     * @param component
     * @param event
     * @param helper
     */
    productCountDecrement: function (component, event, helper) {
        var productQuantityMap = component.get('v.productQuantityMap');
        var productSfid = event.getParam('productSfid');
        if (isNaN(productQuantityMap[productSfid]) || productQuantityMap[productSfid] == 0) {
            productQuantityMap[productSfid] = 0;
        }
        else {
            productQuantityMap[productSfid] = Number(productQuantityMap[productSfid]) - 1;
        }
        component.set('v.productQuantityMap', productQuantityMap);
    },

    /**
     * @description Adds the products to the cart.
     * @param component
     * @param event
     * @param helper
     */
    addProdsToCart: function (component, event, helper) {
        helper.addToCartRequest(component,event,helper);
    },

    /**
     *
     * @param component
     * @param event
     * @param helper
     */
    handleProductSpecMenuOptionSelected: function (component, event, helper) {
        var specValue = event.getSource().get('v.value');
        if (specValue == null || specValue == '') {
            component.set('v.selectedProductSpec', null);
        } else {
            component.set('v.selectedProductSpec', specValue);
        }
        helper.filterProductList(component, event, helper);
    }
})