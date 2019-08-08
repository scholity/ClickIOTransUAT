trigger trgr_ReportCard on ReportCard__c (after insert) {
	
	if (Trigger.isInsert && Trigger.isAfter) {
		SurveyService.updateSurveyReponse(Trigger.newMap);
	}
	
}