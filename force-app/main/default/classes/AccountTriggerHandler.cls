/************************************************************************************************************************************
** Author: Salesforce Services
** Description: The purpose of this class is to complete the trigger actions 
************************************************************************************************************************************/

public without sharing class AccountTriggerHandler {
    
    public AccountTriggerHandler() {} 
    
    public void OnBeforeInsert(List<Account> newAccounts) {
        system.debug('AccountTrigger On Before Insert');        
        accountsToUpdate(newAccounts);
    }
    
    public void OnBeforeUpdate( List<Account> newAccounts, List<Account> oldAccounts, Map<ID, Account> newAccountMap , Map<ID, Account> oldAccountMap ) {
        system.debug('Account Trigger On Before Update');  
        List<Account> accountListToReview = new List<Account>();
        for(Account a: newAccounts) {
            if(a.BillingStreet!=oldAccountMap.get(a.Id).BillingStreet) {
                accountListToReview.add(a); 
            }      
        }
        if(!accountListToReview.isEmpty()) {
            accountsToUpdate(accountListToReview);
        }   
    }
    
    public void accountsToUpdate(List<Account> accountListToReview) {
        String errMessage = 'There are two lines available for the Billing Address and each may not exceed 40 characters. This information will appear on the customer\'s invoice or correspondence. Please re-enter to meet specification.';
        for(Account a: accountListToReview) {
            if(a.BillingStreet!=null) {
                List<String> stringList = new List<String>();
                stringList = String.valueOf(a.BillingStreet).split('\n');
                if(stringList.size()==1) {
                    if(!String.isEmpty(stringList[0]) && stringList[0].length()>40) {
                        a.addError(errMessage);
                    } 
                } else if(stringList.size()==2) {
                    if(!String.isEmpty(stringList[0]) && stringList[0].length()>41) {
                        a.addError(errMessage);
                    }
                    if(!String.isEmpty(stringList[1]) && stringList[1].length()>40) {
                        a.addError(errMessage);
                    }
                } else {
                    a.addError(errMessage);
                }  
            } 
        }
    }
}