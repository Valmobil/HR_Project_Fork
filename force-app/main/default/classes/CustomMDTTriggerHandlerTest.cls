@isTest
public with sharing class CustomMDTTriggerHandlerTest {
    
    @IsTest
    static void testRun() {
        try {
            (new CustomMDTTriggerHandler()).run();
        } catch (Exception e) {
            System.assert(false);
        }
    }
}
