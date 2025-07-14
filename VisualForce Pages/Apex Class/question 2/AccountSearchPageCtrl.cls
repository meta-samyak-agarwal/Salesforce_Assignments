public with sharing class AccountSearchPageCtrl {
      
    public Integer getTotalPages(){
        Integer resultSize = this.objController.getResultSize();
        Integer pgSize = this.objController.getPageSize();
        Integer totPages = (resultSize/pgSize);
        if(Math.mod(resultSize,pgSize) > 0){
            totPages+=1;
        }
        return totPages;
    }
    
    public String pageSize{get;set;}
    public String billingCity{get; set;}
    public String billingState{get;set;}
    public String billingCountry{get;set;}
    
    public ApexPages.StandardSetController objController{
        get{
            if(objController == null){
                List<Account> accountList = [SELECT Id, Name, BillingCity, BillingState, BillingCountry FROM Account];
                this.objController = new ApexPages.StandardSetController(accountList);
                this.objController.setPageSize(10);
            }
            return objController;
        }
        set;
    }
    
    public List<Account> getAccounts(){
        return (List<Account>)this.objController.getRecords();
    }
    
    public void search(){
        this.objController = new ApexPages.StandardSetController(fetchAccounts());
        if(!String.isBlank(pageSize) && pageSize.isNumeric()){
            objController.setPageSize(Integer.valueOf(pageSize));
        }else{
            objController.setPageSize(10);
        }
    }
    
    private List<Account> fetchAccounts(){
        String query = 'SELECT Id, Name, BillingCity, BillingState, BillingCountry FROM Account WHERE Id != null';
        if(!String.isBlank(billingCity)) {
            query += ' AND BillingCity LIKE \'%' + String.escapeSingleQuotes(billingCity) + '%\'';
        }
        if(!String.isBlank(billingState)) {
            query += ' AND BillingState LIKE \'%' + String.escapeSingleQuotes(billingState) + '%\'';
        }
        if(!String.isBlank(billingCountry)) {
            query += ' AND BillingCountry LIKE \'%' + String.escapeSingleQuotes(billingCountry) + '%\'';
        }
        System.debug(query);
        return (List<Account>) Database.query(query);
    }
}