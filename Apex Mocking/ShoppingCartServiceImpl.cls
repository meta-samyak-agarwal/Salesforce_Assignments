public class ShoppingCartServiceImpl implements IShoppingCartService {
    private IPurchaseOrderService purchaseOrderService;
    private IProductService productService;
    
    public ShoppingCartServiceImpl() {
        this.purchaseOrderService = (IPurchaseOrderService) Application.Service.newInstance(IPurchaseOrderService.class);
        this.productService = (IProductService) Application.Service.newInstance(IProductService.class);
    }
    
    public List<PurchaseOrder__c> getPurchaseOrderHistory(Integer pageNumber, Integer pageSize, String sortBy, String sortDirection) {
        return purchaseOrderService.getPurchaseOrderHistory(pageNumber, pageSize, sortBy, sortDirection);
    }
    
    public Integer getPurchaseOrderCount() {
        return purchaseOrderService.getPurchaseOrderCount();
    }
    
    public String createPurchaseOrder(List<String> productIdList, List<String> quantityList) {
        try {
            if (productIdList == null || quantityList == null || productIdList.size() != quantityList.size()) {
                return 'ERROR: Invalid input data';
            }
            
            List<OrderLineItem> lineItems = new List<OrderLineItem>();
            for (Integer i = 0; i < productIdList.size(); i++) {
                lineItems.add(new OrderLineItem(productIdList[i], Integer.valueOf(quantityList[i])));
            }
            
            return purchaseOrderService.createPurchaseOrder(lineItems);
            
        } catch (Exception ex) {
            return 'ERROR: ' + ex.getMessage();
        }
    }
}