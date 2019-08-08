/**
 * Created by dgajwani on 11/12/18.
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
     * @description Fetches the relevant CC Contact Addresses for the account.
     *
     * @param component
     * @param addressType
     */
    fetchAddressesForAccount: function (component, addressType) {
        var opportunitySfid = component.get('v.currOpportunitySfid');
        var action = component.get('c.fetchAddresses');
        action.setParams({
            opportunitySfid: opportunitySfid,
            addressType: addressType
        });
        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === 'SUCCESS') {
                var returnValue = response.getReturnValue();

                if (returnValue != null && returnValue.Error == null) {
                    // Fetch address from account if there is no account address book
                    if(returnValue.AddressList != '') {
                        component.set('v.addressList', returnValue.AddressList);
                        component.set('v.addressMap', returnValue.AddressMap);
                        component.set('v.addressType', returnValue.AddressType);  
                   
                        component.set('v.renderComplete', true);                    
                    	component.set('v.showModal', true);	
                    }
                    else {
                        var action1 = component.get('c.fetchAddressFromAccount');
                        action1.setParams({
                        	opportunitySfid: opportunitySfid    
                        });
                        action1.setCallback(this, function (response) {
                            var state = response.getState();
    						if (state === 'SUCCESS') {
                                var returnValue = response.getReturnValue();
                        		if (returnValue != null && returnValue.Error == null) {
                    				component.set('v.addressList', returnValue.AddressList);
                                    component.set('v.addressMap', returnValue.AddressMap);
                                    component.set('v.addressType', returnValue.AddressType);
                                    component.set('v.selectedAddressSfid',returnValue.AddressList);
                                    
                                    component.set('v.renderComplete', true);                    
                                    component.set('v.showModal', true);
                                }
                                else if (returnValue != null && returnValue.Error != null) {
                                    this.showToastMessage('Error Fetching Addresses', returnValue.Error, 'Error')
                                }
                            }
                            else {
                                this.showToastMessage('Error Fetching Addresses', 'Unable to contact server.', 'Error');
                            }
                    	});
                        $A.enqueueAction(action1);
                    }
                    
                } else if (returnValue != null && returnValue.Error != null) {
                    this.showToastMessage('Error Fetching Addresses', returnValue.Error, 'Error')
                }
            } else {
                this.showToastMessage('Error Fetching Addresses', 'Unable to contact server.', 'Error');
            }
            component.set('v.showSpinner', false);
        });
        component.set('v.showSpinner', true);
        $A.enqueueAction(action);
    },

    /**
     * @description Sets the Bill-To / Ship-To on the cart.
     * @param component
     * @param addressType
     */
    setAddressOnCart: function (component) {
        var opportunitySfid = component.get('v.currOpportunitySfid');
        var addressType = component.get('v.addressType');
        var selectedContactAddressSfid = component.get('v.selectedAddressSfid');
        var action = component.get('c.addAddressToCart');
        action.setParams({
            opportunitySfid: opportunitySfid,
            addressType: addressType,
            selectedContactAddressSfid: selectedContactAddressSfid
        });
        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === 'SUCCESS') {
                var returnValue = response.getReturnValue();
                if (returnValue != null && returnValue.Error == null) {
                    if (returnValue.Success === true) {
                        this.showToastMessage('Success', 'Successfully set the address.', 'Success');
                        this.retrieveAddressesFromCart(component);
                        component.set('v.showModal', false);
                    }
                } else if (returnValue != null && returnValue.Error != null) {
                    this.showToastMessage('Error Setting Addresses', returnValue.Error, 'Error')
                }
            } else {
                this.showToastMessage('Error Setting Addresses', 'Unable to contact server.', 'Error');
            }
        });
        $A.enqueueAction(action);
    },

    /**
     * @description Retrieves the Bill-To/Ship-To Addresses that are currently on the cart.
     * @param component
     */
    retrieveAddressesFromCart: function (component) {
        component.set('v.renderComplete', false);
        var opportunitySfid = component.get('v.currOpportunitySfid');
        var action = component.get('c.getCurrentAddressesFromCart');
        action.setParams({
            opportunitySfid: opportunitySfid
        });
        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === 'SUCCESS') {
                var returnValue = response.getReturnValue();
                if (returnValue != null && returnValue.Error == null) {
                    component.set('v.selectedAddressList', returnValue.AddressList);
                    component.set('v.selectedAddressMap', returnValue.AddressMap);
                    this.getAddressSfidFromMap(component);
                    component.set('v.renderComplete', true);
                } else if (returnValue != null && returnValue.Error != null) {
                    this.showToastMessage('Error Setting Addresses', returnValue.Error, 'Error');
                }
            } else {
                this.showToastMessage('Error Setting Addresses', 'Unable to contact server.', 'Error');
            }
        });
        $A.enqueueAction(action);
    },

    /**
     * @description Finds the billing and shipping addresses in the selectedAddressMap for rendering.
     * @param component
     */
    getAddressSfidFromMap: function (component) {
        var selectedAddressMap = component.get('v.selectedAddressMap');

        for (var key in selectedAddressMap) {
            var currAddress = selectedAddressMap[key];
            if (currAddress.AddressType === 'Billing'){
                component.set('v.cartBillToSfid', key);
            }
            if (currAddress.AddressType === 'Shipping'){
                component.set('v.cartShipToSfid', key);
            }
        }
    },
    
    initAddressWrapper : function(component) {
        var action = component.get('c.initAddrFormWrapper');

        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === 'SUCCESS') {
                var returnValue = response.getReturnValue();
                if (returnValue != null && returnValue.Error == null) {
                    component.set('v.formWrap',returnValue);
                    component.set('v.renderComplete', true);
                } else if (returnValue != null && returnValue.Error != null) {
                    this.showToastMessage('Error initializing address form', returnValue.Error, 'Error')
                }
            } else {
                this.showToastMessage('Error initializing address form', 'Unable to contact server.', 'Error');
            }
        });
        $A.enqueueAction(action);
    },
    
    saveNewAddress : function(component) {
        component.set('v.renderComplete', false);
        
        var action = component.get('c.saveNewShippingAddr');

		action.setParams({
            addrJson: JSON.stringify(component.get("v.formWrap")),
            oppId: component.get("v.currOpportunitySfid")
        });        
        
        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === 'SUCCESS') {
                var returnValue = response.getReturnValue();
                if (returnValue != null && returnValue.Error == null) {
                    component.set('v.isShowNewAddrForm',false);
                    component.set('v.isShowNewAddrBtn',true);
                    //component.set('v.selectedAddressSfid',returnValue.Id);
                    this.fetchAddressesForAccount(component,'Shipping');
                } else if (returnValue != null && returnValue.Error != null) {
                    this.showToastMessage('Error initializing address form', returnValue.Error, 'Error')
                }
            } else {
                this.showToastMessage('Error initializing address form', 'Unable to contact server.', 'Error');
            }
        });
        $A.enqueueAction(action);
    }
})