({
	doInit : function(component, event, helper) {
		component.set("v.storeFrontName","CPS");
        
        helper.initializeWrapper(component, event, helper);
        	
        // Get today's date
        var today = new Date();
        var dd = today.getDate();
        var mm = today.getMonth()+1; //January is 0!
        var yyyy = today.getFullYear();
        today = yyyy + '-' + mm + '-' + dd;
        component.set("v.todaysDate",today);
          
    },
    
    productCountIncrement: function (component, event, helper) {
        var productQuantityMap = component.get('v.productQuantityMap');
        var productSfid = event.getParam('productSfid');
        
        console.log("productSfid**>>**"+productSfid);
        
        component.set("v.CCProductId",productSfid);
        
    },
    
	
    onFormatChange : function(component, event, helper) {
        component.set("v.formatError",false);
        
        // Class format validation
        var format = document.getElementById('formatSelect').value;
        component.set("v.cpsWrap.classFormat",format);
        if(component.get("v.cpsWrap.classFormat")) {
            document.getElementById('formatSelect').classList.remove('requiredSelect');
        }
        else {
            component.set("v.formatError",true);
            document.getElementById('formatSelect').classList.add('requiredSelect');
        }
    },
    
    onZoneChange : function(component, event, helper) {
        component.set("v.zoneError",false);
        
        // Time Zone validation
        var tempList = component.get("v.cpsWrap.sessionList");
        tempList[0].timeZone = document.getElementById('zoneSelect').value;
        component.set("v.cpsWrap.sessionList",tempList);
        
        if(component.get("v.cpsWrap.sessionList")[0].timeZone) {
            document.getElementById('zoneSelect').classList.remove('requiredSelect');
        }
        else {
            component.set("v.zoneError",true);
            document.getElementById('zoneSelect').classList.add('requiredSelect');
        }
    },
    
    /*
    addSession : function(component, event, helper) {
        var tempList = component.get("v.cpsWrap.sessionList");
        tempList.push({'classDate':'',
                       'startTime':'',
                       'endTime':''});
        component.set("v.cpsWrap.sessionList",tempList);
    },*/
    
    onclickNext : function(component,event,helper){
        
        var currentSN = component.get("v.stepNumber");
        
        if(currentSN == "One")            
        {
            helper.validateFields(component,event,helper);
            
            var vorgId 	= component.get("v.selectedLookUpRecord1").Id
            if(vorgId === undefined){
                component.set("v.orgError",true);
            }else{
                component.set("v.orgError",false);
            }
            
            if(component.get("v.allValid") && component.get("v.isUrlValid") && !component.get("v.orgError")) {
                // Show/hide credit card info
                //Will fetch AccountContactRelation record on the basis of loggedin user's ContactId and selected account id
                var action = component.get("c.getDisplayPaymentInfo"); 
                action.setParams({ opportunityId : component.get("v.oppIdParent")});
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        debugger;
                        var data = response.getReturnValue();
                        component.set("v.displayPaymentInfo", data);
                    }
                });
                $A.enqueueAction(action);
                
            	component.set("v.stepNumber", "Two");    
            }
        }
        else if(currentSN == "Two")
        {
            helper.formatTime(component,event,helper);
            component.set("v.stepNumber", "Three");	
        }
        else if(currentSN == "Three")
        {
            component.set("v.stepNumber", "Four");
        }
        else if(currentSN == "Four")
        {
        	component.set("v.stepNumber", "Complete");
        }
    },
    
    showStep1 : function(component,event,helper){
        component.set("v.stepNumber", "One");
        
        var action = component.get("c.createOppForCC");
        
        action.setParams({
            AccountId: component.get("v.cpsWrap.accId")
        });
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            
            console.log(state);
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                if(storeResponse != null){
                   component.set("v.oppIdParent",storeResponse);
                }
            }
            else if (state === "ERROR") {
                
                var errors = response.getError();
                if (errors) {
                    
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            
        });
        
        $A.enqueueAction(action);
    },
    
    showStep2 : function(component,event,helper){
        if(component.set("v.stepNumber") == "One") {
        	helper.validateFields(component,event,helper);
            if(component.get("v.allValid") && component.get("v.isUrlValid")) {
                component.set("v.stepNumber", "Two");    
            }    
        }
        else {
            component.set("v.stepNumber", "Two");
        }
    },
    
    showStep3 : function(component,event,helper){
        if(component.set("v.stepNumber") == "One") {
            helper.validateFields(component,event,helper);
            if(component.get("v.allValid") && component.get("v.isUrlValid")) {
                helper.formatTime(component,event,helper);
                component.set("v.stepNumber", "Three");    
            }
        }
        else {
            helper.formatTime(component,event,helper);
            component.set("v.stepNumber", "Three"); 
        }
    },
    
    showPO : function(component, event, helper) {
        component.set("v.pMethod", "po");
    },
    
    showBillSprt : function(component, event, helper) {
        component.set("v.pMethod", "billSprt");
    },
    
    
    createClass : function(component, event, helper) {
        helper.createClass(component, event, helper);    
    },
    
    cancel : function(component, event, helper){    
        component.set("v.stepNumber", "Zero");
    },
    
     accountSelected : function (component,event,helper){
        var orgId 	= component.get("v.selectedLookUpRecord1").Id;
        component.set("v.cpsWrap.accId",orgId);
        component.set("v.cpsWrap.accName",component.get("v.selectedLookUpRecord1").Name);
        
        var action = component.get("c.createOppForCC");
        action.setParams({
            AccountId: orgId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                if(storeResponse != null){
                    component.set("v.oppIdParent",storeResponse);
                }
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            
        });
        $A.enqueueAction(action);
    },
})