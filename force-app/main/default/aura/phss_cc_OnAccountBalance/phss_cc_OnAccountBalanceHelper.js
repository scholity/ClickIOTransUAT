({  
    showToastMessage: function (header, message, type) {
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            title: header,
            message: message,
            type: type
        });
        toastEvent.fire();
    },

    getStoredPayments: function (component, event, helper) {
        var opportunityId = component.get('v.opportunityId');
        var action = component.get('c.fetchStoredPayments');
        action.setParams({
            opportunitySfid: opportunityId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === 'SUCCESS') {
                var returnValue = response.getReturnValue();
                if (returnValue != null && returnValue.Error == null) {
                    component.set('v.storedPaymentList',returnValue);
                } else if (returnValue != null && returnValue.Error != null) {
                    this.showToastMessage('Error Fetching Cart', returnValue.Error, 'Error')
                }

            } else {
                this.showToastMessage('Error Fetching Cart', 'Unable to contact server.', 'Error');
            }
            component.set('v.showSpinner', false);
        });
        component.set('v.showSpinner', true);
        $A.enqueueAction(action);
    },

    configureUI: function(component) {
        var cartTotal = component.get('v.cartTotal');
        var creditAmount = component.get('v.appliedAmount');

        var disableCheckboxes = creditAmount >= cartTotal;
        var checkboxes = component.find('applyCheckbox');
        if (checkboxes != null) {
            for (var i = 0; i < checkboxes.length; i++) {
                var checkbox = checkboxes[i];
                var isChecked = checkbox.get('v.value');
                if (!isChecked) {
                    checkbox.set('v.disabled', disableCheckboxes);
                }
            }
        }

        var creditCardAmount = cartTotal < creditAmount ? 0 : cartTotal - creditAmount;
        component.set('v.payByCreditCard', '' + creditCardAmount.toFixed(2));
    },
    
    recalculateAmounts: function (component) {
        var cartTotal = component.get('v.cartTotal');
        var creditAmount = 0;

        var storedPayments = component.get('v.storedPaymentList');
        if (storedPayments != null) {
            storedPayments.forEach(function(payment) {
                if (payment.isSelected) {
                    creditAmount += payment.remainingPOAmount;
                }
            });
        }

        component.set('v.appliedAmount', creditAmount);
        component.set('v.remainingAmount', cartTotal - creditAmount);
    },

    submitPayment: function(component) {
        console.log('phss_cc_OnAccountBalanceHelper.submitPayment()');

        var identifiers = [];
        var storedPayments = component.get('v.storedPaymentList');
        if (storedPayments != null) {
            storedPayments.forEach(function(payment) {
                if (payment.isSelected) {
                    identifiers.push(payment.sfid);
                }
            });
        }

        var paymentEvent = component.getEvent('sendCBToCart');
        paymentEvent.setParams({ 'storedPayments' : identifiers });
        paymentEvent.fire();
    },

    updateSelectedPayments: function (component) {
        var selectedPayments = [];      // list of the SELECTED stored payments

        var storedPayments = component.get('v.storedPaymentList');
        if (storedPayments != null) {
            storedPayments.forEach(function(element) {
                if (element.isSelected) {
                    selectedPayments.push(element);
                }
            });
        }

        var updateEvent = component.getEvent('toggleStoredPayment');
        updateEvent.setParams({ 'storedPayments' : selectedPayments });
        updateEvent.fire();
    }

})