({
    doInit: function(component, event, helper){
        helper.getILTClassData(component);
    },
    handleRefreshEvent: function (component, event, helper) {
        if (event.getParams().isRegistrationEvent) {
            helper.getILTClassData(component);
        }
    }
})