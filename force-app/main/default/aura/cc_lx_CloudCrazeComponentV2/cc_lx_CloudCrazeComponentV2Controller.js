({
	doInit : function(component, event, helper) {
        component.set("v.context", {});
		helper.getNetworkInfo(component, helper);
		helper.getQueryString(component, helper);
	}
})