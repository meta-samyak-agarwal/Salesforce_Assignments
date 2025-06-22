@isTest
private class Test_ClassDeleteHandler {
    @testSetup
    static void setupData() {
        Class__c cls = new Class__c(Name='Class A');
        insert cls;

        List<Student__c> students = new List<Student__c>{
            new Student__c(Name='Girl1', Class__c=cls.Id, Gender__c='Female'),
            new Student__c(Name='Girl2', Class__c=cls.Id, Gender__c='Female')
        };
        insert students;
    }

    @isTest
    static void testHandleClassDelete_Negative() {
        Class__c cls = [SELECT Id FROM Class__c WHERE Name = 'Class A' LIMIT 1];

        Test.startTest();
        try {
            delete cls;
            System.assert(false, 'Delete should have failed due to female student constraint');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Cannot delete class with more than one female'), 'Expected delete error');
        }
        Test.stopTest();
    }

    @isTest
    static void testAllowClassDeletion_Positive() {
        Class__c newCls = new Class__c(Name='Class B');
        insert newCls;

        Test.startTest();
        delete newCls;
        Test.stopTest();

        // Assert the class is deleted by checking the absence
        List<Class__c> results = [SELECT Id FROM Class__c WHERE Id = :newCls.Id];
        System.assertEquals(0, results.size(), 'Class B should be deleted successfully');
    }
}
