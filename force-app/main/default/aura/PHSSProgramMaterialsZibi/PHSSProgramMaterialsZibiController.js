({
    doInit : function(component, event, helper) {
		helper.getProgramDetails(component);
        helper.getMaterialsByProgram(component);
    }
})