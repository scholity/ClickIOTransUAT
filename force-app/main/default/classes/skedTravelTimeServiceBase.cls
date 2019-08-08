public abstract class skedTravelTimeServiceBase {
    
    protected Map<string, skedBaseModels.journeyModel> mapJourney {get;set;}
    
    public abstract void initialize(List<skedBaseModels.geometry> origins, List<skedBaseModels.geometry> destinations);

    public virtual skedBaseModels.journeyModel getJourney(Location fromLoc, Location toLoc) {
        string originkey = fromLoc.getLatitude() + ',' + fromLoc.getLongitude();
        string destinationkey = toLoc.getLatitude() + ',' + toLoc.getLongitude();
        string key = originkey + '|' + destinationkey;
        return mapJourney.get(key);
    }
    
}