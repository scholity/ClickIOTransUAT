({
    doInit : function(component, event, helper){
        helper.getData(component, event, helper);
    },
    afterScriptsLoaded : function(component, event, helper) {
        component.set('v.isDataLoaded', true);
    }
})