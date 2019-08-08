({
	goToProgram: function(component, event, helper) {
		$A.get("e.force:navigateToURL").setParams({
			url: '/phss-program/' + component.get('v.program.Id')
		}).fire();
	}
})