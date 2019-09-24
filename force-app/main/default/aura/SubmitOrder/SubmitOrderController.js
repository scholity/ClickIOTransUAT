({
    doInit : function(component,event,helper)
    {
        helper.checkOnAccount(component,event,helper);
    },
    
    showStep1 : function(component,event,helper)
    {        
        component.set("v.stepNumber", "One");
    },
    
    showStep0 : function(component,event,helper)
    {        
        component.set("v.stepNumber", "Zero");            
    },
    
    showSpinner: function(component, event, helper)
    {
        component.set("v.Spinner", true); 
    },

    hideSpinner : function(component,event,helper)
    {
        component.set("v.Spinner", false);
    },
    
    processSubmitOrder : function(component,event,helper)
    {
        component.set("v.isSubmitted", true);
        
        var orderId = component.get("v.recordId");
        
        console.log("***orderId***"+orderId);
        
        var onAcc = component.get("v.CreditOnAccount");
        console.log("onAcc***"+onAcc);
        
        if(onAcc)
        {
            console.log("$$$Is TRUE$$$"+onAcc);
            
            var action = component.get("c.submitOrderCredit");
            action.setParams({ orderId : orderId,
                              hasCreditOnAccount : true});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS")
                {
                    console.log("***SUCCESS***");
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title"   : "Success!",
                        "message" : "Order Credit on Account Submitted Successfully.",
                        "type"    : "success"
                    });
                    toastEvent.fire();
                    $A.get("e.force:refreshView").fire();
                    component.set("v.stepNumber", "Zero");
                }
                
            });
            $A.enqueueAction(action);
        }
        else
        {
            console.log("$$$Is FALSE$$$"+onAcc);
            var action = component.get("c.submitOrderCredit");
            action.setParams({ orderId : orderId,
            				   hasCreditOnAccount : false});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS")
                {
                    console.log("***SUCCESS***");
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title"   : "Success!",
                        "message" : "Order Credit Submitted Successfully.",
                        "type"    : "success"
                    });
                    toastEvent.fire();
                    $A.get("e.force:refreshView").fire();
                    component.set("v.stepNumber", "Zero");
                }
                
            });
            $A.enqueueAction(action);
        }
        
    },
})