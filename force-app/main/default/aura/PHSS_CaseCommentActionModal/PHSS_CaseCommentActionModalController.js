({
	closeModal : function(component) {
		component.set('v.isShown', false);
	},
	saveComment: function(component, event, helper){
		helper.sendData(component);
		helper.clear(component);
	}
})