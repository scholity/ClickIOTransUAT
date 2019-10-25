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

			if (cyberSourceResponse == null) { return; }
            if (typeof cyberSourceResponse == 'object') { return; }
            if (typeof cyberSourceResponse == 'string') {
                try {
                    var json = JSON.parse(cyberSourceResponse);
                    if (!json.hasOwnProperty('decision')) {
                        return;
                    }
                } catch (error) {
                    return;
                }
            }

            var requiresClick = helper.processCyberSourceCallback(component,cyberSourceResponse);
            window.scrollBy(0,1);

            if (requiresClick) {
                if (document !== undefined) {
                    var mouseEvent = document.createEvent("MouseEvents");
                    if (typeof mouseEvent.initMouseEvent === 'function') {
                        if (window.location.pathname.startsWith('/lightning/')) {
                            try {
                                mouseEvent.initMouseEvent("click", true, true, window, 0, 0, 0, 0, 0, false, false, false, false, 0, null);
                                document.dispatchEvent(mouseEvent);
                            } catch (e) {
                                helper.showPaymentProgressAlert(component, helper);
                            }
                        }
                        else {
                            mouseEvent.initMouseEvent("click", true, true, window, 0, 0, 0, 0, 0, false, false, false, false, 0, null);
                            document.dispatchEvent(mouseEvent);
                        }
                    }
                }
            }
        }, false);
    },
    
    dismissPaymentProgress : function (component, event, helper) {
        component.set('v.showPaymentProgress', false);
    },
    
    handleABAmount : function (component, event, helper) {
        console.log("handleABAmount ON CC");
        
        var newAmount = event.getParam('amtFrmAccBalance');
        
        console.log("newAmount ON CC*** " +newAmount);
        
        component.set("v.amount", newAmount);
    },

    /**
     * @description POST the form to Cybersource via the iframe bridge form.
     * @param component
     * @param event
     * @param helper
     */
    submitFormData : function (component, event, helper) {
        helper.POSTFormData(component, helper);
    }

})