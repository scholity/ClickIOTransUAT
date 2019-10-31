public without sharing class AccountAffiliationController
{
    @AuraEnabled
    public static List<AccountContactRelationWrapper> getAccountContactDetails() 
    {
        List<AccountContactRelationWrapper> accountContactForUser = new List<AccountContactRelationWrapper>();
        User usr = [SELECT id, ContactId, Name, Profile.Name, Profile.UserLicense.Name FROM User WHERE id =: UserInfo.getUserId()];
        String sQuery = '';
        sQuery =  'Select id, AccountId, Account.Name, Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingPostalCode, Account.BillingCountry, Roles From AccountContactRelation WHERE ContactId = \'' +usr.ContactId+'\' AND Roles includes(\'Instructor\', \'Administrator\')';
        List<AccountContactRelation> accountContactRelationsList = (List<AccountContactRelation>)Database.query(sQuery);
        for(AccountContactRelation indAccConRec : accountContactRelationsList)
        {
            AccountContactRelationWrapper indAccConWrapper = new AccountContactRelationWrapper();
            //Set Values
            indAccConWrapper.isChecked = false;
            indAccConWrapper.recordId = indAccConRec.Id;
            indAccConWrapper.accountName = indAccConRec.Account.Name;
            indAccConWrapper.contactRole = indAccConRec.Roles;
            
            LocationWrapper accountLocation = new LocationWrapper();
            if(indAccConRec.AccountId != null)
            {
                accountLocation.city        = indAccConRec.Account.BillingCity;
                accountLocation.address1    = indAccConRec.Account.BillingStreet;
                accountLocation.country     = indAccConRec.Account.BillingCountry;
                accountLocation.province    = indAccConRec.Account.BillingState;
                accountLocation.postalCode  = indAccConRec.Account.BillingPostalCode;
            }
            indAccConWrapper.accountBillingDetails = accountLocation;
            accountContactForUser.add(indAccConWrapper);
        }
        system.debug('accountContactForUser:::'+accountContactForUser);
        return accountContactForUser;
    }
    
    @AuraEnabled
    public static List<AccountContactRelationWrapper> removeAccountContactDetails(String AccountContactRelationWrapperString) 
    {
        List<String> accountsRemoved = new List<String>();
        List<AccountContactRelationWrapper> nonSelectedAccConRelations = new List<AccountContactRelationWrapper>();
        List<AccountContactRelationWrapper> ACRWrapperContent = new List<AccountContactRelationWrapper>();
        if(!String.isBlank(AccountContactRelationWrapperString))
            ACRWrapperContent =  (List<AccountContactRelationWrapper>) System.JSON.deserialize(AccountContactRelationWrapperString , List<AccountContactRelationWrapper>.class);
        List<Id> deleteAccConRelation = new List<Id>();
        for(AccountContactRelationWrapper acrIndWrapper : ACRWrapperContent)
        {
            if(acrIndWrapper.isChecked)
            {
                deleteAccConRelation.add(acrIndWrapper.recordId);
                accountsRemoved.add(acrIndWrapper.accountName);
            } 
            else
                nonSelectedAccConRelations.add(acrIndWrapper);
        }
        
        List<AccountContactRelation> accConRelationToDelete = [select id from AccountContactRelation where Id In : deleteAccConRelation];
        if(accConRelationToDelete.size() > 0)
            delete accConRelationToDelete;
        
        sendEmail(accountsRemoved);
        
        return nonSelectedAccConRelations;
    }
    
    public Static void sendEmail(List<String> accountsRemoved)
    {
        List<User> usrList = [SELECT id, email FROM User WHERE id =: UserInfo.getUserId()];
        
        if(usrList.size() > 0 && usrList[0].email != null)
        {
            //Send Email
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> toAddresses = new List<String>(); 
            toAddresses.add(usrList[0].email);
            mail.setToAddresses(toAddresses);
            mail.setSubject('Removal of Affiliation Confirmed');
            mail.setHtmlBody('This is to confirm that your affiliation with <b> ' + String.join(accountsRemoved, ', ') +' </b> organization has been completed per your request. </br></br>To establish affiliation again or with a different organization, please reach out to the appropriate contact with that organization.');
            if(!Test.isRunningTest())
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
    
    public class AccountContactRelationWrapper 
    {
        @AuraEnabled public string recordId;
        @AuraEnabled public boolean isChecked;
        @AuraEnabled public String accountName;
        @AuraEnabled public String contactRole;
        @AuraEnabled public locationWrapper accountBillingDetails;
    }
    
    public with sharing class locationWrapper 
    {
        @AuraEnabled public String city         = '';
        @AuraEnabled public String address1     = '';
        @AuraEnabled public String country      = '';
        @AuraEnabled public String province     = '';
        @AuraEnabled public String postalCode   = '';
    }
}