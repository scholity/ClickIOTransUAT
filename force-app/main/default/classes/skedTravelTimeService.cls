public class skedTravelTimeService extends skedTravelTimeServiceBase {
    
    public override void initialize(List<skedBaseModels.geometry> origins, List<skedBaseModels.geometry> destinations) {
        this.mapJourney = new Map<string, skedBaseModels.journeyModel>();for (skedBaseModels.geometry origin : origins) {

            for (skedBaseModels.geometry destination : destinations) {
                skedBaseModels.journeyModel journey = new skedBaseModels.journeyModel();
                journey.originGeometry = origin;
                journey.destinationGeometry = destination;
                
                Location originGeoLocation = Location.newInstance(origin.lat, origin.lng);
                Location destinationGeoLocation = Location.newInstance(destination.lat, destination.lng);
                decimal distanceInMiles = originGeoLocation.getDistance(destinationGeoLocation, 'mi');
                journey.distance = distanceInMiles * 1609.34; //metre
                integer velocity = 30; //30 miles/hour
                journey.travelTime = integer.valueOf((distanceInMiles / velocity) * 3600); //seconds
                
                string originKey = origin.lat + ',' + origin.lng;
                string destinationKey = destination.lat + ',' + destination.lng;
                this.mapJourney.put(originKey + '|' + destinationKey, journey);
            }
        }
    }
    
}