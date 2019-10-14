({
    getValues : function(component, helper) {
        var action = component.get("c.getPicklistValues");
        action.setParams({
            "objName" : component.get("v.objName"),
            "accId"   : component.get("v.selectedAccount")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var result = response.getReturnValue();
                if(component.get("v.objName") == "Account") {
                    component.set("v.accountList",result);    
                }
            } 
            else {
                console.log('error');
            }
        });
        $A.enqueueAction(action);	
    },
    
    toggleSpinner:function(component, helper) {
        component.set('v.loadingSpinner', !component.get('v.loadingSpinner')); 
    },
    
    getData : function(component, helper) {
        //For date Validation
        if(component.get("v.selectedAccount") != '' && component.get("v.selectedAccount") != null && component.get("v.StartDateFrom") != '' && component.get("v.StartDateFrom") != null && component.get("v.StartDateTo") != '' && component.get("v.StartDateTo") != null)
        {
            var maxEndDate = new Date(component.get("v.StartDateFrom"));
            maxEndDate.setDate(maxEndDate.getDate() + 90);
            if(new Date(component.get("v.StartDateTo")) > maxEndDate)
            {
                component.set("v.isError", true);
                component.set("v.messageType", 'error');
                component.set("v.message",'Date difference between Start date from and Start date to cannot exceed 90 days.');
                return;
            }
            component.set("v.isError", false);
            
            //Actual Logic
            helper.toggleSpinner(component, helper);
            var action = component.get("c.getClasses");
            console.log('selectedLookUpRecord..'+component.get("v.selectedLookUpRecord"));
            var startDateFromVar;
            var startDateToVar;
            var courseId;
            if(component.get("v.StartDateFrom") != '')
                startDateFromVar = component.get("v.StartDateFrom");
            if(component.get("v.StartDateTo") != '')
                startDateToVar = component.get("v.StartDateTo");
            if(component.get("v.selectedLookUpRecord") != '' && component.get("v.selectedLookUpRecord") != null && component.get("v.selectedLookUpRecord") != {})
                courseId = component.get("v.selectedLookUpRecord").Id;
            action.setParams({
                "offset"      : component.get("v.offset"),
                "limitOffset" : component.get("v.limitOffset"),
                "accId"       : component.get("v.selectedAccount"),
                "startDateFrom" : startDateFromVar,
                "startDateTo" : startDateToVar,
                "courseId" : courseId
            });
            
            action.setCallback(this, function(response) {
                helper.toggleSpinner(component, helper);
                var state = response.getState();
                if (state === 'SUCCESS') {
                    var result = response.getReturnValue();
                    component.set('v.Classes', result);
                    //this.sortFields(component, 'startDate', 'asc');
                } else {
                    console.log('error');
                }
            });
            
            $A.enqueueAction(action);
        }
    },
    
    sortFields : function(component, field, order) {
        var resultArray = component.get("v.Classes");
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
        component.set("v.Classes", resultArray);
    }
})