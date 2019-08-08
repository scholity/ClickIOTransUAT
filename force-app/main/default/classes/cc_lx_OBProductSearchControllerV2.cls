public with sharing class cc_lx_OBProductSearchControllerV2 {
    
    public static final String EFFECTIVE_ACCOUNT_ID  = 'effAccountId';
    public static final String PRICE_GROUP_ID        = 'priceGroupId';

    @AuraEnabled
    public static List<Map<String, Object>> doProductSearch(String text, String ctx) {
        List<Map<String, Object>> data = null;
        
		ctx = validateContext(ctx);
        cc_lx_AccountManagerV2.setContext(ctx);

        try {
            data = cc_lx_ProductManagerV2.getProductsSearch(text);
            if(data != null) {
              for(Map<String, Object> item : data)
              {
                item.put('quantity', (Decimal) item.get('quantityperunit'));
              }
            }
        }
        catch (Exception e) {
            System.debug(Logginglevel.ERROR, e);
            throw new AuraHandledException(e.getMessage());
        }

        return data;
    }

    @AuraEnabled
    public static void addItemsToCart(String data, String ctx) {
        String errorMessage = null;

        List<Object> items = (List<Object>) JSON.deserializeUntyped(data);
        cc_lx_AccountManagerV2.setContext(ctx);

        try {
            String cartId = cc_lx_CartManagerV2.getActiveCartId();
            if (cartId != null) {
                cc_lx_CartManagerV2.addToCart(cartId, items);
            }
            else {
                errorMessage = 'Cart not found.';
            }
        }
        catch (Exception e) {
            System.debug(Logginglevel.ERROR, e);
            throw new AuraHandledException(e.getMessage());
        }

        if (errorMessage != null) {
            System.debug(Logginglevel.ERROR, errorMessage);
            throw new AuraHandledException(errorMessage);
        }

    }
    
    private static String validateContext(String ctx) {
        String result = ctx;
        Map<String,Object> properties = (Map<String,Object>) JSON.deserializeUntyped(result);
        
        if (isPriceGroupNull(properties)) {
            String accountId = (String) properties.get(EFFECTIVE_ACCOUNT_ID);
            ccrz__E_PriceGroupAccount__c pgAccount = getDefaultPriceGroupAccount(accountId);
            if (pgAccount != null) {
                properties.put(PRICE_GROUP_ID, pgAccount.ccrz__PriceGroup__c);
                result = JSON.serialize(properties);
            }
        }
        
        return result;
    }
    
    private static Boolean isPriceGroupNull(Map<String,Object> properties) {
        return properties.get(PRICE_GROUP_ID) == null;
    }
    
    private static ccrz__E_PriceGroupAccount__c getDefaultPriceGroupAccount(String accountId) {
        ccrz__E_PriceGroupAccount__c account = null;
        
        if (! String.isBlank(accountId)) {
            List<ccrz__E_PriceGroupAccount__c> pgAccounts = cc_CommonUtil.fetchPriceGroupAccounts(accountId);
            if (pgAccounts != null && pgAccounts.size() > 0) {
                account = pgAccounts[0];
            }
        }
		
        return account;
    }
}