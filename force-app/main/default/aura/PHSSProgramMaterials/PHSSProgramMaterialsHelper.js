({
    getMaterialsByProgram: function(component) {
//        var that = this;
        var action = component.get("c.getMaterialsByProgramApex");
        action.setParams({programID : component.get("v.recordId")});
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var materials = response.getReturnValue();
                if (materials.length > 0) {
                    component.set("v.phssMaterialsAll", materials);
                }
            }
        });
        $A.enqueueAction(action);
    },
	getProgramNameByID: function(component) {
//        var that = this;
        var action = component.get("c.getProgramNameByIDApex");
        action.setParams({programID : component.get("v.recordId")});
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var programname = response.getReturnValue();
                if (programname.length > 0) {
                    component.set("v.programName", programname);
                }
            }
        });
        $A.enqueueAction(action);
    },
	getMaterialsInstructorDocumentByProgram: function(component) {
//        var that = this;
        var action = component.get("c.getMaterialsByCategoryTypeByProgramApex");
        action.setParams({programID : component.get("v.recordId"),
                          category : component.get("v.categoryInstructorDocuments"),
                          type : component.get("v.typeInstructorDocuments")});
        console.log('LOG MESSAGE');
        console.log('recordID : ' + component.get("v.recordId"));
        console.log('category : ' + component.get("v.categoryInstructorDocuments"));
        console.log('type : ' + component.get("v.typeInstructorDocuments"));        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var mID = response.getReturnValue();
                if (mID.length > 0) {
                    component.set("v.phssMaterialsInstructorDocuments", mID);
                }
            }
        });
        $A.enqueueAction(action);
    }    
    
})