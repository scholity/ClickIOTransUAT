/**
 * Created by jbarker on 11/2/18.
 */
({
    getCartItemForProduct: function (component, productSfid, opportunitySfid) {
        var action = component.get('c.getCartItem');
        action.setParams({
            'productSfid': productSfid,
            'opportunitySfid': opportunitySfid
        });
        action.setCallback(this, function (response) {
            if ('SUCCESS' === response.getState()) {
                var value = response.getReturnValue();
                if (value) {
                    var cartItem = value.cartItem;
                    if (cartItem) {
                        component.set('v.cartItem', cartItem);
                    }
                    else {
                        console.log('No cart item was returned.');
                    }
                }
                else {
                    console.log('No value was returned.');
                }
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
        if (result.success) {
            var action = component.get('c.overridePriceForCartItem');
            action.setParams({
                'cartItemSfid': result.cartItemSfid,
                'overrideType': result.overrideType,
                'overrideValue': result.overrideValue.toString()
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

        console.log('result: ');
        console.log(result);

        return result;
    }
})