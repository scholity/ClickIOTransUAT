/**
 * Created by jbarker on 12/19/18.
 */

trigger CaptureCCPaymentOnFulfillmentInsert on Fulfillment__c (after insert) {
    if(!PHSS_TriggerSettings__c.getOrgDefaults().FulfillmentTriggerDisabled__c){
        for (Fulfillment__c fulfillment : trigger.new) {
//            System.debug('JASON: CaptureCCPaymentOnFulfillmentInsert');
            if (fulfillment.CC_Transaction_Payment__c != null) {
                ccrz__E_TransactionPayment__c transactionPayment = [
                        SELECT Id, ccrz__AccountType__c, ccrz__Amount__c
                        FROM ccrz__E_TransactionPayment__c
                        WHERE Id = :fulfillment.CC_Transaction_Payment__c
                        LIMIT 1
                ];

//                System.debug('JASON: transactionPayment: ' + transactionPayment);
                if (transactionPayment != null) {
//                    System.debug('JASON: account type: ' + transactionPayment.ccrz__AccountType__c);
                    if (transactionPayment.ccrz__AccountType__c == 'cc') {
//                        System.debug('JASON: amount: ' + transactionPayment.ccrz__Amount__c);
                        if (transactionPayment.ccrz__Amount__c < 0) {
//                            System.debug('JASON: will credit fulfillment: fulfillment.Id=' + fulfillment.Id);
                            phss_cc_CyberSourceCreditUtil.creditFulfillment(fulfillment.Id);
                        }
                        else if (transactionPayment.ccrz__Amount__c > 0) {
//                            System.debug('JASON: will capture payment: fulfillment.Id=' + fulfillment.Id);
                            phss_cc_FulfillmentUtil.capturePayment(fulfillment);
                        }
                    }
                }
            }
        }
    }
}