public class NewPriceListItemController {
    @AuraEnabled
    public static List<ccrz__E_PriceListItem__c> getPriceListItems(String productId) {
            return new List<ccrz__E_PriceListItem__c>();
    }
    
    @AuraEnabled
    public static Boolean savePriceListItems(List<ccrz__E_PriceListItem__c> priceListItems) {
        insert priceListItems;
        return true;
    }
    
    @AuraEnabled
    public static List<ccrz__E_PriceList__c> getAllPriceLists() {
        return [SELECT Id, Name, ccrz__Desc__c FROM ccrz__E_PriceList__c WHERE ccrz__Enabled__c = true];
    }
    
    
    @AuraEnabled
    public static Boolean createPriceListItems(String priceList, String startDate, String endDate, String subProdTermId, String product, String price, Integer maxQty, Integer minQty, Boolean recurringPrice, List<String> selectPriceLists) {
        ccrz__E_PriceListItem__c pli = new ccrz__E_PriceListItem__c();
        
        pli.ccrz__Pricelist__c = priceList;
        pli.ccrz__StartDate__c = (startDate == null || startDate == '')?null:Date.valueOf(startDate);
        pli.ccrz__EndDate__c = (endDate == null || endDate == '')?null:Date.valueOf(endDate);
        pli.ccrz__SubProdTerm__c = subProdTermId;
        pli.ccrz__Product__c = product;
        pli.ccrz__Price__c = (price == null || price == '')?null:Decimal.valueOf(price);
        pli.ccrz__MaxQty__c = maxQty;
        pli.ccrz__MinQty__c = minQty;
        pli.ccrz__RecurringPrice__c = recurringPrice;
        
        insert pli;
        return true;
    }
}