public without sharing class PHSS_eCommerceIntegrationFiles {
    public Boolean exportAllClasses = false;
    public DateTime RunTime = DateTime.Now();
    
    public class CustomAttributes {
        String   CourseID;
        String   FacilityID;
        String   SabaOfferingId;
        String   CourseFormat;
        String   CourseLanguage;
        Long     CourseSortDate;   // *** Note: These two dates tie to the date of the first session for the course
                                   // *** For LTP CPS, value is start date
        Long     offeringDropDate; 
        String   CourseDates;      
        String   CourseDaysOfWeek; 
        Integer  NumberSessions;   
        String   CourseStartTime;  // Display value (Format: HH:MM)
        String   CourseEndTime;   
        String   OfferingMonth;     
        String   DayOfMonth; 
        String   DayOfWeek;       
        String   UnitCode;      
        String   ChapterName;   
        String   productType;   
        Boolean  IsCourse; 
        String   attachmentID;
        String   attachmentName;
        String   attachmentURL;
        String   AttachmentCategory;
        String   ltpName;
        String   ltpUrl;
        
        Map<String, String> customAttributeValueMap;
    
        CustomAttributes(Boolean CPS, redwing__Training_Plan__c theLearningPlan, redwing__ILT_Class__c theClass, List<redwing__ILT_Session__c> theSessionList, redwing__ILT_Session__c theFirstSession) {                 
            String sessionDateList = '';
            String sessionDayOfWeekList = '';
            String sessionMonthList = '';
            String sessionDayOfMonthList = '';
            String sessionStartTimeList = '';
            String sessionEndTimeList = '';

            String locationKeyPrefix = redwing__ILT_Location__c.SObjectType.getDescribe().getKeyPrefix();   
            
            for (redwing__ILT_Session__c theClassSession : theSessionList) {
        
                String startDateTimeString = String.valueOf(theClassSession.redwing__Date__c) + ' ' + theClassSession.redwing__Start_Time__c + ':00';
                String endDateTimeString   = String.valueOf(theClassSession.redwing__Date__c) + ' ' + theClassSession.redwing__End_Time__c + ':00';             
                
                if (sessionDateList.length() > 0) sessionDateList += ';';
                sessionDateList += String.valueOf(DateTime.valueOf(startDateTimeString).getTime());
                if (sessionDayOfWeekList.length() > 0) sessionDayOfWeekList += ';';                
                sessionDayOfWeekList += String.valueOf(DateTime.valueOf(startDateTimeString).format('EEEE'));
                if (sessionMonthList.length() > 0) sessionMonthList += ';';                
                sessionMonthList += String.valueOf(theClassSession.redwing__Date__c.month());
                if (sessionDayOfMonthList.length() > 0) sessionDayOfMonthList += ';';                
                sessionDayOfMonthList += String.valueOf(theClassSession.redwing__Date__c.day());
                if (sessionStartTimeList.length() > 0) sessionStartTimeList += ';';                
                sessionStartTimeList += theClassSession.redwing__Start_Time__c;
                if (sessionEndTimeList.length() > 0) sessionEndTimeList += ';';                
                sessionEndTimeList += String.valueOf(DateTime.valueOf(endDateTimeString).getTime());
            }                                                       
        
            String firstDateTimeString = String.valueOf(theFirstSession.redwing__Date__c) + ' ' + theFirstSession.redwing__Start_Time__c + ':00';               
            Long firstSessionDateEpochTime = DateTime.valueOf(firstDateTimeString).getTime();                               
                                
            CourseID        = theLearningPlan.Id;
            // Note: NAT and other multi-session classes can be delivered at multiple locations
            // We are selecting the location of the first session for this class
            if (CPS) {
                FacilityID = locationKeyPrefix+String.valueOf(theFirstSession.redwing__ILT_Class__c).substring(3,15);
            } else {
                FacilityID = theFirstSession.redwing__Location__c; 
            }
            SabaOfferingId   = theClass.Id;
            // Trim whitespace to be compatible with DemandWare values
            CourseFormat     = (theLearningPlan.Classroom_Setting__c != null) ? 
                theLearningPlan.Classroom_Setting__c.replace(' ','') : 'Undefined';
            if (CourseFormat == 'Online+Classroom') CourseFormat = 'classroom+online';
            // Default language to English, translate ANSI codes to literals to be compatible with DemandWare
            CourseLanguage = (theLearningPlan.redwing__Language__c != null
                && theLearningPlan.redwing__Language__c == 'es') ? 'Spanish' : 'English';
            CourseSortDate   = firstSessionDateEpochTime; 
            offeringDropDate = firstSessionDateEpochTime;
            CourseDates      = sessionDateList; // Epoch Time Values 
            CourseDaysOfWeek = sessionDayOfWeekList;
            NumberSessions   = theSessionList.size();
            CourseStartTime  = sessionStartTimeList;
            CourseEndTime    = sessionEndTimeList; // Epoch Time Values
            OfferingMonth    = sessionMonthList;
            DayOfMonth       = sessionDayOfMonthList;
            DayOfWeek        = sessionDayOfWeekList;
            UnitCode         = '07038';              // Hard-coded, still in use?
            ChapterName      = 'American Red Cross'; // Hard-coded, are chapters even related to courses any more?
            productType      = 'offering';           // Hard-coded as we are migrating classes (offerings)
            IsCourse         = true;                 // Hard-coded as we are migrating classes (offerings)
            attachmentID     = '';
            attachmentName   = '';
            attachmentURL      = '';
            attachmentCategory = '';
            
            if (CPS) {
                ltpName      = theClass.Skedulo_Account__r.Name;
                ltpUrl       = theClass.CPS_Registration_URL__c;
            } else {
                ltpName      = '';
                ltpUrl       = '';
            }
                  
            customAttributeValueMap = new Map<String, String>{
                'CourseID'=>String.valueOf(CourseID).subString(0,15),
                'FacilityID'=>String.valueOf(FacilityID).subString(0,15),
                'SabaOfferingId'=>String.valueOf(SabaOfferingId).subString(0,15),
                'CourseFormat'=>CourseFormat,
                'CourseLanguage'=>CourseLanguage,
                'CourseSortDate'=>String.valueOf(CourseSortDate),
                'offeringDropDate'=>String.valueOf(offeringDropDate),
                'CourseDates'=>CourseDates,
                'CourseDaysOfWeek'=>CourseDaysOfWeek,
                'NumberSessions'=>String.valueOf(NumberSessions),
                'CourseStartTime'=>CourseStartTime,
                'CourseEndTime'=>CourseEndTime,
                'OfferingMonth'=>OfferingMonth,
                'DayOfMonth'=>DayOfMonth,
                'DayOfWeek'=>DayOfWeek,
                'UnitCode'=>UnitCode,
                'ChapterName'=>ChapterName,
                'productType'=>productType,
                'IsCourse'=>String.valueOf(IsCourse),
                'attachmentID'=>attachmentID,
                'attachmentName'=>attachmentName,
                'attachmentURL'=>attachmentURL,
                'attachmentCategory'=>attachmentCategory,
                'ltpName'=>ltpName,
                'ltpUrl'=>ltpUrl
            };          
        }
    }

    public class OnlineCustomAttributes {
        String   AttachmentCategory;
        String   AttachmentName;
        String   ChapterName;
        String   CourseDates;       
        String   CourseFormat;      
        String   CourseID;
        String   CourseLanguage;
        Long     CourseSortDate;        
        String   FacilityID;
        Boolean  IsCourse;
        String   SabaOfferingId;
        String   UnitCode; 
        String   attachmentID;
        Boolean  isDistributor;
        Long     offeringDropDate;  
        String   productType;   
        
        Map<String, String> customAttributeValueMap;
    
        OnlineCustomAttributes(redwing__Training_Plan__c theLearningPlan, redwing__Learning__c theLearningObject) {                 
            String courseDateList = '';
            String attachmentCategoryList = '';                                                      
        
            String startDateTimeString = (theLearningPlan.redwing__Start_Date__c != null) ? 
                String.valueOf(theLearningPlan.redwing__Start_Date__c) + ' ' + '00:00:00':String.valueOf(Date.Today()) + ' ' + '00:00:00';
                  
            String endDateTimeString = (theLearningPlan.redwing__End_Date__c != null) ?
                String.valueOf(theLearningPlan.redwing__End_Date__c) + ' ' + '00:00:00':String.valueOf(Date.Today()) + ' ' + '00:00:00';
                                        
            Long startDateEpochTime = DateTime.valueOf(startDateTimeString).getTime();   
            Long endDateEpochTime = DateTime.valueOf(endDateTimeString).getTime();  
            Long endDateEpochTimeMinus1 = DateTime.valueOf(endDateTimeString).addDays(-1).getTime();  // Cause Kalpan said so
                   
            CourseID         = theLearningPlan.Id;
            FacilityID       = 'online';
            SabaOfferingId   = theLearningObject.Id;
            // Trim whitespace to be compatible with DemandWare values
            CourseFormat     = 'Online';
            // Default language to English, translate ANSI codes to literals to be compatible with DemandWare
            CourseLanguage = (theLearningPlan.redwing__Language__c != null
                && theLearningPlan.redwing__Language__c == 'es') ? 'Spanish' : 'English';
            CourseDates      = String.valueOf(endDateEpochTime);
            CourseSortDate   = endDateEpochTimeMinus1; 
            offeringDropDate = endDateEpochTimeMinus1;
            UnitCode         = '00000';              // Hard-coded, still in use?
            ChapterName      = 'American Red Cross'; // Hard-coded, are chapters even related to courses any more?
            productType      = 'offering';           // Hard-coded as we are migrating classes (offerings)
            IsCourse         = true;                 // Hard-coded as we are migrating classes (offerings)
            isDistributor    = false;
            AttachmentName   = '';
            AttachmentCategory = '';
                  
            customAttributeValueMap = new Map<String, String>{
                'AttachmentName'=>AttachmentName,
                'AttachmentCategory'=>AttachmentCategory,  
                'ChapterName'=>ChapterName,
                'CourseDates'=>String.valueOf(CourseDates),   
                'CourseFormat'=>CourseFormat,                             
                'CourseID'=>String.valueOf(CourseID).subString(0,15),
                'CourseLanguage'=>CourseLanguage,   
                'CourseSortDate'=>String.valueOf(CourseSortDate),                                            
                'FacilityID'=>FacilityID,
                'IsCourse'=>String.valueOf(IsCourse),                
                'SabaOfferingId'=>String.valueOf(SabaOfferingId).subString(0,15),
                'UnitCode'=>UnitCode,
                'attachmentID'=>attachmentID,
                'isDistributor'=>String.valueOf(isDistributor),
                'offeringDropDate'=>String.valueOf(offeringDropDate),                 
                'productType'=>productType
            };          
        }
    }
    
    public void getAllCommunityClasses() {
        exportAllClasses = true;
        getCommunityClasses();
    }
    
    public void getCommunityClasses() {    
        
        // Set up lists and maps for housekeeping and retrieval     
      
        List<redwing__Training_Plan__c> allActiveLearningPlans = new List<redwing__Training_Plan__c>();
        List<redwing__Training_Plan__c> activeLearningPlans = new List<redwing__Training_Plan__c>();
        List<redwing__ILT_Class__c> allActiveCommunityClasses = new List<redwing__ILT_Class__c>();         
        List<redwing__ILT_Class__c> activeCommunityClasses = new List<redwing__ILT_Class__c>();  
        List<redwing__Training_Plan_Section_Item__c> allActiveOnlineClasses = new List<redwing__Training_Plan_Section_Item__c>();  
        List<redwing__Training_Plan_Section_Item__c> activeOnlineClasses = new List<redwing__Training_Plan_Section_Item__c>();  
        List<redwing__ILT_Session__c> activeCommunitySessions = new List<redwing__ILT_Session__c>();
        List<redwing__ILT_Location__c> activeCommunityLocations = new List<redwing__ILT_Location__c>();
        List<Geo_Location__c> activeCommunityGeoCodes = new List<Geo_Location__c>();
        
        List<String> classXMLList = new List<String>();
        List<String> onlineClassXMLList = new List<String>();
        List<String> CPSXMLList = new List<String>();
        List<String> inventoryXMLList = new List<String>();
        List<String> pricebookXMLList = new List<String>();
        
        Map<Id, String> siteCatalogXMLMap = new Map<Id, String>(); 
        Map<Id, String> courseXMLMap = new Map<Id, String>();
        Map<Id, String> locationXMLMap = new Map<Id, String>();    
        Map<Id, String> CPSLocationXMLMap = new Map<Id, String>();  
        Map<Id, Integer> classInventoryMap = new Map<Id, Integer>();
        Map<Id, Double> classPriceMap = new Map<Id, Double>();
        Map<String, Location> geocodeMap = new Map<String, Location>();       
        
        List<redwing__ILT_Event_Class__c> ILTEventClassList = new List<redwing__ILT_Event_Class__c>();
        List<redwing__Training_Plan_Section_Item__c> ILTTrainingPlanSectionItemList = new List<redwing__Training_Plan_Section_Item__c>();
        List<redwing__Training_Plan__c> trainingPlanList = new List<redwing__Training_Plan__c>();
        
        Set<Id> locationSet = new Set<Id>();
        
        Map<Id, Id> classLearningMap = new Map<Id,Id>();
        Map<Id, Id> eventLearningMap = new Map<Id,Id>();
         
        Map<Id, redwing__ILT_Class__c> classMap = new Map<Id, redwing__ILT_Class__c>();    
        Map<Id, redwing__ILT_Class__c> sessionClassMap = new Map<Id, redwing__ILT_Class__c>();    
        Map<Id, Id> classLearningEventLearningMap = new Map<Id, Id>();
        Map<Id, Id> eventLearningTrainingPlanMap = new Map<Id, Id>();
        Map<Id, redwing__Training_Plan__c> trainingPlanMap = new Map<Id, redwing__Training_Plan__c>();
        Map<Id, redwing__ILT_Location__c> locationMap = new Map<Id, redwing__ILT_Location__c>(); 
        Map<Id, redwing__ILT_Location__c> CPSLocationMap = new Map<Id, redwing__ILT_Location__c>();        
        Map<Id, List<redwing__ILT_Session__c>> classSessionMap  = new Map<Id, List<redwing__ILT_Session__c>>();          
        Map<Id, redwing__ILT_Session__c> classFirstSessionMap  = new Map<Id, redwing__ILT_Session__c>();
                    
        Set<Id> eCommerceClassSet = new Set<Id>();  
        Set<Id> activeCommunityClassSet = new Set<Id>(); 
        Set<String> activeCommunityPostalCodeSet = new Set<String>();     
                      
        // Step 1 - Iterate over Appinium ILTClass object for active community classes
        // Note: This export is intended for distribution to DemandWare as an input source to refresh its master (course)
        // and product (class) catalogs.  Each product in DemandWare is an active public community course. 
            
        DateTime lastRunDate = DateTime.Now();
        String incrementalExport = '';
        if (!exportAllClasses) {
            // Get last run date/time from integration files object 
            List<Integration_Files__c> integrationFiles = [Select Id, CreatedDate From Integration_Files__c Where File_Name__c Like 'ARC_LMS_Master%'
                Order By CreatedDate Desc Limit 1];         
            if (integrationFiles.size() != null && integrationFiles.size() > 0) {
                lastRunDate = integrationFiles[0].CreatedDate;
                incrementalExport = ' And LastModifiedDate > :lastRunDate';
            }
        } 
        System.debug('lastRunDate='+lastRunDate);
        System.debug('incrementalExport='+incrementalExport);
        System.debug('exportAllClasses='+exportAllClasses);
                
        // Build list of all learning plans (complete refresh to be pushed in each export - will be 
        // complemented later with an incremental refresh)
        
        String theLPQuery = 'Select Id, Name, CreatedDate, redwing__About_RTA__c, redwing__Description__c, '; 
            theLPQuery += 'redwing__Language__c, Classroom_Setting__c, redwing__Start_Date__c, redwing__End_Date__c ';
            theLPQuery += 'From redwing__Training_Plan__c Where redwing__Status__c = \'Active\' ';
            theLPQuery += 'And redwing__Start_Date__c <= Today And redwing__End_Date__c >= Today ';
            theLPQuery += incrementalExport;
       
        activeLearningPlans = Database.query(theLPQuery);
        System.debug('# activeLearningPlans='+activeLearningPlans.size());
        
        // Generate XML for Course and Site Catalog Files
        
        for (redwing__Training_Plan__c theLearningPlan : activeLearningPlans) {
                courseXMLMap.put(theLearningPlan.Id, getCourseXml(theLearningPlan));
                siteCatalogXMLMap.put(theLearningPlan.Id, getSiteCatalogXml(theLearningPlan));          
        }
                    
        // Build list of active community classes and CPS requests to be displayed on eCommerce site
            
        String theClassQuery = 'Select Id, CreatedDate, redwing__Learning__c, Learning_Plan__r.Id, Learning_Plan__r.Name, ';
            theClassQuery += 'Learning_Plan__r.CreatedDate, Learning_Plan__r.redwing__End_Date__c, Class_Online__c, Class_Online_From__c, ';
            theClassQuery += 'Class_Online_To__c, Class_Searchable__c, Class_Searchable_If_Unavailable__c, ';
            theClassQuery += 'Request_Type__c, Registration_Fee__c, CPS_Registration_Phone__c, redwing__Start_Date__c, ';
            theClassQuery += 'CPS_Registration_URL__c, Skedulo_Account__r.Name, Learning_Plan__r.Classroom_Setting__c, ';
            // The following fields are used only to dynamically create location records for LTP CPS listings            
            theClassQuery += 'Site_Name__c, Site_Address_1__c, Site_Address_2__c, Site_City__c, State__c, Site_Postal_Code__c ';
            theClassQuery += 'From redwing__ILT_Class__c ';
            theClassQuery += 'Where ((Request_Type__c = \'Community\' And Skedulo_Job_Active__c = true) ';
            theClassQuery += 'OR (Request_Type__c = \'Nurse Assistant Testing\' And Skedulo_Job_Active__c = true And ((Is_Stacked_Class__c = false) OR (Is_Stacked_Class__c = true And Is_Master_Class__c = true))) '; 
            theClassQuery += 'OR (Request_Type__c = \'CPS\'))';
            theClassQuery += incrementalExport;
        
        activeCommunityClasses = Database.query(theClassQuery);
        System.debug('# activeCommunityClasses='+activeCommunityClasses.size());               
        
        // Build list of active online classes which are modeled as Learning Events of type Media
        
        List<Recordtype> theRecordTypeList = [select Id from Recordtype where Name='Media' LIMIT 1];
        Id recordTypeId = theRecordTypeList[0].Id;
        
        String theOnlineQuery = 'Select Id, CreatedDate, redwing__Learning__c, ';
            theOnlineQuery += 'redwing__Training_Plan_Section__r.redwing__Training_Plan__c, ';
            theOnlineQuery += 'redwing__Training_Plan_Section__r.redwing__Training_Plan__r.Classroom_Setting__c, ';
            theOnlineQuery += 'redwing__Training_Plan_Section__r.redwing__Training_Plan__r.redwing__Status__c ';
            theOnlineQuery += 'From redwing__Training_Plan_Section_Item__c ';
            theOnlineQuery += 'Where redwing__Training_Plan_Section__r.redwing__Training_Plan__r.Classroom_Setting__c = \'Online\' ';
            theOnlineQuery += 'And redwing__Training_Plan_Section__r.redwing__Training_Plan__r.redwing__Status__c = \'Active\' ';           
            theOnlineQuery += 'And redwing__Learning__r.RecordTypeId = :recordTypeId And redwing__Learning__r.redwing__Published__c = True ';
            theOnlineQuery += incrementalExport;
            
        activeOnlineClasses = Database.query(theOnlineQuery);
        System.debug('# activeOnlineClasses='+activeOnlineClasses.size());                           
        // Build map of inventory by community class (non-CPS)
        
        classInventoryMap = getClassInventory(activeCommunityClasses);  
        classPriceMap = getClassPrice(activeCommunityClasses, activeOnlineClasses);     
            
        // Build Maps to Support Lookup of ILT Class to Learning Plan Parent
        // Do not want to rely on Learning Plan being populated in ILT Class record
        
        // Build Map of Community Class to Class Learning Object
        
        for (redwing__ILT_Class__c theILTClass : activeCommunityClasses) {
            classLearningMap.put(theILTClass.Id, theILTClass.redwing__Learning__c); 
            classMap.put(theILTClass.Id, theILTClass);
            activeCommunityClassSet.add(theILTClass.Id); 
            if (theILTClass.Site_Postal_Code__c != null) {
                activeCommunityPostalCodeSet.add(theILTClass.Site_Postal_Code__c.substring(0,5));   
            }
        }        

        activeCommunitySessions = [Select Id, redwing__ILT_Class__c,
            redwing__Location__c, redwing__Date__c, redwing__Start_Time__c, redwing__End_Time__c 
            From redwing__ILT_Session__c
            Where redwing__Date__c >= Today And redwing__ILT_Class__c In :activeCommunityClassSet];

        for (redwing__ILT_Session__c theSession : activeCommunitySessions) {
            if (!sessionClassMap.containsKey(theSession.Id)) {
                sessionClassMap.put(theSession.Id, classMap.get(theSession.redwing__ILT_Class__c));  
            }           
        }
        
        activeCommunityGeoCodes = [Select Id, Postal_Code__c, Coordinates__c From Geo_Location__c
            Where Postal_Code__c In :activeCommunityPostalCodeSet];

        For (Geo_Location__c theGeoLocation : activeCommunityGeoCodes) {
            geocodeMap.put(theGeoLocation.Postal_Code__c, theGeoLocation.Coordinates__c);
        }

        // Build Map of locations referenced by active community sessions
        
        for (redwing__ILT_Session__c theSession : activeCommunitySessions) {
            if (theSession.redwing__Location__c != null) {
                locationSet.add(theSession.redwing__Location__c);
            } else {
                // Dynamically create location records for LTP CPS classes which lack location Ids
                redwing__ILT_Class__c theClass = sessionClassMap.get(theSession.Id);
                if (theClass != null) {             
                    redwing__ILT_Location__c theCPSLocation = createCPSLocation(theClass);
                    
                    String thePhoneNumber = (theClass.CPS_Registration_Phone__c != null) ? theClass.CPS_Registration_Phone__c : '';
                    Location theGeoLocation = geocodeMap.get(theClass.Site_Postal_Code__c.substring(0,5));

                    System.debug(theCPSLocation);
                    System.debug(theClass.Id);
                    System.debug(thePhoneNumber);
                    System.debug(theGeoLocation);

                    CPSLocationXMLMap.put(theSession.Id, getLocationXML(theCPSLocation, String.valueOf(theClass.Id), thePhoneNumber, theGeoLocation));
                }
            }
        }

        activeCommunityLocations = [Select Id, Name, redwing__Address_1__c, redwing__Address_2__c, redwing__City__c,
            redwing__State__c, redwing__Postal_Code__c, redwing__Country__c, Skedulo_Location__r.sked__GeoLocation__c,
            Skedulo_Location__r.sked__Account__r.Billing_Contact_email__c, Skedulo_Location__r.sked__Account__r.Billing_Contact_phone__c
            From redwing__ILT_Location__c
            Where Id IN :locationSet];  
            
        for (redwing__ILT_Location__c theLocation : activeCommunityLocations) {
            if (!locationXMLMap.containsKey(theLocation.Id)) {
                String thePhoneNumber = ''; // ILT Location records lack a phone number
                Location theGeoLocation = null; // ILT Location records inherit geo coordinates from Skedulo location
                locationXMLMap.put(theLocation.Id, getLocationXML(theLocation, '', thePhoneNumber, theGeoLocation));            
            }   
        }
        //System.debug('locationXMLMap='+locationXMLMap);   
        
        // Build maps that will be used to support a cascading retrieval of Learning Plan given a class learning object Id      
        
        ILTEventClassList = [Select Id, redwing__Learning__c, redwing__ILT_Event__r.redwing__Learning__c From redwing__ILT_Event_Class__c
            Where redwing__Learning__c In :classLearningMap.values()];
        for (redwing__ILT_Event_Class__c theILTEventClass : ILTEventClassList) {
            classLearningEventLearningMap.put(theILTEventClass.redwing__Learning__c, theILTEventClass.redwing__ILT_Event__r.redwing__Learning__c);
        }           
        //System.debug('classLearningEventLearningMap='+classLearningEventLearningMap);
            
        ILTTrainingPlanSectionItemList = [Select Id, redwing__Learning__c, redwing__Training_Plan_Section__r.redwing__Training_Plan__c
            From redwing__Training_Plan_Section_Item__c Where redwing__Learning__c In :classLearningEventLearningMap.values()];     
        for (redwing__Training_Plan_Section_Item__c theTrainingPlanSectionItem : ILTTrainingPlanSectionItemList) {
            eventLearningTrainingPlanMap.put(theTrainingPlanSectionItem.redwing__Learning__c, theTrainingPlanSectionItem.redwing__Training_Plan_Section__r.redwing__Training_Plan__c);
        }           
        //System.debug('eventLearningTrainingPlanMap='+eventLearningTrainingPlanMap);
        
        trainingPlanList = [Select Id, Name, redwing__About_RTA__c, redwing__Description__c,
            redwing__Language__c, Classroom_Setting__c, CreatedDate, redwing__End_Date__c 
            From redwing__Training_Plan__c];
        for (redwing__Training_Plan__c theTrainingPlan : trainingPlanList) {
            trainingPlanMap.put(theTrainingPlan.Id, theTrainingPlan);
        }
        //System.debug('trainingPlanMap='+trainingPlanMap);
        
        // Build List of Sessions for Each Community Class
        // The session list is used when building the XML definition of a class and supports
        // defining the multiple delivery dates on which the class is scheduled
        
        for (redwing__ILT_Session__c theILTSession : activeCommunitySessions) {
            List<redwing__ILT_Session__c> classSessionList = new List<redwing__ILT_Session__c>();
            redwing__ILT_Location__c sessionLocation = new redwing__ILT_Location__c();
            
            Id theClassId = theILTSession.redwing__ILT_Class__c;                
            
            if (classSessionMap.containsKey(theClassId)) {
                classSessionList = classSessionMap.get(theClassId);
            } 

            classSessionList.add(theILTSession);
            classSessionMap.put(theClassId, classSessionList);
        
            if (!classFirstSessionMap.containsKey(theClassId)) {
                classFirstSessionMap.put(theClassId, theILTSession);    
            } else {
                if (classFirstSessionMap.get(theClassId).redwing__Date__c > theILTSession.redwing__Date__c) {
                    classFirstSessionMap.put(theClassId, theILTSession);    
                }
            }                                
        } 
        //System.debug('classFirstSessionMap='+classFirstSessionMap);      
        
        // Iterate Through Each Active ILT Community Class to Generate XML Definitions     
    
        for (redwing__ILT_Class__c theClass : activeCommunityClasses) {
            Boolean CPS;
            
            redwing__Training_Plan__c theLearningPlan = new redwing__Training_Plan__c();
            List<redwing__ILT_Session__c> theSessionList = new List<redwing__ILT_Session__c>();
            
            // If the ILT Class record lacks a lookup to the Learning Plan we will have to derive from maps

            if (theClass.Learning_Plan__c == null) {
                theLearningPlan = 
                    trainingPlanMap.get(eventLearningTrainingPlanMap.get(classLearningEventLearningMap.get(
                        classLearningMap.get(theClass.Id))));
            } else {
                theLearningPlan = trainingPlanMap.get(theClass.Learning_Plan__c);
            }

            theSessionList = classSessionMap.get(theClass.Id);
            if (theSessionList == null) continue;
            
            //System.debug('theClass='+theClass);
            //System.debug('theSession='+theSessionList);
            //System.debug('theLearningPlan='+theLearningPlan);
            
            if (!courseXMLMap.containsKey(theLearningPlan.Id)) {
                courseXMLMap.put(theLearningPlan.Id, getCourseXml(theLearningPlan));
                if (!siteCatalogXMLMap.containsKey(theLearningPlan.Id)) {
                    siteCatalogXMLMap.put(theLearningPlan.Id, getSiteCatalogXml(theLearningPlan));  
                }                
            }
            
            // Generate master catalog (community ILT course/class)    
            CPS = (theClass.Request_Type__c == 'CPS') ? true : false;
            
            if (CPS) {
                CPSXMLList.add(getClassXml(CPS, theLearningPlan, theClass, theSessionList, classFirstSessionMap.get(theClass.Id)));
            } else {
                classXMLList.add(getClassXml(CPS, theLearningPlan, theClass, theSessionList, classFirstSessionMap.get(theClass.Id)));               
            }
          
            siteCatalogXMLMap.put(theClass.Id, getSiteCatalogXml(theClass));
            inventoryXMLList.add(getInventoryXml(theClass, classInventoryMap.get(theClass.Id), false));
            
            if (CPS) {
                pricebookXMLList.add(getPricebookXml(theClass, Double.valueOf(theClass.Registration_Fee__c)));              
            } else {
                pricebookXMLList.add(getPricebookXml(theClass, classPriceMap.get(theClass.Id)));
            }
        }                         
        
        // Iterate Through Each Active Online Class to Generate XML Definitions   
        
        List<Id> onlineLearningIds = new List<Id>();
        List<Id> onlineLearningPlanIds = new List<Id>();
        Map<Id, redwing__Learning__c> onlineLearningMap = new Map<Id, redwing__Learning__c>();
        Map<Id, redwing__Training_Plan__c> onlineLearningPlanMap = new Map<Id, redwing__Training_Plan__c>();
        
        for (redwing__Training_Plan_Section_Item__c theTPSI : activeOnlineClasses) {
            onlineLearningIds.add(theTPSI.redwing__Learning__c);
            onlineLearningPlanIds.add(theTPSI.redwing__Training_Plan_Section__r.redwing__Training_Plan__c);
        } 
        List<redwing__Training_Plan__c> onlineLearningPlanList = [Select Id, Name, redwing__About_RTA__c, 
             redwing__Description__c, redwing__Language__c, Classroom_Setting__c, CreatedDate, 
             redwing__Start_Date__c, redwing__End_Date__c From redwing__Training_Plan__c Where Id in :onlineLearningPlanIds];
        List<redwing__Learning__c> onlineLearningList = [Select Id, Name From redwing__Learning__c Where Id in :onlineLearningIds];
    
        for (redwing__Training_Plan__c theLearningPlan : onlineLearningPlanList) {
            onlineLearningPlanMap.put(theLearningPlan.Id, theLearningPlan);
        }
        for (redwing__Learning__c theLearningObject : onlineLearningList) {
            onlineLearningMap.put(theLearningObject.Id, theLearningObject);
        }
        
        for (redwing__Training_Plan_Section_Item__c theTPSI : activeOnlineClasses) {
            Id theLearningPlanId = theTPSI.redwing__Training_Plan_Section__r.redwing__Training_Plan__c;
            Id theLearningObjectId = theTPSI.redwing__Learning__c;
            
            redwing__Training_Plan__c theLearningPlan = onlineLearningPlanMap.get(theLearningPlanId);
            redwing__Learning__c theLearningObject = onlineLearningMap.get(theLearningObjectId);
            
            if (!courseXMLMap.containsKey(theLearningPlanId)) {
                
                courseXMLMap.put(theLearningPlanId, getCourseXml(theLearningPlan));
                if (!siteCatalogXMLMap.containsKey(theLearningPlanId)) {
                    siteCatalogXMLMap.put(theLearningPlanId, getSiteCatalogXml(theLearningPlan));
                }
                            
            }
            
            // Generate master catalog (Online course/class)    

            onlineClassXMLList.add(getOnlineClassXml(theLearningPlan, theLearningObject));              
         
            siteCatalogXMLMap.put(theLearningObject.Id, getSiteCatalogXml(theLearningObject));
            inventoryXMLList.add(getInventoryXml(theLearningObject, 9999999, true));
            pricebookXMLList.add(getPricebookXml(theLearningObject, classPriceMap.get(theLearningObject.Id)));
        }                              
        
        // Generate and Upload XML files to platform
        generateCourseClassXmlFile(courseXMLMap.values(), classXMLList, onlineClassXMLList);
        generateCPSXmlFile(CPSXMLList);        
        generateLocationXmlFile(locationXMLMap.values(), CPSLocationXMLMap.values());
        generateSiteCatalogXmlFile(siteCatalogXMLMap.values());
        generateInventoryXmlFile(inventoryXMLList);
        generatePricebookXmlFile(pricebookXMLList);    

        return;
    }
    
    private Map<Id, Double> getPriceOverrides(Set <Id> communityCourseSet, List <redwing__ILT_Class__c> communityClassList) {

        // Get zip code specific pricing (if defined)
            
        String storeFront = 'GeneralStore';
        Set<Id> ccProducts = new Set<Id>();
        Set<Id> communityClasses = new Set<Id>();
        
        Set<String> priceLists = new Set<String>();
        
        List<ccrz__E_Product__c> ccProductList = new List<ccrz__E_Product__c>();
        List<redwing__ILT_Session__c> classSessionList = new List<redwing__ILT_Session__c>();
        
        Map<Id, Double> communityPrices = new Map<Id, Double>();
        Map<Id, Id> ccProductMap = new Map<Id, Id>();
        Map<Id, String> classPriceListMap = new Map<Id, String>();
        
        ccProductList = [Select Id, LMS_Learning_Plan__c From ccrz__E_Product__c Where LMS_Learning_Plan__c IN :communityCourseSet];
        for (ccrz__E_Product__c theCCProduct : ccProductList) {
            ccProducts.add(theCCProduct.Id);
            if (theCCProduct.LMS_Learning_Plan__c != null) ccProductMap.put(theCCProduct.LMS_Learning_Plan__c, theCCProduct.Id);
        }
        for (redwing__ILT_Class__c theClass : communityClassList) {
            communityClasses.add(theClass.Id);
        }
        
        classSessionList = [Select Id, redwing__Location__r.redwing__Postal_Code__c, redwing__ILT_Class__c
            From redwing__ILT_Session__c
            Where redwing__ILT_Class__c In :communityClasses];
            
        for (redwing__ILT_Session__c theSession : classSessionList) {
            String zip = '';
            String pricelist = '';
            if (theSession.redwing__Location__r.redwing__Postal_Code__c != null) {
                zip = theSession.redwing__Location__r.redwing__Postal_Code__c;
                if (zip.length() > 5) zip = zip.substring(0,5);
                pricelist='ZIP-'+zip;
                priceLists.add(pricelist);
            }
            classPriceListMap.put(theSession.redwing__ILT_Class__c, pricelist);
        }

        List<ccrz__E_PriceListItem__c> priceListItems = [SELECT ccrz__Product__c, ccrz__PriceList__r.ccrz__StartDate__c, ccrz__PriceList__r.ccrz__EndDate__c, 
            ccrz__PriceList__r.Name, ccrz__StartDate__c, ccrz__EndDate__c, ccrz__Price__c
             FROM ccrz__E_PriceListItem__c WHERE ccrz__Product__c IN :ccProducts AND ccrz__PriceList__r.Name IN :priceLists
             AND ccrz__PriceList__r.ccrz__Enabled__c = True AND ccrz__PriceList__r.ccrz__Storefront__c = :storeFront];

        for (redwing__ILT_Class__c theClass : communityClassList) {
            if (classPriceListMap.get(theClass.Id) != null) {
                String priceListName = classPriceListMap.get(theClass.Id);
                if (theClass.Learning_Plan__c != null) {
                    Id ccProductId = ccProductMap.get(theClass.Learning_Plan__c);
                    if (ccProductId != null && theClass.redwing__Start_Date__c != null) {
                        for (ccrz__E_PriceListItem__c thePriceListItem : priceListItems) {
                            
                            Boolean itemStartDate = true;
                            Boolean itemEndDate = true;
                            Boolean listStartDate = true;
                            Boolean listEndDate = true;
                            Date classDate = theClass.redwing__Start_Date__c;
                                                        
                            if (thePriceListItem.ccrz__PriceList__r.ccrz__StartDate__c != null) {
                                if (thePriceListItem.ccrz__PriceList__r.ccrz__StartDate__c > classDate) listStartDate = false;
                            }
                            if (thePriceListItem.ccrz__PriceList__r.ccrz__EndDate__c != null) {
                                if (thePriceListItem.ccrz__PriceList__r.ccrz__EndDate__c < classDate) listEndDate = false;
                            }   
                            if (thePriceListItem.ccrz__StartDate__c != null) {
                                if (thePriceListItem.ccrz__StartDate__c > classDate) itemStartDate = false;
                            }
                            if (thePriceListItem.ccrz__EndDate__c != null) {
                                if (thePriceListItem.ccrz__EndDate__c < classDate) itemEndDate = false;
                            }
                            
                            if ((thePriceListItem.ccrz__Product__c != null && thePriceListItem.ccrz__Product__c == ccProductId) &&
                                (thePriceListItem.ccrz__PriceList__r.Name == priceListName) &&
                                (itemStartDate && itemEndDate && listStartDate && listEndDate)) {
                                // Add price override to map
                                communityPrices.put(theClass.Id, thePriceListItem.ccrz__Price__c);  
                            }
                        }
                    }
                }
            }
        }
        return communityPrices;
    }
    
    private redwing__ILT_Location__c createCPSLocation(redwing__ILT_Class__c theClass) {
        redwing__ILT_Location__c theCPSLocation = new redwing__ILT_Location__c();
        
        if (theClass != null) {
            theCPSLocation.Name = theClass.Site_Name__c;
            theCPSLocation.redwing__Address_1__c   = theClass.Site_Address_1__c;
            theCPSLocation.redwing__Address_2__c   = theClass.Site_Address_1__c;   
            theCPSLocation.redwing__City__c        = theClass.Site_City__c;
            theCPSLocation.redwing__State__c       = theClass.State__c;
            theCPSLocation.redwing__Postal_Code__c = theClass.Site_Postal_Code__c;
            theCPSLocation.redwing__Country__c     = 'US'; // theClass.Site_Country__c;  
        }
        
        return theCPSLocation;      
    }    
    
    private void generateCourseClassXmlFile(List<String> courseXMLList, List<String> classXmlList, List<String> onlineClassXMLList) {
        // Define master list to create file export to Integration Files object
        List<Integration_Files__c> exportedXMLRecords = new List<Integration_Files__c>();
        
        String exportFileName = 'ARC_LMS_Master_' + RunTime.format('MMddyyyyhhmma') + '.xml';  
        String targetSystem = 'RCO';    
        Integer theSequenceNumber = 0;
        
        String serializedCourseXMLList = '';
        String serializedClassXMLList = '';
        
        // Write header line to integration file custom object
        Integration_Files__c integrationFileHeader = new Integration_Files__c();              
        integrationFileHeader.Record_Data__c = getCourseXmlHeader(false);
        integrationFileHeader.File_Name__c = exportFileName;
        integrationFileHeader.Target_System__c = targetSystem;     
        integrationFileHeader.Sequence_Number__c = ++theSequenceNumber;
        exportedXMLRecords.add(integrationFileHeader);            
        
        for (String theCourseXML : courseXmlList) {
            serializedCourseXMLList += theCourseXml;
            // Write line to integration file custom object
            Integration_Files__c integrationFileRecord = new Integration_Files__c();              
            integrationFileRecord.Record_Data__c = theCourseXML;
            integrationFileRecord.File_Name__c = exportFileName;
            integrationFileRecord.Target_System__c = targetSystem;              
            integrationFileRecord.Sequence_Number__c = ++theSequenceNumber;
            exportedXMLRecords.add(integrationFileRecord);
        }

        for (String theClassXML : classXMLList) {
            serializedClassXMLList += theClassXml;
            // Write line to integration file custom object
            Integration_Files__c integrationFileRecord = new Integration_Files__c();              
            integrationFileRecord.Record_Data__c = theClassXML;
            integrationFileRecord.File_Name__c = exportFileName;
            integrationFileRecord.Target_System__c = targetSystem;              
            integrationFileRecord.Sequence_Number__c = ++theSequenceNumber;
            exportedXMLRecords.add(integrationFileRecord);            
        }   

        for (String theOnlineClassXML : onlineClassXMLList) {
            serializedClassXMLList += theOnlineClassXML;
            // Write line to integration file custom object
            Integration_Files__c integrationFileRecord = new Integration_Files__c();              
            integrationFileRecord.Record_Data__c = theOnlineClassXML;
            integrationFileRecord.File_Name__c = exportFileName;
            integrationFileRecord.Target_System__c = targetSystem;              
            integrationFileRecord.Sequence_Number__c = ++theSequenceNumber;
            exportedXMLRecords.add(integrationFileRecord);            
        }           
        
        // Write trailer line to integration file custom object
        Integration_Files__c integrationFileTrailer = new Integration_Files__c();              
        integrationFileTrailer.Record_Data__c = getCourseXmlTrailer();
        integrationFileTrailer.File_Name__c = exportFileName;
        integrationFileTrailer.Target_System__c = targetSystem;          
        integrationFileTrailer.Sequence_Number__c = ++theSequenceNumber;
        exportedXMLRecords.add(integrationFileTrailer);        
        
        // Comment out the following block to disable writing file as internal Salesforce file
        ContentVersion v = new ContentVersion();
        v.versionData = Blob.valueOf(getCourseXmlHeader(false)+serializedCourseXMLList+serializedClassXMLList+getCourseXmlTrailer());
        v.title = 'Active Community Classes '+String.valueOf(Date.today());
        v.PathOnClient = '/ActiveCommunityClasses.xml';
        insert v;
        
        // Write export records to Integration Files object
        try {
            insert(exportedXMLRecords);
        } catch (exception e) {
            
        }        
        
        return;
    }
    
    private void generateCPSXmlFile(List<String> CPSXMLList) {
        // Define master list to create file export to Integration Files object
        List<Integration_Files__c> exportedXMLRecords = new List<Integration_Files__c>();
                
        String exportFileName = 'ARC_Master_' + RunTime.format('MMddyyyyhhmma') + '.xml'; 
        String targetSystem = 'RCO';
        Integer theSequenceNumber = 0;
                
        String serializedCPSXMLList = '';
        
        // Write header line to integration file custom object
        Integration_Files__c integrationFileHeader = new Integration_Files__c();              
        integrationFileHeader.Record_Data__c = getCourseXmlHeader(true);
        integrationFileHeader.File_Name__c = exportFileName;
        integrationFileHeader.Target_System__c = targetSystem;          
        integrationFileHeader.Sequence_Number__c = ++theSequenceNumber;
        exportedXMLRecords.add(integrationFileHeader);          
        
        for (String theCPSXML : CPSXMLList) {
            serializedCPSXMLList += theCPSXML;
            // Write line to integration file custom object
            Integration_Files__c integrationFileRecord = new Integration_Files__c();            
            integrationFileRecord.Record_Data__c = theCPSXML;
            integrationFileRecord.File_Name__c = exportFileName;
            integrationFileRecord.Target_System__c = targetSystem;              
            integrationFileRecord.Sequence_Number__c = ++theSequenceNumber;
            exportedXMLRecords.add(integrationFileRecord);           
        }  
        
        // Write trailer line to integration file custom object
        Integration_Files__c integrationFileTrailer = new Integration_Files__c();              
        integrationFileTrailer.Record_Data__c = getCourseXmlTrailer();
        integrationFileTrailer.File_Name__c = exportFileName;
        integrationFileTrailer.Target_System__c = targetSystem;          
        integrationFileTrailer.Sequence_Number__c = ++theSequenceNumber;
        exportedXMLRecords.add(integrationFileTrailer);             
        
        // Comment out the following block to disable writing file as internal Salesforce file        
        ContentVersion v = new ContentVersion();
        v.versionData = Blob.valueOf(getCourseXmlHeader(true)+serializedCPSXMLList+getCourseXmlTrailer());
        v.title = 'Active LTP CPS Classes '+String.valueOf(Date.today());
        v.PathOnClient = '/ActiveLTPCPSClasses.xml';
        insert v;
        
        // Write export records to Integration Files object
        try {
            insert(exportedXMLRecords);
        } catch (exception e) {
            
        } 
        
        return;
    }

    private void generateLocationXmlFile(List<String> locationXMLList, List<String> CPSLocationXMLList) {
        // Define master list to create file export to Integration Files object
        List<Integration_Files__c> exportedXMLRecords = new List<Integration_Files__c>();
        
        String exportFileName = 'ARC_Location_LMS_' + RunTime.format('MMddyyyyhhmma') + '.xml';  
        String targetSystem = 'RCO';
        Integer theSequenceNumber = 0;
                
        String serializedLocationXMLList = '';
        
        // Write header line to integration file custom object
        Integration_Files__c integrationFileHeader = new Integration_Files__c();              
        integrationFileHeader.Record_Data__c = getLocationXmlHeader();
        integrationFileHeader.File_Name__c = exportFileName;
        integrationFileHeader.Target_System__c = targetSystem;         
        integrationFileHeader.Sequence_Number__c = ++theSequenceNumber;
        exportedXMLRecords.add(integrationFileHeader);           
        
        for (String theLocationXML : locationXMLList) {
            serializedLocationXMLList += theLocationXML;
            // Write line to integration file custom object
            Integration_Files__c integrationFileRecord = new Integration_Files__c();              
            integrationFileRecord.Record_Data__c = theLocationXML;
            integrationFileRecord.File_Name__c = exportFileName;
            integrationFileRecord.Target_System__c = targetSystem;             
            integrationFileRecord.Sequence_Number__c = ++theSequenceNumber;
            exportedXMLRecords.add(integrationFileRecord);            
        }
        for (String theLocationXML : CPSLocationXMLList) {
            serializedLocationXMLList += theLocationXML;
            // Write line to integration file custom object
            Integration_Files__c integrationFileRecord = new Integration_Files__c();              
            integrationFileRecord.Record_Data__c = theLocationXML;
            integrationFileRecord.File_Name__c = exportFileName;
            integrationFileRecord.Target_System__c = targetSystem;             
            integrationFileRecord.Sequence_Number__c = ++theSequenceNumber;
            exportedXMLRecords.add(integrationFileRecord);              
        }        
        
        // Write trailer line to integration file custom object
        Integration_Files__c integrationFileTrailer = new Integration_Files__c();              
        integrationFileTrailer.Record_Data__c = getLocationXmlTrailer();
        integrationFileTrailer.File_Name__c = exportFileName;
        integrationFileTrailer.Target_System__c = targetSystem;         
        integrationFileTrailer.Sequence_Number__c = ++theSequenceNumber;
        exportedXMLRecords.add(integrationFileTrailer);  
                
        // Comment out the following block to disable writing file as internal Salesforce file                  
        ContentVersion v = new ContentVersion();
        v.versionData = Blob.valueOf(getLocationXmlHeader()+serializedLocationXMLList+getLocationXmlTrailer());
        v.title = 'Community Class Locations '+String.valueOf(Date.today());
        v.PathOnClient = '/CommunityClassLocations.xml';
        insert v;
        
        // Write export records to Integration Files object
        try {
            insert(exportedXMLRecords);
        } catch (exception e) {
            
        }            
        
        return;
    }
            
    private void generateInventoryXmlFile(List<String> inventoryXmlList) {
        // Define master list to create file export to Integration Files object
        List<Integration_Files__c> exportedXMLRecords = new List<Integration_Files__c>();
        
        String exportFileName = 'ARC_Inventory_LMS_' + RunTime.format('MMddyyyyhhmma') + '.xml'; 
        String targetSystem = 'RCO';    
        Integer theSequenceNumber = 0;
                
        String serializedInventoryXMLList = '';
        
        // Write header line to integration file custom object
        Integration_Files__c integrationFileHeader = new Integration_Files__c();              
        integrationFileHeader.Record_Data__c = getInventoryXmlHeader();
        integrationFileHeader.File_Name__c = exportFileName;
        integrationFileHeader.Target_System__c = targetSystem;         
        integrationFileHeader.Sequence_Number__c = ++theSequenceNumber;
        exportedXMLRecords.add(integrationFileHeader);        
        
        for (String theInventoryXML : inventoryXMLList) {
            serializedInventoryXMLList += theInventoryXML;
            // Write line to integration file custom object
            Integration_Files__c integrationFileRecord = new Integration_Files__c();              
            integrationFileRecord.Record_Data__c = theInventoryXML;
            integrationFileRecord.File_Name__c = exportFileName;
            integrationFileRecord.Target_System__c = targetSystem;             
            integrationFileRecord.Sequence_Number__c = ++theSequenceNumber;
            exportedXMLRecords.add(integrationFileRecord);              
        }   
        
        // Write trailer line to integration file custom object
        Integration_Files__c integrationFileTrailer = new Integration_Files__c();              
        integrationFileTrailer.Record_Data__c = getInventoryXmlTrailer();
        integrationFileTrailer.File_Name__c = exportFileName;
        integrationFileTrailer.Target_System__c = targetSystem;         
        integrationFileTrailer.Sequence_Number__c = ++theSequenceNumber;
        exportedXMLRecords.add(integrationFileTrailer); 
                
        // Comment out the following block to disable writing file as internal Salesforce file                 
        ContentVersion v = new ContentVersion();
        v.versionData = Blob.valueOf(getInventoryXmlHeader()+serializedInventoryXMLList+getInventoryXmlTrailer());
        v.title = 'Community Class Inventory '+String.valueOf(Date.today());
        v.PathOnClient = '/CommunityClassInventory.xml';
        insert v;
        
        // Write export records to Integration Files object
        try {
            insert(exportedXMLRecords);
        } catch (exception e) {
            
        }            
        
        return;
    }
    
            
    private void generatePricebookXmlFile(List<String> pricebookXMLList) {
        // Define master list to create file export to Integration Files object
        List<Integration_Files__c> exportedXMLRecords = new List<Integration_Files__c>();
        
        String exportFileName = 'ARC_Pricebook_LMS_' + RunTime.format('MMddyyyyhhmma') + '.xml'; 
        String targetSystem = 'RCO';    
        Integer theSequenceNumber = 0;
                        
        String serializedPricebookXmlList = '';
        
        // Write header line to integration file custom object
        Integration_Files__c integrationFileHeader = new Integration_Files__c();              
        integrationFileHeader.Record_Data__c = getPricebookXmlHeader();
        integrationFileHeader.File_Name__c = exportFileName;
        integrationFileHeader.Target_System__c = targetSystem;          
        integrationFileHeader.Sequence_Number__c = ++theSequenceNumber;
        exportedXMLRecords.add(integrationFileHeader);            
        
        for (String thePricebookXML : pricebookXMLList) {
            serializedPricebookXmlList += thePricebookXML;
            // Write line to integration file custom object
            Integration_Files__c integrationFileRecord = new Integration_Files__c();              
            integrationFileRecord.Record_Data__c = thePricebookXML;
            integrationFileRecord.File_Name__c = exportFileName;
            integrationFileRecord.Target_System__c = targetSystem;              
            integrationFileRecord.Sequence_Number__c = ++theSequenceNumber;
            exportedXMLRecords.add(integrationFileRecord);             
        }  
        
        // Write trailer line to integration file custom object
        Integration_Files__c integrationFileTrailer = new Integration_Files__c();              
        integrationFileTrailer.Record_Data__c = getPricebookXmlTrailer();
        integrationFileTrailer.File_Name__c = exportFileName;
        integrationFileTrailer.Target_System__c = targetSystem;          
        integrationFileTrailer.Sequence_Number__c = ++theSequenceNumber;
        exportedXMLRecords.add(integrationFileTrailer); 
                
        // Comment out the following block to disable writing file as internal Salesforce file                 
        ContentVersion v = new ContentVersion();
        v.versionData = Blob.valueOf(getPricebookXmlHeader()+serializedPricebookXmlList+getPricebookXmlTrailer());              
        v.title = 'Community Class Pricebook '+String.valueOf(Date.today());
        v.PathOnClient = '/CommunityClassPricebook.xml';
        insert v;
        
        // Write export records to Integration Files object
        try {
            insert(exportedXMLRecords);
        } catch (exception e) {
            
        }            
        
        return;
    }
    
    
    private void generateSiteCatalogXmlFile(List<String> siteCatalogXMLList) {
        // Define master list to create file export to Integration Files object
        List<Integration_Files__c> exportedXMLRecords = new List<Integration_Files__c>();
        
        String exportFileName = 'ARC_Site_Catalog_' + RunTime.format('MMddyyyyhhmma') + '.xml'; 
        String targetSystem = 'RCO';    
        Integer theSequenceNumber = 0;
                        
        String serializedSiteCatalogXMLList = '';
        
        // Write header line to integration file custom object
        Integration_Files__c integrationFileHeader = new Integration_Files__c();              
        integrationFileHeader.Record_Data__c = getSiteCatalogXmlHeader();
        integrationFileHeader.File_Name__c = exportFileName;
        integrationFileHeader.Target_System__c = targetSystem;           
        integrationFileHeader.Sequence_Number__c = ++theSequenceNumber;
        exportedXMLRecords.add(integrationFileHeader);           
        
        for (String theSiteCatalogXML : siteCatalogXMLList) {
            serializedSiteCatalogXMLList += theSiteCatalogXML;
            // Write line to integration file custom object
            Integration_Files__c integrationFileRecord = new Integration_Files__c();              
            integrationFileRecord.Record_Data__c = theSiteCatalogXML;
            integrationFileRecord.File_Name__c = exportFileName;
            integrationFileRecord.Target_System__c = targetSystem;               
            integrationFileRecord.Sequence_Number__c = ++theSequenceNumber;
            exportedXMLRecords.add(integrationFileRecord);              
        }   
        
        // Write trailer line to integration file custom object
        Integration_Files__c integrationFileTrailer = new Integration_Files__c();              
        integrationFileTrailer.Record_Data__c = getSiteCatalogXmlTrailer();
        integrationFileTrailer.File_Name__c = exportFileName;
        integrationFileTrailer.Target_System__c = targetSystem;           
        integrationFileTrailer.Sequence_Number__c = ++theSequenceNumber;
        exportedXMLRecords.add(integrationFileTrailer); 
                
        // Comment out the following block to disable writing file as internal Salesforce file                
        ContentVersion v = new ContentVersion();
        v.versionData = Blob.valueOf(getSiteCatalogXmlHeader()+serializedSiteCatalogXMLList+getSiteCatalogXmlTrailer());
        v.title = 'Community Site Catalog '+String.valueOf(Date.today());
        v.PathOnClient = '/CommunitySiteCatalog.xml';
        insert v;
        
        // Write export records to Integration Files object
        try {
            insert(exportedXMLRecords);
        } catch (exception e) {
            
        }            
        
        return;
    }
    
   private  Map<Id, Double> getClassPrice(List<redwing__ILT_Class__c> communityClassList,
            List<redwing__Training_Plan_Section_Item__c> onlineClassList) {
       Set<Id> communityCourseSet = new Set<Id>();
       Map<Id, Id> classcourseMap = new Map<Id, Id>();
       
       for (redwing__ILT_Class__c theClass : communityClassList) {
            if (theClass.Request_Type__c != 'CPS') communityCourseSet.add(theClass.Learning_Plan__c);
            classCourseMap.put(theClass.Id, theClass.Learning_Plan__c);
       }
       
       // Fetch price overrides (if defined) for each community course
       Map<Id, Double> theCommunityPriceList = new Map<Id, Double>();
       
       theCommunityPriceList = getPriceOverrides(communityCourseSet, communityClassList);
       
       // Remove classes with price overrides from communityCourseSet
       for (Id theClass : theCommunityPriceList.keySet()) {
          if (classCourseMap.get(theClass) != null) communityCourseSet.remove(classCourseMap.get(theClass));
       }
       
       for (redwing__Training_Plan_Section_Item__c theTPSI : onlineClassList) {
            communityCourseSet.add(theTPSI.redwing__Training_Plan_Section__r.redwing__Training_Plan__c);
       }
       
       List<ccrz__E_PriceListItem__c> priceItemList = [Select Id, ccrz__Price__c, ccrz__Product__r.LMS_Learning_Plan__c
            From ccrz__E_PriceListItem__c 
            Where ccrz__Pricelist__r.Name = 'Retail Price List' // Change to retail price group??? (DD-Feb 26)
            And ccrz__Product__r.LMS_Learning_Plan__c In :communityCourseSet];

       for (ccrz__E_PriceListItem__c thePriceListItem : priceItemList) {
            theCommunityPriceList.put(thePriceListItem.ccrz__Product__r.LMS_Learning_Plan__c, thePriceListItem.ccrz__Price__c);
       }

       return theCommunityPriceList;
   }
   
   private  Map<Id, Integer> getClassInventory(List<redwing__ILT_Class__c> communityClassList) {
       Set<Id> theClassSet = new Set<Id>();
       
       // Exclude Class Posting Service (CPS) classes from dynamic inventory calculations (exclude CPS)
       for (redwing__ILT_Class__c theClass : communityClassList) {
            if (theClass.Request_Type__c != 'CPS') theClassSet.add(theClass.Id);
       }
    
       // Determine number of available (unsold) seats in each class represented by 'Issued' vouchers
       List<Voucher__c> theVoucherList = [Select Id, Name, Status__c, Learning_Plan__c, ILT_Class__c
            From Voucher__c Where Status__c = 'Issued' And ILT_Class__c IN :theClassSet];
                              
       Map<Id, Integer> classInventory = new Map<Id, Integer>();
       Integer classVoucherCount;
       
       // Calculate inventory for each no-CPS class as number of vouchers in 'Issued' (unsold) status
       for (Voucher__c theVoucher : theVoucherList) {
            if (classInventory.containsKey(theVoucher.ILT_Class__c)) {
                classVoucherCount = classInventory.get(theVoucher.ILT_Class__c);    
                classInventory.put(theVoucher.ILT_Class__c, ++classVoucherCount);        
            } else {
                classInventory.put(theVoucher.ILT_Class__c, 1);
            }
       }                       
       
       // Calculate inventory for each CPS class as a fixed amount (10,000)
       for (redwing__ILT_Class__c theClass : communityClassList) {
       		if (theClass.Request_Type__c == 'CPS') classInventory.put(theClass.Id, 10000);
       }
       
       return classInventory;
   }       

    // XML for Course/Class and CPS Catalog File Header 
    
    private String getCourseXmlHeader(Boolean CPS) {
        XmlStreamWriter xmlW = new XmlStreamWriter();
        xmlW.writeStartDocument('UTF-8','1.0');
            // if (CPS) xmlW.writeAttribute(null,null,'standalone','yes');
            xmlW.writeCharacters('\n');
            xmlW.writeStartElement(null,'catalog', null);
                xmlW.writeAttribute(null,null,'catalog-id','CourseMaster');
                xmlW.writeAttribute(null,null,'xmlns','http://www.demandware.com/xml/impex/catalog/2006-10-31');
                xmlW.writeCharacters('\n');
                xmlW.writeStartElement(null,'header',null);
                xmlW.writeCharacters('\n');
                    xmlW.writeStartElement(null,'image-settings',null);
                    xmlW.writeCharacters('\n');
                        xmlW.writeStartElement(null,'internal-location',null);                      
                            xmlW.writeAttribute(null,null,'base-path','/');
                        xmlW.writeEndElement(); // Close internal-location
                        xmlW.writeCharacters('\n');
                        xmlW.writeStartElement(null,'view-types',null);
                        xmlW.writeCharacters('\n');
                            xmlW.writeStartElement(null,'view-type',null);          
                                xmlW.writeCharacters('large');
                            xmlW.writeEndElement(); // Close view-type large
                            xmlW.writeCharacters('\n');             
                            xmlW.writeStartElement(null,'view-type',null);          
                                xmlW.writeCharacters('medium');
                            xmlW.writeEndElement(); // Close view-type medium
                            xmlW.writeCharacters('\n');
                            xmlW.writeStartElement(null,'view-type',null);          
                                xmlW.writeCharacters('small');
                            xmlW.writeEndElement(); // Close view-type small
                            xmlW.writeCharacters('\n'); 
                            xmlW.writeStartElement(null,'view-type',null);          
                                xmlW.writeCharacters('swatch');
                            xmlW.writeEndElement(); // Close view-type swatch
                            xmlW.writeCharacters('\n'); 
                        xmlW.writeEndElement(); // Close view-types
                        xmlW.writeCharacters('\n');
                        xmlW.writeStartElement(null,'alt-pattern',null);                        
                            xmlW.writeCharacters('${productname}');
                        xmlW.writeEndElement(); // Close alt-pattern
                        xmlW.writeCharacters('\n');     
                        xmlW.writeStartElement(null,'title-pattern',null);                      
                            xmlW.writeCharacters('${productname}');
                        xmlW.writeEndElement(); // Close title-pattern
                        xmlW.writeCharacters('\n');
                    xmlW.writeEndElement(); // Close image-settings
                    xmlW.writeCharacters('\n');
                xmlW.writeEndElement(); // Close header
                xmlW.writeCharacters('\n');
                
        // System.debug(xmlW.getXmlString());   
        
        String xmlString = xmlW.getXmlString();
        
        return xmlString;
    }            

    // XML for Location File Header 
    
    private String getLocationXmlHeader() {
        XmlStreamWriter xmlW = new XmlStreamWriter();
        xmlW.writeStartDocument('UTF-8','1.0');
            xmlW.writeCharacters('\n');
            xmlW.writeStartElement(null,'stores', null);
                xmlW.writeAttribute(null,null,'xmlns','http://www.demandware.com/xml/impex/store/2007-04-30');
                xmlW.writeCharacters('\n');
                
        // System.debug(xmlW.getXmlString());   
        
        String xmlString = xmlW.getXmlString();
        
        return xmlString;
    } 
        
    // XML for Site Catalog File Header 
    
    private String getSiteCatalogXmlHeader() {
        XmlStreamWriter xmlW = new XmlStreamWriter();
        xmlW.writeStartDocument('UTF-8','1.0');
            xmlW.writeCharacters('\n');
            xmlW.writeStartElement(null,'catalog', null);
                xmlW.writeAttribute(null,null,'xmlns','http://www.demandware.com/xml/impex/catalog/2006-10-31');
                xmlW.writeAttribute(null,null,'catalog-id','arc-site-catalog');
                xmlW.writeCharacters('\n');                
                xmlW.writeStartElement(null,'header',null);
                    xmlW.writeCharacters('\n');
                    xmlW.writeStartElement(null,'image-settings',null);
                        xmlW.writeCharacters('\n'); 
                        xmlW.writeStartElement(null,'internal-location',null);  
                        xmlW.writeAttribute(null,null,'base-path','/');   
                        xmlW.writeEndElement(); // Close internal-location 
                        xmlW.writeCharacters('\n');                         
                        xmlW.writeStartElement(null,'view-types',null);
                            xmlW.writeCharacters('\n');
                            xmlW.writeStartElement(null,'view-type',null);
                                xmlW.writeCharacters('large');
                            xmlW.writeEndElement(); // Close view-type large
                            xmlW.writeCharacters('\n');
                            xmlW.writeStartElement(null,'view-type',null);
                                xmlW.writeCharacters('medium');
                            xmlW.writeEndElement(); // Close view-type medium
                            xmlW.writeCharacters('\n'); 
                            xmlW.writeStartElement(null,'view-type',null);
                                xmlW.writeCharacters('small');
                            xmlW.writeEndElement(); // Close view-type small
                            xmlW.writeCharacters('\n'); 
                            xmlW.writeStartElement(null,'view-type',null);
                                xmlW.writeCharacters('swatch');
                            xmlW.writeEndElement(); // Close view-type swatch
                            xmlW.writeCharacters('\n'); 
                        xmlW.writeEndElement(); // Close view-types
                        xmlW.writeCharacters('\n');                          
                        xmlW.writeStartElement(null,'alt-pattern',null);   
                            xmlW.writeCharacters('${productname}'); 
                        xmlW.writeEndElement(); // Close alt-pattern  
                        xmlW.writeCharacters('\n');                          
                        xmlW.writeStartElement(null,'title-pattern',null);  
                            xmlW.writeCharacters('${productname}');   
                        xmlW.writeEndElement(); // Close title-pattern 
                        xmlW.writeCharacters('\n');                          
                    xmlW.writeEndElement(); // Close image-settings 
                    xmlW.writeCharacters('\n');                     
                xmlW.writeEndElement(); // Close header 
                xmlW.writeCharacters('\n');                 
                xmlW.writeStartElement(null,'category',null);  
                    xmlW.writeAttribute(null,null,'category-id','root');  
                xmlW.writeEndElement(); // Close category   
                xmlW.writeCharacters('\n');  
                xmlW.writeStartElement(null,'category',null);  
                    xmlW.writeAttribute(null,null,'category-id','take-a-class');  
                    xmlW.writeCharacters('\n');  
                    xmlW.writeStartElement(null,'display-name',null);  
                        xmlW.writeCharacters('Training + Certification');   
                    xmlW.writeEndElement(); // Close display-name
                    xmlW.writeCharacters('\n');     
                    xmlW.writeStartElement(null,'online-flag',null);  
                        xmlW.writeCharacters('true');   
                    xmlW.writeEndElement(); // Close online-flag
                    xmlW.writeCharacters('\n'); 
                    xmlW.writeStartElement(null,'parent',null);  
                        xmlW.writeCharacters('root');   
                    xmlW.writeEndElement(); // Close parent
                    xmlW.writeCharacters('\n'); 
                    xmlW.writeStartElement(null,'custom-attributes',null);  
                        xmlW.writeCharacters('\n'); 
                        xmlW.writeStartElement(null,'custom-attribute',null);  
                            xmlW.writeAttribute(null,null,'xmlns:xsi','http://www.w3.org/2001/XMLSchema-instance');
                            xmlW.writeAttribute(null,null,'xsi:type','sharedType.SiteSpecificCustomAttribute'); 
                            xmlW.writeAttribute(null,null,'attribute-id','showInMenu');
                            xmlW.writeCharacters('true');                                                                             
                        xmlW.writeEndElement(); // Close custom-attribute   
                        xmlW.writeCharacters('\n');  
                        xmlW.writeStartElement(null,'custom-attribute',null);  
                            xmlW.writeAttribute(null,null,'xmlns:xsi','http://www.w3.org/2001/XMLSchema-instance');
                            xmlW.writeAttribute(null,null,'xsi:type','sharedType.SiteSpecificCustomAttribute'); 
                            xmlW.writeAttribute(null,null,'attribute-id','enableCompare');
                            xmlW.writeCharacters('false');                                                                            
                        xmlW.writeEndElement(); // Close custom-attribute   
                        xmlW.writeCharacters('\n');     
                    xmlW.writeEndElement(); // Close custom-attributes
                    xmlW.writeCharacters('\n');   
                xmlW.writeEndElement(); // Close category
                xmlW.writeCharacters('\n');  
                xmlW.writeStartElement(null,'category',null);  
                xmlW.writeAttribute(null,null,'category-id','hidden');  
                xmlW.writeCharacters('\n');                   
                    xmlW.writeStartElement(null,'display-name',null);  
                        xmlW.writeCharacters('Hidden');   
                    xmlW.writeEndElement(); // Close display-name
                    xmlW.writeCharacters('\n');     
                    xmlW.writeStartElement(null,'online-flag',null);  
                        xmlW.writeCharacters('true');   
                    xmlW.writeEndElement(); // Close online-flag
                    xmlW.writeCharacters('\n');
                    xmlW.writeStartElement(null,'parent',null);  
                        xmlW.writeCharacters('take-a-class');   
                    xmlW.writeEndElement(); // Close parent
                    xmlW.writeCharacters('\n'); 
                xmlW.writeEndElement(); // Close category
                xmlW.writeCharacters('\n');                                                                                 
                
        // System.debug(xmlW.getXmlString());   
        
        String xmlString = xmlW.getXmlString();
        
        return xmlString;
    } 

    // XML for Inventory File Header 
    
    private String getInventoryXmlHeader() {
        XmlStreamWriter xmlW = new XmlStreamWriter();
        xmlW.writeStartDocument('UTF-8','1.0');
            xmlW.writeCharacters('\n');
            xmlW.writeStartElement(null,'inventory', null);
                xmlW.writeAttribute(null,null,'xmlns','http://www.demandware.com/xml/impex/inventory/2007-05-31');
                xmlW.writeCharacters('\n');               
                xmlW.writeStartElement(null,'inventory-list',null);
                xmlW.writeCharacters('\n');
                    xmlW.writeStartElement(null,'header',null);
                        xmlW.writeAttribute(null,null,'list-id','ARC-US-inventory');            
                        xmlW.writeCharacters('\n'); 
                        xmlW.writeStartElement(null,'default-instock',null);
                            xmlW.writeCharacters('false');      
                        xmlW.writeEndElement(); // Close default-instock
                        xmlW.writeCharacters('\n');                             
                        xmlW.writeStartElement(null,'description',null);
                            xmlW.writeCharacters('ARC inventory List');      
                        xmlW.writeEndElement(); // Close description
                        xmlW.writeCharacters('\n');                             
                        xmlW.writeStartElement(null,'use-bundle-inventory-only',null);
                            xmlW.writeCharacters('false');      
                        xmlW.writeEndElement(); // Close use-bundle-inventory-only
                        xmlW.writeCharacters('\n');                             
                        xmlW.writeStartElement(null,'on-order',null);
                            xmlW.writeCharacters('false');      
                        xmlW.writeEndElement(); // Close on-order     
                        xmlW.writeCharacters('\n'); 
                    xmlW.writeEndElement(); // Close header 
                    xmlW.writeCharacters('\n');     
                    xmlW.writeStartElement(null,'records',null);
                    xmlW.writeCharacters('\n');                                                                                                                                                 
                
        // System.debug(xmlW.getXmlString());   
        
        String xmlString = xmlW.getXmlString();
        
        return xmlString;
    } 

    // XML for Pricebook File Header 
    
    private String getPricebookXmlHeader() {
        XmlStreamWriter xmlW = new XmlStreamWriter();
        xmlW.writeStartDocument('UTF-8','1.0');
            xmlW.writeCharacters('\n');
            xmlW.writeStartElement(null,'pricebooks', null);
                xmlW.writeAttribute(null,null,'xmlns','http://www.demandware.com/xml/impex/pricebook/2006-10-31');
                xmlW.writeCharacters('\n');               
                xmlW.writeStartElement(null,'pricebook',null);
                xmlW.writeCharacters('\n');
                    xmlW.writeStartElement(null,'header',null);
                        xmlW.writeAttribute(null,null,'pricebook-id','Course-Price-Book');            
                        xmlW.writeCharacters('\n'); 
                        xmlW.writeStartElement(null,'currency',null);
                            xmlW.writeCharacters('USD');      
                        xmlW.writeEndElement(); // Close currency
                        xmlW.writeCharacters('\n');                             
                        xmlW.writeStartElement(null,'display-name',null);                       
                            xmlW.writeCharacters('Course Price Book');      
                        xmlW.writeEndElement(); // Close display-name
                        xmlW.writeCharacters('\n');                             
                        xmlW.writeStartElement(null,'online-flag',null);
                            xmlW.writeCharacters('true');      
                        xmlW.writeEndElement(); // Close online-flag
                        xmlW.writeCharacters('\n');                             
                    xmlW.writeEndElement(); // Close header 
                    xmlW.writeCharacters('\n');     
                    xmlW.writeStartElement(null,'price-tables',null);
                    xmlW.writeCharacters('\n');                                                                                                                                                 
                
        // System.debug(xmlW.getXmlString());   
        
        String xmlString = xmlW.getXmlString();
        
        return xmlString;
    }     
           

    // XML Definition for Course Descriptions (Learning Plans)
    
    private String getCourseXml(redwing__Training_Plan__c theLearningPlan) {
        // Unmapped attributes hard-coded for now
        String   taxClass = 'baseTax';  // The following four fields are static (values as per sample files)
        Boolean  forcePriceFlag = true;
        Boolean  nonInventoryFlag = true;
        Boolean  nonDiscountableFlag = true;

        XmlStreamWriter xmlW = new XmlStreamWriter();
        xmlW.writeStartElement(null,'product', null);
            xmlW.writeAttribute(null,null,'product-id',String.valueOf(theLearningPlan.Id).subString(0,15));
            xmlW.writeCharacters('\n');
            xmlW.writeStartElement(null,'display-name', null);
                xmlW.writeCharacters(theLearningPlan.Name);
            xmlW.writeEndElement(); // Close display-name
            xmlW.writeCharacters('\n');
            String longDescription = (theLearningPlan.redwing__About_RTA__c != null) ?
                theLearningPlan.redwing__About_RTA__c.replaceAll('<[^>]+>','').replaceAll('[^\\x00-\\x7f]', '') : '';
            if (String.isNotEmpty(longDescription)) {
                xmlW.writeStartElement(null,'long-description', null);              
                    xmlW.writeCharacters(longDescription);
                xmlW.writeEndElement(); // Close long-description   
                xmlW.writeCharacters('\n');
            }             
            xmlW.writeStartElement(null,'online-flag', null);
                Boolean classOnline = true;
                xmlW.writeCharacters(String.valueOf(classOnline));
            xmlW.writeEndElement(); // Close online-flag    
            xmlW.writeCharacters('\n');
            xmlW.writeStartElement(null,'searchable-flag', null);
                Boolean classSearchable = true;
                xmlW.writeCharacters(String.valueOf(classSearchable));
            xmlW.writeEndElement(); // Close searchable-flag
            xmlW.writeCharacters('\n');
            xmlW.writeStartElement(null,'custom-attributes', null);
            xmlW.writeCharacters('\n');
                xmlW.writeStartElement(null,'custom-attribute', null);
                    xmlW.writeAttribute(null,null,'attribute-id', 'CourseID');
                    xmlW.writeCharacters(String.valueOf(theLearningPlan.Id).subString(0,15));
                xmlW.writeEndElement(); // Close custom-attribute   
                xmlW.writeCharacters('\n');
                xmlW.writeStartElement(null,'custom-attribute', null);
                    xmlW.writeAttribute(null,null,'attribute-id', 'productType');
                    xmlW.writeCharacters('course');
                xmlW.writeEndElement(); // Close custom-attribute   
                xmlW.writeCharacters('\n');
                xmlW.writeStartElement(null,'custom-attribute', null);
                    xmlW.writeAttribute(null,null,'attribute-id', 'IsCourse');
                    xmlW.writeCharacters('true');
                xmlW.writeEndElement(); // Close custom-attribute   
                xmlW.writeCharacters('\n');
            xmlW.writeEndElement(); // Close custom-attributes
            xmlW.writeCharacters('\n');         
            
            xmlW.writeStartElement(null,'store-attributes', null);
            xmlW.writeCharacters('\n');
                xmlW.writeStartElement(null,'tax-class', null);
                    xmlW.writeCharacters(taxClass);
                xmlW.writeEndElement(); // Close tax-class
                xmlW.writeCharacters('\n');     
                xmlW.writeStartElement(null,'force-price-flag', null);
                    xmlW.writeCharacters(String.valueOf(forcePriceFlag));
                xmlW.writeEndElement(); // Close force-price-flag
                xmlW.writeCharacters('\n');     
                xmlW.writeStartElement(null,'non-inventory-flag', null);
                    xmlW.writeCharacters(String.valueOf(nonInventoryFlag));
                xmlW.writeEndElement(); // Close non-inventory-flag
                xmlW.writeCharacters('\n'); 
                xmlW.writeStartElement(null,'non-discountable-flag', null);
                    xmlW.writeCharacters(String.valueOf(nonDiscountableFlag));
                xmlW.writeEndElement(); // Close non-discountable-flag
                xmlW.writeCharacters('\n');     
            xmlW.writeEndElement(); // store-attributes
            xmlW.writeCharacters('\n'); 
        xmlW.writeEndElement(); // Close product    
        xmlW.writeCharacters('\n');                         

        //System.debug(xmlW.getXmlString());        
        
        String xmlString = xmlW.getXmlString();
        
        return xmlString;
    }               
                
    // XML Definition for Class Listings (Community Classes and CPS Listings) 
    
    private String getClassXml(Boolean CPS, redwing__Training_Plan__c theLearningPlan, redwing__ILT_Class__c theClass, List<redwing__ILT_Session__c> theSessionList, redwing__ILT_Session__c theFirstSession) {
        // Unmapped attributes hard-coded for now
        String   siteMapIncludedFlag = 'None'; // Removing the attribute from the generated XML file forces this value to none
        String   taxClass = 'baseTax';  // The following four fields are static (values as per sample files)
        Boolean  forcePriceFlag = true;
        Boolean  nonInventoryFlag = true;
        Boolean  nonDiscountableFlag = true;

        XmlStreamWriter xmlW = new XmlStreamWriter();
        xmlW.writeStartElement(null,'product', null);
            xmlW.writeAttribute(null,null,'product-id',String.valueOf(theClass.Id).subString(0,15));
            xmlW.writeCharacters('\n');
            xmlW.writeStartElement(null,'display-name', null);
                xmlW.writeCharacters(theLearningPlan.Name);
            xmlW.writeEndElement(); // Close display-name
            xmlW.writeCharacters('\n');
            String longDescription = (theLearningPlan.redwing__About_RTA__c != null) ?
                theLearningPlan.redwing__About_RTA__c.replaceAll('<[^>]+>','').replaceAll('[^\\x00-\\x7f]', '') : '';           
            if (String.isNotEmpty(longDescription)) {
                xmlW.writeStartElement(null,'long-description', null);              
                    xmlW.writeCharacters(longDescription);
                xmlW.writeEndElement(); // Close long-description   
                xmlW.writeCharacters('\n');
            }   
            xmlW.writeStartElement(null,'online-flag', null);
                Boolean classOnline = (theClass.Class_Online__c != null) ? theClass.Class_Online__c : true;
                xmlW.writeCharacters(String.valueOf(classOnline));
            xmlW.writeEndElement(); // Close online-flag    
            xmlW.writeCharacters('\n');
            xmlW.writeStartElement(null,'online-from', null);
                Date classOnlineFrom = (theClass.Class_Online_From__c != null) ? theClass.Class_Online_From__c : Date.valueOf(theClass.CreatedDate);
                String dateTimeOnlineFrom = String.valueOf(classOnlineFrom)+'T00:00:00Z';
                xmlW.writeCharacters(String.valueOf(dateTimeOnlineFrom));
            xmlW.writeEndElement(); // Close online-from
            xmlW.writeCharacters('\n');
            xmlW.writeStartElement(null,'online-to', null);
                Date classOnlineTo;
                if (theClass.Class_Online_To__c != null) {
                    classOnlineTo = theClass.Class_Online_To__c;
                } else if (theClass.Request_Type__c == 'Online + Classroom') {
                    classOnlineTo = theFirstSession.redwing__Date__c.addDays(-1);
                } else {
                    classOnlineTo = theFirstSession.redwing__Date__c;
                }
                String dateTimeOnlineTo = String.valueOf(classOnlineTo)+'T00:00:00Z';
                xmlW.writeCharacters(String.valueOf(dateTimeOnlineTo));
            xmlW.writeEndElement(); // Close online-to
            xmlW.writeCharacters('\n');
            xmlW.writeStartElement(null,'searchable-flag', null);
                Boolean classSearchable = (theClass.Class_Searchable__c != null) ? theClass.Class_Searchable__c : false;
                xmlW.writeCharacters(String.valueOf(classSearchable));
            xmlW.writeEndElement(); // Close searchable-flag
            xmlW.writeCharacters('\n');
            xmlW.writeStartElement(null,'searchable-if-unavailable-flag', null);
                Boolean classSearchableIfUnavailable = (theClass.Class_Searchable_If_Unavailable__c != null) ? theClass.Class_Searchable_If_Unavailable__c : false;
                xmlW.writeCharacters(String.valueOf(classSearchableIfUnavailable));
            xmlW.writeEndElement(); // Close searchable-if-unavailable-flag
            xmlW.writeCharacters('\n'); 
            /* Remove sitemap-included attribute to force value to 'none' in DemandWare
            xmlW.writeStartElement(null,'sitemap-included-flag', null);
                 xmlW.writeCharacters(siteMapIncludedFlag);
            xmlW.writeEndElement(); // Close sitemap-included-flag  
            xmlW.writeCharacters('\n');  
            */                         
            
            CustomAttributes theCustomAttributes = new CustomAttributes(CPS, theLearningPlan, theClass, theSessionList, theFirstSession);
            
            xmlW = getCustomAttributesXML(CPS, xmlW, theCustomAttributes);
            
            xmlW.writeStartElement(null,'store-attributes', null);
            xmlW.writeCharacters('\n');
                xmlW.writeStartElement(null,'tax-class', null);
                    xmlW.writeCharacters(taxClass);
                xmlW.writeEndElement(); // Close tax-class
                xmlW.writeCharacters('\n');     
                xmlW.writeStartElement(null,'force-price-flag', null);
                    xmlW.writeCharacters(String.valueOf(forcePriceFlag));
                xmlW.writeEndElement(); // Close force-price-flag
                xmlW.writeCharacters('\n');     
                xmlW.writeStartElement(null,'non-inventory-flag', null);
                    xmlW.writeCharacters(String.valueOf(nonInventoryFlag));
                xmlW.writeEndElement(); // Close non-inventory-flag
                xmlW.writeCharacters('\n'); 
                xmlW.writeStartElement(null,'non-discountable-flag', null);
                    xmlW.writeCharacters(String.valueOf(nonDiscountableFlag));
                xmlW.writeEndElement(); // Close non-discountable-flag
                xmlW.writeCharacters('\n');     
            xmlW.writeEndElement(); // store-attributes
            xmlW.writeCharacters('\n'); 
        xmlW.writeEndElement(); // Close product    
        xmlW.writeCharacters('\n');                         

        //System.debug(xmlW.getXmlString());        
        
        String xmlString = xmlW.getXmlString();
        
        return xmlString;
    }                         
                
    // XML Definition for Class Listings (Online Classes) 
    
    private String getOnlineClassXml(redwing__Training_Plan__c theLearningPlan, redwing__Learning__c theLearningObject) {
        // Unmapped attributes hard-coded for now
        String   taxClass = 'baseTax';  // The following five fields are static (values as per sample files)
        Boolean  forcePriceFlag = true;
        Boolean  nonInventoryFlag = true;
        Boolean  nonRevenueFlag = false;
        Boolean  nonDiscountableFlag = true;

        XmlStreamWriter xmlW = new XmlStreamWriter();
        xmlW.writeStartElement(null,'product', null);
            xmlW.writeAttribute(null,null,'product-id',String.valueOf(theLearningObject.Id).subString(0,15));
            xmlW.writeCharacters('\n');
            xmlW.writeStartElement(null, 'ean', null);
            xmlW.writeEndElement();
            xmlW.writeCharacters('\n');            
            xmlW.writeStartElement(null, 'upc', null);
            xmlW.writeEndElement();       
            xmlW.writeCharacters('\n');                 
            xmlW.writeStartElement(null, 'unit', null);
            xmlW.writeEndElement();       
            xmlW.writeCharacters('\n');                 
            xmlW.writeStartElement(null, 'min-order-quantity', null);
                xmlW.writeCharacters('1');
            xmlW.writeEndElement();  
            xmlW.writeCharacters('\n');  
            xmlW.writeStartElement(null, 'step-quantity', null);
                xmlW.writeCharacters('1');
            xmlW.writeEndElement();  
            xmlW.writeCharacters('\n');                       
            xmlW.writeStartElement(null,'display-name', null);
                xmlW.writeCharacters(theLearningPlan.Name);
            xmlW.writeEndElement(); // Close display-name
            xmlW.writeCharacters('\n');
            String longDescription = (theLearningPlan.redwing__About_RTA__c != null) ?
                theLearningPlan.redwing__About_RTA__c.replaceAll('<[^>]+>','').replaceAll('[^\\x00-\\x7f]', '') : '';           
            if (String.isNotEmpty(longDescription)) {
                xmlW.writeStartElement(null,'long-description', null);          
                    xmlW.writeCharacters(longDescription);
                xmlW.writeEndElement(); // Close long-description   
                xmlW.writeCharacters('\n');
            }   
            xmlW.writeStartElement(null,'store-tax-class', null);
                xmlW.writeCharacters('baseTax');
            xmlW.writeEndElement(); // Close store-tax-class
            xmlW.writeCharacters('\n');   
            /*      
            xmlW.writeStartElement(null,'store-force-price-flag', null);
                xmlW.writeCharacters('true');
            xmlW.writeEndElement(); // Close store-force-price-flag
            xmlW.writeCharacters('\n');         
            xmlW.writeStartElement(null,'store-non-inventory-flag', null);
                xmlW.writeCharacters('true');
            xmlW.writeEndElement(); // Close store-non-inventory-flag
            xmlW.writeCharacters('\n');         
            xmlW.writeStartElement(null,'store-non-revenue-flag', null);
                xmlW.writeCharacters('false');
            xmlW.writeEndElement(); // Close store-non-revenue-flag     
            xmlW.writeCharacters('\n');             
            xmlW.writeStartElement(null,'store-non-discountable-flag', null);
                xmlW.writeCharacters('true');
            xmlW.writeEndElement(); // Close store-non-discountable-flag    
            xmlW.writeCharacters('\n');   
            */      
            xmlW.writeStartElement(null,'online-flag', null);
                Boolean classOnline = true;
                xmlW.writeCharacters(String.valueOf(classOnline));
            xmlW.writeEndElement(); // Close online-flag    
            xmlW.writeCharacters('\n');
            xmlW.writeStartElement(null,'online-from', null);
                Date classOnlineFrom = (theLearningPlan.redwing__Start_Date__c != null) ? theLearningPlan.redwing__Start_Date__c : Date.valueOf(theLearningPlan.CreatedDate);
                String dateTimeOnlineFrom = String.valueOf(classOnlineFrom)+'T00:00:00Z';
                xmlW.writeCharacters(String.valueOf(dateTimeOnlineFrom));
            xmlW.writeEndElement(); // Close online-from
            xmlW.writeCharacters('\n');
            xmlW.writeStartElement(null,'online-to', null);
                Date classOnlineTo = (theLearningPlan.redwing__End_Date__c != null) ? theLearningPlan.redwing__End_Date__c : Date.valueOf('2099-12-31');
                String dateTimeOnlineTo = String.valueOf(classOnlineTo)+'T00:00:00Z';
                xmlW.writeCharacters(String.valueOf(dateTimeOnlineTo));
            xmlW.writeEndElement(); // Close online-to
            xmlW.writeCharacters('\n');
            xmlW.writeStartElement(null,'available-flag', null);
                Boolean classAvailable = true;
                xmlW.writeCharacters(String.valueOf(classAvailable));
            xmlW.writeEndElement(); // Close available-flag
            xmlW.writeCharacters('\n');            
            xmlW.writeStartElement(null,'searchable-flag', null);
                Boolean classSearchable = true;
                xmlW.writeCharacters(String.valueOf(classSearchable));
            xmlW.writeEndElement(); // Close searchable-flag
            xmlW.writeCharacters('\n');
            xmlW.writeStartElement(null,'searchable-if-unavailable-flag', null);
                Boolean classSearchableIfUnavailable = false;
                xmlW.writeCharacters(String.valueOf(classSearchableIfUnavailable));
            xmlW.writeEndElement(); // Close searchable-if-unavailable-flag
            xmlW.writeCharacters('\n'); 
            xmlW.writeStartElement(null,'page-attributes', null);
            xmlW.writeEndElement();     
            xmlW.writeCharacters('\n');             

            OnlineCustomAttributes theOnlineCustomAttributes = new OnlineCustomAttributes(theLearningPlan, theLearningObject);
            
            xmlW = getOnlineCustomAttributesXML(xmlW, theOnlineCustomAttributes);
            
            xmlW.writeStartElement(null,'pinterest-enabled-flag', null);
                Boolean pinterestEnabled = false;
                xmlW.writeCharacters(String.valueOf(pinterestEnabled));
            xmlW.writeEndElement(); // Close pinterest-enabled-flag
            xmlW.writeCharacters('\n');            
            xmlW.writeStartElement(null,'facebook-enabled-flag', null);
                Boolean facebookEnabled = false;
                xmlW.writeCharacters(String.valueOf(facebookEnabled));
            xmlW.writeEndElement(); // Close pinterest-enabled-flag            
            xmlW.writeCharacters('\n');            
            xmlW.writeStartElement(null,'store-attributes', null);
            xmlW.writeCharacters('\n');
                xmlW.writeStartElement(null,'tax-class', null);
                    xmlW.writeCharacters(taxClass);
                xmlW.writeEndElement(); // Close tax-class
                xmlW.writeCharacters('\n');     
                xmlW.writeStartElement(null,'force-price-flag', null);
                    xmlW.writeCharacters(String.valueOf(forcePriceFlag));
                xmlW.writeEndElement(); // Close force-price-flag
                xmlW.writeCharacters('\n');     
                xmlW.writeStartElement(null,'non-inventory-flag', null);
                    xmlW.writeCharacters(String.valueOf(nonInventoryFlag));
                xmlW.writeEndElement(); // Close non-inventory-flag
                xmlW.writeCharacters('\n'); 
                xmlW.writeStartElement(null,'non-revenue-flag', null);
                    xmlW.writeCharacters(String.valueOf(nonRevenueFlag));
                xmlW.writeEndElement(); // Close non-revenue-flag
                xmlW.writeCharacters('\n');                 
                xmlW.writeStartElement(null,'non-discountable-flag', null);
                    xmlW.writeCharacters(String.valueOf(nonDiscountableFlag));
                xmlW.writeEndElement(); // Close non-discountable-flag
                xmlW.writeCharacters('\n');     
            xmlW.writeEndElement(); // store-attributes
            xmlW.writeCharacters('\n'); 
        xmlW.writeEndElement(); // Close product    
        xmlW.writeCharacters('\n');                         

        //System.debug(xmlW.getXmlString());        
        
        String xmlString = xmlW.getXmlString();
        
        return xmlString;
    }               
                   
    private XmlStreamWriter getCustomAttributesXML(Boolean CPS, XmlStreamWriter xmlW, CustomAttributes theCustomAttributes) {
        xmlW.writeStartElement(null,'custom-attributes', null);
        xmlW.writeCharacters('\n');
     
        for (String fieldName : theCustomAttributes.customAttributeValueMap.keySet()) {
            if (CPS) {
                if ('attachmentID attachmentName attachmentURL AttachmentCategory'.contains(fieldName)) continue;
            } else {
                if ('ltpName ltpUrl'.contains(fieldName)) continue;
            }
            String theFieldValue = theCustomAttributes.customAttributeValueMap.get(fieldName);
            if (String.isNotEmpty(theFieldValue)) {         
                xmlW.writeStartElement(null,'custom-attribute', null);
                    xmlW.writeAttribute(null,null,'attribute-id', fieldName);
                    if ('CourseDates,CourseDaysOfWeek,CourseStartTime,CourseEndTime,OfferingMonth,DayOfMonth,DayOfWeek'.contains(fieldName)) {
                        String[] fieldValues = theFieldValue.split(';');
                        for (String nextFieldValue : fieldValues) {
                            xmlW.writeStartElement(null,'value', null); 
                            xmlW.writeCharacters(nextFieldValue);
                            xmlW.writeEndElement(); // Close nextFieldValue                 
                        }
                    } else xmlW.writeCharacters(theFieldValue);
                xmlW.writeEndElement(); // Close custom-attribute   
                xmlW.writeCharacters('\n');
            }
        }

        xmlW.writeEndElement(); // Close custom-attributes
        xmlW.writeCharacters('\n');
        
        return xmlW;
    } 
                   
    private XmlStreamWriter getOnlineCustomAttributesXML(XmlStreamWriter xmlW, OnlineCustomAttributes theOnlineCustomAttributes) {
        xmlW.writeStartElement(null,'custom-attributes', null);
        xmlW.writeCharacters('\n');

        for (String fieldName : theOnlineCustomAttributes.customAttributeValueMap.keySet()) {
            String theFieldValue = theOnlineCustomAttributes.customAttributeValueMap.get(fieldName);
            if (String.isNotEmpty(theFieldValue)) {         
                xmlW.writeStartElement(null,'custom-attribute', null);
                    xmlW.writeAttribute(null,null,'attribute-id', fieldName);
                    if ('CourseDates'.contains(fieldName)) {
                        String[] fieldValues = theFieldValue.split(';');
                        for (String nextFieldValue : fieldValues) {
                            xmlW.writeStartElement(null,'value', null); 
                            xmlW.writeCharacters(nextFieldValue);
                            xmlW.writeEndElement(); // Close nextFieldValue                 
                        }
                    } else xmlW.writeCharacters(theFieldValue);
                xmlW.writeEndElement(); // Close custom-attribute   
                xmlW.writeCharacters('\n');
            }
        }

        xmlW.writeEndElement(); // Close custom-attributes
        xmlW.writeCharacters('\n');
        
        return xmlW;
    }     
    
    private String getLocationXml(redwing__ILT_Location__c theLocation, String syntheticId, String thePhoneNumber, Location theGeoLocation) {
        // Hard-code values for unmapped attributes for now
        Boolean  storeLocatorEnabledFlag = true;
        Boolean  demandwarePosEnabledFlag = true;
        Boolean  posEnabledFlag = true;
        String   inventoryListId = '1';
        
        Boolean  syntheticKey = (theLocation.Id == null) ? true : false;
        String   locationKeyPrefix = redwing__ILT_Location__c.SObjectType.getDescribe().getKeyPrefix();     
        
        XmlStreamWriter xmlW = new XmlStreamWriter();
        xmlW.writeStartElement(null,'store', null);
            String locationId;
            if (syntheticKey) {
                locationId = locationKeyPrefix+(syntheticId.substring(3,15));
            } else {
                locationId = String.valueOf(theLocation.Id).subString(0,15);
            }
            xmlW.writeAttribute(null,null,'store-id',locationId);
            xmlW.writeCharacters('\n');
            if (String.isNotEmpty(theLocation.Name)) {
                xmlW.writeStartElement(null,'name', null);
                    xmlW.writeCharacters(theLocation.Name);
                xmlW.writeEndElement(); // Close name  
                xmlW.writeCharacters('\n');                                 
            }
            if (String.isNotEmpty(theLocation.redwing__Address_1__c)) {       
                xmlW.writeStartElement(null,'address1', null);
                    xmlW.writeCharacters(theLocation.redwing__Address_1__c);
                xmlW.writeEndElement(); // Close address1 
                xmlW.writeCharacters('\n');
            }
            if (String.isNotEmpty(theLocation.redwing__Address_2__c)) { 
                xmlW.writeStartElement(null,'address2', null);
                    xmlW.writeCharacters(theLocation.redwing__Address_2__c);
                xmlW.writeEndElement(); // Close address2  
                xmlW.writeCharacters('\n');  
            }
            if (String.isNotEmpty(theLocation.redwing__City__c)) {
                xmlW.writeStartElement(null,'city', null);
                    xmlW.writeCharacters(theLocation.redwing__City__c);
                xmlW.writeEndElement(); // Close city  
                xmlW.writeCharacters('\n');  
            } 
            if (String.isNotEmpty(theLocation.redwing__Postal_Code__c)) {
                xmlW.writeStartElement(null,'postal-code', null);
                    xmlW.writeCharacters(theLocation.redwing__Postal_Code__c);
                xmlW.writeEndElement(); // Close postal-code  
                xmlW.writeCharacters('\n');  
            }
            if (String.isNotEmpty(theLocation.redwing__State__c)) {
                xmlW.writeStartElement(null,'state-code', null);
                    xmlW.writeCharacters(theLocation.redwing__State__c);
                xmlW.writeEndElement(); // Close state-code  
                xmlW.writeCharacters('\n'); 
            }   
            if (String.isEmpty(theLocation.redwing__Country__c)) {
                theLocation.redwing__Country__c = 'US';
            } 
                xmlW.writeStartElement(null,'country-code', null);
                    xmlW.writeCharacters(theLocation.redwing__Country__c.substring(0,2));
                xmlW.writeEndElement(); // Close country-code  
                xmlW.writeCharacters('\n');  
            if (!syntheticKey && theLocation.Skedulo_Location__c != null
                && theLocation.Skedulo_Location__r.sked__Account__c != null
                && theLocation.Skedulo_Location__r.sked__Account__r.Billing_Contact_email__c != null) {
                xmlW.writeStartElement(null,'email', null);
                    xmlW.writeCharacters(theLocation.Skedulo_Location__r.sked__Account__r.Billing_Contact_email__c);
                xmlW.writeEndElement(); // Close email  
                xmlW.writeCharacters('\n');     
            }
            if (!syntheticKey && theLocation.Skedulo_Location__c != null
                && theLocation.Skedulo_Location__r.sked__Account__c != null
                && String.isNotEmpty(theLocation.Skedulo_Location__r.sked__Account__r.Billing_Contact_phone__c)) {          
                xmlW.writeStartElement(null,'phone', null);
                    xmlW.writeCharacters(theLocation.Skedulo_Location__r.sked__Account__r.Billing_Contact_phone__c);
                xmlW.writeEndElement(); // Close phone  
                xmlW.writeCharacters('\n'); 
            }
            xmlW.writeStartElement(null,'store-hours', null);        
            xmlW.writeEndElement(); // Close store-hours
            xmlW.writeCharacters('\n'); 
             
            String geoLatitude = '';
            if (!syntheticKey && theLocation.Skedulo_Location__c != null
                && theLocation.Skedulo_Location__r.sked__GeoLocation__c != null) {
                geoLatitude = String.valueOf(theLocation.Skedulo_Location__r.sked__GeoLocation__c.getLatitude());
            } else if (syntheticKey && theGeoLocation != null) {
                geoLatitude = String.valueOf(theGeoLocation.getLatitude());
            }
            if (String.isNotEmpty(geoLatitude)) {
                xmlW.writeStartElement(null,'latitude', null);
                    xmlW.writeCharacters(geoLatitude);
                xmlW.writeEndElement(); // Close latitude 
                xmlW.writeCharacters('\n');  
            }
            
            String geoLongitude = '';
            if (!syntheticKey && theLocation.Skedulo_Location__c != null
                && theLocation.Skedulo_Location__r.sked__GeoLocation__c != null) {
                geoLongitude = String.valueOf(theLocation.Skedulo_Location__r.sked__GeoLocation__c.getLongitude());
            } else if (syntheticKey && theGeoLocation != null) {
                geoLongitude = String.valueOf(theGeoLocation.getLongitude());
            }
            if (String.isNotEmpty(geoLongitude)) {
                xmlW.writeStartElement(null,'longitude', null);
                    xmlW.writeCharacters(geoLongitude);                     
                xmlW.writeEndElement(); // Close longitude
                xmlW.writeCharacters('\n'); 
            }             
            xmlW.writeStartElement(null,'store-locator-enabled-flag', null);
                xmlW.writeCharacters(String.valueOf(storeLocatorEnabledFlag));
            xmlW.writeEndElement(); // Close store-locator-enabled-flag  
            xmlW.writeCharacters('\n');     
            xmlW.writeStartElement(null,'demandware-pos-enabled-flag', null);
                xmlW.writeCharacters(String.valueOf(demandwarePosEnabledFlag));
            xmlW.writeEndElement(); // Close demandware-pos-enabled-flag  
            xmlW.writeCharacters('\n');        
            xmlW.writeStartElement(null,'pos-enabled-flag', null);
                xmlW.writeCharacters(String.valueOf(posEnabledFlag));
            xmlW.writeEndElement(); // Close pos-enabled-flag  
            xmlW.writeCharacters('\n');                                
            xmlW.writeStartElement(null,'custom-attributes',null);
                xmlW.writeStartElement(null,'custom-attribute', null);
                    xmlW.writeAttribute(null,null,'attribute-id', 'inventoryListId');
                    xmlW.writeCharacters(inventoryListId);
                xmlW.writeEndElement(); // Close custom-attribute   
            xmlW.writeEndElement(); // Close custom-attributes
            xmlW.writeCharacters('\n');         
        xmlW.writeEndElement(); // Close store    
        xmlW.writeCharacters('\n');                         

        //System.debug(xmlW.getXmlString());        
        
        String xmlString = xmlW.getXmlString();
        
        return xmlString;
    }
    
    private String getSiteCatalogXml(sObject theObject) { // Supports both ILT Class and Learning Plan objects
        String theRecordId = (String)theObject.get('Id');
        XmlStreamWriter xmlW = new XmlStreamWriter();
        xmlW.writeStartElement(null,'category-assignment', null);
            xmlW.writeAttribute(null,null,'category-id','hidden');        
            xmlW.writeAttribute(null,null,'product-id',theRecordId.subString(0,15)); // String.valueOf(theClass.Id).subString(0,15));
        xmlW.writeEndElement(); // Close category-assignment
        xmlW.writeCharacters('\n');  

        //System.debug(xmlW.getXmlString());        
        
        String xmlString = xmlW.getXmlString();
        
        return xmlString;
    }   
                  
    private String getInventoryXml(sObject theObject, Integer classInventory, Boolean onlineCourse) {
        XmlStreamWriter xmlW = new XmlStreamWriter();
        Id theRecordId = (Id)theObject.get('Id');
        xmlW.writeStartElement(null,'record', null);      
            xmlW.writeAttribute(null,null,'product-id',String.valueOf(theRecordId).subString(0,15));
            xmlW.writeCharacters('\n');  
            if (!onlineCourse) {           
                xmlW.writeStartElement(null,'allocation',null);
                    Integer seatsAvailable = (classInventory == null) ? 0 : classInventory;
                    xmlW.writeCharacters(String.valueOf(seatsAvailable)); 
                xmlW.writeEndElement(); // Close allocation  
                xmlW.writeCharacters('\n');                 
            }             
            xmlW.writeStartElement(null,'perpetual',null);
                Boolean perpetual = (onlineCourse) ? true : false;
                xmlW.writeCharacters(String.valueOf(perpetual)); 
            xmlW.writeEndElement(); // Close perpetual  
            xmlW.writeCharacters('\n');             
            xmlW.writeStartElement(null,'preorder-backorder-handling',null);
                xmlW.writeCharacters('none'); 
            xmlW.writeEndElement(); // Close preorder-backorder-handling   
            xmlW.writeCharacters('\n');                                                 
        xmlW.writeEndElement(); // Close record
        xmlW.writeCharacters('\n');  

        //System.debug(xmlW.getXmlString());        
        
        String xmlString = xmlW.getXmlString();
        
        return xmlString;
    } 
    
    private String getPricebookXml(sObject theObject, Double theRetailPrice) {
        Id theObjectId = (Id)theObject.get('Id');
        XmlStreamWriter xmlW = new XmlStreamWriter();
        xmlW.writeStartElement(null,'price-table', null); 
            theRetailPrice = (theRetailPrice == null) ? 0 : theRetailPrice;      
            xmlW.writeAttribute(null,null,'product-id',String.valueOf(theObjectId).subString(0,15));
            xmlW.writeCharacters('\n');  
            xmlW.writeStartElement(null,'amount', null);        
                xmlW.writeAttribute(null,null,'quantity','1'); 
                xmlW.writeCharacters(String.valueOf(theRetailPrice));                       
            xmlW.writeEndElement(); // Close amount
            xmlW.writeCharacters('\n');  
        xmlW.writeEndElement(); // Close price-table
        xmlW.writeCharacters('\n');                  

        //System.debug(xmlW.getXmlString());        
        
        String xmlString = xmlW.getXmlString();
        
        return xmlString;
    }     
             
    // This XML trailer is used for both Course/Class as well as CPS requests         
                                
    private String getCourseXmlTrailer() {   
        return '</catalog>';    
    }   
    
    private String getLocationXmlTrailer() {   
        return '</stores>';    
    }    
          
    private String getSiteCatalogXmlTrailer() {   
        return '</catalog>';    
    }
    
    private String getInventoryXmlTrailer() {   
        return '</records>\n</inventory-list>\n</inventory>';    
    }
            
    private String getPricebookXmlTrailer() {   
        return '</price-tables>\n</pricebook>\n</pricebooks>';    
    }
}