({
	goToCommentOwner : function(component) {
		$A.get("e.force:navigateToURL").setParams({
			url: '/profile/' + component.get('v.caseComment.ownerId')
		}).fire();
	},
	deleteComment: function(component, event, helper){
		helper.fireAction(component, 'DELETE');
	},
	updateComment: function(component, event, helper){
		helper.fireAction(component, 'UPDATE');
	}
})