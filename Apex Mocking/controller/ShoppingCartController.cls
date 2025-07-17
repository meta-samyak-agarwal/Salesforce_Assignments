public with sharing class ShoppingCartController {
    
    @TestVisible
    private static IShoppingCartService shoppingCartService {
        get {
            if (shoppingCartService == null) {
                shoppingCartService = new ShoppingCartService();
            }
            return shoppingCartService;
        }
        set;
    }
    
    @AuraEnabled()
    public static List<PurchaseOrder__c> getPurchaseOrderHistory(Integer pageNumber, Integer pageSize, String sortBy, String sortDirection) {
        return shoppingCartService.getPurchaseOrderHistory(pageNumber, pageSize, sortBy, sortDirection);
    }
    
    @AuraEnabled
    public static Integer getPurchaseOrderCount() {
        return shoppingCartService.getPurchaseOrderCount();
    }
    
    @AuraEnabled
    public static String createPurchaseOrder(List<String> productIdList, List<String> quantityList) {
        return shoppingCartService.createPurchaseOrder(productIdList, quantityList);
    }
    
    @AuraEnabled
    public static List<Product2> getProducts(Integer pageNumber, Integer pageSize, String searchTerm, String sortBy, String sortDirection) {
        return shoppingCartService.getProducts(pageNumber, pageSize, searchTerm, sortBy, sortDirection);
    }
    
    @AuraEnabled(cacheable=true)
    public static Integer getProductCount(String searchTerm) {
        return shoppingCartService.getProductCount(searchTerm);
    }
    
    @AuraEnabled(cacheable=true)
    public static Product2 getProductById(Id productId) {
        return shoppingCartService.getProductById(productId);
    }
}