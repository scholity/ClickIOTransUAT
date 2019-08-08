({
    doInit : function(component, event, helper) {
        // load messages from the backend
        helper.getMessages(component);
    },
    handleClick : function(cmp, event) {
        var attributeValue = cmp.get("v.show");
        cmp.set("v.show", "false");
	}
})