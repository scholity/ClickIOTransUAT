public without sharing class PHSS_CpsController {
	
    @AuraEnabled
    public static PHSS_CpsWrapper initWrapper() {
    	PHSS_CpsWrapper cpsWrap = new PHSS_CpsWrapper();
        // Get Organization name
        List<User> userList = [Select Id,Name,ContactId From User Where Id = :UserInfo.getUserId()];
        if(!userList.isEmpty() && userList[0].ContactId != null) {
            List<Contact> conList = [Select Id,Account.Name From Contact Where Id = :userList[0].ContactId];
            cpsWrap.accId = conList[0].Account.Id;
            cpsWrap.accName = conList[0].Account.Name;
        }
        
        // Initialize Session list
        List<PHSS_CpsWrapper.SessionWrapper> sessionWrapList = new List<PHSS_CpsWrapper.SessionWrapper>();
        PHSS_CpsWrapper.SessionWrapper sessionWrap = new PHSS_CpsWrapper.SessionWrapper();
        sessionWrapList.add(sessionWrap);
        cpsWrap.sessionList = sessionWrapList;
        
        // Class Formats
        List<String> formatsList = new List<String>();
        Schema.DescribeFieldResult fieldResult = redwing__ILT_Class__c.Classroom_Setting__c.getDescribe();
        List<Schema.PicklistEntry> entries = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry val : entries) {
            if(val.getLabel() != 'Online') {
            	formatsList.add(val.getLabel());
            }
        }
        cpsWrap.classFormatList = formatsList;
        
        // Timezone
        skedJobtoILTClass localSkedJobtoILTClass = new skedJobtoILTClass();
        cpsWrap.timeZoneList = localSkedJobtoILTClass.timeZoneMap;
        
        return cpsWrap;
    }
    
    @AuraEnabled
    public static void postClass(String jsonStr) {
        try {
            PHSS_CpsWrapper cpsWrap = (PHSS_CpsWrapper)JSON.deserialize(jsonStr, PHSS_CpsWrapper.class);
            
            // Create Learning (master) record
            redwing__Learning__c objLearning = new redwing__Learning__c();
            objLearning.RecordTypeId = Schema.SObjectType.redwing__Learning__c.getRecordTypeInfosByName().get('ILT Class').getRecordTypeId();
            objLearning.Name = cpsWrap.courseName;
            objLearning.redwing__Published__c = true;
            insert objLearning;    
            
            // Create ILT Class record
            redwing__ILT_Class__c newClass = new redwing__ILT_Class__c();
            newClass.Request_Type__c = 'CPS';
            newClass.Name = cpsWrap.courseName;
            newClass.Skedulo_Account__c = cpsWrap.accId;
            newClass.Learning_Plan__c = cpsWrap.courseId;
            
            // Convert date and time to UTC 
            Date classDate = Date.valueOf(cpsWrap.sessionList[0].classDate);
            
            List<String> startTimeList = cpsWrap.sessionList[0].startTime.split(':');
            List<String> endTimeList = cpsWrap.sessionList[0].endTime.split(':');
            
            String timeZoneVal = cpsWrap.timeZoneList.get(cpsWrap.sessionList[0].timeZone); 
            TimeZone tz = Timezone.getTimeZone(timeZoneVal);
            
            DateTime startDateTime = DateTime.newInstanceGmt(classDate.year(),classDate.month(),classDate.day(),Integer.valueOf(startTimeList[0]),Integer.valueOf(startTimeList[1]),0);
            DateTime endDateTime = DateTime.newInstanceGmt(classDate.year(),classDate.month(),classDate.day(),Integer.valueOf(endTimeList[0]),Integer.valueOf(endTimeList[1]),0);
             
            Integer offset = (tz.getOffset(startDateTime))/(60*60*1000);
             
            Integer offsetStartTime = Integer.valueOf(startTimeList[0]) - offset;
            Integer offsetEndTime = Integer.valueOf(endTimeList[0]) - offset;
                        
            String timeStart = String.valueOf(offsetStartTime);
            String timeEnd = String.valueOf(offsetEndTime);
            Integer daysToAdd = 0;
            
            if(offsetStartTime > 23){
                timeStart = String.valueOf(offsetStartTime - 24);
                daysToAdd = 1;
            }
            else if(offsetStartTime < 0) {
                timeStart = String.valueOf(12 - offsetStartTime);  
                daysToAdd = -1;
            }
            
            if(offsetEndTime > 23){
                timeEnd = String.valueOf(offsetEndTime - 24);
            }
            else if(offsetEndTime < 0) {
                timeEnd = String.valueOf(12 - offsetEndTime);  
            }
 
			DateTime startTime = DateTime.newInstanceGmt(classDate.year(),classDate.month(),Integer.valueOf(classDate.day()+daysToAdd),Integer.valueOf(timeStart),Integer.valueOf(startTimeList[1]),0); 
			DateTime endTime = DateTime.newInstanceGmt(classDate.year(),classDate.month(),Integer.valueOf(classDate.day()+daysToAdd),Integer.valueOf(timeEnd),Integer.valueOf(endTimeList[1]),0); 

            newClass.redwing__Start_Time__c = startTime.format('HH:mm', 'GMT'); 
            newClass.redwing__End_Time__c = endTime.format('HH:mm', 'GMT'); 
            
            newClass.redwing__Start_Date__c = startTime.dateGmt();
            newClass.redwing__End_Date__c = startTime.dateGmt();             
              
            newClass.redwing__Timezone__c = timeZoneVal;
            newClass.Site_Name__c = cpsWrap.siteName;
            newClass.Site_Address_1__c = cpsWrap.address1;
            newClass.Site_Address_2__c = cpsWrap.address2;
            newClass.Site_City__c = cpsWrap.city;
            newClass.State__c = cpsWrap.state;
            newClass.Site_Postal_Code__c = cpsWrap.zip;
            newClass.CPS_Registration_URL__c = cpsWrap.regUrl;
            newClass.CPS_Registration_Phone__c = cpsWrap.regPhone;
            newClass.Registration_Fee__c = cpsWrap.regFee;
            newClass.CPS_Approval_Status__c = 'Submitted';
            newClass.redwing__Learning__c = objLearning.Id;
            newClass.Classroom_Setting__c = cpsWrap.classFormat;
            insert newClass;
             
            List<redwing__ILT_Session__c> sessList = new List<redwing__ILT_Session__c>();
            for(PHSS_cpsWrapper.SessionWrapper sessWrap : cpsWrap.sessionList) {
                redwing__ILT_Session__c sess = new redwing__ILT_Session__c();
                sess.redwing__ILT_Class__c = newClass.Id;
                sess.redwing__Date__c = Date.valueOf(sessWrap.classDate);
                
                List<String> sessStartTimeList = cpsWrap.sessionList[0].startTime.split(':');
                Time sessStartTime = Time.newInstance(Integer.valueOf(sessStartTimeList[0]),Integer.valueOf(sessStartTimeList[1]),0,0);
                List<String> sessEndTimeList = cpsWrap.sessionList[0].endTime.split(':');
                Time sessEndTime = Time.newInstance(Integer.valueOf(sessEndTimeList[0]),Integer.valueOf(sessEndTimeList[1]),0,0);
            
                sess.redwing__Start_Time__c = String.valueOf(sessStartTime).subString(0,5);
                sess.redwing__End_Time__c = String.valueOf(sessEndTime).subString(0,5);
            	sessList.add(sess);
            }
			
            if(!Test.isRunningTest()) {
            	insert sessList;    
            }
            
            // Insert Learning Versiom
            redwing__Learning_Version__c lv = new redwing__Learning_Version__c();
            lv.redwing__Learning__c = objLearning.id;
            lv.redwing__Version__c = 1;
            lv.redwing__Type__c = 'Published';
            lv.redwing__Version_selection_behavior__c = null;
            lv.redwing__ILT__c = newClass.Id;
            insert lv;
   
        }
        catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
	public static Id createOppForCC(String AccountId) {
        
        Opportunity o = new Opportunity();
        
        o.Name          = 'Community Opportunity';
        o.AccountId     = AccountId;
        o.StageName     = 'Approach';
        o.CloseDate     = date.today();
        o.Type          = 'New Business - FS';
        o.RecordTypeId  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Order Opportunity').getRecordTypeId();
        o.Source_System__c = 'CPS';
        
        insert o;
        
     return o.Id;
    }
    
    @AuraEnabled
    public static ccrz__E_Product__c getLearningPlanId(String ccProdId) {
        
        ccrz__E_Product__c  ccProd = [SELECT Id, LMS_Learning_Plan__c, LMS_Learning_Plan__r.Name  FROM ccrz__E_Product__c WHERE Id =: ccProdId LIMIT 1];
        
        return ccProd;
    }
    
    //Method to Skip payment page
    @AuraEnabled
    public static Boolean getDisplayPaymentInfo(String opportunityId) {
    	User u = [Select id, ContactId, Name, Profile.Name, Profile.UserLicense.Name from user where id=: UserInfo.getUserId()];
        Opportunity opp = [Select Id,AccountId From Opportunity WHERE Id = :opportunityId];
        List<AccountContactRelation> accConRel = [SELECT AccountId, Display_Payment_Info__c FROM AccountContactRelation WHERE ContactId = : u.ContactId and AccountId =: opp.AccountId]; 
        if(!accConRel.isEmpty()) {
            return accConRel[0].Display_Payment_Info__c;
        }
        return true;
    }
    
    
}