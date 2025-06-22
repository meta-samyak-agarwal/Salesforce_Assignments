@isTest
private class Test_UpdateOpportunityCloseDate {
    @isTest
    static void testUpdateCloseDate_Positive() {
        Opportunity opp = new Opportunity(Name='Test Opp', StageName='Prospecting', CloseDate=Date.today().addDays(10));
        insert opp;

        opp.StageName = 'Closed Won';
        Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>{
            opp.Id => new Opportunity(Id=opp.Id, StageName='Prospecting')
        };

        Test.startTest();
        TriggerHandler.updateOpportunityCloseDate(new List<Opportunity>{opp}, oldMap);
        Test.stopTest();

        Opportunity updated = [SELECT CloseDate FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(Date.today(), updated.CloseDate);
    }

    @isTest
    static void testUpdateCloseDate_SameStage_Negative() {
        Opportunity opp = new Opportunity(Name='Test Opp2', StageName='Prospecting', CloseDate=Date.today().addDays(5));
        insert opp;

        Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>{ opp.Id => opp };
        Test.startTest();
        TriggerHandler.updateOpportunityCloseDate(new List<Opportunity>{opp}, oldMap);
        Test.stopTest();

        System.assertNotEquals(Date.today(), [SELECT CloseDate FROM Opportunity WHERE Id = :opp.Id].CloseDate);
    }
} 