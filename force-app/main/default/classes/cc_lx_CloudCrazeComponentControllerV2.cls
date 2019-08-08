public with sharing class cc_lx_CloudCrazeComponentControllerV2 {

    @AuraEnabled
    public static Map<String, Object> getCart(String ctx) {
        Map<String, Object> data = null;
        String errorMessage = null;

        cc_lx_AccountManagerV2.setContext(ctx);

        try {
            data = cc_lx_CartManagerV2.getActiveCart();
            if (data == null) {
                String cartId = cc_lx_CartManagerV2.createCart();
                if (cartId != null) {
                    data = cc_lx_CartManagerV2.getCart(cartId);
                }
                else {
                    errorMessage = 'Cart not found.';
                }
            }
        }
        catch (Exception e) {
            System.debug(Logginglevel.ERROR, e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }

        if (errorMessage != null) {
            System.debug(Logginglevel.ERROR, errorMessage);
            throw new AuraHandledException(errorMessage);
        }

        return data;
    }

    @AuraEnabled
    public static void addToCart(String data, String ctx) {
        String errorMessage = null;

        Map<String, Object> item = (Map<String, Object>) JSON.deserializeUntyped(data);
        cc_lx_AccountManagerV2.setContext(ctx);

        try {
            String cartId = cc_lx_CartManagerV2.getActiveCartId();
            if (cartId != null) {
                cc_lx_CartManagerV2.addToCart(cartId, (String)item.get('id'), (String)item.get('sku'), (Integer)item.get('quantity'));
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

    @AuraEnabled
    public static void removeFromCart(String item, String ctx) {
        String errorMessage = null;

        cc_lx_AccountManagerV2.setContext(ctx);

        try {
            String cartId = null;
            Map<String, Object> data = cc_lx_CartManagerV2.getActiveCart();
            if (data != null) {
                cartId = (String) data.get(cc_lx_CartManagerV2.ENCRYPTED_ID_KEY);
            }
            if (cartId != null) {
                cc_lx_CartManagerV2.removeFromCart(cartId, item);
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

    @AuraEnabled
    public static Map<String,Object> getCommunityUrl() {
        String networkId = Network.getNetworkId();

        Network currentNetwork = [SELECT Name,UrlPathPrefix FROM Network WHERE Id = :networkId];

        Map<String, Object> retVal = new Map<String, Object> {
                'networkName' => currentNetwork.Name,
                'networkUrlPrefix' => currentNetwork.UrlPathPrefix,
                'networkId' => currentNetwork.Id
        };

        return retVal;
    }
    
    @AuraEnabled
    public static cc_lx_AccountManagerV2.ContextData getInitialContext(String componentOnObject, String recordId) {    
        return cc_lx_AccountManagerV2.getInitialContext(componentOnObject, recordId);
    }
}