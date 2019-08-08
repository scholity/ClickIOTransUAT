({
    doInit : function (cmp, evt, helper) {

        helper.initializeWrapper(cmp, evt, helper).then(function(results) {
            helper.validateClaim(cmp, evt, helper);
        });
    },
    
    // Method to validate form fields
    handleClaimVoucher : function (cmp, evt, helper) {
        // Validate fields
        var allValid = cmp.find('field').reduce(function (validSoFar, inputCmp) {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        
        if(allValid) {
    		helper.registerLearner(cmp, evt, helper);        
        }
    },
    
})