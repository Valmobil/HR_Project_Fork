@isTest
private class TriggerUtilityTest {
    @isTest
    static void isFieldValueChangedTest_positive() {
        Account accountRecord = new Account(Name = 'Acme');
        Account changedAccountRecord = new Account(Name = 'NotAcme');
        System.assertEquals(true, TriggerUtility.isFieldValueChanged(changedAccountRecord, accountRecord, 'Name'), 'Field changed, so it should return true');
    }

    @isTest
    static void isFieldValueChangedTest_negative() {
        Account accountRecord = new Account(Name = 'Acme');
        Account changedAccountRecord = accountRecord.clone();
        System.assertEquals(
            false,
            TriggerUtility.isFieldValueChanged(changedAccountRecord, accountRecord, 'Name'),
            'Field didn\'t change so it should return false'
        );
    }

    @isTest
    static void isFieldsValueChangedOrNullTest() {
        Account accountRecord = new Account();
        Account changedAccountRecord = new Account();
        System.assertEquals(
            true,
            TriggerUtility.isFieldsValueChangedOrNull(accountRecord, changedAccountRecord, new Set<String>{ 'Name' }),
            'Field equals null, so it should return true'
        );
    }

    @IsTest
    static void testIsFieldValueChangedOrPopulated(){
        Account accountRecord = new Account(Name='Test');
        Account changedAccountRecord = new Account(Name='Test Changed');
        System.assertEquals(true, TriggerUtility.isFieldValueChangedOrPopulated(accountRecord, changedAccountRecord, 'Name'));
    }
}
