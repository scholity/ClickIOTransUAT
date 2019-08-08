/*
    Extend the class ccrz.cc_hk_Payment.
*/
global class CC_PHSS_hk_Payment extends ccrz.cc_hk_Payment {

    // overide the method so that we return the new Amount fields:
    // 1. Original PO Amount
    // 2. Remaining PO Amount
    global override Map<String, Object> fetchStoredPayments(Map<String, Object> inputData) {
        // get the data from original method
        Map<String, Object> theMap = super.fetchStoredPayments(inputData);

        // collect the sf ids of the stored payments.
        List<Map<String, Object>> listStoredPayments = (List<Map<String, Object>>) theMap.get(ccrz.cc_hk_Payment.PARAM_STORED_PAYMENTS);
        Set<String> setStoredPaymentsIds = new Set<String>();
        for (Map<String, Object> sp : listStoredPayments) {
            setStoredPaymentsIds.add((String) sp.get('sfid'));
        }

        // read the amount fields from CC Stored Payment object
        Map<Id, ccrz__E_StoredPayment__c> mapSP = new Map<Id, ccrz__E_StoredPayment__c>([SELECT Id, Original_PO_Amount__c, Remaining_PO_Amount__c FROM ccrz__E_StoredPayment__c WHERE Id IN :setStoredPaymentsIds]);

        // set the amount fields in the map to be returned.
        for (Map<String, Object> sp : listStoredPayments) {
            ccrz__E_StoredPayment__c sObjSP = mapSP.get((String) sp.get('sfid'));
            sp.put('originalPOAmount', sObjSP.Original_PO_Amount__c);
            sp.put('remainingPOAmount', sObjSP.Remaining_PO_Amount__c);
        }

        return theMap;
    }


    // override the method so that we can save the new Amount fields:
    // 1. Original PO Amount
    // 2. Remaining PO Amount
    global override Map<String, Object> createStoredPayment(Map<String, Object> inputData) {

        // get the data from original method
        Map<String, Object> theMap = super.createStoredPayment(inputData);

        // get transaction data
        TransactionPaymentParams storedPayment = (TransactionPaymentParams) theMap.get(ccrz.cc_hk_Payment.PARAM_TRANSACTION_PROCESSED_DATA);

        // if accountType is po also store Original_PO_Amount__c  and Remaining_PO_Amount__c
        if (storedPayment.accountType == 'po') {
            // get originalPOAmount

            Map<String, Object> transactionData = (Map<String, Object>) JSON.deserializeUntyped((String) inputData.get(ccrz.cc_hk_Payment.PARAM_TRANSACTION_DATA));
            Decimal originalPOAmount = (Decimal)transactionData.get('originalPOAmount');
            Date startDate = DateUtil.parse((String) transactionData.get('poStartDate'), DateUtil.format.YYYY_MM_DD);
            Date endDate = DateUtil.parse((String) transactionData.get('poEndDate'), DateUtil.format.YYYY_MM_DD);

            //update Original_PO_Amount__c  and Remaining_PO_Amount__c 
            ccrz__E_StoredPayment__c pmt = new ccrz__E_StoredPayment__c(
                    Id = storedPayment.storedPaymentId,
                    ccrz__DisplayName__c = (String)transactionData.get('displayName'),
                    Original_PO_Amount__c = originalPOAmount,
                    Remaining_PO_Amount__c = originalPOAmount,
                    ccrz__StartDate__c = startDate,
                    ccrz__EndDate__c = endDate
            );
            update pmt;
        }

        return theMap;
    }
}