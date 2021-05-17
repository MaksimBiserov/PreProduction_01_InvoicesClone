public class RecordDeepClonerSource {

    public Id doClone(String recordId) {
        Map <String, Schema.SObjectType> describeMap = Schema.getGlobalDescribe(); // iterate objects to find the object which has keyPrefix
        String keyPrefix = recordId.substring(0,3); // left 3 symbols of record ID
        String objectType = ''; // SObject API Name
        Set<String> objectFields = new Set<String>();
        String queryExpression = 'SELECT ';
        Set<String> querySObject = new Set<String>();

        System.debug('recordId: ' + recordId);
        System.debug('keyPrefix: ' + keyPrefix);

        for(Schema.SObjectType describe : describeMap.Values()) { // get Object Type
            String prefix = describe.getDescribe().getKeyPrefix();

            if(prefix == keyPrefix) {
                objectType = describe.getDescribe().getName();
                break;
            }
        }

        // get all fields
        // objectFields = describeMap.get(objectType).getDescribe().fields.getMap().keySet();

        for(Schema.FieldSetMember field : getInvoiceFields()) { // get elements of FieldSet
            queryExpression += '' + field.getFieldPath() + ', ';
            System.debug('field: ' + field.getFieldPath());
        }
        
        SObjectType sObjType = Schema.getGlobalDescribe().get(objectType); 
        DescribeSObjectResult describeObject = sObjType.getDescribe();
        System.debug('sObjType: ' + sObjType);
        System.debug('describeObject: ' + describeObject);
        Map<String,String> parentMap = new Map<String, String>();
        Map<String,String> childMap = new Map<String, String>();

        for(Clone_Objects__mdt mdt : [SELECT Id, DeveloperName, Label, API_Name__c 
                                      FROM Clone_Objects__mdt]) {
                                        querySobject.add(mdt.API_Name__c);
                                      }
        
        for (Schema.ChildRelationship cr: describeObject.getChildRelationships()) 
        {
            if(cr.getField().getDescribe().isAccessible() &&
               cr.getField().getDescribe().isCreateable() &&
               cr.getRelationshipName()!=null) {
                if(querySobject.contains('' + cr.getChildSObject())) {
                    parentMap.put('' + cr.getChildSObject(), '' + cr.getRelationshipName());
                    childMap.put('' + cr.getRelationshipName(), '' + cr.getField());
                }
            }
        } 
        
        List<String> subQueries = doSubqueries(parentMap, describeMap);
        String lotSubQueries = '';

        for(String subQuery : subQueries) { // get sub query
            lotSubQueries += '' + subQuery + ', ';
        }

        lotSubQueries = lotSubQueries.removeEnd(', ');

        queryExpression += lotSubQueries + ' FROM ' + objectType + ' WHERE Id = \'' + recordId + '\'';
        System.debug('queryExpression of RecordDeepClonerSource: ' + queryExpression);
        
        List<Sobject> parentObj = Database.query(queryExpression);
        Sobject parentRecord = parentObj[0];
        
        Sobject newRecord = parentRecord.clone();
        insert newRecord;
        List<sObject> childObjects = cloneChildren(parentRecord, newRecord, parentMap  ,childMap);
        insert childObjects;
        System.debug('newRecord ID: ' + newRecord.Id);
        return newRecord.Id;
    }
    
    private List<String> doSubqueries(Map<String, String> childObjects,
                                      Map<String, Schema.SObjectType> describeMap) {

        List<String> subQueries = new List<String>();
        String fieldsQuery = '';

        for(String childObject : childObjects.keySet()) {
            List<String> childFields = new List<String>();
            Map<String, Schema.SObjectField> fieldMap = describeMap.get(childObject).
                                                        getDescribe().fields.getMap();
            System.debug('fieldMap: ' + fieldMap);

            for(Schema.SObjectField sof : fieldMap.values()) {
                DescribeFieldResult dfr = sof.getDescribe();

                if(dfr.isCreateable()) {
                    childFields.add(dfr.getName());
                }
            }

            for(String childField : childFields) { // get child fields
                fieldsQuery += '' + childField + ', ';
            }

            fieldsQuery = fieldsQuery.removeEnd(', ');

            if(!childFields.isEmpty()) {
                String queryExpression = ' (SELECT ' + fieldsQuery +
                                         ' FROM ' + childObjects.get(childObject) + ')';
                subQueries.add(queryExpression);
            }
        }

        return subQueries;
    }

    private List<sObject> cloneChildren(Sobject parent, Sobject child,
                                        Map<String, String> childMap,
                                        Map<String, String> childMap1) {
        
        List<SObject> childObjects = new List<SObject>();

        for (String childObject : childMap.values()) {
            List<SObject> parentRecords = parent.getSObjects(childObject);
            System.debug('parentRecords: ' + parentRecords);

            if (parentRecords != null) {
                List<SObject> records = parentRecords.deepClone();
                System.debug('records: ' + records);

                for (SObject record : records) {
                    record.put(childMap1.get(childObject), child.Id);
                }

                childObjects.addAll(records);
            }
        }

        return childObjects;
    }

    public static List<Schema.FieldSetMember> getInvoiceFields() {
        return SObjectType.Invoice__c.FieldSets.Invoice_Fields.getFields();
    }
}