({
    doInit: function(component, event, helper) {
        
        // get the fields API name and pass it to helper function  
        var controllingFieldAPI = component.get("v.controllingFieldAPI");
        var dependingFieldAPI = component.get("v.dependingFieldAPI");
        var objDetails = component.get("v.objDetail");
        // call the helper function
        helper.fetchPicklistValues(component,objDetails,controllingFieldAPI, dependingFieldAPI);
        
        var orderId = component.get("v.recordId");
        
        console.log("***orderId***"+orderId);
        
        var action = component.get('c.getOrderItemDetail');
        action.setParams({ orderId : orderId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var storeResponse = response.getReturnValue();
                
                component.set("v.orderItemList", storeResponse);
                
                component.set("v.price",storeResponse[0].ccrz__Price__c);
                component.set("v.subAmount",storeResponse[0].ccrz__SubAmount__c);
                component.set("v.qty",storeResponse[0].ccrz__Quantity__c);
                
            }
        });
        $A.enqueueAction(action);
    },
    
    onControllerFieldChange: function(component, event, helper) {     
        var controllerValueKey = event.getSource().get("v.value"); // get selected controller field value
        var depnedentFieldMap = component.get("v.depnedentFieldMap");
        
        if (controllerValueKey != '--- None ---') {
            var ListOfDependentFields = depnedentFieldMap[controllerValueKey];
            
            if(ListOfDependentFields.length > 0){
                component.set("v.bDisabledDependentFld" , false);  
                helper.fetchDepValues(component, ListOfDependentFields);    
            }else{
                component.set("v.bDisabledDependentFld" , true); 
                component.set("v.listDependingValues", ['--- None ---']);
            }  
            
        } else {
            component.set("v.listDependingValues", ['--- None ---']);
            component.set("v.bDisabledDependentFld" , true);
        }
    },
    
    showStep1 : function(component,event,helper)
    {        
        component.set("v.stepNumber", "One");
    },
    
    showStep0 : function(component,event,helper)
    {        
        component.set("v.stepNumber", "Zero");            
    },
    
    showSpinner : function (component, event, helper)
    {
        component.set("v.isSubmitted", 'true');
    },
    
    hideSpinner : function (component, event, helper)
    {
        component.set("v.isSubmitted", 'false');
    },
    
    onReasonCodeChange : function(component, event, helper)
    {
        if(component.find("rCodeField").get("v.value") != '--- None ---')
        {
            component.set("v.rCodeError", false);
        }
        
        if(component.find("rCodeField").get("v.value") === 'Other')
        {
            component.set("v.isOther", false);
        }
        else
        {
            component.set("v.isOther", true);
        }
    },
    
    processSubmit : function(component, event, helper)
    {
        var explntn	  = component.get("v.explnation");
        
        var adjValid   = false;
        var rCodeValid = false;
        var otherValid = false;
        
        if(component.find("adjField").get("v.value") === '--- None ---')
        {
            component.set("v.adjError", true);
            
        }
        else
        {
            adjValid   = true;
        }
        
        if(component.find("rCodeField").get("v.value") === '--- None ---')
        {
            component.set("v.rCodeError", true);
        }
        else
        {
            rCodeValid = true;
        }
        
        if(explntn === undefined && component.find("rCodeField").get("v.value") === 'Other')
        {
            component.set("v.otherError", true);
        }
        else
        {
            var otherValid = true;
        }
        
        if (adjValid && rCodeValid && otherValid)
        {
            helper.onClickYes(component, event, helper);
        }
    },
    
    
})