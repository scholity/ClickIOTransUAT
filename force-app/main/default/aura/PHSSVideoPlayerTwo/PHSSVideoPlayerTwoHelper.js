({
	getPHSSMaterialByID: function(component) {
        var action = component.get("c.getPHSSMaterialDetails");
        var recID = component.get("v.recordId");     
        action.setParams({phssID : component.get("v.recordId")});
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var materials = response.getReturnValue();
                if (materials.length > 0) {
                    component.set("v.phssMaterial", materials);
                    component.set("v.phssMaterialVideoURL", materials[0].ContentVersionLink__c);
                    if (materials[0].Type__c === 'Video') {
	                    component.set("v.phssMaterialTypeIsVideo", "true");                                            
                    } else {
                        component.set("v.phssMaterialTypeIsVideo", "false");                                            
                    }
                    component.set("v.VideoTitle", materials[0].Material_Name__c);
                    component.set("v.VideoDescription", materials[0].Description__c);
                    component.set("v.ContentVersionID", materials[0].ContentVersionID__c);
                    component.set("v.ContentDocumentID", materials[0].ContentDocumentID__c);
                }
            }
        });
        $A.enqueueAction(action);
    },
    getURLParamByName: function(component) {
        var action = component.get("c.getURLParam");
        action.setParams({paramName : component.get("v.urlParamName")});
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var paramVal = response.getReturnValue();
                if (paramVal.length > 0) {
                    component.set("v.urlParamValue", paramVal);
                }
            }
        });
        $A.enqueueAction(action);
    }
})