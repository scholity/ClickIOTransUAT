({

    doInit: function (component, event, helper) {
        helper.getStoredPayments(component);
        helper.recalculateAmounts(component);
    },

    handleSubmitPayment: function (component, event, helper) {
        console.log('phss_cc_OnAccountBalanceController.handleSubmitPayment()');
        helper.submitPayment(component);
    },

    navigateToCreditCardPaymentForm: function (component, event, helper) {
        var navEvent = component.getEvent('paymentTabSelected');
        navEvent.setParams({ 'selectedTab' : 'Credit Card' });
        navEvent.fire();
    },

    toggleStoredPaymentSelection: function (component, event, helper) {
        helper.recalculateAmounts(component);
        helper.configureUI(component);
        helper.updateSelectedPayments(component);
    }
})