@isTest
private class Test_TeacherTriggerHandler {
    @isTest
    static void testPreventHindiTeacherInsert_Negative() {
        Teacher__c hindiTeacher = new Teacher__c(Name='TeacherA', Subjects__c='Hindi');
        Test.startTest();
        Database.SaveResult result = Database.insert(hindiTeacher, false);
        Test.stopTest();
        System.assert(!result.isSuccess(), 'Insert should fail for Hindi teacher');
    }

    @isTest 
    static void testPreventHindiTeacherInsert_Positive() {
        Teacher__c engTeacher = new Teacher__c(Name='TeacherB', Subjects__c='English');
        insert engTeacher;
        System.assertNotEquals(null, engTeacher.Id);
    }
}