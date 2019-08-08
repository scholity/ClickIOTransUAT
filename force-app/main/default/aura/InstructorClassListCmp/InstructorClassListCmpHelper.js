({
    getData : function(component) {
        var helper = this;
        var action = component.get("c.getData");
        var offset = component.get("v.offset");
        component.set("v.isDataLoaded", true);
        action.setParams({
            "instructorId" : component.get("v.recordId"),
            "offset" : offset,
            "limitOffset" : component.get("v.limitOffset"),
            "isHistory" : component.get("v.isHistory")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var result = response.getReturnValue();

                if (result.status === 'SUCCESS') {
                    if(result.classWrappers){
                        moment.locale(result.lang);
                        var res = result.classWrappers;
                        for(var i=0; i<res.length; i++){
                            res[i].formattedStartDate =  moment(res[i].startDate).format('L');
                        }
                        if( !component.get("v.isHistory")){
                            component.set('v.currentClasses', res);
                            helper.sortFields(component, 'current', 'startDate', 'asc');
                        } else{
                            component.set('v.historyClasses', res);
                            helper.sortFields(component, 'history', 'startDate', 'asc');
                        }
                    }
                } else {
                    console.log('error');
                }

            } else {
                console.log('error');
            }
            component.set("v.isDataLoaded", false);
        });

        $A.enqueueAction(action);
    },
    sortFields : function(component, array, field, order) {
        var resultArray = component.get("v." + array + "Classes");
        resultArray = resultArray.sort(function(first, second){
            var a = first[field];
            var b = second[field];
            if(a > b) {
                return order === 'asc' ? 1 : -1;
            } else if(a < b) {
                return order === 'asc' ? -1 : 1;
            } else {
                return 0;
            }
        });
        component.set("v.sortField", field);
        component.set("v.sortOrder", order);
        component.set("v." + array + "Classes", resultArray);
    }
})