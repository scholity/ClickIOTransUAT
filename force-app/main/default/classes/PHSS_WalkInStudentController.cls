public without sharing class PHSS_WalkInStudentController {
    
    @AuraEnabled
    public static Boolean isCommunityClass(String classId) {
        // Get ILT Class
        redwing__ILT_Class__c cls = [Select Id, Request_Type__c From redwing__ILT_Class__c Where Id = :classId Limit 1];
        if(cls.Request_Type__c == 'Community') {
            return true;
        }
        return false;
    }
    
    
    @AuraEnabled
    public static PHSS_CaseFormWrapper initCaseFormWrapper() {
        PHSS_CaseFormWrapper caseWrap = new PHSS_CaseFormWrapper();
        return caseWrap;
    }
    
    @AuraEnabled
    public static Map<String,String> createCase(String caseJson, String classId) {
        // Assign Walk-In Student Registration Cases to Registration Support Queue
        String caseAssignmentQueueName = 'Registration Support Queue';

        // Get ILT Class
        redwing__ILT_Class__c cls = [Select Id, Learning_Plan__r.Name, redwing__Start_Date__c, ltui__Start_Time_Formatted__c, 
                                            redwing__Location__r.Skedulo_Address__c, Skedulo_Job_Id__r.Name 
                                     From redwing__ILT_Class__c 
                                     Where Id = :classId Limit 1];
        
        PHSS_CaseFormWrapper caseWrap = (PHSS_CaseFormWrapper)JSON.deserialize(caseJson, PHSS_CaseFormWrapper.class);

        Group theQueue = [Select Id from Group where Name=:caseAssignmentQueueName LIMIT 1];
        
        Case cs = new Case();
        cs.RecordTypeId = [Select Id,Name From RecordType Where Name = 'Sales Case' Limit 1].Id;
        cs.Type = 'Community Course Registration';
        cs.Case_Sub_Type__c = 'New Registration';
        cs.Status = 'New';
        cs.Origin = 'Community';
        cs.Channel__c = 'Community';
        cs.System__c = 'Instructor Corner';
        cs.OwnerId = theQueue.Id;
        cs.Transferred_to_RSG__c = 'N';
        
        User usr = [Select Id,ContactId From User Where Id = :UserInfo.getUserId() Limit 1];
        cs.Instructor_Account__c = [Select Id,AccountId From Contact Where Id = :usr.ContactId Limit 1].AccountId;
        cs.Instructors_Name__c = UserInfo.getName();
        cs.Subject = 'Walk-In Registration for ' + caseWrap.firstName + ' ' + caseWrap.lastName + ' ' + cls.Learning_Plan__r.Name;
        if (usr.ContactId != null) {
            cs.ContactId = usr.ContactId;
        }
        if (cs.Instructor_Account__c != null) {
            cs.AccountId = cs.Instructor_Account__c;
        }
        
        
        String location = '';
        List<redwing__ILT_Session__c> sessionList = [Select Id,redwing__Location__c,
                                                            redwing__Location__r.Name,
                                                            redwing__Location__r.redwing__Address_1__c,
                                                            redwing__Location__r.redwing__Address_2__c,
                                                            redwing__Location__r.redwing__City__c,
                                                            redwing__Location__r.redwing__State__c,
                                                            redwing__Location__r.redwing__Country__c,
                                                            redwing__Location__r.redwing__Postal_Code__c
                                                     From redwing__ILT_Session__c 
                                                     Where redwing__ILT_Class__c = :classId 
                                                     Order By CreatedDate ASC];
        if(!sessionList.isEmpty() && sessionList[0].redwing__Location__c != null) {  
            String name = '';
            String addr1 = '';
            String addr2 = '';
            String city = '';
            String state = '';
            String zip = '';
 
            if(sessionList[0].redwing__Location__r.Name != null) {
                location = sessionList[0].redwing__Location__r.Name + ',';    
            }
            if(sessionList[0].redwing__Location__r.redwing__Address_1__c != null) {
                location += '\n' + sessionList[0].redwing__Location__r.redwing__Address_1__c + ',';    
            } 
            if(sessionList[0].redwing__Location__r.redwing__Address_2__c != null) {
                location += '\n' + sessionList[0].redwing__Location__r.redwing__Address_2__c + ',';    
            }
            if(sessionList[0].redwing__Location__r.redwing__City__c != null) {
                location += '\n' + sessionList[0].redwing__Location__r.redwing__City__c + ',';    
            }
            if(sessionList[0].redwing__Location__r.redwing__State__c != null) {
                location += '\n' + sessionList[0].redwing__Location__r.redwing__State__c + ',';    
            }
            if(sessionList[0].redwing__Location__r.redwing__Postal_Code__c != null) {
                location += '\n' + sessionList[0].redwing__Location__r.redwing__Postal_Code__c;    
            }
        }       
      
        String jobNumber = '';
        if(cls.Skedulo_Job_Id__r.Name != null) {
            jobNumber = cls.Skedulo_Job_Id__r.Name;    
        }
        
        cs.Description = 'Class Name: '+ cls.Learning_Plan__r.Name
                         + '\n Date: '+ cls.redwing__Start_Date__c.format()
                         + '\n Time: '+ cls.ltui__Start_Time_Formatted__c
                         + '\n Location: '+ location
                         + '\n Job Number: '+ jobNumber
                         + '\n Learner Evaluation: Pass'
                         + '\n Student First Name: '+ caseWrap.firstName
                         + '\n Student Last Name: '+ caseWrap.lastName
                         + '\n Student Email: '+ caseWrap.email
                         + '\n Student Phone: '+ caseWrap.phone;
        insert cs;    
            
        Map<String,String> resultMap = new Map<String,String>();
        resultMap.put('CaseNumber',[Select Id, CaseNumber From Case Where Id = :cs.Id Limit 1].CaseNumber);
        resultMap.put('CourseName',cls.Learning_Plan__r.Name);
        resultMap.put('Date',cls.redwing__Start_Date__c.format());
        
        return resultMap;
    }
}