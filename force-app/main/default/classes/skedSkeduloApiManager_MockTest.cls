@isTest
global class skedSkeduloApiManager_MockTest implements HttpCalloutMock {

	global string calloutMethod {get;set;}

	global string resourceId {get;set;}

	global HTTPResponse respond(HTTPRequest req) {
		HttpResponse res = new HttpResponse();
		if (calloutMethod == 'dispatch' || calloutMethod == 'cancel') {
			res.setHeader('Content-Type', 'application/json');
			string jsonResult = '{"results":{"' + resourceId + '":{"dts":"2016-04-22T06:37:59.585Z","protocol":"n/a","success":true}}}';
			res.setBody(jsonResult);
			res.setStatusCode(200);
		}
		else if (calloutMethod == 'dispatch_error' || calloutMethod == 'cancel_error') {
			res.setHeader('Content-Type', 'application/json');
			string jsonResult = '{"results":{"' + resourceId + '":{"dts":"2016-04-22T06:37:59.585Z","protocol":"n/a","success":false,"errorMessage":"The resource is not notifiable","errorCode":"NotNotifiable"}}}';
			res.setBody(jsonResult);
			res.setStatusCode(200);
		}
        else if (calloutMethod == 'dispatch_error_salesforce_side' || calloutMethod == 'cancel_error_salesforce_side') {
			res.setHeader('Content-Type', 'application/json');
			string jsonResult = '<html>error</html>';
			res.setBody(jsonResult);
			res.setStatusCode(400);
		}
		return res;
	}

}