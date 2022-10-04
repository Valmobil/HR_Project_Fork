public with sharing class InterviewSummaryController {
    @AuraEnabled(cacheable = false)
    public static Id addInfo(Id summaryId, Id documentId) {
        try {
            Interview_Summary__c summary = [
                SELECT Summary_of_Qualification__c, Years_of_Experience__c, Level__c,
                Gaps__c, Technical_English__c, High_Potential__c, Potentially_Hire__c,
                (SELECT Grade__c, Topic__c FROM Interview_Answers__r)
                FROM Interview_Summary__c
                WHERE Id =: summaryId
            ];
            ContentVersion cv = [SELECT ContentDocumentId, VersionData, Title, FileExtension from ContentVersion WHERE ContentDocumentId =: documentId and isLatest =: true];
            Id jobId = System.enqueueJob(new InterviewSummaryQueueable(summary, cv));
            return jobId;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable = false)
    public static List<String> checkJobStatus(Id jobId) {
        //actually checks if job is done and if it is, file is changed
        AsyncApexJob job = [SELECT Status, ExtendedStatus FROM AsyncApexJob WHERE Id =: jobId];
        return new List<String>{job.Status, job.ExtendedStatus};
    }

    @AuraEnabled(cacheable = false)
    public static void deleteUploadedDoc(Id documentId){
        String name = Constants.SCHEDULED_DOC_DELETION_TITLE_PREFIX + documentId;
        List<CronTrigger> scheduledJobs = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name =: name];
        if (scheduledJobs.size() != 0) {
            System.abortJob(scheduledJobs[0].Id); //there will be only 1 job because of how it's name was made
        }
        delete [SELECT Id FROM ContentDocument WHERE Id =: documentId];
    }

    @AuraEnabled(cacheable = false)
    public static void deleteUploadedDocScheduled(Id documentId, String documentName){
        try {
            InterviewSummaryRemoveScheduler s = new InterviewSummaryRemoveScheduler(documentId, documentName);
            Datetime tomorrow = Datetime.now().addDays(1);
            String scheduleString = tomorrow.second() + ' ' + tomorrow.minute() + ' ' + tomorrow.hour() + ' ' + tomorrow.day() + ' ' + tomorrow.month() + ' ? ' + tomorrow.year();
            System.schedule(Constants.SCHEDULED_DOC_DELETION_TITLE_PREFIX + documentId, scheduleString, s);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
