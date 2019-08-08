/**
 * Created by dgajwani on 9/11/18.
 */

public with sharing class cc_lx_CyberSourceCCProcessorController {

    private static final String SUCCESS = 'success';
    private static final String RETURN_MESSAGE = 'message';
    private static final String ERROR_MESSAGE_FORM_DATA_ERROR = 'There was a problem processing the form data.';
    private static final String ERROR_MESSAGE_PAYMENT_DATA_ERROR = 'There was a problem processing the payment data.';

    /**
     * @description Returns the data required to make a POST request to CyberSource.
     *
     * @param ctx
     *
     * @return
     */
    @AuraEnabled
    public static Map<String, Object> getCybersourceHostedFormData(String currCartId) {
        Map<String, Object> response;
        try {
            response = cc_lx_CyberSourceUtil.buildCyberSourceFormData(currCartId);
        } catch (Exception ex) {
            return new Map<String, Object> {
                    SUCCESS => String.valueOf(false),
                    RETURN_MESSAGE => ERROR_MESSAGE_FORM_DATA_ERROR
            };
        }
        return response;
    }

    /**
     * @description Processes CyberSource response and places an order on successful transaction.
     *
     * @return
     */
    @AuraEnabled
    public static Map<String, Object> processCyberSourceResponse(Map<String, Object> cart, String cybersourcePaymentResponse) {
        Map<String, Object> response;
        try {
            response = cc_lx_OrderUtil.parseCyberSourceResponse(cart,cybersourcePaymentResponse);
        } catch (Exception ex) {
            return new Map<String, Object> {
                    SUCCESS => String.valueOf(false),
                    RETURN_MESSAGE => ERROR_MESSAGE_PAYMENT_DATA_ERROR
            };
        }
        return response;
    }
}