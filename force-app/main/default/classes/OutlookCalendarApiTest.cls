@isTest
public with sharing class OutlookCalendarApiTest {    
    @isTest
    static void testGetToken() {
        Test.setMock(HttpCalloutMock.class, new OutlookCalendarApiMock());
        String result = OutlookIntegrationService.getToken();

        System.assert(result == 'qwerty', 'Test token should be "qwerty", not ' + result);
    }

    @isTest
    static void testListEventsCorrectPrincipalName() {
        Test.setMock(HttpCalloutMock.class, new OutlookCalendarApiMock());
        OutlookEventsWrapper result = OutlookIntegrationService.getEvents('test@test.com');

        System.assert(!result.getMeetingsInfo().isEmpty(), 'Meetings should\'ve been present');
    }

    @isTest
    static void testListEventsNoEvents() {
        Test.setMock(HttpCalloutMock.class, new OutlookCalendarApiMock());
        OutlookEventsWrapper result = OutlookIntegrationService.getEvents('empty@test.com');
        
        System.assert(result.getMeetingsInfo().isEmpty(), 'Meetings should\'ve been absent, found ' + result.getMeetingsInfo().size());
    }

    @isTest
    static void testListEventsWrongPrincipalName() {
        Test.setMock(HttpCalloutMock.class, new OutlookCalendarApiMock());
        OutlookEventsWrapper result;
        String errorMsg = '';
        try {
            result = OutlookIntegrationService.getEvents('wrong@test.com');
        } catch (Exception e) {
            errorMsg = e.getMessage();
        }

        System.assert(errorMsg == '{"error":"such user does not exist"}', 'Wrong (or no) error message, got ' + errorMsg);
    }
}
