import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createContact from '@salesforce/apex/ContactController.createContact';

export default class ContactCreator extends LightningElement {
    @track contact = {
        FirstName: '',
        LastName: '',
        Email: '',
        Phone: '',
        Fax: ''
    };
    
    @track savedContact = null;
    @track isLoading = false;
    @track showSavedRecord = false;

    handleInputChange(event) {
        const fieldName = event.target.dataset.field;
        this.contact[fieldName] = event.target.value;
    }

    async handleSave() {
        // Basic validation
        if (!this.contact.FirstName || !this.contact.LastName) {
            this.showToast('Error', 'First Name and Last Name are required', 'error');
            return;
        }

        if (this.contact.Email && !this.isValidEmail(this.contact.Email)) {
            this.showToast('Error', 'Please enter a valid email address', 'error');
            return;
        }

        this.isLoading = true;
        
        try {
            const result = await createContact({ contactData: this.contact });
            this.savedContact = result;
            this.showSavedRecord = true;
            this.showToast('Success', 'Contact created successfully!', 'success');
            this.resetForm();
        } catch (error) {
            console.error('Error creating contact:', error);
            this.showToast('Error', error.body?.message || 'An error occurred while creating the contact', 'error');
        } finally {
            this.isLoading = false;
        }
    }

    handleReset() {
        this.resetForm();
        this.showSavedRecord = false;
        this.savedContact = null;
    }

    resetForm() {
        this.contact = {
            FirstName: '',
            LastName: '',
            Email: '',
            Phone: '',
            Fax: ''
        };
        
        // Reset form inputs
        const inputs = this.template.querySelectorAll('lightning-input');
        inputs.forEach(input => {
            input.value = '';
        });
    }

    isValidEmail(email) {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return emailRegex.test(email);
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            duration: 3000
        });
        this.dispatchEvent(event);
    }
}

