trigger ReducePOAmountOnTransactionPaymentInsert on ccrz__E_TransactionPayment__c (after insert) {
    for (ccrz__E_TransactionPayment__c transactionPayment : Trigger.new) {
        if (transactionPayment.ccrz__AccountType__c == 'po' && String.isNotBlank(transactionPayment.ccrz__StoredPayment__c)) {
            ccrz__E_StoredPayment__c storedPayment = [
                SELECT Id, Remaining_PO_Amount__c
                FROM ccrz__E_StoredPayment__c
                WHERE Id = :transactionPayment.ccrz__StoredPayment__c
                LIMIT 1
            ];
            storedPayment.Remaining_PO_Amount__c -= transactionPayment.ccrz__Amount__c;
            update storedPayment;
        }
    }
}