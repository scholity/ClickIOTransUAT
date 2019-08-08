/**
 * Created by dgajwani on 10/29/18.
 */
({

    /**
     * @description Find the address in the addressMap.
     * @param component
     * @param event
     * @param helper
     */
    doInit: function (component, event, helper) {
        var addressMap = component.get('v.addressMap');
        var addressSfid = component.get('v.addressSfid');

        var address = addressMap[addressSfid];
        component.set('v.address', address);
        component.set('v.renderComplete', true);
    },

    /**
     * @description Event handler when a new address card is selected.
     * @param component
     * @param event
     * @param helper
     */
    updateSelectedAddress :  function (component, event, helper) {
        var addressSfid = component.get('v.addressSfid');
        var addressType = component.get('v.addressType');
        var updateEvent = component.getEvent('addressSelected');
        updateEvent.setParams({
            selectedAddressSfid: addressSfid,
            selectedAddressType : addressType
        });
        updateEvent.fire();
    }
})