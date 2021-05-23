public with sharing class RecordCloneTriggerHandler {
    public static void onAfterInsert(List<Invoice__c> newObjects) {
        RecordCloneTriggerHandlerHelper.deepClone(newObjects);
    }
}