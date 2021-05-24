@isTest
private class RecordClonerTest {
    @isTest
    static void testGetStringFields() {
        Invoice__c invoice = new Invoice__c(Client_Adress__c = 'Client Adress',
                                            Client_City__c = 'Client City',
                                            Client_Country__c = 'Client Country',
                                            Client_Name__c = 'Client name',
                                            Client_ZIP__c = 'Client ZIP',
                                            Consignee_Adress__c = 'Consignee Adress',
                                            Consignee_City__c = 'Consignee City',
                                            Consignee_Country__c = 'Consignee Country',
                                            Consignee_Name__c = 'Consignee Name',
                                            Consignee_ZIP__c = 'Consignee ZIP');
        insert invoice;

        String methodResult = RecordCloner.getStringFields(invoice.Id);
        String stringResult = '\'Client_Adress__c\' : \'Client Adress\' , ' +
                              '\'Client_City__c\' : \'Client City\' , ' +
                              '\'Client_Country__c\' : \'Client Country\' , ' +
                              '\'Client_Name__c\' : \'Client name\' , ' +
                              '\'Client_ZIP__c\' : \'Client ZIP\' , ' +
                              '\'Consignee_Adress__c\' : \'Consignee Adress\' , ' +
                              '\'Consignee_City__c\' : \'Consignee City\' , ' +
                              '\'Consignee_Country__c\' : \'Consignee Country\' , ' +
                              '\'Consignee_Name__c\' : \'Consignee Name\' , ' +
                              '\'Consignee_ZIP__c\' : \'Consignee ZIP\' , ' +
                              '\'External_Id__c\' : \'' + invoice.Id + '\'';

        System.assertEquals(methodResult, stringResult);
    }

    @isTest
    static void testGetInvoiceFields() {
        String lotOfFields = '';
        List<Schema.FieldSetMember> fieldsetList = RecordCloner.getInvoiceFields();
        
        System.assertEquals(fieldsetList.size(), 10);

        for(Schema.FieldSetMember field : fieldsetList) {
            lotOfFields += field.getFieldPath() + ',';
        }

        System.assertEquals(lotOfFields.contains('Client_Adress__c'), true);
        System.assertEquals(lotOfFields.contains('Client_City__c'), true);
        System.assertEquals(lotOfFields.contains('Client_Country__c'), true);
        System.assertEquals(lotOfFields.contains('Client_Name__c'), true);
        System.assertEquals(lotOfFields.contains('Client_ZIP__c'), true);
        System.assertEquals(lotOfFields.contains('Consignee_Adress__c'), true);
        System.assertEquals(lotOfFields.contains('Consignee_City__c'), true);
        System.assertEquals(lotOfFields.contains('Consignee_Country__c'), true);
        System.assertEquals(lotOfFields.contains('Consignee_Name__c'), true);
        System.assertEquals(lotOfFields.contains('Consignee_ZIP__c'), true);
    }
}