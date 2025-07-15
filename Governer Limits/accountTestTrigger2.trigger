trigger accountTestTrigger2 on Account (before delete, before insert, before update) {

    // List<Opportunity> opptysClosedLost = [select id, name, closedate, stagename 
    //                                         from Opportunity
    //                                         where accountId IN :Trigger.newMap.keySet() and StageName='Closed - Lost'];

    // List<Opportunity> opptysClosedWon = [select id, name, closedate, stagename 
    //                                     from Opportunity 
    //                                     where accountId IN :Trigger.newMap.keySet() and StageName='Closed - Won'];

    Set<Id> accountId = new Set<Id>();

    if(Trigger.isDelete || Trigger.isUpdate){
        accountId.addAll(Trigger.newMap.keySet());
    }
    else if(Trigger.isInsert){
        for(Account acc : Trigger.new){
            if(acc.Id != null)  accountId.add(acc.Id);
        }
    }

    if(accountId.isEmpty())   return ;

    // now we merger the two calls of the above code and make a single one
    List<Opportunity> oppList = [SELECT Id, Name, CloseDate, StageName FROM Opportunity
                                    WHERE AccountId IN :accountId AND StageName IN ('Closed - Won', 'Closed-Lost')];


       

// Grouping opp by AccountId
    Map<Id, List<Opportunity>> oppMap = new Map<Id, List<Opportunity>>();

    for(Opportunity opp: oppList) {
        if(!oppMap.containsKey(opp.accountId)) {
            oppMap.put(opp.accountId, new List<Opportunity>());
        }
        oppMap.get(opp.accountId).add(opp);
    }


        for(Account acc: Trigger.new) {
            // releted opp to acc 
            List<Opportunity> releatedAccOpps = oppMap.get(acc.Id);

            if(releatedAccOpps != null) {
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