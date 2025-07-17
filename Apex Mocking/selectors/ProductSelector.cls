public inherited sharing class ProductSelector extends fflib_SObjectSelector {
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Product2.Id,
            Product2.Name,
            Product2.Product_Code__c,
            Product2.Available_Quantity__c,
            Product2.Price__c,
            Product2.IsActive
        };
    }
    
    public Schema.SObjectType getSObjectType() {
        return Product2.sObjectType;
    }
    
    public List<Product2> selectByIds(Set<Id> productIds) {
        return (List<Product2>) selectSObjectsById(productIds);
    }
    
    public List<Product2> selectActiveProductsWithPagination(Integer pageNumber, Integer pageSize, String searchTerm, String sortBy, String sortDirection) {
        String sortOrder = String.isNotBlank(sortDirection) ? sortDirection : 'ASC';
        String orderBy = String.isNotBlank(sortBy) ? sortBy : 'Name';
        Integer offset = (pageNumber - 1) * pageSize;
        
        fflib_QueryFactory queryFactory = newQueryFactory()
            .setCondition('IsActive = true AND Available_Quantity__c > 0')
            .setOrdering(orderBy, fflib_QueryFactory.SortOrder.valueOf(sortOrder))
            .setLimit(pageSize)
            .setOffset(offset);
        
        if (String.isNotBlank(searchTerm)) {
            queryFactory.setCondition('IsActive = true AND Available_Quantity__c > 0 AND Name LIKE \'%' + String.escapeSingleQuotes(searchTerm) + '%\'');
        }
        
        return (List<Product2>) Database.query(queryFactory.toSOQL());
    }
    
    public Integer selectActiveProductCount(String searchTerm) {
        String whereClause = 'WHERE IsActive = true AND Available_Quantity__c > 0';
        
        if (String.isNotBlank(searchTerm)) {
            whereClause += ' AND Name LIKE \'%' + String.escapeSingleQuotes(searchTerm) + '%\'';
        }
        
        return Database.countQuery('SELECT COUNT() FROM Product2 ' + whereClause);
    }
    
    public Product2 selectById(Id productId) {
        List<Product2> products = selectByIds(new Set<Id>{productId});
        return products.isEmpty() ? null : products[0];
    }
}