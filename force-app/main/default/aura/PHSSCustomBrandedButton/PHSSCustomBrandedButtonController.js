({
	handleClick : function(component, event, helper) {
        var attr_value = component.get("v.buttonURL");
		// Find the text value of the component with aura:id set to "address"
    	var address = component.find("address").get("v.value");
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({"url": attr_value});
        urlEvent.fire();
	} 
})