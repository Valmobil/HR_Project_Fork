global with sharing class InterviewSummaryRemoveScheduler implements Schedulable{
    private Id documentId;
    private String documentName;

    public InterviewSummaryRemoveScheduler(Id documentId, String documentName) {
        this.documentId = documentId;
        this.documentName = documentName;
    }
    
    private void deleteDocument() {
        try {
            delete [SELECT Id FROM ContentDocument WHERE Id =: documentId];
        } catch (Exception e) {
            String docDeletionPrefix = String.format(Constants.SCHEDULE_ERROR_DOC_DELETION_PREFIX, new List<Object>{documentName, documentId});
            Utils.sendScheduleExceptionMessage(
                Constants.DELETE_FAILED_MAIL_SENDER,
                Constants.DELETE_FAILED_MAIL_SUBJECT,
                String.format(Constants.SCHEDULE_ERROR_MSG, new List<Object>{
                    docDeletionPrefix, e.getTypeName(), e.getMessage(), e.getStackTraceString()
                }),
                Constants.SCHEDULED_DOC_DELETION_TITLE_PREFIX + documentId
            );
        }
    }

    global void execute(SchedulableContext SC) {
        this.deleteDocument();
    }
}
