({  
    doInit : function(component, event, helper)
  	{
		var oId = component.get("v.oId");
        var action = component.get('c.getOrderItemDetail');
        
        action.setParams({orderId : oId});
        action.setCallback(this, function(response) 
		{
            var state = response.getState();
            if (state === "SUCCESS")
            {   
                var storeResponse = response.getReturnValue();
                var newPrice 	  = storeResponse[0].ccrz__Price__c * -1;
                component.set("v.adjPercentDiscountOld",newPrice);                
            }
        });
        $A.enqueueAction(action);
	},
     
	showPrompt : function(component, event, helper)
    {
    	component.set("v.isPrompt", "true");        
	},
    
    overrideSelected: function (component, event, helper)
    {   
        var overrideType = event.getSource().get('v.value');
        
        if (typeof overrideType !== "undefined")
        {
            component.set("v.overrideType", overrideType);
        }
    },
    
    valueFieldChanged: function (component, event, helper)
    {
        var overrideType = null;
        
        var fieldId = event.getSource().getLocalId();
        
        if ("percentDiscountField" === fieldId)
        {
            overrideType = "percentDiscount";
        }
        else if ("unitPriceField" === fieldId)
        {
            overrideType = "unitPrice";
        }
        
        component.set("v.overrideType", overrideType);
    },
    
    processAdjustment : function(component,event,helper)
    {
        var total	= component.get("v.maxDisAllowed") * -1;
        var priceA	= component.get("v.adjPercentDiscount");
        var priceP	= priceA * -1;
        var oType	= component.get("v.overrideType");

        if (oType != "undefined")
        {   
            if(oType === "unitPrice")
            {
                if (priceA !== "")
                {
                    if(priceA < 0)
                    {
                        if(!isNaN(total))
                        {
                            if(priceP <= total)
                            {
                                component.set("v.newPrice",priceA);
                                component.set("v.isPrompt", false);
                                
                                var vx = component.get("v.method");
                                $A.enqueueAction(vx);
                            }
                            else
                            {
                                component.set("v.hasGraterDiscount", true);
                                component.set("v.prMsg","Can't exceed the purchase price.")
                            }
                        }
                        else
                        {
                            component.set("v.newPrice",priceA);
                            component.set("v.isPrompt", false);
                            
                            var vx = component.get("v.method");
                            $A.enqueueAction(vx);
                        }
                    }
                    else
                    {
                        component.set("v.hasGraterDiscount", true);
                        component.set("v.prMsg","The amount must be negative.")
                    }
                }
                else
                {
                    component.set("v.hasGraterDiscount", true);
                    component.set("v.prMsg","Complete this field.")
                }
            }
            else if(oType === "percentDiscount")
            {   
                var percentDiscount = component.get("v.percentDiscount");
                
                if (percentDiscount > 100)
                {
                    component.set("v.hasGraterPercent", true);
                    component.set("v.pMsg", "Percentage value can't be more than 100.");
                }
                else
                {
                    component.set("v.hasGraterPercent", false);
                    
                    var price = component.get("v.adjPercentDiscountOld");
                    var pDis  = component.get("v.percentDiscount");
                    
                    if(pDis !== undefined)
                    {
                        var newPrice = price * pDis / 100;
                    
                        //price = price - newPrice; //DE1381
                        
                        component.set("v.newPrice", newPrice);
                        component.set("v.isPrompt", false);
                        
                        var vx = component.get("v.method");
                        $A.enqueueAction(vx);
                    }else{
                        component.set("v.hasGraterPercent", true);
                        component.set("v.pMsg", "Complete this field.");
                    }
                }
                
                
            }
        }
    },
    
    showStep2 : function(component,event,helper)
    {        
        component.set("v.stepNumber", "Zero");
        component.set("v.isPrompt", "false");
        var oPrice = component.get("v.adjPercentDiscountOld");
        console.log("oPrice***"+oPrice);
        component.set("v.adjPercentDiscount", oPrice);
        component.set("v.hasGraterPercent", false);
        component.set("v.hasGraterDiscount", false);
    },
})