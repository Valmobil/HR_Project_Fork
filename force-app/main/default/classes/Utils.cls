public with sharing class Utils {
    public static void sendMessage(String senderDisplayName, String subject, String mailTextBody, List<String> targetAddresses) {
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        msg.setSenderDisplayName(senderDisplayName);
        msg.setToAddresses(targetAddresses);
        msg.setSubject(subject);
        msg.setPlainTextBody(mailTextBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { msg });
    }

    public static void sendScheduleExceptionMessage(String senderDisplayName, String subject, String mailTextBody, String cronTriggerName) {
        //Sends an exception email to org-wide email address instead of user-defined
        //If there's no org-wide email address, cronTrigger's owner is used instead
        String targetAddress;
        List<OrgWideEmailAddress> targetAddressQuery = [SELECT Address FROM OrgWideEmailAddress WHERE DisplayName =: Constants.SCHEDULE_FAILED_MAIL_TARGET];
        if (targetAddressQuery.isEmpty()) {
            Id ownerId = [SELECT OwnerId FROM CronTrigger WHERE CronJobDetail.Name =: cronTriggerName].OwnerId;
            targetAddress = [SELECT Email FROM User WHERE Id = :ownerId].Email;
        } else {
            targetAddress = targetAddressQuery[0].Address;
        }
        sendMessage(senderDisplayName, subject, mailTextBody, new List<String>{targetAddress});
    }

    public static Map<Id,String> recordTypeMap(String obj){
        Map<Id,String> recordTypeNamesById = new Map<Id,String>();
        if(obj != null){
            for(Schema.RecordTypeInfo recInfo : Schema.getGlobalDescribe().get(obj).getDescribe().getRecordTypeInfosByName().values()){
                recordTypeNamesById.put(recInfo.getRecordTypeId(),recInfo.getName());
            }
        }
        return recordTypeNamesById;
    }
    
    public static Id getOutlookRecordTypeId(String eventTypeName) {
        return Schema.SObjectType.Event.getRecordTypeInfosByName().get(eventTypeName).getRecordTypeId();
    }

    public static String formatDateForOutlook(Date d, Integer hour) {
        return d.year() + '-' 
               + (d.month() < 10 ? '0' : '') + d.month() + '-' 
               + (d.day() < 10 ? '0' : '') + d.day() + 'T'
               + (hour < 10 ? '0' : '') + hour + ':00:00Z';
    }
}
