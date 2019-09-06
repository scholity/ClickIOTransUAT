({
	checkOnAccount: function(component, event, helper)
    {
        var action = component.get('c.getOnAccountBoolean');
        
        var orderId = component.get("v.recordId");
        
        action.setParams({ orderId : orderId });
        
        action.setCallback(this, function(response) 
		{
            var state = response.getState();
            if (state === "SUCCESS")
            {   
                var storeResponse = response.getReturnValue();
                console.log("storeResponse***"+storeResponse);
                if (storeResponse != null)
                {
                    component.set("v.showCreditOnAccount",storeResponse);
                }
                           
            }
        });
        $A.enqueueAction(action);
    },
})