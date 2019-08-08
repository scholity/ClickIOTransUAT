({
	getVouchers : function(component, event, helper) {
		var action = component.get("c.getVoucherList");
    
        action.setParams({ recId : component.get("v.recordId") });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.vouchList",response.getReturnValue());
                console.log(response.getReturnValue()[0]);
                console.log('closed '+response.getReturnValue()[0].ILT_Class__r.Class_Closed_Date__c);

                if (response.getReturnValue()[0].ILT_Class__r.Class_Closed_Date__c) {
                    component.set("v.classClosed", true );
                }
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
	},

    unenrollStudent : function(component, event, helper) {

        component.set("v.showSpinner", true);
        var action = component.get("c.cancelEnrollment");

        action.setParams({ recId : component.get("v.voucherId") });

        action.setCallback(this, function(response) {
            component.set("v.showSpinner", false);
            component.set("v.showModal",false);

            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.cancelMessage",response.getReturnValue());
                this.getVouchers(component, event, helper);
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    }
})