 
public with sharing class AccountController {
    
    
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccountList() {
        
            List<Account> accountList = [
                SELECT Id,                    // Unique identifier for the record
                       Name,                  // Account name
                       Type,                  // Account type (Customer, Partner, etc.)
                       Industry,              // Industry classification
                       Phone,                 // Primary phone number
                       Website,               // Company website
                       BillingCity,           // Billing address city
                       BillingState,          // Billing address state
                       BillingCountry,        // Billing address country
                       CreatedDate            // When the record was created
                FROM Account
                WHERE Name != null           // Filter out accounts without names
                ORDER BY CreatedDate DESC    // Order by newest first
                LIMIT 10                     // Limit results to 50 records for performance
            ];
            
    
            return accountList;
            
        }  
    }
