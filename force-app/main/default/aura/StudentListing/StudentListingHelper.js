({
    toggleSpinner:function(component, helper) {
        component.set('v.loadingSpinner', !component.get('v.loadingSpinner')); 
    },
    
    getValues : function(component, event, helper) {
        helper.toggleSpinner(component, helper);
        var action = component.get("c.getPicklistValues");
        action.setParams({
            "objName" : component.get("v.objName"),
            "accId"   : component.get("v.selectedAccount")
        });
        action.setCallback(this, function(response) {
            helper.toggleSpinner(component, helper);
            var state = response.getState();
            if (state === 'SUCCESS') {
                var result = response.getReturnValue();
                if (state === 'SUCCESS') {
                    if(component.get("v.objName") == "Account") {
                        component.set("v.accountList",result);    
                    }
                    else {
                        if(result.length == 1)
                        {
                            component.set("v.instList",result);
                            component.set("v.selectedInstructor",component.get("v.instList")[0].Id);
                        }
                        else if(result.length > 1)
                        {
                            result.unshift({"Id" : "ALL", "Name" : "ALL"});
                            component.set("v.instList",result);
                            component.set("v.selectedInstructor","ALL");
                        }
                        this.fetchIns(component, event, helper);
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
    },
    fetchIns : function(component, event, helper) {
        //For date Validation
        if(component.get("v.expirationDateFrom") != '' && component.get("v.expirationDateFrom") != null && component.get("v.expirationDateTo") != '' && component.get("v.expirationDateTo") != null && component.get("v.selectedAccount") != '' && component.get("v.selectedAccount") != undefined && component.get("v.selectedAccount") != null)
        {
            var maxEndDate = new Date(component.get("v.expirationDateFrom"));
            maxEndDate.setDate(maxEndDate.getDate() + 90);
            if(new Date(component.get("v.expirationDateTo")) > maxEndDate)
            {
                component.set("v.isError", true);
                component.set("v.messageType", 'error');
                component.set("v.message",'Date difference between Expiration date from and Expiration date to cannot exceed 90 days.');
                return;
            }
            component.set("v.isError", false);
            
            //Actual Logic
            helper.toggleSpinner(component, helper);
            var action = component.get("c.fetchAchv");
            var orgId 	= component.get("v.selectedAccount");
            var InsId   = component.get("v.selectedInstructor");
            var orgg = [];
            var Ins = [];
            if((orgId!=null && InsId!=undefined && orgId!='' && InsId!=''))
            {
                if(orgId == 'ALL')
                {
                    var accountDetailsFromServer = component.get("v.selectedAccount");
                    for(var i in  accountDetailsFromServer)
                    {
                        orgg.push(accountDetailsFromServer[i].Id);
                    }
                }
                else
                    orgg.push(orgId);
                
                if(InsId == 'ALL')
                {
                    var userDetailsFromServer = component.get("v.instList");
                    for(var i in  userDetailsFromServer)
                    {
                        if(userDetailsFromServer[i].Id != 'ALL')
                            Ins.push(userDetailsFromServer[i].Id);
                    }
                }
                else
                    Ins.push(InsId);
            }
            
            var expirationDateFromVar;
            var expirationDateToVar;
            var certificateId;
            if(component.get("v.expirationDateFrom") != '')
                expirationDateFromVar = component.get("v.expirationDateFrom");
            if(component.get("v.expirationDateTo") != '')
                expirationDateToVar = component.get("v.expirationDateTo");
            if(component.get("v.selectedLookUpRecord") != '' && component.get("v.selectedLookUpRecord") != null && component.get("v.selectedLookUpRecord") != {})
                certificateId = component.get("v.selectedLookUpRecord").Id;
            
            if((orgId!=null && InsId!=null && orgId!='' && InsId!='' && orgId!= undefined && InsId!=undefined))
            {
                action.setParams({accId : JSON.stringify(orgg), instId : JSON.stringify(Ins), expirationDateFrom : expirationDateFromVar, expirationDateTo : expirationDateToVar, certificateId : certificateId});
                action.setCallback(this, function(response){
                    helper.toggleSpinner(component, helper);
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var a = response.getReturnValue();
                        component.set("v.Listss", response.getReturnValue());
                    }
                });
                $A.enqueueAction(action);
            }
        }
    }
})