public class skedGeoservicesApi {
    
    public static skedGeoservicesData.distanceMatrixResult calculateMultiDistances(List<skedBaseModels.geometry> originList, List<skedBaseModels.geometry> destinationList) {
        skedGeoservicesData.distanceMatrixResult result = new skedGeoservicesData.distanceMatrixResult();
        
        distanceMatrixRequestBody body = new distanceMatrixRequestBody(originList, destinationList);
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Skedulo_API/geoservices/distanceMatrix');
        req.setMethod('POST');
        req.setBody(Json.serialize(body));
        
        try {
            HttpResponse res = h.send(req);
            string jsonResult = res.getBody();
            system.debug('#jsonResult#' + jsonResult);
            result = (skedGeoservicesData.distanceMatrixResult)(Json.deserialize(jsonResult, skedGeoservicesData.distanceMatrixResult.class));
            result.HasError = false;
            
        } catch (Exception e) {
            result.HasError = true;
            result.ErrorMessage = e.getMessage() + '\n' + e.getStackTraceString();
        }

        return result;
    }

    /************************************************ nested classes ****************************************************/
    public class distanceMatrixRequestBody {
        public List<skedBaseModels.geometry> origins {get;set;}
        public List<skedBaseModels.geometry> destinations {get;set;}
        
        public distanceMatrixRequestBody(List<skedBaseModels.geometry> originList, List<skedBaseModels.geometry> destinationList) {
            this.origins = originList;
            this.destinations = destinationList;
        }
    }
    
}