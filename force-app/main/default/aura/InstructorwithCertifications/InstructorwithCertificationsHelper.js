({
    onLoad: function(component, event, sortField) {
        //call apex class method
        var action = component.get('c.fetchsortedAccountDetails');
        
        // pass the apex method parameters to action 
        action.setParams({
            "sortField": sortField,
            "isAsc": component.get("v.isAsc"),
            "objName" : component.get("v.objName"),
            "objInsName":component.get("v.objInsName"),
            "accId"   : component.get("v.selectedAccount")
        });
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                //set response value in ListOfContact attribute on component.
                // component.set('v.ListOfContact', response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    
    sortHelper: function(component, event, sortFieldName) {
        var currentDir = component.get("v.arrowDirection");
        
        if (currentDir == 'arrowdown') {
            // set the arrowDirection attribute for conditionally rendred arrow sign  
            component.set("v.arrowDirection", 'arrowup');
            // set the isAsc flag to true for sort in Assending order.  
            component.set("v.isAsc", true);
        } else {
            component.set("v.arrowDirection", 'arrowdown');
            component.set("v.isAsc", false);
        }
        // call the onLoad function for call server side method with pass sortFieldName 
        this.onLoad(component, event, sortFieldName);
    },
    
    getValues : function(component, event, helper) {
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
        
        var action = component.get("c.fetchAchv");
        var orgId 	= component.get("v.selectedAccount")
        var InsId   = component.get("v.selectedInstructor")
        var orgg = [];
        var Ins = [];
        if((orgId!=null||orgId!=undefined||orgId!='') && (InsId==null||InsId==undefined||InsId==''))
        {
            if(orgId == 'All')
            {
                var accountDetailsFromServer = component.get("v.accountList.Accountdetails");
                for(var i in  accountDetailsFromServer)
                {
                    orgg.push(accountDetailsFromServer[i].Id);
                }
            }
            else
                orgg.push(orgId);
        }
        if((orgId==null||orgId==undefined||orgId=='') && (InsId!=null||InsId!=undefined||InsId!=''))
        {
            if(InsId == 'All')
            {
                var userDetailsFromServer = component.get("v.instList.Userdetails");
                for(var i in  userDetailsFromServer)
                {
                    Ins.push(userDetailsFromServer[i].Id);
                }
            }
            else
                Ins.push(InsId);
        }
        if((orgId!=null && InsId!=undefined && orgId!='' && InsId!=''))
        {
            if(orgId == 'All')
            {
                var accountDetailsFromServer = component.get("v.accountList.Accountdetails");
                for(var i in  accountDetailsFromServer)
                {
                    orgg.push(accountDetailsFromServer[i].Id);
                }
            }
            else
                orgg.push(orgId);
            
            if(InsId == 'ALL')
            {
                var userDetailsFromServer = component.get("v.instList.Userdetails");
                for(var i in  userDetailsFromServer)
                {
                    Ins.push(userDetailsFromServer[i].Id);
                }
            }
            else
                Ins.push(InsId);
        }
        
        console.log('Accountid>>>>>>>>'+orgg);
        console.log('Instructor idd>>>>>>>>'+Ins);
        var idx = event.target.id;
        
        if((orgId!=null && InsId!=null && orgId!='' && InsId!='' && orgId!= undefined && InsId!=undefined))
        {
            action.setParams({accId : JSON.stringify(orgg),instId :JSON.stringify(Ins)});
            
            console.log('Button id>>>>>>>>'+idx);
            action.setCallback(this, function(response){
                
                var state = response.getState();
                console.log('Expected State'+state);
                if (state === "SUCCESS") {
                    var a = response.getReturnValue();
                    console.log('success'+a);
                    console.log('getting inside succes'+JSON.stringify(a));
                    component.set("v.Listss", response.getReturnValue());
                }
            });
            $A.enqueueAction(action);
        }
    }
})