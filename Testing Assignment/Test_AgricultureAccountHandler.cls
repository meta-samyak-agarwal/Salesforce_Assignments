@isTest
private class Test_AgricultureAccountHandler {
    @isTest
    static void testCreateOpportunityForAgriculture_Positive() {
        Account acc = new Account(Name='Agri', Industry='Agriculture');
        insert acc;

        Map<Id, Account> oldMap = new Map<Id, Account>();
        Test.startTest();
        TriggerHandler.handleAgricultureAccounts(new List<Account>{acc}, oldMap);
        Test.stopTest();

        List<Opportunity> opps = [SELECT Id FROM Opportunity WHERE AccountId = :acc.Id];
        System.assert(opps.size() > 0);
    }

    // this is for the updating of the field Industry to the Agriculture
    @isTest
    static void testNoOpportunityForOtherIndustry_Negative() {
        Account acc = new Account(Name='Tech', Industry='Technology');
        insert acc;

        Map<Id, Account> oldMap = new Map<Id, Account>();
        Test.startTest();
        TriggerHandler.handleAgricultureAccounts(new List<Account>{acc}, oldMap);
        Test.stopTest();

        acc.Industry = 'Agriculture';

        update acc;

        List<Opportunity> opps = [SELECT Id FROM Opportunity WHERE AccountId = :acc.Id];
        System.assertEquals(1, opps.size());
    }

    
}