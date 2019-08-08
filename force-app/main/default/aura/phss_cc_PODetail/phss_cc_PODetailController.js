/**
 * Created by dgajwani on 10/2/18.
 */
({

    /**
     * @description Init method to get the stored payments on the account.
     * @param component
     * @param event
     * @param helper
     */
    doInit : function (component, event, helper) {
        var storedPaymentMap = component.get('v.storedPaymentMap');
        var storedPaymentSfid = component.get('v.storedPaymentSfid');

        var storedPayment = storedPaymentMap[storedPaymentSfid];
        component.set('v.storedPayment', storedPayment);
    },

    /**
     * @description Event handler when a new PO is seleced via the radio button.
     * @param component
     * @param event
     * @param helper
     */
    handleSelected :  function (component, event, helper) {
        var storedPaymentSfid = component.get('v.storedPaymentSfid');
        var updateEvent = component.getEvent('sendSelectedPO');
        updateEvent.setParams({'POSfid': storedPaymentSfid});
        updateEvent.fire();
    }
})