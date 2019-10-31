({
    toggleSpinner:function(component, helper) {
        component.set('v.loadingSpinner', !component.get('v.loadingSpinner')); 
    },
    getRecords : function(component, event, helper) {
        helper.toggleSpinner(component, helper);
        var action = component.get("c.getAccountContactDetails");
        action.setCallback(this, function(response) {
            helper.toggleSpinner(component, helper);
            console.log(response.getReturnValue());
            var state = response.getState();
            if (state === 'SUCCESS'){
                var result = response.getReturnValue();
                component.set("v.accountContactsList",result); 
            } 
            else {
                console.log('error');
            }
        });
        $A.enqueueAction(action);	
    },
    removeAffiliation : function(component, event, helper){
        //Validation
        var isValid = false;
        var accConList = component.get("v.accountContactsList");
        for(var i = 0; i < accConList.length; i++)
        {
            if(accConList[i].isChecked)
                isValid = true;
        } 
        if(!isValid)
        {
            component.set("v.isError", true);
            component.set("v.messageType", 'error');
            component.set("v.message",'You have not selected any account to remove');
            return;
        }
        
        //Actual Logic
        helper.toggleSpinner(component, helper);
        var action = component.get("c.removeAccountContactDetails");
        action.setParams({ AccountContactRelationWrapperString : JSON.stringify(component.get("v.accountContactsList"))});
        action.setCallback(this, function(response) {
            helper.toggleSpinner(component, helper);
            console.log(response.getReturnValue());
            var state = response.getState();
            if (state === 'SUCCESS'){
                var result = response.getReturnValue();
                component.set("v.accountContactsList",result); 
                component.set("v.isError", false);
            } 
            else {
                console.log('error');
            }
        });
        $A.enqueueAction(action);
    }
})