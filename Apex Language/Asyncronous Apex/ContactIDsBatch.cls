public class ContactIDsBatch implements Database.Batchable<Id> {

    // Accept list of Contact IDs
    private List<Id> contactIds;

    public ContactIDsBatch(List<Id> contactIds) {
        this.contactIds = contactIds;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
            SELECT Id, AccountId FROM Contact WHERE Id IN :contactIds AND AccountId != null
        ]);
    }

    public void execute(Database.BatchableContext BC, List<Contact> contactList) {
        Map<Id, Set<Id>> accountToContactSetMap = new Map<Id, Set<Id>>();

        for (Contact con : contactList) {
            if (!accountToContactSetMap.containsKey(con.AccountId)) {
                accountToContactSetMap.put(con.AccountId, new Set<Id>());
            }
            accountToContactSetMap.get(con.AccountId).add(con.Id);
        }

        List<Account> accountsToUpdate = new List<Account>();
        List<Id> accountIds = new List<Id>(accountToContactSetMap.keySet());

        Map<Id, Account> accountMap = new Map<Id, Account>(
            [SELECT Id, ContactIDs__c, (SELECT Id FROM Contacts) FROM Account WHERE Id IN :accountIds]
        );

        for (Id accId : accountToContactSetMap.keySet()) {
            Account acc = accountMap.get(accId);

            Set<String> existingIds = new Set<String>();
            if (!String.isBlank(acc.ContactIDs__c)) {
                existingIds.addAll(acc.ContactIDs__c.split(','));
            }

            // If field is blank, add all related contacts
            if (String.isBlank(acc.ContactIDs__c)) {
                for (Contact c : acc.Contacts) {
                    existingIds.add(c.Id);
                }
            } else {
                for (Id cid : accountToContactSetMap.get(accId)) {
                    existingIds.add(cid);
                }
            }

            acc.ContactIDs__c = String.join(new List<String>(existingIds), ',');
            accountsToUpdate.add(acc);
        }

        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }

    public void finish(Database.BatchableContext BC) {
        // You can add logic here if needed (e.g., notify admin)
    }
}