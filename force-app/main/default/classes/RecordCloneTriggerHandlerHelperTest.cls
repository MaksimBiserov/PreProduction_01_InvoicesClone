@isTest
private class RecordCloneTriggerHandlerHelperTest {
    @isTest
    static void testDeepClone() {
        
        Invoice__c invoice = new Invoice__c(Client_Name__c = 'Client name 1', IsDeepClone__c = false);
        insert invoice;

        List<Invoice_Item__c> items = new List<Invoice_Item__c>();

        for(Integer i = 0; i < 3; i++) {
            Invoice_Item__c item = new Invoice_Item__c(
                Invoice__c = invoice.Id,
                Name = 'Item ' + i + ' for invoice',
                Unit_cost__c = 2.00,
                Quantity__c = 2
            );

            items.add(item);
        }
        
        insert items;

        Invoice__c copiedInvoice = new Invoice__c(Client_Name__c = 'Client name 2',
                                                  IsDeepClone__c = true,
                                                  External_Id__c = invoice.Id);

        insert copiedInvoice;

        List<Invoice_Item__c> resultItems = [SELECT Id,
                                                    Name,
                                                    Invoice__c,
                                                    Unit_cost__c,
                                                    Quantity__c
                                             FROM   Invoice_Item__c
                                             WHERE  Invoice__c =: copiedInvoice.Id];

        System.assertEquals(items.size(), resultItems.size());

        for(Invoice_Item__c resultItem : resultItems) {
            System.assertEquals(resultItem.Name.contains('for invoice'), true);
            System.assertEquals(resultItem.Unit_cost__c, 2.00);
            System.assertEquals(resultItem.Quantity__c, 2);
        }

        System.debug('Message from testDeepClone. items: ' + items);
        System.debug('Message from testDeepClone. resultItems: ' + resultItems);
        System.debug('Message from testDeepClone. items.size(): ' + items.size());
        System.debug('Message from testDeepClone. resultItems.size(): ' + resultItems.size());
    }
}