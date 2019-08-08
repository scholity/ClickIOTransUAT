@isTest
global class skedGeoservicesApi_Mock implements HttpCalloutMock {

    public string calloutMethod {get;set;}
    
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        string finalResult;
        
        if (this.calloutMethod == 'calculateMultiDistances') {
            finalResult = '{"result":{"matrix":[[{"duration":{"durationInSeconds":1359},"distance":{"distanceInMeters":10045},"status":"OK"}],[{"duration":{"durationInSeconds":1373},"distance":{"distanceInMeters":8252},"status":"OK"}],[{"duration":{"durationInSeconds":1616},"distance":{"distanceInMeters":12746},"status":"OK"}]]}}';
        }
        res.setBody(finalResult);
        res.setStatusCode(200);
        
        return res;
    }
    
}