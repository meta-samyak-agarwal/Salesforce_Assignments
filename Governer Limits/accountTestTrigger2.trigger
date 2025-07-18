trigger accountTestTrigger2 on Account (before delete, before insert, before update) {

    // Problem 1 :
    --> Trigger.new will return the null in the before Delete, so we can't do like that 

    // Problem 2 : 
    --> there is no need to make the two seperate List for it , we can combine it too.

    // problem 3 : 
    --> there should be no before insert , coz question is saying that whenever trigger runs on the Account
         its related opportunity shoud perform something based on the stage-Name ok ? so we don't need before insert
        because before recored is created we don't have the opportunity realted to it.


    // List<Opportunity> opptysClosedLost = [select id, name, closedate, stagename 
    //                                         from Opportunity
    //                                         where accountId IN :Trigger.newMap.keySet() and StageName='Closed - Lost'];

    // List<Opportunity> opptysClosedWon = [select id, name, closedate, stagename 
    //                                     from Opportunity 
    //                                     where accountId IN :Trigger.newMap.keySet() and StageName='Closed - Won'];

    Set<Id> accountId = new Set<Id>();

    if(Trigger.isDelete && Trigger.old != null){
        accountId = Trigger.oldMap.keySet();      // this is for the delete 
    }
    else if(Trigger.new != null) {
        accountId = Trigger.newMap.keySet();     // this is for the update and insert both because we can access the acc.id before insert too
    }

    if(accountId.isEmpty())   return ;         // early return if the accId is null


    // now we merger the two calls of the above code and make a single one
    List<Opportunity> oppList = [SELECT Id,Name, CloseDate, StageName 
                                FROM Opportunity
                                WHERE AccountId IN :accountId AND StageName IN ('Closed - Won', 'Closed-Lost')];


    // Grouping opp by AccountId
    Map<Id, List<Opportunity>> oppMap = new Map<Id, List<Opportunity>>();

    for(Opportunity opp: oppList) {
        if(!oppMap.containsKey(opp.accountId)) {
            oppMap.put(opp.accountId, new List<Opportunity>());
        }
        oppMap.get(opp.accountId).add(opp);
    }


    // this will be applicable for the before update and before delete not the before insert

    for(Account acc: Trigger.new) {
        // releted oppList related to the given account on which the trigger is run
        List<Opportunity> releatedAccOpps = oppMap.get(acc.Id);

        if(releatedAccOpps != null) {                      // it will be null in case of the before insert 
            for(Opportunity opp: releatedAccOpps) {

                if(opp.StageName == 'Closed - Won') {
                    System.debug('Closed Won Opportunity ' + opp.Name);
                } else if(opp.StageName == 'Closed - Lost') {
                    System.debug('Closed Lost Opportunity ' + opp.Name);
                }

            }
        }
    }
    }
