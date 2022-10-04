public with sharing class OutlookCalendarsScheduler implements Schedulable{
    private String scheduleString; //used for finding job by title

    public OutlookCalendarsScheduler(String scheduleString) {
        this.scheduleString = scheduleString;
    }

    public void execute(SchedulableContext sc) {
        OutlookCalendarManager.insertOutlookEvents(scheduleString);
    }
}