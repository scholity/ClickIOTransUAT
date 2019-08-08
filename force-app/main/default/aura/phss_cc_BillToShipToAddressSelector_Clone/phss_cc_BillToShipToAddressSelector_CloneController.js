/**
 * Created by dgajwani on 10/28/18.
 */
({

    /**
     * @description Look for addresses on the cart.
     * @param component
     * @param event
     * @param helper
     */
    doInit: function (component, event, helper) {
        helper.retrieveAddressesFromCart(component);
        helper.initAddressWrapper(component);
    },

    /**
     * @description Event handler to show/hide the billing address picker modal
     * @param component
     * @param event
     * @param helper
     */
    hideAddressModal : function (component, event, helper) {
        component.set('v.showModal',false);
        component.set('v.isShowNewAddrBtn',true);
        component.set('v.isShowNewAddrForm',false);
    },

    /**
     * @description Event handler to show/hide the shipping address picker modal
     * @param component
     * @param event
     * @param helper
     */
    handleBillingAddressModal : function (component, event, helper) {
        component.set('v.selectedAddressSfid','');
        helper.fetchAddressesForAccount(component,'Billing');
    },

    /**
     * @description Event handler to show/hide the shipping address picker modal
     * @param component
     * @param event
     * @param helper
     */
    handleShippingAddressModal : function (component, event, helper) {
        component.set('v.selectedAddressSfid','');
        helper.fetchAddressesForAccount(component,'Shipping');
    },

    /**
     * @description Event handler to update the selected address.
     * @param component
     * @param event
     * @param helper
     */
    handleSelectedAddress : function (component, event, helper) {
        component.set('v.showModal', false);
        var selectedAddressSfid = event.getParam('selectedAddressSfid');
        component.set('v.selectedAddressSfid',selectedAddressSfid);
        component.set('v.showModal', true);
    },

    /**
     * @description Saves the selected address on the cart.
     * @param component
     * @param event
     * @param helper
     */
    saveAddressOnCart : function (component, event, helper) {
        helper.setAddressOnCart(component);
    },
    
    handleNewAddress : function (component, event, helper) {
        if(component.get("v.isShowNewAddrForm")) {
        	component.set("v.isShowNewAddrForm",false);    
        }
        else {
            component.set("v.isShowNewAddrForm",true);
        }
        
        if(component.get("v.isShowNewAddrBtn")) {
        	component.set("v.isShowNewAddrBtn",false);    
        }
        else {
            component.set("v.isShowNewAddrBtn",true);
        }    
        
    },
    
    saveNewAddress : function(component, event, helper) {
        
        var allValid = component.find('field').reduce(function (validSoFar, inputCmp) {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
        }, true);
        
        if(allValid) {
        	helper.saveNewAddress(component);
        }
        else {
            console.log('invalid');
            helper.showToastMessage('Error adding new address', "Please fill all the mandatory details" , 'Error');
        }
    }
    
})