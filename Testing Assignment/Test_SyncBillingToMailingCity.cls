@isTest
private class Test_SyncBillingToMailingCity {
    @isTest
    static void testSyncCity_Positive() {
        Account acc = new Account(Name='CityAcc', BillingCity='Jaipur');
        insert acc;

        Contact con = new Contact(LastName='Syncee', AccountId=acc.Id, MailingCity='OldCity');
        insert con;

        acc.BillingCity = 'Delhi';
        Map<Id, Account> oldMap = new Map<Id, Account>{ acc.Id => new Account(Id=acc.Id, BillingCity='Jaipur') };

        TriggerHandler.syncBillingToMailingCity(new List<Account>{acc}, oldMap);

        Contact updated = [SELECT MailingCity FROM Contact WHERE Id = :con.Id];
        System.assertEquals('Delhi', updated.MailingCity);
    }

    @isTest
    static void testNoBillingCityChange_Negative() {
        Account acc = new Account(Name='StaticAcc', BillingCity='Mumbai');
        insert acc;

        Contact con = new Contact(LastName='StaticCon', AccountId=acc.Id, MailingCity='Mumbai');
        insert con;

        Map<Id, Account> oldMap = new Map<Id, Account>{ acc.Id => new Account(Id=acc.Id, BillingCity='Mumbai') };

        TriggerHandler.syncBillingToMailingCity(new List<Account>{acc}, oldMap);

        Contact same = [SELECT MailingCity FROM Contact WHERE Id = :con.Id];
        System.assertEquals('Mumbai', same.MailingCity);
    }
}