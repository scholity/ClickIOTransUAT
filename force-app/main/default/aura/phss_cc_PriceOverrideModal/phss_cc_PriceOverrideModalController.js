/**
 * Created by jbarker on 11/2/18.
 */
({
    doInit: function(component, event, helper)
    {
        //helper.getCouponInfo(component, event, helper);
        console.log("doInit$$$");
    },
    
    onChange : function (component, event, helper)
    {
        var cId = event.getSource().get("v.value");
        
        component.set("v.CouponId",cId);
        
        console.log("cId"+cId);
        
        if(cId !== "")
        {
            
            component.set("v.fieldDisable",true);
            
            var action = component.get("c.getCouponsDiscount");
            action.setParams({
                "couponId": cId
            });
            
            action.setCallback(this, function(response) {
                if (response.getState() === "SUCCESS") 
                {   
                    
                    var receivedValues = response.getReturnValue();
                    console.log("**receivedValues**"+receivedValues);
                    component.set("v.CouponType",receivedValues[0].Type__c);
                    component.set("v.CouponValue",receivedValues[0].Value__c);
                    
                    if(receivedValues[0].Type__c === "Percentage")
                    {
                        component.set('v.overrideType', 'percentDiscount');
                        component.set("v.cartItem.percentDiscount",receivedValues[0].Value__c);
                        component.set("v.cartItem.price","");
                    }
                    else
                    {
                        component.set('v.overrideType', 'unitPrice');
                        //var oPrice 			= component.get("v.priceOld"):
                        
                        //var price    		= component.get("v.cartItem.price");
                        var price    		= component.get("v.priceOld");
                        var valueOff 		= receivedValues[0].Value__c;
                        var dicountedPrice  = price - valueOff;
                        
                        component.set("v.cartItem.price",dicountedPrice);
                        component.set("v.cartItem.percentDiscount","");
                    }
                }
            });
            $A.enqueueAction(action);
        }
        else
        {
            component.set("v.fieldDisable",false);
            component.set("v.cartItem.price",component.get("v.priceOld"));
            component.set("v.cartItem.percentDiscount","");
            component.set('v.overrideType', 'unitPrice');
        }
    },
    
    hide: function (component, event, helper) {
        component.set('v.isShown', false);
        helper.reset(component);
    },

    show: function (component, event, helper) {
        component.set('v.isShown', true);

        var opportunitySfid = event.getParam('opportunitySfid');
        var cartItemId = event.getParam('cartItemId');
        helper.getCartItemForOpportunity(component, cartItemId, opportunitySfid);
    },

    overrideSelected: function (component, event, helper) {
        var overrideType = event.getSource().get('v.value');
        if (typeof overrideType !== 'undefined') {
            component.set('v.overrideType', overrideType);
        }
    },

    save: function (component, event, helper) {
        console.log('save()');
        helper.savePriceOverride(component);
        component.set("v.fieldDisable",false);
    },
    
    removeCoupon: function (component, event, helper) {
        console.log('removeCoupon()');
        helper.removeCouponHelper(component);
    },

    valueFieldChanged: function (component, event, helper) {
        var overrideType = null;
        var fieldId = event.getSource().getLocalId();
        if ('percentDiscountField' === fieldId) {
            overrideType = 'percentDiscount';
        }
        else if ('unitPriceField' === fieldId) {
            overrideType = 'unitPrice';
        }
        component.set('v.overrideType', overrideType);
    }
})