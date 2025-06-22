@isTest
private class Test_UpdateClassMyCount {
    @isTest
    static void testMyCountUpdate_UnitTest() {
        Class__c cls = new Class__c(Name='MyCounter');
        insert cls;

        insert new List<Student__c>{
            new Student__c(Name='S1', Class__c=cls.Id),
            new Student__c(Name='S2', Class__c=cls.Id)
        };

        Set<Id> classIds = new Set<Id>{cls.Id};
        TriggerHandler.updateClassMyCount(classIds);

        Class__c updated = [SELECT My_Count__c FROM Class__c WHERE Id = :cls.Id];
        System.assertEquals(2, updated.My_Count__c, 'Should reflect correct student count');
    }

    @isTest
    static void testMyCountEmptyClass_Positive() {
        Class__c cls = new Class__c(Name='TempClass_Empyu');
        insert cls;
        TriggerHandler.updateClassMyCount(new Set<Id>{cls.Id});
        Class__c updated = [SELECT My_Count__c FROM Class__c WHERE Id = :cls.Id];
        System.assertEquals(0, updated.My_Count__c);
    }
}