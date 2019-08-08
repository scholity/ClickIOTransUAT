@isTest
public class skedLocationTrigger_Test {

    @isTest static void MainTest() {
        Map<string, sObject> mapTestData = skedDataSetup.setupCommonTestData();
        sked__Location__c communityLocation1 = (sked__Location__c)mapTestData.get('communityLocation1');
        sked__Location__c communityLocation2 = (sked__Location__c)mapTestData.get('communityLocation2');
        
        skedGoogleApi_Mock mockClass = new skedGoogleApi_Mock();
        mockClass.calloutMethod = 'getGeocode';
        Test.setMock(HttpCalloutMock.class, mockClass);
        
        Test.startTest();
        
        communityLocation1.Is_Active__c = FALSE;
        update communityLocation1;
        
        communityLocation1.sked__Address__c = '77 Rio Robles, San Jose, CA 95134';
        update communityLocation1;
        
        List<sked__Location__c> locations = new List<sked__Location__c>();
        communityLocation1.sked__Address__c = '75 Rio Robles, San Jose, CA 95134';
        communityLocation2.sked__Address__c = '75 Rio Robles, San Jose, CA 95134';
        locations.add(communityLocation1);
        locations.add(communityLocation2);
        update locations;
        
        Test.stopTest();
    }
}