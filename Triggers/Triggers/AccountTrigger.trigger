trigger AccountTrigger on Account (after insert, after update, before update) {
    
    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        TriggerHandler.handleAgricultureAccounts(Trigger.new, Trigger.isInsert ? null : Trigger.oldMap);
    }

    if (Trigger.isBefore && Trigger.isUpdate) {
        TriggerHandler.syncBillingToMailingCity(Trigger.new, Trigger.oldMap);
    }
}

