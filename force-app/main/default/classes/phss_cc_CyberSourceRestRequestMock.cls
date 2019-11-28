/**
 * Created by jbarker on 2019-11-13.
 */

@IsTest
global class phss_cc_CyberSourceRestRequestMock implements HttpCalloutMock {

    public String responseStr;

    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(responseStr);
        res.setStatusCode(201);

        return res;
    }
}