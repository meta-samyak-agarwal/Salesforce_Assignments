trigger OpportunityTrigger on Opportunity (before update) {
    if (Trigger.isUpdate) {
 
        TriggerHandler.updateOpportunityCloseDate(Trigger.new, Trigger.oldMap);
        TriggerHandler.populateManagerField(Trigger.new);
    
    }
}