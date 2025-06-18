public class TriggerHandler {

    // Prevent Hindi teacher insert/update
    public static void handleTeacherInsertUpdate(List<Teacher__c> newList) {
        for (Teacher__c teacher : newList) {
            if (teacher.Subjects__c != null && teacher.Subjects__c.contains('Hindi')) {
                teacher.addError('Teachers teaching Hindi are not allowed to be inserted or updated.');
            }
        }
    }

    // Prevent Class deletion if it has more than one female student
    public static void handleClassDelete(List<Class__c> oldList) {
        Set<Id> classIds = new Map<Id, Class__c>(oldList).keySet();
        Map<Id, Integer> femaleCounts = new Map<Id, Integer>();

        for (AggregateResult ar : [
            SELECT Class__c classId, COUNT(Id) femaleCount
            FROM Student__c
            WHERE Class__c IN :classIds AND Gender__c = 'Female'
            GROUP BY Class__c
        ]) {
            femaleCounts.put((Id)ar.get('classId'), (Integer)ar.get('femaleCount'));
        }

        for (Class__c cls : oldList) {
            if (femaleCounts.containsKey(cls.Id) && femaleCounts.get(cls.Id) > 1) {
                cls.addError('Cannot delete class with more than one female student.');
            }
        }
    }

    // Prevent Student insert if class has reached max limit
    public static void preventStudentOverLimit(List<Student__c> newList) {
        Set<Id> classIds = new Set<Id>();
        for (Student__c stu : newList) {
            if (stu.Class__c != null) classIds.add(stu.Class__c);
        }

        Map<Id, Class__c> classMap = new Map<Id, Class__c>([
            SELECT Id, MaxLimit__c, (SELECT Id FROM Students__r) FROM Class__c WHERE Id IN :classIds
        ]);

        for (Student__c stu : newList) {
            if (stu.Class__c != null) {
                Class__c cls = classMap.get(stu.Class__c);
                if (cls.Students__r.size() >= cls.MaxLimit__c) {
                    stu.addError('Class has reached the max student limit.');
                }
            }
        }
    }

    // Update MyCount on Student insert/update/delete
    public static void updateClassMyCount(Set<Id> classIds) {
        Map<Id, Integer> studentCounts = new Map<Id, Integer>();

        for (AggregateResult ar : [
            SELECT Class__c classId, COUNT(Id) studentCount
            FROM Student__c
            WHERE Class__c IN :classIds
            GROUP BY Class__c
        ]) {
            studentCounts.put((Id)ar.get('classId'), (Integer)ar.get('studentCount'));
        }

        List<Class__c> updates = new List<Class__c>();
        for (Id cid : classIds) {
            Class__c cls = new Class__c(Id = cid, My_Count__c = studentCounts.containsKey(cid) ? studentCounts.get(cid) : 0);
            updates.add(cls);
        }
 
        update updates;
              
    }

    // Update Opportunity Close Date if stage changed to CLOSED_WON or CLOSED_LOST
    public static void updateOpportunityCloseDate(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        for (Opportunity opp : newList) {
            Opportunity oldOpp = oldMap.get(opp.Id);
            if ((opp.StageName == 'Closed Won' || opp.StageName == 'Closed Lost') &&
                oldOpp.StageName != opp.StageName) {
                opp.CloseDate = Date.today();
            }
        }
    }

    // Handle Reset on Class Status -> delete all students
    public static void handleClassStatusReset(List<Class__c> newList, Map<Id, Class__c> oldMap) {
        Set<Id> toDeleteFromClass = new Set<Id>();

        for (Class__c cls : newList) {

            Class__c oldCls = oldMap.get(cls.Id);

            if (cls.Custom_Status__c == 'Reset' && oldCls.Custom_Status__c != 'Reset') {
                toDeleteFromClass.add(cls.Id);
            }
        }

        TriggerControl.skipMyCountUpdate = true;

        if (!toDeleteFromClass.isEmpty()) {
            List<Student__c> toDelete = [SELECT Id FROM Student__c WHERE Class__c IN :toDeleteFromClass];
            delete toDelete;
        }

        TriggerControl.skipMyCountUpdate = false;

    }

    // Create new Opportunity when Account created/updated with Industry = Agriculture
    public static void handleAgricultureAccounts(List<Account> newList, Map<Id, Account> oldMap) {
        List<Opportunity> newOpps = new List<Opportunity>();

        for (Account acc : newList) {
            Boolean isNew = oldMap == null || !oldMap.containsKey(acc.Id);  // new record
            Boolean isChanged = !isNew && acc.Industry != oldMap.get(acc.Id).Industry;  // updated record

            if (acc.Industry == 'Agriculture' && (isNew || isChanged)) {
                newOpps.add(new Opportunity(
                    Name = acc.Name + ' Opportunity',
                    StageName = 'Prospecting',
                    CloseDate = Date.today().addDays(30),
                    AccountId = acc.Id
                ));
            }
        }
        if (!newOpps.isEmpty()) insert newOpps;
    }

    // Update Contact's MailingCity when Account BillingCity is updated
    public static void syncBillingToMailingCity(List<Account> newList, Map<Id, Account> oldMap) {
        Map<Id, String> updatedCities = new Map<Id, String>();
        for (Account acc : newList) {
            if (acc.BillingCity != oldMap.get(acc.Id).BillingCity) {
                updatedCities.put(acc.Id, acc.BillingCity);
            }
        }

        if (!updatedCities.isEmpty()) {
            List<Contact> updates = [SELECT Id, MailingCity, AccountId FROM Contact WHERE AccountId IN :updatedCities.keySet()];
            for (Contact c : updates) {
                c.MailingCity = updatedCities.get(c.AccountId);
            }
            update updates;
        }
    }

    
    // Populate Opportunity Manager from BillToContact if blank
    public static void populateManagerField(List<Opportunity> newList) {
        Set<Id> contactIds = new Set<Id>();
        for (Opportunity opp : newList) {
            if (opp.BillToContact__c != null && opp.Manager__c == null) {
                contactIds.add(opp.BillToContact__c);
            }
        }

        Map<Id, Contact> contactMap = new Map<Id, Contact>([
            SELECT Id, AccountId FROM Contact WHERE Id IN :contactIds
        ]);

        for (Opportunity opp : newList) {
            if (opp.BillToContact__c != null && opp.Manager__c == null) {
                Contact con = contactMap.get(opp.BillToContact__c);
                if (con != null && con.AccountId != null) {
                    opp.Manager__c = con.AccountId;
                }
            }
        }
    }

}