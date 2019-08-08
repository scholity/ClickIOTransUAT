({
    getValues : function(component) {
        var action = component.get("c.getPicklistValues");
        console.log('objName..'+component.get("v.objName"));
        console.log('accId..'+component.get("v.selectedAccount"));
        action.setParams({
            "objName" : component.get("v.objName"),
            "objInsName":component.get("v.objInsName"),
            "accId"   : component.get("v.selectedAccount")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var result = response.getReturnValue();
                if (state === 'SUCCESS') {
                    console.log('Expected result'+JSON.stringify(result));
                    
                    // if(component.get("v.objName") == "Account") {
                    component.set("v.accountList",result);
                    
                    component.set("v.instList",result);
                    
                    
                    
                } 
                else {
                    console.log('error');
                }
            } 
            else {
                console.log('error');
            }
        });
        $A.enqueueAction(action);	
    },
    sortBy: function(component, field) {
        var sortAsc = component.get("v.sortAsc"),
            sortField = component.get("v.sortField"),
            Listss = component.get("v.Listss");
        sortAsc = field == sortField? !sortAsc: true;
        records.sort(function(a,b){
            var t1 = a[field] == b[field],
                t2 = a[field] > b[field];
            return t1? 0: (sortAsc?-1:1)*(t2?-1:1);
        });
        component.set("v.sortAsc", sortAsc);
        component.set("v.sortField", field);
        component.set("v.records", Listss);
    }
})