/**
 * Created by dgajwani on 9/21/18.
 */

public with sharing class cc_lx_OrderUtil {

    //CyberSource Response message keys.
    private static final String CYBER_SOURCE_RESPONSE_PAYMENT_TOKEN = 'payment_token';
    private static final String CYBER_SOURCE_RESPONSE_CARD_EXPIRATION_KEY = 'req_card_expiry_date';
    private static final String CYBER_SOURCE_TRANSACTION_DECISION_KEY = 'decision';
    private static final String CYBER_SOURCE_DECISION_ACCEPT = 'ACCEPT';
    private static final String CYBER_SOURCE_AUTH_RESPONSE_CODE_KEY = 'auth_response';

    //CyberSource Error Codes
    private static final String CYBER_SOURCE_ERROR_INVALID_CARD_NUMBER = '591';
    private static final String CYBER_SOURCE_ERROR_INVALID_ADDRESS = '547';
    private static final String CYBER_SOURCE_ERROR_INVALID_CVV = '531';
    private static final String CYBER_SOURCE_ERROR_INVALID_EXPIRATION_DATE = '605';
    private static final String CYBER_SOURCE_ERROR_INSUFFICIENT_FUNDS = '521';

    //Error messages to user.
    private static final String ERROR_MESSAGE_INSUFFICIENT_FUNDS = 'Card Declined. Insufficient funds.';
    private static final String ERROR_MESSAGE_INVALID_BILLING_ADDRESS = 'Card Declined. Invalid billing address.';
    private static final String ERROR_MESSAGE_INVALID_CARD_DETAILS = 'Card Declined. Please check the card number, CVV and expiration number.';
    private static final String ERROR_MESSAGE_CARD_DECLINED_UNKNOWN_REASON = 'Card Declined.';
    private static final String ERROR_MESSAGE_FAILED_TO_CREATE_ORDER = 'Failed to create an order';
    private static final String MESSAGE_SUCCESSFULLY_CREATED_AN_ORDER = 'Successfully created an order.';
    private static final String ERROR_MESSAGE_DEFAULT_PAYMENT_FAIL = 'There was problem with the payment.';

    //Response map Keys
    private static final String ORDER_ID = 'orderId';
    private static final String RETURN_MESSAGE = 'message';
    private static final String SUCCESS_KEY = 'success';
    private static final String PAYMENT_TOKEN = 'token';
    private static final String EXPIRATION_MONTH = 'expirationMonth';
    private static final String EXPIRATION_YEAR = 'expirationYear';
    private static final String ACCOUNT_TYPE = 'accountType';
    private static final String ACCOUNT_TYPE_CREDIT_CARD = 'cc';

    //Misc
    private static final String CART_ENCID = 'encryptedId';
    private static final String CONTEXT_STOREFRONT_KEY = 'storefront';

    /**
     * @description Returns a Map that is serialized and sent to Payment hook.
     *
     * @param cyberSourceResponse
     *
     * @return
     */
    public static Map<String, Object> getPaymentDataMap(Map<String, Object> cyberSourceResponse) {
        String cardExpiration = (String) cyberSourceResponse.get(CYBER_SOURCE_RESPONSE_CARD_EXPIRATION_KEY);
        String[] cardExpirationSplit;
        Decimal expMonth = 0.0;
        Decimal expYear = 0.0;
        if (cardExpiration.contains('-')) {
            cardExpirationSplit = cardExpiration.split('-');
            expMonth = Decimal.valueOf(cardExpirationSplit[0]);
            expYear = Decimal.valueOf(cardExpirationSplit[1]);
        }

        return new Map<String, Object>{
                PAYMENT_TOKEN => cyberSourceResponse.get(CYBER_SOURCE_RESPONSE_PAYMENT_TOKEN),
                EXPIRATION_MONTH => expMonth,
                EXPIRATION_YEAR => expYear,
                ACCOUNT_TYPE => ACCOUNT_TYPE_CREDIT_CARD
        };
    }

    /**
     * @description Parses the resposne from Cybersource and places an order on successful request.
     *
     * @param
     *
     * @return
     */
    public static Map<String, Object> parseCyberSourceResponse(Map<String, Object> cart, String cybersourcePaymentResponse) {
        String message = ERROR_MESSAGE_DEFAULT_PAYMENT_FAIL;
        Boolean success = false;
        Map<String, Object> response;
        Map<String, Object> cyberSourceResponseMap = (Map<String, Object>) JSON.deserializeUntyped(cybersourcePaymentResponse);
        String storefront = (String) cart.get(CONTEXT_STOREFRONT_KEY);

        if (cyberSourceResponseMap != null && cc_lx_CyberSourceUtil.verifyCyberSourceResponseSignature(cyberSourceResponseMap, storefront)) {
            String transactionDecision = (String) cyberSourceResponseMap.get(CYBER_SOURCE_TRANSACTION_DECISION_KEY);

            if (transactionDecision == CYBER_SOURCE_DECISION_ACCEPT) {
                Map<String, Object> paymentDataMap = getPaymentDataMap(cyberSourceResponseMap);
                response = placeOrder(cart, paymentDataMap);
            } else {
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
                        SUCCESS_KEY => String.valueOf(success),
                        RETURN_MESSAGE => message
                };
            }
        }
        return response;
    }

    /**
     * @description Places an order on the cart and creates a transaction payment record using the payment data.
     *
     * @param cart
     * @param paymentDataMap
     *
     * @return
     */
    public static Map<String, Object> placeOrder(Map<String, Object> cart, Map<String, Object> paymentDataMap) {
        Boolean success = false;
        Map<String, Object> ctx = new Map<String, Object>{
                CONTEXT_STOREFRONT_KEY => (String) cart.get(CONTEXT_STOREFRONT_KEY)
        };

        cc_lx_AccountManagerV2.setContext(JSON.serialize(ctx));
        String paymentDataJSON = JSON.serialize(paymentDataMap);

        String encId = (String) cart.get(CART_ENCID);
        Id orderId = cc_lx_CartManagerV2.placeOrder(encId, paymentDataJSON);
        String message = '';
        if (orderId == null) {
            message = ERROR_MESSAGE_FAILED_TO_CREATE_ORDER;
        } else {
            message = MESSAGE_SUCCESSFULLY_CREATED_AN_ORDER;
            success = true;
        }
        return new Map<String, Object>{
                ORDER_ID => orderId,
                RETURN_MESSAGE => message,
                SUCCESS_KEY => String.valueOf(success)
        };
    }


}