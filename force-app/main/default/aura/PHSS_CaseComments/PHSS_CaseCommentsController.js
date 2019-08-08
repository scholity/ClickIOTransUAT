({
	createNewComment : function(component, event, helper) {
		helper.openModal(component, null);
	},
	onInit: function(component, event, helper){
		helper.loadLimitedCaseComments(component);
	},
	onCommentAction: function(component, event, helper){
		var action = event.getParam('actionName');
		var index = event.getParam('index');
		if(action === 'DELETE'){
			helper.deleteComment(component, index);
		} else if(action === 'UPDATE'){
			helper.openModal(component, index);
		}
	},
	onModalSave: function(component, event, helper){
		var index = event.getParam('index');
		var comment = event.getParam('comment');
		if(index === null || index === undefined || index < 0){
			helper.createComment(component, comment);
		} else {
			helper.updateComment(component, comment, index);
		}
	},
	getAll: function(component, event, helper){
		helper.loadAllCaseComments(component);
	}
})