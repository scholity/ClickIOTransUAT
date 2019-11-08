/**
 * Created by jbarker on 2019-02-08.
 */

public with sharing class phss_cc_TransactionPaymentUtil {

    // payment types
    public static final String CREDIT_CARD_PAYMENT_TYPE = 'cc';

    // transaction types
    public static final String AUTH_TRANSACTION_TYPE = 'AUTH';
    public static final String CAPTURE_TRANSACTION_TYPE = 'CAPTURE';
    public static final String BALANCE_TRANSACTION_TYPE= 'BALANCE';

    // error messages
    public static final String FAILED_TO_CREATE_CAPTURE_TRANSACTION_PAYMENT_FROM_AUTH_TRANSACTION_PAYMENT = 'Failed to create CAPTURE transaction payment from AUTH transaction payment.';
    public static final String FAILED_TO_DESIGNATE_CONTACT = 'Failed to designate contact on the transaction payment.';
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
                            ccrz__BillTo__c,
                            ccrz__CCOrder__c,
                            ccrz__CCOrder__r.Opportunity_Order__c,
                            ccrz__Contact__c,
                            ccrz__InvoiceAppliedFor__c,
                            ccrz__ParentTransactionPayment__c,
                            ccrz__PaymentType__c,
                            ccrz__RequestAmount__c,
                            ccrz__SoldTo__c,
                            ccrz__SourceTransactionPayment__c,
                            ccrz__Storefront__c,
                            ccrz__Token__c,
                            ccrz__TransactionPaymentId__c,
                            ccrz__TransactionTS__c,
                            ccrz__TransactionType__c,
                            ccrz__User__c,
                            Name
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

    /**
     * @description Creates a CAPTURE transaction payment based on the specified AUTH transaction payment
     *
     * @param authTransactionPaymentId
     *
     * @return
     */
    public static ccrz__E_TransactionPayment__c createCaptureTransactionPaymentFromAuthTransactionPayment(String authTransactionPaymentId) {
        try {
            ccrz__E_TransactionPayment__c authTxnPmt = fetchTransactionPayment(authTransactionPaymentId);

            ccrz__E_TransactionPayment__c captureTxnPmt = new ccrz__E_TransactionPayment__c();
            captureTxnPmt.ccrz__Account__c = authTxnPmt.ccrz__Account__c;
            captureTxnPmt.ccrz__AccountType__c = authTxnPmt.ccrz__AccountType__c;
            captureTxnPmt.ccrz__Amount__c = authTxnPmt.ccrz__Amount__c;
            captureTxnPmt.ccrz__BillTo__c = authTxnPmt.ccrz__BillTo__c;
            captureTxnPmt.ccrz__CCOrder__c = authTxnPmt.ccrz__CCOrder__c;
            captureTxnPmt.ccrz__Contact__c = authTxnPmt.ccrz__Contact__c;
            captureTxnPmt.ccrz__SoldTo__c = authTxnPmt.ccrz__SoldTo__c;
            captureTxnPmt.ccrz__SourceTransactionPayment__c = authTxnPmt.Id;
            captureTxnPmt.ccrz__Storefront__c = authTxnPmt.ccrz__Storefront__c;
            captureTxnPmt.ccrz__TransactionType__c = CAPTURE_TRANSACTION_TYPE;
            captureTxnPmt.ccrz__User__c = authTxnPmt.ccrz__User__c;
            insert captureTxnPmt;
            return captureTxnPmt;

        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_CREATE_CAPTURE_TRANSACTION_PAYMENT_FROM_AUTH_TRANSACTION_PAYMENT, e);
        }
    }

    /**
     * @description Assigns the contact on the transaction payment. This is ONLY intended for Individual Accounts.
     *
     * @param transactionPaymentId
     *
     * @return
     */
    public static void designateContactForTransactionPayment(ccrz__E_TransactionPayment__c transactionPayment) {
        try {
            List<AccountContactRelation> relations = [
                    SELECT
                            ContactId
                    FROM
                            AccountContactRelation
                    WHERE
                            AccountId = :transactionPayment.ccrz__Account__c
                            AND IsDirect = true
                    ORDER BY
                            CreatedDate DESC
            ];
            if (relations != null && relations.size() > 0) {
                AccountContactRelation relation = relations[0];
                if (relation.ContactId != null) {
                    transactionPayment.ccrz__Contact__c = relation.ContactId;
                    update transactionPayment;
                }
            }

        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_DESIGNATE_CONTACT, e);
        }
    }
}