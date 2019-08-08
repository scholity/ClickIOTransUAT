({
    getData : function(component) {
        var recordId = component.get('v.recordId');
        if($A.util.isEmpty(recordId)){
            var urlRecordId = /[?&]urlRecordId(=([^&]*)|&|$)/.exec(location.href);
            if (urlRecordId != null && urlRecordId.length > 2 && urlRecordId[2] != null) {
                recordId = urlRecordId[2];
            }
        }
        var planId = '';
        var urlPlanId = /[&]pId(=([^&]*)|&|$)/.exec(location.href);
        if (urlPlanId != null && urlPlanId.length > 2 && urlPlanId[2] != null) {
            planId = urlPlanId[2];
        }
        var action = component.get('c.getData');
        action.setParams({
            "classId" : recordId,
            "planId" : planId
        });
        component.find("templateMainCmp").doRequest(action, function(result){
            if(result.RCUserWrappers){
                component.set('v.students', result.RCUserWrappers);
                var colWidth = '35';
                if(result.RCUserWrappers.length > 9999){
                    colWidth = '54'
                } else if(result.RCUserWrappers.length > 999){
                    colWidth = '47'
                } else if(result.RCUserWrappers.length > 99){
                    colWidth = '40'
                }
                component.set("v.colWidth", colWidth);
            }
        });
    }
});