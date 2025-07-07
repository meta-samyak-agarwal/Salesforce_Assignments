public with sharing class ShoppingCartController {
    
    @AuraEnabled(cacheable=true)
    public static List<PurchaseOrder__c> getPurchaseOrderHistory(Integer pageNumber, Integer pageSize, String sortBy, String sortDirection) {
        String sortOrder = String.isNotBlank(sortDirection) ? sortDirection : 'DESC';
        String orderBy = String.isNotBlank(sortBy) ? sortBy : 'CreatedDate';
        
        Integer offset = (pageNumber - 1) * pageSize;
        
        String query = 'SELECT Id, Name, Order_Date__c, Total_Amount__c, Status__c, Order_Number__c, CreatedDate ' +
                      'FROM PurchaseOrder__c ' +
                      'ORDER BY ' + orderBy + ' ' + sortOrder + ' ' +
                      'LIMIT ' + pageSize + ' OFFSET ' + offset;
        
        return Database.query(query);
    }
    
    @AuraEnabled(cacheable=true)
    public static Integer getPurchaseOrderCount() {
        return [SELECT COUNT() FROM PurchaseOrder__c];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Product2> getProducts(Integer pageNumber, Integer pageSize, String searchTerm, String sortBy, String sortDirection) {
        String sortOrder = String.isNotBlank(sortDirection) ? sortDirection : 'ASC'; // for the sorting
        String orderBy = String.isNotBlank(sortBy) ? sortBy : 'Name'; // for the sorting
        
        Integer offset = (pageNumber - 1) * pageSize; // for the pagination 
        
        String whereClause = 'WHERE IsActive = true AND Available_Quantity__c > 0';
        
        if (String.isNotBlank(searchTerm)) {
            whereClause += ' AND Name LIKE \'%' + String.escapeSingleQuotes(searchTerm) + '%\'';
        }
        
        String query = 'SELECT Id, Name, Product_Code__c, Available_Quantity__c, Price__c ' +
                      'FROM Product2 ' +
                      whereClause + ' ' +
                      'ORDER BY ' + orderBy + ' ' + sortOrder + ' ' +
                      'LIMIT ' + pageSize + ' OFFSET ' + offset;
        
        return Database.query(query);
    }
    
    @AuraEnabled(cacheable=true)
    public static Integer getProductCount(String searchTerm) {
        String whereClause = 'WHERE IsActive = true AND Available_Quantity__c > 0';
        
        if (String.isNotBlank(searchTerm)) {
            whereClause += ' AND Name LIKE \'%' + String.escapeSingleQuotes(searchTerm) + '%\'';
        }
        
        String query = 'SELECT COUNT() FROM Product2 ' + whereClause;
        
        return Database.countQuery(query);
    }
    
    @AuraEnabled
    public static String createPurchaseOrder(List<Object> cartItems, Decimal totalAmount){
    System.debug('=== START createPurchaseOrder ===');
    System.debug('Received cartItems raw: ' + JSON.serialize(cartItems));
    System.debug('Received totalAmount: ' + totalAmount);

    // Deserialize each item to CartItem wrapper
    List<CartItem> cartItemList = new List<CartItem>();
    for (Object o : cartItems) {
        String jsonItem = JSON.serialize(o);
        CartItem item = (CartItem)JSON.deserialize(jsonItem, CartItem.class);
        System.debug('Deserialized CartItem: ' + jsonItem);
        cartItemList.add(item);
    }

    if (cartItemList.isEmpty()) {
        throw new AuraHandledException('Cart is empty.');
    }
    if (totalAmount == null || totalAmount <= 0) {
        throw new AuraHandledException('Invalid total amount.');
    }

    PurchaseOrder__c po = new PurchaseOrder__c();
    po.Order_Date__c = Date.today();
    po.Total_Amount__c = totalAmount;
    po.Status__c = 'Placed';
    po.Order_Number__c = 'PO-' + String.valueOf(System.now().getTime());
    insert po;

    List<PurchaseOrderLineItem__c> lineItems = new List<PurchaseOrderLineItem__c>();
    List<Product2> productsToUpdate = new List<Product2>();

    for (CartItem item : cartItemList) {
        System.debug('Processing cart item: ' + JSON.serialize(item));

        if (String.isBlank(item.productId)) {
            throw new AuraHandledException('Invalid product in cart: blank productId.');
        }
        if (item.availableQuantity == null || item.quantity == null || item.quantity <= 0) {
            throw new AuraHandledException('Invalid quantity for product ' + item.productId);
        }

        PurchaseOrderLineItem__c lineItem = new PurchaseOrderLineItem__c();
        lineItem.Purchase_Order__c = po.Id;
        lineItem.Product__c = item.productId;
        lineItem.Quantity__c = item.quantity;
        lineItem.Unit_Price__c = item.price;
        lineItems.add(lineItem);

        Product2 product = new Product2();
        product.Id = item.productId;
        product.Available_Quantity__c = item.availableQuantity - item.quantity;
        productsToUpdate.add(product);
    }

    insert lineItems;
    update productsToUpdate;

    System.debug('=== END createPurchaseOrder ===');
    return 'SUCCESS: Purchase Order created successfully with Order Number: ' + po.Order_Number__c;
}
    
    @AuraEnabled(cacheable=true)
    public static Product2 getProductById(Id productId) {
        return [SELECT Id, Name, Product_Code__c, Available_Quantity__c, Price__c 
                FROM Product2 WHERE Id = :productId LIMIT 1];
    }
    
    // Wrapper class for cart items 
    // DTO (data transfer object) , used as a bridge between the apex and ligntning
    public class CartItem {
        @AuraEnabled public String productId;
        @AuraEnabled public String productName;
        @AuraEnabled public String productCode;
        @AuraEnabled public Decimal quantity;
        @AuraEnabled public Decimal price;
        @AuraEnabled public Decimal totalPrice;
        @AuraEnabled public Decimal availableQuantity;
    }
}