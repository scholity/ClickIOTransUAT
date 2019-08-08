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
		
		Set <Id> pricelistItemIds = new Set <Id>();
		
		for (ccrz__E_PriceListItem__c theNewPLItem : newPLItems) {
			Decimal newPrice = theNewPLItem.ccrz__Price__c;
			if (oldPLItemMap.get(theNewPLItem.Id) != null) {
				Decimal oldPrice = oldPLItemMap.get(theNewPLItem.Id).ccrz__Price__c;
				if (oldPrice != null && newPrice != oldPrice) pricelistItemIds.add(theNewPLItem.Id);
			}
		}
		
		// Fetch all zips (names) of price lists which have modified prices
		List <ccrz__E_PriceListItem__c> pricelistNames = [Select Id, ccrz__StartDate__c, ccrz__EndDate__c, ccrz__Product__c, ccrz__Price__c, 
			ccrz__Pricelist__r.Name, ccrz__Pricelist__r.ccrz__StartDate__c, ccrz__Pricelist__r.ccrz__EndDate__c, 
			ccrz__Pricelist__r.ccrz__StoreFront__c From ccrz__E_PriceListItem__c 
			Where Id In :pricelistItemIds];
			
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
						zipcodeItemMap.put(zipCode, priceOverrides);
					}
				}	
			}	
		}
		System.debug('zipCodes='+zipCodes);
		System.debug('zipcodeItemMap='+zipcodeItemMap);
		
		// Find all Community classes for these products being delivered to a location with these zip codes
		
		List<redwing__ILT_Session__c> communityClassSessions = [Select Id, redwing__ILT_Class__r.Id, redwing__ILT_Class__r.Price_Override__c,
			redwing__Location__r.redwing__Postal_Code__c, redwing__ILT_Class__r.Request_Type__c,
			redwing__ILT_Class__r.Cloud_Craze_Product__c, redwing__Date__c, Skedulo_Job_Id__c
			From redwing__ILT_Session__c
			Where redwing__Location__r.redwing__Postal_Code__c In :zipCodes AND redwing__ILT_Class__r.Request_Type__c = 'Community'
				AND redwing__Date__c >= TODAY Order by Skedulo_Job_Id__c];
		System.debug('Number of communityClassSession='+communityClassSessions.size());
				
        Set <Id> classIds = new Set<Id>();
        List <redwing__ILT_Class__c> updatedClasses = new List <redwing__ILT_Class__c>();
        
        // Skip all but the first session for a class (arbitrary which one is processed first)
        Id lastILTClass;
        for (redwing__ILT_Session__c theSession : communityClassSessions) {
			if (lastILTClass == null) {
				lastILTClass = theSession.redwing__ILT_Class__r.Id;
			} else {
				if (lastILTClass != theSession.redwing__ILT_Class__r.Id) {
					lastILTClass = theSession.redwing__ILT_Class__r.Id;
				} else continue;
			}
        	if (theSession.redwing__ILT_Class__r.Price_Override__c != null) {
        		Set<ccrz__E_PriceListItem__c> priceOverrides = zipcodeItemMap.get(theSession.redwing__Location__r.redwing__Postal_Code__c);
        		
        		for (ccrz__E_PriceListItem__c thePriceListItem : priceOverrides) {
	        		if (thePriceListItem != null && theSession.redwing__ILT_Class__r.Cloud_Craze_Product__c != null &&
	        			thePriceListItem.ccrz__Product__c == theSession.redwing__ILT_Class__r.Cloud_Craze_Product__c) {
	        			
			        	Boolean itemStartDate = true;
						Boolean itemEndDate = true;
						Boolean listStartDate = true;
						Boolean listEndDate = true;
						Date classDate = theSession.redwing__Date__c;
							        				
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
							theUpdatedClass.Id = theSession.redwing__ILT_Class__r.Id;
							theUpdatedClass.Price_Override__c = thePriceListItem.ccrz__Price__c;
							updatedClasses.add(theUpdatedClass);
						}
	        		}
        		}
        	}
        }
        try {
        	update(updatedClasses);
        } catch (exception e) {
        	
        }
    }
}