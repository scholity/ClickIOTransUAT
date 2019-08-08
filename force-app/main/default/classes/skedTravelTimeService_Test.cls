@isTest
public class skedTravelTimeService_Test {
    
    static testmethod void mainTest() {
        List<skedBaseModels.geometry> origins = new List<skedBaseModels.geometry>();
        List<skedBaseModels.geometry> destinations = new List<skedBaseModels.geometry>();
        
        skedBaseModels.geometry testOrigin = new skedBaseModels.geometry();
        testOrigin.lat = 37.787866;
        testOrigin.lng = -122.441803;
        origins.add(testOrigin);
        
        skedBaseModels.geometry testDestination = new skedBaseModels.geometry();
        testDestination.lat = 37.787866;
        testDestination.lng = -122.441803;
        destinations.add(testDestination);
        
        Test.startTest();
        
        skedTravelTimeService travelTimeService = new skedTravelTimeService();
        travelTimeService.initialize(origins, destinations);
        
        Test.stopTest();
    }
    
}