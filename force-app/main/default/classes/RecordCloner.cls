public with sharing class RecordCloner {
	
	@AuraEnabled
	public static String getStringFields(String recordId) {
		String result = '';
		List<String> objectFields = new List<String>();
        Map<String, Schema.SObjectType> describeMap = Schema.getGlobalDescribe(); // iterate objects to find the object which has keyPrefix
        String keyPrefix = recordId.substring(0,3); // left 3 symbols of record ID
        String objectType = ''; // SObject API Name
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
            objectFields.add(field.getFieldPath());
            System.debug('field: ' + field.getFieldPath());
        }

		String queryFields = String.join(objectFields, ',');
        queryExpression += '' + queryFields + ' FROM ' + objectType + ' WHERE Id =: recordId';
        System.debug('queryExpression: ' + queryExpression);

		SObject currentObject = Database.query(queryExpression);
        
		for(String field : objectFields) {
			String value = (String)currentObject.get(field);

			if(value != null) {
                result += '\'' + field + '\' : \'' + value + '\' , ';
			}

            System.debug('field: ' + field);
            System.debug('value: ' + value);
		}

        result += '\'External_Id__c\' : \'' + recordId + '\'';
        System.debug('result: ' + result);

		return result;
	}

    // get fieldset Invoice_Fields of Invoice__c object
    public static List<Schema.FieldSetMember> getInvoiceFields() {
        return SObjectType.Invoice__c.FieldSets.Invoice_Fields.getFields();
    }
}