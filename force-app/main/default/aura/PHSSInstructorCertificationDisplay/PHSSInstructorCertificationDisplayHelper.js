({	
    getFilteredCerts : function(component) {        
        var action = component.get("c.getInstructorCertificationDetailsFiltered");     
        action.setParams({numberOfElements: component.get('v.numberOfElements')});
        action.setCallback(this, function(a) {
            component.set("v.certificationsLimited", a.getReturnValue());
        });
        $A.enqueueAction(action);        
	},
    getAllCerts : function(component) {
        var action = component.get("c.getInstructorCertificationDetails");
        action.setParams({userID: component.get('v.recordId')});        
        action.setCallback(this, function(a) {
            component.set("v.certifications", a.getReturnValue());
        });
        $A.enqueueAction(action);        
	},
	getFilteredSortedCerts : function(component) {        
        var action = component.get("c.getInstructorCertificationDetailsSorted");     
        action.setParams({sortOrder: component.get('v.sortOrderAscending'),
                          sortColumn: component.get('v.sortColumn'),
                          numberOfElements: component.get('v.numberOfElements')});
        action.setCallback(this, function(a) {
            component.set("v.certificationsLimited", a.getReturnValue());
        });
        $A.enqueueAction(action);        
	}    
})