trigger accountTestTrigger on Account (before insert, before update) {

    // first of all we store the List<Id> of accounts which are triggering
    List<Id> accIdList = new List<Id>();

    for(Account a: Trigger.new) {
        accIdList.add(a.Id);
    }

    // finding the contacts which are present in the accIdList
    List<Contact> contacts = [select id, salutation, firstname, lastname, email
                                FROM Contact where accountId IN: accIdList];

     
    List<Contact> contactList = new List<Contact>();

    // then simply did the bulk DML operation by creating the list of Contact
    for(Contact c: contacts) {

        c.Description = c.salutation + ' ' + c.firstName + ' ' + c.lastname;

        contactList.add(c);
    }

    
    update contactList;
        
}