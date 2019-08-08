({
    checkIfCancelled : function(component, event, helper) {
        var action = component.get("c.checkIfCancelled");
    
        action.setParams({ recId : component.get("v.recordId") });
    
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.status",response.getReturnValue());
                console.log('status..'+component.get("v.status"));
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },
    
	cancelEnrollment1 : function(component, event, helper) {
		var action = component.get("c.cancelEnrollment");
    
        action.setParams({ recId : component.get("v.recordId") });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                // Display the total in a "toast" status message
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Cancel Enrollment",
                    "message": "Enrollment cancelled successfully"
                });
                resultsToast.fire();

                // Close the action panel
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
        		dismissActionPanel.fire();

        		//navigate to ILT class
                this.navigateToIltClass(component, event);
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);	
	},

	navigateToIltClass: function (component, event) {

        var pageReference = {
            type: 'standard__recordPage',
            attributes: {
                "recordId": component.get("v.rosterFields.redwing__ILT_Class__c"),
                "objectApiName": "redwing__ILT_Class__c",
                "actionName": "view"
            }
        };

        var navService = component.find("navService");
        event.preventDefault();
        navService.navigate(pageReference);
    }
})