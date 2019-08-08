({
	loadLimitedCaseComments : function(component) {
		var action = component.get('c.getCaseComments');
		action.setParams({
			caseId: component.get('v.recordId'),
			numberOfElements: component.get('v.numberOfElements')
		});
		action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set('v.caseComments', response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	},
	loadAllCaseComments: function(component){
		var action = component.get('c.getAllCaseComments');
		action.setParams({
			caseId: component.get('v.recordId')
		});
		action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set('v.caseComments', response.getReturnValue());
                component.set('v.isAll', true);
            }
        });
        $A.enqueueAction(action);
	}, 
	deleteComment: function(component, index){
		var action = component.get('c.deleteComment');
		var material = component.get('v.caseComments')[index];
		action.setParams({
			commentId: material.commentId
		});
		var _this = this;
		action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS" && response.getReturnValue()) {
            	if(component.get('v.isAll')){
            		_this.loadAllCaseComments(component);
            	} else {
            		_this.loadLimitedCaseComments(component);
            	}
            }
        });
        $A.enqueueAction(action);
	},
	openModal: function(component, index){
		var modal = component.find('modal');
		if(index === null || index === undefined || index < 0){
			modal.set('v.isCreate', true);
			modal.set('v.comment', '');
			modal.set('v.index', null);
			modal.set('v.isShown', true);
		} else {
			var caseComment = component.get('v.caseComments')[0];
			modal.set('v.isCreate', false);
			modal.set('v.comment', caseComment.commentBody);
			modal.set('v.index', index);
			modal.set('v.isShown', true);
		}
	},
	createComment: function(component, comment){
		var action = component.get('c.createComment');
		action.setParams({
			caseId: component.get('v.recordId'),
			commentBody: comment
		});
		var _this = this;
		action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS" && response.getReturnValue()) {
            	if(component.get('v.isAll')){
            		_this.loadAllCaseComments(component);
            	} else {
            		_this.loadLimitedCaseComments(component);
            	}
            }
        });
        $A.enqueueAction(action);
	},
	updateComment: function(component, comment, index){
		var caseComments = component.get('v.caseComments');

		var action = component.get('c.updateComment');
		action.setParams({
			commentId: caseComments[index].commentId,
			newCommentBody: comment
		});
		var _this = this;
		action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS" && response.getReturnValue()) {
            	if(component.get('v.isAll')){
            		_this.loadAllCaseComments(component);
            	} else {
            		_this.loadLimitedCaseComments(component);
            	}
            }
        });
        $A.enqueueAction(action);
	}
})