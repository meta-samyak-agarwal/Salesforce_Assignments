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
    public static String createPurchaseOrder(List<PurchaseOrderLineItem__c> lineItems, Decimal totalAmount) {
        System.debug('=== START createPurchaseOrder1 ===');
        System.debug('Received lineItems: ' + lineItems);
        System.debug('Received totalAmount: ' + totalAmount);
    
        Savepoint sp = Database.setSavepoint();
        
        try {
             
            // Validate line items and collect product IDs
            Set<String> productIds = new Set<String>();
            
            for (Integer i = 0; i < lineItems.size(); i++) {
                PurchaseOrderLineItem__c item = lineItems[i];
                 
                productIds.add(item.Product__c);
            }
    
    
            // Get current product information to validate availability
            Map<Id, Product2> productMap = new Map<Id, Product2>([
                SELECT Id, Name, Available_Quantity__c, Price__c, IsActive
                FROM Product2 
                WHERE Id IN :productIds
            ]);
    
            System.debug('Retrieved ' + productMap.size() + ' products from database');
    
            // Validate product availability and active status
            for (PurchaseOrderLineItem__c item : lineItems) {
                Product2 product = productMap.get(item.Product__c);
                
                if (product == null) {
                    throw new AuraHandledException('Product not found: ' + item.Product__c);
                }
                
                if (!product.IsActive) {
                    throw new AuraHandledException('Product is not active: ' + product.Name);
                }
                
                if (product.Available_Quantity__c < item.Quantity__c) {
                    throw new AuraHandledException('Insufficient quantity for product: ' + product.Name + 
                        '. Available: ' + product.Available_Quantity__c + ', Requested: ' + item.Quantity__c);
                }
            }
    
            System.debug('Product availability validation passed');
    
            // Create Purchase Order
            PurchaseOrder__c po = new PurchaseOrder__c();
            po.Order_Date__c = Date.today();
            po.Total_Amount__c = totalAmount;
            po.Status__c = 'Placed';
            po.Order_Number__c = 'PO-' + String.valueOf(System.now().getTime());
            
            System.debug('About to insert Purchase Order: ' + JSON.serialize(po));
            insert po;
            System.debug('Purchase Order inserted with ID: ' + po.Id);
    
            // Set Purchase Order reference and prepare products for update
            List<PurchaseOrderLineItem__c> poLineItemsToInsert = new List<PurchaseOrderLineItem__c>();
            List<Product2> productsToUpdate = new List<Product2>();
    
            for (PurchaseOrderLineItem__c item : lineItems) {
                System.debug('Processing line item for product: ' + item.Product__c);
    
                // Set the Purchase Order reference
                item.Purchase_Order__c = po.Id;
                poLineItemsToInsert.add(item);
    
                // Get current product data
                Product2 currentProduct = productMap.get(item.Product__c);
                
                // Prepare product for quantity update
                Product2 productToUpdate = new Product2();
                productToUpdate.Id = item.Product__c;
                productToUpdate.Available_Quantity__c = currentProduct.Available_Quantity__c - item.Quantity__c;
                productsToUpdate.add(productToUpdate);
                
                System.debug('Product ' + item.Product__c + ' quantity will be updated from ' + 
                            currentProduct.Available_Quantity__c + ' to ' + 
                            (currentProduct.Available_Quantity__c - item.Quantity__c));
            }
    
            System.debug('About to insert ' + poLineItemsToInsert.size() + ' purchase order line items');
            insert poLineItemsToInsert;
            System.debug('Purchase order line items inserted successfully');
    
            System.debug('About to update ' + productsToUpdate.size() + ' products');
            update productsToUpdate;
            System.debug('Products updated successfully');
    
            System.debug('=== END createPurchaseOrder SUCCESS ===');
            return 'SUCCESS: Purchase Order created successfully with Order Number: ' + po.Order_Number__c;
            
        } catch (DmlException e) {
            System.debug('=== DML ERROR in createPurchaseOrder ===');
            System.debug('DML Error Type: ' + e.getTypeName());
            System.debug('DML Error Message: ' + e.getMessage());
            System.debug('DML Error Stack Trace: ' + e.getStackTraceString());
            System.debug('DML Error Line Number: ' + e.getLineNumber());
            
            // Rollback transaction
            Database.rollback(sp);
            
            // Handle specific DML errors
            String errorMessage = 'Database error occurred: ';
            for (Integer i = 0; i < e.getNumDml(); i++) {
                errorMessage += e.getDmlMessage(i) + ' ';
            }
            
            throw new AuraHandledException('Purchase Order creation failed: ' + errorMessage);
            
        } catch (Exception e) {
            System.debug('=== GENERAL ERROR in createPurchaseOrder ===');
            System.debug('Error Type: ' + e.getTypeName());
            System.debug('Error Message: ' + e.getMessage());
            System.debug('Error Stack Trace: ' + e.getStackTraceString());
            System.debug('Error Line Number: ' + e.getLineNumber());
            
            // Rollback transaction
            Database.rollback(sp);
            
            // Re-throw as AuraHandledException for proper client handling
            throw new AuraHandledException('Purchase Order creation failed: ' + e.getMessage());
        }
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
