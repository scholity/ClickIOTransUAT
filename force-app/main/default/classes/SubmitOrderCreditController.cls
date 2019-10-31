public class SubmitOrderCreditController
{
    @AuraEnabled 
    public static boolean getOnAccountBoolean(String orderId)
    {
        boolean isCreditOnAccount = false;
        
        ccrz__E_Order__c ccOrder = [SELECT  Id,
                                    		ccrz__Order__c
                                       FROM ccrz__E_Order__c
                                   	  WHERE Id =: orderId];

        ccrz__E_Order__c ccCreditOrder = [SELECT  Id,
                                          		  (SELECT Id,
                                                   		  ccrz__AccountType__c
                                                     FROM ccrz__TransactionPayments__r
                                                  	WHERE ccrz__AccountType__c = 'cc')
                                             FROM ccrz__E_Order__c
                                            WHERE Id =: ccOrder.ccrz__Order__c
                                            LIMIT 1];

        if(ccCreditOrder.ccrz__TransactionPayments__r.size() > 0)
        {
            isCreditOnAccount = true;
        }
        return isCreditOnAccount;
    }
    
	@AuraEnabled   
    public  static void submitOrderCredit(String orderId, Boolean hasCreditOnAccount)
    {
        if(orderId != null)
        {
            ccrz__E_Order__c ccCreditOrder = [SELECT  Id,
                                                	  ccrz__SubtotalAmount__c,
                                                	  ccrz__Order__c
		                                        FROM  ccrz__E_Order__c
		                                        WHERE Id =: orderId];
            
            if(ccCreditOrder != null)
            {  
                ccrz__E_Order__c  crdOrdr = new ccrz__E_Order__c ();
                
                crdOrdr.Id 				= ccCreditOrder.Id;
                crdOrdr.Is_Submitted__c = true;
                
                update crdOrdr;
            }
            
            ccrz__E_Order__c ccOrder = [SELECT  Id,
                                        		Name,
                                        		ccrz__SubtotalAmount__c,
        										ccrz__Account__c,
												ccrz__Name__c,
												ccrz__OriginatedCart__c,
												Opportunity_Order__c,
												Error_Message__c,
												ccrz__OrderDate__c,
												ccrz__OrderStatus__c,
												ccrz__CurrencyISOCode__c,
												ccrz__Storefront__c,
												FOCIS_Category__c,
												
												(SELECT Id
												   FROM ccrz__E_Orders__r),
												(SELECT Id
												   FROM ccrz__TransactionPayments__r)
												   
										   FROM ccrz__E_Order__c
										  WHERE Id =: ccCreditOrder.ccrz__Order__c];
            
            ccrz__E_TransactionPayment__c tPayment = [SELECT Id,
	        										ccrz__Account__c,
													ccrz__AccountNumber__c,
													ccrz__AccountType__c,
													ccrz__Address__c,
													ccpgcs__Address__c,
													ccrz__Amount__c,
													ccrz__BillTo__c,
													ccrz__CCSubscription__c,
													Name,
													ccrz__Comments__c,
													ccrz__Contact__c,
													cclxrep__Contract__c,
													ccrz__CurrencyISOCode__c,
													ccrz__ExpirationMonth__c,
													ccrz__ExpirationYear__c,
													ccrz__InvoiceAppliedFor__c,
													ccrz__InvoiceAppliedTo__c,
													ccrz__ParentTransactionPayment__c,
													ccrz__PaymentType__c,
													ccrz__RequestAmount__c,
													ccrz__SoldTo__c,
													ccrz__SourceTransactionPayment__c,
													ccrz__StoredPayment__c,
													ccrz__Storefront__c,
													ccrz__SubAccountNumber__c,
													ccrz__Token__c,
													ccrz__TransactionCode__c,
													ccrz__TransactionPaymentId__c,
													ccrz__TransactionSubcode__c,
													ccrz__TransactionTS__c,
													ccrz__TransactionType__c,
													ccrz__VerificationCode__c,
													(SELECT Id
													   FROM ccrz__SourcedTransactionPayments__r)
											   FROM	ccrz__E_TransactionPayment__c
											  WHERE	Id =: ccOrder.ccrz__TransactionPayments__r[0].Id];
            
            
            ccrz__E_StoredPayment__c storedPymt = new ccrz__E_StoredPayment__c ();
            
            if(hasCreditOnAccount)
            {   
                	storedPymt.ccrz__Account__c				= ccOrder.ccrz__Account__c;
					storedPymt.ccrz__AccountType__c			= 'cb';
					storedPymt.ccrz__DisplayName__c			= 'Order ' +ccOrder.Name;
					storedPymt.ccrz__EffectiveAccountID__c	= '';
					storedPymt.Original_PO_Amount__c		= ccCreditOrder.ccrz__SubtotalAmount__c * -1;
					storedPymt.Remaining_PO_Amount__c		= ccCreditOrder.ccrz__SubtotalAmount__c * -1;
					storedPymt.ccrz__Storefront__c			= '';
                	storedPymt.ccrz__StartDate__c			= Date.today();
                    storedPymt.ccrz__EndDate__c 			= Date.today().addDays(30);
					storedPymt.ccrz__ExpMonth__c			= tPayment.ccrz__ExpirationMonth__c;
					storedPymt.ccrz__ExpYear__c				= tPayment.ccrz__ExpirationYear__c;
					storedPymt.ccrz__PaymentType__c			= tPayment.ccrz__PaymentType__c;
					storedPymt.ccrz__Token__c				= tPayment.ccrz__Token__c;
                
                insert storedPymt;
            }
            system.debug('$$$tPayment$$$'+tPayment);
            ccrz__E_TransactionPayment__c newTransPayment = tPayment.clone(false,false,false,false);
            
            newTransPayment.ccrz__CCOrder__c					= orderId;
            newTransPayment.ccrz__ParentTransactionPayment__c 	= tPayment.Id;
			newTransPayment.ccrz__PaymentType__c				= tPayment.ccrz__PaymentType__c;
            newTransPayment.ccrz__Amount__c 					= ccCreditOrder.ccrz__SubtotalAmount__c;

			if(hasCreditOnAccount)
            {
				newTransPayment.ccrz__AccountType__c 			= 'cb';
				newTransPayment.ccrz__StoredPayment__c 			= storedPymt.Id;
				newTransPayment.ccrz__TransactionType__c		= phss_cc_TransactionPaymentUtil.BALANCE_TRANSACTION_TYPE;
			}
            
            insert newTransPayment;
            
            Map<String, Object> myMap = new Map<String, Object>();
            
            myMap.put('frmOrderId', orderId);
            
            Flow.Interview.Manage_Credit_Status  myFlow = new Flow.Interview.Manage_Credit_Status (myMap);
            
            myFlow.start();
        
       }
    
    }
}