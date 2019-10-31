/**
 * Created by dgajwani on 9/28/18.
 */

public with sharing class phss_cc_OrderUtil {

    //CyberSource Response message keys.
    private static final String CYBER_SOURCE_RESPONSE_PAYMENT_TOKEN = 'payment_token';
    private static final String CYBER_SOURCE_RESPONSE_CARD_EXPIRATION_KEY = 'req_card_expiry_date';
    private static final String CYBER_SOURCE_RESPONSE_BILL_TO_POSTAL_CODE_KEY = 'req_bill_to_address_postal_code';
    private static final String CYBER_SOURCE_TRANSACTION_DECISION_KEY = 'decision';
    private static final String CYBER_SOURCE_DECISION_ACCEPT = 'ACCEPT';
    @TestVisible private static final String CYBER_SOURCE_AUTH_RESPONSE_CODE_KEY = 'auth_response';

    //CyberSource Error Codes
    @TestVisible private static final String CYBER_SOURCE_ERROR_INVALID_CARD_NUMBER = '591';
    @TestVisible private static final String CYBER_SOURCE_ERROR_INVALID_ADDRESS = '547';
    @TestVisible private static final String CYBER_SOURCE_ERROR_INVALID_CVV = '531';
    @TestVisible private static final String CYBER_SOURCE_ERROR_INVALID_EXPIRATION_DATE = '605';
    @TestVisible private static final String CYBER_SOURCE_ERROR_INSUFFICIENT_FUNDS = '521';

    //Error messages to user.
    private static final String ERROR_MESSAGE_INSUFFICIENT_FUNDS = 'Card Declined. Insufficient funds.';
    private static final String ERROR_MESSAGE_INVALID_BILLING_ADDRESS = 'Card Declined. Invalid billing address.';
    private static final String ERROR_MESSAGE_INVALID_CARD_DETAILS = 'Card Declined. Please check the card number, CVV and expiration number.';
    private static final String ERROR_MESSAGE_CARD_DECLINED_UNKNOWN_REASON = 'Card Declined.';
    private static final String ERROR_MESSAGE_FAILED_TO_CREATE_ORDER = 'Failed to create an order';

    //Response map Keys
    @TestVisible private static final String ORDER_ID = 'orderId';
    @TestVisible private static final String RETURN_MESSAGE = 'message';
    private static final String PAYMENT_TOKEN_KEY = 'token';
    private static final String EXPIRATION_MONTH_KEY = 'expirationMonth';
    private static final String EXPIRATION_YEAR_KEY = 'expirationYear';
    private static final String ACCOUNT_TYPE_KEY = 'accountType';
    private static final String AMOUNT_KEY = 'amount';
    private static final String COMMENTS_KEY = 'comments';
    private static final String REQUEST_AMOUNT_KEY = 'requestAmount';
    public static final String ACCOUNT_TYPE_CREDIT_BALANCE = 'cb';
    public static final String ACCOUNT_TYPE_CREDIT_CARD = 'cc';
    public static final String ACCOUNT_TYPE_PURCHASE_ORDER = 'po';
    public static final String REFUND_COMMENT = 'Refund for Stored Payment. Id=';
    @TestVisible private static final String SUCCESS_KEY = 'success';

    // Credit response keys
    private static final String CREDIT_AMOUNT_KEY = 'creditAmount';
    private static final String STORED_PAYMENTS_KEY = 'storedPayments';
    private static final String APPLICABLE_STORED_PAYMENTS_KEY = 'applicableStoredPayments';
    private static final String SURPLUS_CREDIT_AMOUNT_KEY = 'surplusCreditAmount';
    private static final String GREATEST_REMAINING_BALANCE_STORED_PAYMENT_KEY = 'greatestRemainingBalanceStoredPayment';

    //
    private static final String CREDIT_DATA_KEY = 'creditData';
    private static final String DEFAULT_APPLIED_CREDIT_REASON = 'Using on balance amount';
    private static final String PAYMENT_TYPE_KEY = 'paymentType';
    private static final String STOREFRONT_KEY = 'storefront';
    private static final String TRANSACTION_TYPE_KEY = 'transactionType';

    //Stored payments
    private static final String STORED_PAYMENT_SFID = 'sfid';
    private static final String STORED_PAYMENT_NAME_KEY = 'name';
    private static final String STORED_PAYMENT_ORIGINAL_PO_AMOUNT = 'originalPOAmount';
    private static final String STORED_PAYMENT_REMAINING_PO_AMOUNT = 'remainingPOAmount';
    private static final String STORED_PAYMENT_PO_START_DATE = 'poStartDate';
    private static final String STORED_PAYMENT_PO_END_DATE = 'poEndDate';
    private static final String STORED_PAYMENT_ACCOUNT_TYPE = 'accountType';
    private static final String STORED_PAYMENT_DISPLAY_NAME = 'displayName';
    private static final String STORED_PAYMENT_TYPE_PO = 'po';
    private static final String STORED_PAYMENT_ID_KEY = 'storedPaymentId';
    @TestVisible private static final String STORED_PAYMENT_SAVE_AS_STORED_PAYMENT = 'saveAsStoredPayment';

    // New PO Details from the front end.
    @TestVisible private static final String NEW_PO_SFID_KEY = 'POSfid';
    @TestVisible private static final String NEW_PO_NAME_KEY = 'newPOName';
    @TestVisible private static final String NEW_PO_AMOUNT_KEY = 'newPOAmount';
    @TestVisible private static final String NEW_PO_START_DATE_KEY = 'newPOStartDate';
    @TestVisible private static final String NEW_PO_END_DATE_KEY = 'newPOEndDate';
    @TestVisible private static final String NEW_PO_DOSAVE_KEY = 'newPODoSave';

    // Updates for PO Details from the front end
    @TestVisible private static final String UPDATE_PO_KEY = 'updatePO';
    @TestVisible private static final String UPDATED_PO_AMOUNT_KEY = 'updatedPOAmount';

    // No PO Details from the front end
    @TestVisible private static final String CART_AMOUNT_KEY = 'cartAmount';

    private static final String FAILED_TO_APPLY_CREDIT = 'Failed to apply credit.';
    private static final String FAILED_TO_APPLY_STORED_PAYMENTS_TO_ORDER = 'Failed to apply stored payments to order.';
    private static final String FAILED_TO_PROCESS_PAYMENT_DATA = 'Failed to process payment data.';
    private static final String FAILED_TO_PLACE_ORDER_CB = 'Failed to place order using on account balance.';
    private static final String FAILED_TO_PLACE_ORDER_PO = 'Failed to place order using PO.';
    private static final String FAILED_TO_DETECT_REASON_OF_PAYMENT_FAILURE = 'Failed to detect reason of payment failure.';
    private static final String SUCCESSFULLY_CREATED_AN_ORDER = 'Successfully created an Order.';
    private static final String FAILED_TO_CAPTURE_BILLING_DATA_FOR_PAYMENT = 'Failed to capture billing data for payment.';
    private static final String FAILED_TO_CONVERT_TRANSACTION_PAYMENT_DATA = 'Failed to convert the transaction payment data.';
    private static final String FAILED_TO_CREATE_A_TRANSACTION_RECORD_ON_THE_ORDER = 'Failed to create a transaction record on the order.';
    private static final String FAILED_TO_CREATE_CREDIT_BALANCE_TRANSACTION_PAYMENT = 'Failed to create credit balance transaction payment.';
    private static final String FAILED_TO_GET_ORIGINAL_ORDER_FOR_STORED_PAYMENT = 'Failed to get original order for stored payment.';
    private static final String FAILED_TO_PARSE_PAYMENT_DATA = 'Failed to parse payment data.';
    private static final String FAILED_TO_PLACE_ORDER_CB_WITHOUT_A_STORED_PAYMENT = 'Failed to place order with zero stored payments.';
    private static final String FAILED_TO_FETCH_STORED_PAYMENT = 'Failed to fetch stored payment.';
    private static final String FAILED_TO_ASSIGN_CASE_CONTACT_TO_ORDER = 'Failed to assign case contact to order.';
    private static final String FAILED_TO_IDENTIFY_ORDER_ASSOCIATION_TO_CASE = 'Failed to identify an association between an order and a case.';
    private static final String FAILED_TO_UPDATE_AMOUNT_ON_NEW_TRANSACTION_PAYMENT = 'Failed to update the amount on the new transaction payment.';
    private static final String FAILED_TO_UPDATE_STORED_PAYMENT = 'Failed to update stored payment.';
    private static final String FAILED_TO_REFUND_CREDIT = 'Failed to refund credit';
    private static final String PO_INSUFFICIENT_FUNDS_AVAILABLE = 'The balance of this Purchase Order does not cover your order. Please update value or set up a new Purchase Order to complete your order.';

    /**
     * @description Returns a Map that is serialized and sent to Payment hook.
     *
     * @param inputData
     *
     * @return
     */
    private static String getPaymentDataJSONString(Map<String, Object> inputData) {
        Map<String, Object> paymentDataMap;
        try {
            if (inputData.containsKey(CYBER_SOURCE_RESPONSE_PAYMENT_TOKEN)) {
                String cardExpiration = (String) inputData.get(CYBER_SOURCE_RESPONSE_CARD_EXPIRATION_KEY);
                String[] cardExpirationSplit;
                Decimal expMonth = 0.0;
                Decimal expYear = 0.0;
                if (cardExpiration.contains('-')) {
                    cardExpirationSplit = cardExpiration.split('-');
                    expMonth = Decimal.valueOf(cardExpirationSplit[0]);
                    expYear = Decimal.valueOf(cardExpirationSplit[1]);
                }

                paymentDataMap = new Map<String, Object>{
                        PAYMENT_TOKEN_KEY => inputData.get(CYBER_SOURCE_RESPONSE_PAYMENT_TOKEN),
                        EXPIRATION_MONTH_KEY => expMonth,
                        EXPIRATION_YEAR_KEY => expYear,
                        ACCOUNT_TYPE_KEY => ACCOUNT_TYPE_CREDIT_CARD
                };

            } else if (inputData.containsKey(ACCOUNT_TYPE_KEY) && inputData.get(ACCOUNT_TYPE_KEY) == ACCOUNT_TYPE_CREDIT_BALANCE) {
                Map<String, Object> creditData = (Map<String, Object>) inputData.get(CREDIT_DATA_KEY);
                ccrz__E_StoredPayment__c storedPayment = (ccrz__E_StoredPayment__c) creditData.get(GREATEST_REMAINING_BALANCE_STORED_PAYMENT_KEY);
                Decimal requestAmount = (Decimal) creditData.get(SURPLUS_CREDIT_AMOUNT_KEY);
                paymentDataMap = new Map<String, Object>{
                        ACCOUNT_TYPE_KEY => ACCOUNT_TYPE_CREDIT_BALANCE,
                        PAYMENT_TYPE_KEY => storedPayment.ccrz__PaymentType__c,
                        REQUEST_AMOUNT_KEY => requestAmount,
                        STORED_PAYMENT_ID_KEY => storedPayment.Id,
                        STORED_PAYMENT_SAVE_AS_STORED_PAYMENT => false,
                        STOREFRONT_KEY => storedPayment.ccrz__Storefront__c,
                        TRANSACTION_TYPE_KEY => phss_cc_TransactionPaymentUtil.BALANCE_TRANSACTION_TYPE
                };

            } else if (inputData.containsKey(CART_AMOUNT_KEY)) {
                paymentDataMap = new Map<String, Object>();
                paymentDataMap.put(STORED_PAYMENT_ACCOUNT_TYPE, STORED_PAYMENT_TYPE_PO);
                paymentDataMap.put(STORED_PAYMENT_ORIGINAL_PO_AMOUNT, inputData.get(CART_AMOUNT_KEY));
                paymentDataMap.put(STORED_PAYMENT_REMAINING_PO_AMOUNT, (Decimal) 0);
                paymentDataMap.put(STORED_PAYMENT_PO_START_DATE, Date.today());
                paymentDataMap.put(STORED_PAYMENT_PO_END_DATE, Date.today());
                paymentDataMap.put(STORED_PAYMENT_SAVE_AS_STORED_PAYMENT, false);

            } else if (inputData.containsKey(SURPLUS_CREDIT_AMOUNT_KEY)) {
                ccrz__E_StoredPayment__c storedPayment = (ccrz__E_StoredPayment__c) inputData.get(GREATEST_REMAINING_BALANCE_STORED_PAYMENT_KEY);
                Decimal requestAmount = (Decimal) inputData.get(SURPLUS_CREDIT_AMOUNT_KEY);
                requestAmount *= -1;

                paymentDataMap = new Map<String, Object>{
                        ACCOUNT_TYPE_KEY => ACCOUNT_TYPE_CREDIT_CARD,
                        PAYMENT_TYPE_KEY => storedPayment.ccrz__PaymentType__c,
                        EXPIRATION_MONTH_KEY => storedPayment.ccrz__ExpMonth__c,
                        EXPIRATION_YEAR_KEY => storedPayment.ccrz__ExpYear__c,
                        PAYMENT_TOKEN_KEY => storedPayment.ccrz__Token__c,
                        REQUEST_AMOUNT_KEY => requestAmount,
                        AMOUNT_KEY => requestAmount,
                        COMMENTS_KEY => REFUND_COMMENT + storedPayment.Id
                };

            } else {
                paymentDataMap = new Map<String, Object>();
                paymentDataMap.put(STORED_PAYMENT_ACCOUNT_TYPE, STORED_PAYMENT_TYPE_PO);

                if (inputData.containsKey(STORED_PAYMENT_SFID)) {
                    // Use existing stored payment.
                    paymentDataMap.put(STORED_PAYMENT_ID_KEY, inputData.get(STORED_PAYMENT_SFID));
                } else {
                    // Using a new PO as entered by the customer.
                    paymentDataMap.put(STORED_PAYMENT_DISPLAY_NAME, (String) inputData.get(NEW_PO_NAME_KEY));
                    paymentDataMap.put(STORED_PAYMENT_ORIGINAL_PO_AMOUNT, Decimal.valueOf((String) inputData.get(NEW_PO_AMOUNT_KEY)));
                    paymentDataMap.put(STORED_PAYMENT_REMAINING_PO_AMOUNT, Decimal.valueOf((String) inputData.get(NEW_PO_AMOUNT_KEY)));
                    paymentDataMap.put(STORED_PAYMENT_PO_START_DATE, DateUtil.parse((String) inputData.get(NEW_PO_START_DATE_KEY), DateUtil.format.YYYY_MM_DD));
                    paymentDataMap.put(STORED_PAYMENT_PO_END_DATE, DateUtil.parse((String) inputData.get(NEW_PO_END_DATE_KEY), DateUtil.format.YYYY_MM_DD));
                    paymentDataMap.put(STORED_PAYMENT_SAVE_AS_STORED_PAYMENT, true); //(Boolean) inputData.get(NEW_PO_DOSAVE_KEY));
                }
            }
            return JSON.serialize(paymentDataMap);
        } catch (Exception e) {
            System.debug('exception caught in getPaymentDataJSONString(): ' + e.getMessage() + ' lineNumber=' + e.getLineNumber() + ' stackTrace=' + e.getStackTraceString());
            throw new phss_cc_Exception(FAILED_TO_PARSE_PAYMENT_DATA, e);
        }
    }

    /**
     * @description Creates a CC TransactionPayment Record to store the payment details.
     *
     * @return
     */
    private static Map<String, Object> processPayment(String encryptedCartId, String paymentData) {
        Map<String, Object> processPaymentResponse;
        try {
            ccrz__E_Cart__c cart;

            //Fetch current cart.
            Map<String, Object> cartFetchResponse = phss_cc_CartUtil.cartFetch(encryptedCartId, true);
            List<ccrz__E_Cart__c> outputCartList = (List<ccrz__E_Cart__c>) cartFetchResponse.get(ccrz.ccApiCart.CART_OBJLIST);
            if (outputCartList != null && !outputCartList.isEmpty()) {
                cart = outputCartList[0];
            }

            if (cart != null) {
                Map<String, Object> paymentRequest = new Map<String, Object>{
                        ccrz.cc_hk_Payment.PARAM_TRANSACTION_DATA => paymentData,
                        ccrz.cc_hk_Payment.PARAM_CART => cart,
                        ccrz.cc_hk_Payment.PARAM_PAYMENT_CTX => ccrz.cc_hk_Payment.PARAM_PAYMENT_CTX_CHECKOUT
                };
                ccrz.cc_hk_Payment paymentHook = ccrz.cc_hk_Payment.getInstance(null);
                processPaymentResponse = paymentHook.processPayment(paymentRequest);
            }

        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_PROCESS_PAYMENT_DATA);
        }
        return processPaymentResponse;
    }

    /**
     * @description Creates a transactionPayment record on the order.
     *
     * @param orderPlaceResponse
     * @param processPaymentResponse
     * @param transactionPaymentData
     * @param paymentData
     */
    private static void registerTransactionOnOrder(Map<String, Object> orderPlaceResponse, Map<String, Object> paymentResult, Object transactionPaymentData, String paymentData) {

        try {
            final String payAccountType = (String) paymentResult.get(ccrz.cc_hk_Payment.PARAM_ACCOUNT_TYPE);
            final ccrz.ccPaymentProcessor payProcessor = (ccrz.ccPaymentProcessor) paymentResult.get(ccrz.cc_hk_Payment.PARAM_PAYMENT_PROCESSOR);

            String orderId = (String) orderPlaceResponse.get(ccrz.ccApiCart.ORDER_ID);
            Map<String, Object> createTransactionResults = (Map<String, Object>) orderPlaceResponse.get(ccrz.ccApiCart.TRANSACTIONRESULT);
            Map<String, Object> subRes = (Map<String, Object>) orderPlaceResponse.get(ccrz.ccApiCart.SUBCRESULT);

            Map<String, Object> postProcessRequest = new Map<String, Object>{
                    ccrz.cc_hk_Payment.PARAM_TRANSACTION_DATA => paymentData,
                    ccrz.cc_hk_Payment.PARAM_ORDER_ID => orderId,
                    ccrz.cc_hk_Payment.PARAM_TRANSACTION_PROCESSED_DATA => transactionPaymentData,
                    ccrz.cc_hk_Payment.PARAM_PRIMARY_TRANSACTION_RESULTS => createTransactionResults,
                    ccrz.cc_hk_Payment.PARAM_SUBS_RESULTS => subRes,
                    ccrz.cc_hk_Payment.PARAM_ACCOUNT_TYPE => payAccountType,
                    ccrz.cc_hk_Payment.PARAM_PAYMENT_CTX => ccrz.cc_hk_Payment.PARAM_PAYMENT_CTX_CHECKOUT,
                    ccrz.cc_hk_Payment.PARAM_SUCCESS => true
            };

            if (payProcessor != null) {
                payProcessor.postProcess(postProcessRequest);
            }

        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_CREATE_A_TRANSACTION_RECORD_ON_THE_ORDER);
        }
    }

    /**
     * @description Converts the cart into an Order.
     *
     * @return
     */
    private static Map<String, Object> cartPlace(String encryptedCartId, Map<String, Object> paymentResult, Object transactionPaymentData, String paymentData) {
        try {
            String orderId = null;
            String message;
            Map<String, Object> placeOrderRequest = new Map<String, Object>{
                    ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
                    ccrz.ccApiCart.CART_ENCID => encryptedCartId,
                    ccrz.ccApiCart.SKIP_VALID_CHECK => true
            };

            if (paymentResult != null && transactionPaymentData != null && paymentData != null) {
                placeOrderRequest.put(ccrz.ccApiCart.PAYMENTDATA, paymentData);
                placeOrderRequest.put(ccrz.ccApiCart.TRANSPAYMENTDATA, transactionPaymentData);
                placeOrderRequest.put(ccrz.ccApiCart.PAYMENTRESULT, paymentResult);
            }

            Map<String, Object> placeOrderResponse = ccrz.ccApiCart.place(placeOrderRequest);
            Boolean isSuccess = (Boolean)placeOrderResponse.get(ccrz.ccApi.SUCCESS);
            if (isSuccess) {
                orderId = (String) placeOrderResponse.get(ccrz.ccApiCart.ORDER_ID);
                message = SUCCESSFULLY_CREATED_AN_ORDER;
                assignCaseContactToOrder(orderId);
            } else {
                message = ERROR_MESSAGE_FAILED_TO_CREATE_ORDER;
            }
            return new Map<String, Object>{
                    SUCCESS_KEY => true,
                    ORDER_ID => orderId,
                    RETURN_MESSAGE => SUCCESSFULLY_CREATED_AN_ORDER
            };
        } catch (Exception e) {
            throw new phss_cc_Exception(e.getMessage());
        }
    }

    /**
     * @description Places an order on the cart using the CyberSource credit card response.
     *
     * @return
     */
    public static Map<String, Object> placeOrderOnCartCC(String opportunitySfid, String encryptedCartId, String cyberSourcePaymentResponse, List<String> storedPayments) {

        phss_cc_Context.setContext(opportunitySfid);
        Map<String, Object> response;
        try {
            if (cyberSourcePaymentResponse != null) {
                Map<String, Object> cyberSourceResponseMap = (Map<String, Object>) JSON.deserializeUntyped(cyberSourcePaymentResponse);

                String ccPostalCode = (String) cyberSourceResponseMap.get(CYBER_SOURCE_RESPONSE_BILL_TO_POSTAL_CODE_KEY);
                captureBillingDataForPayment(encryptedCartId, ccPostalCode);

                String transactionDecision = (String) cyberSourceResponseMap.get(CYBER_SOURCE_TRANSACTION_DECISION_KEY);
                if (transactionDecision == CYBER_SOURCE_DECISION_ACCEPT) {
                    String paymentData = getPaymentDataJSONString(cyberSourceResponseMap);
                    Map<String, Object> creditResult = applyCreditToCart(encryptedCartId, storedPayments);
                    Map<String, Object> paymentResult = processPayment(encryptedCartId, paymentData);
                    Object transactionPaymentData = paymentResult.get(ccrz.cc_hk_Payment.PARAM_TRANSACTION_PROCESSED_DATA);

                    Map<String, Object> placeOrderResponse = cartPlace(encryptedCartId, paymentResult, transactionPaymentData, paymentData);
                    registerTransactionOnOrder(placeOrderResponse, paymentResult, transactionPaymentData, paymentData);

                    if (storedPayments != null && storedPayments.size() > 0 && creditResult.containsKey(CREDIT_AMOUNT_KEY)) {
                        String orderId = (String) placeOrderResponse.get(ORDER_ID);
                        applyStoredPayments(orderId, storedPayments);
                    }

                    response = placeOrderResponse;
                } else {
                    response = findPaymentDeclineReason(cyberSourceResponseMap);
                }
            }
        } catch (Exception e) {
            throw new phss_cc_Exception(e.getMessage());
        }
        return response;
    }

    /**
     * @description Places an order on the cart using the CyberSource credit card response.
     *
     * @return
     */
    public static Map<String, Object> placeOrderOnCartPO(String opportunitySfid, String encryptedCartId, Map<String, Object> PODetailsMap) {
        phss_cc_Context.setContext(opportunitySfid);
        Map<String, Object> response;
        try {
            if (PODetailsMap != null) {
                String POSfid = (String) PODetailsMap.get(NEW_PO_SFID_KEY);
                if (POSfid != null && !String.isEmpty(POSfid)) {
                    Boolean shouldUpdatePOAmount = (Boolean) PODetailsMap.get(UPDATE_PO_KEY);
                    String updatedPOAmount = (String) PODetailsMap.get(UPDATED_PO_AMOUNT_KEY);
                    System.debug('shouldUpdatePOAmount ' + shouldUpdatePOAmount);
                    if (shouldUpdatePOAmount) {
                        updateRemainingPOAmount(POSfid, updatedPOAmount);
                    }

                    PODetailsMap = fetchStoredPaymentBySfid(POSfid);
                }

                if (!purchaseOrderHasSufficientFunds(PODetailsMap, encryptedCartId)) {
                    throw new phss_cc_Exception(PO_INSUFFICIENT_FUNDS_AVAILABLE);
                }
            } else {
                PODetailsMap = createDataForNoPurchaseOrder(encryptedCartId);
            }

            String paymentData = getPaymentDataJSONString(PODetailsMap);
            Map<String, Object> paymentResult = processPayment(encryptedCartId, paymentData);
            Object transactionPaymentData = paymentResult.get(ccrz.cc_hk_Payment.PARAM_TRANSACTION_PROCESSED_DATA);
            Map<String, Object> placeOrderResponse = cartPlace(encryptedCartId, paymentResult, transactionPaymentData, paymentData);
            registerTransactionOnOrder(placeOrderResponse, paymentResult, transactionPaymentData, paymentData);
            response = placeOrderResponse;

        } catch (Exception e) {
            if (e.getMessage() == PO_INSUFFICIENT_FUNDS_AVAILABLE) {
                throw e;
            }

            throw new phss_cc_Exception(FAILED_TO_PLACE_ORDER_PO, e);
        }
        return response;
    }

    /**
     * @description Places an order using on account balance for payment.
     *
     * @param opportunitySfid
     * @param encryptedCartId
     * @param storedPaymentIdentifiers
     *
     * @return
     */
    public static Map<String, Object> placeOrderOnCartCB(String opportunitySfid, String encryptedCartId, List<String> storedPaymentIdentifiers) {
        phss_cc_Context.setContext(opportunitySfid);
        Map<String, Object> response;

        try {
            Map<String, Object> paymentInputData;

            Map<String, Object> creditResult;
            if (storedPaymentIdentifiers != null && storedPaymentIdentifiers.size() > 0) {
                creditResult = applyCreditToCart(encryptedCartId, storedPaymentIdentifiers);

                if (creditResult.containsKey(SURPLUS_CREDIT_AMOUNT_KEY)) {
                    // credit card refund
                    paymentInputData = creditResult;

                } else {
                    // credit balance
                    paymentInputData = new Map<String, Object>{
                            ACCOUNT_TYPE_KEY => ACCOUNT_TYPE_CREDIT_BALANCE,
                            CREDIT_DATA_KEY => creditResult
                    };
                }
            } else {
                throw new phss_cc_Exception(FAILED_TO_PLACE_ORDER_CB_WITHOUT_A_STORED_PAYMENT);
            }

            String paymentData = getPaymentDataJSONString(paymentInputData);
            Map<String, Object> paymentResult = processPayment(encryptedCartId, paymentData);

            Object transactionPaymentData = paymentResult.get(ccrz.cc_hk_Payment.PARAM_TRANSACTION_PROCESSED_DATA);
            if (creditResult != null && creditResult.containsKey(SURPLUS_CREDIT_AMOUNT_KEY)) {
                if (transactionPaymentData instanceof ccrz.cc_hk_Payment.TransactionPaymentParams) {
                    ccrz.cc_hk_Payment.TransactionPaymentParams params = (ccrz.cc_hk_Payment.TransactionPaymentParams) transactionPaymentData;
                    Decimal creditAmount = (Decimal) creditResult.get(SURPLUS_CREDIT_AMOUNT_KEY);
                    params.amount = creditAmount * -1;

                } else {
                    throw new phss_cc_Exception(FAILED_TO_CONVERT_TRANSACTION_PAYMENT_DATA);
                }
            }

            Map<String, Object> placeOrderResponse = cartPlace(encryptedCartId, paymentResult, transactionPaymentData, paymentData);

            if (creditResult != null && creditResult.containsKey(CREDIT_AMOUNT_KEY)) {
                for (String storedPaymentId : storedPaymentIdentifiers) {
                    updateRemainingPOAmount(storedPaymentId, '0');
                }
            }

            registerTransactionOnOrder(placeOrderResponse, paymentResult, transactionPaymentData, paymentData);
            response = placeOrderResponse;

            if (creditResult != null && creditResult.containsKey(CREDIT_AMOUNT_KEY)) {
                String orderId = (String) placeOrderResponse.get(ORDER_ID);
                Boolean hasSurplusCredit = creditResult.containsKey(SURPLUS_CREDIT_AMOUNT_KEY);
                List<ccrz__E_StoredPayment__c> storedPayments = (List<ccrz__E_StoredPayment__c>) creditResult.get(STORED_PAYMENTS_KEY);
                ccrz__E_StoredPayment__c greatestRemainingBalanceStoredPayment = (ccrz__E_StoredPayment__c) creditResult.get(GREATEST_REMAINING_BALANCE_STORED_PAYMENT_KEY);
                if (!hasSurplusCredit && greatestRemainingBalanceStoredPayment != null) {

                    Decimal amount = greatestRemainingBalanceStoredPayment.Remaining_PO_Amount__c;
                    updateAmountOnNewTransactionPayment(orderId, greatestRemainingBalanceStoredPayment.Id, amount);

                    /*
                        Remove the greatestRemainingBalanceStoredPayment from list BEFORE creating additional
                        CREDIT BALANCE transaction payments for the order. The first CREDIT BALANCE transaction
                        payment should have already been created during processPayment().
                     */

                    List<ccrz__E_StoredPayment__c> remainingStoredPayments = new List<ccrz__E_StoredPayment__c>();
                    for (ccrz__E_StoredPayment__c storedPayment : storedPayments) {
                        if (storedPayment.Id != greatestRemainingBalanceStoredPayment.Id) {
                            remainingStoredPayments.add(storedPayment);
                        }
                    }
                    storedPayments = remainingStoredPayments;

                    greatestRemainingBalanceStoredPayment.Remaining_PO_Amount__c = 0;
                    update greatestRemainingBalanceStoredPayment;
                }

                if (storedPayments != null && storedPayments.size() > 0) {
                    createCreditBalanceTransactionPayments(orderId, storedPayments);
                }
            }

        } catch (Exception e) {
            System.debug('Exception caught: message=' + e.getMessage() + ' lineNumber=' + e.getLineNumber() + ' stackTrace=' + e.getStackTraceString());
            throw new phss_cc_Exception(FAILED_TO_PLACE_ORDER_CB, e);
        }

        return response;
    }

    /**
     * @description Applies stored payments to the cart total
     *
     * @param encryptedCartId
     * @param storedPaymentIDs
     *
     * @return
     */
    private static Map<String, Object> applyCreditToCart(String encryptedCartId, List<String> storedPaymentIDs) {
        Map<String, Object> result = new Map<String, Object>();

        try {
            List<ccrz__E_StoredPayment__c> storedPayments = phss_cc_StoredPaymentUtil.getStoredPayments(storedPaymentIDs);
            if (storedPayments != null && storedPayments.size() > 0) {

                Decimal creditAmount = 0;
                List<ccrz__E_StoredPayment__c> applicablePayments = new List<ccrz__E_StoredPayment__c>();
                for (ccrz__E_StoredPayment__c storedPayment : storedPayments) {
                    if (storedPayment.Remaining_PO_Amount__c > 0) {
                        applicablePayments.add(storedPayment);
                        creditAmount += storedPayment.Remaining_PO_Amount__c;
                    }
                }

                ccrz__E_Cart__c cart = phss_cc_CartUtil.fetchCart(encryptedCartId);
                if (cart != null) {
                    if (creditAmount > cart.ccrz__TotalAmount__c) {
                        Decimal surplusCredit = creditAmount - cart.ccrz__TotalAmount__c;
                        result.put(SURPLUS_CREDIT_AMOUNT_KEY, surplusCredit);
                        creditAmount = cart.ccrz__TotalAmount__c;
                    }

                    cart.ccrz__AdjustmentAmount__c = creditAmount * -1;
                    cart.ccrz__AdjustmentReason__c = DEFAULT_APPLIED_CREDIT_REASON;
                    update cart;

                    result.put(CREDIT_AMOUNT_KEY, creditAmount);
                }

                if (applicablePayments.size() > 0) {
                    result.put(APPLICABLE_STORED_PAYMENTS_KEY, applicablePayments);
                }

                result.put(STORED_PAYMENTS_KEY, storedPayments);

                ccrz__E_StoredPayment__c storedPaymentWithGreatestBalance = storedPayments[0];
                for (ccrz__E_StoredPayment__c storedPayment : storedPayments) {
                    if (storedPayment.Remaining_PO_Amount__c > storedPaymentWithGreatestBalance.Remaining_PO_Amount__c) {
                        storedPaymentWithGreatestBalance = storedPayment;
                    }
                }

                // Capture the stored payment that can be used for applying the refund
                result.put(GREATEST_REMAINING_BALANCE_STORED_PAYMENT_KEY, storedPaymentWithGreatestBalance);
            }

        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_APPLY_CREDIT, e);
        }

        return result;
    }

    /**
     * @description Creates corresponding transaction payments for stored payments and zeros out their remaining amount
     *
     * @param identifiers
     */
    private static void applyStoredPayments(String orderId, List<String> identifiers) {
        try {
            List<ccrz__E_StoredPayment__c> storedPayments = [
                    SELECT
                            Id,
                            ccrz__Account__c,
                            Remaining_PO_Amount__c
                    FROM
                            ccrz__E_StoredPayment__c
                    WHERE
                            Id IN :identifiers
            ];
            if (storedPayments != null && storedPayments.size() > 0) {
                List<ccrz__E_TransactionPayment__c> transactionPayments = new List<ccrz__E_TransactionPayment__c>();
                for (ccrz__E_StoredPayment__c storedPayment : storedPayments) {
                    ccrz__E_TransactionPayment__c transactionPayment = new ccrz__E_TransactionPayment__c(
                            ccrz__Account__c = storedPayment.ccrz__Account__c,
                            ccrz__AccountType__c = ACCOUNT_TYPE_CREDIT_BALANCE,
                            ccrz__CCOrder__c = orderId,
                            ccrz__Amount__c = storedPayment.Remaining_PO_Amount__c,
                            ccrz__StoredPayment__c = storedPayment.Id
                    );
                    transactionPayments.add(transactionPayment);

                    storedPayment.Remaining_PO_Amount__c = 0;
                }
                insert transactionPayments;
                update storedPayments;
            }

        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_APPLY_STORED_PAYMENTS_TO_ORDER, e);
        }
    }

    /**
     * @description Creates credit balance 'cb' transaction payments based on the applied stored payments
     *
     * @param orderId
     * @param storedPayments
     * @param creditData
     */
    private static void createCreditBalanceTransactionPayments(String orderId, List<ccrz__E_StoredPayment__c> storedPayments) {
        try {
            List<ccrz__E_TransactionPayment__c> transactionPayments = new List<ccrz__E_TransactionPayment__c>();

            if (storedPayments != null) {
                for (ccrz__E_StoredPayment__c storedPayment : storedPayments) {
                    List<ccrz__E_TransactionPayment__c> txnPayments = phss_cc_TransactionPaymentUtil.getTransactionPaymentsForStoredPayment(storedPayment.Id);
                    if (txnPayments != null && txnPayments.size() > 0) {
                        ccrz__E_TransactionPayment__c transactionPayment = new ccrz__E_TransactionPayment__c(
                                ccrz__Account__c = storedPayment.ccrz__Account__c,
                                ccrz__AccountType__c = ACCOUNT_TYPE_CREDIT_BALANCE,
                                ccrz__Amount__c = storedPayment.Remaining_PO_Amount__c,
                                ccrz__BillTo__c = txnPayments[0].ccrz__BillTo__c,
                                ccrz__CurrencyISOCode__c = txnPayments[0].ccrz__CurrencyISOCode__c,
                                ccrz__CCOrder__c = orderId,
                                ccrz__ParentTransactionPayment__c = txnPayments[0].Id,
                                ccrz__StoredPayment__c = storedPayment.Id,
                                ccrz__Storefront__c = txnPayments[0].ccrz__Storefront__c,
                                ccrz__Token__c = storedPayment.ccrz__Token__c
                        );
                        transactionPayments.add(transactionPayment);
                    }
                }
            }

            if (transactionPayments.size() > 0) {
                insert transactionPayments;
            }

        } catch (Exception e) {
            System.debug('createCreditBalanceTransactionPayments()  --  exception caught: ' + e.getMessage() + ' lineNumber=' + e.getLineNumber() + ' stackTrace=' + e.getStackTraceString());
            throw new phss_cc_Exception(FAILED_TO_CREATE_CREDIT_BALANCE_TRANSACTION_PAYMENT, e);
        }
    }

    /**
     * @description Returns the order ID for the original order related to a stored payment.
     *
     * @param storedPaymentId
     *
     * @return
     */
    public static String getOriginalOrderForStoredPayment(String storedPaymentId) {
        String orderId = null;
        try {
            List<ccrz__E_TransactionPayment__c> transactionPayments = [
                    SELECT  Id,
                            ccrz__ParentTransactionPayment__r.ccrz__CCOrder__c
                    FROM    ccrz__E_TransactionPayment__c
                    WHERE   ccrz__StoredPayment__c = :storedPaymentId
            ];

            if (transactionPayments != null) {
                for (ccrz__E_TransactionPayment__c transactionPayment : transactionPayments) {
                    if (String.isNotEmpty(transactionPayment.ccrz__ParentTransactionPayment__r.ccrz__CCOrder__c)) {
                        orderId = transactionPayment.ccrz__ParentTransactionPayment__r.ccrz__CCOrder__c;
                        break;
                    }
                }
            }

        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_GET_ORIGINAL_ORDER_FOR_STORED_PAYMENT, e);
        }

        return orderId;
    }

    /**
     * @description Creates the necessary data for the No-PO option
     *
     * @param encryptedCartId
     *
     * @return
     */
    @TestVisible
    private static Map<String, Object> createDataForNoPurchaseOrder(String encryptedCartId) {
        Decimal cartAmount = 0;

        Map<String, Object> cartFetchResponse = phss_cc_CartUtil.cartFetch(encryptedCartId, true);
        List<ccrz__E_Cart__c> cartList = (List<ccrz__E_Cart__c>) cartFetchResponse.get(ccrz.ccApiCart.CART_OBJLIST);
        if (cartList != null && !cartList.isEmpty()) {
            cartAmount = cartList[0].ccrz__TotalAmount__c;
        }

        Map<String, Object> data = new Map<String, Object>{
                CART_AMOUNT_KEY => cartAmount,
                STORED_PAYMENT_SAVE_AS_STORED_PAYMENT => false
        };

        return data;
    }

    /**
     * @description Returns a flag indicating whether the cart total exceeds the remaining balance on the PO
     *
     * @param PODetailsMap
     * @param encryptedCartId
     *
     * @return
     */
    private static Boolean purchaseOrderHasSufficientFunds(Map<String, Object> PODetailsMap, String encryptedCartId) {

        Map<String, Object> cartFetchResponse = phss_cc_CartUtil.cartFetch(encryptedCartId, true);
        List<ccrz__E_Cart__c> outputCartList = (List<ccrz__E_Cart__c>) cartFetchResponse.get(ccrz.ccApiCart.CART_OBJLIST);

        if (outputCartList != null && !outputCartList.isEmpty()) {
            ccrz__E_Cart__c cart = outputCartList[0];
            Decimal cartTotal = cart.ccrz__TotalAmount__c;

            if (PODetailsMap.containsKey(STORED_PAYMENT_REMAINING_PO_AMOUNT)) {
                Decimal remainingBalance = (Decimal) PODetailsMap.get(STORED_PAYMENT_REMAINING_PO_AMOUNT);
                return remainingBalance >= cartTotal;
            }
            else if (PODetailsMap.containsKey(NEW_PO_AMOUNT_KEY)) {
                Decimal newPOAmount = Decimal.valueOf(PODetailsMap.get(NEW_PO_AMOUNT_KEY).toString());
                return newPOAmount >= cartTotal;
            }
        }

        return false;
    }

    /**
     * @description Finds out the reason if the payment was declined.
     *
     * @param cyberSourceResponseMap
     *
     * @return
     */
    @TestVisible
    private static Map<String, Object> findPaymentDeclineReason(Map<String, Object> cyberSourceResponseMap) {
        Map<String, Object> response;
        String message = '';
        try {
            String failureCode = (String) cyberSourceResponseMap.get(CYBER_SOURCE_AUTH_RESPONSE_CODE_KEY);
            if (failureCode == CYBER_SOURCE_ERROR_INSUFFICIENT_FUNDS) {
                message = ERROR_MESSAGE_INSUFFICIENT_FUNDS;
            } else if (failureCode == CYBER_SOURCE_ERROR_INVALID_ADDRESS) {
                message = ERROR_MESSAGE_INVALID_BILLING_ADDRESS;
            } else if (failureCode == CYBER_SOURCE_ERROR_INVALID_CVV || failureCode == CYBER_SOURCE_ERROR_INVALID_CARD_NUMBER || failureCode == CYBER_SOURCE_ERROR_INVALID_EXPIRATION_DATE) {
                message = ERROR_MESSAGE_INVALID_CARD_DETAILS;
            } else {
                message = ERROR_MESSAGE_CARD_DECLINED_UNKNOWN_REASON;
            }
            response = new Map<String, Object>{
                    SUCCESS_KEY => false,
                    RETURN_MESSAGE => message
            };
        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_DETECT_REASON_OF_PAYMENT_FAILURE);
        }
        return response;
    }

    /**
     * @description Fetches the stored payment details and returns a map.
     *
     * @param POSfid
     *
     * @return
     */
    private static Map<String, Object> fetchStoredPaymentBySfid(String POSfid) {
        Map<String, Object> fetchStoredPaymentResponse;
        try {
            ccrz__E_StoredPayment__c storedPayment = [
                    SELECT Id, ccrz__Account__c,ccrz__AccountType__c,ccrz__DisplayName__c,ccrz__PaymentType__c, Original_PO_Amount__c,Remaining_PO_Amount__c
                    FROM ccrz__E_StoredPayment__c
                    WHERE Id = :POSfid
                    LIMIT 1
            ];
            fetchStoredPaymentResponse = new Map<String, Object>{
                    STORED_PAYMENT_SFID => storedPayment.Id,
                    STORED_PAYMENT_ACCOUNT_TYPE => storedPayment.ccrz__AccountType__c,
                    STORED_PAYMENT_NAME_KEY => storedPayment.ccrz__DisplayName__c,
                    STORED_PAYMENT_ORIGINAL_PO_AMOUNT => storedPayment.Original_PO_Amount__c,
                    STORED_PAYMENT_REMAINING_PO_AMOUNT => storedPayment.Remaining_PO_Amount__c
            };
        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_FETCH_STORED_PAYMENT);
        }
        return fetchStoredPaymentResponse;
    }

    /**
     * @description Stores payment data on the transaction payment
     *
     * @param
     * @param
     */
    private static void captureBillingDataForPayment(String encryptedCartId, String postalCode) {
        try {
            ccrz__E_Cart__c cart = [
                    SELECT
                            Id,
                            Payment_Postal_Code__c
                    FROM
                            ccrz__E_Cart__c
                    WHERE
                            ccrz__EncryptedId__c = :encryptedCartId
            ];
            if (cart != null) {
                cart.Payment_Postal_Code__c = postalCode;
                update cart;
            }

        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_CAPTURE_BILLING_DATA_FOR_PAYMENT, e);
        }
    }

/**
 * @description Creates a transaction payment record for an order not associated with a purchase order
 *
 * @param orderId
 */
    @TestVisible
    private static void createNoPOTransactionPaymentForOrder(String orderId) {
        if (String.isBlank(orderId)) {
            return;
        }

        try {
            ccrz__E_Order__c order = [
                    SELECT ccrz__Account__c, ccrz__CurrencyISOCode__c, ccrz__Storefront__c, ccrz__TotalAmount__c
                    FROM ccrz__E_Order__c
                    WHERE Id = :orderId
                    LIMIT 1
            ];

            if (order != null) {
                ccrz__E_TransactionPayment__c transactionPayment = new ccrz__E_TransactionPayment__c();
                transactionPayment.ccrz__Account__c = order.ccrz__Account__c;
                transactionPayment.ccrz__AccountType__c = ACCOUNT_TYPE_PURCHASE_ORDER;
                transactionPayment.ccrz__Amount__c = order.ccrz__TotalAmount__c;
                transactionPayment.ccrz__CCOrder__c = orderId;
                transactionPayment.ccrz__CurrencyISOCode__c = order.ccrz__CurrencyISOCode__c;
                transactionPayment.ccrz__Storefront__c = order.ccrz__Storefront__c;
                transactionPayment.ccrz__TransactionTS__c = System.now();
                transactionPayment.ccrz__User__c = UserInfo.getUserId();
                insert transactionPayment;
            }

        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_CREATE_A_TRANSACTION_RECORD_ON_THE_ORDER);
        }
    }

    /**
     * @description Assigns the contact on the case (if associated to one) to the order
     *
     * @param orderId
     */
    @TestVisible
    private static void assignCaseContactToOrder(String orderId) {
        try {
            ccrz__E_Order__c order = [
                    SELECT  Opportunity_Order__r.Case__r.ContactId,
                            ccrz__Contact__c
                    FROM    ccrz__E_Order__c
                    WHERE   Id = :orderId
            ];
            if (order != null && order.Opportunity_Order__r.Case__r.ContactId != null && order.ccrz__Contact__c == null) {
                order.ccrz__Contact__c = order.Opportunity_Order__r.Case__r.ContactId;
                update order;
            }

        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_ASSIGN_CASE_CONTACT_TO_ORDER, e); 
        }
    }

    /**
     * @description Updates the stored payment's remaining PO amount.
     *
     * @param POSfid
     * @param amountStr
     */
    private static void updateRemainingPOAmount(String POSfid, String amountStr) {
        Decimal amount = Decimal.valueOf(amountStr);
        if (String.isBlank(POSfid) || amount < 0) {
            return;
        }

        try {
            ccrz__E_StoredPayment__c storedPayment = [
                    SELECT  Id,
                            ccrz__Account__c,
                            ccrz__AccountType__c,
                            ccrz__DisplayName__c,
                            ccrz__PaymentType__c,
                            Original_PO_Amount__c,
                            Remaining_PO_Amount__c
                    FROM    ccrz__E_StoredPayment__c
                    WHERE   Id = :POSfid
                    LIMIT   1
            ];

            if (storedPayment != null) {
                storedPayment.Remaining_PO_Amount__c = amount;
                update storedPayment;
            }

        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_UPDATE_STORED_PAYMENT);
        }
    }

    private static void updateAmountOnNewTransactionPayment(String orderId, String storedPaymentId, Decimal amount) {
        if (String.isNotBlank(orderId) && String.isNotBlank(storedPaymentId)) {
            try {
                Id orderIdentifier = Id.valueOf(orderId);
                Id storedPaymentIdentifier = Id.valueOf(storedPaymentId);
                ccrz__E_TransactionPayment__c transactionPayment = [
                        SELECT
                                Id,
                                ccrz__Amount__c,
                                ccrz__RequestAmount__c
                        FROM
                                ccrz__E_TransactionPayment__c
                        WHERE
                                ccrz__CCOrder__c = :orderIdentifier
                                AND ccrz__StoredPayment__c = :storedPaymentIdentifier
                        ORDER BY
                                CreatedDate DESC
                        LIMIT
                                1
                ];
                System.debug('JASON: updateAmountOnTransactionPayment()  --  transactionPayment: ' + transactionPayment);
                if (transactionPayment != null) {
                    transactionPayment.ccrz__Amount__c = amount;
                    update transactionPayment;
                }
            } catch (Exception e) {
                throw new phss_cc_Exception(FAILED_TO_UPDATE_AMOUNT_ON_NEW_TRANSACTION_PAYMENT, e);
            }
        }
    }
}