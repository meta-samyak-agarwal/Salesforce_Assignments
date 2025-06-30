({
    doInit: function(component, event, helper) {
        // Initialize component
    },
    
    handleInputChange: function(component, event, helper) {
        var fieldName = event.getSource().get("v.name");
        var fieldValue = event.getParam("value");
        var contact = component.get("v.contact");
        contact[fieldName] = fieldValue;
        component.set("v.contact", contact);
    },
    
    handleSave: function(component, event, helper) {
        var contact = component.get("v.contact");
        
        // Basic validation
        if (!contact.FirstName || !contact.LastName) {
            helper.showToast("Error", "First Name and Last Name are required", "error");
            return;
        }
        
        if (contact.Email && !helper.isValidEmail(contact.Email)) {
            helper.showToast("Error", "Please enter a valid email address", "error");
            return;
        }
        
        component.set("v.isLoading", true);
        
        var action = component.get("c.createContact");
        action.setParams({
            "contactData": contact
        });
        
        action.setCallback(this, function(response) {
            component.set("v.isLoading", false);
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.savedContact", result);
                component.set("v.showSavedRecord", true);
                helper.showToast("Success", "Contact created successfully!", "success");
                helper.resetForm(component);
            } else if (state === "ERROR") {
                var errors = response.getError();
                var message = "An error occurred while creating the contact";
                if (errors && errors[0] && errors[0].message) {
                    message = errors[0].message;
                }
                helper.showToast("Error", message, "error");
                console.error("Error: ", errors);
            }
        });
        
        $A.enqueueAction(action);
    },
    
    handleReset: function(component, event, helper) {
        helper.resetForm(component);
        component.set("v.showSavedRecord", false);
        component.set("v.savedContact", null);
    }
})
