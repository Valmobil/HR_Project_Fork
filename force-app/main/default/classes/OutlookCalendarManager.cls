public with sharing class OutlookCalendarManager {
    @future(callout = true)
    public static void insertOutlookEvents(String scheduleString) {
        try {
            Map<Id, User> salesforceInterviewers = getSalesforceInterviewers();
            Map<Id, OutlookEventsWrapper> outlookCalendarEvents = fetchOutlookCalendarEvents(salesforceInterviewers);
            List<List<Event>> eventsToInsertAndDelete = generateEventListsForInsertAndDelete(salesforceInterviewers, outlookCalendarEvents);
            insert eventsToInsertAndDelete[0];
            markEventsForDeletion(eventsToInsertAndDelete[1]);
            delete eventsToInsertAndDelete[1];
        } catch (Exception e) {
            String outlookIntegrationPrefix = String.format(Constants.SCHEDULE_ERROR_OUTLOOK_INTEGRATION_PREFIX, new List<Object>{Datetime.now()});
            Utils.sendScheduleExceptionMessage(
                Constants.OUTLOOK_FAILED_MAIL_SENDER,
                Constants.OUTLOOK_FAILED_MAIL_SUBJECT,
                String.format(Constants.SCHEDULE_ERROR_MSG, new List<Object>{
                    outlookIntegrationPrefix, e.getTypeName(), e.getMessage(), e.getStackTraceString()
                }),
                Constants.SCHEDULED_OUTLOOK_INTEGRATION_TITLE_PREFIX + scheduleString
            );
        }
    }

    private static void markEventsForDeletion(List<Event> events) {
        //before delete event trigger do not allow to delete events of some record type
        //so we should mark them before deletion to avoid trigger check
        for (Event evnt : events) {
            evnt.Description = Constants.OUTLOOL_EVENT_MARK_FOR_DELETION + evnt.Description;
        }
        update events;
    }

    private static Map<Id, User> getSalesforceInterviewers() {
        return new Map<Id, User>([SELECT Id, Azure_Principal_Name__c, Name FROM User
            WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE Group.Name =: Constants.SALESFORCE_INTERVIEWERS_GROUP_NAME)
            AND isActive = True]);
    }

    private static  Map<Id, OutlookEventsWrapper> fetchOutlookCalendarEvents(Map<Id, User> users) {
        Map<Id, OutlookEventsWrapper> outlookCalendarEvents = new Map<Id, OutlookEventsWrapper>();
        for (Id userId : users.keySet()) {
            outlookCalendarEvents.put(userId, OutlookIntegrationService.getEvents(users.get(userId).Azure_Principal_Name__c));
        }
        return outlookCalendarEvents;
    }

    private static List<Event> getExistingEventsForUsers(Map<Id, User> users) {
        Set<String> userNames = new Set<String>();
        for (User u : users.values()) {
            userNames.add(u.Name);
        }
        return [SELECT StartDateTime, EndDateTime, Subject, Description FROM Event
        WHERE StartDateTime >= :Date.today() AND Subject IN :userNames AND RecordType.Name = :Constants.RECORD_TYPE_OUTLOOK_EVENT];
    }

    private static List<List<Event>> generateEventListsForInsertAndDelete(Map<id, User> salesforceInterviewers, Map<Id, OutlookEventsWrapper> outlookEventsWrappersByUserId) {
        //Searching for existing events that meet our criteria
        List<Event> existingEvents = getExistingEventsForUsers(salesforceInterviewers);
        List<Event> eventsToDelete = new List<Event>(existingEvents);

        //Create new events (if not in the system already)
        List<Event> eventsToInsert = new List<Event>();
        for (Id userId : outlookEventsWrappersByUserId.keySet()) {
            for (OutlookEventsWrapper.MeetingInfo outlookEventItem : outlookEventsWrappersByUserId.get(userId).getMeetingsInfo()) {
                if (outlookEventItem.getSubject() == Constants.INTERVIEW_SLOT_TITLE) {
                    Event newEvent = new Event(
                        OwnerId = userId,
                        StartDateTime = outlookEventItem.getStartDateTime(),
                        EndDateTime = outlookEventItem.getEndDateTime(),
                        Subject = salesforceInterviewers.get(userId).Name,
                        RecordTypeId = Utils.getOutlookRecordTypeId(Constants.RECORD_TYPE_OUTLOOK_EVENT)
                    );
                    //Checking if event already exists in Salesforce
                    Boolean toAddEvent = true;
                    for (Event e : existingEvents) {
                        if (e.StartDateTime == newEvent.startDateTime && e.EndDateTime == newEvent.endDateTime && e.Subject == newEvent.Subject) {
                            toAddEvent = false;
                            eventsToDelete.remove(eventsToDelete.indexOf(e));
                            break;
                        }
                    }
                    if (toAddEvent) {
                        eventsToInsert.add(newEvent);
                    }
                }
            }
        }
        return new List<List<Event>>{eventsToInsert, eventsToDelete};
    }
}