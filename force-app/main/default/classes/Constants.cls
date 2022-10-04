public with sharing class Constants {
    public static final List<String> SUMMARY_FIELDS_API = new List<String>{
        Interview_Summary__c.Summary_of_Qualification__c.getDescribe().getName(),
        Interview_Summary__c.Years_of_Experience__c.getDescribe().getName(),
        Interview_Summary__c.Level__c.getDescribe().getName(),
        Interview_Summary__c.Gaps__c.getDescribe().getName(),
        Interview_Summary__c.Technical_English__c.getDescribe().getName(),
        Interview_Summary__c.High_Potential__c.getDescribe().getName(),
        Interview_Summary__c.Potentially_Hire__c.getDescribe().getName()
    };
    public static List<String> SCORE_NAMES = new List<String>{
        'Trainee', 'Junior Low', 'Junior', 'Junior Strong',
        'Intermediate Low', 'Intermediate', 'Intermediate Strong',
        'Senior Low', 'Senior', 'Senior Strong', 'Leader Low', 'Leader'
    };
    public static final List<String> GRADE_NAMES_TABLE = new List<String>{'None', 'Beginner', 'Good', 'Strong', 'Not Evaluated'};
    public static final List<String> GRADE_NAMES_ORG = new List<String>{'None – 0', 'Beginner - 1', 'Good - 2', 'Strong - 3', 'Not evaluated'};
    public static final List<String> SUMMARY_CELLS = new List<String>{
        'B9', 'B10', 'B11', 'B12', 'B13', 'B14', 'B15'
    };
    public static List<String> PERCENTAGE_CELLS = new List<String>{'B2', 'F2','G2','H2','I2'};
    public static final List<String> READ_DATA_COLUMNS = new List<String>{'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y'};
    public static final List<String> WRITE_DATA_COLUMNS = new List<String> {
        'F', 'G', 'H', 'I', 'AA', 'AB', 'AC', 'AD',
        'AE', 'AF', 'AG', 'AH'
    };
    public static final List<Integer> TEST_DATA_ROWS = new List<Integer>{
        5, 6, 8, 10
    };
    public static final List<String> CREATE_TEST_DATA_COLUMNS = new List<String>{
        'F', 'G', 'H', 'I', 'R', 'S', 'T',
        'U', 'V', 'W', 'X', 'Y', 'Z', 'AA', 'AB', 'AC', 'AD', 'AE', 'AF',
        'AG', 'AH', 'AI', 'AJ', 'AK', 'AL', 'AM', 'AN', 'AO', 'AP', 'AQ'
    };
    public static final List<String> MAX_SCORE_COLUMNS = new List<String>{'AN', 'AO', 'AP', 'AQ'};
    public static final String GRADE_TEXT_COLUMN = 'D';
    public static final Integer AMOUNT_OF_GRADES = 4;
    public static final String XML_WORKBOOK_PATH = 'xl/workbook.xml';
    public static final String XML_WORKSHEET_PATH_PREFIX = 'xl/worksheets/sheet';
    public static final String XML_SHAREDSTRINGS_PATH = 'xl/sharedStrings.xml';
    public static final String SUMMARY_TAB_TITLE = 'Summary';
    public static final String ACTIVITIES_TAB_TITLE = 'Activities';
    public static final String TAB_NOT_FOUND_MSG = 'Summary and/or Activities tab(s) not found';
    public static final String TOPIC_NOT_FOUND_MSG = 'Topic "{0}" not found in the uploaded table.';
    public static final String TEST_TOPIC_TITLE = 'Help me, I can\'t figure out this {0} anymore';
    public static final String PROFILE_NAME_SYSTEM_ADMINISTRATOR = 'System Administrator';

    public static final Integer NUMBER_OF_TEST_ROWS = 10;
    public static final String SCHEDULE_FAILED_MAIL_TARGET = 'Schedule Failed Target';
    public static final String DELETE_FAILED_MAIL_SENDER = 'Document Deletion Failed';
    public static final String DELETE_FAILED_MAIL_SUBJECT = 'Scheduled document deletion failed';
    public static final String OUTLOOK_FAILED_MAIL_SENDER = 'Scheduled Outlook Integration failed';
    public static final String OUTLOOK_FAILED_MAIL_SUBJECT = 'Scheduled Outlook Integration failed';

    public static final String SCHEDULE_ERROR_MSG = '{0}. The following error occured:\n{1}: {2}\n\n{3}';
    public static final String SCHEDULE_ERROR_DOC_DELETION_PREFIX = 'Document "{0}" with Id {1} wasn\'t deleted by scheduler';
    public static final String SCHEDULE_ERROR_OUTLOOK_INTEGRATION_PREFIX = 'Outlook integration, which happenned at {0} as part of the schedule, failed';
    public static final String SCHEDULED_DOC_DELETION_TITLE_PREFIX = 'Removing document ';
    public static final String SCHEDULED_OUTLOOK_INTEGRATION_TITLE_PREFIX = 'Scheduled Outlook Integration ';
    public static final String OBJECT_TYPE_EVENT = 'Event';

    public static final String RECORD_TYPE_OUTLOOK_EVENT = 'Outlook Event'; 
    public static final String RECORD_TYPE_OTHER = 'Other'; 
    public static final String OUTLOOL_EVENT_MARK_FOR_DELETION = 'to Delete'; 
    public static final String OUTLOOK_EVENT_MODIFICATION_ERROR = 'You cannot edit or delete events exported from Outlook.';

    public static final String SALESFORCE_INTERVIEWERS_GROUP_NAME = 'Salesforce Interviewers';
    public static final String INTERVIEW_SLOT_TITLE = 'Salesforce Interview Slot';
    public static final String OUTLOOK_API_METADATA_NAME = 'Default';
    public static final String MICROSOFT_GRAPH_CALENDAR_ENDPOINT = 'https://graph.microsoft.com/v1.0/users/{0}/calendarview?startdatetime={1}&enddatetime={2}';
    public static final String LOGIN_MICROSOFTONLINE_URL = 'https://login.microsoftonline.com/';
}
