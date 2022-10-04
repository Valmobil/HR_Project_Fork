public with sharing class OutlookIntegrationService {
    public class TokenWrapper {
        public String access_token;
    }

    public static String getToken() {
        Outlook_Calendar_Authorization__mdt outlookCalendarAuthorization = Outlook_Calendar_Authorization__mdt.getAll().get(Constants.OUTLOOK_API_METADATA_NAME);
        if (outlookCalendarAuthorization != null) {
            HttpRequest request = new HttpRequest();
            request.setEndpoint(Constants.LOGIN_MICROSOFTONLINE_URL + outlookCalendarAuthorization.Tenant_Id__c + '/oauth2/v2.0/token');
            request.setMethod('GET');
            request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            request.setBody(String.format('grant_type={0}&client_id={1}&scope={2}&client_secret={3}', new List<String> {
                outlookCalendarAuthorization.Grant_Type__c, 
                outlookCalendarAuthorization.Client_Id__c, 
                outlookCalendarAuthorization.Scope__c, 
                outlookCalendarAuthorization.Client_Secret__c
            }));
            Http http = new Http();
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                TokenWrapper tokenWrapper = (TokenWrapper) JSON.deserialize(response.getBody(), TokenWrapper.class);
                return tokenWrapper.access_token;
            } else {
                throw new AuthorizationException(response.getBody());
            }
        } else {
            throw new AuthorizationException(System.Label.Empty_Outlook_Calendar_Authorization);
        }
    }


    public static OutlookEventsWrapper getEvents(String userId) {
        String token = getToken();
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setHeader('Authorization', 'Bearer ' + token);
        request.setHeader('Accept', 'application/json');

        String startTimeString = Utils.formatDateForOutlook(Date.today(), 0);
        String endTimeString = Utils.formatDateForOutlook(Date.today().addDays(7), 23);
        request.setEndpoint(String.format(Constants.MICROSOFT_GRAPH_CALENDAR_ENDPOINT, new List<Object>{
            userId, startTimeString, endTimeString
        }));
    
        Http http = new Http();
        HttpResponse response = http.send(request);
        if (response.getStatusCode() == 200) {
            OutlookEventsWrapper eventsWrapper = new OutlookEventsWrapper(response.getBody());
            return eventsWrapper; 
        }
        else {
            throw new AuthorizationException(response.getBody());
        }
    }


    public class AuthorizationException extends Exception {}
}
