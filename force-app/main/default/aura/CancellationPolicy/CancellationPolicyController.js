({
	handlePolicy : function(component, event, helper) {
		component.set("v.stepNumber","One");
	},
    
    handleCancel : function(component, event, helper) {
		component.set("v.stepNumber","Zero");
	}
})