/**
 * Created by dgajwani on 9/24/18.
 */

public with sharing class phss_cc_Exception extends Exception{

    public static String ERROR_KEY = 'Error';

    /**
     * @description Returns a Map<String,Object> to convey the error message to the lightning cmp.
     *
     * @param errorMessage
     *
     * @return
     */
    public static Map<String, Object> getErrorMessageMap(String errorMessage)
    {
        return new Map<String, Object> {ERROR_KEY => errorMessage};
    }
}