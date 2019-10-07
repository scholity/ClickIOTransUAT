/**
 * Created by dgajwani on 9/25/18.
 */

public without sharing class phss_cc_Context {

    private static final String INIT_CONTEXT_ERROR_MSG = 'Failed to instantiate context.';

    /**
     * @description CC Storefront being used.
     */
    public Static String STOREFRONT_NAME {
        get {
            if (STOREFRONT_NAME == null) {
                return 'GeneralStore';
            } else {
                return STOREFRONT_NAME;
            }
        }
        set {
            STOREFRONT_NAME = value;
        }
        // private set;
    }

    /**
     * @description Current Opportunity Id.
     */
    public static String currOpportunityId {
        get {
            return currOpportunityId;
        }
        private set;
    }

    /**
     * @description Current Account Id.
     */
    public static String currAccountId {
        get {
            if (null == currAccountId) {
                Opportunity currOpportunity = [
                        SELECT Id,AccountId
                        FROM Opportunity
                        WHERE Id = :currOpportunityId
                        LIMIT 1
                ];
                currAccountId = currOpportunity.AccountId;
            }
            return currAccountId;
        }
        private set;
    }

    /**
     * @description Current Cart object Id.
     */
    public static ccrz__E_Cart__c currCart {
        get {
            if (null == currCart) {
                List<ccrz__E_Cart__c> fetchCarts = [
                        SELECT Id,ccrz__Account__c, ccrz__EncryptedId__c
                        FROM ccrz__E_Cart__c
                        WHERE Opportunity__c = :currOpportunityId AND ccrz__ActiveCart__c = true
                        LIMIT 1
                ];

                if (fetchCarts == null || fetchCarts.isEmpty()) {
                    currCart = phss_cc_CartUtil.activateOpenCart(currOpportunityId);
                } else {
                    currCart = fetchCarts[0];
                }
            }
            return currCart;
        }
        private set;
    }

    /**
     * @description Get the priceGroupId if there is one.
     */
    public static String currPriceGroupId {
        get {
            if (null == currPriceGroupId) {
                currPriceGroupId = fetchPriceGroupIdByAccount(currAccountId,STOREFRONT_NAME);
            }
            return currPriceGroupId;
        }
        private set;
    }

    /**
     * @description Sets current commerce context for LEX components.
     *
     * @param ctx Serialized JSON representing ccrz.cc_RemoteActionContext.
     */
    public static void setContext(String opportunitySfid) {
        try {
            currOpportunityId = opportunitySfid;

            STOREFRONT_NAME = getStoreFrontName(opportunitySfid);
            ccrz.cc_RemoteActionContext remoteActionContext = new ccrz.cc_RemoteActionContext();
            remoteActionContext.storefront = STOREFRONT_NAME;
            System.debug('remoteActionContext.storefront..'+remoteActionContext.storefront);

            if (currPriceGroupId != '') {
                remoteActionContext.priceGroupId = currPriceGroupId;
            }
            ccrz.cc_CallContext.init(remoteActionContext);

        } catch (Exception e) {
            throw new phss_cc_Exception(INIT_CONTEXT_ERROR_MSG);
        }
    }
	
    /**
     * @description Retrieves storefront name from opportunity
     *
     * @param opportunitySfid
     *
     * @return
     */
    public static String getStoreFrontName(String opportunitySfid)
    {
    	List<Opportunity> opp = [Select Id, Source_System__c From Opportunity Where Id = :opportunitySfid];
        if(!opp.isEmpty()) {
            if(opp[0].Source_System__c != null) {
                if(opp[0].Source_System__c == 'CRE') {
                    return 'CREStore';
                }
                else if(opp[0].Source_System__c == 'CPS') {
                    return 'CPS';
                }
             }
        }
        return STOREFRONT_NAME;    
    }
    
    
    /**
     * @description Retrieves the price group ID to enable contract pricing.
     *
     * @param currAccountId
     * @param storefrontName
     *
     * @return
     */
    public static String fetchPriceGroupIdByAccount(String currAccountId, String storefrontName)
    {
        String currPriceGroupId = '';
        List<ccrz__E_PriceGroupAccount__c> priceGroupAccountFetch =
        [
                SELECT
                        Id,
                        ccrz__PriceGroup__c
                FROM
                        ccrz__E_PriceGroupAccount__c
                WHERE
                ccrz__Account__c = :currAccountId
                AND
                ccrz__Enabled__c = true
                AND
                ccrz__Storefront__c = :storefrontName
                AND
                ccrz__PriceGroup__r.ccrz__Enabled__c = true
                AND
                ccrz__EffectiveStart__c <= :System.today()
                AND
                ccrz__EffectiveEnd__c > :System.today()
                AND
                ccrz__PriceGroup__r.ccrz__EffectiveStart__c <= :System.today()
                AND
                ccrz__PriceGroup__r.ccrz__EffectiveEnd__c > :System.today()
                LIMIT 1 ] ;
        if (!priceGroupAccountFetch.isEmpty())
        {
            ccrz__E_PriceGroupAccount__c currPriceGroupAccount = priceGroupAccountFetch.get(0);
            currPriceGroupId = currPriceGroupAccount.ccrz__PriceGroup__c;
        }
        return currPriceGroupId;
    }
}