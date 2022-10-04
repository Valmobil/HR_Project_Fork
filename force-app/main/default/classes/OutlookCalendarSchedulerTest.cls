@isTest
public with sharing class OutlookCalendarSchedulerTest {
    @isTest
    static void testOutlookCalendarSchedule() {
        String scheduleString = '0 0 0 1 1 ? ' + (Date.today().year() + 1);
        
        Test.startTest();
        OutlookCalendarsScheduler s = new OutlookCalendarsScheduler(scheduleString);
        System.schedule(Constants.SCHEDULED_OUTLOOK_INTEGRATION_TITLE_PREFIX + scheduleString, scheduleString, s);
        Test.stopTest();

        Integer triggerCount = [SELECT Count() FROM CronTrigger WHERE CronJobDetail.Name =: Constants.SCHEDULED_OUTLOOK_INTEGRATION_TITLE_PREFIX + scheduleString];
        System.assert(triggerCount == 1, 'scheduled event was not created');
    }
}
