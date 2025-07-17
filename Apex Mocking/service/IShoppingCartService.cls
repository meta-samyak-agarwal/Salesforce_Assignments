public interface IShoppingCartService {
    List<PurchaseOrder__c> getPurchaseOrderHistory(Integer pageNumber, Integer pageSize, String sortBy, String sortDirection);
    Integer getPurchaseOrderCount();
    String createPurchaseOrder(List<String> productIdList, List<String> quantityList);
    List<Product2> getProducts(Integer pageNumber, Integer pageSize, String searchTerm, String sortBy, String sortDirection);
    Integer getProductCount(String searchTerm);
    Product2 getProductById(Id productId);
}