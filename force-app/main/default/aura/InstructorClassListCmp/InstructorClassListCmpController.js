({
    doInit : function(component, event, helper) {
        helper.getData(component);
    },
    handleSelectTab : function(component, event, helper){
        var nameTab = event.getParam('id');
        var selectedTab = component.get("v.selectedTab");
        var isNeedUpdatedData = true;
        if(selectedTab === nameTab){
            isNeedUpdatedData = false;
        } else{
            component.set("v.isHistory", !component.get("v.isHistory"));
        }
        if(isNeedUpdatedData){
            helper.getData(component);
        }
        component.set("v.selectedTab", nameTab);
    },
    goToDetail : function(component, event, helper){
        var url = location.href;
        url= url.split('/s/');
        window.location.href = url[0] + '/s/ilt-detail?recordId=' + event.target.dataset.id + '&pId=' + (event.target.dataset.pid ? event.target.dataset.pid : 'null');
        /*var navEvt = $A.get("e.force:navigateToURL");
        navEvt.setParams({
            "url": 'ilt-detail?urlRecordId=' + event.target.dataset.id + '&pId=' + (event.target.dataset.pid ? event.target.dataset.pid : 'null'),
            "isredirect": true
        });
        navEvt.fire();*/
    },
    sortField : function(component, event, helper) {
        var dataset = event.target.dataset;
        helper.sortFields(component, dataset.array, dataset.field, dataset.order);
    }
})