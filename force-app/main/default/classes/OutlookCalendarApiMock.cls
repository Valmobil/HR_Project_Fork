@isTest
public with sharing class OutlookCalendarApiMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
        HttpResponse response = new HttpResponse();
        if (req.getEndpoint().startsWith('https://graph.microsoft.com/v1.0/users/test@test.com')) {
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(200);
            response.setBody('{"value": ['
                + '{"start": { "dateTime": "' + DateTime.now().addDays(1).format('yyyy-MM-dd\'T\'05') + ':00:00.0000000", "timeZone": "UTC" },'
                + '"end": { "dateTime": "' + DateTime.now().addDays(1).format('yyyy-MM-dd\'T\'05') + ':30:00.0000000", "timeZone": "UTC" },'
                + '"subject": "Salesforce Interview Slot"},'
                + '{"start": { "dateTime": "' + DateTime.now().addDays(1).format('yyyy-MM-dd\'T\'06') + ':00:00.0000000", "timeZone": "UTC" },'
                + '"end": { "dateTime": "' + DateTime.now().addDays(1).format('yyyy-MM-dd\'T\'06') + ':30:00.0000000", "timeZone": "UTC" },'
                + '"subject": "Some different meeting we do not care about"}]}'
            );
        } else if (req.getEndpoint().startsWith('https://graph.microsoft.com/v1.0/users/wrong@test.com')) {
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(400);
            response.setBody('{"error":"such user does not exist"}');
        } else if (req.getEndpoint().startsWith('https://graph.microsoft.com/v1.0/users/')) {
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(200);
            response.setBody('{"value":[]}');
        } else if (req.getEndpoint().startsWith(Constants.LOGIN_MICROSOFTONLINE_URL)) {
            if (req.getBody().contains('grant_type=client_credentials') && req.getBody().contains('scope=https://graph.microsoft.com/.default')) {
                response.setHeader('Content-Type', 'application/json');
                response.setStatusCode(200);
                response.setBody('{"token_type":"Bearer","expires_in":3599,"ext_expires_in":3599,"access_token":"qwerty"}');
            } else {
                response.setHeader('Content-Type', 'application/json');
                response.setStatusCode(400);
                response.setBody('{"error":"Bad request"}');
            }
        }
        return response;
    }
}
