@isTest 
private class PHSS_InstructorCertificationCTRL_Test {
    static testMethod void testGetData() {
    
        Profile p = [select id from profile where name='System Administrator'];
        System.debug('System Administrator Profile ID : ' + p.id);
        User u = new User(alias = 'testAdm', email='testadmin@redcross.org', emailencodingkey='UTF-8', 
                lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', profileid = p.Id,
                timezonesidkey='America/Los_Angeles', username='testadmin@redcross.org');
        insert u;
        System.debug('System Administrator Test User ID : ' + u.id);        
        
        System.debug('Current User: ' + UserInfo.getUserName());
        System.debug('Current User ID: ' + UserInfo.getUserId());
        System.debug('Current Profile: ' + UserInfo.getProfileId());
        
        PHSS_Instructor_Certification__c cert = new PHSS_Instructor_Certification__c();
        cert.Certification_Name__c = 'Test Certificate';
        Date expDate = Date.today();
        cert.Expired_On__c = expDate;
        cert.User__c = u.id;
        cert.OwnerId = u.id;
        insert cert;
        
        System.debug('PHSS_Instructor_Certification__c ID : ' + cert.id);
        
        List<PHSS_Instructor_Certification__c> listcerts = PHSS_InstructorCertificationController.getInstructorCertificationDetails(u.id);

        System.debug('PHSS_Instructor_Certification__c list : ' + listcerts);
        System.debug('PHSS_Instructor_Certification__c list.size() : ' + listcerts.size());        
                    
        System.assertEquals(listcerts.size(), 1);
       
    }
    static testMethod void testGetFilteredData() {
    
        Profile p = [select id from profile where name='System Administrator'];
        System.debug('System Administrator Profile ID : ' + p.id);
        User u = new User(alias = 'testAdm', email='testadmin@redcross.org', emailencodingkey='UTF-8', 
                lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', profileid = p.Id,
                timezonesidkey='America/Los_Angeles', username='testadmin@redcross.org');
        insert u;
        System.debug('System Administrator Test User ID : ' + u.id);        
        
        System.debug('Current User: ' + UserInfo.getUserName());
        System.debug('Current User ID: ' + UserInfo.getUserId());
        System.debug('Current Profile: ' + UserInfo.getProfileId());
        
        PHSS_Instructor_Certification__c cert = new PHSS_Instructor_Certification__c();
        cert.Certification_Name__c = 'Test Certificate';
        Date expDate = Date.today();
        cert.Expired_On__c = expDate;
        cert.User__c = u.id;
        cert.OwnerId = u.id;
        insert cert;
        
        System.debug('PHSS_Instructor_Certification__c ID : ' + cert.id);
        
        List<PHSS_Instructor_Certification__c> listcerts = PHSS_InstructorCertificationController.getInstructorCertificationDetailsFiltered(u.id, '1');

        System.debug('PHSS_Instructor_Certification__c list : ' + listcerts);
        System.debug('PHSS_Instructor_Certification__c list.size() : ' + listcerts.size());        
                    
        System.assertEquals(listcerts.size(), 1);
       
    }  
	static testMethod void testGetInstructorCertificationDetailsSorted() {
    
        Profile p = [select id from profile where name='System Administrator'];
        System.debug('System Administrator Profile ID : ' + p.id);
        User u = new User(alias = 'testAdm', email='testadmin@redcross.org', emailencodingkey='UTF-8', 
                lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', profileid = p.Id,
                timezonesidkey='America/Los_Angeles', username='testadmin@redcross.org');
        insert u;
        System.debug('System Administrator Test User ID : ' + u.id);        
        
        System.debug('Current User: ' + UserInfo.getUserName());
        System.debug('Current User ID: ' + UserInfo.getUserId());
        System.debug('Current Profile: ' + UserInfo.getProfileId());
        
        PHSS_Instructor_Certification__c cert = new PHSS_Instructor_Certification__c();
        cert.Certification_Name__c = 'Test Certificate';
        Date expDate = Date.today();
        cert.Expired_On__c = expDate;
        cert.User__c = u.id;
        cert.OwnerId = u.id;        
        insert cert;
        
        System.debug('PHSS_Instructor_Certification__c ID : ' + cert.id);

        Boolean sortOrder = TRUE;
        String sortColumn = 'Expired_On__C';
 		String numb = '1';
        List<PHSS_Instructor_Certification__c> listcerts = PHSS_InstructorCertificationController.getInstructorCertificationDetailsSorted(u.id,sortOrder, sortColumn, numb);

        System.debug('PHSS_Instructor_Certification__c list : ' + listcerts);
        System.debug('PHSS_Instructor_Certification__c list.size() : ' + listcerts.size());        
                    
        System.assertEquals(listcerts.size(), 1);
       
    }
    static testMethod void testForCoverage() {
        String uID = null;
        Boolean sortOrder = FALSE;
        String sortColumn = 'Expired_On__C';
 		String numb = 'X';        
        List<PHSS_Instructor_Certification__c> listcertsX = null;
        listcertsX = PHSS_InstructorCertificationController.getInstructorCertificationDetails(uID);
        uID = '';
        listcertsX = PHSS_InstructorCertificationController.getInstructorCertificationDetails(uID);
        uID = null;
		listcertsX = PHSS_InstructorCertificationController.getInstructorCertificationDetailsFiltered(uID, numb);       
        uID = '';
        listcertsX = PHSS_InstructorCertificationController.getInstructorCertificationDetailsFiltered(uID, numb);               
        uID = null;        
        listcertsX = PHSS_InstructorCertificationController.getInstructorCertificationDetailsSorted(uID, sortOrder, sortColumn, numb);
        uID = '';        
        listcertsX = PHSS_InstructorCertificationController.getInstructorCertificationDetailsSorted(uID, sortOrder, sortColumn, numb);
    }
}