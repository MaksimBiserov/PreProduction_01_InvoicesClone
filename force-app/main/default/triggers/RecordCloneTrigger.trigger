trigger RecordCloneTrigger on Invoice__c (after insert) {
    if (Trigger.isInsert && Trigger.isAfter) {
        RecordCloneTriggerHandler.onAfterInsert(Trigger.new);
    }
}