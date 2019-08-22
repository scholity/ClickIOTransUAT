/**
 * Created by jbarker on 2019-02-08.
 */

public with sharing class phss_cc_TransactionPaymentUtil {

    // payment types
    public static final String CREDIT_CARD_PAYMENT_TYPE = 'cc';

    // transaction types
    public static final String AUTH_TRANSACTION_TYPE = 'AUTH';
    public static final String CAPTURE_TRANSACTION_TYPE = 'CAPTURE';

    // error messages
    public static final String FAILED_TO_OBTAIN_TRANSACTION_PAYMENTS_FOR_STORED_PAYMENT = 'Failed to obtain the transaction payments for the stored payment.';


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
                    SELECT  Id,
                            ccrz__Account__c,
                            ccrz__AccountType__c,
                            ccrz__Amount__c,
                            ccrz__CCOrder__c,
                            ccrz__InvoiceAppliedFor__c,
                            ccrz__ParentTransactionPayment__c,
                            ccrz__PaymentType__c,
                            ccrz__RequestAmount__c,
                            ccrz__SourceTransactionPayment__c,
                            ccrz__Storefront__c,
                            ccrz__Token__c,
                            ccrz__TransactionPaymentId__c,
                            ccrz__TransactionTS__c,
                            ccrz__TransactionType__c
                    FROM    ccrz__E_TransactionPayment__c
                    WHERE   Id = :transactionPaymentId
            ];

        } catch (Exception e) {
            throw new phss_cc_Exception('Failed to fetch transaction payment', e);
        }

        return transactionPayment;
    }

    /**
     * @description Returns a list of transaction payments associated with a stored payment.
     *
     * @param storedPaymentId
     *
     * @return
     */
    public static List<ccrz__E_TransactionPayment__c> getTransactionPaymentsForStoredPayment(String storedPaymentId) {
        List<ccrz__E_TransactionPayment__c> transactionPayments;
        try {
            transactionPayments = [
                    SELECT  cclxrep__Contract__c,
                            ccpgcs__Address__c,
                            ccrz__Account__c,
                            ccrz__AccountNumber__c,
                            ccrz__AccountType__c,
                            ccrz__Address__c,
                            ccrz__Amount__c,
                            ccrz__BillTo__c,
                            ccrz__CCOrder__c,
                            ccrz__CCSubscription__c,
                            ccrz__Comments__c,
                            ccrz__Contact__c,
                            ccrz__CurrencyISOCode__c,
                            ccrz__ExpirationMonth__c,
                            ccrz__ExpirationYear__c,
                            ccrz__InvoiceAppliedFor__c,
                            ccrz__InvoiceAppliedTo__c,
                            ccrz__ParentTransactionPayment__c,
                            ccrz__PaymentType__c,
                            ccrz__RequestAmount__c,
                            ccrz__SoldTo__c,
                            ccrz__SourceTransactionPayment__c,
                            ccrz__StoredPayment__c,
                            ccrz__Storefront__c,
                            ccrz__SubAccountNumber__c,
                            ccrz__Token__c,
                            ccrz__TransactionCode__c,
                            ccrz__TransactionPaymentId__c,
                            ccrz__TransactionSubcode__c,
                            ccrz__TransactionTS__c,
                            ccrz__TransactionType__c,
                            ccrz__User__c,
                            ccrz__VerificationCode__c,
                            Id,
                            Name
                    FROM    ccrz__E_TransactionPayment__c
                    WHERE   ccrz__StoredPayment__c = :storedPaymentId
                    ORDER BY CreatedDate
            ];
        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_OBTAIN_TRANSACTION_PAYMENTS_FOR_STORED_PAYMENT, e);
        }
        return transactionPayments;
    }
}