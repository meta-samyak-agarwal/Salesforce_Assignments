public with sharing class ShoppingCartController {
    
    @AuraEnabled
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
    
    @AuraEnabled
    public static Integer getPurchaseOrderCount() {
        return [SELECT COUNT() FROM PurchaseOrder__c];
    }
    
    @AuraEnabled
    public static List<Product2> getProducts(Integer pageNumber, Integer pageSize, String searchTerm, String sortBy, String sortDirection) {
        String sortOrder = String.isNotBlank(sortDirection) ? sortDirection : 'ASC';
        String orderBy = String.isNotBlank(sortBy) ? sortBy : 'Name';
        
        Integer offset = (pageNumber - 1) * pageSize;
        
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
    public static String createPurchaseOrder2(List<String> productIdList, List<String> quantityList) {
    System.debug('=== START createPurchaseOrder2 ===');
    System.debug('Received product ID list: ' + productIdList);
    System.debug('Received quantity list: ' + quantityList);

    try {
        if (productIdList == null || quantityList == null || productIdList.size() != quantityList.size()) {
            return 'ERROR: Invalid input data';
        }

        // Get current product information to validate availability
        Map<Id, Product2> productMap = new Map<Id, Product2>([
            SELECT Id, Name, Available_Quantity__c, Price__c, IsActive
            FROM Product2 
            WHERE Id IN :productIdList
        ]);

        System.debug('Retrieved ' + productMap.size() + ' products from database');

        Decimal totalAmount = 0;
        List<PurchaseOrderLineItem__c> poLineItemsToInsert = new List<PurchaseOrderLineItem__c>();
        List<Product2> productsToUpdate = new List<Product2>();

        // Loop through each product and corresponding quantity
        for (Integer i = 0; i < productIdList.size(); i++) {
            Id prodId = productIdList[i];
            Integer qty = Integer.valueOf(quantityList[i]);

            if (!productMap.containsKey(prodId)) {
                return 'ERROR: Product with ID ' + prodId + ' not found';
            }

            Product2 prod = productMap.get(prodId);

            if (!prod.IsActive || prod.Available_Quantity__c < qty) {
                return 'ERROR: Product ' + prod.Name + ' is either inactive or does not have enough stock';
            }

            Decimal lineTotal = prod.Price__c * qty;
            totalAmount += lineTotal;

            // Prepare line item
            PurchaseOrderLineItem__c lineItem = new PurchaseOrderLineItem__c();
            lineItem.Product__c = prod.Id;
            lineItem.Quantity__c = qty;
            lineItem.Unit_Price__c = prod.Price__c;

             // We'll assign Purchase_Order__c after inserting PO
            poLineItemsToInsert.add(lineItem);

            // Update available quantity
            prod.Available_Quantity__c -= qty;
            productsToUpdate.add(prod);
        }

        // Create Purchase Order
        PurchaseOrder__c po = new PurchaseOrder__c();
        po.Order_Date__c = Date.today();
        po.Total_Amount__c = totalAmount;
        po.Status__c = 'Placed';
        po.Order_Number__c = 'PO-' + String.valueOf(System.now().getTime());

        insert po;
        System.debug('Purchase Order inserted with ID: ' + po.Id);

        // Set PO reference in line items
        for (PurchaseOrderLineItem__c item : poLineItemsToInsert) {
            item.Purchase_Order__c = po.Id;
        }

        insert poLineItemsToInsert;
        update productsToUpdate;

        return 'SUCCESS: Purchase Order created successfully with Order Number: ' + po.Order_Number__c;

    } catch (Exception ex) {
        System.debug('Exception in createPurchaseOrder2: ' + ex.getMessage());
        return 'ERROR: ' + ex.getMessage();
    }
}

    @AuraEnabled(cacheable=true)
    public static Product2 getProductById(Id productId) {
        return [SELECT Id, Name, Product_Code__c, Available_Quantity__c, Price__c 
                FROM Product2 WHERE Id = :productId LIMIT 1];
    }
    
}
