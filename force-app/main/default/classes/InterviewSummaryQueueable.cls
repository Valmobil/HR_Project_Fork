public with sharing class InterviewSummaryQueueable implements Queueable{
    private Interview_Summary__c summary;
    private ContentVersion cv;

    public InterviewSummaryQueueable(Interview_Summary__c summary, ContentVersion cv) {
        this.summary = summary;
        this.cv = cv;
    }

    //XLSX document is edited here
    public void execute(QueueableContext context) {
        new InterviewSummaryManager(summary, cv).fillInterviewSummaryTable();
    }
}