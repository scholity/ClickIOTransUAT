@isTest
private class UpdateContactByQueueTest{
    static testMethod void test()
    {   
        Bucket_Account_Settings__c bas = new Bucket_Account_Settings__c();
        bas.Bucket_Account_Owner_ID__c ='005d0000001WOeV';
        bas.Bucket_Account_RecordTypeID__c = '012d000000098Wt';
        bas.Default_Bucket_Name__c = 'Bucket Account';
        bas.Maximum_Size_of_Bucket__c = 5000;
        insert bas;             
        
        User currUser = [select Id from User where Id = :UserInfo.getUserId()];
        System.runAs(currUser){
            Set<String> customerUserTypes = new Set<String> {'CSPLiteUser', 'PowerPartner', 'PowerCustomerSuccess',   'CustomerSuccess'};
            Account acc1 = new Account (
            Name = 'newAcc1'
            );  
            insert acc1;
            
            Contact con = new Contact (
            AccountId = acc1.id,
            LastName = 'portalTestUserv1'
            );
            insert con;
            
            Profile prfile = [select Id,name from Profile where UserType in :customerUserTypes limit 1];

            User newUser1 = new User(
            profileId = prfile.id,
            username = 'newUser@yahoo.com',
            email = 'pb@f.com',
            emailencodingkey = 'UTF-8',
            localesidkey = 'en_US',
            languagelocalekey = 'en_US',
            timezonesidkey = 'America/Los_Angeles',
            alias='nuser',
            lastname='lastname',
            contactId = con.id
            );
            insert newUser1;    
            
            List<Id> contactList = new List<Id>();
            contactList.add(con.Id);
            
            Test.startTest();
            UpdateContactByQueue updateCont = new UpdateContactByQueue(contactList);        
            ID jobID = System.enqueueJob(updateCont);
            Test.stopTest();    
        }
    }
}