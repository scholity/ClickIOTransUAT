@isTest
private class ContactHandlerTest{
    static testMethod void testMyInvocableMethod()
    {               
        Bucket_Account_Settings__c bas = new Bucket_Account_Settings__c();
        bas.Bucket_Account_Owner_ID__c ='005d0000001WOeV';
        bas.Bucket_Account_RecordTypeID__c = '012d000000098Wt';
        bas.Default_Bucket_Name__c = 'Bucket Account';
        bas.Maximum_Size_of_Bucket__c = 5000;
        insert bas;
        
        Set<String> customerUserTypes = new Set<String> {'CSPLiteUser', 'PowerPartner', 'PowerCustomerSuccess',   'CustomerSuccess'};
                        
        Account acc = new Account (
        Name = 'newAcc1'
        );  
        insert acc;
        Contact con = new Contact (
        AccountId = acc.id,
        //AccountId = null,
        LastName = 'portalTestUser'
        );
        insert con;
        Profile p = [select Id,name from Profile where UserType in :customerUserTypes limit 1];
         
        User newUser = new User(
        profileId = p.id,
        username = 'newUser@yahoo.com',
        email = 'pb@ff.com',
        emailencodingkey = 'UTF-8',
        localesidkey = 'en_US',
        languagelocalekey = 'en_US',
        timezonesidkey = 'America/Los_Angeles',
        alias='nuser',
        lastname='lastname',
        contactId = con.id
        );
        insert newUser;
        ContactHandler.inflateTest();
    }
}