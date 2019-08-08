({
	sendData : function(component) {
		component.getEvent('caseCommentModalSave').setParams({
			comment: component.get('v.comment'),
			index: component.get('v.index')
		}).fire();
	},
	clear: function(component){
		component.set('v.isShown', false);
		component.set('v.comment', '');
		component.set('v.isCreate', true);
		component.set('v.index', null);
	}
})