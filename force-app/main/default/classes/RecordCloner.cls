public with sharing class RecordCloner {

    @AuraEnabled
    public static String cloneSObject(String recordId) {
        Map<String, Schema.SObjectType> describeMap = Schema.getGlobalDescribe(); // iterate objects to find the object which has keyPrefix
        String keyPrefix = recordId.substring(0,3); // left 3 symbols of record ID
        String objectType = ''; // SObject API Name
        Set<String> objectFields = new Set<String>();
        String queryExpression = 'SELECT ';

        System.debug('recordId: ' + recordId);
        System.debug('keyPrefix: ' + keyPrefix);

        for(Schema.SObjectType describe : describeMap.Values()) { // get Object Type
            String prefix = describe.getDescribe().getKeyPrefix();

            if(prefix == keyPrefix) {
                objectType = describe.getDescribe().getName();
                break;
            }
        }

        System.debug('objectType: ' + objectType);

        for(Schema.FieldSetMember field : getInvoiceFields()) { // get elements of FieldSet
            queryExpression += '' + field.getFieldPath() + ', ';
            System.debug('field: ' + field.getFieldPath());
        }

        queryExpression = queryExpression.removeEnd(', ');
        queryExpression += ' FROM ' + objectType + ' WHERE Id = \'' + recordId + '\'';

        System.debug('queryExpression: ' + queryExpression);

        SObject sourceObject = Database.query(queryExpression);
        System.debug('sourceObject: ' + sourceObject);

        SObject newObject = sourceObject.clone(false, false, false, false); // clone without details
        System.debug('newObject: ' + newObject);

        insert newObject;
        return newObject.Id;
    }

    // get fieldset Invoice_Fields of Invoice__c object
    public static List<Schema.FieldSetMember> getInvoiceFields() {
        return SObjectType.Invoice__c.FieldSets.Invoice_Fields.getFields();
    }
}