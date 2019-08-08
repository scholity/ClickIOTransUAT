/**
 * Created by jbarker on 12/19/18.
 */

public with sharing class phss_cc_FulfillmentUtil {

    private static final String INVOICE_STATUS_CLOSED = 'Closed';
    private static final String FULFILLMENT_ITEM_STATUS_READY = 'Ready';
    private static final String FULFILLMENT_ITEM_STATUS_COMPLETE = 'Complete';

    //  error messages
    private static final String FAILED_TO_CAPTURE_PAYMENT = 'Failed to capture payment.';
    private static final String FAILED_TO_COMPLETE_FULFILLMENT = 'Failed to complete fulfillment.';
    private static final String FAILED_TO_CREATE_INVOICE = 'Failed to create invoice.';
    private static final String FAILED_TO_CREATE_CAPTURE_TRANSACTION_PAYMENT = 'Failed to create the transaction payment for the payment capture.';
    private static final String FAILED_TO_FINALIZE_PAYMENT = 'Failed to finalize payment.';


    /**
     * @description Captures the payment information related to the Fulfillment
     *
     * @param fulfillment
     */
    public static void capturePayment(Fulfillment__c fulfillment) {

        if (fulfillment == null || fulfillment.Order__c == null) {
            System.debug('capture payment: the fulfillment object is null');
            return;
        }

        try {
            ccrz__E_TransactionPayment__c payment = getTransactionPaymentForOrder(fulfillment.Order__c);
            if (payment != null && payment.ccrz__AccountType__c == phss_cc_TransactionPaymentUtil.CREDIT_CARD_PAYMENT_TYPE && payment.ccrz__Amount__c > 0) {
                phss_cc_CyberSourceUtil.capturePayment(payment.Id, fulfillment.Id);
            }

        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_CAPTURE_PAYMENT, e);
        }
    }


    /**
     * @description Completes the open items associated to a fulfillment record
     *
     * @param fulfillmentId
     */
    public static Fulfillment__c completeFulfillment(String fulfillmentId, String transactionPaymentId) {

        List<Fulfillment_Item__c> fulfillmentItems = getFulfillmentItems(fulfillmentId);
        List<Fulfillment_Item__c> updatedItems = new List<Fulfillment_Item__c>();

        try {
            Fulfillment__c fulfillment = getFulfillment(fulfillmentId);

            if (String.isNotBlank(transactionPaymentId)) {
                fulfillment.CC_Transaction_Payment__c = transactionPaymentId;
                update fulfillment;
            }

            for (Fulfillment_Item__c item : fulfillmentItems) {
                if (item.Status__c == FULFILLMENT_ITEM_STATUS_READY) {
                    item.Status__c = FULFILLMENT_ITEM_STATUS_COMPLETE;
                    updatedItems.add(item);
                }
            }
            update updatedItems;

            return fulfillment;

        } catch (Exception e) {
            system.debug('@@@completeFulfillment Exception: '+e.getMessage());
            throw new phss_cc_Exception(FAILED_TO_COMPLETE_FULFILLMENT, e);
        }
    }

	@testVisible
    private static ccrz__E_TransactionPayment__c completeAuthTransactionPayment(String transactionPaymentId, String invoiceId) {
        ccrz__E_TransactionPayment__c transactionPayment = getTransactionPayment(transactionPaymentId);
        if (transactionPayment != null) {
            transactionPayment.ccrz__InvoiceAppliedFor__c = invoiceId;
            transactionPayment.ccrz__TransactionType__c = phss_cc_TransactionPaymentUtil.AUTH_TRANSACTION_TYPE;
            update transactionPayment;
        }
        return transactionPayment;
    }

	@testVisible
    private static ccrz__E_Invoice__c createInvoiceForPayment(String transactionPaymentId) {

        try {
            ccrz__E_TransactionPayment__c payment = getTransactionPayment(transactionPaymentId);
            ccrz__E_Invoice__c invoice = new ccrz__E_Invoice__c();
            invoice.ccrz__CCOrder__c = payment.ccrz__CCOrder__c;
            invoice.ccrz__CurrencyCode__c = payment.ccrz__CurrencyISOCode__c;
            invoice.ccrz__DateIssued__c = System.now().date();
            invoice.ccrz__OriginalAmount__c = payment.ccrz__Amount__c;
            invoice.ccrz__RemainingAmount__c = 0;
            invoice.ccrz__Status__c = INVOICE_STATUS_CLOSED;
            invoice.ccrz__Storefront__c = payment.ccrz__Storefront__c;
            insert invoice;

            // Create Invoice Items
            List<ccrz__E_InvoiceItem__c> invoiceItems = new List<ccrz__E_InvoiceItem__c>();
            List<ccrz__E_OrderItem__c> orderItems = getItemsForOrder(payment.ccrz__CCOrder__c);
            for (ccrz__E_OrderItem__c orderItem : orderItems) {
                ccrz__E_InvoiceItem__c invoiceItem = new ccrz__E_InvoiceItem__c();
                invoiceItem.ccrz__Invoice__c = invoice.Id;
                invoiceItem.ccrz__CCOrder__c = invoice.ccrz__CCOrder__c;
                invoiceItem.ccrz__CCOrderItem__c = orderItem.Id;
                invoiceItem.ccrz__OriginalAmount__c = orderItem.ccrz__AdjustmentAmount__c;
                invoiceItem.Quantity__c = orderItem.ccrz__Quantity__c;
                invoiceItems.add(invoiceItem);
            }
            if (invoiceItems.size() > 0) {
                insert invoiceItems;
            }

            return invoice;

        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_CREATE_INVOICE, e);
        }
    }


    private static ccrz__E_TransactionPayment__c createCaptureTransactionPayment(Map<String, Object> cyberSourceResponseMap, ccrz__E_TransactionPayment__c srcTransactionPayment, String invoiceId) {

        try {
            ccrz__E_TransactionPayment__c transactionPayment = new ccrz__E_TransactionPayment__c();
            transactionPayment.ccrz__InvoiceAppliedFor__c = invoiceId;
            transactionPayment.ccrz__SourceTransactionPayment__c = srcTransactionPayment.Id;
            transactionPayment.ccrz__Account__c = srcTransactionPayment.ccrz__Account__c;
            transactionPayment.ccrz__AccountType__c = srcTransactionPayment.ccrz__AccountType__c;
            transactionPayment.ccrz__CCOrder__c = srcTransactionPayment.ccrz__CCOrder__c;
            transactionPayment.ccrz__Storefront__c = srcTransactionPayment.ccrz__Storefront__c;
            transactionPayment.ccrz__TransactionType__c = phss_cc_TransactionPaymentUtil.CAPTURE_TRANSACTION_TYPE;

            String cardTypeCode = (String) cyberSourceResponseMap.get(phss_cc_CyberSourceUtil.CYBER_SOURCE_REQ_CARD_TYPE_KEY);
            if (String.isNotBlank(cardTypeCode)) {
                Map<String, Object> cardTypes = phss_cc_CyberSourceUtil.translateCardTypes(cardTypeCode);
                String cardType = (String) cardTypes.get(cardTypeCode);
                if (String.isNotBlank(cardType)) {
                    transactionPayment.ccrz__PaymentType__c = cardType;
                }
            }

            String requestToken = (String) cyberSourceResponseMap.get(phss_cc_CyberSourceUtil.CYBER_SOURCE_REQUEST_TOKEN_KEY);
            if (String.isNotBlank(requestToken)) {
                transactionPayment.ccrz__Token__c = requestToken;
            }

            String transactionId = (String) cyberSourceResponseMap.get(phss_cc_CyberSourceUtil.CYBER_SOURCE_TRANSACTION_ID_KEY);
            if (String.isNotEmpty(transactionId)) {
                transactionPayment.ccrz__TransactionPaymentId__c = transactionId;
            }

            String authTime = (String) cyberSourceResponseMap.get(phss_cc_CyberSourceUtil.CYBER_SOURCE_AUTH_TIME_KEY);
            if (String.isNotBlank(authTime)) {
                Datetime timestamp = parseDatetime(authTime);
                transactionPayment.ccrz__TransactionTS__c = timestamp;
            }

            String authAmount = (String) cyberSourceResponseMap.get(phss_cc_CyberSourceUtil.CYBER_SOURCE_AUTH_AMOUNT_KEY);
            if (String.isNotBlank(authAmount)) {
                Decimal amount = Decimal.valueOf(authAmount);
                transactionPayment.ccrz__Amount__c = amount;
            }

            String reqAmount = (String) cyberSourceResponseMap.get(phss_cc_CyberSourceUtil.CYBER_SOURCE_REQ_AMOUNT_KEY);
            if (String.isNotBlank(reqAmount)) {
                Decimal amount = Decimal.valueOf(reqAmount);
                transactionPayment.ccrz__RequestAmount__c = amount;
            }

            insert transactionPayment;
            return transactionPayment;

        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_CREATE_CAPTURE_TRANSACTION_PAYMENT, e);
        }
    }


    /**
     * @description Finalizes a transaction payment
     *
     * @param paymentId
     * @param fulfillmentId
     */
    public static void finalizePayment(String transactionPaymentId, String fulfillmentId, Map<String, Object> cyberSourceResponseMap) {
        try {
            ccrz__E_Invoice__c invoice = createInvoiceForPayment(transactionPaymentId);
            completeFulfillment(fulfillmentId, transactionPaymentId);
            
            ccrz__E_TransactionPayment__c authTransactionPayment = completeAuthTransactionPayment(transactionPaymentId, invoice.Id);
            ccrz__E_TransactionPayment__c captureTransactionPayment = createCaptureTransactionPayment(cyberSourceResponseMap, authTransactionPayment, invoice.Id);

            authTransactionPayment.ccrz__PaymentType__c = captureTransactionPayment.ccrz__PaymentType__c;
            update authTransactionPayment;

        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_FINALIZE_PAYMENT, e);
        }
    }

	@testVisible
    private static Fulfillment__c getFulfillment(String fulfillmentId) {
        return [
                SELECT Id, Name, CC_Transaction_Payment__c
                FROM Fulfillment__c
                WHERE Id = :fulfillmentId
        ];
    }


    /**
     * @description Returns a list of fulfillment item identifiers for the specified fulfillment identifier
     *
     * @param fulfillmentId
     *
     * @return
     */
    @testVisible
    private static List<Fulfillment_Item__c> getFulfillmentItems(String fulfillmentId) {
        return [
                SELECT Id, Order_Item__c, Quantity__c, Status__c
                FROM Fulfillment_Item__c
                WHERE Fulfillment__c = :fulfillmentId
        ];
    }

	@testVisible
    private static List<ccrz__E_OrderItem__c> getItemsForOrder(String orderId) {
        return [
                SELECT Id, ccrz__AdjustmentAmount__c, ccrz__Quantity__c
                FROM ccrz__E_OrderItem__c
                WHERE ccrz__Order__c = :orderId
        ];
    }

	@testVisible
    private static ccrz__E_TransactionPayment__c getTransactionPayment(String transactionPaymentId) {
        ccrz__E_TransactionPayment__c transactionPayment = [
                SELECT Id, ccrz__Account__c, ccrz__AccountType__c, ccrz__Amount__c, ccrz__CCOrder__c, ccrz__CurrencyISOCode__c, ccrz__PaymentType__c, ccrz__Storefront__c
                FROM ccrz__E_TransactionPayment__c
                WHERE Id = :transactionPaymentId
        ];
        return transactionPayment;
    }


    /**
     * @description Fetches the transaction payment related to the order
     *
     * @param orderId
     *
     * @return
     */
    @testVisible
    private static ccrz__E_TransactionPayment__c getTransactionPaymentForOrder(String orderId) {

        if (String.isBlank(orderId)) {
            return null;
        }

        List<ccrz__E_TransactionPayment__c> transactionPayments = [
                SELECT Id
                FROM ccrz__E_TransactionPayment__c
                WHERE ccrz__CCOrder__c = :orderId
        ];

        if (transactionPayments.size() > 0) {
            String transactionPaymentId = transactionPayments[0].Id;
            ccrz__E_TransactionPayment__c transactionPayment = getTransactionPayment(transactionPaymentId);
            return transactionPayment;
        }

        return null;
    }


    /**
     *
     *
     * @param dtStr A String representation of a Datetime in the format 'YYYY-MM-DDTHHMMSSZ'
     *
     * @return
     */
    @testVisible
    private static Datetime parseDatetime(String dtStr) {
        try {
            List<String> components = dtStr.split('T');
            String dateStr = components.get(0);
            List<String> dateComponents = dateStr.split('-');
            Integer year = Integer.valueOf(dateComponents.get(0));
            Integer month = Integer.valueOf(dateComponents.get(1));
            Integer day = Integer.valueOf(dateComponents.get(2));

            String timeStr = components.get(1);
            Integer hours = Integer.valueOf(timeStr.substring(0, 2));
            Integer minutes = Integer.valueOf(timeStr.substring(2, 4));
            Integer seconds = Integer.valueOf(timeStr.substring(4, 6));

            return Datetime.newInstanceGmt(year, month, day, hours, minutes, seconds);

        } catch (Exception e) {
            throw new phss_cc_Exception('Failed to parse String (' + dtStr + ') as Datetime', e);
        }
    }
}