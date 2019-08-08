public with sharing class AccountService {


	public static String constructAccountName( String lastName, String accountNumber ) {      
        // Construct an Account Name defined by American Red Cross
        String accountName = lastName + ' - Household - ' + accountNumber;    
        return accountName;
    } 
}