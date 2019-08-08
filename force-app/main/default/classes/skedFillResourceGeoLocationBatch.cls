global class skedFillResourceGeoLocationBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
	
	String query;
	list<string> recordIds = new list<string>();
	string objectType = '';
	
	global skedFillResourceGeoLocationBatch(list<string> ids,string ot) {
		recordIds = ids;
		objectType = ot;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		//query = 'select id,sked__Home_Address__c ,sked__GeoLocation__latitude__s , sked__GeoLocation__Longitude__s from sked__Resource__c where id in:rIds';

		if (objectType == 'job') {  
            query = 'SELECT Id, sked__Address__c FROM sked__Job__c WHERE Id IN :recordIds';
        } 
        else if (objectType == 'location') {  
            query = 'SELECT Id, sked__Address__c FROM sked__Location__c WHERE Id IN :recordIds';
        } 
        else if (objectType == 'resource') {  
            query = 'SELECT Id, sked__Home_Address__c, sked__User__c FROM sked__Resource__c WHERE Id IN :recordIds';
        } 
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
   		//list<sked__Resource__c> upList = new list<sked__Resource__c>();
   		//List<sObject> records = new List<sObject>();
   		string addressFieldName = 'sked__Address__c';
        if (objectType == 'resource') {
            addressFieldName = 'sked__Home_Address__c';
        }

		for (sObject record : scope) {
            string address = string.valueOf(record.get(addressFieldName));
            if (string.isBlank(address)) {
                record.put('sked__GeoLocation__latitude__s', null);
                record.put('sked__GeoLocation__longitude__s', null);
                continue;
            }
            skedGoogleData.geocodeResult result = skedGoogleServiceApi.getGeocode(address);
            if (result.hasError == false) {
                skedGoogleData.geocodeResultItem geoData = result.results.get(0);
                record.put('sked__GeoLocation__latitude__s', geoData.geometry.location.lat);
                record.put('sked__GeoLocation__longitude__s', geoData.geometry.location.lng);
            }
        }
        update scope;
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}