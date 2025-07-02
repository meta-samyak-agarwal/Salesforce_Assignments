import { LightningElement, wire } from 'lwc';
import getAccountList from '@salesforce/apex/AccountController.getAccountList';


export default class AccountsList extends LightningElement {

    accounts;
    columns = [
        { label: 'Account Name', fieldName: 'Name' },
        { label: 'Account Phone', fieldName: 'Phone', type: 'phone' }
    ];

    @wire(getAccountList)
    wiredAccounts(response) {
        const data = response.data;
        const error = response.error;

        if(data){
            this.accounts = data;
        }else{
            console.log("error occurs" , error);
        }
    };

}