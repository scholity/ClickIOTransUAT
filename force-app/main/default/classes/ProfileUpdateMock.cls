@isTest
global class ProfileUpdateMock implements HttpCalloutMock
{
    global HTTPResponse respond(HTTPRequest request) {
        
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"Test": "ProfileUpdated"}');
        response.setStatusCode(200);
        return response; 
    }
}