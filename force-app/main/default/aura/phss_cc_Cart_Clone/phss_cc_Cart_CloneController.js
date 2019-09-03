/**
 * Created by dgajwani on 9/27/18.
 */
({
    /**
     * @description Init method to get the current cart for the account.
     * @param component
     * @param event
     * @param helper
     */
    doInit : function (component, event, helper) {
        debugger;
        helper.getActiveCart(component);
        helper.getPaymentTabsetPermissions(component);
    },

    /**
     * @description Reloads the cart.
     * @param component
     * @param event
     * @param helper
     */
    reloadCart : function (component, event, helper) {
        helper.getActiveCart(component);
    },

    /**
     * @description Refreshes the component after a product was added to the cart. Clears the productQuantityMap.
     * @param component
     * @param event
     * @param helper
     */
    handleRefreshComponentEvent : function (component, event, helper){
        component.set('v.productQuantityMap',new Map());
        helper.getActiveCart(component);
    },

    /**
     * @description Reloads the cart.
     * @param component
     * @param event
     * @param helper
     */
    placeOrder : function (component, event, helper) {
        helper.doPlaceOrder(component);
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
        component.set('v.isCartUpdated', true);
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
        component.set('v.isCartUpdated', true);
    },

    /**
     * @description Updates the cart with the new quantity values.
     * @param component
     * @param event
     * @param helper
     */
    updateCart: function (component, event, helper){
        helper.doUpdateCart(component);
    },

    /**
     * @description Receive the response from cybersource and place order.
     * @param component
     * @param event
     * @param helper
     */
    handleCyberSourceResponse: function (component, event, helper) {
        var cyberSourceResponse = event.getParam('responseString');
        helper.doPlaceOrderCC(component,event,helper,cyberSourceResponse);
    },

    /**
     * @description Receive the response from PO component with the selected PO.
     * @param component
     * @param event
     * @param helper
     */
    handlePOPayment: function (component, event, helper) {
        var POSfid = event.getParam('POSfid');
        var newPOName = event.getParam('newPOName');
        var newPOAmount = event.getParam('newPOAmount');
        var newPOStartDate = event.getParam('newPOStartDate');
        var newPOEndDate = event.getParam('newPOEndDate');
        var newPODoSave = event.getParam('newPODoSave');
        var updatePO = event.getParam('updatePO');
        var updatedPOAmount = event.getParam('updatedPOAmount');

        if (POSfid === 'NoPORequired') {
            helper.doPlaceOrderPO(component,event,helper,null);
        }
        else {
            var PODetailsMap = {};
            if (POSfid != undefined && POSfid !== ''){
                PODetailsMap['POSfid'] = POSfid;
                PODetailsMap['updatePO'] = updatePO;
                PODetailsMap['updatedPOAmount'] = updatedPOAmount;
            } else {
                PODetailsMap['newPOName'] = newPOName;
                PODetailsMap['newPOAmount'] = newPOAmount;
                PODetailsMap['newPOStartDate'] = newPOStartDate;
                PODetailsMap['newPOEndDate'] = newPOEndDate;
                PODetailsMap['newPODoSave'] = newPODoSave;
            }

            helper.doPlaceOrderPO(component,event,helper,PODetailsMap);
        }
    },

    /**
     * @description Refires ShowPriceOverrideModal event with opportunity ID
     * @param component
     * @param event
     * @param helper
     */
    handleShowPriceOverrideModal: function (component, event, helper) {
        var opportunitySfid = event.getParam('opportunitySfid');
        if (typeof opportunitySfid === 'undefined') {
            var showEvent = $A.get('e.c:phss_cc_ShowPriceOverrideModalEvent');
            showEvent.setParams({
                'opportunitySfid': component.get('v.recordId'),
                'productSfid': event.getParam('productSfid')
            });
            showEvent.fire();
        }
    }
})