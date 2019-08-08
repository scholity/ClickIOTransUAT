@isTest
public class skedActivityTrigger_Test {

	static testmethod void mainTest() {
    	Map<string, sObject> mapTestData = skedDataSetup.setupCommonTestData();
    	sked__Resource__c instructor2 = (sked__Resource__c)mapTestData.get('instructor2');

    	Test.startTest();

    	sked__Activity__c skedActivity = new sked__Activity__c(
    		sked__Start__c = system.now().addHours(1),
    		sked__End__c = system.now().addHours(2),
    		sked__Type__c = 'Leave',
    		sked__Resource__c = instructor2.Id,
    		sked__Address__c = 'meeting room'
		);
		insert skedActivity;

		skedActivity.sked__End__c = skedActivity.sked__End__c.addHours(1);
		update skedActivity;

		delete skedActivity;

    	Test.stopTest();
    }

}