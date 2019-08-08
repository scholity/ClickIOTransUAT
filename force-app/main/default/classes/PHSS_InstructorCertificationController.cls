public with sharing class PHSS_InstructorCertificationController {
    @AuraEnabled
    public static List<PHSS_Instructor_Certification__c> getInstructorCertificationDetailsSorted(String userID, Boolean sortOrder, String sortColumn, String numberOfElements){ 

        System.debug('PHSS_InstructorCertificationController.getInstructorCertificationDetailsSorted::userID           : ' +userID);
        System.debug('PHSS_InstructorCertificationController.getInstructorCertificationDetailsSorted::sortOrder        : ' +sortOrder);
        System.debug('PHSS_InstructorCertificationController.getInstructorCertificationDetailsSorted::usesortColumnrID : ' +sortColumn);
        System.debug('PHSS_InstructorCertificationController.getInstructorCertificationDetailsSorted::numberOfElements : ' +numberOfElements);

        if(userID == null){
            userID = UserInfo.getUserId();
        } else if (userID.equals('')){
            userID = UserInfo.getUserId();            
        }
        Integer castedNumberOfElements = 0;
        try {
			castedNumberOfElements = Integer.valueOf(numberOfElements);
        } catch (Exception e) {
            System.debug('PHSS_InstructorCertificationController exception : ' + e.getMessage());
        }
        // THIS QUERY ASSUMES OWNERID ON PHSS_Instructor_Certification__c HAS BEEN SET TO THE USER MATCHING THE SABA_Internal_ID__c VALUE - THE TRIGGER SHOULD DO THIS !
        String query = 'SELECT Acquired_On__c, Certification_Name__c, Certification_Version__c, Expired_On__c, ID, Name, isExpiring__c,' + 
            'SABA_Certificate_Number__c, SABA_Internal_ID__c, Status__c, User__c FROM PHSS_Instructor_Certification__c WHERE OWNERID =';

        query = query + '\'' + userID + '\'';
        query = query + ' and Expired_On__c >= TODAY ';
        if (sortColumn != null) {
	        if (sortColumn != '') {
            	query = query + ' ORDER BY ' + sortColumn;
                if (sortOrder) {           
                    query = query + ' ASC';
                } else {
                    query = query + ' DESC';
                }
    	    }
    	}
        if (castedNumberOfElements > 0) {
            query = query + ' LIMIT ' + castedNumberOfElements;
        }
        System.debug('query:'+query);
        List<PHSS_Instructor_Certification__c> certificateDetails = Database.query(query);
        return certificateDetails;        
    } 

    @AuraEnabled
    public static List<PHSS_Instructor_Certification__c> getInstructorCertificationDetails(String userID){ 
        if(userID == null){
            userID = UserInfo.getUserId();
        } else if (userID.equals('')){
            userID = UserInfo.getUserId();            
        } else {
        }
        // THIS QUERY ASSUMES OWNERID ON PHSS_Instructor_Certification__c HAS BEEN SET TO THE USER MATCHING THE SABA_Internal_ID__c VALUE - THE TRIGGER SHOULD DO THIS !
        List<PHSS_Instructor_Certification__c> certificateDetails = [SELECT Acquired_On__c, Certification_Name__c, 
                                                                     Certification_Version__c, Expired_On__c, ID, 
                                                                     Name, isExpiring__c, SABA_Certificate_Number__c, 
                                                                     SABA_Internal_ID__c, Status__c, User__c 
                                                                     FROM PHSS_Instructor_Certification__c 
                                                                     WHERE OWNERID =: userID and Expired_On__c >= TODAY ORDER BY Expired_On__c ASC];

        return certificateDetails;        
    } 
    @AuraEnabled
    public static List<PHSS_Instructor_Certification__c> getInstructorCertificationDetailsFiltered(String userID, String numberOfElements){ 
        if(userID == null){
            userID = UserInfo.getUserId();
        } else if (userID.equals('')){
            userID = UserInfo.getUserId();            
        } else {
        }
        Integer castedNumberOfElements = 0;
        try {
			castedNumberOfElements = Integer.valueOf(numberOfElements);
        } catch (Exception e) {
            System.debug('PHSS_InstructorCertificationController exception : ' + e.getMessage());
        }
        // THIS QUERY ASSUMES OWNERID ON PHSS_Instructor_Certification__c HAS BEEN SET TO THE USER MATCHING THE SABA_Internal_ID__c VALUE - THE TRIGGER SHOULD DO THIS !
        List<PHSS_Instructor_Certification__c> certificateDetailsFiltered = [SELECT Acquired_On__c, Certification_Name__c, 
                                                                     Certification_Version__c, Expired_On__c, ID, 
                                                                     Name, isExpiring__c, SABA_Certificate_Number__c, 
                                                                     SABA_Internal_ID__c, Status__c, User__c 
                                                                     FROM PHSS_Instructor_Certification__c 
                                                                     WHERE OWNERID =: userID and Expired_On__c >= TODAY ORDER BY Expired_On__c ASC
                                                                     LIMIT :castedNumberOfElements];

        return certificateDetailsFiltered;        
    }     
}