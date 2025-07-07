import { LightningElement, track , wire} from 'lwc';
import getPurchaseOrderHistory from '@salesforce/apex/ShoppingCartController.getPurchaseOrderHistory';
import getPurchaseOrderCount from '@salesforce/apex/ShoppingCartController.getPurchaseOrderCount';
import getProducts from '@salesforce/apex/ShoppingCartController.getProducts';
import getProductCount from '@salesforce/apex/ShoppingCartController.getProductCount';
import createPurchaseOrder from '@salesforce/apex/ShoppingCartController.createPurchaseOrder';
import getProductById from '@salesforce/apex/ShoppingCartController.getProductById';

export default class ShoppingCart extends LightningElement {
    @track purchaseOrders = [];
    @track products = [];
    @track cartItems = [];
    @track searchTerm = '';
    
    // State management
    @track showPurchaseHistory = false;
    @track showProductSection = false;
    @track showCartSection = false;
    @track showSuccessMessage = false;
    @track isCheckoutMode = false;
    
    // Pagination for Purchase Orders
    @track currentPage = 1;
    @track totalPages = 1;
    @track totalRecords = 0;
    @track pageSize = 10;
    
    // Pagination for Products
    @track productCurrentPage = 1;
    @track productTotalPages = 1;
    @track productTotalRecords = 0;
    @track productPageSize = 10;
    
    // Sorting
    @track sortedBy = 'CreatedDate';
    @track sortedDirection = 'desc';
    @track productSortedBy = 'Name';
    @track productSortedDirection = 'asc';
    
    // Toast
    @track showToast = false;
    @track toastMessage = '';
    @track toastClass = '';
    
    @track successMessage = '';

    @track title = 'Shopping Cart';
    
    // Column definitions
    purchaseOrderColumns = [
        { label: 'Order Number', fieldName: 'Order_Number__c', type: 'text', sortable: true },
        { label: 'Order Date', fieldName: 'Order_Date__c', type: 'date', sortable: true },
        { label: 'Total Amount', fieldName: 'Total_Amount__c', type: 'currency', sortable: true },
        { label: 'Status', fieldName: 'Status__c', type: 'text', sortable: true }
    ];
    
    productColumns = [
        { label: 'Product Code', fieldName: 'Product_Code__c', type: 'text', sortable: true },
        { label: 'Product Name', fieldName: 'Name', type: 'text', sortable: true },
        { label: 'Available Quantity', fieldName: 'Available_Quantity__c', type: 'number', sortable: true },
        { label: 'Price', fieldName: 'Price__c', type: 'currency', sortable: true },
        {
            type: 'action',
            typeAttributes: {
                rowActions: [
                    { label: 'Add to Cart', name: 'add_to_cart' }
                ]
            }
        }
    ];
    
    cartColumns = [
        { label: 'Product Code', fieldName: 'productCode', type: 'text' },
        { label: 'Product Name', fieldName: 'productName', type: 'text' },
        { 
            label: 'Quantity', 
            fieldName: 'quantity', 
            type: 'number',
            editable: true,
            typeAttributes: { 
                minimumIntegerDigits: 1,
                maximumFractionDigits: 0
            }
        },
        { label: 'Unit Price', fieldName: 'price', type: 'currency' },
        { label: 'Total Price', fieldName: 'totalPrice', type: 'currency' },
        {
            type: 'action',
            typeAttributes: {
                rowActions: [
                    { label: 'Remove', name: 'remove_from_cart' }
                ]
            }
        }
    ];
    
    checkoutColumns = [
        { label: 'Product Code', fieldName: 'productCode', type: 'text' },
        { label: 'Product Name', fieldName: 'productName', type: 'text' },
        { label: 'Quantity', fieldName: 'quantity', type: 'number' },
        { label: 'Unit Price', fieldName: 'price', type: 'currency' },
        { label: 'Total Price', fieldName: 'totalPrice', type: 'currency' }
    ];
    
    connectedCallback() {
        try {
            console.log('Component connected');
            
            // Initialize arrays if they're undefined
            this.cartItems = this.cartItems || [];
            this.products = this.products || [];
            this.purchaseOrders = this.purchaseOrders || [];
            
            this.loadPurchaseOrderHistory();
        } catch (error) {
            console.error('Error in connectedCallback:', error);
            this.showToastMessage('Error initializing component: ' + error.message, 'error');
        }
    }
    
    async loadPurchaseOrderHistory() {
        try {
            const count = await getPurchaseOrderCount();
            if (count > 0) {
                this.showPurchaseHistory = true;
                this.totalRecords = count;
                this.totalPages = Math.ceil(count / this.pageSize);
                await this.loadPurchaseOrders();
            }
        } catch (error) {
            this.showToastMessage('Error loading purchase order history: ' + error.body.message, 'error');
        }
    }
    
    async loadPurchaseOrders() {
        try {
            const data = await getPurchaseOrderHistory({
                pageNumber: this.currentPage,
                pageSize: this.pageSize,
                sortBy: this.sortedBy,
                sortDirection: this.sortedDirection
            });
            this.purchaseOrders = data;
        } catch (error) {
            this.showToastMessage('Error loading purchase orders: ' + error.body.message, 'error');
        }
    }

    
    handleAddNewPurchaseOrder() {
        this.showProductSection = true;
        this.productCurrentPage = 1;
        this.loadProducts();
    }


    async loadProducts() {
        try {
            const count = await getProductCount({ searchTerm: this.searchTerm });
            this.productTotalRecords = count;
            this.productTotalPages = Math.ceil(count / this.productPageSize);
            
            const data = await getProducts({
                pageNumber: this.productCurrentPage,
                pageSize: this.productPageSize,
                searchTerm: this.searchTerm,
                sortBy: this.productSortedBy,
                sortDirection: this.productSortedDirection
            });

            this.products = data;
        } catch (error) {
            this.showToastMessage('Error loading products: ' + error.body.message, 'error');
        }
    }
    
    handleSearchChange(event) {
        this.searchTerm = event.target.value;
        this.productCurrentPage = 1;
        this.loadProducts();
    }
    
    handleSort(event) {
        this.sortedBy = event.detail.fieldName;
        this.sortedDirection = event.detail.sortDirection;
        this.loadPurchaseOrders();
    }
    
    handleProductSort(event) {
        this.productSortedBy = event.detail.fieldName;
        this.productSortedDirection = event.detail.sortDirection;
        this.loadProducts();
    }
    
    // Pagination handlers for Purchase Orders
    handlePreviousPage() {

        // pagination for the purchase order table
        if (this.currentPage > 1) {
            this.currentPage--;
            this.loadPurchaseOrders();
        }

        // PAGGINATION FOR THE PRODUCT TABLE        
        if (this.productCurrentPage > 1) {
            this.productCurrentPage--;
            this.loadProducts();
        }
    }
    
    handleNextPage() {

        // paggination for the purchase order table
        if (this.currentPage < this.totalPages) {
            this.currentPage++;
            this.loadPurchaseOrders();
        }

        // pagginatino for the product table
        if (this.productCurrentPage < this.productTotalPages) {
            this.productCurrentPage++;
            this.loadProducts();
        }
    }
 
    
    // Handle row actions for products table
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        
        if (actionName === 'add_to_cart') {
            this.addToCart(row);
        }


        if (actionName === 'remove_from_cart') {
            this.removeFromCart(row);
        }
    }
    
    
    addToCart(product) {
        try {
            // Validate product
            if (!product || !product.Id) {
                this.showToastMessage('Invalid product selected', 'error');
                return;
            }
            
            if (product.Available_Quantity__c <= 0) {
                this.showToastMessage('Product is out of stock', 'error');
                return;
            }
            
            // Create a deep copy of cartItems to avoid mutation issues
            let updatedCartItems = [...this.cartItems];
            
            // Check if product already exists in cart
            const existingItemIndex = updatedCartItems.findIndex(item => item.productId === product.Id);
            
            if (existingItemIndex !== -1) {
                // Check if we can add more quantity
                const existingItem = updatedCartItems[existingItemIndex];
                if (existingItem.quantity >= product.Available_Quantity__c) {
                    this.showToastMessage('Cannot add more quantity than available', 'error');
                    return;
                }
                
                // Update existing item
                updatedCartItems[existingItemIndex] = {
                    ...existingItem,
                    quantity: existingItem.quantity + 1,
                    totalPrice: (existingItem.quantity + 1) * existingItem.price
                };
            } else {
                // Add new item to cart
                const cartItem = {
                    productId: product.Id,
                    productName: product.Name,
                    productCode: product.Product_Code__c,
                    quantity: 1,
                    price: product.Price__c,
                    totalPrice: product.Price__c,
                    availableQuantity: product.Available_Quantity__c
                };

                updatedCartItems.push(cartItem);
            }
            
            // Update product quantity in the products list
            const updatedProducts = this.products.map(p => {
                if (p.Id === product.Id) {
                    return {
                        ...p,
                        Available_Quantity__c: p.Available_Quantity__c - 1
                    };
                }
                return p;
            });
            
            // Update both arrays at once
            this.products = updatedProducts;
            this.cartItems = updatedCartItems;
            this.showCartSection = true;
            this.showToastMessage('Product added to cart successfully', 'success');
            
        } catch (error) {
            console.error('Error in addToCart:', error);
            this.showToastMessage('Error adding product to cart: ' + error.message, 'error');
        }
    }

    
    removeFromCart(cartItem) {
        const index = this.cartItems.findIndex(item => item.productId === cartItem.productId);
        if (index !== -1) {
            // Add quantity back to product
            const productIndex = this.products.findIndex(p => p.Id === cartItem.productId);
            if (productIndex !== -1) {
                this.products[productIndex].Available_Quantity__c += cartItem.quantity;
                this.products = [...this.products];
            }
            
            this.cartItems.splice(index, 1);
            this.cartItems = [...this.cartItems];
            
            if (this.cartItems.length === 0) {
                this.showCartSection = false;
            }
            
            this.showToastMessage('Product removed from cart', 'success');
        }
    }
    

    // this is for the correcting the quantity of the product in the cart 
    handleCellChange(event) {
        try {
            // Extract draft values from the inline edit event
            const draftValues = event.detail.draftValues;
            
            // Early return if no draft values to process
            if (!draftValues || draftValues.length === 0) {
                return;
            }
            
            // Create copies of the arrays to avoid mutation issues
            // This ensures we don't accidentally modify the original arrays during processing
            let updatedCartItems = [...this.cartItems];
            let updatedProducts = [...this.products];
            
            // Flag to track if any validation errors occurred
            let hasErrors = false;
            
            // Process each draft value (edited cell)
            draftValues.forEach(draft => {
                // Find the corresponding cart item by product ID
                const cartItemIndex = updatedCartItems.findIndex(item => item.productId === draft.productId);
                
                // Get the cart item and parse the new quantity
                const cartItem = updatedCartItems[cartItemIndex];
                const newQuantity = parseInt(draft.quantity);
                
                // Validation: Check if quantity is a valid positive number
                if (isNaN(newQuantity) || newQuantity <= 0) {
                    this.showToastMessage('Quantity must be a positive number', 'error');
                    hasErrors = true;
                    return;
                }
                
                // Validation: Check if new quantity exceeds available inventory
                // availableQuantity + current quantity = total possible quantity for this item
                if (newQuantity > cartItem.availableQuantity + cartItem.quantity) {
                    this.showToastMessage('Cannot exceed available quantity', 'error');
                    hasErrors = true;
                    return;
                }
                
                // Calculate the difference between old and new quantities
                // Positive value means quantity decreased (inventory should increase)
                // Negative value means quantity increased (inventory should decrease)
                const quantityDifference = cartItem.quantity - newQuantity;
                
                // Update the corresponding product's available quantity
                const productIndex = updatedProducts.findIndex(p => p.Id === cartItem.productId);
                if (productIndex !== -1) {
                    updatedProducts[productIndex] = {
                        ...updatedProducts[productIndex],
                        // Add the quantity difference back to available stock
                        Available_Quantity__c: updatedProducts[productIndex].Available_Quantity__c + quantityDifference
                    };
                }
                
                // Update the cart item with new quantity and recalculated total price
                updatedCartItems[cartItemIndex] = {
                    ...cartItem,
                    quantity: newQuantity,
                    totalPrice: newQuantity * cartItem.price
                };
            });
            
            // Only commit the changes if no validation errors occurred
            if (!hasErrors) {
                this.products = updatedProducts;
                this.cartItems = updatedCartItems;
            }
            
            // Clear draft values from the data table to reset the inline edit state
            // Using setTimeout to avoid timing issues with the Lightning component lifecycle
            setTimeout(() => {
                const cartDataTable = this.template.querySelector('[data-id="cart-datatable"]');
                if (cartDataTable) {
                    cartDataTable.draftValues = [];
                }
            }, 0);
            
        } catch (error) {
            // Handle any unexpected errors during processing
            console.error('Error in handleCellChange:', error);
            this.showToastMessage('Error updating cart: ' + error.message, 'error');
        }
    }
    
    handleCheckout() {
        this.isCheckoutMode = true;
    }
    
    handleBackToCart() {
        this.isCheckoutMode = false;
    }

    
    async handlePlaceOrder() {
        try {
            const plainCartItems = JSON.parse(JSON.stringify(this.cartItems));
    
            const totalAmount = plainCartItems.reduce((sum, item) => sum + item.totalPrice, 0);
    
            console.log('Sending cartItems:', JSON.stringify(plainCartItems));
            console.log('totalAmount:', totalAmount);
            console.log('sendingggg' , JSON.stringify(plainCartItems, null , 2));
    
            const result = await createPurchaseOrder({
                cartItems: plainCartItems,
                totalAmount: totalAmount
            });
    
            // Success handling
            this.successMessage = result.replace('SUCCESS: ', '');
            this.showSuccessMessage = true;
            this.showProductSection = false;
            this.showCartSection = false;
            this.isCheckoutMode = false;
    
            this.cartItems = [];
            this.loadPurchaseOrderHistory();
    
        } catch (error) {
            console.error(error);
            this.showToastMessage('Error placing order: ' + error.body?.message || error.message, 'error');
        }
    }
    
    handleStartNewOrder() {
        this.showSuccessMessage = false;
        this.showProductSection = true;
        this.productCurrentPage = 1;
        this.searchTerm = '';
        this.loadProducts();
        this.loadPurchaseOrderHistory();
    }
    
    showToastMessage(message, type) {
        this.toastMessage = message;
        this.toastClass = `slds-notify slds-notify_toast slds-theme_${type}`;
        this.showToast = true;
        
        setTimeout(() => {
            this.showToast = false;
        }, 3000);
    }
    
    // Computed properties
    get isFirstPage() {
        return this.currentPage === 1;
    }
    
    get isLastPage() {
        return this.currentPage === this.totalPages;
    }
    
    get isProductFirstPage() {
        return this.productCurrentPage === 1;
    }
    
    get isProductLastPage() {
        return this.productCurrentPage === this.productTotalPages;
    }
    
    get totalAmount() {
        return this.cartItems.reduce((total, item) => total + item.totalPrice, 0);
    }
    
    get isCartEmpty() {
        return this.cartItems.length === 0;
    }
}