@isTest
private class Test_StudentLimitHandler {
    @testSetup
    static void setupData() {
        Class__c cls = new Class__c(Name='LimitClass', MaxLimit__c=1);
        insert cls;

        Student__c student = new Student__c(Name='Student 1', Class__c=cls.Id);
        insert student;
    }

    @isTest
    static void testStudentInsertOverLimit_Negative() {
        Class__c cls = [SELECT Id FROM Class__c WHERE Name='LimitClass' LIMIT 1];
        Student__c newStudent = new Student__c(Name='Student 2', Class__c=cls.Id);
        Test.startTest();
        Database.SaveResult result = Database.insert(newStudent, false);
        Test.stopTest();
        System.assert(!result.isSuccess(), 'Insert should fail as max limit is 1');
    }

    @isTest
    static void testStudentInsertWithinLimit_Positive() {
        Class__c cls = new Class__c(Name='FreeClass', MaxLimit__c=3);
        insert cls;

        Student__c s1 = new Student__c(Name='Allowed', Class__c=cls.Id);
        insert s1;
        System.assertNotEquals(null, s1.Id);
    }
}