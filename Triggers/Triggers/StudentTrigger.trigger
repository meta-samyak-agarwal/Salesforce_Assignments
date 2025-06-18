trigger StudentTrigger on Student__c (before insert, before update, after insert, after update, after delete) {
    
    if (Trigger.isBefore && (Trigger.isInsert)) {
        TriggerHandler.preventStudentOverLimit(Trigger.new);
    }


    // this is for the updation of the student in the class
    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        Set<Id> classIds = new Set<Id>();

        // int this Trigger.New we have tbe list of the student list
        for (Student__c stu : Trigger.new) {
            if (stu.Class__c != null) classIds.add(stu.Class__c);
        }
        TriggerHandler.updateClassMyCount(classIds);
    }


    // this is for the deletion of the students in the class
    if (Trigger.isAfter && Trigger.isDelete) {
        Set<Id> classIds = new Set<Id>();
        for (Student__c stu : Trigger.old) {
            if (stu.Class__c != null) classIds.add(stu.Class__c);
        }

        if(!TriggerControl.skipMyCountUpdate) {
            TriggerHandler.updateClassMyCount(classIds);
        }
    } 
    
}