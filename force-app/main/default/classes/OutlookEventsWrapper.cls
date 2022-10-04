public with sharing class OutlookEventsWrapper {
    private List<MeetingInfo> meetingsInfo;

    public class MeetingInfo {
        private Map<String, Object> startDateTime;
        private Map<String, Object> endDateTime;
        private String subject;

        public MeetingInfo() {}

        public Datetime getStartDateTime() {
            return parseOutlookDatetime((String) startDateTime.get('dateTime'));
        }

        public Datetime getEndDateTime() {
            return parseOutlookDatetime((String) endDateTime.get('dateTime'));
        }

        public String getSubject() {
            return subject;
        }

        private Datetime parseOutlookDatetime(String datetimeString) {
            List<String> dateAndTime = datetimeString.split('\\.')[0].split('\\D+');
            return Datetime.newInstanceGMT(
                Integer.valueOf(dateAndTime[0]),
                Integer.valueOf(dateAndTime[1]),
                Integer.valueOf(dateAndTime[2]),
                Integer.valueOf(dateAndTime[3]),
                Integer.valueOf(dateAndTime[4]),
                Integer.valueOf(dateAndTime[5])
            );
        }
    }

    public OutlookEventsWrapper(String jsonBody) {
        meetingsInfo = new List<MeetingInfo>();
        Map<String, Object> initialJson = (Map<String, Object>) JSON.deserializeUntyped(jsonBody);
        List<Object> jsonValues = (List<Object>) initialJson.get('value');
        for (Object value : jsonValues) {
            Map<String, Object> valueMap = (Map<String, Object>) value;
            MeetingInfo info = new MeetingInfo();
            info.startDateTime = (Map<String, Object>) valueMap.get('start');
            info.endDateTime = (Map<String, Object>) valueMap.get('end');
            info.subject = (String) valueMap.get('subject');
            meetingsInfo.add(info);
        }
    }

    public List<MeetingInfo> getMeetingsInfo() {
        return meetingsInfo;
    }
}
