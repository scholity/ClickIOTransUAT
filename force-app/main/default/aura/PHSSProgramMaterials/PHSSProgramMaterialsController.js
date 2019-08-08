({
    doInit : function(component, event, helper) {
		helper.getProgramNameByID(component);
        helper.getMaterialsByProgram(component);
        helper.getMaterialsInstructorDocumentByProgram(component);
    }
})