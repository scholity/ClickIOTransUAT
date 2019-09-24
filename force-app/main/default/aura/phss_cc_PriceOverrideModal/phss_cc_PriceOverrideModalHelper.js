/**
 * Created by jbarker on 11/2/18.
 */
({
    getCartItemForOpportunity: function (component, cartItemId, opportunitySfid) {
        var action = component.get('c.getCartItem');
        console.log("Test1");
        action.setParams({
            'cartItemId': cartItemId,
            'opportunitySfid': opportunitySfid
        });
        action.setCallback(this, function (response) {
            if ('SUCCESS' === response.getState()) {
                
                var options = [];
                var value   = response.getReturnValue();
                
                if (value) {
                    var cartItem = value.cartItem;
                    if (cartItem) {
                        component.set('v.cartItem', cartItem);
                        component.set("v.priceOld",cartItem.price);
                        
                        if(cartItem.Coupon !== undefined)
                        {
                        	component.set("v.fieldDisable",true);
                            component.set("v.buttonSwitch",false);
                            options.push({
                                label: cartItem.CouponName,
                                value: cartItem.Coupon
                            });
                            
                            component.set("v.options", options);
                        }
                        else
                        {
                            component.set("v.fieldDisable",false);
                            component.set("v.buttonSwitch",true);
                            this.getCouponInfo(component, event);
                        }
                    }
                    else {
                        this.showToast('info', 'No cart item was found', 'Try reloading the page and attempt to override the price again.');
                    }
                }
                else {
                    this.showToast('info', 'No cart item was found', 'Try reloading the page and attempt to override the price again.');
                }
            }
            else {
                this.showToast('error', 'Could not get cart item', 'Try reloading the page and attempt this action again.');
            }
            
            component.set('v.showSpinner', false);
        });
        $A.enqueueAction(action);
        component.set('v.showSpinner', true);
    },

    reset: function (component) {
        component.set('v.cartItem', null);
        component.set('v.overrideType', null);
    },

    savePriceOverride: function (component) {
        var result = this.validatePriceOverride(component);
        var couponId = component.get("v.CouponId");
        
        if (result.success) {
            var action = component.get('c.overridePriceForCartItem');
            action.setParams({
                'cartItemSfid': result.cartItemSfid,
                'overrideType': result.overrideType,
                'overrideValue': result.overrideValue.toString(),
                'couponId':couponId
            });
            action.setCallback(this, function (response) {
                if ('SUCCESS' === response.getState()) {
                    var returnValue = response.getReturnValue();
                    if (typeof returnValue !== 'undefined') {
                        var cartItem = returnValue.cartItem;
                        if (typeof cartItem !== 'undefined') {
                            component.set('v.isShown', false);
                            this.showToast('success', 'Price override was successful', 'The price for this cart item was successfully overridden.');
                            var updateEvent = $A.get('e.c:phss_cc_RefreshComponentEvent');
                            updateEvent.fire();
                        }
                        else {
                            this.showToast('info', 'There was no cart item to update', 'Try reloading the page and attempt to override the price again.');
                        }
                    }
                    else {
                        this.showToast('error', 'An unknown error occurred.', 'Please report this error for further assistance.');
                    }
                }
                else {
                    this.showToast('error', 'Could not override price.', 'Failed to override the price for this cart item: ' + response.getState());
                }
                component.set('v.showSpinner', false);
            });
            $A.enqueueAction(action);
            component.set('v.showSpinner', true);
        }
        else {
            this.showToast('error', 'Cannot override price', result.error);
        }
    },
    
    removeCouponHelper :  function (component) {
        var cartItemSfid = component.get('v.cartItem.cartItemSfid');
        var couponId = component.get("v.CouponId");
        
        var action = component.get('c.processRemoveCoupon');
        action.setParams({
            'cartItemSfid': cartItemSfid,
            'couponId':couponId
        });
        action.setCallback(this, function (response) {
            if ('SUCCESS' === response.getState()) {
                var returnValue = response.getReturnValue();
                if (typeof returnValue !== 'undefined') {
                    var cartItem = returnValue.cartItem;
                    if (typeof cartItem !== 'undefined') {
                        component.set('v.isShown', false);
                        component.set("v.options","");
                        component.set("v.CouponId",null);
                        this.showToast('success', 'Coupon emoved successfully');
                        var updateEvent = $A.get('e.c:phss_cc_RefreshComponentEvent');
                        updateEvent.fire();
                        
                        $A.get("e.force:refreshView").fire();
                    }
                    else {
                        this.showToast('info', 'There was no cart item to update', 'Try reloading the page and attempt to override the price again.');
                    }
                }
                else {
                    this.showToast('error', 'An unknown error occurred.', 'Please report this error for further assistance.');
                }
            }
            else {
                this.showToast('error', 'Could not remove Coupon.', 'Failed to remove Coupon for this cart item: ' + response.getState());
            }
            component.set('v.showSpinner', false);
        });
        $A.enqueueAction(action);
        component.set('v.showSpinner', true);
        
    },

    showToast : function(type, title, message) {
        var toastEvent = $A.get('e.force:showToast');
        if (toastEvent) {
            toastEvent.setParams({
                'message' : message,
                'mode'    : 'dismissible',
                'title'   : title,
                'type'    : type
            });
            toastEvent.fire();
        }
        else {
            alert(title + '.\n' + message + ' [' + type + ']');
        }
    },

    validatePriceOverride: function (component) {
        var result = { success: false };

        var cartItemSfid = component.get('v.cartItem.cartItemSfid');
        if (typeof cartItemSfid !== 'undefined') {
            result.cartItemSfid = cartItemSfid;

            var overrideType = component.get('v.overrideType');
            if (overrideType == 'percentDiscount') {
                var percentDiscountStr = component.find('percentDiscountField').get('v.value');
                if (typeof percentDiscountStr !== 'undefined') {
                    var percentDiscount = Number(percentDiscountStr);
                    if (percentDiscount != NaN) {
                        result.overrideType = overrideType;
                        result.overrideValue = percentDiscount;
                        result.success = true;
                    }
                    else {
                        result.error = 'Please provide a numeric value for the Percent Discount field.';
                    }
                }
                else {
                    result.error = 'Please provide a value for the Percent Discount field.';
                }
            }
            else if (overrideType == 'unitPrice') {
                var unitPriceStr = component.find('unitPriceField').get('v.value');
                if (typeof unitPriceStr !== 'undefined') {
                    var unitPrice = Number(unitPriceStr);
                    if (unitPrice != NaN) {
                        result.overrideType = overrideType;
                        result.overrideValue = unitPrice;
                        result.success = true;
                    }
                    else {
                        result.error = 'Please provide a numeric value for the Unit Price field.';
                    }
                }
                else {
                    result.error = 'Please provide a value for the Unit Price field.';
                }
            }
            else {
                result.error = 'Please choose an override type of Percent Discount or Unit Price.';
            }
        }
        else {
            result.error = 'No cart item identifier was found.';
        }

        return result;
    },
    
    getCouponInfo : function(component)
    {
        var action = component.get("c.getCoupons");
        
        var options = [];
        
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var receivedValues = response.getReturnValue();
                if (receivedValues != undefined && receivedValues.length > 0) {
                    options.push({
                        label: "-- None --",
                        value: ""
                    });
                }
                
                for (var i = 0; i < receivedValues.length; i++) {
                    options.push({
                        label: receivedValues[i].Display_Name__c,
                        value: receivedValues[i].Id
                    });
                }
                component.set("v.options", options);
            }
        });
        $A.enqueueAction(action);
    },
    
})