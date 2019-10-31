({
    doInit : function(component, event, helper) {
        helper.getRecords(component, event, helper);
    },
    handleIsSelectAll : function(component, event, helper) {
        if(component.get("v.isSelectAll"))
        {
            var accConList = component.get("v.accountContactsList");
            for(var i = 0; i < accConList.length; i++)
            {
                accConList[i].isChecked = true;
            }
            component.set("v.accountContactsList",accConList);            
        }
        else
        {
            var accConList = component.get("v.accountContactsList");
            for(var i = 0; i < accConList.length; i++)
            {
                accConList[i].isChecked = false;
            }
            component.set("v.accountContactsList",accConList); 
        }
    },
    removeAffiliation : function(component, event, helper) {
        var message ='Remove Affiliation:  The instructor or administrator will be removed from the organization’s approved list of instructors and/or administrators and will no longer be able to view or perform actions associated to this organization.';
        if (confirm(message)) 
            helper.removeAffiliation(component, event, helper);
        else
            return;
    }
})