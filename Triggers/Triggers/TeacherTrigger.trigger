trigger TeacherTrigger on Teacher__c (before insert , before update) {

    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
        TriggerHandler.handleTeacherInsertUpdate(Trigger.new);
    }
}


