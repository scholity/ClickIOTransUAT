public class UpdateContactRecord {  
    //Method to update Contact record with extra information  

    @InvocableMethod
    public static void updateContacts(List<Id> contactIds)
    {
        System.debug('contactIds==='+contactIds);                    
        UpdateContactByQueue testUpdate = new UpdateContactByQueue(contactIds);  
        ID jobID = System.enqueueJob(testUpdate);      
    }
}