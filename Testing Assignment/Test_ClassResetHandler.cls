@isTest
private class Test_ClassResetHandler {
    @isTest
    static void testResetStatusDeletesStudents_Positive() {
        Class__c cls = new Class__c(Name='ResetClass', Custom_Status__c='New');
        insert cls;

        insert new Student__c(Name='ResetMe', Class__c=cls.Id);

        cls.Custom_Status__c = 'Reset';
        Map<Id, Class__c> oldMap = new Map<Id, Class__c>{
            cls.Id => new Class__c(Id=cls.Id, Custom_Status__c='New')
        };

        Test.startTest();
        TriggerHandler.handleClassStatusReset(new List<Class__c>{cls}, oldMap);
        Test.stopTest();

        System.assertEquals(0, [SELECT COUNT() FROM Student__c WHERE Class__c = :cls.Id]);
    }

    @isTest
    static void testNoResetStatusChange_Negative() {
        Class__c cls = new Class__c(Name='NoReset', Custom_Status__c='New');
        insert cls;

        insert new Student__c(Name='NoDelete', Class__c=cls.Id);

        Map<Id, Class__c> oldMap = new Map<Id, Class__c>{ cls.Id => cls };

        Test.startTest();
        TriggerHandler.handleClassStatusReset(new List<Class__c>{cls}, oldMap);
        Test.stopTest();

        System.assertEquals(1, [SELECT COUNT() FROM Student__c WHERE Class__c = :cls.Id]);
    }
}