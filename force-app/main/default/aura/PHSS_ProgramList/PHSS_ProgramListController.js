({
	onInit : function(component, event, helper) {
		helper.loadFeatured(component);
	},
	getAll: function(component, event, helper){
		helper.loadAll(component);
	}
})