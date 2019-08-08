/**
 * Created by dgajwani on 10/9/18.
 */
({
    /**
     * @description Find the product in the productMap and makes the product data available.
     * @param component
     * @param event
     * @param helper
     */
    doInit: function (component, event, helper) {
        var productQuantityMap = component.get('v.productQuantityMap');
        var productsMap = component.get('v.productMap');
        var productSfid = component.get('v.productSfid');

        var product = productsMap[productSfid];
        if (productQuantityMap != null) {
            component.set('v.productCount', productQuantityMap[productSfid]);
        }
        else {
            component.set('v.productCount', 0);
        }
        component.set('v.product', product);

    },

    /**
     * @description Event handler for the price override link.
     * @param component
     * @param event
     * @param helper
     */
    handlePriceOverrideClick: function (component, event, helper) {
        var showEvent = component.getEvent('showPriceOverrideModal');
        showEvent.setParam('productSfid', component.get('v.product.sfid'));
        showEvent.fire();
    }
})