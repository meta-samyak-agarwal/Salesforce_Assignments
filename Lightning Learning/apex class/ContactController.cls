public with sharing class ContactController {
    @AuraEnabled
    public static Contact createContact(Map<String, Object> contactData) {
        try {
            Contact newContact = new Contact();
            
            if (contactData.containsKey('FirstName')) {
                newContact.FirstName = (String) contactData.get('FirstName');
            }
            if (contactData.containsKey('LastName')) {
                newContact.LastName = (String) contactData.get('LastName');
            }
            if (contactData.containsKey('Email')) {
                newContact.Email = (String) contactData.get('Email');
            }
            if (contactData.containsKey('Phone')) {
                newContact.Phone = (String) contactData.get('Phone');
            }
            if (contactData.containsKey('Fax')) {
                newContact.Fax = (String) contactData.get('Fax');
            }
            
            insert newContact;
            
            // Return the created contact with all fields
            return [SELECT Id, FirstName, LastName, Email, Phone, Fax, CreatedDate 
                   FROM Contact WHERE Id = :newContact.Id LIMIT 1];
            
        } catch (Exception e) {
            throw new AuraHandledException('Error creating contact: ' + e.getMessage());
        }
    }
}