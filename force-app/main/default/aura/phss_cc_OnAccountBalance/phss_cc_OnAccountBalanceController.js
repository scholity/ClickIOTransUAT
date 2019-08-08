({
    
    doInit: function (component, event, helper)
    {
        helper.getStoredPayments(component);

        var now = new Date();
        component.set('v.newPOStartDate', $A.localizationService.formatDate(now, "yyyy-MM-dd"));
        var later = new Date(2099, 11, 31);
        component.set('v.newPOEndDate', $A.localizationService.formatDate(later, "yyyy-MM-dd"));
    },
    
    onCheck: function (component, event, helper)
    {
        component.set("v.showCalc", false);
        component.set("v.showCalcErr", false);
    },
    
    applyPayment : function (component, event, helper)
    {
        console.log("##applyPayment##");
    },
    
    submitPayment : function (component, event, helper)
    {
        console.log("##submitPayment##");
    },
    
    calculateCredit: function (component, event, helper)
    {
        console.log("calculateCredit");
        component.set("v.showSpinner",true);
        var storedPaymentList = component.get("v.storedPaymentList");
        
        var action = component.get("c.performAction");
        
        var productRecords = JSON.stringify(storedPaymentList);
        
        
        
        action.setParams({prodRecords : productRecords});
        
        action.setCallback(this,function(a){
            
            var state 		= a.getState();
            var returnValue = a.getReturnValue();
            
            console.log("returnValue@@@"+returnValue);
            
            if(state == "SUCCESS")
            {
                if (returnValue != "")
                {
                    var selectedCB = returnValue;
                    
                    component.set("v.TotalAppliedCreditAmount",selectedCB);
                	component.set("v.showCalc", true);
                    component.set("v.showCalcErr", false);
                    component.set("v.showSpinner",false);
                    
                    var cartAmt 		= component.get("v.TotalCartAmount");
                    var remainingCrtAmt = cartAmt - selectedCB;
                    
                    component.set("v.RemainingCartAmount",remainingCrtAmt);
                    
                    var valueCheck = Math.sign(remainingCrtAmt);
                    
                    console.log("valueCheck&&&"+valueCheck);
                    
                    if(valueCheck !== 1)
                    {
                        component.set("v.disableSubmit", false);
                    }
                    else
                    {
                        component.set("v.disableSubmit", true);
                    }
                }
                else
                {
                    component.set("v.showCalcErr", true);
                    component.set("v.showSpinner",false);
                }
                
            }
            
            else if(state == "ERROR")
            {
                alert('Error in calling server side action');
            }
        });
        
        
        $A.enqueueAction(action);
    },


    handleDoSave: function (component, event, helper)
    {
        var newPODoSave = component.get('v.newPODoSave');
        if (newPODoSave) {
            component.set('v.newPODoSave', false);
        } else {
            component.set('v.newPODoSave', true);
        }
    },


    handleSelectedPO: function (component, event, helper)
    {
        component.set('v.renderComplete', false);
        var selectedPOSfid = event.getParam('POSfid');
        component.set('v.selectedPOSfid', selectedPOSfid);
        component.set('v.renderComplete', true);
    },

 
    clearPOSelected: function (component, event, helper)
    {
        var selectedPO = component.get('v.selectedPOSfid');
        if (selectedPO !== '') {
            component.set('v.listUpdate', false);
            component.set('v.selectedPOSfid', '');
            component.set('v.listUpdate', true);
        }
    },


    invoiceTypeSelected: function (component, event, helper)
    {
        var invoiceType = event.getSource().get('v.value');
        if (typeof invoiceType !== 'undefined') {
            component.set('v.invoiceType', invoiceType);
        }
    },

    sendPOToCart: function (component, event, helper)
    {
        var errMsg;
        var invoiceType = component.get('v.invoiceType');
        
        
        var selectedPO = component.get('v.selectedPOSfid');
        
        var shouldUpdatePOAmount = true;
        var updatePOAmount = component.get('v.updatePOAmount');
        
        console.log("$$$selectedPO###"+selectedPO);
        
        console.log("$$$updatePOAmount###"+updatePOAmount);
        
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
        
        
        if (errMsg != null) {
            helper.showToastMessage('Error', errMsg, 'Error');
        }
    },

    toggleShouldUpdatePOAmount: function (component, event, helper)
    {
        var shouldUpdatePOAmount = component.get('v.shouldUpdatePOAmount');
        component.set('v.shouldUpdatePOAmount', !shouldUpdatePOAmount);
    }

})