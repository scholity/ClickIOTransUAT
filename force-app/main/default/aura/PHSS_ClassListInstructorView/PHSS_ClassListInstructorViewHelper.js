({
	getValues : function(component) {
		var action = component.get("c.getPicklistValues");
        action.setParams({
            "objName" : component.get("v.objName"),
            "accId"   : component.get("v.selectedAccount")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var result = response.getReturnValue();
                if (state === 'SUCCESS') {
                	 if(component.get("v.objName") == "Account") {
                    	component.set("v.accountList",result);    
                    }
                    else {
                        component.set("v.instList",result);
                        if(component.get("v.instList").length == 1) {
                            component.set("v.selectedInstructor",component.get("v.instList")[0].Id);
            			}
                        else {
                            component.set("v.selectedInstructor","");
                        }
                    }
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
    
    getData : function(component) {
        var action = component.get("c.getClasses");
        console.log('account..'+component.get("v.selectedAccount"));
        console.log('instructor..'+component.get("v.selectedInstructor"));
        action.setParams({
            "offset"      : component.get("v.offset"),
            "limitOffset" : component.get("v.limitOffset"),
            "isHistory"   : component.get("v.isHistory"),
            "accId"       : component.get("v.selectedAccount"),
            "instructorId": component.get("v.selectedInstructor")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var result = response.getReturnValue();

                if (state === 'SUCCESS') {
                    
                    if( !component.get("v.isHistory")){
                        component.set('v.currentClasses', result);
                        this.sortFields(component, 'current', 'startDate', 'asc');
                    } else{
                        component.set('v.historyClasses', result);
                        this.sortFields(component, 'history', 'startDate', 'asc');
                    }
                } else {
                    console.log('error');
                }

            } else {
                console.log('error');
            }
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
    },
})