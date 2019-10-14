public without sharing class ClassListInstructorCPSController 
{
    @AuraEnabled
    public static List<sObject> getPicklistValues(String objName, String accId) 
    {
        User usr = [SELECT id, ContactId, Name, Profile.Name, Profile.UserLicense.Name FROM User WHERE id=: UserInfo.getUserId()];
        String sQuery = '';
        if(objName == 'Account')
        {
            sQuery =  'Select id, Name From ' +objName + ' Where id in (SELECT AccountId FROM AccountContactRelation WHERE ContactId = \'' +usr.ContactId+'\') Order By Name ASC';
        }   
        List <sObject> lstOfRecords = Database.query(sQuery);
        return lstOfRecords;
    }
    
    @AuraEnabled
    public static List<ClassWrapper> getClasses(Integer offset, Integer limitOffset, String accId, String startDateFrom, String startDateTo, String courseId) 
    {        
        List<classWrapper> classWrapperList = new List<classWrapper>();
        limitOffset = Integer.valueOf(limitOffset);
        offset = Integer.valueOf(offset);
        Set<String> neededFields = new Set<String>{
            'Id'
                ,'Id'
                ,'Name'
                ,'ltui__Start_Time_Formatted__c'
                ,'ltui__End_Time_Formatted__c'
                ,'redwing__End_Date__c'
                ,'redwing__Learning__c'
                ,'redwing__Location__c'
                ,'redwing__Learning__r.Name'
                ,'redwing__Location__r.Name'
                ,'redwing__Location__r.redwing__Address_1__c'
                ,'redwing__Location__r.redwing__City__c'
                ,'redwing__Location__r.redwing__Country__c'
                ,'redwing__Location__r.redwing__State__c'
                ,'redwing__Location__r.redwing__Postal_Code__c'
                ,'redwing__Start_Date__c'
                ,'Offering_Id__c'
                ,'Class_Closed_Date__c'
                ,'Skedulo_Account__c'
                ,'Account__c'
                ,'Account__r.Name'
                ,'Skedulo_Account__r.Name'
                ,'CC_Order_Number__r.Name'
                ,'CPS_Registration_URL__c'
                ,'CPS_Registration_Phone__c'
                ,'Registration_Fee__c'
                ,'Class_Online_From__c'
                ,'Class_Online_To__c'
                ,'createdby.Name'
                ,'CreatedDate'
                ,'Request_Type__c'
                };
                    
                    String query = 'SELECT ' + String.join(new List<String>(neededFields), ', ') + ' FROM redwing__ILT_Class__c WHERE Id != null And Request_Type__c = \'CPS\'';
        
        // Account condition
        if(accId != null && accId != '') {
            query += ' AND Skedulo_Account__c = :accId ';
        }
        
        //Start Date Condition
        date dateStartDateFrom;
        If(!String.isBlank(startDateFrom))
        {
            dateStartDateFrom = date.valueOf(startDateFrom);
            query += ' AND redwing__Start_Date__c >= : dateStartDateFrom ';  
        }
        else
        {
            if(!String.isBlank(startDateTo))
                dateStartDateFrom = date.valueOf(startDateTo) - 30;
            else
                dateStartDateFrom = system.today();
            
            query += ' AND redwing__Start_Date__c >= : dateStartDateFrom ';  
        }
        
        date dateStartDateTo;
        If(!String.isBlank(startDateTo))
        {
            dateStartDateTo = date.valueOf(startDateTo);
            query += ' AND redwing__Start_Date__c <= : dateStartDateTo ';  
        }
        else
        {
            if(!String.isBlank(startDateFrom))
                dateStartDateTo = date.valueOf(startDateFrom) + 30;
            else
                dateStartDateTo = system.today() + 30;
            
            query += ' AND redwing__Start_Date__c <= : dateStartDateTo '; 
        }
        
        //Course Id Condition
        if(!String.isBlank(courseId))
            query += ' AND redwing__Learning__c = : courseId '; 
        
        System.debug('courseId - ' + courseId);
        query +=  'ORDER BY redwing__Learning__r.Name ASC ';
        
        if(Integer.valueOf(limitOffset) != 0){
            query +=  'LIMIT :limitOffset OFFSET :offset';
        }
        System.debug('query - ' + query);
        List<redwing__ILT_Class__c> cpsClassesList = Database.query(query);
        
        System.debug('>> cpsClassesList - ' + cpsClassesList);
        
        for(redwing__ILT_Class__c item : cpsClassesList)
        {
            // Location
            LocationWrapper currentLocation = new LocationWrapper();
            if(item.redwing__Location__c != null){
                currentLocation.city        = item.redwing__Location__r.redwing__City__c;
                currentLocation.address1    = item.redwing__Location__r.redwing__Address_1__c;
                currentLocation.country     = item.redwing__Location__r.redwing__Country__c;
                currentLocation.province    = item.redwing__Location__r.redwing__State__c;
                currentLocation.postalCode  = item.redwing__Location__r.redwing__Postal_Code__c;
            }
            classWrapper tempClassWrap = new classWrapper(item, currentLocation);
            classWrapperList.add(tempClassWrap);
        }
        return classWrapperList;         
    }
    
    public with sharing class ClassWrapper
    {
        @AuraEnabled public String facilityName    = '';
        @AuraEnabled public String courseId    = '';
        @AuraEnabled public String courseName   = '';
        @AuraEnabled public String classId   = '';
        @AuraEnabled public String accountName      = '';
        @AuraEnabled public String orderNumber      = '';
        @AuraEnabled public String classOfferingId  = '';
        @AuraEnabled public String className        = '';
        @AuraEnabled public Date startDate;
        @AuraEnabled public Date endDate;
        @AuraEnabled public String startTime        = '';
        @AuraEnabled public String endTime          = '';
        @AuraEnabled public locationWrapper location;
        @AuraEnabled public String locationName   = '';
        @AuraEnabled public String CPSRegistrationURL      = '';
        @AuraEnabled public String CPSRegistrationPhone      = '';
        @AuraEnabled public Decimal registrationFee;
        @AuraEnabled public Date classOnlineFrom;
        @AuraEnabled public Date classOnlineTo;
        @AuraEnabled public String createdByName     = '';
        @AuraEnabled public DateTime createdDateandTime;
        @AuraEnabled public String requestType     = '';
        
        public ClassWrapper(redwing__ILT_Class__c iltClass, locationWrapper currentLocation)
        {
            if(iltClass.Skedulo_Account__c != null)
                this.accountName = iltClass.Skedulo_Account__r.Name;
            if(iltClass.Account__c != null)
                this.facilityName = iltClass.Account__r.Name;
            this.courseId = iltClass.redwing__Learning__c;
            if(iltClass.redwing__Learning__c != null)
                this.courseName = iltClass.redwing__Learning__r.Name;
            if(iltClass.redwing__Location__c != null)
                locationName = iltClass.redwing__Location__r.Name;
            this.classId = iltClass.Id;
            this.orderNumber = iltClass.CC_Order_Number__r.Name;
            this.classOfferingId = iltClass.Offering_Id__c;
            this.className    = iltClass.Name;
            this.startDate    = iltClass.redwing__Start_Date__c;
            this.endDate      = iltClass.redwing__End_Date__c;
            this.startTime    = iltClass.ltui__Start_Time_Formatted__c;
            this.endTime      = iltClass.ltui__End_Time_Formatted__c;
            this.location     = currentLocation;
            this.CPSRegistrationURL = iltClass.CPS_Registration_URL__c;
            this.CPSRegistrationPhone = iltClass.CPS_Registration_Phone__c;
            this.registrationFee = iltClass.Registration_Fee__c;
            this.classOnlineFrom = iltClass.Class_Online_From__c;
            this.classOnlineTo = iltClass.Class_Online_To__c;
            this.createdByName = iltClass.createdby.Name;
            this.createdDateandTime = iltClass.CreatedDate;
            this.requestType = iltClass.Request_Type__c;
        }
    }
    
    public with sharing class locationWrapper 
    {
        @AuraEnabled public String city         = '';
        @AuraEnabled public String address1     = '';
        @AuraEnabled public String country      = '';
        @AuraEnabled public String province     = '';
        @AuraEnabled public String postalCode   = '';
    }
}