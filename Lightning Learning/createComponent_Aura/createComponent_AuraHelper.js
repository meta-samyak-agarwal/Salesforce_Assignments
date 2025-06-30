({
    resetForm: function(component) {
        var emptyContact = {
            'sobjectType': 'Contact',
            'FirstName': '',
            'LastName': '',
            'Email': '',
            'Phone': '',
            'Fax': ''
        };
        component.set("v.contact", emptyContact);
    },
    
    isValidEmail: function(email) {
        var emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return emailRegex.test(email);
    },
    
    showToast: function(title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        if (toastEvent) {
            toastEvent.setParams({
                "title": title,
                "message": message,
                "type": type,
                "duration": 3000
            });
            toastEvent.fire();
        }
    }
})
