({
    getMaterials: function(component) {
        var action = component.get('c.getMaterialsByTagsOrLibrary');
        action.setParams({
            libaryName: component.get('v.libraryName'),
            tagsCsv: component.get('v.tagsCsv'),
            isCandidateMaterial: component.get('v.isCandidateMaterial')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var materials = response.getReturnValue();
                if (materials.length > 0) {
                    // component.getEvent("ProgramMaterialList").setParams({
                    //     "materials": materials
                    // }).fire();
                    component.set('v.materials', materials);
                    component.set('v.shouldProcess', true);
                }
            }
        });
        $A.enqueueAction(action);
    }
})