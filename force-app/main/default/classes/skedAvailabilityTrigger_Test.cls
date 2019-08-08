@isTest
public class skedAvailabilityTrigger_Test {
    
    static testmethod void mainTest() {
    	Map<string, sObject> mapTestData = skedDataSetup.setupCommonTestData();
    	sked__Resource__c instructor2 = (sked__Resource__c)mapTestData.get('instructor2');

    	Test.startTest();

    	sked__Availability__c skedAvailability = new sked__Availability__c(
    		sked__Start__c = system.now().addHours(1),
    		sked__Finish__c = system.now().addHours(2),
    		sked__Type__c = 'Leave',
    		sked__Is_Available__c = FALSE,
    		sked__Resource__c = instructor2.Id,
    		sked__Status__c = 'Pending'
		);
		insert skedAvailability;

		skedAvailability.sked__Status__c = 'Approved';
		update skedAvailability;

    	Test.stopTest();
    }

}