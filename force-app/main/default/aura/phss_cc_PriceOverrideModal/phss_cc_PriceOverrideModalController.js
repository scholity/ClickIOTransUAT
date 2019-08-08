/**
 * Created by jbarker on 11/2/18.
 */
({
    hide: function (component, event, helper) {
        component.set('v.isShown', false);
        helper.reset(component);
    },

    show: function (component, event, helper) {
        component.set('v.isShown', true);

        var opportunitySfid = event.getParam('opportunitySfid');
        var productSfid = event.getParam('productSfid');
        helper.getCartItemForProduct(component, productSfid, opportunitySfid);
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