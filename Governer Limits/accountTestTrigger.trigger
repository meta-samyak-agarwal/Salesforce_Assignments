trigger accountTestTrigger on Account (after insert, after update) {  // problem was here is that we are using 
                                                                      // before update/insert 

    // first of all we store the List<Id> of accounts which are triggering
    List<Id> accIdList = new List<Id>();

    for(Account a: Trigger.new) {
        if(a.id != null){
            accIdList.add(a.Id);
        }
    }

    // finding the contacts which are present in the accIdList
    List<Contact> contacts = [select id, salutation, firstname, lastname, email
                                FROM Contact where accountId IN: accIdList];


    // then simply did the bulk DML operation by creating the list of Contact
    for(Contact c: contacts) {
        c.Description = c.salutation + ' ' + c.firstName + ' ' + c.lastname;
    }

    update contacts;    // this will reduce the number of DML operations
        
}
