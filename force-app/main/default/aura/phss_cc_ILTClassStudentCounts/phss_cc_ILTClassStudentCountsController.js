({
	doInit : function(component, event, helper) {
		helper.validateNumberOfEvaluations(component);
	},

	handleNumberChanged : function(component, event, helper) {
		console.log("handleNumberChanged() " + event.getSource().get("v.value"));
		helper.validateNumberOfEvaluations(component);
	}
})