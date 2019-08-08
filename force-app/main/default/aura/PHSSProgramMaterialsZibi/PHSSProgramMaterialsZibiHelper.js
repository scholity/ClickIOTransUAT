({
    getMaterialsByProgram: function(component) {
//        var that = this;
        var action = component.get("c.getMaterialsByProgramApex");
        action.setParams({
            programID : component.get("v.recordId"),
            isCandidateMaterial: component.get('v.isCandidateMaterial')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var materials = response.getReturnValue();

                if (materials.length > 0) {
					var appEvent = $A.get("e.c:PHSSProgramMaterialLoadedEvent");
					appEvent.setParams({
						"materials" : materials});
					appEvent.fire();
                }
            }
        });
        $A.enqueueAction(action);
    },

	getProgramDetails: function(component) {
        var action = component.get("c.getProgramDetailsApex");
        action.setParams({programID : component.get("v.recordId")});
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var program = response.getReturnValue();
                if (program) {
                    component.set("v.programName", program.Program_Long_Name__c);
                    component.set("v.programDescription", program.Description__c);
                }
            }
        });
        $A.enqueueAction(action);
    }
})