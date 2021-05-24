public with sharing class RecordCloneTriggerHandlerHelper {
    public static void deepClone(List<Invoice__c> newObjects) {
        
        Map <String, Schema.SObjectType> describeMap = Schema.getGlobalDescribe();
        String externalId = '';
        Set<String> querySObject = new Set<String>();
        String queryExpression = 'SELECT ';

        for(Schema.FieldSetMember field : getInvoiceFields()) { // get elements of FieldSet
            queryExpression += '' + field.getFieldPath() + ', ';
            System.debug('field: ' + field.getFieldPath());
        }
        
        for(Invoice__c newObject : newObjects) {
            if(newObject.IsDeepClone__c == true && newObject.External_Id__c != null) {
                externalId = newObject.External_Id__c;
                System.debug('externalId: ' + externalId);

                Invoice__c sourceObject = [SELECT Id, Name FROM Invoice__c WHERE Id =: externalId][0];
                System.debug('sourceObject: ' + sourceObject);

                getTypesFromMdt(querySObject);
                System.debug('querySObject: ' + querySObject);

                Map<String,String> parentMap = new Map<String, String>();
                Map<String,String> childMap = new Map<String, String>();

                Schema.DescribeSObjectResult describeObject = Schema.SObjectType.Invoice__c;
                System.debug('describeObject: ' + describeObject);

                for (Schema.ChildRelationship cr: describeObject.getChildRelationships()) {
                    if(cr.getField().getDescribe().isAccessible() &&
                    cr.getField().getDescribe().isCreateable() &&
                    cr.getRelationshipName() != null) {
                        if(querySobject.contains('' + cr.getChildSObject())) {
                            parentMap.put('' + cr.getChildSObject(), '' + cr.getRelationshipName());
                            childMap.put('' + cr.getRelationshipName(), '' + cr.getField());
                        }
                    }
                }

                System.debug('parentMap: ' + parentMap);
                System.debug('childMap: ' + childMap);

                List<String> subQueries = doSubqueries(parentMap, describeMap);
                String lotSubQueries = '';

                for(String subQuery : subQueries) { // get sub query
                    lotSubQueries += '' + subQuery + ', ';
                }

                lotSubQueries = lotSubQueries.removeEnd(', ');
                System.debug('lotSubQueries: ' + lotSubQueries);

                queryExpression += lotSubQueries + ' FROM Invoice__c WHERE Id = \'' + sourceObject.Id + '\'';
                System.debug('queryExpression of Helper: ' + queryExpression);
                
                List<SObject> parentItems = Database.query(queryExpression);
                SObject parentItem = parentItems[0];
                System.debug('parentItem: ' + parentItem);

                List<SObject> childItems = cloneChildren(parentItem, newObject, parentMap, childMap);
                insert childItems;

                for(SObject childItem : childItems) {
                    System.debug('childItem: ' + childItem);
                }
            }
        } 
    }

    public static void getTypesFromMdt(Set<String> querySObject) {
        for(Clone_Objects__mdt mdt : [SELECT Id, DeveloperName, Label, API_Name__c
                                      FROM Clone_Objects__mdt]) {
                                        querySobject.add(mdt.API_Name__c);
                                      }
    }

    private static List<String> doSubqueries(Map<String, String> childItems,
                                      Map<String, Schema.SObjectType> describeMap) {

        List<String> subQueries = new List<String>();
        String fieldsQuery = '';

        for(String childItem : childItems.keySet()) {
            List<String> childFields = new List<String>();
            Map<String, Schema.SObjectField> fieldMap = describeMap.get(childItem).
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
            System.debug('fieldsQuery: ' + fieldsQuery);

            if(!childFields.isEmpty()) {
                String queryExpression = ' (SELECT ' + fieldsQuery +
                                         ' FROM ' + childItems.get(childItem) + ')';
                subQueries.add(queryExpression);
            }
        }

        System.debug('subQueries: ' + subQueries);
        return subQueries;
    }

    private static List<sObject> cloneChildren(SObject parent, SObject child,
                                        Map<String, String> childMap,
                                        Map<String, String> childMap1) {
        
        List<SObject> childItems = new List<SObject>();

        for (String childItem : childMap.values()) {
            List<SObject> parentItems = parent.getSObjects(childItem);
            System.debug('parentItems: ' + parentItems);

            if (parentItems != null) {
                List<SObject> records = parentItems.deepClone();
                System.debug('records: ' + records);

                for (SObject record : records) {
                    record.put(childMap1.get(childItem), child.Id);
                }

                childItems.addAll(records);
            }
        }

        return childItems;
    }

    public static List<Schema.FieldSetMember> getInvoiceFields() {
        return SObjectType.Invoice__c.FieldSets.Invoice_Fields.getFields();
    }
}