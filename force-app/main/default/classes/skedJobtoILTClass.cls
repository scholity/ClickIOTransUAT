public without sharing class skedJobtoILTClass {
    public Boolean updateRecords = false;
    public static Set<Id> insertedJobs = new Set<Id>();
    public static Set<Id> updatedJobs = new Set<Id>();

    public void afterInsert(List<sked__Job__c> newRecords) {
        // Create dummy old list of jobs (Map with no values) so we have one entry point to process jobs (UpsertILTClass)
        Map<Id, sked__Job__c> oldRecords = new Map<Id, sked__Job__c>();

        // call checkEligibility method to make sure the user is eligible to trigger the logic
        if (!checkEligibility()) {
            System.debug('eligibility check negative');
            return;
        }
        System.debug('eligibility check positive');

        updateRecords = false;
        
        List<sked__Job__c> lstnewRecords = new List<sked__Job__c>();
            
        for(sked__Job__c jobRecord : newRecords) {
            if (!insertedJobs.contains(jobRecord.Id)) {
                if (checkJobStatus(jobRecord)) {
                    lstnewRecords.add(jobRecord);
                    insertedJobs.add(jobRecord.Id);
                }
            }
        }

        System.debug('lstnewrecords is new '+lstnewRecords);
        upsertILTClass(lstnewRecords, oldRecords);
    }
    
    public void afterUpdate(List<sked__Job__c> newRecords, Map<Id, sked__Job__c> oldRecords) {
        // call checkEligibility method to make sure the user is eligible to trigger the logic
        if (!checkEligibility()) {
            System.debug('eligibility check negative');
            return;
        }
        System.debug('eligibility check positive');

        updateRecords = true;

        List<sked__Job__c> lstnewRecords = new List<sked__Job__c>();
        Map<Id, sked__Job__c> MapCanceledJobs = new Map<Id, sked__Job__c>();
            
        for(sked__Job__c jobRecord : newRecords) {
            if (!updatedJobs.contains(jobRecord.Id)) {
                sked__Job__c oldJob = oldRecords.get(jobRecord.Id);
                if (oldJob.sked__Job_Status__c != jobRecord.sked__Job_Status__c && jobRecord.sked__Job_Status__c == 'Cancelled') {
                    MapCanceledJobs.put(jobRecord.Id, jobRecord);
                    updatedJobs.add(jobRecord.Id);
                } else if (jobRecord.sked__Job_Status__c != 'Cancelled') {
                    if (checkJobStatus(jobRecord)) {
                        //if (checkClassJobFields(jobRecord, oldJob) || checkSessionJobFields(jobRecord, oldJob)) {
                            lstnewRecords.add(jobRecord);
                            updatedJobs.add(jobRecord.Id);
                        //}
                    }
                }
            }
        }
        
        if(!lstnewRecords.isEmpty()) {
            System.debug('lstnewrecords is '+lstnewRecords);
            upsertILTClass(addDependentStackedClasses(lstnewRecords, false), oldRecords);
        }
        
        if(!MapCanceledJobs.isEmpty()) {   
            List<sked__Job__c> lstCanceledJobs = MapCanceledJobs.values();  
            for (sked__Job__c theJob : addDependentStackedClasses(lstCanceledJobs, true)) {
                if (!MapCanceledJobs.containsKey(theJob.Id)) {
                    MapCanceledJobs.put(theJob.Id, theJob);
                }
            }       
            cancelRelatedRecords(MapCanceledJobs); 
        }   
    }
    
    public void beforeDelete(Map<Id, sked__Job__c> MapCanceledJobs){
        //  cancelRelatedRecords(MapCanceledJobs);
    } 
    
    public List<sked__Job__c> addDependentStackedClasses(List<sked__Job__c> jobList, Boolean bCancel) {
        // Augment both updated and deleted job Lists as they may contain master classes for stacked classes
        // Workaround: Skedulo only assigns instructors to the master (parent) class in a stacked class, and in addition
        // only updates the master (parent) class when a stacked class is canceled.  This code block forces the child (dependent) 
        // classes to be updated/canceled when the master class is updated, resulting in an assignment of an instructor to and/or 
        // the cancellation of these dependent classes when an updated job is received from Skedulo
            
        String objectName = 'sked__Job__c';
        String masterJobIds = '';
        String jobQuery = '';
        Set<Id> jobIds = new Set<Id>();
        
        for (sked__Job__c theJob : jobList) {
            jobIds.add(theJob.Id);  
            if (theJob.Is_Stacked_Class__c==true && theJob.Is_Master_Class__c==true) {
                if (masterJobIds.length() > 0) {
                    masterJobIds += ',';
                }
                masterJobIds += '\''+theJob.Id+'\'';
            }
        }
        
        if (String.isNotBlank(masterJobIds)) {            
            Map<String, Schema.SObjectField> jobFields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
            
            for(String theField : jobFields.keySet()) {
                if (jobQuery.length() > 0) {
                    jobQuery += ',';
                }
                jobQuery += theField;
            }
            // Build a query to return all of the dependent classes for each class contained in master job List
            jobQuery = 'Select '+jobQuery+' From '+objectName+' Where Is_Stacked_Class__c = true And Is_Master_Class__c = false ';
            jobQuery += ' And sked__Parent__c In ('+masterJobIds+')';
            
            List <sked__Job__c> dependentJobs = new List <sked__Job__c>();
            dependentJobs = Database.query(jobQuery);
            
            if (!dependentJobs.isEmpty()) {
                for (sked__Job__c theDependentJob : dependentJobs) {
                    if (bCancel) theDependentJob.sked__Job_Status__c = 'Cancelled';
                    if (!jobIds.contains(theDependentJob.Id)) jobList.add(theDependentJob);
                }
            }
        }  
        return jobList;               
    }
    
    public  Map<Id, String> learningPlanName;
    public  Map<Id, Datetime> learningPlancDate;
    public  Map<Id, String> learningPlancs;
    public  Map<Id, Id> learningplancc;
    public  Map<Id, Id> locationToILTLocationMap = new Map<Id, Id>();
    public  Map<Id, String> locationToILTLocationZip = new Map<Id, String>();  
    public  Map<Id, Id> resourceToInstructorMap = new Map<Id, Id>();
    public  Map<Id, Decimal> jobPriceOverrIdeMap = new Map<Id, Decimal>();
    public  Map<Id, redwing__ILT_Class__c> jobToClassMap = new Map<Id, redwing__ILT_Class__c>();
    public  Map<Id, redwing__ILT_Class__c> newJobToClassMap = new Map<Id, redwing__ILT_Class__c>();
    
    public  List<sked__Job_Allocation__c> jobAllocationList = new List<sked__Job_Allocation__c>();   
    public  List<redwing__ILT_Instructor__c> jobInstructorList = new List<redwing__ILT_Instructor__c>();      
    public  Map<Id, Set<Id>> jobAllocationMap = new Map<Id, Set<Id>>();
    public  Map<Id, Set<Id>> scheduleAllocationMap = new Map<Id, Set<Id>>();    
    public  Map<Id, List<redwing__ILT_Instructor__c>> jobInstructorMap = new Map<Id, List<redwing__ILT_Instructor__c>>();
    public  Map<Id, List<redwing__ILT_Instructor__c>> scheduleInstructorMap = new Map<Id, List<redwing__ILT_Instructor__c>>();    
    public  Map<Id, Id> instructorResourceMap = new Map<Id, Id>();        
    public  Map<Id, Id> jobCatalogMap = new Map<Id, Id>();
    public  Map<String, Id> CCwithIds = new Map<String, Id>();
    public  Map<Id, ccrz__E_Product__c > catalogIds = new Map<Id, ccrz__E_Product__c >();  
    public  Map<String, String> timeZoneMap = new Map<String,String> 
       {'US/Eastern' => 'America/New_York',
        'US/Central' => 'America/Chicago',
        'US/Mountain' => 'America/Denver',
        'US/Pacific' => 'America/Los_Angeles',
        'US/Alaska' => 'America/Anchorage',
        'US/Arizona' => 'America/Phoenix',
        'US/Hawaii' => 'Pacific/Honolulu',
        'America/Puerto_Rico' => 'America/Puerto_Rico'};
            
            
          //Fetch Joblearning Map - List of Learning, learning plan, product and catalog records
    public  Map<Id, Id> fetchJobLearningMap(List<sked__Job__c> newRecords){      
        Map<Id, Id> jobLearningMap = new Map<Id, Id>();
        
        Set<Id> locationIds = new Set<Id>();
        Set<Id> resourceIds = new Set<Id>();   
        
        Set<Id> jobIds = new Set<Id>();
        Set<Id> masterJobIds = new Set<Id>();              

        // Build a Map of Skedulo Course Catalog Id to Job Id, and all Locations and Jobs in Scope
        
        // Get a Map of all course catalog available to match it with course code in Stacked class
        for(Course_Catalog__c cc:[SELECT Name, Id FROM Course_Catalog__c where Type__c!=null limit 10000])
        {
            CCwithIds.put(cc.name, cc.Id);
        }
        //System.debug('Course catalog with Name and Id' +CCwithIds);
                
        for(sked__Job__c curJobRecord : newRecords){    
            if(curJobRecord.Is_Stacked_Class__c==true){   
                if(CCwithIds.containsKey(curJobRecord.Course_Code__c)){ 
                    jobIds.add(curJobRecord.Id);                            
                    System.debug('*** Job:'+curJobRecord.Name+' is a valid stacked class with course code:'+curJobRecord.Course_Code__c);
                    jobCatalogMap.put(curJobRecord.Id, CCwithIds.get(curJobRecord.Course_Code__c));//JobId with respective course catalog record - only stacked class
                    System.debug('*** Job catalog Map stacked class:'+jobCatalogMap);
                    
                    // *** US1493 - Enhancement to Skedulo record allocation to jobs
                    // It was noticed that Skedulo does NOT assign a resource to stacked classes (only the master class)
                    // masterJobIds insures that if the master class was created first that the stacked classes are assigned an instructor 
                    // (Note the above disclaimer - this is an important assumption in this design - record order cannot be guaranteed) 
                    if (curJobRecord.Is_Master_Class__c == false && curJobRecord.sked__Parent__c != null) {
                        masterJobIds.add(curJobRecord.sked__Parent__c);
                        System.debug('Adding masterJobId:'+curJobRecord.sked__Parent__c);
                    }
                }
            }
            else
            {
                jobIds.add(curJobRecord.Id);                        
                jobCatalogMap.put(curJobRecord.Id, curJobRecord.Course_Catalog__c); //JobId with respective course catalog record(Stacked class not included)
                System.debug('*** Job:'+curJobRecord.name+' is a normal class:'+jobCatalogMap);
            }
            
            if(curJobRecord.sked__Location__c != null){
                locationIds.add(curJobRecord.sked__Location__c);
            }
            System.debug('locationIds='+locationIds);  
        }
        
        //Usage help:
        //CCwithIds     - Map of all course catalog records - Name and Id pair
        //jobIds        - List of valId job Ids 
        //jobCatalogMap - Job Id along with course catalog
        //locationIds   - Location for specific jobId 
        
        
        // Build a Set of all Skedulo Resource Ids that are allocated to Jobs in Skedulo (can be many-to-one)
        // Also build List of allocated instructors by job to support updating assignments when job is processed 
        // Note: Instructors are currently only assigned to master jobs in Skedulo stacked jobs       
        
        if(!jobIds.IsEmpty()) {
            jobAllocationList = [Select sked__Job__c, sked__Job__r.sked__Recurring_Schedule__c, sked__Resource__c 
                From sked__Job_Allocation__c 
                Where (sked__Job__c In :jobIds Or sked__Job__c IN :masterJobIds)
                And sked__Status__c Not In ('Deleted','Declined')];
            
            Set<Id> jobResources;
            Set<Id> scheduleResources;
            for (sked__Job_Allocation__c theAllocation : jobAllocationList) {
                resourceIds.add(theAllocation.sked__Resource__c);
                if (jobAllocationMap.containsKey(theAllocation.sked__Job__c)) {
                    jobResources = jobAllocationMap.get(theAllocation.sked__Job__c);
                } else {
                    jobResources = new Set<Id>();
                }
                jobResources.add(theAllocation.sked__Resource__c);
                jobAllocationMap.put(theAllocation.sked__Job__c, jobResources);
                    
                if (theAllocation.sked__Job__r.sked__Recurring_Schedule__c != null) {
                    if (scheduleAllocationMap.containsKey(theAllocation.sked__Job__r.sked__Recurring_Schedule__c)) {
                        scheduleResources = scheduleAllocationMap.get(theAllocation.sked__Job__r.sked__Recurring_Schedule__c);
                    } else {
                        scheduleResources = new Set<Id>();
                    }
                    scheduleResources.add(theAllocation.sked__Resource__c);
                    scheduleAllocationMap.put(theAllocation.sked__Job__r.sked__Recurring_Schedule__c, scheduleResources);                   
                }
            }
            System.debug('resourceIds='+resourceIds);
            System.debug('jobAllocationMap='+jobAllocationMap);    
            System.debug('scheduleAllocationMap='+scheduleAllocationMap);              
            
            // Build a Map of instructors assigned to each ILT Class by job, as well as a Map of 
            // resources assigned to each job in Skedulo (system of record).  Any deltas will be corrected
            // via inserts or deletions of redwing__ILT_Intructor__c records.
            
            jobInstructorList = [Select Id, redwing__ILT_Class__r.Skedulo_Job_Id__c, 
                redwing__ILT_Class__r.Skedulo_Job_Id__r.sked__Recurring_Schedule__c, redwing__Instructor__c
                From redwing__ILT_Instructor__c 
                Where redwing__ILT_Class__r.Skedulo_Job_Id__c in :jobIds Or redwing__ILT_Class__r.Skedulo_Job_Id__c IN :masterJobIds];

            Set<Id> instructorSet = new Set<Id>();
            for (redwing__ILT_Instructor__c theILTInstructor : jobInstructorList) {
              instructorSet.add(theILTInstructor.redwing__Instructor__c);
            }
            
            List<redwing__Instructor__c> userInstructorList = [Select redwing__User__c, Skedulo_Instructor__c
              From redwing__Instructor__c Where redwing__User__c in :instructorSet];
              
            for (redwing__Instructor__c theInstructor : userInstructorList) {
              instructorResourceMap.put(theInstructor.redwing__User__c, theInstructor.Skedulo_Instructor__c);
            }  
            System.debug('instructorResourceMap='+instructorResourceMap);               
                
            List<redwing__ILT_Instructor__c> instructorList;
                
            // Create Map of job to currently assigned instructors for non-recurring schedules
            for (redwing__ILT_Instructor__c theInstructor : jobInstructorList) {
                if(theInstructor.redwing__Instructor__c != null && instructorResourceMap.containsKey(theInstructor.redwing__Instructor__c)
                    && theInstructor.redwing__ILT_Class__r.Skedulo_Job_Id__c != null) {
                    if (jobInstructorMap.containsKey(theInstructor.redwing__ILT_Class__r.Skedulo_Job_Id__c)) {
                        instructorList = jobInstructorMap.get(theInstructor.redwing__ILT_Class__r.Skedulo_Job_Id__c);
                    } else {
                        instructorList = new List<redwing__ILT_Instructor__c>();
                    }
                    instructorList.add(theInstructor);
                    jobInstructorMap.put(theInstructor.redwing__ILT_Class__r.Skedulo_Job_Id__c, instructorList);
                }               
            }
            System.debug('jobInstructorMap='+jobInstructorMap);
            
            // Create of recurring schedule to currently assigned instructors for recurring schedules
            for (redwing__ILT_Instructor__c theInstructor : jobInstructorList) {
                if(theInstructor.redwing__Instructor__c != null && instructorResourceMap.containsKey(theInstructor.redwing__Instructor__c)
                    && theInstructor.redwing__ILT_Class__r.Skedulo_Job_Id__r.sked__Recurring_Schedule__c != null) {
                    if (scheduleInstructorMap.containsKey(theInstructor.redwing__ILT_Class__r.Skedulo_Job_Id__r.sked__Recurring_Schedule__c)) {
                        instructorList = scheduleInstructorMap.get(theInstructor.redwing__ILT_Class__r.Skedulo_Job_Id__r.sked__Recurring_Schedule__c);
                    } else {
                        instructorList = new List<redwing__ILT_Instructor__c>();
                    }
                    instructorList.add(theInstructor);
                    scheduleInstructorMap.put(theInstructor.redwing__ILT_Class__r.Skedulo_Job_Id__r.sked__Recurring_Schedule__c, instructorList);
                }               
            }   
            System.debug('scheduleInstructorMap='+scheduleInstructorMap);             
        }  
        
        // Use the List of Skedulo Resource Ids to build a Map of Resource to Appinium Instructor Ids
        
        if(!resourceIds.IsEmpty()){
            for (redwing__Instructor__c instructor : [Select Id, Skedulo_Instructor_External__c, redwing__User__c from redwing__Instructor__c where Skedulo_Instructor__c in :resourceIds]) {
                if(instructor.Skedulo_Instructor_External__c != null){
                    resourceToInstructorMap.put(instructor.Skedulo_Instructor_External__c, instructor.redwing__User__c);
                }
            }
            System.debug('resourceToInstructorMap='+resourceToInstructorMap);            
        }         
        
        //Usage help:
        //resourceToInstructorMap - Appinium Instructor User - Map of Skedulo_Instructor_External__c and User
        
        // Build a Map of Skedulo Location Ids to Appinium ILT Location Ids (one-to-one)
        // *****
        // US1356 - Determine if class-specific (geography-specific) pricing is defined for any job
        // Added redwing__Postal_Code__c to query, added new Map locationToILTLocationZip
        // *****        
        
        if(!locationIds.IsEmpty()){
            for(redwing__ILT_Location__c loctn : [Select Id, Skedulo_Location_External__c, redwing__Postal_Code__c from redwing__ILT_Location__c where Skedulo_Location_External__c IN: locationIds]){
                if(loctn.Skedulo_Location_External__c != null){
                    locationToILTLocationMap.put(loctn.Skedulo_Location_External__c, loctn.Id);  
                    locationToILTLocationZip.put(loctn.Skedulo_Location_External__c, loctn.redwing__Postal_Code__c);
                }  
            }
            System.debug('locationToILTLocationMap='+locationToILTLocationMap);
        }
        
        //Usage help:
        //locationToILTLocationMap - Map of location external and location Id 
        //locationToILTLocationZip - Map with zip codes of the location
                
        if(!jobCatalogMap.keySet().isEmpty()){
            List<ccrz__E_Product__c> productCatalogRecords = [Select Id, Course_Catalog__c, Course_Catalog__r.Number_of_Students__c, Course_Catalog__r.Number_of_Instructors__c, Course_Catalog__r.Ratio_to_Instructor__c,
                LMS_Learning_Plan__c, LMS_Learning_Plan__r.Name, LMS_Learning_Plan__r.CreatedDate, LMS_Learning_Plan__r.redwing__End_Date__c, LMS_Learning_Plan__r.Classroom_Setting__c
                From ccrz__E_Product__c where Course_Catalog__c in :jobCatalogMap.values()];
                
            System.debug('productCatalogRecords ='+productCatalogRecords );
            if(!productCatalogRecords.isEmpty()){
                Map<Id, Id> learningPlanIds = new Map<Id, Id>();
                learningPlanName = new Map<Id, String>();
                learningPlancDate = new Map<Id, Datetime>();
                learningPlancs = new Map<Id, String>();
                learningplancc = new Map<Id, Id>();
                // Build Map of Learning Plan Ids to Course Catalog record
                for(ccrz__E_Product__c productCatalog : productCatalogRecords) {
                    if(productCatalog.LMS_Learning_Plan__c != null) {
                        learningPlanName.put(productCatalog.Course_Catalog__c, productCatalog.LMS_Learning_Plan__r.Name);
                        learningPlancDate.put(productCatalog.Course_Catalog__c, productCatalog.LMS_Learning_Plan__r.CreatedDate);
                        learningPlancs.put(productCatalog.Course_Catalog__c, productCatalog.LMS_Learning_Plan__r.Classroom_Setting__c);
                        learningPlanIds.put(productCatalog.LMS_Learning_Plan__c, productCatalog.Course_Catalog__c);
                        learningplancc.put(productCatalog.Course_Catalog__c, productCatalog.LMS_Learning_Plan__c);
                        catalogIds.put(productCatalog.Course_Catalog__c, productCatalog);
                        System.debug('Id1' +learningPlancDate);
                        System.debug('Id2' +learningPlancs);
                        System.debug('Id3' +learningPlanIds);
                        System.debug('Id4' +learningplancc);
                        System.debug('Id5' +catalogIds);
                        
                        
                    }
                }
                //Usage help:
                // productCatalogRecords - List of all produts that belong to the course catalog of that specific job
                // learningPlanIds - Map of Product's learning plan and product's course catalog records
                //learningPlanName - Map of Product's course catalog with product's learning plan name
                //learningPlancDate - Map of Product's course catalog with learning plan's date belonging to that product
                //learningPlancs - Map of Product's course catalog with learning plan's classroomSettings belonging to the product 
                //learningplancc - Map of Product's course catalog with product's learning plan
                        
                        
                if(!learningPlanIds.keySet().isEmpty()){
                    System.debug('learningPlanIds='+learningPlanIds);
                    
                    // Get Set of Learning Plan Sections across all Learning Plans in scope
                    List <redwing__Training_Plan_Section__c> learningPlanSections =  [Select Id, redwing__Training_Plan__c from redwing__Training_Plan_Section__c 
                                                                                      where redwing__Training_Plan__c IN :learningPlanIds.keySet()];
                    Set <Id> learningPlanSectionIds = (new Map<Id,redwing__Training_Plan_Section__c>(learningPlanSections)).keySet();
                    
                    // Map Learning Plan Section to Learning Plan 
                    Map <Id, Id> learningPlanSectionMap = new Map<Id, Id>();
                    for (redwing__Training_Plan_Section__c tps : learningPlanSections) {
                        learningPlanSectionMap.put(tps.Id, tps.redwing__Training_Plan__c);
                    }
                    
                    System.debug('learningPlanSectionMap='+learningPlanSectionMap);
                    
                    // Get List of Learning Plan Section Items with Learning Object of type ILT Event
                    // across all Learning Plan Sections in scope
                    List <redwing__Training_Plan_Section_Item__c> learningPlanSectionItems = [Select Id, redwing__Training_Plan_Section__c,
                                                                                              redwing__Learning__c from redwing__Training_Plan_Section_Item__c 
                                                                                              where redwing__Training_Plan_Section__c IN :learningPlanSectionIds AND redwing__Learning__r.recordtype.Name = 'ILT Event'];  
                    
                    // Map Learning Object with record type ILT Event to Learning Plan
                    Map <Id, Id> learningObjectMap = new Map<Id, Id>();
                    for (redwing__Training_Plan_Section_Item__c tpsi : learningPlanSectionItems) {
                        learningObjectMap.put(tpsi.redwing__Learning__c, learningPlanSectionMap.get(tpsi.redwing__Training_Plan_Section__c));
                    }
                    
                    System.debug('learningObjectMap='+learningObjectMap);
                    
                    // Get ILT Event object for each Learning Object in scope
                    List <redwing__ILT_Event__c> ILTEventForJob = [Select Id, redwing__Learning__c from redwing__ILT_Event__c 
                                                                   where redwing__Learning__c IN :learningObjectMap.keySet()];
                    
                    // Map Course Catalog to ILT Event
                    Map <Id, Id> courseCatalogILTEvent = new Map<Id, Id>();
                    for (redwing__ILT_Event__c iltevent : ILTEventForJob) {
                        courseCatalogILTEvent.put(learningPlanIds.get(learningObjectMap.get(iltevent.redwing__Learning__c)), iltevent.Id); 
                    }
                    
                    // Create Map of Job Id to ILT Event
                    for (Id theJobId : jobCatalogMap.keySet()) {
                        jobLearningMap.put(theJobId, courseCatalogILTEvent.get(jobCatalogMap.get(theJobId)));
                    }
                    
                    System.debug('jobLearningMap='+jobLearningMap);
                }    
               
                //Usage Help:
                
                // learningPlanSectionIds  - List of learningplansection Id which has ILTEvent record type
                // learningPlanSectionMap  - Map of learningplansectionId along with their learning plan 
                // learningObjectMap - Map of learning record along with learning plan       
                // ILTEventForJob - List of ILT Event record base on learning
                // courseCatalogILTEvent - Map of course catalog with ILTEvent record
                // jobLearningMap - Map of jobId with their ILTEvent record
                
                
            }  
        }
                
                
        return jobLearningMap;
    }
    
    public void upsertILTClass(List<sked__Job__c> newRecords, Map<Id, sked__Job__c> oldRecords) {
        Map<Id, Id> jobLearningMap = fetchJobLearningMap(newRecords);
        Map<Id, String> suppInfoMap = new Map<Id, String>();
        Map<Id, Id> MapScheduleToExistingClass = new Map<Id, Id>();
        Map<String,redwing__Learning_Version__c> lVersions = new Map<String,redwing__Learning_Version__c>();
        Map<Id,Id> insertedclassId = new Map<Id,Id>();
        Map<Id, Id> JobIdOppIdMap = new Map<Id, Id>();
        Map<Id, Id> orderIdJobIdMap = new Map<Id, Id>(); // key: order Id, value: skedulo Job Id
        Map<Id, Id> jobIdOrderIdMap = new Map<Id, Id>(); // key: skedulo Job Id , value: order Id
        Map<Id, Set<ccrz__E_OrderItem__c>> jobIdOrderItems = new Map<Id, Set<ccrz__E_OrderItem__c>>(); // skedulo job Id as key, Set of related order items as value

        List<redwing__Learning__c> lstLearning = new List<redwing__Learning__c>();
        List<redwing__Training_Activity__c> lstTrainingActivity = new List<redwing__Training_Activity__c>();
        List<redwing__ILT_Event_Class__c> lstEventClass = new List<redwing__ILT_Event_Class__c>();
        List<redwing__ILT_Class__c> lstILTClass = new List<redwing__ILT_Class__c>();
        List<redwing__ILT_Session__c> lstILTSession = new List<redwing__ILT_Session__c>();
        List<redwing__Learning__c> insertedLearnings = new List<redwing__Learning__c>();
        List<redwing__ILT_Class__c> updateclassrecList = new List<redwing__ILT_Class__c>();
        List<ccrz__E_OrderItem__c> lstOrderItems = new List<ccrz__E_OrderItem__c>(); // List to be populated with order items after ILT class is added
        List<ccrz__E_Order__c> lstOrders = new List<ccrz__E_Order__c>(); // List to be populated with CRE Request Processed flag
        List<ccrz__E_OrderItem__c> orderItems = new List<ccrz__E_OrderItem__c>();
        List<Voucher__c> voucherList = new List<Voucher__c>();

        Set<Id> SetJob = new Set<Id>();
        Set<Id> SetTrainingEvents = new Set<Id>();
        Set<Id> SetDeleteILTInstructor = new Set<Id>();
        Set<Id> SetSchedule = new Set<Id>();
        Set<Id> orderIdSet = new Set<Id>();
        Set<redwing__ILT_Instructor__c> SetILTInstructor = new Set<redwing__ILT_Instructor__c>();

        Boolean jobst = false; // No longer used
        Boolean recurringJob = false;
        Boolean classExists = false;

        for(sked__Job__c curJobRecord : newRecords){
            SetJob.add(curJobRecord.Id);            
            if (curJobRecord.sked__Recurring_Schedule__c != null) SetSchedule.add(curJobRecord.sked__Recurring_Schedule__c);
            if (curJobRecord.Training_Event__c != null)  SetTrainingEvents.add(curJobRecord.Training_Event__c);     
        }
        System.debug('Jobs retrieved in this schedule ' +SetJob);
        System.debug('$$$$'+SetSchedule);

        // Determine if ILT Class currently exists for the job (typical for an updated Skedulo job
        // to result in creation of new ILT Class record since when they are created the location may not be confirmed)

        if (updateRecords){
            for(redwing__ILT_Class__c theClass : [Select Id, Skedulo_Job_Id__c, redwing__Max_Seats__c from redwing__ILT_Class__c where Skedulo_Job_Id__c IN: SetJob]) {
                jobToClassMap.put(theClass.Skedulo_Job_Id__c, theClass);
            }
        }

        // Build Set of recurring schedule Ids that have outstanding ILT Classes
        // There should only be one ILT Class per recurring schedule
        // If the job being processed has the same recurring schedule as an existing ILT Class then 
        // process session only (skip ILT class, LActvity, LObject, and LVersion creation)
        if (SetSchedule.size() > 0) {
            For (redwing__ILT_Class__c theILTClass : [Select Id, Skedulo_Job_Id__c, Skedulo_Job_Id__r.sked__Recurring_Schedule__c From redwing__ILT_Class__c Where Skedulo_Job_Id__r.sked__Recurring_Schedule__c In :SetSchedule]) {
                MapScheduleToExistingClass.put(theILTClass.Skedulo_Job_Id__r.sked__Recurring_Schedule__c, theILTClass.Skedulo_Job_Id__c);
            }
        }

        jobPriceOverrIdeMap = checkGeographicSpecificPricing(newRecords, locationToILTLocationZip);
                     
        // Get value from training event to populate Supplement
        if (SetTrainingEvents.size() > 0) {
            List<Training_Events__c> trainingEvents = [Select Id, Supp_Info__c from Training_Events__c Where Id In :SetTrainingEvents];
            for (Training_Events__c theTrainingEvent : trainingEvents) {
                if (String.isNotBlank(theTrainingEvent.Supp_Info__c)) suppInfoMap.put(theTrainingEvent.Id, theTrainingEvent.Supp_Info__c);
            }
        }

        // **** logic to populate Opp Id on Full Service class
        // query opportunity IDs, Map - dependency Map between job and opp Id

        Map<Id, sked__Job__c> skedJobsMap = new Map<Id, sked__Job__c>([SELECT Id, Training_Event__r.Opportunity__c, Training_Event__r.CC_Order__c FROM sked__Job__c WHERE Id IN:SetJob]);

        // *** get order items to populate them with ILT class Id.

        for (Id Id : skedJobsMap.keySet()) {
            Id orderId = skedJobsMap.get(Id).Training_Event__r.CC_Order__c;
            orderIdJobIdMap.put(orderId, Id);
            jobIdOrderIdMap.put(Id, orderId);
            orderIdSet.add(orderId);
        }

        orderItems = [SELECT Id, ILT_Class__c, ccrz__Order__c FROM ccrz__E_OrderItem__c WHERE ccrz__Order__c IN :orderIdSet];

        for (ccrz__E_OrderItem__c item : orderItems) {
            Id skeduloJobId = orderIdJobIdMap.get(item.ccrz__Order__c);

            if (skeduloJobId != null) {
                if (jobIdOrderItems.keySet().contains(skeduloJobId)) {
                    // if the skedulo job exists as key already, add the order item to existing Set
                    Set<ccrz__E_OrderItem__c> orderItemSet = jobIdOrderItems.get(skeduloJobId);
                    orderItemSet.add(item);
                    jobIdOrderItems.put(skeduloJobId, orderItemSet);
                } else {
                    // if the skedulo job does not exist as key, create Set and add to the Map
                    Set<ccrz__E_OrderItem__c> orderItemSet = new Set<ccrz__E_OrderItem__c>{item};
                    jobIdOrderItems.put(skeduloJobId, orderItemSet);
                }
            }
        }
        // ****

        // **************************************************************************************************************   
        // Main loop of method - iterate across all incoming jobs
        // **************************************************************************************************************

        for(sked__Job__c curJobRecord : newRecords) {
            sked__Job__c oldJobRecord = oldRecords.get(curJobRecord.Id);

            // Determine if this is an updated job record for which an ILT class record does not already exist
            // If so, treat as an insert not an update

            if (jobToClassMap.containsKey(curJobRecord.Id)) {
                classExists = true;
            } else {
                classExists = false;
            }

            // Determine if there is an existing class with this recurring schedule Id - if so do not create or modify ILT Class record
            if (curJobRecord.sked__Recurring_Schedule__c != null && MapScheduleToExistingClass.containsKey(curJobRecord.sked__Recurring_Schedule__c)) {
                if (MapScheduleToExistingClass.get(curJobRecord.sked__Recurring_Schedule__c) != curJobRecord.Id) {
                    recurringJob = true; 
                } else recurringJob = false;
            } else recurringJob = false;

            // Validate data synchronization between Skedulo, Cloud Craze, and Appinium
            // Stacked Class
            if (curJobRecord.Is_Stacked_Class__c==true){
                // ValIdation 1 - If no Skedulo Course Catalog Id is available, skip this job               
                if (curJobRecord.Course_Code__c == null || CCwithIds.get(curJobRecord.Course_Code__c) == null) continue;
                // ValIdation 2 - If no Cloud Craze product record is Mapped to the Skedulo Course Catalog, then skip this job              
                if (catalogIds.get(CCwithIds.get(curJobRecord.Course_Code__c)) == null) continue;
                // ValIdation 3 - If no Appinium Learning Plan is Mapped to the Cloud Craze product record, then skip this job              
                if (learningplancc.get(CCwithIds.get(curJobRecord.Course_Code__c)) == null) continue;   
            } else {
            // Non-stacked (regular delivery) class
                // ValIdation 1 - If no Skedulo Course Catalog Id is available, skip this job               
                if (curJobRecord.Course_Catalog__c == null) continue;
                // ValIdation 2 - If no Cloud Craze product record is Mapped to the Skedulo Course Catalog, then skip this job
                if (catalogIds.get(curJobRecord.Course_Catalog__c) == null) continue;                       
                // ValIdation 3 - If no Appinium Learning Plan is Mapped to the Cloud Craze product record, then skip this job              
                if (learningplancc.get(curJobRecord.Course_Catalog__c) == null) continue;           
            }

            // Insure that a valid ILT Event record exists for the Course Catalog defined in the Job record
            if(jobLearningMap.containsKey(curJobRecord.Id)) {
                String formattedEndTimeHHMM = '';
                String formattedStartTimeHHMM = '';
                
                // Determine time zone from Skedulo job record
                System.debug('Job timezone:'+curJobRecord.sked__Timezone__c);
                System.debug('Salesforce timezone:'+timeZoneMap.get(curJobRecord.sked__Timezone__c));

                if (curJobRecord.sked__TimeZone__c != null) {
                    String timeZoneName = timeZoneMap.get(curJobRecord.sked__TimeZone__c); 
                    System.debug('timezone Map and name' +timeZoneName);
                    if (timeZoneName != null) {  
                        formattedStartTimeHHMM = curJobRecord.sked__Start__c.format('HH:mm', timeZoneName);    
                        formattedEndTimeHHMM = curJobRecord.sked__Finish__c.format('HH:mm', timeZoneName);  
                        System.debug('formattedStartTimeHHMM'+formattedStartTimeHHMM); 
                    } 
                }                       

                // Process ILT Class logic ONLY if this is a new job (insert), an updated job for which an ILT Class does not yet exist,
                // an update for the first class in a recurring job,
                // or an update with at least one field change that impacts the ILT Class record

                if(!recurringJob) {
                    // **************************************************************************************************************                   
                    // Step 1 - Create ILT Class record for this Skedulo Job (may exist from previous requests)
                    // Note: The Skedulo Job Id binds the ILT Class, Session, Learning Object, and EventClass records together      
                    // **************************************************************************************************************  
                    
                    System.debug('updateRecords++++++++++++' +updateRecords );
                    System.debug('sked start++++++++++++' +curJobRecord.sked__Start__c);
                    
                    System.debug('Inside class creation');
                    Redwing__ILT_Class__c clsRecord = new Redwing__ILT_Class__c();
                    clsRecord.Skedulo_Account__c = curJobRecord.sked__Account__c;
                    clsRecord.redwing__Description__c = curJobRecord.sked__Description__c;      
                    clsRecord.Request_Type__c = curJobRecord.sked__Type__c;  
                    clsRecord.Ready_to_Publish__c = curJobRecord.Ready_to_Publish__c;
                    clsRecord.redwing__Location__c = (!locationToILTLocationMap.IsEmpty() && locationToILTLocationMap.containsKey(curJobRecord.sked__Location__c)) ? locationToILTLocationMap.get(curJobRecord.sked__Location__c) : null; // added as per DE1443

                    clsRecord.Class_Online__c = true;
                    clsRecord.Course_Class_Type__c = curJobRecord.Course_Class_Type__c;

                    if (curJobRecord.sked__Type__c == 'Full Service') {
                        if (skedJobsMap.get(curJobRecord.Id) != null && skedJobsMap.get(curJobRecord.Id).Training_Event__c != null) {
                            clsRecord.Opportunity__c = skedJobsMap.get(curJobRecord.Id).Training_Event__r.Opportunity__c;
                        }
                    } else clsRecord.Opportunity__c = null;

                    Integer nTotalStudents = 0;
                    String instructorStudentRatio = '';

                    if(curJobRecord.Is_Stacked_Class__c==true) {
                        if (catalogIds.get(CCwithIds.get(curJobRecord.Course_Code__c)) != Null) {                   
                            instructorStudentRatio = catalogIds.get(CCwithIds.get(curJobRecord.Course_Code__c)).Course_Catalog__r.Ratio_to_Instructor__c;
                        }
                    } else {
                        if (catalogIds.get(curJobRecord.Course_Catalog__c) != Null) {
                            instructorStudentRatio = catalogIds.get(curJobRecord.Course_Catalog__c).Course_Catalog__r.Ratio_to_Instructor__c;                       
                        }
                    }
                    
                    // Default instructor:student ratio to 1:12 
                    if (String.isBlank(instructorStudentRatio)) {
                        instructorStudentRatio = '1:12';   
                    }
                                    
                    if (instructorStudentRatio != null) {
                        String[] ratio = instructorStudentRatio.split(':');
                        if (ratio.size() == 2 && ratio[0] != null && ratio[1] != null) {
                            Integer nInstructor = Integer.valueOf(ratio[0]);
                            Integer nStudent = Integer.valueOf(ratio[1]);

                            if (nInstructor != null && nStudent != null && nInstructor != 0) {
                                Id jobAllocationId;
                                if (curJobRecord.Is_Stacked_Class__c == true && curJobRecord.Is_Master_Class__c == false
                                        && curJobRecord.sked__Parent__c != null) {
                                    jobAllocationId = curJobRecord.sked__Parent__c;
                                } else {
                                    jobAllocationId = curJobRecord.Id;
                                }

                                Set<Id> nAllocations = jobAllocationMap.get(jobAllocationId);
                                Integer nAllocatedInstructors;
                                // Default to one instructor if none have been allocated yet
                                if (nAllocations == null || nAllocations.size() == 0) {
                                    nAllocatedInstructors = 1;
                                } else {
                                    nAllocatedInstructors = nAllocations.size();
                                }

                                nTotalStudents = Integer.valueOf(Math.ceil((nStudent/nInstructor) * nAllocatedInstructors));
                            }
                        } else {
                            nTotalStudents = 12;
                        }
                    }                        

                    if(curJobRecord.Is_Stacked_Class__c==true) {
                        System.debug('*** Creating stacked class for job:'+curJobRecord.name);
                        System.debug('*** Course code:'+curJobRecord.Course_Code__c);                       
                        System.debug('*** Skedulo course catalog Id:'+CCwithIds.get(curJobRecord.Course_Code__c));                      
                        clsRecord.Is_Stacked_Class__c = curJobRecord.Is_Stacked_Class__c;
                        clsRecord.Learning_Plan__c =  learningplancc.get(CCwithIds.get(curJobRecord.Course_Code__c));
                        System.debug('*** Learning plan:'+clsRecord.Learning_Plan__c);
                        clsRecord.Classroom_Setting__c = learningPlancs.get(CCwithIds.get(curJobRecord.Course_Code__c));
                        System.debug('*** Cloud Craze Product:'+catalogIds.get(CCwithIds.get(curJobRecord.Course_Code__c)));
                        
                        if(catalogIds!=null && catalogIds.get(CCwithIds.get(curJobRecord.Course_Code__c))!=null){
                            clsRecord.Cloud_Craze_Product__c = catalogIds.get(CCwithIds.get(curJobRecord.Course_Code__c)).Id;                                                   
                            //clsRecord.redwing__Max_Seats__c = catalogIds.get(CCwithIds.get(curJobRecord.Course_Code__c)).Course_Catalog__r.Number_of_Students__c; 
                            //clsRecord.Available_Seats__c = catalogIds.get(CCwithIds.get(curJobRecord.Course_Code__c)).Course_Catalog__r.Number_of_Students__c;
                            clsRecord.redwing__Max_Seats__c = nTotalStudents;
                            clsRecord.Available_Seats__c = nTotalStudents;
                        }
                        
                        clsRecord.Is_Master_Class__c = curJobRecord.Is_Master_Class__c;
                        if (curJobRecord.Is_Master_Class__c != true) {
                            if (curJobRecord.sked__Parent__c != null) {
                                clsRecord.Skedulo_Parent_Job__c = curJobRecord.sked__Parent__c;
                            }
                        } else {
                            // If this is the Master Class of a Stacked Class then Set Parent Job equal to self
                            clsRecord.Skedulo_Parent_Job__c = curJobRecord.Id;
                        }                        
                    }
                    else
                    {
                        System.debug('*** Creating non-stacked (normal delivery) class for job:'+curJobRecord.name);                        
                        clsRecord.Learning_Plan__c = learningplancc.get(curJobRecord.Course_Catalog__c);
                        //clsRecord.Classroom_Setting__c = learningPlancs.get(curJobRecord.Course_Catalog__c);
                        if(!learningPlancDate.IsEmpty() && !learningPlancs.IsEmpty()&& learningPlancDate.containsKey(curJobRecord.Course_Catalog__c) && learningPlancs.containsKey(curJobRecord.Course_Catalog__c)){
                            //Date createdDate = date.newinstance(learningPlancDate.get(curJobRecord.Course_Catalog__c).year(), learningPlancDate.get(curJobRecord.Course_Catalog__c).month(), learningPlancDate.get(curJobRecord.Course_Catalog__c).day());
                            //Date enddateDate = date.newinstance(learningPlancs.get(curJobRecord.Course_Catalog__c).year(), learningPlancs.get(curJobRecord.Course_Catalog__c).month(), learningPlancs.get(curJobRecord.Course_Catalog__c).day());
                            //clsRecord.Class_Online_From__c = learningPlancDate.get(curJobRecord.Course_Catalog__c).date();
                            clsRecord.Classroom_Setting__c = learningPlancs.get(curJobRecord.Course_Catalog__c);
                            if (catalogIds!=null && catalogIds.get(curJobRecord.Course_Catalog__c)!=null) {
                                clsRecord.Cloud_Craze_Product__c= catalogIds.get(curJobRecord.Course_Catalog__c).Id;
                                //clsRecord.redwing__Max_Seats__c = catalogIds.get(curJobRecord.Course_Catalog__c).Course_Catalog__r.Number_of_Students__c;
                                //clsRecord.Available_Seats__c = catalogIds.get(curJobRecord.Course_Catalog__c).Course_Catalog__r.Number_of_Students__c;
                                clsRecord.redwing__Max_Seats__c = nTotalStudents;
                                clsRecord.Available_Seats__c = nTotalStudents;
                            }
                        }
                    }
                    
                    if (curJobRecord.sked__TimeZone__c != null) {
                        clsRecord.redwing__Timezone__c  = timeZoneMap.get(curJobRecord.sked__TimeZone__c); 
                    }
                    clsRecord.Class_Searchable__c = true;
                    clsRecord.Class_Searchable_If_Unavailable__c = false;
                    clsRecord.Supplemental_Information__c = (suppInfoMap.containsKey(clsRecord.Skedulo_Training_Event__c)) ? suppInfoMap.get(clsRecord.Skedulo_Training_Event__c) : '';

                    if(curJobRecord.sked__Start__c != null){
                        System.debug('formattedStartTimeHHMM insIde class'+formattedStartTimeHHMM); 
                        clsRecord.redwing__Start_Time__c = formattedStartTimeHHMM;
                        
                    } else clsRecord.redwing__Start_Time__c = '';  
                    
                    if(curJobRecord.sked__Finish__c != null){
                        clsRecord.redwing__End_Time__c = formattedEndTimeHHMM;
                    } else clsRecord.redwing__End_Time__c = '';  
                    
                    // *****
                    // US1356 - Determine if class-specific (geography-specific) pricing is defined for this job
                    // Price overrIdes are applicable only to community classes (ignored for Full Service jobs)
                    // *****
                    System.debug('Inspecting price overrIde');
                    
                    if (jobPriceOverrIdeMap.get(curJobRecord.Id) != null && curJobRecord.sked__Type__c == 'Community') {
                        System.debug('OverrIde='+jobPriceOverrIdeMap.get(curJobRecord.Id));                 
                        clsRecord.Price_OverrIde__c = jobPriceOverrIdeMap.get(curJobRecord.Id);
                    } 
                                    
                    clsRecord.redwing__End_Date__c = (curJobRecord.sked__Finish__c != null) ?  
                        date.newinstance(curJobRecord.sked__Finish__c.year(),curJobRecord.sked__Finish__c.month(),curJobRecord.sked__Finish__c.day()) : Date.Today();              
                    clsRecord.redwing__Start_Date__c = (curJobRecord.sked__Start__c != null) ? 
                        date.newinstance(curJobRecord.sked__Start__c.year(),curJobRecord.sked__Start__c.month(),curJobRecord.sked__Start__c.day()) : Date.Today();
                    clsRecord.Skedulo_Training_Event__c = curJobRecord.Training_Event__c;
                    
                    clsRecord.Skedulo_Job_Id__c = curJobRecord.Id; 
                    clsRecord.Skedulo_Job_Id_External__c = curJobRecord.Id;
                    clsRecord.Skedulo_Job_Number__c = curJobRecord.Name;
                    
                    clsRecord.Name = (curJobRecord.Is_Stacked_Class__c==true) ? 
                        learningPlanName.get(CCwithIds.get(curJobRecord.Course_Code__c)) : learningPlanName.get(curJobRecord.Course_Catalog__c);
                    System.debug('++++Learning Plan Name='+clsRecord.Name);
                    
                    clsRecord.Skedulo_Job_Active__c = True;
                    clsRecord.Skedulo_Job_Status__c = curJobRecord.sked__Job_Status__c;
                    
                    // Associate to Learning Object with same external Id
                    if (!updateRecords || !classExists) {
                        clsRecord.redwing__Learning__r = new redwing__Learning__c(Skedulo_Job_Id_External__c = curJobRecord.Id);
                    }
                    
                    // Add new class to schedule->class Map to insure additional jobs processed in this batch do not create dup class records
                    if ((!updateRecords || !classExists) && curJobRecord.sked__Recurring_Schedule__c != null) {
                        MapScheduleToExistingClass.put(curJobRecord.sked__Recurring_Schedule__c, curJobRecord.Id);
                    }   
                    lstILTClass.add(clsRecord);
                }
                System.debug('lstILTClass records' +lstILTClass);

                // **************************************************************************************************************                  
                // Housekeeping - Obtain the class job Id value to be used to associate records across all related objects
                // Recurring jobs need to cross-reference the existing class job Id stored in MapScheduleToExistingClass (if present)
                // (Used to define lookup value for ILT Class in records below)
                // **************************************************************************************************************  
                                
                Id jobRecordId = curJobRecord.Id;
                if (recurringJob) {
                    if (MapScheduleToExistingClass.containsKey(curJobRecord.sked__Recurring_Schedule__c)) {
                        jobRecordId = MapScheduleToExistingClass.get(curJobRecord.sked__Recurring_Schedule__c);  
                    }                                   
                }

                // **************************************************************************************************************
                // Step 2 - Create ILT Session record for this Skedulo Job (OK for recurring job - needs session)
                // **************************************************************************************************************  

                if (!updateRecords || !classExists || checkSessionJobFields(curJobRecord, oldJobRecord)) {
                    redwing__ILT_Session__c sessionRecord = new redwing__ILT_Session__c();

                    sessionRecord.redwing__Date__c = (curJobRecord.sked__Start__c != null) ? curJobRecord.sked__Start__c.date() : null;

                    // Adjust parent class start/end dates for this new/updated session
                    if (recurringJob && sessionRecord.redwing__Date__c != null) {
                        if (lstILTClass.size() > 0) {
                            for (Integer listIndex=0; listIndex < lstILTClass.size(); listIndex++) {
                                redwing__ILT_Class__c theClass = lstILTClass.get(listIndex);
                                if (theClass.Skedulo_Job_Id__c == jobRecordId) {
                                    if (sessionRecord.redwing__Date__c < theClass.redwing__Start_Date__c) {
                                        theClass.redwing__Start_Date__c = sessionRecord.redwing__Date__c;
                                    } else if (sessionRecord.redwing__Date__c > theClass.redwing__End_Date__c) {
                                        theClass.redwing__End_Date__c = sessionRecord.redwing__Date__c;
                                    }
                                    lstILTClass.set(listIndex, theClass);
                                    break;
                                }
                            }
                        }
                    }
                    System.debug('Inside session creation');
                    if (curJobRecord.sked__Start__c != null) {
                        sessionRecord.redwing__Start_Time__c = formattedStartTimeHHMM;
                    } else sessionRecord.redwing__Start_Time__c = '';

                    if (curJobRecord.sked__Finish__c != null) {
                        sessionRecord.redwing__End_Time__c = formattedEndTimeHHMM;
                    } else sessionRecord.redwing__End_Time__c = '';

                    if (curJobRecord != null && curJobRecord.Name != null) {
                        // Insure that datetime is not converted to UTC
                        Integer clsday = sessionRecord.redwing__Date__c.day();
                        Integer clsmonth = sessionRecord.redwing__Date__c.month();
                        Integer clsyear = sessionRecord.redwing__Date__c.year();
                        Datetime sessionDatetime = Datetime.newInstance(clsyear, clsmonth, clsday, 12, 00, 00);

                        Integer namePrefixLength = Math.min(curJobRecord.Name.length(), 40);
                        sessionRecord.Name = curJobRecord.Name.substring(0, namePrefixLength) + ' ' + sessionDatetime.format('MM/dd/yyyy');
                        // sessionRecord.Name = curJobRecord.Name;
                    }

                    sessionRecord.Skedulo_Account__c = curJobRecord.sked__Account__c;
                    sessionRecord.redwing__Description__c = curJobRecord.sked__Description__c;
                    if (curJobRecord.sked__Location__c != null) {
                        sessionRecord.redwing__Location__c = (!locationToILTLocationMap.IsEmpty() && locationToILTLocationMap.containsKey(curJobRecord.sked__Location__c)) ? locationToILTLocationMap.get(curJobRecord.sked__Location__c) : null;
                    } else sessionRecord.redwing__Location__c = null;
                    sessionRecord.Skedulo_Special_Instructions__c = curJobRecord.Special_Instructions__c;
                    // Note the used of the actual job record Id here, not the class job record Id for recurring schedules
                    // Session records are unique for each job record, including those defined for recurring schedules
                    sessionRecord.Skedulo_Job_Id__c = curJobRecord.Id;
                    sessionRecord.Skedulo_Job_Id_External__c = curJobRecord.Id;
                    sessionRecord.Skedulo_Job_Active__c = True;
                    sessionRecord.Skedulo_Address__c = curJobRecord.sked__Address__c;

                    // Associate to ILT Class with same external Id
                    if (!updateRecords || !classExists) {
                        sessionRecord.redwing__ILT_Class__r = new redwing__ILT_Class__c(Skedulo_Job_Id_External__c = jobRecordId);
                    }
                    lstILTSession.add(sessionRecord);
                }
                System.debug('lstILTSession records' +lstILTSession);
                if (!recurringJob && (!updateRecords || !classExists)) {
                    // **************************************************************************************************************   
                    // Step 3 - Create Learning Object for this ILT Class
                    // **************************************************************************************************************   
                    
                    redwing__Learning__c theLearningObject = new redwing__Learning__c();
                    theLearningObject.RecordTypeId = Schema.SObjectType.redwing__Learning__c.getRecordTypeInfosByName().get('ILT Class').getRecordTypeId();
                    theLearningObject.Name = curJobRecord.Name;
                    theLearningObject.Skedulo_Job_Id_External__c = curJobRecord.Id;            
                    
                    lstLearning.add(theLearningObject);

                    // **************************************************************************************************************                   
                    // Step 4 - Create Junction object record that binds the Learning Object to the course ILT Event
                    // **************************************************************************************************************
                                        
                    redwing__ILT_Event_Class__c theEventClass = new redwing__ILT_Event_Class__C();
                    theEventClass.Skedulo_Job_Id_External__c = curJobRecord.Id;            
                    theEventClass.redwing__ILT_Event__c = jobLearningMap.get(curJobRecord.Id);                                  
                    theEventClass.Skedulo_Job_Name__c = curJobRecord.Name;  
                                
                    // Associate to Learning Object with same external Id
                    theEventClass.redwing__Learning__r = new redwing__Learning__c(Skedulo_Job_Id_External__c = curJobRecord.Id);
                    
                    lstEventClass.add(theEventClass);
                    
                    // **************************************************************************************************************   
                    // Step 5 - Create Learning Activity for this ILT Class
                    // **************************************************************************************************************   
                    
                    redwing__Training_Activity__c theTrainingActivity = new redwing__Training_Activity__c();
                    theTrainingActivity.Skedulo_Job_Id_External__c = curJobRecord.Id;
                    theTrainingActivity.redwing__Learning_Name__c = curJobRecord.Name;

                    // Associate to Learning Object with same external Id
                    theTrainingActivity.redwing__Learning__r = new redwing__Learning__c(Skedulo_Job_Id_External__c = curJobRecord.Id);
                    
                    lstTrainingActivity.add(theTrainingActivity);                   
                }
                
                // **************************************************************************************************************                 
                // Step 6 - Create Junction object records that bind the ILT Class to the Instructor (enhanced to include instructor changes)
                // **************************************************************************************************************                 
                
                // Use job Id from parent (master) class if this is a dependent stacked class job being processed
                Id jobAllocationId = curJobRecord.Id;
                Id scheduleAllocationId;
                
                if (curJobRecord.Is_Stacked_Class__c == true && curJobRecord.Is_Master_Class__c == false 
                    && curJobRecord.sked__Parent__c != null) jobAllocationId = curJobRecord.sked__Parent__c;
    
                if (curJobRecord.sked__Recurring_Schedule__c != null)
                    scheduleAllocationId = curJobRecord.sked__Recurring_Schedule__c;
                                
                if ((String.isNotBlank(scheduleAllocationId) && scheduleAllocationMap.containsKey(scheduleAllocationId)) 
                    || (jobAllocationMap.containsKey(jobAllocationId))) {
                    Set<Id> jobResources;
                    if (String.isNotBlank(scheduleAllocationId)) {
                        jobResources = scheduleAllocationMap.get(scheduleAllocationId);
                    } else {
                        jobResources = jobAllocationMap.get(jobAllocationId);
                    }
                    System.debug('jobResources='+jobResources);
                    System.debug('scheduleAllocationId='+scheduleAllocationId);
                    System.debug('jobAllocationId='+jobAllocationId);                       
                    System.debug('scheduleAllocationMap='+scheduleAllocationMap);
                    System.debug('jobAllocationMap='+jobAllocationMap);                     

                    if (String.isNotBlank(scheduleAllocationId)) {
                        if (scheduleInstructorMap.containsKey(scheduleAllocationId)) {
                            for (redwing__ILT_Instructor__c theILTInstructor : scheduleInstructorMap.get(scheduleAllocationId)) {
                                if (!jobResources.contains(instructorResourceMap.get(theILTInstructor.redwing__Instructor__c))) {
                                    SetDeleteILTInstructor.add(theILTInstructor.Id);    
                                    System.debug('schedule-based SetDeleteILTInstructor:'+SetDeleteILTInstructor);
                                } 
                            }      
                        }               
                    } else {
                        if (jobInstructorMap.containsKey(jobAllocationId)) {
                            for (redwing__ILT_Instructor__c theILTInstructor : jobInstructorMap.get(jobAllocationId)) {
                                if (!jobResources.contains(instructorResourceMap.get(theILTInstructor.redwing__Instructor__c))) {
                                    SetDeleteILTInstructor.add(theILTInstructor.Id);    
                                    System.debug('job-based SetDeleteILTInstructor:'+SetDeleteILTInstructor);
                                } 
                            }
                        }
                    }

                    for (Id resourceId : jobResources) {
                        System.debug('Create ILT Instructor - Resource Id='+resourceId);
                        
                        //Should not allow to create iltinstructor if instructor for the current job is null
                        //Data for resource and instructor has to be same in both object but they are different - shoul make it same
                        if(!resourceToInstructorMap.IsEmpty() && resourceToInstructorMap.containsKey(resourceId)) {
                            redwing__ILT_Instructor__c theILTInstructor = new redwing__ILT_Instructor__c();
                            // Note: All instructors for all sessions are associated to the ILT Class record
                            // The extenal Id insures that if the same instructor is assigned to multiple session
                            // they are only associated once at the ILT Class level
                            theILTInstructor.Skedulo_Job_Id_External__c = jobRecordId+':'+resourceId;                 
                            theILTInstructor.redwing__Instructor__c = resourceToInstructorMap.get(resourceId);
                            System.debug('Creating ILTInstructor:'+theILTInstructor);
                            
                            //*****
                            // USxxxx - Instructors are always to be associated to the ILT Class
                            // in order to provide support for community pages (session-level assignments don't work)
                            // 
                            // Can only assign and Instructor to a Session **OR** a Class (not both)                            
                            //*****
                            theILTInstructor.redwing__ILT_Class__r = new redwing__ILT_Class__c(Skedulo_Job_Id_External__c = jobRecordId);

                            SetILTInstructor.add(theILTInstructor);
                        }
                    }    
                    System.debug('SetILTInstructor='+SetILTInstructor);
                }
            }            
        }
        
        if(lstLearning.size() > 0) {
            System.debug(' Learning record created');
            Schema.SObjectField f = redwing__Learning__c.Fields.Skedulo_Job_Id_External__c;
            Database.UpsertResult[] results = Database.upsert(lstLearning, f, false);
            System.debug('get learning Id '+results[0].getId());
        }   
        
        //Publishing Learning records
        if (lstLearning.size() > 0) {
            for(redwing__Learning__c l : lstLearning){
                redwing__Learning_Version__c lv = new redwing__Learning_Version__c();
                lv.redwing__Learning__c = l.Id;
                lv.redwing__Version__c = 1;
                lv.redwing__Type__c = 'Published';
                lv.redwing__Version_selection_behavior__c = null;

                // This code has no function - insertedclassId not even populated at this point
                /*
                if(insertedclassId.containskey(l.Id)){
                    lv.redwing__ILT__c = insertedclassId.get(l.Id);
                }
                else {
                    //TODO: Handle custom record types here
                }
                */
                
                lVersions.put(l.Id,lv);
            }
            
            if(lVersions.size() > 0){
                insert lVersions.values();
            }
            
            //Update header information
            for(redwing__Learning__c l : lstLearning){
                l.redwing__Current_Published_Version__c = lVersions.get(l.Id).Id;
                l.redwing__Published__c = true;
            }
            
            if(lstLearning.size() > 0){
                update lstLearning;
            }
        }        
                 
        if(lstILTClass.size() > 0) {
            Schema.SObjectField f = redwing__ILT_Class__c.Fields.Skedulo_Job_Id_External__c;
            database.UpsertResult[] results = Database.upsert(lstILTClass, f, false);
            System.debug('Class created results' + results);

            for (Integer nILTClass=0; nILTClass < results.size(); nILTClass++) {
                if (results[nILTClass].isSuccess()) {
                    redwing__ILT_Class__c clsRecord = lstILTClass[nILTClass];
                    newJobToClassMap.put(clsRecord.Skedulo_Job_Id__c, clsRecord);
                    // *** populate order items for FS class with the ILT class

                    // for every successful inserted class check if it is FS
                    // get Set of order items
                    // iterate through order items, populate ILT class, add to the order items List
                    // update order items

                    if (clsRecord.Request_Type__c == 'Full Service') {
                        Set<ccrz__E_OrderItem__c> orderItemSet = jobIdOrderItems.get(clsRecord.Skedulo_Job_Id__c);
                        if (!orderItemSet.isEmpty()) {
                            Id theOrderId;
                            for (ccrz__E_OrderItem__c oi : orderItemSet) {
                                if (oi.ILT_Class__c == null) {
                                    oi.ILT_Class__c = clsRecord.Id;
                                    lstOrderItems.add(oi);
                                }
                                theOrderId = oi.ccrz__Order__c;
                            }
                            ccrz__E_Order__c theOrder = new ccrz__E_Order__c();
                            theOrder.Id = theOrderId;
                            theOrder.CRE_Request_Processed__c = true;
                            lstOrders.add(theOrder);
                        }
                    }
                }
            }
        }
           
        // Voucher creation (newJobToClassMap now contains a mapping of Job Id to ILT Class for both new and existing classes)
        // We must iterate over old and new to determine if class size has changed based on job allocation or ratio change

        for (redwing__ILT_Class__c theClass :  newJobToClassMap.values()) {
            // Insure that the Learning Plan Id will be available if we need to create voucher, otherwise need to skip
            if (catalogIds.get(jobCatalogMap.get(theClass.Skedulo_Job_Id__c)) != null) {
                // For new ILT Class records use the previously calculated max seats(number of students) for voucher count
                // For updated (existing) ILT Class records determine if voucher count is still valid (max seats)
                Integer nTotalStudentsOld = 0;
                Integer nTotalStudents = Integer.valueOf(theClass.redwing__Max_Seats__c);

                if (jobToClassMap.containsKey(theClass.Skedulo_Job_Id__c)) {
                    nTotalStudentsOld = Integer.valueOf(jobToClassMap.get(theClass.Skedulo_Job_Id__c).redwing__Max_Seats__c);
                }

                System.debug('*** nTotalStudentsOld='+nTotalStudentsOld+' nTotalStudents='+nTotalStudents);
                if (nTotalStudents > nTotalStudentsOld) {
                    for (Integer i = 0; i < (nTotalStudents - nTotalStudentsOld); i++) {
                        Voucher__c objVoucher = new Voucher__c();
                        objVoucher.ILT_Class__c = theClass.Id;
                        objVoucher.Learning_Plan__c = catalogIds.get(jobCatalogMap.get(theClass.Skedulo_Job_Id__c)).LMS_Learning_Plan__c;
                        voucherList.add(objVoucher);
                    }
                }
                // What about reductions in max class size?  Are vouchers to be removed?
            }
        }
                    
        if(voucherList.size() > 0) {
            System.debug('voucherList='+voucherList);
            List<Database.SaveResult> sresult = Database.insert(voucherList, false);
        }

        if (lstOrders.size() > 0) {
            System.debug('lstOrders='+lstOrders);
            List<Database.SaveResult> sresult = Database.update(lstOrders, false);
        }

        if (lstOrderItems.size() > 0) {
            System.debug('lstOrderItems='+lstOrderItems);
            List<Database.SaveResult> sresult = Database.update(lstOrderItems, false);
        }

        if(lstILTSession.size() > 0) {
            System.debug('ListILTSession='+lstILTSession);
            Schema.SObjectField f = redwing__ILT_Session__c.Fields.Skedulo_Job_Id_External__c;        
            Database.UpsertResult[] results = Database.upsert(lstILTSession, f, false);
            System.debug('ListILTSession Upsert Results='+results);
        }    
        
        if(lstEventClass.size() > 0){
            System.debug(' Event Class record created');
            Schema.SObjectField f = redwing__ILT_Event_Class__c.Fields.Skedulo_Job_Id_External__c;
            Database.UpsertResult[] results = Database.upsert(lstEventClass, f, false);
            System.debug('get eventclass Id '+results[0].getId());            
        } 

        if(lstTrainingActivity.size() > 0){
            System.debug(' Learning Activity record created');
            Schema.SObjectField f = redwing__Training_Activity__c.Fields.Skedulo_Job_Id_External__c;
            Database.UpsertResult[] results = Database.upsert(lstTrainingActivity, f, false);
            System.debug('get learning activity Id '+results[0].getId());
        }  
                 
        if(SetILTInstructor.size() > 0) {
            System.debug('SetILTInstructor='+SetILTInstructor);  
            List<redwing__ILT_Instructor__c> lstILTInstructor = new List<redwing__ILT_Instructor__c>(SetILTInstructor);             
            //List<redwing__ILT_Instructor__c> updateclassList = new List<redwing__ILT_Instructor__c>();
            Schema.SObjectField f = redwing__ILT_Instructor__c.Fields.Skedulo_Job_Id_External__c;       
            Database.UpsertResult[] results = Database.upsert(lstILTInstructor, f, false);
            System.debug('Update ILTinstructor>>>>'+results);
            for(Integer index = 0, size = results.size(); index < size; index++) {
                if(results[index].isSuccess()) {
                    if(results[index].isCreated()) {
                        System.debug(lstILTInstructor[index].Skedulo_Job_Id_External__c +' was created');
                    } else {
                        System.debug(lstILTInstructor[index].Skedulo_Job_Id_External__c +' was updated');
                    }
                }
            } 
            
            /* This code block does not accomplish anything
            for(redwing__ILT_Instructor__c ril:lstILTInstructor)
            {
                System.debug('Value of ILTClassId outsIde>>>>'+ILTClassId);
                if(ILTClassId!=null && ril.redwing__ILT_Class__c==null)
                {
                    System.debug('Value of ILTClassId>>>>'+ILTClassId);
                    //ril.redwing__ILT_Class__c=ILTClassId;
                    System.debug('Instructors ILTClass>>>>'+ril.redwing__ILT_Class__c);
                    updateclassList.add(ril);
                }
            }
            if(updateclassList.size()>0)
            {   
                update updateclassList;
            }
            */
            
        }

        if(SetDeleteILTInstructor.size() > 0){
            System.debug('SetDeleteILTInstructor='+SetDeleteILTInstructor);  
            List<Id> lstDeleteILTInstructor = new List<Id>(SetDeleteILTInstructor);    
            Database.DeleteResult[] results = Database.delete(lstDeleteILTInstructor, false);
            System.debug('Delete ILTinstructor>>>>'+results);
            for(Integer index = 0, size = results.size(); index < size; index++) {
                if(results[index].isSuccess()) {
                    System.debug(lstDeleteILTInstructor[index] +' was deleted');
                }
            }             
        }          
    }
    
    public void cancelRelatedRecords(Map<Id, sked__Job__c> MapCanceledJobs) {
        
        // Implementing the Isactive and deletion Logic

        // DE1562 - Do not delete Roster records.  Learning Assignments must be retained,
        //          since these are M-D on Roster records.
        /*
        Set<Id> rosterclass = new Set<Id>();
        List<redwing__Learning_Assignment__c> lstAssignment = new List<redwing__Learning_Assignment__c>();
        for(redwing__ILT_Roster__c roster : [Select Id, redwing__ILT_Class__c, redwing__Learning_Assignment__c, redwing__ILT_Class__r.Skedulo_Job_Id_External__c from redwing__ILT_Roster__c where redwing__ILT_Class__r.Skedulo_Job_Id_External__c IN: MapCanceledJobs.keySet()]){
            rosterclass.add(roster.redwing__ILT_Class__r.Skedulo_Job_Id_External__c);
            lstAssignment.add(new redwing__Learning_Assignment__c(Id=roster.redwing__Learning_Assignment__c));
            
        }
        
        if(lstAssignment.size() > 0)
            delete lstAssignment;
        */

        List<redwing__ILT_Session__c> updSessionRecords = new List<redwing__ILT_Session__c>();
        //Update Session with job Active field if students are registered
        for(redwing__ILT_Session__c sesRec : [Select Id, Skedulo_Job_Status__c, Skedulo_Job_Id_External__c, Skedulo_Job_Active__c
            From redwing__ILT_Session__c Where Skedulo_Job_Id_External__c IN: MapCanceledJobs.keySet()]){
            sesRec.Skedulo_Job_Active__c = false;
            sesRec.Skedulo_Job_Status__c = 'Cancelled';
            updSessionRecords.add(sesRec); 
        }
        if(updSessionRecords.size() > 0){
            update updSessionRecords;
        }
        
        Set<Id> SetIds = new Set<Id>();
        Set<Id> SetjobIds = new Set<Id>();
        for(sked__Job__c job : MapCanceledJobs.values()){
            if(job.sked__Recurring_Schedule__c != null){
                SetIds.add(job.sked__Recurring_Schedule__c);
            }
            else {
                SetJobIds.add(job.Id);             
            }
        }
        
        Set<Id> clsRecIds = new Set<Id>();        

        if(!SetIds.isEmpty()){
            //Update class with job Active field if students are registered
            for(redwing__ILT_Class__c clsRec : [Select Id, Skedulo_Job_Status__c, (select Id, Skedulo_Job_Active__c, Skedulo_Job_Id_External__c , Skedulo_Job_Status__c from redwing__ILT_Sessions__r where Skedulo_Job_Active__c = true), Skedulo_Job_Id_External__c, Skedulo_Job_Active__c from redwing__ILT_Class__c where Skedulo_Job_Id__r.sked__Recurring_Schedule__c IN: SetIds]){
                if(clsRec.redwing__ILT_Sessions__r.isEmpty()){
                    clsRecIds.add(clsRec.Id);
                }
            }
        }
        if(!SetJobIds.isEmpty()){
            for(redwing__ILT_Class__c clsRec : [Select Id, Skedulo_Job_Status__c, Skedulo_Job_Id_External__c, Skedulo_Job_Active__c from redwing__ILT_Class__c where Skedulo_Job_Id_External__c IN: SetJobIds]){        
                clsRecIds.add(clsRec.Id);
            }
        }
        if(!clsRecIds.isEmpty()){
            updateClass(clsRecIds);
        }
        System.debug('clsRecIds='+clsRecIds);

        // *** US1517 - Deactivate all remaining (unused) vouchers for this class
        // *** US1562 - Deactivate all remaining (unused) vouchers (status = 'Void')
        // *** US1562 - Change status of assigned vouchers (status = 'Pending Cancellation')
        // *** US1562 - Change status of outstanding rosters (status = 'Cancelled')

        // Generate List of both claimed and unused vouchers for this class
        String claimedStatuses = 'Reserved, Claimed';
        //List<String> ClaimedStatuses = System.label.ClaimedVoucherTypes.split(';');

        List<Voucher__c> lstVouchersToUpdate = new List<Voucher__c>();
        List<redwing__ILT_Roster__c> lstRostersToUpdate = new List<redwing__ILT_Roster__c>();
        List<redwing__Learning_Assignment__c> lstLearningAssignmentsToUpdate = new List<redwing__Learning_Assignment__c>();

        Set<Id> lstRosterUsers = new Set<Id>();
        Set<Id> lstRosterLearningAssignments = new Set<Id>();

        String cancelReason = 'Course Cancelled';

        if (clsRecIds.size() > 0) {
            List<Voucher__c> classVouchers = [Select Id, Name, Status__c From Voucher__c
            Where ILT_Class__c In :clsRecIds];
            //  And Status__c Not In :ClaimedStatuses];

            List<redwing__ILT_Roster__c> classRosters = [Select Id, redwing__User__c, redwing__ILT_Class__r.Learning_Plan__c, redwing__ILT_Class__c, redwing__Learning_Assignment__c
            From redwing__ILT_Roster__c Where redwing__ILT_Class__c In :clsRecIds];

            // Update impacted Vouchers - status 'Pending Cancellation' or 'Void' as appropriate

            for (Voucher__c theVoucher : classVouchers) {
                voucher__c theUpdatedVoucher = new voucher__c();
                theUpdatedVoucher.Id = theVoucher.Id;
                if (claimedStatuses.contains(theVoucher.Status__c)) {
                    theUpdatedVoucher.Status__c = 'Pending Cancellation';
                } else {
                    theUpdatedVoucher.Status__c = 'Void';
                    // theUpdatedVoucher.Status__c = 'Blocked';
                }
                lstVouchersToUpdate.add(theUpdatedVoucher);
            }

            if (lstVouchersToUpdate.size() > 0) {
                update lstVouchersToUpdate;
            }

            // Update impacted Rosters - status 'Cancelled' , Cancellation Date and Reason

            for (redwing__ILT_Roster__c theRoster : classRosters) {
                redwing__ILT_Roster__c theUpdatedRoster = new redwing__ILT_Roster__c();
                theUpdatedRoster.Id = theRoster.Id;
                theUpdatedRoster.redwing__Status__c = 'Cancelled';
                theUpdatedRoster.Cancellation_Date__c = System.today();
                theUpdatedRoster.Cancellation_Reason__c = cancelReason;

                lstRostersToUpdate.add(theUpdatedRoster);
                lstRosterLearningAssignments.add(theRoster.redwing__Learning_Assignment__c);
                lstRosterUsers.add(theRoster.redwing__User__c);
            }

            if (lstRostersToUpdate.size() > 0) {
                update lstRostersToUpdate;

                if (String.isNotBlank(classRosters[0].redwing__ILT_Class__r.Learning_Plan__c)) {
                    // Get Learning Plan Assignments for Rosters
                    List<redwing__Training_Plan_Assignment__c> lstRosterLearningPlanAssignments = [
                            Select Id, redwing__User__c
                            From redwing__Training_Plan_Assignment__c
                            Where redwing__User__c In :lstRosterUsers And redwing__Training_Plan__c = :classRosters[0].redwing__ILT_Class__r.Learning_Plan__c
                    ];

                    // Get Learning Plan Achievements for Rosters
                    List<redwing__Training_Plan_Achievement__c> lstLearningPlanAchievements = [
                            Select Id, redwing__Training_Plan__c
                            From redwing__Training_Plan_Achievement__c
                            Where redwing__Training_Plan__c = :classRosters[0].redwing__ILT_Class__r.Learning_Plan__c
                    ];

                    // Get Achievement assignments for Rosters
                    List<redwing__Achievement_Assignment__c> lstRosterAchievementAssignments = [
                            Select Id, redwing__User__c
                            From redwing__Achievement_Assignment__c
                            Where redwing__User__c In :lstRosterUsers And redwing__Status__c Not In ('Acquired', 'Expired')
                            And redwing__Training_Plan_Achievement__c IN :lstLearningPlanAchievements
                    ];

                    delete lstRosterLearningPlanAssignments;
                    delete lstRosterAchievementAssignments;
                }

                // US1555 - 'Cancelled' should appear on Roster (Student) List in the Online Work column if the enrollment was cancelled
                for (Id theLearningAssignment : lstRosterLearningAssignments) {
                    redwing__Learning_Assignment__c theUpdatedLearningAssignment = new redwing__Learning_Assignment__c();
                    theUpdatedLearningAssignment.Id = theLearningAssignment;
                    theUpdatedLearningAssignment.redwing__Progress__c = 'Cancelled';
                    lstLearningAssignmentsToUpdate.add(theUpdatedLearningAssignment);
                }
                update lstLearningAssignmentsToUpdate;
            }
        }

        // *** End of US1517
        // *** End of US1562
    }

    public void updateClass(Set<Id> clsIds){
        List<redwing__ILT_Class__c> lstCls = new List<redwing__ILT_Class__c>();
        for(Id clsId : clsIds){
            redwing__ILT_Class__c clsRec = new redwing__ILT_Class__c();
            clsRec.Id = clsId;
            clsRec.Skedulo_Job_Active__c = false;
            clsRec.Skedulo_Job_Status__c= 'Cancelled';

            // *** US1562 - Insure that cancelled class does not display on RCO
            clsRec.Class_Online__c = false;
            clsRec.Class_Searchable__c = false;
            // *** End of US1562

            lstCls.add(clsRec);
            //update clsRec;
        }
        update lstCls;
    }

    private Boolean checkClassJobFields(sked__Job__c newJob, sked__Job__c oldJob) {
        Boolean classFieldChange = false; // true = at least one field value has changed between old and new records

        Map<String, Object>
                oldValues = oldJob.getPopulatedFieldsAsMap(),
                newValues = newJob.getPopulatedFieldsAsMap();

        String classFields = 'sked__Account__c,sked__Location__c,sked__Type__c,Ready_to_Publish__c,Location_Confirmed__c,';
        classFields += 'Course_Class_Type__c,Is_Stacked_Class__c,Is_Master_Class__c,Course_Code__c,';
        classFields += 'sked__Parent__c,Course_Catalog__c,sked__TimeZone__c,sked__Start__c,sked__Finish__c,';
        classFields += 'sked__Recurring_Schedule__c,sked__Job_Status__c,sked__Description__c';
        List<String> classFieldList = classFields.split(',');

        for (String theClassField : classFieldList) {
            if (newValues.containsKey(theClassField) && oldValues.containsKey(theClassField)) {
                if (newValues.get(theClassField) != oldValues.get(theClassField)) {
                    classFieldChange = true;
                    break;
                }
            }
        }

        return classFieldChange;
    }

    private Boolean checkSessionJobFields(sked__Job__c newJob, sked__Job__c oldJob) {
        Boolean sessionFieldChange = false; // true = at least one field value has changed between old and new records

        Map<String, Object>
                oldValues = oldJob.getPopulatedFieldsAsMap(),
                newValues = newJob.getPopulatedFieldsAsMap();

        String sessionFields = 'sked__Start__c,sked__Finish__c,sked__Account__c,sked__Description__c,sked__Location__c,';
        sessionFields += 'Special_Instructions__c,sked__Address__c';
        List<String> sessionFieldList = sessionFields.split(',');

        for (String theSessionField : sessionFieldList) {
            if (newValues.containsKey(theSessionField) && oldValues.containsKey(theSessionField)) {
                if (newValues.get(theSessionField) != oldValues.get(theSessionField)) {
                    sessionFieldChange = true;
                    break;
                }
            }
        }

        return sessionFieldChange;
    }

    private Boolean checkEligibility() {
        if(Test.isRunningTest()) {return true;}
        
        // load string from custom label
        // assumption: values in the label are separate by semi-colon, remove space after semi-colon if there is one
        String includedProfiles = Label.SBSkedToILTClassAllowedProfiles.replace('; ', ';');
        List<String> includedProfilesList = includedProfiles.split(';');
        Set<String> includedProfilesSet = new Set<String>(includedProfilesList);

        // get profile name of the current user
        Id profileId = UserInfo.getProfileId();
        List<Profile> profiles = [SELECT Id, Name FROM Profile WHERE Id =:profileId];

        // if Set contains the current profile, return true (only profiles in this List can trigger integration logic)
        if (includedProfilesSet.contains(profiles[0].Name)) {
            return true; // Eligible, profile in included List
        } else {
            return false; // Not eligible, profile not in included List
        }
    }

    private Boolean checkJobStatus(sked__Job__c jobRecord) {
        //****************************************************************************
        // US1539 - Prevent creation of ILT Class under specific conditions
        // (1) For community classes, do not create ILT Class until location is confirmed
        // (2) For CEP classes (Nurse Assistant Testing), do not create ILT Class until Ready to Publish = True
        //****************************************************************************
        Boolean locationConfirmed = jobRecord.Location_Confirmed__c;
        Boolean readyToPublish = jobRecord.Ready_to_Publish__c;
        String jobType = jobRecord.sked__Type__c;

        // Skip community class creation if location not confirmed
        if (((jobType == 'Community') && !locationConfirmed) ||
                // Skip CEP class creation if not ready to publish
                ((jobType == 'Nurse Assistant Testing') && !readyToPublish)) {
            return false; // Take no action on this job
        } else {
            return true;  // Process this job
        }
    }

    private Map<Id, Decimal> checkGeographicSpecificPricing(List<sked__Job__c> newRecords, Map<Id, String> locationToILTLocationZip) {

        // *****
        // US1356 - Determine if class-specific (geography-specific) pricing is defined for any job
        // *****

        Map<Id, String> MapLocationToPriceList = new Map<Id, String>();
        Map<Id, Decimal> jobPriceOverrIdeMap = new Map<Id, Decimal>();

        // Get zip code from location record referenced in Job
        for (String theLocation : locationToILTLocationZip.keySet()) {
            if (theLocation != null) {
                String theZipCode = locationToILTLocationZip.get(theLocation);
                if (theZipCode != null && theZipCode.length()>5) {
                    theZipCode = theZipCode.substring(0,5);
                }
                if (theZipCode != null && theZipCode.length()==5) {
                    String priceListName = 'ZIP-'+theZipCode;
                    MapLocationToPriceList.put(theLocation, priceListName);
                }
            }
        }

        // Get zip code specific pricing (if defined)

        String storeFront = 'GeneralStore';
        Set<Id> ccProducts = new Set<Id>();
        for (ccrz__E_Product__c theCCProduct : catalogIds.values()) {
            ccProducts.add(theCCProduct.Id);
        }

        List<ccrz__E_PriceListItem__c> priceListItems = [SELECT ccrz__Product__c, ccrz__PriceList__r.ccrz__StartDate__c, ccrz__PriceList__r.ccrz__EndDate__c,
                ccrz__PriceList__r.Name, ccrz__StartDate__c, ccrz__EndDate__c, ccrz__Price__c
        FROM ccrz__E_PriceListItem__c WHERE ccrz__Product__c IN :ccProducts AND ccrz__PriceList__r.Name IN :MapLocationToPriceList.values()
        AND ccrz__PriceList__r.ccrz__Enabled__c = True AND ccrz__PriceList__r.ccrz__Storefront__c = :storeFront];

        System.Debug('priceListItems='+priceListItems);

        if (priceListItems != null && priceListItems.size() > 0) { // At least one price overrIde for location and product in job record(s)
            for (sked__Job__c curJobRecord : newRecords) {
                if (curJobRecord.sked__Location__c != null) {
                    String priceListName = MapLocationToPriceList.get(curJobRecord.sked__Location__c);
                    Id courseCatalogId = jobCatalogMap.get(curJobRecord.Id);
                    if (priceListName != null && courseCatalogId != null) {
                        Id ccProductId = catalogIds.get(courseCatalogId).Id;
                        if (ccProductId != null && curJobRecord.sked__Start__c != null) {
                            for (ccrz__E_PriceListItem__c thePriceListItem : priceListItems) {
                                System.debug('thePriceListItem='+thePriceListItem);
                                System.debug('curJobRecord='+curJobRecord);

                                Boolean itemStartDate = true;
                                Boolean itemEndDate = true;
                                Boolean ListStartDate = true;
                                Boolean ListEndDate = true;
                                Date classDate = curJobRecord.sked__Start__c.date();

                                if (thePriceListItem.ccrz__PriceList__r.ccrz__StartDate__c != null) {
                                    if (thePriceListItem.ccrz__PriceList__r.ccrz__StartDate__c > classDate) ListStartDate = false;
                                }
                                if (thePriceListItem.ccrz__PriceList__r.ccrz__EndDate__c != null) {
                                    if (thePriceListItem.ccrz__PriceList__r.ccrz__EndDate__c < classDate) ListEndDate = false;
                                }
                                if (thePriceListItem.ccrz__StartDate__c != null) {
                                    if (thePriceListItem.ccrz__StartDate__c > classDate) itemStartDate = false;
                                }
                                if (thePriceListItem.ccrz__EndDate__c != null) {
                                    if (thePriceListItem.ccrz__EndDate__c < classDate) itemEndDate = false;
                                }

                                System.debug('priceListName='+priceListName);
                                System.debug('ccProductId='+ccProductId);

                                if ((thePriceListItem.ccrz__Product__c != null && thePriceListItem.ccrz__Product__c == ccProductId) &&
                                        (thePriceListItem.ccrz__PriceList__r.Name == priceListName) &&
                                        (itemStartDate && itemEndDate && ListStartDate && ListEndDate)) {
                                    // Add price override to Map
                                    System.debug('Added price overrIde');
                                    jobPriceOverrIdeMap.put(curJobRecord.Id, thePriceListItem.ccrz__Price__c);
                                }
                            }
                        }
                    }
                }
            }
        }
        return jobPriceOverrIdeMap;
        // *****
        // End of US1356
        // *****
    }
}