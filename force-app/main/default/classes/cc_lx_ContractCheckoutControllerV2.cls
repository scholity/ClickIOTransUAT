public with sharing class cc_lx_ContractCheckoutControllerV2 {

    @AuraEnabled
    public static List<Map<String, Object>> getCyberSourcePaymentTypes(String ctx) {
        cc_lx_AccountManagerV2.setContext(ctx);
        
        ccrz.cc_RemoteActionResult result = ccpgcs.cc_pgcs_ctrl_pmt_SOPCC_Pay.getPaymentTypes(new ccrz.cc_RemoteActionContext(), '');
        
        return (List<Map<String, Object>>)result.data;
    }
    
    @AuraEnabled
    public static List<Map<String, Object>> getStoredPayments(String ctx) {
        cc_lx_AccountManagerV2.setContext(ctx);
        
        Date today = Date.today();
        
        List<ccrz__E_StoredPayment__c> listStoredPayments = [SELECT Id, ccrz__AccountNumber__c, ccrz__AccountType__c, ccrz__PaymentType__c, Original_PO_Amount__c, Remaining_PO_Amount__c FROM ccrz__E_StoredPayment__c WHERE ccrz__User__c = :cc_lx_AccountManagerV2.currentContext.portalUserId  AND ccrz__Enabled__c = true AND (ccrz__StartDate__c = null OR ccrz__StartDate__c <= :today) AND (ccrz__EndDate__c = null OR ccrz__EndDate__c >= :today)];
        
        List<Map<String, Object>> listReturnData = new List<Map<String, Object>>();
        for (ccrz__E_StoredPayment__c sp : listStoredPayments) {
            Map<String, Object> mapSP = new Map<String, Object>();
            mapSP.put('sfid', sp.Id);
            mapSP.put('selected', false);
            mapSP.put('accountNumber', sp.ccrz__AccountNumber__c);
            mapSP.put('accountType', sp.ccrz__AccountType__c);
            mapSP.put('paymentType', sp.ccrz__PaymentType__c);
            mapSP.put('originalPOAmount', sp.Original_PO_Amount__c);
            mapSP.put('remainingPOAmount', sp.Remaining_PO_Amount__c);
            
            listReturnData.add(mapSP);
        }
        
        return listReturnData;
       
    }
    @AuraEnabled
    public static Map<String, Object> getCart(String ctx) {
        Map<String, Object> data = null;
        String errorMessage = null;

        cc_lx_AccountManagerV2.setContext(ctx);

        try {
            String cartId = cc_lx_CartManagerV2.getActiveCartId();
            // reprice on load
            cc_lx_CartManagerV2.repriceCart(cartId);
            if (cartId != null) {
                data = cc_lx_CartManagerV2.getCartForCheckout(cartId);
            } else {
                errorMessage = 'Cart not found.';
            }
        } catch (Exception e) {
            System.debug(Logginglevel.ERROR, e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }

        if (errorMessage != null) {
            System.debug(Logginglevel.ERROR, errorMessage);
            throw new AuraHandledException(errorMessage);
        }

        return data;
    }

    private static Date dv(Object d){
        Date rd=null;
        try{rd=(Date)d;}catch(Exception e){}
        if(rd==null){try{rd=Date.parse((String)d);}catch(Exception e){}}
        if(rd==null){try{rd=((DateTime)d).date();}catch(Exception e){}}
        return rd;
    }

    @AuraEnabled
    public static void modifyCart(String cartId, String itemsJson, String dataJson, String ctx) {
        String errorMessage = null;

        List<Object> items = (List<Object>) JSON.deserializeUntyped(itemsJson);
        cc_lx_AccountManagerV2.setContext(ctx);

        Map<String, Object> dataItems = (Map<String, Object>) JSON.deserializeUntyped(dataJson);
        String note = (String) dataItems.get('note');
        String shipMethod = (String) dataItems.get('shippingMethod');
        Decimal shipAmount = (Decimal) dataItems.get('shippingAmount');
        Map<String, Object> deliveryDate = (Map<String,Object>)dataItems.get('deliveryDate');
        Date requestDate = null;
        if(!ccrz.ccUtil.isEmpty(deliveryDate) &&
                deliveryDate.get('year') != null &&
                deliveryDate.get('month') != null &&
                deliveryDate.get('day') != null ) {

                try {
                    requestDate = Date.newInstance(Integer.valueOf(deliveryDate.get('year')), Integer.valueOf(deliveryDate.get('month')), Integer.valueOf(deliveryDate.get('day')));
                } catch (Exception e) {
                    // swallow any casting errors - they would only come from inline JS object editing
                }
        }

        try {
            if (cartId != null) {
                Map<String, Object> cart = cc_lx_CartManagerV2.getCart(cartId);
                cc_lx_CartManagerV2.saveCartDetails(cartId, note, shipMethod, shipAmount, requestDate);

                List<Object> addItems = new List<Object>();
                Set<String> removeItems = new Set<String>();
                for (Object o : items) {
                    Map<String, Object> m = (Map<String, Object>) o;
                    String theId = (String) m.get(cc_lx_CartManagerV2.SFID_KEY);
                    Integer quantity = Integer.valueOf(m.get(cc_lx_CartManagerV2.QUANTITY_KEY));
                    Map<String, Object> cartItem = findCartItem(cart, theId);
                    if (cartItem != null) {
                        Integer beforeQuantity = (Integer) cartItem.get(cc_lx_CartManagerV2.QUANTITY_KEY);
                        if (quantity < 1) {
                            removeItems.add(theId);
                        } else if (quantity != beforeQuantity) {
                            if (quantity > beforeQuantity) {
                                Map<String, Object> item = new Map<String, Object>(m);
                                item.put(cc_lx_CartManagerV2.QUANTITY_KEY, quantity - beforeQuantity);
                                addItems.add(item);
                            } else {
                                removeItems.add(theId);
                                addItems.add(o);
                            }
                        }
                    }
                }
                if (!removeItems.isEmpty()) {
                    cc_lx_CartManagerV2.removeFromCart(cartId, removeItems);
                }
                if (!addItems.isEmpty()) {
                    cc_lx_CartManagerV2.addToCart(cartId, addItems);
                }

            } else {
                errorMessage = 'Cart not found.';
            }

        } catch (Exception e) {
            System.debug(Logginglevel.ERROR, e);
            throw new AuraHandledException(e.getMessage());
        }

        if (errorMessage != null) {
            System.debug(Logginglevel.ERROR, errorMessage);
            throw new AuraHandledException(errorMessage);
        }
    }

    public class TransactionPaymentParams {
        public String accountNumber { get; set; } //StringAccountNumber__c
        public String accountType { get; set; } //AccountType__c
        public Decimal amount { get; set; } //Amount__c
        public String storedPaymentId {get;set;} //StoredPayment__c
        /*public String comments {get;set;} //Comments__c
        public Decimal expirationMonth {get;set;} //ExpirationMonth__c
        public Decimal expirationYear {get;set;} //ExpirationYear__c
        public String paymentType {get;set;} //PaymentType__c
        public Decimal requestAmount {get;set;} //RequestAmount__c
        public String storefront {get;set;} //Storefront__c
        public String subAccountNumber {get;set;} //SubAccountNumber__c
        public String token {get;set;} //Token__c
        public String transactionCode {get;set;} //TransactionCode__c
        public String transactionPaymentId {get;set;} //TransactionPaymentId__c
        public String transactionSubcode {get;set;} //TransactionSubcode__c
        public String transactionType {get;set;} //TransactionType__c
        public String verificationCode {get;set;} //VerificationCode__c */
        public Boolean saveAsStoredPayment { get; set; }
        public Decimal originalPOAmount { get; set; }
        public String displayName { get; set; }
        public Boolean isEnabled { get; set; }
        public Decimal ammount { get; set; }//@Deprecated
        public String contract { get; set; }
        public Date deliveryDate { get; set; }
    }

    @AuraEnabled
    public static String placeOrder(String cartId, String data, String ctx) {
        String orderId = null;
        String errorMessage = null;

        cc_lx_AccountManagerV2.setContext(ctx);

        /* Incoming data JSON
        var data = {
            paymentMethod : component.get("v.paymentMethod"),
            deliveryDate : component.get("v.deliveryDate"),
            agreeToTerms : component.get("v.agreeToTerms"),
            showTerms : component.get("v.showTerms"),
            selectedContract : component.get("v.selectedContract"),
            poNumber : component.get("v.poNumber"),
            cardNumber : component.get("v.cardNumber"),
            cardExpirationDate : component.get("v.cardExpirationDate"),
            cardCode : component.get("v.cardCode"),
            cardName : component.get("v.cardName")
        };
        */
        if (ccrz.cc_CallContext.currUser.Id != null) {
            Map<String, Object> account = cc_lx_AccountManagerV2.getCurrent();
            String logJSON = JSON.serialize(account);
            String accountNumber = (String) account.get('accountNumber');

            Map<String, Object> dataMap = (Map<String, Object>) JSON.deserializeUntyped(data);

            try {
                if (cartId != null) {
                    TransactionPaymentParams params = new TransactionPaymentParams();
                    params.accountNumber = accountNumber;
                    
                    List<Object> listStoredPayments = (List<Object>) dataMap.get('storedPayments');
                    
                    if (listStoredPayments != null) {
                        for (Object ob : listStoredPayments) {
                            Map<String, Object> sp = (Map<String, Object>)ob;
                            if ((Boolean)sp.get('selected')) {
                                params.storedPaymentId = (String)sp.get('sfid');
                                break;
                            }
                        }
                    }
                    
                    if (params.storedPaymentId == null) {                   
                        if (dataMap.containsKey('poNumber')) {
                            params.accountNumber = (String) dataMap.get('poNumber');
                            params.accountType = 'po';
                            if ((Boolean) dataMap.get('savePayment')) {
                                params.saveAsStoredPayment = true;
                                params.originalPOAmount =  Decimal.valueOf((String)dataMap.get('originalPOAmount'));
                                params.isEnabled = true;
                            }
                        } else if (dataMap.containsKey('selectedContract')) {
                            params.accountNumber = (String) dataMap.get('selectedContract');
                            params.accountType = 'Contract';
                            params.contract = (String) dataMap.get('selectedContract');
                        }
                    }
                    String paramJSON = JSON.serialize(params);
                    orderId = cc_lx_CartManagerV2.placeOrder(cartId, paramJSON);
                    // reset the cart as the cart is converted to order
                    cc_lx_AccountManagerV2.orderPlaced();
                } else {
                    errorMessage = 'Cart not found.';
                }

            } catch (Exception e) {
                System.debug(Logginglevel.ERROR, e);
                throw new AuraHandledException(e.getMessage());
            }

        } else {
            errorMessage = 'User not logged in';
        }

        if (errorMessage != null) {
            System.debug(Logginglevel.ERROR, errorMessage);
            throw new AuraHandledException(errorMessage);
        }
        return orderId;
    }

    private static Map<String, Object> findCartItem(Map<String, Object> cart, String theId) {
        Map<String, Object> data = null;
        List<Map<String, Object>> items = (List<Map<String, Object>>) cart.get(cc_lx_CartManagerV2.CART_ITEMS_KEY);
        for (Map<String, Object> item : items) {
            String itemId = (String) item.get(cc_lx_CartManagerV2.SFID_KEY);
            if (itemId == theId) {
                data = item;
                break;
            }
        }
        return data;
    }

    @AuraEnabled
    public static List<Contract> getContracts(String ctx) {
        List<Contract> data = null;

        cc_lx_AccountManagerV2.setContext(ctx);

        try {
            if (ccrz.cc_CallContext.currUser.Id != null) {
                Id accountId = cc_lx_AccountManagerV2.getCurrentId();
                data = cc_lx_AccountManagerV2.getContractsForAccount(accountId);
            }
        } catch (Exception e) {
            System.debug(Logginglevel.ERROR, e);
            throw new AuraHandledException(e.getMessage());
        }

        return data;
    }

    @AuraEnabled
    public static List<Map<String, Object>> getShippingOptions(String cartId, String shippingAddress, String ctx) {
        cc_lx_AccountManagerV2.setContext(ctx);
        // cartId needs to be the sfid
        try {
            if (ccrz.cc_CallContext.currUser.Id != null) {
                List<Map<String, Object>> result = cc_lx_CartManagerV2.getShippingOptions(cartId, shippingAddress);
                for (Map<String, Object> item : result) {
                    item.put('shippingLabel', item.get('price') + ' - ' + item.get('provider') + ' - ' + item.get('serviceName'));
                    item.put('isSelected', false);
                }
                //shippingLabel
                return result;
            }
        } catch (Exception e) {
            System.debug(Logginglevel.ERROR, e);
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }

    @AuraEnabled
    public static Map<String, Object> getAddresses(String billingId, String shippingId, String ctx) {
        Map<String, Object> data = null;

        cc_lx_AccountManagerV2.setContext(ctx);

        try {
            if (ccrz.cc_CallContext.currUser.Id != null) {
                if (!String.isBlank(billingId) || !String.isBlank(shippingId)) {
                    // First we check if we have addresses on the cart
                    data = cc_lx_AccountManagerV2.getAddresses(billingId, shippingId);
                } else {
                    // fall back to the account addresses
                    data = cc_lx_AccountManagerV2.getAccountAddresses(ccrz.cc_CallContext.currAccount.Id);
                }
                /*
                if (ccrz.cc_CallContext.currAccount != null) {
                    data.put('accountName', ccrz.cc_CallContext.currAccount.Name);
                } else {
                    data.put('accountName', '');
                }
                */
                
                if (cc_lx_AccountManagerV2.currentContext.effAccountId != null) {
                    Account acc = [SELECT Id, Name FROM Account WHERe Id = :cc_lx_AccountManagerV2.currentContext.effAccountId];
                    data.put('accountName', acc.Name);
                } else {
                    data.put('accountName', '');
                }
            }
        } catch (Exception e) {
            System.debug(Logginglevel.ERROR, e);
            throw new AuraHandledException(e.getMessage());
        }

        return data;
    }

    @AuraEnabled
    public static void saveAddresses(Map<String, Object> addresses, String cartId, String ctx) { //Map<String,Object> shipping, Map<String,Object> billing, String ctx) {
        cc_lx_AccountManagerV2.setContext(ctx);
        List<Map<String, Object>> addrList = new List<Map<String, Object>>();
        Map<String, Object> shipping = new Map<String, Object>{
                'sfid' => addresses.get('ShippingSfid'),
                'addressFirstline' => addresses.get('ShippingStreet'),
                'addressSecondline' => addresses.get('ShippingStreet2'),
                'city' => addresses.get('ShippingCity'),
                'stateISOCode' => addresses.get('ShippingStateISOCode'),
                'postalCode' => addresses.get('ShippingPostalCode'),
                'country' => addresses.get('ShippingCountry'),
                'type' => 'shipping'
        };
        Map<String, Object> billing = new Map<String, Object>{
                'sfid' => addresses.get('BillingSfid'),
                'addressFirstline' => addresses.get('BillingStreet'),
                'addressSecondline' => addresses.get('BillingStreet2'),
                'city' => addresses.get('BillingCity'),
                'stateISOCode' => addresses.get('BillingStateISOCode'),
                'postalCode' => addresses.get('BillingPostalCode'),
                'country' => addresses.get('BillingCountry'),
                'type' => 'billing'
        };
        addrList.add(shipping);
        addrList.add(billing);

        try {
            if (ccrz.cc_CallContext.currUser.Id != null) {
                cc_lx_AccountManagerV2.saveAddresses(addrList, cartId);
            }
        } catch (Exception e) {
            System.debug(Logginglevel.ERROR, e);
            throw new AuraHandledException(e.getMessage());
        }
    }
}