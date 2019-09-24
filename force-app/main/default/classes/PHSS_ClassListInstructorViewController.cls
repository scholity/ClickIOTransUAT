public without sharing class PHSS_ClassListInstructorViewController {
    
    @AuraEnabled
    public static List<sObject> getPicklistValues(String objName, String accId) {
        User usr = [SELECT id, ContactId, Name, Profile.Name, Profile.UserLicense.Name FROM User WHERE id=: UserInfo.getUserId()];
        String sQuery = '';
        List <sObject> returnList = new List <sObject> ();
        
        if(objName == 'Account')
        {
            sQuery =  'Select id, Name From ' +objName + ' Where id in (SELECT AccountId FROM AccountContactRelation WHERE ContactId = \'' +usr.ContactId+'\') Order By Name ASC';
        }
        else if(ObjName == 'User')
        {
            List<String> ListRolesName= new List<String> {'Administrator','Instructor'};
                Boolean isInstructor = isInstructor(accId);
            
            if(isInstructor) {
                sQuery =  'Select id, Name From ' +objName + ' Where ContactId in (SELECT ContactId FROM AccountContactRelation WHERE AccountId = \'' +accId +'\' and ContactId = \'' +usr.ContactId+'\' and Roles IN: ListRolesName) Order By Name ASC';    
            }
            else {
                sQuery =  'Select id, Name From ' +objName + ' Where ContactId in (SELECT ContactId FROM AccountContactRelation WHERE AccountId = \'' +accId +'\' and Roles IN: ListRolesName) Order By Name ASC';    
            }
        }        
        List <sObject> lstOfRecords = Database.query(sQuery);
        return lstOfRecords;
    }
    
    @AuraEnabled
    public static List<ClassWrapper> getClasses(Integer offset, Integer limitOffset, Boolean isHistory, String accId, String instructorId) {        
        List<classWrapper> classWrapperList = new List<classWrapper>();
        limitOffset = Integer.valueOf(limitOffset);
        offset = Integer.valueOf(offset);
        Set<String> neededFields = new Set<String>{
            'Id'
                ,'redwing__ILT_Class__c'
                ,'redwing__ILT_Class__r.Name'
                ,'redwing__ILT_Class__r.ltui__Start_Time_Formatted__c'
                ,'redwing__ILT_Class__r.ltui__End_Time_Formatted__c'
                ,'redwing__ILT_Class__r.redwing__End_Date__c'
                ,'redwing__ILT_Class__r.redwing__Learning__c'
                ,'redwing__ILT_Class__r.redwing__Location__c'
                ,'redwing__ILT_Class__r.redwing__Location__r.redwing__Address_1__c'
                ,'redwing__ILT_Class__r.redwing__Location__r.redwing__City__c'
                ,'redwing__ILT_Class__r.redwing__Location__r.redwing__Country__c'
                ,'redwing__ILT_Class__r.redwing__Location__r.redwing__State__c'
                ,'redwing__ILT_Class__r.redwing__Location__r.redwing__Postal_Code__c'
                ,'redwing__ILT_Class__r.redwing__Start_Date__c'
                ,'redwing__ILT_Class__r.Offering_Id__c'
                ,'redwing__ILT_Class__r.Class_Closed_Date__c'
                ,'redwing__ILT_Class__r.' + RCConstants.APINAME_FIELD_ORGANIZATION
                ,'redwing__ILT_Session__c'
                ,'redwing__Instructor__c'
                ,'redwing__Instructor__r.Name'    
                ,'redwing__Primary__c '
                };
                    
                    String instructId;
        if(instructorId != null && !String.isBlank(instructorId)) {
            instructId = instructorId;
        }
        else {
            instructId = UserInfo.getUserId();
        }
        String query = 'SELECT ' + String.join(new List<String>(neededFields), ', ') + ' FROM redwing__ILT_Instructor__c WHERE redwing__ILT_Class__c != null ';
        
        // Account condition
        if(accId != null && accId != '') {
            query += ' AND redwing__ILT_Class__r.Skedulo_Account__c = :accId ';
        }
        
        if(instructorId != null && !String.isBlank(instructorId)) {
            query += ' AND redwing__Instructor__c = :instructorId ';    
        }
        else {
            query += ' AND redwing__Instructor__c = \'' + UserInfo.getUserId() + '\'';
        }
        
        if(isHistory){
            query +=  'AND redwing__ILT_Class__r.redwing__End_Date__c < TODAY ';
        } else {
            query +=  'AND redwing__ILT_Class__r.redwing__End_Date__c >= TODAY ';
        }
        
        query +=  'ORDER BY redwing__ILT_Class__r.Name ASC ';
        if(Integer.valueOf(limitOffset) != 0){
            query +=  'LIMIT :limitOffset OFFSET :offset';
        }
        System.debug('query - ' + query);
        List<redwing__ILT_Instructor__c> instructors = Database.query(query);
        
        System.debug('>> instructors - ' + instructors);
        
        Set<String> classIds = new Set<String>();
        List<String> classIdsToQuery = new List<String>();
        if(!instructors.isEmpty()){
            Set<String> learningIds = new Set<String>();
            for(redwing__ILT_Instructor__c item : instructors){
                learningIds.add(item.redwing__ILT_Class__r.redwing__Learning__c);
                classIdsToQuery.add(item.redwing__ILT_Class__c);
            }
            Map<String,  Map<String, redwing__Training_Plan__c>> learningId_tpaln = RCUtils.getPlanToLearningIds(learningIds);
            
            //To Handle number of students
            Map <Id, redwing__ILT_Class__c> classIdWithChildRecords = new Map <Id, redwing__ILT_Class__c>();
            if(classIdsToQuery.size() > 0)
            {
                String studentsChildQuery = 'SELECT Id, Name, (SELECT Id FROM Achievement_Assignments__r WHERE Achievement_Type__c = \'Certifications\' And (redwing__Status__c = \'Acquired\' OR redwing__Status__c = \'Eligible\')) from redwing__ILT_Class__c where Id In (\'' + String.join(classIdsToQuery, '\',\'') + '\')';
                classIdWithChildRecords = new Map<Id, redwing__ILT_Class__c>((List<redwing__ILT_Class__c>)Database.query(studentsChildQuery));
            }
            
            for(redwing__ILT_Instructor__c item : instructors){
                if(!classIds.contains(item.redwing__ILT_Class__c)){    
                    // Duration
                    Integer duration = 0;
                    if(item.redwing__ILT_Class__r.redwing__Start_Date__c != null && item.redwing__ILT_Class__r.redwing__End_Date__c != null){
                        duration = getCountDays(item.redwing__ILT_Class__r.redwing__Start_Date__c, item.redwing__ILT_Class__r.redwing__End_Date__c);
                    }
                    
                    // Location
                    LocationWrapper currentLocation = new LocationWrapper();
                    if(item.redwing__ILT_Class__r.redwing__Location__c != null){
                        currentLocation.city        = item.redwing__ILT_Class__r.redwing__Location__r.redwing__City__c;
                        currentLocation.address1    = item.redwing__ILT_Class__r.redwing__Location__r.redwing__Address_1__c;
                        currentLocation.country     = item.redwing__ILT_Class__r.redwing__Location__r.redwing__Country__c;
                        currentLocation.province    = item.redwing__ILT_Class__r.redwing__Location__r.redwing__State__c;
                        currentLocation.postalCode  = item.redwing__ILT_Class__r.redwing__Location__r.redwing__Postal_Code__c;
                    }
                    
                    // Status 
                    String classStatus = RCConstants.STATUS_UPCOMING;
                    if(item.redwing__ILT_Class__r.redwing__Start_Date__c <= datetime.now()){
                        classStatus = RCConstants.STATUS_IN_PROGRESS;
                    }
                    if(item.redwing__ILT_Class__r.redwing__End_Date__c <= datetime.now()){
                        classStatus = RCConstants.STATUS_COMPLETED;
                    }
                    if(item.redwing__ILT_Class__r.Class_Closed_Date__c != null) {
                        classStatus = RCConstants.STATUS_REPORTED;
                    }
                    
                    String currentLearnId = item.redwing__ILT_Class__r.redwing__Learning__c;
                    if(learningId_tpaln.containsKey(currentLearnId)){
                        Map<String, redwing__Training_Plan__c> plansById = learningId_tpaln.get(currentLearnId);
                        for(String pId : plansById.keySet()){
                            
                            //Handle number of students
                            Integer numberOfStudentsInClass = 0;
                            If(classIdWithChildRecords.containsKey(item.redwing__ILT_Class__c))
                            {
                                If(classIdWithChildRecords.get(item.redwing__ILT_Class__c).Achievement_Assignments__r != null)
                                    numberOfStudentsInClass = classIdWithChildRecords.get(item.redwing__ILT_Class__c).Achievement_Assignments__r.size();
                            }
                            
                            classWrapper tempClassWrap = new classWrapper(item, plansById.get(pId), currentLocation, classStatus, duration, numberOfStudentsInClass);
                            classWrapperList.add(tempClassWrap);
                        }
                    } else{
                        //Handle number of students
                        Integer numberOfStudentsInClass = 0;
                        If(classIdWithChildRecords.containsKey(item.redwing__ILT_Class__c))
                        {
                            If(classIdWithChildRecords.get(item.redwing__ILT_Class__c).Achievement_Assignments__r != null)
                                numberOfStudentsInClass = classIdWithChildRecords.get(item.redwing__ILT_Class__c).Achievement_Assignments__r.size();
                        }
                        
                        classWrapper tempClassWrap = new classWrapper(item, null, currentLocation, classStatus, duration, numberOfStudentsInClass);
                        classWrapperList.add(tempClassWrap);
                    }
                    
                    /*classWrapper tempClassWrap = new classWrapper(item, currentLocation, classStatus, duration);
classWrapperList.add(tempClassWrap);*/
                }
            }
        }
        return classWrapperList;         
    }
    
    public static Integer getCountDays(Date startDate, Date endDate){
        Integer result = startDate.daysBetween(endDate);
        result += 1;
        return result;
    }
    
    public static Boolean isInstructor(String accId) {
        User usr = [Select Id,Name,Profile.Name, ContactId From User Where Id = :UserInfo.getUserId()];  
        if(usr.Profile.Name.containsIgnoreCase('partner')) 
        {
            List<AccountContactRelation> accountConRelation = [select id, Roles from AccountContactRelation where AccountId =: accId And ContactId =: usr.ContactId AND Roles includes ('Administrator')];
            if(accountConRelation.size() > 0)
                return false;
            else
                return true;
        }
        return true;
    }
    
    public with sharing class ClassWrapper {
        @AuraEnabled public String classId          = '';
        @AuraEnabled public String className        = '';
        @AuraEnabled public String classOfferingId  = '';
        @AuraEnabled public String lpName           = '';
        @AuraEnabled public String lplanId          = '';
        @AuraEnabled public Date startDate;
        @AuraEnabled public Date endDate;
        @AuraEnabled public String startTime        = '';
        @AuraEnabled public String endTime          = '';
        @AuraEnabled public Integer days            = 0;
        @AuraEnabled public String instructorName   = '';
        @AuraEnabled public String company          = '';
        @AuraEnabled public locationWrapper location;
        @AuraEnabled public String classSettings    = '';
        @AuraEnabled public String status           = '';
        @AuraEnabled public Integer numberOfStudents;
        
        public ClassWrapper(redwing__ILT_Instructor__c instructor, redwing__Training_Plan__c plan, locationWrapper currentLocation, String classStatus, Integer duration, Integer numberOfStudents){
            system.debug(instructor.redwing__ILT_Class__r.redwing__Start_Date__c + 'Start Date');
            this.classId      = instructor.redwing__ILT_Class__c;
            this.classOfferingId = instructor.redwing__ILT_Class__r.Offering_Id__c;
            this.className    = instructor.redwing__ILT_Class__r.Name;
            this.startDate    = instructor.redwing__ILT_Class__r.redwing__Start_Date__c;
            this.endDate      = instructor.redwing__ILT_Class__r.redwing__End_Date__c;
            this.startTime    = instructor.redwing__ILT_Class__r.ltui__Start_Time_Formatted__c;
            this.endTime      = instructor.redwing__ILT_Class__r.ltui__End_Time_Formatted__c;
            this.location     = currentLocation;
            this.status       = classStatus;
            this.days         = duration;
            this.instructorName = instructor.redwing__Instructor__r.Name;
            this.numberOfStudents  = numberOfStudents;
            String tempCompany = instructor.redwing__ILT_Class__r.Skedulo_Account__r.Name;
            this.company      = String.isNotBlank(tempCompany) ? tempCompany : '';
            
            if(plan != null) {
                Set<String> fieldNameSet = plan.getPopulatedFieldsAsMap().keySet();
                
                this.lplanId = plan.Id;
                if(fieldNameSet.contains('Name')) {
                    this.lpName = plan.Name;
                }
                if(fieldNameSet.contains(RCConstants.APINAME_FIELD_CLASSSETTINGS)) {
                    this.classSettings = (String)plan.get(RCConstants.APINAME_FIELD_CLASSSETTINGS);
                }
            }
        }
    }
    
    public with sharing class locationWrapper {
        @AuraEnabled public String city         = '';
        @AuraEnabled public String address1     = '';
        @AuraEnabled public String country      = '';
        @AuraEnabled public String province     = '';
        @AuraEnabled public String postalCode   = '';
    }
}