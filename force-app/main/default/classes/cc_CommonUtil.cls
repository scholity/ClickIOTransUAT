public with sharing class cc_CommonUtil
{
 
    public static List<ccrz__E_PriceGroupAccount__c> fetchPriceGroupAccounts(String accountId)
    {
        Date dateVal = Date.today();
         
        String storeName = ccrz.cc_CallContext.storefront;
 
        // check for null in dates of price group also
        return  [SELECT
                        ID,
                        ccrz__PriceGroup__c,
                        ccrz__PriceGroup__r.ccrz__GroupName__c
                    FROM
                    ccrz__E_PriceGroupAccount__c
                WHERE
                    ccrz__Account__c   = :accountId
                AND
                    ccrz__Enabled__c = true
                AND
                    ccrz__PriceGroup__r.ccrz__Enabled__c = true
                AND
                    (ccrz__EffectiveStart__c <= :dateVal OR ccrz__EffectiveStart__c = NULL)
                AND
                    (ccrz__EffectiveEnd__c > :dateVal OR ccrz__EffectiveEnd__c = NULL)
                 AND
                    ccrz__Storefront__c = : storeName
                AND
                   (ccrz__PriceGroup__r.ccrz__EffectiveStart__c <=  :dateVal OR ccrz__PriceGroup__r.ccrz__EffectiveStart__c = NULL)
                AND
                    (ccrz__PriceGroup__r.ccrz__EffectiveEnd__c > :dateVal OR ccrz__PriceGroup__r.ccrz__EffectiveEnd__c = NULL) LIMIT 2000 ];
        }
 
}