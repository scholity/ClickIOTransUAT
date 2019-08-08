/*****************************************************************************************************
Class    :  SurveyService
Author   :	Kiril Minev
Created  :  Dec 17, 2013

Last Modified By: 
Reason for Revision: 
Last Modified: 

Objective: The purpose of the class is to support integration between salesforce objects,modules the third party
		   survey tool.

Developer Comments:

*****************************************************************************************************/
public with sharing class SurveyService {
	
	
	private static final String SURVEY_TYPE_VALUE = 'Closed Case';
	 
	/*****************************************************************************************
	*	Purpose: Adding case owner to report card, because the case owner can change
	*		 and it will be hard to run a survey report based on agent who closed the case
	*		 TODO: Not in use
	*******************************************************************************************/
	public static void addCaseOwnerToReportCard(Map<Id, ReportCard__c> newMap) {
		
		try {
			//Case_Closed_By
			
			Map<Id, ReportCard__c> mapReortCardWithCases = new Map<Id, ReportCard__c>();//1st Id = CaseId, 2th Id = ReportCard__c 
			List<ReportCard__c> reportCardsToUpdate = new List<ReportCard__c>();
			
			for (ReportCard__c rc : newMap.values()) {
				
				if (rc.Case__c != null) {
					mapReortCardWithCases.put(rc.Case__c, rc);
				}
			}
			
			List<Case> cases = [Select Id, OwnerId FROM Case WHERE Id IN :mapReortCardWithCases.keySet()];
			
			System.debug('*** cases: ' + cases);
			
			for (Case c : cases) {
				
				ReportCard__c rp = mapReortCardWithCases.get(c.Id);
				
				rp.Case_Closed_By__c = c.OwnerId;
			}
			
			System.debug('*** report cards to update: ' + reportCardsToUpdate);
			
			update reportCardsToUpdate;
			
		}catch(System.Exception ex) {
			System.debug('*** Exception:' + ex);
            ExLog.log(ex);	
		}
		
	}
	
	/************************************************************************************************
	*	Description: Only use on after insert
	*	Purpose: Update survey object when survey is responded to
	*************************************************************************************************/
	public static void updateSurveyReponse(Map<Id, ReportCard__c> newMap){
		
		
		try {
			if (newMap != null) {
				
				//ContactId, ReportCard__c object
				Map<Id, ReportCard__c> mapContactToReportCard = new Map<Id, ReportCard__c>();
				
				for (ReportCard__c rcNew : newMap.values()) {
					
					mapContactToReportCard.put(rcNew.Contact__c, rcNew);
				}
				
				List<Survey__c> surveys = [SELECT Id, Contact__c FROM Survey__c WHERE Contact__c IN :mapContactToReportCard.keySet()];
				
				List<Survey__c> surveysResponded = new List<Survey__c>();
				
				if (surveys != null && surveys.size() > 0) {
					
					for (Survey__c survey :surveys) {
						survey.ReportCard__c = mapContactToReportCard.get(survey.Contact__c).Id;
						
						surveysResponded.add(survey);
					}
				}
				
				update surveysResponded;
				
			}
		}catch (Exception ex) {
			ExLog.log(ex);
		}
		
	}
	
	/************************************************************************************************
	*	
	*	Purpose: Update survey sent timestamp on contact object and insert survey object to report on
	*	surveys sent vs received and trending analytics
	*
	*************************************************************************************************/
	public static void updateContactSurveySentTimestamp(Map<Id, Case> newMap, Map<Id, Case> oldMap) {
		
		
		try {
			ETL_Configuration__c userAccessConfig = ETL_Configuration__c.getInstance(Userinfo.getUserId());
			Survey_Settings__c surveyConfig = Survey_Settings__c.getInstance(Userinfo.getUserId());
	
			if (surveyConfig.Is_Closed_Case_Survey_Active__c == false){
				System.debug('Suvery is disabled skip logic.');
				return;
			}
			
			
			if (userAccessConfig != null && userAccessConfig.Is_ETL_User__c == true) { // If a mass update is performed from an API user we don't want this to fire off
				
				ExLog.log('Contact Survey Sent Timestamp not updated due to  the user having ETL profile!', 'SurveyService');
				return;
			}
	
			if (oldMap != null) {
				
				List<Contact> contactsToUpdate = new List<Contact>();
				List<Survey__c> surveysSent = new List<Survey__c>();
				
				for (Case c :oldMap.values()) {
					
					if (c.IsClosed == false && newMap.get(c.Id).isClosed == true && newMap.get(c.Id).Survey_Sent_API__c == 'Sent') {
						
						contactsToUpdate.add(new Contact(Id = newMap.get(c.Id).ContactId));
						
						surveysSent.add(new Survey__c(Survey_Type__c = SurveyService.SURVEY_TYPE_VALUE, Contact__c = newMap.get(c.Id).ContactId, Case__c = c.Id));
					}
				}
				
				if (contactsToUpdate.size() > 0) {
					
					for (Contact ct :contactsToUpdate) {
						ct.Survey_Last_Sent__c = Datetime.now();//Update flag to capture when the contact last received a survey from closed case
					}
					
					try {
						update contactsToUpdate;
						insert surveysSent;
					}catch (Exception ex) {
						ExLog.log(ex);
					}
				}
			}
		}catch(Exception ex2){
			ExLog.log(ex2);
		}
		
	} 
	
}