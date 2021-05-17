public class RecordDeepCloner {
    private static RecordDeepClonerSource source = new RecordDeepClonerSource();
    
    @AuraEnabled
    public static String doClone(String recordId) {
        String newId = source.doClone(recordId);
        return newId;
    }
}