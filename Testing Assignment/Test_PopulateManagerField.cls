@isTest
private class Test_PopulateManagerField {
    @isTest
    static void testPopulateManager_Positive() {
        Account acc = new Account(Name='Manager Acc');
        insert acc;

        Contact con = new Contact(LastName='BillContact', AccountId=acc.Id);
        insert con;

        Opportunity opp = new Opportunity(Name='OppMgr', StageName='Prospecting', CloseDate=Date.today(), BillToContact__c=con.Id);
        insert opp;

        opp.Manager__c = null;
        TriggerHandler.populateManagerField(new List<Opportunity>{opp});

        System.assertEquals(acc.Id, opp.Manager__c);
    }

    @isTest
    static void testNoBillToContact_Negative() {
        Opportunity opp = new Opportunity(Name='NoBillOpp', StageName='Prospecting', CloseDate=Date.today());
        insert opp;

        // here the billToContacy is also we kept as null for the negative test case
        opp.Manager__c = null;
        TriggerHandler.populateManagerField(new List<Opportunity>{opp});

        System.assertEquals(null, opp.Manager__c);
    }
}