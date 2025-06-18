trigger ClassTrigger on Class__c (before delete , before update) {
    if(Trigger.isDelete){
        TriggerHandler.handleClassDelete(Trigger.old);
    }

    
    if(Trigger.isUpdate){
        TriggerHandler.handleClassStatusReset(Trigger.new,Trigger.oldMap);
    }
    
}

 