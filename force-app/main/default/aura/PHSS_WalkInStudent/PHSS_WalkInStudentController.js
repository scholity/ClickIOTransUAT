({
	doInit: function (component, event, helper) {
        helper.isCommunityCls(component);
        helper.initCaseWrapper(component);
    },
    
    showCaseForm : function(component, event, helper)  {
    	component.set("v.showForm",true);
    },
    
    cancel : function(component, event, helper) {
        component.set("v.showForm",false);
    },
    
    saveCase : function(component, event, helper) {
        helper.saveCase(component, event, helper);
    }
})