@isTest
public with sharing class InterviewSummaryTests {
    @TestSetup
    static void makeData(){
        Contact c = TestUtils.populateContact(false);
        Interview_Summary__c summary = TestUtils.populateInterviewSummary(c);
        TestUtils.populateInterviewTopics();
        TestUtils.populateInterviewAnswer(summary);
    }

    @isTest
    static void testAddInfo() {
        ContentVersion cv = TestUtils.createTestExcel();
        ContentDocument cd = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId =: cv.Id];
        Interview_Summary__c summary = [
            SELECT Summary_of_Qualification__c, Years_of_Experience__c, Level__c,
            Gaps__c, Technical_English__c, High_Potential__c, Potentially_Hire__c,
            (SELECT Grade__c, Topic__c FROM Interview_Answers__r)
            FROM Interview_Summary__c
        ];

        Test.startTest();
        InterviewSummaryController.addInfo(summary.Id, cd.Id);
        Test.stopTest();

        Integer expectedResult = 2;
        Integer actualResult = [SELECT Count() FROM ContentVersion WHERE ContentDocumentId =: cd.Id];
        System.assert(expectedResult == actualResult);
    }

    @isTest
    static void testCheckJobStatusCompleted() {
        ContentVersion cv = TestUtils.createTestExcel();
        ContentDocument cd = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId =: cv.Id];
        Interview_Summary__c summary = [
            SELECT Summary_of_Qualification__c, Years_of_Experience__c, Level__c,
            Gaps__c, Technical_English__c, High_Potential__c, Potentially_Hire__c,
            (SELECT Grade__c, Topic__c FROM Interview_Answers__r)
            FROM Interview_Summary__c
        ];
        
        Test.startTest();
        Id jobId = InterviewSummaryController.addInfo(summary.Id, cd.Id);
        Test.stopTest();

        String jobStatus = InterviewSummaryController.checkJobStatus(jobId)[0];
        System.assert(jobStatus == 'Completed', 'expected Completed, got ' + jobStatus);
    }

    @isTest
    static void testDeleteUploadedDocScheduled() {
        ContentDocument doc = TestUtils.createTestDoc();

        Test.startTest();
        InterviewSummaryController.deleteUploadedDocScheduled(doc.Id, doc.Title);
        Test.stopTest();

        Integer documentsCount = [SELECT Count() FROM ContentDocument];
        System.assert(documentsCount == 0);
    }

    @isTest
    static void testDeleteUploadedDoc() {
        ContentDocument doc = TestUtils.createTestDoc();

        Test.startTest();
        InterviewSummaryController.deleteUploadedDoc(doc.Id);
        Test.stopTest();

        Integer documentsCount = [SELECT Count() FROM ContentDocument];
        System.assert(documentsCount == 0);
    }
}
