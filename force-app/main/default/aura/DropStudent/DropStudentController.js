({
    doInit: function (component, event, helper)
    {
        helper.getData(component);
        helper.getPreviousCredit(component, event, helper);
 
        var controllingFieldAPI	= component.get("v.controllingFieldAPI");
        var dependingFieldAPI	= component.get("v.dependingFieldAPI");
        var objDetails			= component.get("v.objDetail");

        helper.fetchPicklistValues(component,objDetails,controllingFieldAPI, dependingFieldAPI);
        
        var orderId = component.get("v.recordId");
        
        component.set("v.oId",orderId);
        
        console.log("***orderId***"+orderId);
        
        var action = component.get('c.getOrderItemDetail');
        
        action.setParams({ orderId : orderId });
        action.setCallback(this, function(response) 
		{
            var state = response.getState();
            if (state === "SUCCESS")
            {   
                var storeResponse = response.getReturnValue();
                
                component.set("v.orderItemList", storeResponse);
                
                var newPrice 	= storeResponse[0].ccrz__Price__c * -1;
                var itemTotal	= storeResponse[0].ccrz__ItemTotal__c;
                
                console.log("itemTotal***"+itemTotal);
                
                helper.checkCancellationPolicy(component, event, helper);
                
                component.set("v.actualPrice",newPrice);
                component.set("v.itemTotal",itemTotal);
                
            }
        });
        $A.enqueueAction(action);
    },
    
    processAdj : function(component, event, helper)
    {    
        var objChild	= component.find('adj');
        var adjPrice 	= objChild.get("v.newPrice");
        var quantity	= component.get("v.qty");
        var extQuantity = quantity * adjPrice;
        
        console.log("***extQuantity***"+extQuantity);

        component.set ("v.price",adjPrice);
        component.set("v.extAmount",extQuantity);
    },
    
    onControllerFieldChange: function(component, event, helper)
    {     
        var controllerValueKey	= event.getSource().get("v.value");
        var depnedentFieldMap 	= component.get("v.depnedentFieldMap");
        
        if (controllerValueKey != '--- None ---')
        {
            var ListOfDependentFields = depnedentFieldMap[controllerValueKey];
            
            if(ListOfDependentFields.length > 0)
            {
                component.set("v.bDisabledDependentFld" , false);  
                helper.fetchDepValues(component, ListOfDependentFields);
                component.set("v.adjError", false);
            }
            else
            {
                component.set("v.bDisabledDependentFld" , true); 
                component.set("v.listDependingValues", ['--- None ---']);
            }  
            
        }
        else
        {
            component.set("v.listDependingValues", ['--- None ---']);
            component.set("v.bDisabledDependentFld" , true);
        }
    },
    
    showPrompt : function(component, event, helper)
    {
    	component.set("v.isPrompt", "true");

        var price = component.get("v.price");
        
        component.set("v.adjPercentDiscount",price);
	},
    
    showStep1 : function(component,event,helper)
    {        
        component.set("v.stepNumber", "One");
    },
    
    showStep2 : function(component,event,helper)
    {        
        component.set("v.stepNumber", "Two");
        component.set("v.isPrompt", "false");
    },
    
    onCheck: function(component,event,helper)
    {
		component.set("v.countError", "false");
	},
    
    onclickNext : function(component,event,helper)
    {
        var currentSN = component.get("v.stepNumber");
        
        if(currentSN == "One")
        {
            var lstVouchers = component.get("v.voucherList");
            var prcPrLrnr	= component.get("v.actualPrice");
            var itmTotal	= component.get("v.itemTotal");
            var previousCr	= component.get("v.previousCredit");
            var count 		= 0;
            console.log("$$$prcPrLrnr$$$"+prcPrLrnr);
            console.log("$$$previousCr$$$"+previousCr);
            for (var i=0; i < lstVouchers.length; i++)
            {
                if (lstVouchers[i].isSelected) count++;
            }
            
            console.log('***count***'+count);
            
            if(count > 0)
            {
                //var extAmountActual = prcPrLrnr * count;
                var crLeft			= (itmTotal +previousCr) * -1;
                var rCrLeft			= crLeft.toFixed(2);
                
                component.set("v.countError", false);
                component.set("v.qty",count);
                //component.set("v.extAmount",extAmountActual);
                component.set("v.stepNumber", "Two");
                component.set("v.CreditLeft",rCrLeft);
                component.set("v.maxPrice",prcPrLrnr);
                
                var policyPercent = component.get("v.percentForCnclPlcy");
                var newPrice	  = prcPrLrnr;//component.get("v.price");
                if(policyPercent > 0)
                {
                    console.log("newPrice***"+newPrice);
                    console.log("policyPercent***"+policyPercent);
                    
                    if(policyPercent === 100)
                    {
                        component.set("v.price",0);
                        component.set("v.extAmount",0);
                    }
                    else
                    {
                        var feePrice 	= newPrice * (policyPercent/100);
                        var finalPrice 	= newPrice - feePrice;
                        var fixedPrice	= finalPrice.toFixed(2);
                        
                        component.set("v.price",fixedPrice);
                        
                        var extAmountNew = fixedPrice * count;
                        
                        component.set("v.extAmount",extAmountNew);
                    }
                	
                    component.set("v.hasPolicy",true);
                }
                else
                {
                    component.set("v.price",newPrice);
                    component.set("v.hasPolicy",false);
                    
                    var extAmountActual = prcPrLrnr * count;
                    component.set("v.extAmount",extAmountActual);
                }
                
                if(crLeft >= 0)
                {
                   component.set("v.buttonDisable", true); 
                }
            }
            else
            {
                component.set("v.countError", true);
            }
        }
        
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
    
    overrideSelected: function (component, event, helper)
    {
        console.log("***overrideSelected***");
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
            
        }else{
            adjValid   = true;
        }
        
        if(component.find("rCodeField").get("v.value") === '--- None ---' && adjValid === false)
        {
            console.log("***");
            component.set("v.rCodeError", true);
        }else{
            rCodeValid = true;
        }
        
        if(explntn === undefined && component.find("rCodeField").get("v.value") === 'Other')
        {
            component.set("v.otherError", true);
        }else{
            var otherValid = true;
        }
        
        if (adjValid && rCodeValid && otherValid)
        {
            helper.onClickYes(component, event, helper);
            helper.processDropStudent(component, event, helper);
        }
    },
    
    cancel : function(component, event, helper)
    {
        $A.get("e.force:refreshView").fire();
        component.set("v.stepNumber", "Zero");
    },
    
    isRefreshed: function(component, event, helper)
    {
        location.reload();
    },
})