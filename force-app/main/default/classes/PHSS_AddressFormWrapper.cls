public class PHSS_AddressFormWrapper {
	
    @AuraEnabled
    public String firstName {get;set;}
	
    @AuraEnabled
    public String lastName {get;set;}
    
    @AuraEnabled
    public String email {get;set;}
    
    @AuraEnabled
    public String phone {get;set;}
    
    @AuraEnabled
    public String addressFirstLine {get;set;}
    
    @AuraEnabled
    public String addressSecondLine {get;set;}
    
    @AuraEnabled
    public String city {get;set;}
    
    @AuraEnabled
    public String state {get;set;}
    
    @AuraEnabled
    public String country {get;set;}
    
    @AuraEnabled
    public String postalCode {get;set;}
  
}