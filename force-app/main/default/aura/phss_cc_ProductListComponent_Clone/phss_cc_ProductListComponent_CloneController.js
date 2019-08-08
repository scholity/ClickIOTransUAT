({
    /**
     * @description Init method to get the current cart for the account.
     * @param component
     * @param event
     * @param helper
     */
    doInit : function (component, event, helper) {
        helper.getActiveCart(component);
    },

    /**
     * @description Requests a search for products matching the searchString.
     * @param component
     * @param event
     * @param helper
     */
    onSearch: function (component, event, helper) {
        component.set("v.errorMessage", null);
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
        //helper.getActiveCart(component); //JA
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
        var productName = event.getParam('productName');
        
        console.log("productName>>>***"+productName);
        
        if (isNaN(productQuantityMap[productSfid])) {
            productQuantityMap[productSfid] = 1;
        }
        else {
            productQuantityMap[productSfid] = Number(productQuantityMap[productSfid]) + 1;
        }

        component.set('v.productQuantityMap', productQuantityMap);
        component.set("v.CCProductName",productName);
        
        helper.addToCartRequest(component,event,helper); // JA      
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

    handleErrorMessage: function (component, event, helper) {
        var errorMessage = component.get("v.errorMessage");
        if (errorMessage == null || errorMessage == "") {
            helper.clearErrorMessage(component);
        }
        else {
            helper.displayErrorMessage(component, errorMessage);
        }
    }
})