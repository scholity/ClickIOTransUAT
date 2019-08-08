/**
 * Created by dgajwani on 10/1/18.
 */
({
    /**
     * @description Init method to get the stored payments on the account.
     * @param component
     * @param event
     * @param helper
     */
    doInit: function (component, event, helper) {
        helper.getStoredPayments(component);

        var now = new Date();
        component.set('v.newPOStartDate', $A.localizationService.formatDate(now, "yyyy-MM-dd"));
        var later = new Date(2099, 11, 31);
        component.set('v.newPOEndDate', $A.localizationService.formatDate(later, "yyyy-MM-dd"));
    },

    /**
     * @description Event handler for new PO Save checkbox.
     * @param component
     * @param event
     * @param helper
     */
    handleDoSave: function (component, event, helper) {
        var newPODoSave = component.get('v.newPODoSave');
        if (newPODoSave) {
            component.set('v.newPODoSave', false);
        } else {
            component.set('v.newPODoSave', true);
        }
    },

    /**
     * @description Updates the selected PO from the list. Clears the new purchase order form.
     * @param component
     * @param event
     * @param helper
     */
    handleSelectedPO: function (component, event, helper) {
        component.set('v.renderComplete', false);
        var selectedPOSfid = event.getParam('POSfid');
        component.set('v.selectedPOSfid', selectedPOSfid);
        component.set('v.renderComplete', true);
    },

    /**
     * @description If the user enters a new PO Number/Amount, the selected PO from the stored payments list is cleared.
     * @param component
     * @param event
     * @param helper
     */
    clearPOSelected: function (component, event, helper) {
        var selectedPO = component.get('v.selectedPOSfid');
        if (selectedPO !== '') {
            component.set('v.listUpdate', false);
            component.set('v.selectedPOSfid', '');
            component.set('v.listUpdate', true);
        }
    },

    /**
     * @description Sets the value of the selected invoice type
     * @param component
     * @param event
     * @param helper
     */
    invoiceTypeSelected: function (component, event, helper) {
        var invoiceType = event.getSource().get('v.value');
        if (typeof invoiceType !== 'undefined') {
            component.set('v.invoiceType', invoiceType);
        }
    },

    /**
     * @description Places an order using the selected PO.
     * @param component
     * @param event
     * @param helper
     */
    sendPOToCart: function (component, event, helper) {
        var errMsg;
        var invoiceType = component.get('v.invoiceType');
        if (invoiceType != undefined) {
            if (invoiceType == 'existingPO') {
                var selectedPO = component.get('v.selectedPOSfid');
                var shouldUpdatePOAmount = component.get('v.shouldUpdatePOAmount');
                var updatePOAmount = component.get('v.updatePOAmount');

                if (updatePOAmount) {
                    if (!shouldUpdatePOAmount) {
                        errMsg = 'Checkbox must be checked to allow the remaining PO amount to be updated.';
                    }
                }

                if (shouldUpdatePOAmount) {
                    if (updatePOAmount == undefined || updatePOAmount === '') {
                        errMsg = 'Missing remaining PO amount for updating the PO.';
                    }
                }

                if (errMsg == null) {
                    if (selectedPO !== '') {
                        if (updatePOAmount == undefined || updatePOAmount === '') {
                            updatePOAmount = '0';
                        }

                        var updateEvent = component.getEvent('sendPOToCart');
                        updateEvent.setParams({
                            POSfid: selectedPO,
                            updatePO: shouldUpdatePOAmount,
                            updatedPOAmount: updatePOAmount
                        });
                        updateEvent.fire();
                        return;
                    }
                    else {
                        errMsg = 'No Purchase Order was selected.';
                    }
                }
            }
            else if (invoiceType == 'newPO') {
                var newPOName = component.get('v.newPOName');
                var newPOAmount = component.get('v.newPOAmount');
                var newPOStartDate = component.get('v.newPOStartDate');
                var newPOEndDate = component.get('v.newPOEndDate');
                var newPODoSave = component.get('v.newPODoSave');
                var startDate = helper.getDateFromString(newPOStartDate);
                var endDate = helper.getDateFromString(newPOEndDate);
                var now = new Date();
                var minimumEndDate = new Date(now.getFullYear(), now.getMonth(), now.getDate());

                if (newPOName == undefined || newPOName === '') {
                    errMsg = 'Missing PO name.';
                }
                else if (newPOAmount == undefined || newPOAmount === '') {
                    errMsg = 'Missing PO amount.';
                }
                else if (newPOStartDate == undefined || newPOStartDate === '') {
                    errMsg = 'Missing PO start date.';
                }
                else if (newPOEndDate == undefined || newPOEndDate === '') {
                    errMsg = 'Missing PO end date.';
                }
                else if (startDate == null) {
                    errMsg = 'Invalid value for PO start date.';
                }
                else if (endDate == null) {
                    errMsg = 'Invalid value for PO end date.';
                }
                else if (startDate > endDate) {
                    errMsg = 'End Date must be later than Start Date.';
                }
                else if (endDate < minimumEndDate) {
                    errMsg = 'PO end date must be later or equal to Order Date.';
                }
                else {
                    var updateEvent = component.getEvent('sendPOToCart');
                    updateEvent.setParams({
                        newPOName: newPOName,
                        newPOAmount: newPOAmount,
                        newPOStartDate: newPOStartDate,
                        newPOEndDate: newPOEndDate,
                        newPODoSave: newPODoSave
                    });
                    updateEvent.fire();
                    return;
                }
            }
            else if (invoiceType == 'noPO') {
                var updateEvent = component.getEvent('sendPOToCart');
                updateEvent.setParams({POSfid: 'NoPORequired'});
                updateEvent.fire();
                return;
            }
            else {
                errMsg = 'Unknown invoice type selected: ' + invoiceType;
            }
        }
        else {
            errMsg = 'No invoice type selected.';
        }

        if (errMsg != null) {
            helper.showToastMessage('Error', errMsg, 'Error');
        }
    },

    toggleShouldUpdatePOAmount: function (component, event, helper) {
        var shouldUpdatePOAmount = component.get('v.shouldUpdatePOAmount');
        component.set('v.shouldUpdatePOAmount', !shouldUpdatePOAmount);
    }

})