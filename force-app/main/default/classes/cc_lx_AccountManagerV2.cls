public with sharing class cc_lx_AccountManagerV2 {

    private static Integer RESULT_LIMIT = 10;
    
    // SA 9 store the acoount and userid from context from lightning component    
    public static ContextData currentContext = new ContextData(null, null, null, null, null, null);

    @TestVisible
    private static Integer API_VERSION = ccrz.ccApi.CURRENT_VERSION;

    public static String getCurrentId() {
      String accountId = null;

      Map<String,Object> inputData = new Map<String,Object>{
          ccrz.ccApi.API_VERSION => API_VERSION
      };

      try {
        Map<String, Object> outputData = ccrz.ccAPIAccount.getCurrent(inputData);
        if(outputData.get(ccrz.ccAPIAccount.ACCOUNTS) != null) {
            // The cast to List<Map<String, Object>> is necessary...
            List<Map<String,Object>> accounts = (List<Map<String,Object>>) outputData.get(ccrz.ccAPIAccount.ACCOUNTS);

            // Get the Current Account Account
            Map<String, Object> currentAccount = accounts.get(0);

            // The cast, again, is necessary...
            accountId = (String)currentAccount.get('sfid');
        }
      } catch (Exception e) {
        System.debug(System.LoggingLevel.ERROR, e.getMessage());
        throw new AccountManagerException(e.getMessage());
      }
      return accountId;
    }

    public static Map<String, Object> getCurrent() {
      Map<String, Object> account = null;

      Map<String,Object> inputData = new Map<String,Object>{
          ccrz.ccApi.API_VERSION => API_VERSION
      };

      try {
        Map<String, Object> outputData = ccrz.ccAPIAccount.getCurrent(inputData);
        if(outputData.get(ccrz.ccAPIAccount.ACCOUNTS) != null) {
            // The cast to List<Map<String, Object>> is necessary...
            List<Map<String,Object>> accounts = (List<Map<String,Object>>) outputData.get(ccrz.ccAPIAccount.ACCOUNTS);

            // Get the Current Account Account
            account = accounts.get(0);
        }
      } catch (Exception e) {
        System.debug(System.LoggingLevel.ERROR, e.getMessage());
        throw new AccountManagerException(e.getMessage());
      }
      return account;
    }

    public static void setContext(String ctx) {
        if (ctx != null) {
            ccrz.cc_RemoteActionContext rctx = (ccrz.cc_RemoteActionContext) JSON.deserialize(ctx, ccrz.cc_RemoteActionContext.class);
            if(null==rctx.queryParams){
                rctx.queryParams = new Map<String,String>();
            }
            
            // SA 10 : save for later use
            currentContext = (ContextData) JSON.deserialize(ctx, ContextData.class);

            try{
                if(String.isBlank(rctx.storefront)){
                    rctx.storefront = (String)ccrz.ccApiStorefront.getAccessibleDefault(new Map<String,Object>{
                        ccrz.ccApi.API_VERSION => API_VERSION
                        ,ccrz.ccApiStorefront.PARAM_REFID => Network.getNetworkId()
                    }).get('sfDefault');
                }
            }catch(Exception e){
                //Ignore, use core CCRZ mechanism
            }


            ccrz.cc_CallContext.initRemoteContext(rctx);
        }
    }

    public static List<Contract> getContractsForAccount(String accountId) {
        // Ek Note: I don't think there's a way of doing this via the API
        List<Contract> contracts = [
            SELECT
                Id, ContractNumber, StartDate, EndDate
            FROM
                Contract
            WHERE
                AccountId = :accountId AND Status = 'Activated'
            ORDER BY
                StartDate ASC
        ];
        return contracts;
    }

    public static Map<String,Object> getAccountAddresses(String accountId) {
      Map<String,Object> addrFetch = ccrz.ccApiAddressBook.fetch(new Map<String,Object>{
                 ccrz.ccApi.API_VERSION => API_VERSION
                ,ccrz.ccApiAddressBook.ACCOUNTID => accountId
            });
        Map<String,Object> returnVal = new Map<String,Object>();


        List<Map<String,Object>> addrs = (List<Map<String,Object>>)addrFetch.get(ccrz.ccApiAddressBook.ADDRESSBOOKS);
        if(null!=addrs){
            Map<String,Map<String,Object>> caddrMap = new Map<String,Map<String,Object>>();
            for(Map<String,Object> caddr:(List<Map<String,Object>>)addrFetch.get(ccrz.ccApiAddress.ADDRESSLIST)){
                caddrMap.put((String)caddr.get('sfid'),caddr);
            }

            Map<String,Object> defaultAddresses = new Map<String, Object>();
            for(Map<String,Object> addr:addrs){
              Map<String,Object> cad = (Map<String,Object>)caddrMap.get((String)addr.get('EContactAddress'));

              if('Shipping'.equalsIgnoreCase((String)addr.get('addressType'))){
                        if(ccrz.ccUtil.isTrue(addr,'default')){
                          defaultAddresses.put('ShippingStreet',cad.get('addressFirstline'));
                          defaultAddresses.put('ShippingCity',cad.get('city'));
                            defaultAddresses.put('ShippingStateISOCode', cad.get('stateISOCode'));
                          defaultAddresses.put('ShippingPostalCode',cad.get('postalCode'));
                            defaultAddresses.put('ShippingCountry',cad.get('country'));
                            defaultAddresses.put('ShippingCountryISOCode', cad.get('countryISOCode'));
                        }
                    }

                    if('Billing'.equalsIgnoreCase((String)addr.get('addressType'))){
                        if(ccrz.ccUtil.isTrue(addr,'default')){
                          defaultAddresses.put('BillingStreet',cad.get('addressFirstline'));
                          defaultAddresses.put('BillingCity',cad.get('city'));
                            defaultAddresses.put('BillingStateISOCode', cad.get('stateISOCode'));
                          defaultAddresses.put('BillingPostalCode',cad.get('postalCode'));
                            defaultAddresses.put('BillingCountry', cad.get('country'));
                            defaultAddresses.put('BillingCountryISOCode', cad.get('countryISOCode'));
                        }
                    }
                }
            if (defaultAddresses.size() > 0)
            {
              returnVal.put('addresses', defaultAddresses);
            }
      } else {
            returnVal.put('addresses', new Map<String, Object>());
        }

        return returnVal;

    }

    public static Map<String,Object> getAddresses(String billingId, String shippingId) {
        List<String> addressIdList = new List<String>();
        if(!String.isBlank(billingId)) {
            addressIdList.add(billingId);
        }
        if(!String.isBlank(shippingId)) {
            addressIdList.add(shippingId);
        }
        Map<String,Object> returnVal = new Map<String,Object>();
        if(addressIdList.size() > 0) {

            Map<String,Object> addrFetch = ccrz.ccApiAddress.fetch(new Map<String,Object>{
                 ccrz.ccApi.API_VERSION => API_VERSION
                ,ccrz.ccApiAddress.ADDRESSIDLIST => addressIdList
            });

            Map<String,Object> savedAddresses = new Map<String, Object>();

            List<Map<String,Object>> addrs = (List<Map<String,Object>>)addrFetch.get(ccrz.ccApiAddress.ADDRESSLIST);
            for(Map<String,Object> addr:addrs){
                if(addr.get('sfid') == billingId) {
                    savedAddresses.put('BillingSfid', addr.get('sfid'));
                    savedAddresses.put('BillingStreet',addr.get('addressFirstline'));
                    savedAddresses.put('BillingStreet2',addr.get('addressSecondline'));
                    savedAddresses.put('BillingCity',addr.get('city'));
                    savedAddresses.put('BillingStateISOCode', addr.get('stateISOCode'));
                    savedAddresses.put('BillingPostalCode',addr.get('postalCode'));
                    savedAddresses.put('BillingCountry', addr.get('country'));
                    savedAddresses.put('BillingCountryISOCode', addr.get('countryISOCode'));
                }
                if(addr.get('sfid') == shippingId) {
                    savedAddresses.put('ShippingSfid', addr.get('sfid'));
                    savedAddresses.put('ShippingStreet',addr.get('addressFirstline'));
                    savedAddresses.put('ShippingStreet2',addr.get('addressSecondline'));
                    savedAddresses.put('ShippingCity',addr.get('city'));
                    savedAddresses.put('ShippingStateISOCode', addr.get('stateISOCode'));
                    savedAddresses.put('ShippingPostalCode',addr.get('postalCode'));
                    savedAddresses.put('ShippingCountry',addr.get('country'));
                    savedAddresses.put('ShippingCountryISOCode', addr.get('countryISOCode'));
                }
            }
            returnVal.put('addresses', savedAddresses);
        }
        else {
            returnVal.put('addresses', new Map<String, Object>());
        }
        return returnVal;
    }

    public static void saveAddresses(List<Map<String,Object>> addresses, String cartId) {
        List<Map<String,Object>> newAddresses = new List<Map<String,Object>>();
        List<Map<String,Object>> editAddresses = new List<Map<String,Object>>();

        for(Map<String,Object> add : addresses) {
            if(String.isBlank((String)add.get('sfid'))) {
                newAddresses.add(add);
            } else {
                editAddresses.add(add);
            }
        }
        if(newAddresses.size() > 0) {
            Map<String, Object> cartRequest = new Map<String,Object>{
                    ccrz.ccApi.API_VERSION => API_VERSION,
                    ccrz.ccAPICart.CART_ENCID => cartId,
                    ccrz.ccAPI.SIZING=>new Map<String, Object>{
                        ccrz.ccAPICart.ENTITYNAME => new Map<String, Object>{
                            ccrz.ccAPI.SZ_DATA => ccrz.ccAPI.SZ_XL,
                            ccrz.ccAPI.SZ_ASSC=>false
                        }
                    }
            };

            Map<String,Object> cart = null;
            Map<String,Object> cartResponse = ccrz.ccAPICart.fetch(cartRequest);
            List<Map<String, Object>> outputCartList = (List<Map<String, Object>>) cartResponse.get(ccrz.ccAPICart.CART_OBJLIST);
            if (outputCartList != null && !outputCartList.isEmpty()) {
                    cart = outputCartList[0];
            }

            if(cart != null) {
                // this only takes one address at a time, but we might be making two
                for(Map<String,Object> addr : newAddresses) {
                    Map<string,Object> newInputData = new Map<String,Object> {
                        ccrz.ccApi.API_VERSION => API_VERSION,
                        ccrz.ccApiAddress.ADDRESSLIST => new List<Map<String,Object>>{addr}
                    };
                    Map<String,Object> addrResponse = ccrz.ccApiAddress.createAddress(newInputData);
                    if((Boolean)addrResponse.get(ccrz.ccApi.SUCCESS)) {
                        System.debug(JSON.serialize(addrResponse.get(ccrz.ccApiAddress.ADDRESSIDLIST)));
                        String addrId = ((List<String>)addrResponse.get(ccrz.ccApiAddress.ADDRESSIDLIST))[0];
                        if (addr.get('type') == 'shipping') {
                            cart.put('shipTo', addrId);
                        } else {
                            cart.put('billTo', addrId);
                        }
                    }
                }
                Map<String,Object> saveCartInput = new Map<String,Object>{
                        ccrz.ccApi.API_VERSION => API_VERSION,
                        ccrz.ccAPICart.CART_OBJLIST => new List<Map<String,Object>> { cart }
                };
                Map<String,Object> saveResponse = ccrz.ccApiCart.revise(saveCartInput);
            }
        }

        if(editAddresses.size() > 0) {
            Map<String,Object> inputData = new Map<String,Object>{
                ccrz.ccApi.API_VERSION => API_VERSION,
                ccrz.ccApiAddress.ADDRESSLIST => editAddresses
            };
            Map<String,Object> response = ccrz.ccAPIAddress.revise(inputData);
        }
    }

    public static List<User> getUserForId(String theId) {
      User selectedUser = null;
      List<Object> usrRes = (List<Object>)ccrz.ccApiUser.fetch(new Map<String,Object>{
         ccrz.ccApi.API_VERSION => API_VERSION
        ,ccrz.ccApiUser.USER_ID => theId
        ,ccrz.ccApi.SIZING=>new Map<String, Object>{
                     ccrz.ccApiUser.ENTITYNAME => new Map<String, Object>{
                         ccrz.ccAPI.SZ_DATA => ccrz.ccAPI.SZ_M,
                         ccrz.ccAPI.SZ_SKIPTRZ=>true
                     }
                 }
      }).get(ccrz.ccApiUser.USERLIST);
            if(!usrRes.isEmpty()){
                selectedUser = (User)usrRes.get(0);
            }
      List<User> returnList = new List<User>();
      returnList.add(selectedUser);
      return returnList;
    }

    public class AccountManagerException extends Exception {}
    
    public static ContextData getInitialContext(String componentOnObject, String recordId) {
        
        if (componentOnObject == 'Account') {
            // component is added on an Account Page, recordId is accountId
            return new ContextData(componentOnObject, recordId, recordId, UserInfo.getUserId(), null, null);
        }
        else if (componentOnObject == 'Opportunity') {
            // the component is added on Opportunity page.
            // get the Account from opportunity
            List<Opportunity> listOpps = [SELECT Id, AccountId, Account.OwnerId, Cart_Id__c, CC_Account_Group__c, Account.ccrz__E_AccountGroup__c FROM Opportunity WHERE Id = :recordId];
            if (listOpps.size() > 0) {
                
                if (listOpps[0].Cart_Id__c == null) {
                    ContextData cdata = new ContextData(componentOnObject, recordId, listOpps[0].AccountId, listOpps[0].Account.OwnerId, listOpps[0].Cart_Id__c, null);
                    /*ccrz.cc_RemoteActionContext rctx = new ccrz.cc_RemoteActionContext();
                    rctx.portalUserId = listOpps[0].Account.OwnerId;
                    rctx.effAccountId = listOpps[0].AccountId;*/
                    cc_lx_AccountManagerV2.setContext(JSON.serialize(cdata));
                    String cartId = cc_lx_CartManagerV2.createCart();
                    listOpps[0].Cart_Id__c = cartId;
                    if (listOpps[0].CC_Account_Group__c == null && listOpps[0].Account.ccrz__E_AccountGroup__c != null) {
                        listOpps[0].CC_Account_Group__c = listOpps[0].Account.ccrz__E_AccountGroup__c;
                    }
                    update listOpps[0];
                    
                    ccrz__E_Cart__c cart = cc_lx_CartManagerV2.getCartObject(cartId);
                    cart.Opportunity__c = listOpps[0].Id;
                    update cart;
                    
                }
                String message = null;
                if (listOpps[0].CC_Account_Group__c == null) {
                    message = 'Account Group must be set on Account or Opportunity';
                }
                return new ContextData(componentOnObject, recordId, listOpps[0].AccountId, listOpps[0].Account.OwnerId, listOpps[0].Cart_Id__c, message);
            }
        }
        return null;
    }
    
    public static void orderPlaced() {
        
        if (currentContext.componentOnObject == 'Account') {
            
        }
        else if (currentContext.componentOnObject == 'Opportunity') {
            // order is placed so change stage of Opportunity .
            List<Opportunity> listOpps = [SELECT Id, AccountId, Account.OwnerId, Cart_Id__c, CC_Account_Group__c, Account.ccrz__E_AccountGroup__c FROM Opportunity WHERE Id = :currentContext.recordId];
            if (listOpps.size() > 0) {
                listOpps[0].StageName = 'Reservation';
                update listOpps[0];
            }
        }
        return;
    }
    
    // the context data to be sent to the lightnig component
    public class ContextData {
        @AuraEnabled
        public String componentOnObject {get; set;}
        @AuraEnabled
        public String recordId {get; set;}
        @AuraEnabled
        public String effAccountId {get; set;}
        @AuraEnabled
        public String portalUserId {get; set;}
        @AuraEnabled
        public String cartId {get; set;}
        @AuraEnabled
        public String message {get; set;}
        
        public ContextData(String componentOnObject, String recordId, String effAccountId, String portalUserId, String cartId, String message) {
            this.componentOnObject = componentOnObject;
            this.recordId = recordId;
            this.effAccountId = effAccountId;
            this.portalUserId = portalUserId;
            this.cartId = cartId;
            this.message = message;
        }
    }

}