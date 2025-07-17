public inherited sharing class PurchaseOrderLineItemSelector extends fflib_SObjectSelector {
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            PurchaseOrderLineItem__c.Id,
            PurchaseOrderLineItem__c.Purchase_Order__c,
            PurchaseOrderLineItem__c.Product__c,
            PurchaseOrderLineItem__c.Quantity__c,
            PurchaseOrderLineItem__c.Unit_Price__c
        };
    }
    
    public Schema.SObjectType getSObjectType() {
        return PurchaseOrderLineItem__c.sObjectType;
    }
}