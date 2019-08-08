/**
 * Created by dgajwani on 9/28/18.
 */
({
    /**
     * @description Gets the form POST data from the server and attaches a listener to hear for the cybersource response.
     * @param component
     * @param event
     * @param helper
     */
    doInit: function (component, event, helper) {
        helper.getFormData(component, event, helper);
        window.addEventListener("message", function(event) {
            var cyberSourceResponse = event.data;
            helper.processCyberSourceCallback(component,cyberSourceResponse)
            window.scroll(0,0);
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