public class phss_cc_OnAccountBalanceController 
{
    @AuraEnabled
    public static List<WrapperToDisplayAccountBalanceRecords> fetchStoredPayments(String opportunitySfid) {
        
         List<ccrz__E_StoredPayment__c> fetchStoredPaymentsResponse = new List<ccrz__E_StoredPayment__c> ();
         try {
             fetchStoredPaymentsResponse = phss_cc_StoredPaymentUtil.fetchOnAccountPayments(opportunitySfid);

         } catch (Exception e) {
             //fetchStoredPaymentsResponse = phss_cc_Exception.getErrorMessageMap(e.getMessage());
         }
         
         system.debug('***fetchStoredPaymentsResponse***'+fetchStoredPaymentsResponse);
         
         List<WrapperToDisplayAccountBalanceRecords> lstCBRecords = new List<WrapperToDisplayAccountBalanceRecords>();
         
         for(ccrz__E_StoredPayment__c  sp : fetchStoredPaymentsResponse)
         {
             System.debug('JASON: storedPayment.Id=' + sp.Id);
             WrapperToDisplayAccountBalanceRecords abRecords = new WrapperToDisplayAccountBalanceRecords();
             
             abRecords.name				 = sp.ccrz__DisplayName__c;
             abRecords.originalPOAmount	 = sp.Original_PO_Amount__c;
             abRecords.poEndDate		 = sp.ccrz__EndDate__c;
             abRecords.poStartDate		 = sp.ccrz__StartDate__c;
             abRecords.remainingPOAmount = sp.Remaining_PO_Amount__c;
             abRecords.sfid				 = sp.Id;
             
             lstCBRecords.add(abRecords);
         }
         return lstCBRecords;
    }
    
    public class WrapperToDisplayAccountBalanceRecords
    {
        
        @AuraEnabled public boolean isSelected		  {get;set;}
        @AuraEnabled public string  name			  {get;set;}
        @AuraEnabled public decimal originalPOAmount  {get;set;}
        @AuraEnabled public date 	poEndDate		  {get;set;}
        @AuraEnabled public date 	poStartDate		  {get;set;}
        @AuraEnabled public decimal remainingPOAmount {get;set;}
        @AuraEnabled public string  sfid			  {get;set;}
        
        public WrapperToDisplayAccountBalanceRecords()
        {
            isSelected 		  = false;
            name 			  = '';
            /*originalPOAmount  = '';
            remainingPOAmount = '';
            poEndDate 		  = '';
            poStartDate 	  = '';*/
            sfid 			  = '';
        }
    }
}