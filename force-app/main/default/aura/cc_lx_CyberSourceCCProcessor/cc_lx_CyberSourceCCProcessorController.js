/**
 * Created by dgajwani on 9/12/18.
 */
({
    /**
     * @description Gets the form POST data from the server and attaches a listener to hear for the cybersource response.
     * @param component
     * @param event
     * @param helper
     */
    doInit: function (component, event, helper) {
        var cart = component.get('v.cart');
        if (cart != null)
            component.set('v.currCartId',cart.sfid);
        helper.getFormData(component, event, helper);
        window.addEventListener("message", function(event) {
            var cyberSourceResponse = event.data;
            helper.processCyberSourceCallback(component,cyberSourceResponse)
        }, false);
    },

    /**
     * @description POST the form to Cybersource via the iframe bridge form.
     * @param component
     * @param event
     * @param helper
     */
    submitFormData : function (component, event, helper) {
        helper.POSTFormData(component);
    }

})