@isTest
public with sharing class OutlookCalendarManagerTest {
    @isTest
    static void testOutlookCalendarManager() {
        Test.setMock(HttpCalloutMock.class, new OutlookCalendarApiMock());
        Id salesforceInterviewersGroupId = [SELECT Id FROM Group WHERE Name = :Constants.SALESFORCE_INTERVIEWERS_GROUP_NAME].Id;
        Id profileId = [SELECT Id FROM Profile WHERE Name = :Constants.PROFILE_NAME_SYSTEM_ADMINISTRATOR].Id;
        User u = TestUtils.createTestUser(profileId, true);
        GroupMember gm = new GroupMember(UserOrGroupId = u.Id, GroupId = salesforceInterviewersGroupId);
        System.runAs(u) {
            insert gm;
            insert TestUtils.createEvent(u.Id, u.LastName, Constants.RECORD_TYPE_OUTLOOK_EVENT, null);
        }

        Test.startTest();
        OutlookCalendarManager.insertOutlookEvents('test');
        Test.stopTest();

        Integer amount = [SELECT COUNT() FROM Event];
        System.assert(amount == 1, 'Wrong amount of events created, expected 1, got ' + amount);
    }
}
