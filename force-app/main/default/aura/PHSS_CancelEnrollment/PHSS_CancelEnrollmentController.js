({
    doInit : function(component, event, helper) {
    	helper.checkIfCancelled(component, event, helper);
    },
    
    cancelEnrollment1 : function(component, event, helper) {
        helper.cancelEnrollment1(component, event, helper);
    },
    
    // Close the action panel
    closePanel : function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
	}
})