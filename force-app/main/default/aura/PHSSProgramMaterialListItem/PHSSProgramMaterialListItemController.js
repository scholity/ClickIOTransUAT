({
	doInit : function(component, event, helper) {
		// var isSafari = /^((?!chrome|android).)*safari/i.test(navigator.userAgent);
		var isSafari = new RegExp('^((?!chrome|android).)*safari', 'i').test(navigator.userAgent);
		var materialType = component.get('v.materialObject.Type__c');
		if(isSafari && materialType === 'Video'){
			component.set('v.previewAvailable', false);
		}else{
			component.set('v.previewAvailable', true);
		}
		component.set('v.isLink', materialType === 'Link');
	},
	toggle: function(component, event, helper) {
		if(component.get('v.isLink')){
			var material = component.get('v.materialObject');
			$A.get("e.force:navigateToURL").setParams({
				url: component.get('v.materialObject.ContentVersionContentURL__c')
			}).fire();
		} else {
			var appEvent = $A.get("e.c:PHSSProgramMaterialListItemToggleEvent");
	        appEvent.setParams({
	            "materialId" : component.get('v.materialObject.Id')});
	        appEvent.fire();
			component.set('v.expanded',!component.get('v.expanded'));
		}
	},
	handleToggle: function(component, event, helper) {
		var materialId = event.getParam("materialId");
		if(materialId !== component.get('v.materialObject.Id')){
			component.set('v.expanded', false);
		}
	},
	openLink: function(component, event, helper){
		
	}
})