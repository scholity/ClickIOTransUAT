public class skedGoogleServiceApi {
    
    public static skedGoogleData.geocodeResult getGeocode(string address) {
        skedGoogleData.geocodeResult result = new skedGoogleData.geocodeResult();
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        string requestString = 'https://maps.googleapis.com/maps/api/geocode/json?address=' + EncodingUtil.URLENCODE(address, 'UTF-8');
        
        sked_Google_Api_Settings__c googleApiSetting = sked_Google_Api_Settings__c.getOrgDefaults();
        if (!string.isBlank(googleApiSetting.Server_Key__c)) {
            requestString += '&key=' + googleApiSetting.Server_Key__c;
        }
        
        req.setEndpoint(requestString);
        req.setMethod('GET');
        req.setTimeout(60000);
        try {
            HttpResponse res = h.send(req);
            string jsonResult = res.getBody();
            result = (skedGoogleData.geocodeResult)(Json.deserialize(jsonResult, skedGoogleData.geocodeResult.class));
            
            if (result.status != 'OK') {
                result.HasError = true;
                result.ErrorMessage = result.status;
            } else {
                result.HasError = false;
            }
        } catch (Exception e) {
            result.HasError = true;
            result.ErrorMessage = e.getMessage() + '\n' + e.getStackTraceString();
        }

        return result;
    }
    
}