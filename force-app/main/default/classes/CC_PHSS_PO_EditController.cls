global with sharing class CC_PHSS_PO_EditController {
    public ccrz__E_StoredPayment__c storedPayment {get; set;}

    global CC_PHSS_PO_EditController() {

        String store = ccrz.cc_CallContext.storefront;
        String pid = ApexPages.currentPage().getParameters().get('pid');
        if (pid != null) {
            List<ccrz__E_StoredPayment__c> listStoredPayments = [SELECT Id, ccrz__AccountNumber__c, ccrz__DisplayName__c, ccrz__Enabled__c, Original_PO_Amount__c, Remaining_PO_Amount__c FROM ccrz__E_StoredPayment__c WHERE Id = :pid];
            if (listStoredPayments.size() > 0) {
                storedPayment = listStoredPayments[0];
            }
        }
    }
    
    @RemoteAction
    global static ccrz.cc_RemoteActionResult updatePONumber(ccrz.cc_RemoteActionContext ctx, String data) {
        ccrz.cc_CallContext.initRemoteContext(ctx);
        ccrz.ccLog.log(System.LoggingLevel.INFO,'M:E','updatePONumber');
        ccrz.ccLog.log(System.LoggingLevel.DEBUG,'P:data',data);
        ccrz.cc_RemoteActionResult response = new ccrz.cc_RemoteActionResult();
        response.success = false;

        try {
            Map<String, Object> input = (Map<String, Object>) JSON.deserializeUntyped(data);

            String storefront = ccrz.cc_CallContext.storefront;
            
            String pid = (String)input.get('storedPaymentId');
            List<ccrz__E_StoredPayment__c> listStoredPayments = [SELECT Id, ccrz__AccountNumber__c, ccrz__DisplayName__c, ccrz__Enabled__c, Original_PO_Amount__c, Remaining_PO_Amount__c FROM ccrz__E_StoredPayment__c WHERE Id = :pid];
            if (listStoredPayments.size() > 0) {            
                ccrz__E_StoredPayment__c storedPayment = listStoredPayments[0];
                storedPayment.ccrz__AccountNumber__c = (String)input.get('accountNumber');
                storedPayment.ccrz__DisplayName__c = (String)input.get('displayName');
                storedPayment.ccrz__Enabled__c = (Boolean)input.get('isEnabled');
                String updateOriginalPOAmountStr = (String)input.get('updateOriginalPOAmount');
                if (updateOriginalPOAmountStr != null) {
                    Decimal updateOriginalPOAmount = Decimal.valueOf(updateOriginalPOAmountStr);
                    storedPayment.Original_PO_Amount__c += updateOriginalPOAmount;
                    storedPayment.Remaining_PO_Amount__c += updateOriginalPOAmount;                
                }
                update storedPayment;
                
                response.success = true;
            }
        }
        catch (Exception e) {
            ccrz.ccLog.log(System.LoggingLevel.ERROR, 'ERR', e);
        }
        return response;
    }
}