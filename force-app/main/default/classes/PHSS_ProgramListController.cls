public with sharing class PHSS_ProgramListController {
	@AuraEnabled
	public static List<PHSS_Program__c> getAllPrograms(){
		return [SELECT Id, Program_Long_Name__c, Instructor_Bulletin__c FROM PHSS_Program__c WHERE Archived__c = false ORDER BY Program_Long_Name__c];
	}

	@AuraEnabled
	public static List<PHSS_Program__c> getFeaturedPrograms(){
		return [SELECT Id, Program_Long_Name__c, Instructor_Bulletin__c FROM PHSS_Program__c WHERE Featured__c = true AND Archived__c = false ORDER BY Program_Long_Name__c];
	}
}