public inherited sharing class PurchaseOrderSelector extends fflib_SObjectSelector {
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            PurchaseOrder__c.Id,
            PurchaseOrder__c.Name,
            PurchaseOrder__c.Order_Date__c,
            PurchaseOrder__c.Total_Amount__c,
            PurchaseOrder__c.Status__c,
            PurchaseOrder__c.Order_Number__c,
            PurchaseOrder__c.CreatedDate
        };
    }
    
    public Schema.SObjectType getSObjectType() {
        return PurchaseOrder__c.sObjectType;
    }
    
    public List<PurchaseOrder__c> selectByIdWithPagination(Integer pageNumber, Integer pageSize, String sortBy, String sortDirection) {
        String sortOrder = String.isNotBlank(sortDirection) ? sortDirection : 'DESC';
        String orderBy = String.isNotBlank(sortBy) ? sortBy : 'CreatedDate';
        Integer offset = (pageNumber - 1) * pageSize;
        
        return (List<PurchaseOrder__c>) Database.query(
            newQueryFactory()
                .setOrdering(orderBy, fflib_QueryFactory.SortOrder.valueOf(sortOrder))
                .setLimit(pageSize)
                .setOffset(offset)
                .toSOQL()
        );
    }
    
    public Integer selectCount() {
        return Database.countQuery('SELECT COUNT() FROM PurchaseOrder__c');
    }
}