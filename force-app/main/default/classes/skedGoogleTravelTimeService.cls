public class skedGoogleTravelTimeService extends skedTravelTimeServiceBase {
    
    protected integer maxOrigins = 25;
    
    public override void initialize(List<skedBaseModels.geometry> origins, List<skedBaseModels.geometry> destinations) {
        List<distanceMatrixRequest> requests = getRequestList(origins, destinations);
        
        initialize(requests);
    }

    public void initialize(List<distanceMatrixRequest> requests) {
        //process matrix distance request
        this.mapJourney = new Map<string, skedBaseModels.journeyModel>();

		system.debug('#requests#' + requests.size());
        
        for (distanceMatrixRequest request : requests) {
            List<skedBaseModels.geometry> originList = new List<skedBaseModels.geometry>();
            originList.addAll(request.mapOrigin.values());
            
            List<skedBaseModels.geometry> destinationList = new List<skedBaseModels.geometry>();
            destinationList.addAll(request.mapDestination.values());
            
            skedGeoservicesData.distanceMatrixResult matrixResult = skedGeoservicesApi.calculateMultiDistances(originList, destinationList);
            if (matrixResult.hasError == false && matrixResult.result != NULL && matrixResult.result.matrix != NULL) {
                integer minDistance;
                for (integer i = 0; i < matrixResult.result.matrix.size(); i++) {
                    List<skedGeoservicesData.Element> row = matrixResult.result.matrix.get(i);
                    for (integer j = 0; j < row.size(); j++) {
                        skedGeoservicesData.Element element = row.get(j);
                        
                        skedBaseModels.geometry originGeometry = originList.get(i);
                        string originKey = originGeometry.lat + ',' + originGeometry.lng;
                        
                        skedBaseModels.geometry destinationGeometry = destinationList.get(j);
                        string destinationKey = destinationGeometry.lat + ',' + destinationGeometry.lng;
                        
                        skedBaseModels.journeyModel journey = new skedBaseModels.journeyModel();
                        journey.originGeometry = originGeometry;
                        journey.destinationGeometry = destinationGeometry;
                        if (element.distance != NULL) {
                            journey.distance = element.distance.distanceInMeters;
                        }
                        if (element.duration != NULL) {
                            journey.travelTime = element.duration.durationInSeconds;
                        }
                        
                        this.mapJourney.put(originKey + '|' + destinationKey, journey);
                    }
                }
            }
            else {
                system.debug('#mapOrigin#' + request.mapOrigin.size());
                system.debug('#mapDestination#' + request.mapDestination.size());
                system.debug('#matrixResult#' + matrixResult);
                string errorMessage = matrixResult.errorMessage;
                if (string.isBlank(errorMessage)) {
                    errorMessage = 'We are experiencing a high usage volume at present. Please try again in a few seconds.';
                }
                throw new skedException('Google Distance Matrix API Error: ' + errorMessage);
            }
        } 
    }
    
    public List<distanceMatrixRequest> getRequestList(List<skedBaseModels.geometry> origins, List<skedBaseModels.geometry> destinations) {
        List<distanceMatrixRequest> result = new List<distanceMatrixRequest>();
        
        integer noOfOriginSets = integer.valueOf(Math.ceil(decimal.valueOf(origins.size()) / maxOrigins));
        integer noOfDestinationSets = integer.valueOf(Math.ceil(decimal.valueOf(destinations.size()) / maxOrigins));
        
        for (integer i = 0; i < noOfOriginSets; i++) {
            integer originFirstIdx = maxOrigins * i;
            integer originLastIdx = originFirstIdx + (maxOrigins - 1);
            originLastIdx = originLastIdx > (origins.size() - 1) ? origins.size() - 1 : originLastIdx;

            Map<string, skedBaseModels.geometry> mapOrigin = new Map<string, skedBaseModels.geometry>();
            for (integer j = originFirstIdx; j <= originLastIdx; j++) {
                skedBaseModels.geometry originGeometry = origins.get(j);
                mapOrigin.put(originGeometry.lat + ',' + originGeometry.lng, originGeometry);
            }
            
            for (integer m = 0; m < noOfDestinationSets; m++) {
                integer destinationFirstIdx = maxOrigins * m;
                integer destinationLastIdx = destinationFirstIdx + (maxOrigins - 1);
                destinationLastIdx = destinationLastIdx > (destinations.size() - 1) ? destinations.size() - 1 : destinationLastIdx;
                
                Map<string, skedBaseModels.geometry> mapDestination = new Map<string, skedBaseModels.geometry>();
                for (integer n = destinationFirstIdx; n <= destinationLastIdx; n++) {
                    skedBaseModels.geometry destinationGeometry = destinations.get(n);
                    mapDestination.put(destinationGeometry.lat + ',' + destinationGeometry.lng, destinationGeometry);
                }
                
                distanceMatrixRequest request = new distanceMatrixRequest();
                request.mapOrigin = mapOrigin;
                request.mapDestination = mapDestination;
                result.add(request);
            }
        }
        
        return result;
    }

    public class distanceMatrixRequest {
        public Map<string, skedBaseModels.geometry> mapOrigin {get;set;}
        public Map<string, skedBaseModels.geometry> mapDestination {get;set;}
    }
    
}