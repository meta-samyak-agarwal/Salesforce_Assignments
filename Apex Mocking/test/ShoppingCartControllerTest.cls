@IsTest
private class ShoppingCartControllerTest {

    @IsTest      
    static void test_getPurchaseOrderHistory() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IShoppingCartService mockService = (IShoppingCartService) mocks.mock(IShoppingCartService.class);

        List<PurchaseOrder__c> mockOrders = new List<PurchaseOrder__c>{
            new PurchaseOrder__c(), new PurchaseOrder__c()
        };

        mocks.startStubbing();
        mocks.when(mockService.getPurchaseOrderHistory(1, 10, 'Order_Date__c', 'DESC')).thenReturn(mockOrders);
        mocks.stopStubbing();

        ShoppingCartController.shoppingCartService = mockService;

        Test.startTest();
        List<PurchaseOrder__c> result = ShoppingCartController.getPurchaseOrderHistory(1, 10, 'Order_Date__c', 'DESC');
        Test.stopTest();

        System.assertEquals(2, result.size(), 'Should return two purchase orders');
        ((IShoppingCartService)mocks.verify(mockService, 1)).getPurchaseOrderHistory(1, 10, 'Order_Date__c', 'DESC');
    }

    @IsTest
    static void test_getPurchaseOrderCount() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IShoppingCartService mockService = (IShoppingCartService) mocks.mock(IShoppingCartService.class);

        mocks.startStubbing();
        mocks.when(mockService.getPurchaseOrderCount()).thenReturn(5);
        mocks.stopStubbing();

        ShoppingCartController.shoppingCartService = mockService;

        Test.startTest();
        Integer result = ShoppingCartController.getPurchaseOrderCount();
        Test.stopTest();

        System.assertEquals(5, result, 'Should return correct order count');
        ((IShoppingCartService) mocks.verify(mockService, 1)).getPurchaseOrderCount();
    }

    @IsTest
    static void test_createPurchaseOrder_success() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IShoppingCartService mockService = (IShoppingCartService) mocks.mock(IShoppingCartService.class);

        List<String> productIds = new List<String>{'01tXXXXXXXXX001', '01tXXXXXXXXX002'};
        List<String> quantities = new List<String>{'2', '3'};

        String expectedMessage = 'SUCCESS: Purchase Order created successfully with Order Number: PO-123456';

        mocks.startStubbing();
        mocks.when(mockService.createPurchaseOrder(productIds, quantities)).thenReturn(expectedMessage);
        mocks.stopStubbing();

        ShoppingCartController.shoppingCartService = mockService;

        Test.startTest();
        String result = ShoppingCartController.createPurchaseOrder(productIds, quantities);
        Test.stopTest();

        System.assertEquals(expectedMessage, result, 'Should return success message');
        ((IShoppingCartService) mocks.verify(mockService, 1)).createPurchaseOrder(productIds, quantities);
    }

    @IsTest
    static void test_getProducts_returnsProducts() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IShoppingCartService mockService = (IShoppingCartService) mocks.mock(IShoppingCartService.class);

        List<Product2> mockProducts = new List<Product2>{
            new Product2(Name='Product A'),
            new Product2(Name='Product B')
        };

        mocks.startStubbing();
        mocks.when(mockService.getProducts(1, 10, '', 'Name', 'ASC')).thenReturn(mockProducts);
        mocks.stopStubbing();

        ShoppingCartController.shoppingCartService = mockService;

        Test.startTest();
        List<Product2> result = ShoppingCartController.getProducts(1, 10, '', 'Name', 'ASC');
        Test.stopTest();

        System.assertEquals(2, result.size(), 'Should return two products');
        ((IShoppingCartService) mocks.verify(mockService, 1)).getProducts(1, 10, '', 'Name', 'ASC');
    }

    @IsTest
    static void test_getProductCount_withSearchTerm() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IShoppingCartService mockService = (IShoppingCartService) mocks.mock(IShoppingCartService.class);

        mocks.startStubbing();
        mocks.when(mockService.getProductCount('milk')).thenReturn(3);
        mocks.stopStubbing();

        ShoppingCartController.shoppingCartService = mockService;

        Test.startTest();
        Integer result = ShoppingCartController.getProductCount('milk');
        Test.stopTest();

        System.assertEquals(3, result, 'Should return product count for search');
        ((IShoppingCartService) mocks.verify(mockService, 1)).getProductCount('milk');
    }

    @IsTest
    static void test_getProductById_returnsProduct() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IShoppingCartService mockService = (IShoppingCartService) mocks.mock(IShoppingCartService.class);

        Id productId = fflib_IDGenerator.generate(Product2.getSObjectType());
        Product2 mockProduct = new Product2(Id=productId, Name='Test Product');

        mocks.startStubbing();
        mocks.when(mockService.getProductById(productId)).thenReturn(mockProduct);
        mocks.stopStubbing();

        ShoppingCartController.shoppingCartService = mockService;

        Test.startTest();
        Product2 result = ShoppingCartController.getProductById(productId);
        Test.stopTest();

        System.assertEquals('Test Product', result.Name, 'Should return correct product');
        ((IShoppingCartService) mocks.verify(mockService, 1)).getProductById(productId);
    }
}