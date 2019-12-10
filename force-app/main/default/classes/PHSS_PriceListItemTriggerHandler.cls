/************************************************************************************************************************************
** Author: Salesforce Services
** Description: This is the trigger handler class for the price list item trigger
************************************************************************************************************************************/
public class PHSS_PriceListItemTriggerHandler {
    public PHSS_PriceListItemTriggerHandler(){}

    /************************************************************************************************************************************
    ** Author: Salesforce Services
    ** Description: This method to block the issued vouchers for load balancing and vice versa
    ************************************************************************************************************************************/
    public void UpdatePriceOverridesInILTClassRecords(List<ccrz__E_PriceListItem__c> newPLItems, List<ccrz__E_PriceListItem__c> oldPLItems,
		Map<Id,ccrz__E_PriceListItem__c> newPLItemMap , Map<Id,ccrz__E_PriceListItem__c> oldPLItemMap) {

		// List of products with modified prices at the price item level
		
		Set <Id> priceListItemIds = new Set <Id>();
        Set <Id> priceListProducts = new Set <Id>();
		
		for (ccrz__E_PriceListItem__c theNewPLItem : newPLItems) {
			Decimal newPrice = theNewPLItem.ccrz__Price__c;
			if (oldPLItemMap.get(theNewPLItem.Id) != null) {
				// Presence of an old PriceListItemId indicates an existing PriceListItemId is being updated;
				// process only if price field has been updated
				Decimal oldPrice = oldPLItemMap.get(theNewPLItem.Id).ccrz__Price__c;
				if (oldPrice != null && newPrice != oldPrice) priceListItemIds.add(theNewPLItem.Id);
			} else {
				// Lack of an old PriceListItemId indicates a new PriceListItemId is being inserted; force processing
				priceListItemIds.add(theNewPLItem.Id);
			}
		}
		
		// Fetch all zips (names) of price lists which have modified prices
		List <ccrz__E_PriceListItem__c> pricelistNames = [Select Id, ccrz__StartDate__c, ccrz__EndDate__c, ccrz__Product__c, ccrz__Price__c, 
			ccrz__Pricelist__r.Name, ccrz__Pricelist__r.ccrz__StartDate__c, ccrz__Pricelist__r.ccrz__EndDate__c, 
			ccrz__Pricelist__r.ccrz__StoreFront__c From ccrz__E_PriceListItem__c 
			Where Id In :priceListItemIds];
			
		Set <String> zipCodes = new Set<String>();
		Map <String, Set<ccrz__E_PriceListItem__c>> zipcodeItemMap = new Map <String, Set<ccrz__E_PriceListItem__c>>();
		
		for (ccrz__E_PriceListItem__c thePriceListItem : pricelistNames) {
			if (thePriceListItem.ccrz__Pricelist__r.ccrz__StoreFront__c != null && thePriceListItem.ccrz__Pricelist__r.ccrz__StoreFront__c == 'GeneralStore') {
				String prefix = (thePriceListItem.ccrz__Pricelist__r.Name.length() > 4) ? thePriceListItem.ccrz__Pricelist__r.Name.substring(0,4) : '';
				if (prefix == 'ZIP-') {
					String zipCode = thePriceListItem.ccrz__Pricelist__r.Name.substring(4);
					if (zipCode != null && zipCode.length() == 5) {
						zipCodes.add(zipCode);	
						Set<ccrz__E_PriceListItem__c> priceOverrides = new Set<ccrz__E_PriceListItem__c>();
						if (zipcodeItemMap.get(zipCode) != null) priceOverrides = zipcodeItemMap.get(zipCode);
						priceOverrides.add(thePriceListItem);
                        priceListProducts.add(thePriceListItem.ccrz__Product__c);
						zipcodeItemMap.put(zipCode, priceOverrides);
					}
				}	
			}	
		}
		System.debug('zipCodes='+zipCodes);
		System.debug('zipcodeItemMap='+zipcodeItemMap);
        System.debug('priceListProducts='+priceListProducts);
		
		// Find all Community classes for these products being delivered to a location with these zip codes
		
		List<redwing__ILT_Class__c> communityClasses = [Select Id, Price_Override__c, redwing__Location__r.redwing__Postal_Code__c,  
			Request_Type__c, Cloud_Craze_Product__c, redwing__Start_Date__c, Skedulo_Job_Id__c
			From redwing__ILT_Class__c
			Where redwing__Location__c != null AND Cloud_Craze_Product__c != null 
                AND redwing__Location__r.redwing__Postal_Code__c In :zipCodes 
                AND Cloud_Craze_Product__c IN :priceListProducts                                        
                AND Request_Type__c = 'Community'
				AND redwing__Start_Date__c >= TODAY Order by Skedulo_Job_Id__c];
		System.debug('Number of communityClasses='+communityClasses.size());
				
        Set <Id> classIds = new Set<Id>();
        List <redwing__ILT_Class__c> updatedClasses = new List <redwing__ILT_Class__c>();
        
        for (redwing__ILT_Class__c theClass : communityClasses) {
			// DE2051 - 12-7-2019 (SJC) - Removed this constraint per Dalia 
			// Update ILT Class (if override exists) regardless of whether there is an existing price override value in current ILT Class record
        	//if (theSession.redwing__ILT_Class__r.Price_Override__c != null) {
        		Set<ccrz__E_PriceListItem__c> priceOverrides = zipcodeItemMap.get(theClass.redwing__Location__r.redwing__Postal_Code__c);
        		
        		for (ccrz__E_PriceListItem__c thePriceListItem : priceOverrides) {
	        		if (thePriceListItem != null && theClass.Cloud_Craze_Product__c != null &&
	        			thePriceListItem.ccrz__Product__c == theClass.Cloud_Craze_Product__c) {
	        			
			        	Boolean itemStartDate = true;
						Boolean itemEndDate = true;
						Boolean listStartDate = true;
						Boolean listEndDate = true;
						Date classDate = theClass.redwing__Start_Date__c;
							        				
						if (thePriceListItem.ccrz__PriceList__r.ccrz__StartDate__c != null) {
							if (thePriceListItem.ccrz__PriceList__r.ccrz__StartDate__c > classDate) listStartDate = false;
						}
						if (thePriceListItem.ccrz__PriceList__r.ccrz__EndDate__c != null) {
							if (thePriceListItem.ccrz__PriceList__r.ccrz__EndDate__c < classDate) listEndDate = false;
						}	
						if (thePriceListItem.ccrz__StartDate__c != null) {
							if (thePriceListItem.ccrz__StartDate__c > classDate) itemStartDate = false;
						}
						if (thePriceListItem.ccrz__EndDate__c != null) {
							if (thePriceListItem.ccrz__EndDate__c < classDate) itemEndDate = false;
						}
						
						if (itemStartDate && itemEndDate && listStartDate && listEndDate) {
							// Update price in ILT Class record
							redwing__ILT_Class__c theUpdatedClass = new redwing__ILT_Class__c();
							theUpdatedClass.Id = theClass.Id;
							theUpdatedClass.Price_Override__c = thePriceListItem.ccrz__Price__c;
							updatedClasses.add(theUpdatedClass);
						}
	        		}
        		}
        	//}
        }
        try {
        	update(updatedClasses);
        } catch (exception e) {
        	
        }
    }
}