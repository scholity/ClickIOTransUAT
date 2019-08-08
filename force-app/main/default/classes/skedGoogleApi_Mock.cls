@isTest
global class skedGoogleApi_Mock implements HttpCalloutMock {

    public string calloutMethod {get;set;}
    
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        string finalResult;
        
        if (this.calloutMethod == 'getGeocode') {
            finalResult = '{"status":"OK","results":[{"geometry":{"location":{"lng":-121.9466052,"lat":37.4050308}},"formatted_address":"77 Rio Robles, San Jose, CA 95134, USA","address_components":[{"types":["street_number"],"short_name":"77","long_name":"77"},{"types":["route"],"short_name":"Rio Robles","long_name":"Rio Robles"},{"types":["neighborhood","political"],"short_name":"North San Jose","long_name":"North San Jose"},{"types":["locality","political"],"short_name":"San Jose","long_name":"San Jose"},{"types":["administrative_area_level_2","political"],"short_name":"Santa Clara County","long_name":"Santa Clara County"},{"types":["administrative_area_level_1","political"],"short_name":"CA","long_name":"California"},{"types":["country","political"],"short_name":"US","long_name":"United States"},{"types":["postal_code"],"short_name":"95134","long_name":"95134"},{"types":["postal_code_suffix"],"short_name":"1859","long_name":"1859"}]}]}';
        }
        else if (this.calloutMethod == 'calculateMultiDistances') {
            finalResult = '{ "destination_addresses" : [ "2900 Bush St, San Francisco, CA 94115, Hoa Kỳ" ], "origin_addresses" : [ "2876-2880 California St, San Francisco, CA 94115, Hoa Kỳ", "355 Presidio Ave, San Francisco, CA 94115, Hoa Kỳ", "514-520 Presidio Ave, San Francisco, CA 94115, Hoa Kỳ" ], "rows" : [ { "elements" : [ { "distance" : { "text" : "0,5 dặm", "value" : 766 }, "duration" : { "text" : "2 phút", "value" : 146 }, "status" : "OK" } ] }, { "elements" : [ { "distance" : { "text" : "0,3 dặm", "value" : 446 }, "duration" : { "text" : "2 phút", "value" : 123 }, "status" : "OK" } ] }, { "elements" : [ { "distance" : { "text" : "0,2 dặm", "value" : 276 }, "duration" : { "text" : "1 phút", "value" : 72 }, "status" : "OK" } ] } ], "status" : "OK" }';
        }
        res.setBody(finalResult);
        res.setStatusCode(200);
        
        return res;
    }
    
}