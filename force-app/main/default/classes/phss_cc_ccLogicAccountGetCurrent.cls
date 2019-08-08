/**
 * Created by dgajwani on 9/26/18.
 */

global with sharing class phss_cc_ccLogicAccountGetCurrent extends ccrz.ccLogicAccountGetCurrent {

    global virtual override Map<String, Object> process(Map<String, Object> inpData) {

        // This is used to set the account ID for product search and cart actions done on an opportunity Detail page.
        if (phss_cc_Context.currOpportunityId != null) {
            Map<String, Object> ret = ccrz.ccApiAccount.fetch(new Map<String, Object>{
                    ccrz.ccApi.API_VERSION => inpData.get(ccrz.ccApi.API_VERSION),
                    ccrz.ccApiAccount.ID => phss_cc_Context.currAccountId,
                    ccrz.ccAPI.SIZING => ccrz.ccUtil.defv(inpData, ccrz.ccAPI.SIZING, new Map<String, Object>())
            });
            return ret;
        }
        return super.process(inpData);
    }
}