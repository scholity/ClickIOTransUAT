/**
 * Created by dgajwani on 9/28/18.
 */

public with sharing class phss_cc_CyberSourceCCProcessorController {

    private static final String SUCCESS = 'success';
    private static final String RETURN_MESSAGE = 'message';
    private static final String ERROR_MESSAGE_FORM_DATA_ERROR = 'There was a problem processing the form data.';
    private static final String ERROR_MESSAGE_VERIFY_FAILED = 'There was a problem processing the credit card payment.';

    /**
     * @description Returns the data required to make a POST request to CyberSource.
     *
     * @param ctx
     *
     * @return
     */
    @AuraEnabled
    public static Map<String, Object> getCybersourceHostedFormData(String currOpportunitySfid) {
        Map<String, Object> response;
        try {
            response = phss_cc_CyberSourceUtil.buildCyberSourceFormData(currOpportunitySfid);
        } catch (Exception ex) {
            response = new Map<String, Object>{
                    SUCCESS => false,
                    RETURN_MESSAGE => ERROR_MESSAGE_FORM_DATA_ERROR
            };
        }
        return response;
    }

    /**
     * @description Verifies the response from CyberSource to ensure it was not tampered.
     *
     * @param ctx
     *
     * @return
     */
    @AuraEnabled
    public static Map<String, Object> verifyCyberSourceResponse(String currOpportunitySfid, String cyberSourceResponseString) {
        Map<String, Object> response;
        try {
            Boolean signatureMatches = phss_cc_CyberSourceUtil.verifyCyberSourceResponseSignature(currOpportunitySfid, cyberSourceResponseString);
            if (signatureMatches) {
                response = new Map<String, Object>{
                        SUCCESS => true
                };
            }
        } catch (Exception ex) {
            response = new Map<String, Object>{
                    SUCCESS => false,
                    RETURN_MESSAGE => ERROR_MESSAGE_VERIFY_FAILED
            };
            if (ex.getMessage() == phss_cc_CyberSourceUtil.FAILED_TO_VERIFY_CYBERSOURCE_RESPONSE_SIGNATURE &&
                    cyberSourceResponseString.startsWith('setImmediate$0.'))
            {
                response.put('ignoreError', true);
            }
        }
        System.debug('JASON: phss_cc_CyberSourceCCProcessorController.verifyCyberSourceResponse() SUCCESS: ' + response.get(SUCCESS));
        return response;
    }
}