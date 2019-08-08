@isTest
public class skedResourceTrigger_Test {
    
    @isTest static void TestUpdateGeoLocation() {
        Map<string, sObject> mapTestData = skedDataSetup.setupCommonTestData();
        sked__Resource__c instructor1 = (sked__Resource__c)mapTestData.get('instructor1');
        sked__Resource__c instructor2 = (sked__Resource__c)mapTestData.get('instructor2');
        
        skedGoogleApi_Mock mockClass = new skedGoogleApi_Mock();
        mockClass.calloutMethod = 'getGeocode';
        Test.setMock(HttpCalloutMock.class, mockClass);
        
        Test.startTest();
        
        instructor1.sked__Home_Address__c = '77 Rio Robles, San Jose, CA 95134';
        update instructor1;
        
        List<sked__Resource__c> resources = new List<sked__Resource__c>();
        instructor1.sked__Home_Address__c = '75 Rio Robles, San Jose, CA 95134';
        instructor2.sked__Home_Address__c = '75 Rio Robles, San Jose, CA 95134';
        resources.add(instructor1);
        resources.add(instructor2);
        update resources;
        
        Test.stopTest();
    }
    
}