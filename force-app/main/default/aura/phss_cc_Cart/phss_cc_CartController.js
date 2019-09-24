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
        console.log('phss_cc_Cart.doInit()');
        helper.getActiveCart(component);
        helper.getPaymentTabsetPermissions(component);
        helper.fetchOpportunityApprovalState(component);
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
        helper.fetchOpportunityApprovalState(component);
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
    cartItemQuantityIncrement: function (component, event, helper) {
        var quantities = component.get('v.cartItemQuantityMap');
        var cartItemId = event.getParam('cartItemId');
        var cartItemQty = quantities[cartItemId];
        if (isNaN(cartItemQty)) {
            quantities[cartItemId] = 1;
        } else {
            quantities[cartItemId] = Number(cartItemQty) + 1;
        }
        component.set('v.isCartUpdated', true);
    },

    /**
     * @description Event Handler to update product count increment on the front end.
     * @param component
     * @param event
     * @param helper
     */
    cartItemQuantityDecrement: function (component, event, helper) {
        var quantities = component.get('v.cartItemQuantityMap');
        var cartItemId = event.getParam('cartItemId');
        var cartItemQty = quantities[cartItemId];
        if (isNaN(cartItemQty)) {
            quantities[cartItemId] = 0;
        } else {
            quantities[cartItemId] = Number(cartItemQty) - 1;
        }
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
        helper.doPlaceOrderCC(component, event, helper, cyberSourceResponse);
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

        var storedPayments = helper.getStoredPaymentIDs(component);

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

            helper.doPlaceOrderPO(component, event, helper, PODetailsMap);
        }
    },

    /**
     * @description Receive the response from the On Account Balance component with the selected stored payments
     * @param component
     * @param event
     * @param helper
     */
    handleCBPayment: function (component, event, helper) {
        console.log("phss_cc_Cart.handleCBPayment()");
        var storedPayments = event.getParam('storedPayments');
        helper.doPlaceOrderCB(component, event, helper, storedPayments);
    },

    handleCartPaymentNavigationEvent: function (component, event, helper) {
        var selectedTabName = event.getParam('selectedTab');
        var tabset = component.find('paymentTabset');
        if (selectedTabName != null && tabset != null) {
            if (selectedTabName == 'Credit Card') {
                tabset.set('v.selectedTabId', '1');
            } else if (selectedTabName == 'Invoice') {
                tabset.set('v.selectedTabId', '2');
            } else if (selectedTabName == 'Account Balance') {
                tabset.set('v.selectedTabId', '3');
            } else {
                console.log('Unknown tab [name=' + selectedTabName + ']');
            }
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
                'cartItemId': event.getParam('cartItemId')
            });
            showEvent.fire();
        }
    },

    handleToggleStoredPaymentSelection: function (component, event, helper) {
        var storedPayments = event.getParam('storedPayments');
        if (storedPayments != null) {

            // sum up amounts
            var totalAmount = 0.0;
            storedPayments.forEach(function (payment) {
                totalAmount += payment.remainingPOAmount;
            });

            // format label text
            var labelText = 'Account Balance';
            if (totalAmount > 0.0) {
                labelText += ':  $' + totalAmount + ' to be applied';
            }

            // set label text for Account Balance tab
            var label = component.find('onAccountBalanceTab').get('v.label');
            label[0].set('v.value', labelText);
        }

        component.set('v.storedPayments', storedPayments);
    }
})