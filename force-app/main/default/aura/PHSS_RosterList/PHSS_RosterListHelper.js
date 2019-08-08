({
    getData : function(component) {
        var recordId = component.get("v.recordId");
        if($A.util.isEmpty(recordId)){
            var recordIdpattern = new RegExp("[?&]recordId=(([^&]*)&?|&|$)");
            var urlRecordId = recordIdpattern.exec(location.href);
            //var urlRecordId = /[?&]urlRecordId(=([^&]*)|&|$)/.exec(location.href);
            if (urlRecordId != null && urlRecordId.length > 2 && urlRecordId[2] != null && urlRecordId[2].length > 2) {
                recordId = urlRecordId[2];
            }
        }
        var planId = '';
        var planIdpattern = new RegExp("[?&]pId=(([^&]*)&?|&|$)");
        var urlPlanId = planIdpattern.exec(location.href);        
        //var urlPlanId = /[&]pId(=([^&]*)|&|$)/.exec(location.href);
        if (urlPlanId != null && urlPlanId.length > 2 && urlPlanId[2] != null && urlPlanId[2].length > 2) {
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