/**
 * Created by dgajwani on 9/14/18.
 */


global class cc_lx_CyberSourceCCProcessorPostback {
    public String result { get; set; }
    public String returnURL { get; set; }
    public Map<String, Object> parameters { get; set; }

    global cc_lx_CyberSourceCCProcessorPostback() {
        this.result = '{}';
        this.parameters = new Map<String, Object>();

        Map<String, String> params = ApexPages.currentPage().getParameters();

        if (!params.isEmpty()) {
            for (String key : params.keySet()) {
                this.parameters.put(key, params.get(key));
            }
            this.result = JSON.serialize(parameters);
        }
        this.returnURL = phss_cc_CyberSourceUtil.getLightningURLToPOSTCyberSourceResponse();
    }
}