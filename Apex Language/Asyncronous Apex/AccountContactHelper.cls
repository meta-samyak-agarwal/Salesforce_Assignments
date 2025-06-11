public class AccountContactHelper {
    public static void updateContactIds(Id contactId) {
        if(contactId == null ) return ;

        Contact con = [SELECT Id, AccountId FROM Contact WHERE ID = :contactId LIMIT 1];
        if(con.AccountId == null) return ;

        Account acc = [SELECT Id, ContactIDs__c, (SELECT Id FROM Contacts) FROM Account WHERE ID = :con.AccountId LIMIT 1];
        
        String existingIds = acc.ContactIDs__c;
        
        if(String.isBlank(existingIds)) {
            List<String> contactIds = new List<String>();
            for(Contact c: acc.Contacts) {
                contactIds.add(c.Id);
            }
            acc.ContactIDs__c = String.join(contactIds, ',');
        } else {
            List<String> contactIdList = new List<String>();
            contactIdList.addAll(existingIds.split(','));
            if(!contactIdList.contains(contactId)) {
                contactIdList.add(contactId);
                acc.ContactIDs__c = String.join(contactIdList, ',');
            }
        }

        update acc;
    }
}