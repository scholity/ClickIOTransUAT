/**
 * Created by jbarker on 2019-02-08.
 */

public with sharing class phss_cc_TransactionPaymentUtil {

    // payment types
    public static final String CREDIT_CARD_PAYMENT_TYPE = 'cc';

    // transaction types
    public static final String AUTH_TRANSACTION_TYPE = 'AUTH';
    public static final String CAPTURE_TRANSACTION_TYPE = 'CAPTURE';


    public static Boolean isAuthTransaction(ccrz__E_TransactionPayment__c tp) {
        return tp.ccrz__TransactionType__c == AUTH_TRANSACTION_TYPE;
    }

    public static Boolean isCaptureTransaction(ccrz__E_TransactionPayment__c tp) {
        return tp.ccrz__TransactionType__c == CAPTURE_TRANSACTION_TYPE;
    }


    public static ccrz__E_TransactionPayment__c fetchTransactionPayment(String transactionPaymentId) {
        ccrz__E_TransactionPayment__c transactionPayment;
        try {
             transactionPayment = [
                    SELECT Id, ccrz__Account__c, ccrz__AccountType__c, ccrz__Amount__c, ccrz__CCOrder__c,
                            ccrz__InvoiceAppliedFor__c, ccrz__ParentTransactionPayment__c, ccrz__PaymentType__c,
                            ccrz__RequestAmount__c, ccrz__SourceTransactionPayment__c, ccrz__Storefront__c, ccrz__Token__c,
                            ccrz__TransactionPaymentId__c, ccrz__TransactionTS__c, ccrz__TransactionType__c
                    FROM ccrz__E_TransactionPayment__c
                    WHERE Id = :transactionPaymentId
            ];

        } catch (Exception e) {
            throw new phss_cc_Exception('Failed to fetch transaction payment', e);
        }

        return transactionPayment;
    }
}