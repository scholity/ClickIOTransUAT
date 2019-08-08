({
	handleGlobalMaterials : function(component, event, helper) {
		if(component.get('v.isUsingGlobalEvent')){
			helper.processMaterials(component, event.getParam("materials"));
		}
	},
	filterMaterials: function(component, event, helper) {
		helper.filterMaterials(component, event);
	},
	handleSearch: function(component, event, helper) {
		helper.filterMaterials(component, event);
	},
	showMore: function(component, event, helper) {
		var newDisplayNum = component.get('v.currentDisplayNum')+component.get('v.initalDisplayNum');
		var materials = component.get('v.filteredMaterials');
		if(materials.length>newDisplayNum){
			component.set('v.showMoreButton', true);
		}

		component.set('v.currentDisplayNum', newDisplayNum);
		helper.filterMaterials(component);
	},
	handleLocalMaterials: function(component, event, helper){
		if(!component.get('v.isUsingGlobalEvent')) {
			helper.processMaterials(component, component.get("v.materials"));
		}
	}
})