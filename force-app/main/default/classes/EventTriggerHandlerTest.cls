@isTest
public with sharing class EventTriggerHandlerTest {
    @testSetup
    static void testSetup() {
        User testUser = TestUtils.createTestUser([SELECT Id FROM Profile WHERE Name = :Constants.PROFILE_NAME_SYSTEM_ADMINISTRATOR].Id, true);
        List<Event> eventList = new List<Event>();
        eventList.add(TestUtils.createEvent(testUser.id, 'Subject 0', null, null));
        eventList.add(TestUtils.createEvent(testUser.id, 'Subject 1', Constants.RECORD_TYPE_OUTLOOK_EVENT, null));
        eventList.add(TestUtils.createEvent(testUser.id, 'Subject 2', Constants.RECORD_TYPE_OTHER, null));
        eventList.add(TestUtils.createEvent(testUser.id, 'Subject 3', Constants.RECORD_TYPE_OUTLOOK_EVENT, Constants.OUTLOOL_EVENT_MARK_FOR_DELETION));
        insert eventList;
    }

    @isTest static void testProtectOutlookEventsFromDeletion() {
        List<Event> eventsTestSource = [SELECT Subject FROM Event ORDER BY Subject];

        Test.startTest();
        Database.DeleteResult[] deleteResults = Database.delete(eventsTestSource, false);
        Test.stopTest();

        System.assert(deleteResults.get(0).isSuccess() || deleteResults.get(2).isSuccess(), 'Event with category diferent from "' + Constants.RECORD_TYPE_OUTLOOK_EVENT + '" can be deleted or updated');
        System.assert(!deleteResults.get(1).isSuccess(), 'Event with category "' + Constants.RECORD_TYPE_OUTLOOK_EVENT + '" can not be deleted or updated');
        System.assert(deleteResults.get(3).isSuccess(), 'Event with "to Delete" in Description and any category can be updated or deleted');
    }

    @isTest static void testProtectOutlookEventsFromUpdating() {
        List<Event> eventsTestSource = [SELECT Subject FROM Event ORDER BY Subject];

        Test.startTest();
        Database.SaveResult[] deleteResults = Database.update(eventsTestSource, false);
        Test.stopTest();

        System.assert(deleteResults.get(0).isSuccess() || deleteResults.get(2).isSuccess(), 'Event with category diferent from "' + Constants.RECORD_TYPE_OUTLOOK_EVENT + '" can be deleted or updated');
        System.assert(!deleteResults.get(1).isSuccess(), 'Event with category "' + Constants.RECORD_TYPE_OUTLOOK_EVENT + '" can not be deleted or updated');
        System.assert(deleteResults.get(3).isSuccess(), 'Event with "to Delete" in Description and any category can be updated or deleted');
    }
}
