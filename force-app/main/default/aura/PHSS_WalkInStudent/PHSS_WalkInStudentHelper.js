({
    isCommunityCls : function(component) {
    	var action = component.get('c.isCommunityClass');
		
        action.setParams({
            classId  : component.get("v.recordId")
        });
        
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var returnValue = response.getReturnValue();
                if (returnValue != null && returnValue.Error == null) {
                    component.set('v.isCommunityCourse',returnValue);
                } else if (returnValue != null && returnValue.Error != null) {
                    this.showToastMessage('Error initializing case form', returnValue.Error, 'Error')
                }
            } else {
                this.showToastMessage('Error initializing case form', 'Unable to contact server.', 'Error');
            }
        });
        $A.enqueueAction(action);	    
    },
    
	initCaseWrapper : function(component) {
        var action = component.get('c.initCaseFormWrapper');

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var returnValue = response.getReturnValue();
                if (returnValue != null && returnValue.Error == null) {
                    component.set('v.formWrap',returnValue);
                } else if (returnValue != null && returnValue.Error != null) {
                    this.showToastMessage('Error initializing case form', returnValue.Error, 'Error')
                }
            } else {
                this.showToastMessage('Error initializing case form', 'Unable to contact server.', 'Error');
            }
        });
        $A.enqueueAction(action);
    },
    
    saveCase : function(component, event, helper) {
        var action = component.get('c.createCase');
		
        console.log('caseJson..'+JSON.stringify(component.get("v.formWrap")));
        console.log('classId..'+component.get("v.recordId"));
        
        action.setParams({
            caseJson : JSON.stringify(component.get("v.formWrap")),
            classId  : component.get("v.recordId")
        });
        
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var returnValue = response.getReturnValue();
                if (returnValue != null && returnValue.Error == null) {
                    var popUpText = "Case Number : " +returnValue['CaseNumber']
                    			    + "\nCourse Name : " +returnValue['CourseName']
                    			    + "\nDate : " +returnValue['Date'];
                    window.confirm(popUpText);
                    console.log('result..'+JSON.stringify(returnValue));
                    component.set("v.showForm",false);
                } else if (returnValue != null && returnValue.Error != null) {
                    this.showToastMessage('Error initializing case form', returnValue.Error, 'Error')
                }
            } else {
                this.showToastMessage('Error initializing case form', 'Unable to contact server.', 'Error');
            }
        });
        $A.enqueueAction(action);
    },
    
    showToastMessage: function (header, message, type) {
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            title: header,
            message: message,
            type: type
        });
        toastEvent.fire();
    },
})