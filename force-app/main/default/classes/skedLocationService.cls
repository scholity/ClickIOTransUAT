global class skedLocationService {
    
    @future(callout=true)
    global static void updateGeoLocation(String idList, string objectType) {
        string[] recordIds = idList.split(';');
        List<sObject> records = new List<sObject>();
        
        if (objectType == 'job') {  
            records = [SELECT Id, sked__Address__c FROM sked__Job__c WHERE Id IN :recordIds];
        } 
        else if (objectType == 'location') {  
            records = [SELECT Id, sked__Address__c FROM sked__Location__c WHERE Id IN :recordIds];
        } 
        else if (objectType == 'resource') {  
            records = [SELECT Id, sked__Home_Address__c, sked__User__c FROM sked__Resource__c WHERE Id IN :recordIds];
        } 
        else {
            return;
        }
        
        string addressFieldName = 'sked__Address__c';
        if (objectType == 'resource') {
            addressFieldName = 'sked__Home_Address__c';
        }
        for (sObject record : records) {
            string address = string.valueOf(record.get(addressFieldName));
            if (string.isBlank(address)) {
                record.put('sked__GeoLocation__latitude__s', null);
                record.put('sked__GeoLocation__longitude__s', null);
                continue;
            }
            skedGoogleData.geocodeResult result = skedGoogleServiceApi.getGeocode(address);
            system.debug('#result#' + result);
            if (result.hasError == false) {
                skedGoogleData.geocodeResultItem geoData = result.results.get(0);
                record.put('sked__GeoLocation__latitude__s', geoData.geometry.location.lat);
                record.put('sked__GeoLocation__longitude__s', geoData.geometry.location.lng);
            }
        }
        update records;
    }
    
}