public inherited sharing class ShoppingCartService implements IShoppingCartService {
    
    @TestVisible
    private final PurchaseOrderSelector purchaseOrderSelector;
    @TestVisible
    private final ProductSelector productSelector;
    @TestVisible
    private final PurchaseOrderLineItemSelector lineItemSelector;
    
    // Static factories for selectors and unit of work 
    private static final fflib_Application.SelectorFactory selectorFactory = 
        new fflib_Application.SelectorFactory(
            new Map<SObjectType, Type> {
                PurchaseOrder__c.SObjectType => PurchaseOrderSelector.class,
                Product2.SObjectType => ProductSelector.class,
                PurchaseOrderLineItem__c.SObjectType => PurchaseOrderLineItemSelector.class
            }
        );
    
    private static final fflib_Application.UnitOfWorkFactory unitOfWorkFactory = 
        new fflib_Application.UnitOfWorkFactory(
            new List<SObjectType> {
                PurchaseOrder__c.SObjectType,
                PurchaseOrderLineItem__c.SObjectType,
                Product2.SObjectType
            }
        );
    
    static{
        purchaseOrderSelector = new PurchaseOrderSelector();
        productSelector = new ProductSelector();
        lineItemSelector = new PurchaseOrderLineItemSelector();
    }
        
    public List<PurchaseOrder__c> getPurchaseOrderHistory(Integer pageNumber, Integer pageSize, String sortBy, String sortDirection) {
        return purchaseOrderSelector.selectByIdWithPagination(pageNumber, pageSize, sortBy, sortDirection);
    }
    
    public Integer getPurchaseOrderCount() {
        return purchaseOrderSelector.selectCount();
    }
    
    public String createPurchaseOrder(List<String> productIdList, List<String> quantityList) {
        try {
            // Input validation
            if (productIdList == null || quantityList == null || productIdList.size() != quantityList.size()) {
                return 'ERROR: Invalid input data';
            }
            
            // Convert to proper types
            Set<Id> productIds = new Set<Id>();
            Map<Id, Integer> productQuantityMap = new Map<Id, Integer>();
            
            for (Integer i = 0; i < productIdList.size(); i++) {
                Id prodId = productIdList[i];
                Integer qty = Integer.valueOf(quantityList[i]);
                productIds.add(prodId);
                productQuantityMap.put(prodId, qty);
            }
            
            // Get products
            List<Product2> products = productSelector.selectByIds(productIds);
            
            if (products.size() != productIdList.size()) {
                return 'ERROR: One or more products not found';
            }
            
            // Validate inventory availability
            this.validateInventoryAvailability(products, productQuantityMap);
            
            // Calculate total and prepare line items
            Decimal totalAmount = 0;
            List<PurchaseOrderLineItem__c> poLineItemsToInsert = new List<PurchaseOrderLineItem__c>();
            
            for (Product2 product : products) {
                Integer qty = productQuantityMap.get(product.Id);
                Decimal lineTotal = product.Price__c * qty;
                totalAmount += lineTotal;
                
                PurchaseOrderLineItem__c lineItem = new PurchaseOrderLineItem__c();
                lineItem.Product__c = product.Id;
                lineItem.Quantity__c = qty;
                lineItem.Unit_Price__c = product.Price__c;
                poLineItemsToInsert.add(lineItem);
            }
            
            // Create Purchase Order with generated order number
            PurchaseOrder__c po = new PurchaseOrder__c();
            po.Order_Date__c = Date.today();
            po.Total_Amount__c = totalAmount;
            po.Status__c = 'Placed';
            po.Order_Number__c = 'PO-' + String.valueOf(System.now().getTime());
            
            // Use Unit of Work for transaction management - now using local factory
            fflib_ISObjectUnitOfWork uow = unitOfWorkFactory.newInstance();
            
            uow.registerNew(po);     // work as a kind of insert operation
            
            // Register line items with relationship to PO
            for (PurchaseOrderLineItem__c item : poLineItemsToInsert) {
                uow.registerNew(item, PurchaseOrderLineItem__c.Purchase_Order__c, po);
            }
            
            // Update inventory quantities
            this.reduceInventory(products, productQuantityMap);
            uow.registerDirty(products);        // kind of update operation
            
            // Commit all changes
            uow.commitWork();
            
            return 'SUCCESS: Purchase Order created successfully with Order Number: ' + po.Order_Number__c;
            
        } catch (ShoppingCartException ex) {
            return 'ERROR: ' + ex.getMessage();
        } catch (Exception ex) {
            System.debug('Exception in createPurchaseOrder: ' + ex.getMessage());
            return 'ERROR: ' + ex.getMessage();
        }
    }
    
    public List<Product2> getProducts(Integer pageNumber, Integer pageSize, String searchTerm, String sortBy, String sortDirection) {
        return productSelector.selectActiveProductsWithPagination(pageNumber, pageSize, searchTerm, sortBy, sortDirection);
    }
    
    public Integer getProductCount(String searchTerm) {
        return productSelector.selectActiveProductCount(searchTerm);
    }
    
    public Product2 getProductById(Id productId) {
        return productSelector.selectById(productId);
    }
    
    // Private helper methods for business logic
    private void validateInventoryAvailability(List<Product2> products, Map<Id, Integer> productQuantityMap) {
        for (Product2 product : products) {
            Integer requestedQuantity = productQuantityMap.get(product.Id);
            if (requestedQuantity != null) {
                if (!product.IsActive) {
                    throw new ShoppingCartException('Product ' + product.Name + ' is inactive');
                }
                if (product.Available_Quantity__c < requestedQuantity) {
                    throw new ShoppingCartException('Product ' + product.Name + ' does not have enough stock');
                }
            }
        }
    }
    
    private void reduceInventory(List<Product2> products, Map<Id, Integer> productQuantityMap) {
        for (Product2 product : products) {
            Integer requestedQuantity = productQuantityMap.get(product.Id);
            if (requestedQuantity != null) {
                product.Available_Quantity__c -= requestedQuantity;
            }
        }
    }
    
    // Optional: Public methods to access the factories if needed by other classes
    public static fflib_Application.SelectorFactory getSelectorFactory() {
        return selectorFactory;
    }
    
    public static fflib_Application.UnitOfWorkFactory getUnitOfWorkFactory() {
        return unitOfWorkFactory;
    }
}


