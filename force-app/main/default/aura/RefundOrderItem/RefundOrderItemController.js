({
	doInit: function(component, event, helper)
    {
        var controllingFieldAPI	= component.get("v.controllingFieldAPI");
        var dependingFieldAPI	= component.get("v.dependingFieldAPI");
        var objDetails			= component.get("v.objDetail");
        
        helper.fetchPicklistValues(component,objDetails,controllingFieldAPI, dependingFieldAPI);        
        helper.getPreviousCredit(component, event, helper);
        helper.getCreditedOrderItemCount(component, event, helper);
        helper.onButtonClick(component, event, helper);
    },
    
    processAdj : function(component, event, helper)
    {    
        var objChild	= component.find('adj');
        var adjPrice 	= objChild.get("v.newPrice");
        var quantity	= component.get("v.qty");
        var extQuantity = quantity * adjPrice;
        
        console.log("***extQuantity***"+extQuantity);

        component.set ("v.price",adjPrice);
        component.set("v.subAmount",extQuantity);
    },
    
    onControllerFieldChange: function(component, event, helper)
    {     
        var controllerValueKey	= event.getSource().get("v.value");
        var depnedentFieldMap	= component.get("v.depnedentFieldMap");
        
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
    
    valueFieldChanged: function (component, event, helper)
    {
        console.log("***valueFieldChanged***");
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
        component.set("v.isPrompt", "false");
        
        var previousCreditCount = component.get("v.previousCreditCount");
        var originalQty			= component.get("v.originalQty");
        var price				= component.get("v.price");
        if(previousCreditCount != undefined)
        {
            var qtyToCrdt 		= originalQty - previousCreditCount;
        }
        else
        {
            var qtyToCrdt		= originalQty;
        }
        
        component.set("v.qty",qtyToCrdt);
        
        component.set("v.maxQty",qtyToCrdt);
        
        var newSubAmount = qtyToCrdt * price;
        
        component.set("v.subAmount",newSubAmount);
        
        var itmTotal		= component.get("v.itemTotal");
        var previousCr		= component.get("v.previousCredit");
        var extAmountActual = price * qtyToCrdt;
        var crLeft			= (itmTotal + previousCr) * -1;
        var rCrLeft			= crLeft.toFixed(2);
        
        //console.log("rCrLeft>>>>"+rCrLeft);
        //if (isNaN(rCrLeft))
        //{
            //component.set("v.CreditLeft",price);
            component.set("v.maxPrice",price);
        /*}
        else
        {*/
            component.set("v.CreditLeft",rCrLeft);
        //}
        
    },
    
    checkMaxQty : function(component,event,helper)
    {
        var qty    = component.get("v.qty");
        var maxQty = component.get("v.maxQty");
        var price  = component.get("v.price");
        
        if(qty === 0)
        {
            component.set("v.qtyError",true);
            component.set("v.errMsg", "Quantity should not be Zero.");
        }
        else if (qty > maxQty)
        {
            component.set("v.qtyError",true);
            component.set("v.errMsg", "Quantity should not be higher than the actual Quantity.");
        }
        else if (qty === undefined)
        {
            component.set("v.qtyError",true);
            component.set("v.errMsg", "Please enter Quantity value.");
        }
        else
        {
            component.set("v.qtyError",false);
            
            var newSubAmount = qty * price;
        
        	component.set("v.subAmount",newSubAmount);
        }
        
    },
    
    processAdjustment : function(component,event,helper)
    {        
		component.set("v.stepNumber", "One");
        component.set("v.isPrompt", "false");
        
        var percentValue 	= component.get("v.percentDiscount");
        var priceA			= component.get("v.price");
        var qty				= component.get("v.qty");
        var adjPercentDiscount = component.get("v.adjPercentDiscount");
        
        console.log("***adjPercentDiscount***"+adjPercentDiscount);
        
        var discountedPrice = priceA * percentValue/100;
        
        priceA = priceA - discountedPrice;
        console.log("***priceA***"+priceA);
        if(!isNaN(priceA))
        {
            var subAmountA		= priceA * qty;
            
            component.set("v.price",priceA);
            component.set("v.subAmount",subAmountA);
        }
        else
        {   
            var subAmountA		= adjPercentDiscount * qty;
            
            component.set("v.price",adjPercentDiscount);
            component.set("v.subAmount",subAmountA);
        }
    },
    
    showStep0 : function(component,event,helper)
    {        
        component.set("v.stepNumber", "Zero");
        $A.get("e.force:refreshView").fire();
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
    
    isRefreshed: function(component, event, helper)
    {
        location.reload();
    },
    
    processSubmit : function(component, event, helper)
    {
        var explntn	  = component.get("v.explnation");
        var qtyError  = component.get("v.qtyError");
        
        var adjValid   = false;
        var rCodeValid = false;
        var otherValid = false;
        var qtyValid   = false;
        
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
        
        var qty = component.get("v.qty");
        
        console.log("qty^^^"+qty);
        if(qty === "" || qty === "0")
        {
            component.set("v.qtyError",true);
            component.set("v.errMsg", "Quantity should not be Zero or Empty.");
        }
        else
        {
            var qtyValid = true;
        }
        
        if (adjValid && rCodeValid && otherValid && !qtyError && qtyValid)
        {
            helper.onClickYes(component, event, helper);
        }
    },
})