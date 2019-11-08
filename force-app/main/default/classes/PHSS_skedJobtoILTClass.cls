public without sharing class PHSS_skedJobtoILTClass {
    public Boolean updateRecords = false;
    public static Set<Id> insertedJobs = new Set<Id>();
    public static Set<Id> updatedJobs = new Set<Id>();
    public static Set<Id> canceledJobs = new Set<Id>();

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
            System.debug('tst: new: jobRecord.Id='+jobRecord.Id);
            System.debug('tst: new: insertedJobs.contains(jobRecord.Id)='+insertedJobs.contains(jobRecord.Id));
            System.debug('tst: new: sked__Job_Status__c='+jobRecord.sked__Job_Status__c); 
            System.debug('tst: new: sked__Start_Date__c='+jobRecord.sked__Start__c);
            SYstem.debug('tst: new: sked__Type__c='+jobRecord.sked__Type__c);            
            
            if (!insertedJobs.contains(jobRecord.Id)) {
                if (checkJobStatus(jobRecord)) {
                    lstnewRecords.add(jobRecord);
                    insertedJobs.add(jobRecord.Id);
                }
            }
        }
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
        Map<Id, sked__Job__c> mapCanceledJobs = new Map<Id, sked__Job__c>();
            
        for(sked__Job__c jobRecord : newRecords) {
            System.debug('tst: update: jobRecord.Id='+jobRecord.Id);
            System.debug('tst: update: updatedJobs.contains(jobRecord.Id)='+updatedJobs.contains(jobRecord.Id));
            System.debug('tst: update: sked__Job_Status__c='+jobRecord.sked__Job_Status__c);
            System.debug('tst: update(old): sked__Job_Status__c='+oldRecords.get(jobRecord.Id).sked__Job_Status__c);
            System.debug('tst: update: sked__Start_Date__c='+jobRecord.sked__Start__c);
            System.debug('tst: update: sked__Type__c='+jobRecord.sked__Type__c);
            
            sked__Job__c oldJob = oldRecords.get(jobRecord.Id);
            if (jobRecord.sked__Job_Status__c == 'Cancelled') {
                if (!canceledJobs.contains(jobRecord.Id)) {                    
                    mapCanceledJobs.put(jobRecord.Id, jobRecord);
                    canceledJobs.add(jobRecord.Id);
                }
            } else {
                if (!updatedJobs.contains(jobRecord.Id)) {
                    if (checkJobStatus(jobRecord)) {
                        // Need to open this up; Job is "updated" when new/additional instructor is assigned.
                        // ILT Class logic needs to be traversed to issue additional vouchers, if required,
                        // based on number of instructors (resources) assigned to class (job).  In this case
                        // no fields are modified in Job record, but the record still needs to be processed.
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
        
        if(!mapCanceledJobs.isEmpty()) {   
            List<sked__Job__c> lstCanceledJobs = MapCanceledJobs.values();  
            for (sked__Job__c theJob : addDependentStackedClasses(lstCanceledJobs, true)) {
                if (!mapCanceledJobs.containsKey(theJob.Id)) {
                    mapCanceledJobs.put(theJob.Id, theJob);
                }
            }       
            cancelRelatedRecords(mapCanceledJobs); 
        }   
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
        //Set<Id> masterJobIds = new Set<Id>();
        
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

    public List<redwing__ILT_Instructor__c> assignInstructors(Set<Id> setJob) {
        // Assign all instructors to jobs/classes based on current allocations in Skedulo

        Set<String> allocationExternalIds = new Set<String>();
        Set<Id> recurringJobIds = new Set<Id>();
        Set<Id> ILTInstructors = new Set<Id>();

        List<Id> ILTInstructorIds = new List<Id>();
        List<Id> validatedJobIds = new List<Id>();
        List<redwing__ILT_Instructor__c> assignedInstructors = new List<redwing__ILT_Instructor__c>();
        List<redwing__ILT_Instructor__c> updatedInstructors = new List<redwing__ILT_Instructor__c>();

        Map<Id, Id> dependentJobMap = new Map<Id, Id>();
        Map<Id, Set<Id>> existingInstructorMap = new Map<Id, Set<Id>>();

        // Insure we are rebuilding instructor assignments only for those jobs which have a defined allocation
        // Dependent stacked classes have been added to setJob prior to this call, and these do NOT
        // have their own allocation (they inherit from the parent in the stack).

        for (Id theJobId : setJob) {
            if (jobAllocationMap.containsKey(theJobId)) {
                validatedJobIds.add(theJobId);
            }
        }

        // Add all members of a stacked class Job Ids to list of validated jobs (these have no explicit allocations)
        for (sked__Job__c theJob : [
                SELECT Id, sked__Parent__c
                FROM sked__Job__c
                WHERE sked__Parent__c IN :validatedJobIds
        ]) {
            // Discard this job if in fact it represents a master class (parent id == class id)
            if (theJob.Id == theJob.sked__Parent__c) continue;

            dependentJobMap.put(theJob.Id, theJob.sked__Parent__c);
            validatedJobIds.add(theJob.Id);
        }

        // Build list of all instructors previously assigned to Jobs in scope of this request
        assignedInstructors = [
                SELECT Id, redwing__ILT_Class__c, redwing__Instructor__c,
                        redwing__ILT_Class__r.Skedulo_Job_Id__c
                FROM redwing__ILT_Instructor__c
                WHERE redwing__ILT_Class__r.Skedulo_Job_Id__c IN :validatedJobIds
        ];

        if (!assignedInstructors.isEmpty()) {
            for (redwing__ILT_Instructor__c theILTInstructor : assignedInstructors) {
                if (existingInstructorMap.containsKey(theILTInstructor.redwing__ILT_Class__r.Skedulo_Job_Id__c)) {
                    ILTInstructors = existingInstructorMap.get(theILTInstructor.redwing__ILT_Class__r.Skedulo_Job_Id__c);
                }
                ILTInstructors.add(theILTInstructor.redwing__Instructor__c);
                existingInstructorMap.put(theILTInstructor.redwing__ILT_Class__r.Skedulo_Job_Id__c, ILTInstructors);
            }
        }

        // Map all instructors allocated to the current job to this class
        // The external Id insures that if the same instructor is assigned to multiple sessions (as in a recurring series)
        // that they are only associated once at the ILT Class level (all instructors across all recurring jobs
        // are assigned at the class level, not the session level)

        // Add allocations for the master (parent) class in a recurring series (only one - typically the first in the series -
        // will have an ILT Class defined)
        List<redwing__ILT_Class__c> recurringMasterClasses = [SELECT Id, Skedulo_Job_Id__c, Skedulo_Job_Id__r.sked__Recurring_Schedule__c
            FROM redwing__ILT_Class__c
            WHERE Skedulo_Job_Id__r.sked__Recurring_Schedule__c IN :scheduleAllocationMap.keySet()];
        for (redwing__ILT_Class__c theClass : recurringMasterClasses) {
            if (scheduleAllocationMap.containsKey(theClass.Skedulo_Job_Id__r.sked__Recurring_Schedule__c)) {
                for (Id theResourceId : scheduleAllocationMap.get(theClass.Skedulo_Job_Id__r.sked__Recurring_Schedule__c)) {
                    if (!allocationExternalIds.contains(theClass.Skedulo_Job_Id__c + ':' + theResourceId)) {
                        redwing__ILT_Instructor__c theILTInstructor = new redwing__ILT_Instructor__c();
                        theILTInstructor.Skedulo_Job_Id_External__c = theClass.Skedulo_Job_Id__c + ':' + theResourceId;
                        theILTInstructor.redwing__Instructor__c = resourceToInstructorMap.get(theResourceId);
                        theILTInstructor.redwing__ILT_Class__c = theClass.Id;

                        System.debug('**** Creating ILTInstructor (schedule allocation):' + theILTInstructor);

                        updatedInstructors.add(theILTInstructor);
                        allocationExternalIds.add(theILTInstructor.Skedulo_Job_Id_External__c);
                        if (existingInstructorMap.containsKey(theClass.Skedulo_Job_Id__c)) {
                            ILTInstructors = existingInstructorMap.get(theClass.Skedulo_Job_Id__c);
                            ILTInstructors.remove(theILTInstructor.redwing__Instructor__c);
                            existingInstructorMap.put(theClass.Skedulo_Job_Id__c, ILTInstructors);
                        }
                    }
                }
            }
        }

        // Add allocations for each job in scope of this request (which now includes all members of stacked classes)
        for (Id theJobId : validatedJobIds) {
            // If this is a stacked class (job), then we use job Id of the master (parent) class/job
            Id jobAllocationId = theJobId;
            if (dependentJobMap.containsKey(theJobId)) {
                jobAllocationId = dependentJobMap.get(theJobId);
            }

            if (jobAllocationMap.containsKey(jobAllocationId)) {
                for (Id theResourceId : jobAllocationMap.get(jobAllocationId)) {
                    if (!allocationExternalIds.contains(theJobId + ':' + theResourceId)) {
                        redwing__ILT_Instructor__c theILTInstructor = new redwing__ILT_Instructor__c();
                        theILTInstructor.Skedulo_Job_Id_External__c = theJobId + ':' + theResourceId;
                        theILTInstructor.redwing__Instructor__c = resourceToInstructorMap.get(theResourceId);
                        theILTInstructor.redwing__ILT_Class__r = new redwing__ILT_Class__c(Skedulo_Job_Id_External__c = theJobId);

                        System.debug('**** Creating ILTInstructor (job allocation):' + theILTInstructor);

                        updatedInstructors.add(theILTInstructor);
                        allocationExternalIds.add(theILTInstructor.Skedulo_Job_Id_External__c);
                        if (existingInstructorMap.containsKey(theJobId)) {
                            ILTInstructors = existingInstructorMap.get(theJobId);
                            ILTInstructors.remove(theILTInstructor.redwing__Instructor__c);
                            existingInstructorMap.put(theJobId, ILTInstructors);
                        }
                    }
                }
            }
        }
        /*
        // Delete orphaned instructors (inactive allocations)
        for (Id theJobId : existingInstructorMap.keySet()) {
            Set<Id> ILTInstructors = existingInstructorMap.get(theJobId);

            for (redwing__ILT_Instructor__c theILTInstructor : assignedInstructors) {
                ILTInstructorIds.add(theILTInstructor.Id);
            }

            if (!ILTInstructorIds.isEmpty()) {
                Database.DeleteResult[] drList = Database.delete(ILTInstructorIds, false);
            }

        }
        */
        return updatedInstructors;
    }

    public Map<Id, Id> getResourceInstructorMap(Set<Id> setJob) {
        Map<Id, Id> resourceToInstructorMap = new Map<Id, Id>();
        Set<Id> resourceIdSet = new Set<Id>();

        for (Id theJobId : setJob) {
            // Skip stacked class job ids which do not have allocations assigned to them (master classes do)
            if (jobAllocationMap.containsKey(theJobId)) {
                for (Id theResourceId : jobAllocationMap.get(theJobId)) {
                    resourceIdSet.add(theResourceId);
                }
            }
        }

        if(!resourceIdSet.isEmpty()){
            for (redwing__Instructor__c instructor : [SELECT Id, Skedulo_Instructor__c, redwing__User__c, Skedulo_Instructor_External__c
                FROM redwing__Instructor__c WHERE Skedulo_Instructor__c IN :resourceIdSet]) {
                resourceToInstructorMap.put(instructor.Skedulo_Instructor__c, instructor.redwing__User__c);
            }
        }
        system.debug('**** resourceToInstructorMap:'+resourceToInstructorMap);
        return resourceToInstructorMap;
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
    public  Map<Id, Integer> jobInstructorCountMap = new Map<Id, Integer>();
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
        for(Course_Catalog__c cc:[SELECT Name, Id, Number_of_Instructors__c FROM Course_Catalog__c WHERE Type__c!=NULL LIMIT 10000])
        {
            CCwithIds.put(cc.name, cc.Id);
        }
        //System.debug('Course catalog with Name and Id' +CCwithIds);
                
        for(sked__Job__c curJobRecord : newRecords){    
            if(curJobRecord.Is_Stacked_Class__c==true){   
                if(CCwithIds.containsKey(curJobRecord.Course_Code__c)){ 
                    jobIds.add(curJobRecord.Id);
                    jobCatalogMap.put(curJobRecord.Id, CCwithIds.get(curJobRecord.Course_Code__c));//JobId with respective course catalog record - only stacked class
                    System.debug('*** Job:'+curJobRecord.Name+' is a valid stacked class with course code:'+curJobRecord.Course_Code__c);
                    System.debug('*** Job catalog Map stacked class:'+jobCatalogMap);
                    
                    // *** US1493 - Enhancement to Skedulo record allocation to jobs
                    // It was noticed that Skedulo does NOT assign a resource to stacked classes (only the master class)
                    // masterJobIds insures that if the master class was created first that the stacked classes are assigned an instructor 
                    // (Note the above disclaimer - this is an important assumption in this design - record order cannot be guaranteed) 
                    if (curJobRecord.Is_Master_Class__c == false && curJobRecord.sked__Parent__c != null) {
                        masterJobIds.add(curJobRecord.sked__Parent__c);
                        System.debug('Adding masterJobId:'+curJobRecord.sked__Parent__c);
                    }
                    if (curJobRecord.Is_Master_Class__c) {
                        jobInstructorCountMap.put(curJobRecord.Id, (Integer) curJobRecord.Number_of_Instructors__c);
                    }
                    System.debug('**** Job: '+curJobRecord.Name+' Id:'+curJobRecord.Id+' jobInstructorCountMap='+jobInstructorCountMap);
                }
            }
            else
            {
                jobIds.add(curJobRecord.Id);                        
                jobCatalogMap.put(curJobRecord.Id, curJobRecord.Course_Catalog__c); //JobId with respective course catalog record(Stacked class not included)
                System.debug('*** Job:'+curJobRecord.name+' is a normal class:'+jobCatalogMap);

                jobInstructorCountMap.put(curJobRecord.Id, (Integer) curJobRecord.Number_of_Instructors__c);
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

        if(!jobIds.isEmpty()) {
            jobAllocationList = [SELECT sked__Job__c, sked__Job__r.sked__Recurring_Schedule__c, sked__Resource__c
            FROM sked__Job_Allocation__c
            WHERE (sked__Job__c IN :jobIds OR sked__Job__c IN :masterJobIds)
            AND sked__Status__c NOT IN ('Deleted','Declined')];

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
        }

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
        Map<Id, Id> scheduleToParentJobIdMap = new Map<Id, Id>();
        Map<String,redwing__Learning_Version__c> lVersions = new Map<String,redwing__Learning_Version__c>();
        Map<Id,Id> insertedclassId = new Map<Id,Id>();
        Map<Id, Id> JobIdOppIdMap = new Map<Id, Id>();
        Map<String, Id> orderIdJobIdMap = new Map<String, Id>(); // key: order:orderItem Id, value: skedulo Job Id
        Map<Id, String> jobIdOrderIdMap = new Map<Id, String>(); // key: skedulo Job Id , value: order:orderItem Id
        Map<Id, Set<ccrz__E_OrderItem__c>> jobIdOrderItems = new Map<Id, Set<ccrz__E_OrderItem__c>>(); // skedulo job Id as key, Set of related order items as value

        List<redwing__Learning__c> lstLearning = new List<redwing__Learning__c>();
        List<redwing__Training_Activity__c> lstTrainingActivity = new List<redwing__Training_Activity__c>();
        List<redwing__ILT_Event_Class__c> lstEventClass = new List<redwing__ILT_Event_Class__c>();
        List<redwing__ILT_Class__c> lstILTClass = new List<redwing__ILT_Class__c>();
        List<redwing__ILT_Session__c> lstILTSession = new List<redwing__ILT_Session__c>();
        List<redwing__ILT_Instructor__c> lstILTInstructor = new List<redwing__ILT_Instructor__c>();
        List<redwing__Learning__c> insertedLearnings = new List<redwing__Learning__c>();
        List<redwing__ILT_Class__c> updateclassrecList = new List<redwing__ILT_Class__c>();
        List<ccrz__E_OrderItem__c> lstOrderItems = new List<ccrz__E_OrderItem__c>(); // List to be populated with order items after ILT class is added
        List<ccrz__E_Order__c> lstOrders = new List<ccrz__E_Order__c>(); // List to be populated with CRE Request Processed flag
        List<ccrz__E_OrderItem__c> orderItems = new List<ccrz__E_OrderItem__c>();
        List<Voucher__c> voucherList = new List<Voucher__c>();
        List<String> fullServiceJobTypes = new List<String>{'Full Service',
                'Nurse Assistant Testing - Full Service','Nurse Assistant Training - Full Service'};

        Set<Id> SetJob = new Set<Id>();
        Set<Id> SetTrainingEvents = new Set<Id>();
        //Set<Id> SetDeleteILTInstructor = new Set<Id>();
        Set<Id> SetSchedule = new Set<Id>();
        Set<Id> orderIdSet = new Set<Id>();
        Set<Id> orderItemIdSet = new Set<Id>();
        //Set<redwing__ILT_Instructor__c> SetILTInstructor = new Set<redwing__ILT_Instructor__c>();

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
            for(redwing__ILT_Class__c theClass : [Select Id, Skedulo_Job_Id__c, redwing__Max_Seats__c, Available_Seats__c from redwing__ILT_Class__c where Skedulo_Job_Id__c IN: SetJob]) {
                jobToClassMap.put(theClass.Skedulo_Job_Id__c, theClass);
            }
        }

        // Build Set of recurring schedule Ids that have outstanding ILT Classes
        // There should only be one ILT Class per recurring schedule
        // If the job being processed has the same recurring schedule as an existing ILT Class then 
        // process session only (skip ILT class, LActvity, LObject, and LVersion creation)
        if (SetSchedule.size() > 0) {
            For (redwing__ILT_Class__c theILTClass : [Select Id, Skedulo_Job_Id__c, Skedulo_Job_Id__r.sked__Recurring_Schedule__c From redwing__ILT_Class__c Where Skedulo_Job_Id__r.sked__Recurring_Schedule__c In :SetSchedule]) {
                scheduleToParentJobIdMap.put(theILTClass.Skedulo_Job_Id__r.sked__Recurring_Schedule__c, theILTClass.Skedulo_Job_Id__c);
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

        // **** logic to populate Opp Id on Full Service class and Full Service NATraining/Testing
        // query opportunity IDs, Map - dependency Map between job and opp Id

        Map<Id, sked__Job__c> skedJobsMap = new Map<Id, sked__Job__c>([SELECT Id,
                Training_Event__r.Opportunity__c, Training_Event__r.CC_Order__c, Training_Event__r.CC_Order_Item__c
                FROM sked__Job__c WHERE Id IN :SetJob AND sked__Type__c IN :fullServiceJobTypes]);

        // *** get order items to populate them with ILT class Id.
        if (!skedJobsMap.isEmpty()) {
            for (Id jobId : skedJobsMap.keySet()) {
                Id orderId = skedJobsMap.get(jobId).Training_Event__r.CC_Order__c;
                Id orderItemId = skedJobsMap.get(jobId).Training_Event__r.CC_Order_Item__c;
                if (orderId == null || orderItemId == null) continue;
                String orderIdOrderItemId = String.valueOf(orderId) + ':' + String.valueOf(orderItemId);
                jobIdOrderIdMap.put(jobId, orderIdOrderItemId);
                orderIdSet.add(orderId);
                orderItemIdSet.add(orderItemId);
            }

            orderItems = [
                    SELECT Id, ILT_Class__c, ccrz__Order__c, ccrz__ParentOrderItem__c
                    FROM ccrz__E_OrderItem__c
                    WHERE (ccrz__Order__c IN :orderIdSet) AND (Id IN :orderItemIdSet
                    OR (ccrz__ParentOrderItem__c IN :orderItemIdSet AND ccrz__OrderLineType__c = 'Minor'))
            ];

            for (ccrz__E_OrderItem__c item : orderItems) {
                String orderIdOrderItemId = '';
                if (String.isNotBlank(item.ccrz__ParentOrderItem__c)) {
                    orderIdOrderItemId = String.valueOf(item.ccrz__Order__c) + ':' + String.valueOf(item.ccrz__ParentOrderItem__c);
                } else {
                    orderIdOrderItemId = String.valueOf(item.ccrz__Order__c) + ':' + String.valueOf(item.Id);
                }

                for (Id jobId : skedJobsMap.keySet()) {
                    if (jobIdOrderIdMap.containsKey(jobId) && jobIdOrderIdMap.get(jobid) == orderIdOrderItemId) {
                        if (jobIdOrderItems.keySet().contains(jobId)) {
                            // if the skedulo job exists as key already, add the order item to existing Set
                            Set<ccrz__E_OrderItem__c> orderItemSet = jobIdOrderItems.get(jobId);
                            orderItemSet.add(item);
                            jobIdOrderItems.put(jobId, orderItemSet);
                        } else {
                            // if the skedulo job does not exist as key, create Set and add to the Map
                            Set<ccrz__E_OrderItem__c> orderItemSet = new Set<ccrz__E_OrderItem__c>{item};
                            jobIdOrderItems.put(jobId, orderItemSet);
                        }
                    }
                }
            }
        }
        // ****

        // **************************************************************************************************************   
        // Main loop of method - iterate across all incoming jobs
        // **************************************************************************************************************

        for(sked__Job__c curJobRecord : newRecords) {
            Integer nMaxStudents = 0;
            String instructorStudentRatio = '';
            Integer nRequiredInstructors = 0;

            sked__Job__c oldJobRecord = oldRecords.get(curJobRecord.Id);

            // Determine if this is an updated job record for which an ILT class record does not already exist
            // If so, treat as an insert not an update

            if (jobToClassMap.containsKey(curJobRecord.Id)) {
                classExists = true;
            } else {
                classExists = false;
            }

            // Determine if there is an existing class with this recurring schedule Id - if so do not create or modify ILT Class record
            if (curJobRecord.sked__Recurring_Schedule__c != null && scheduleToParentJobIdMap.containsKey(curJobRecord.sked__Recurring_Schedule__c)) {
                if (scheduleToParentJobIdMap.get(curJobRecord.sked__Recurring_Schedule__c) != curJobRecord.Id) {
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

                // Skip if this job is not the first class created in a recurring schedule

                if(!recurringJob) {
                    // **************************************************************************************************************                   
                    // Step 1 - Create ILT Class record for this Skedulo Job (may exist from previous requests)
                    // Note: The Skedulo Job Id binds the ILT Class, Session, Learning Object, and EventClass records together      
                    // **************************************************************************************************************  

                    System.debug('updateRecords++++++++++++' + updateRecords);
                    System.debug('sked start++++++++++++' + curJobRecord.sked__Start__c);

                    System.debug('Inside class creation');
                    Redwing__ILT_Class__c clsRecord = new Redwing__ILT_Class__c();
                    clsRecord.Skedulo_Account__c = curJobRecord.sked__Account__c;
                    clsRecord.redwing__Description__c = curJobRecord.sked__Description__c;
                    clsRecord.Request_Type__c = curJobRecord.sked__Type__c;
                    clsRecord.Ready_to_Publish__c = curJobRecord.Ready_to_Publish__c;
                    if (curJobRecord.sked__Type__c != null && !curJobRecord.sked__Type__c.contains('Full Service')) {
                        if (String.isNotBlank(curJobRecord.sked__Location__c) && locationToILTLocationMap.containsKey(curJobRecord.sked__Location__c)) {
                            clsRecord.redwing__Location__c = locationToILTLocationMap.get(curJobRecord.sked__Location__c);
                        } else {
                            clsRecord.redwing__Location__c = null; // added as per DE1443
                        }
                    } else {
                        // DE1743 - Create location for full service classes (if required)
                        // Full service jobs do NOT have a location record created in Skedulo; must create one in Appinium
                        // as an ILTLocation record (locations are specific to an account)

                        if (curJobRecord.sked__Account__c != null && String.isNotBlank(curJobRecord.sked__Address__c)) {
                            Id fullServiceLocationId = convertSkedLocationToILTLocation(curJobRecord.sked__Account__c, curJobRecord.sked__Address__c);
                            if (fullServiceLocationId != null) {
                                clsRecord.redwing__Location__c = fullServiceLocationId;
                            }
                        }
                    }

                    clsRecord.Class_Online__c = true;
                    clsRecord.Course_Class_Type__c = curJobRecord.Course_Class_Type__c;

                    if (curJobRecord.sked__Type__c != null && curJobRecord.sked__Type__c.contains('Full Service')) {
                        if (skedJobsMap.get(curJobRecord.Id) != null && skedJobsMap.get(curJobRecord.Id).Training_Event__c != null) {
                            clsRecord.Opportunity__c = skedJobsMap.get(curJobRecord.Id).Training_Event__r.Opportunity__c;
                        }
                    } else clsRecord.Opportunity__c = null;

                    if (curJobRecord.Is_Stacked_Class__c == true) {
                        if (catalogIds.get(CCwithIds.get(curJobRecord.Course_Code__c)) != Null) {
                            instructorStudentRatio = catalogIds.get(CCwithIds.get(curJobRecord.Course_Code__c)).Course_Catalog__r.Ratio_to_Instructor__c;
                        }
                        if (curJobRecord.sked__Parent__c != null && jobInstructorCountMap.containsKey(curJobRecord.sked__Parent__c)) {
                            nRequiredInstructors = jobInstructorCountMap.get(curJobRecord.sked__Parent__c);
                        } else {
                            if (curJobRecord.Is_Master_Class__c && jobInstructorCountMap.containsKey(curJobRecord.Id)) {
                                nRequiredInstructors = jobInstructorCountMap.get(curJobRecord.Id);
                            }
                        }
                    } else {
                        if (catalogIds.get(curJobRecord.Course_Catalog__c) != Null) {
                            instructorStudentRatio = catalogIds.get(curJobRecord.Course_Catalog__c).Course_Catalog__r.Ratio_to_Instructor__c;
                        }
                        if (jobInstructorCountMap.containsKey(curJobRecord.Id)) {
                            nRequiredInstructors = jobInstructorCountMap.get(curJobRecord.Id);
                        }
                    }

                    // Default instructor:student ratio to 1:12 
                    if (String.isBlank(instructorStudentRatio)) {
                        instructorStudentRatio = '1:12';
                    }
                    system.debug('*** instructorStudentRatio=' + instructorStudentRatio);
                    system.debug('*** nRequiredInstructors=' + nRequiredInstructors);

                    String[] ratio = instructorStudentRatio.split(':');
                    if (ratio.size() == 2 && ratio[0] != null && ratio[1] != null) {
                        Integer nInstructor = Integer.valueOf(ratio[0]);
                        Integer nStudent = Integer.valueOf(ratio[1]);

                        if (nInstructor != null && nStudent != null && nInstructor != 0) {
                            // Default to one instructor if none have been defined
                            if (nRequiredInstructors == null || nRequiredInstructors <= 0) {
                                nRequiredInstructors = 1;
                            }
                            nMaxStudents = Integer.valueOf(Math.ceil((nStudent / nInstructor) * nRequiredInstructors));
                        }
                    } else {
                        nMaxStudents = 12;
                    }
                    system.debug('*** nMaxStudents=' + nMaxStudents);

                    // Instructor and student counts are NEVER decremented, only adjusted upwards
                    if (jobToClassMap.containsKey(curJobRecord.Id)) {
                        redwing__ILT_Class__c theExistingClass = jobToClassMap.get(curJobRecord.Id);
                        if (theExistingClass.redwing__Max_Seats__c < nMaxStudents) {
                            clsRecord.redwing__Max_Seats__c = nMaxStudents;
                            clsRecord.Available_Seats__c = theExistingClass.Available_Seats__c + (nMaxStudents - theExistingClass.redwing__Max_Seats__c);
                        }
                    } else {
                        clsRecord.redwing__Max_Seats__c = nMaxStudents;
                        clsRecord.Available_Seats__c = nMaxStudents;
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
                            clsRecord.Classroom_Setting__c = learningPlancs.get(curJobRecord.Course_Catalog__c);
                            if (catalogIds!=null && catalogIds.get(curJobRecord.Course_Catalog__c)!=null) {
                                clsRecord.Cloud_Craze_Product__c= catalogIds.get(curJobRecord.Course_Catalog__c).Id;
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
                    
                    if (jobPriceOverrideMap.get(curJobRecord.Id) != null && curJobRecord.sked__Type__c == 'Community') {
                        System.debug('OverrIde='+jobPriceOverrideMap.get(curJobRecord.Id));
                        clsRecord.Price_Override__c = jobPriceOverrideMap.get(curJobRecord.Id);
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
                        scheduleToParentJobIdMap.put(curJobRecord.sked__Recurring_Schedule__c, curJobRecord.Id);
                    }   
                    lstILTClass.add(clsRecord);

                }
                System.debug('lstILTClass records' +lstILTClass);

                // **************************************************************************************************************                  
                // Housekeeping - Obtain the class job Id value to be used to associate records across all related objects
                // Recurring jobs need to cross-reference the existing class job Id stored in scheduleToParentJobIdMap (if present)
                // (Used to define lookup value for ILT Class in records below)
                // **************************************************************************************************************  
                                
                Id jobRecordId = curJobRecord.Id;
                if (recurringJob) {
                    if (scheduleToParentJobIdMap.containsKey(curJobRecord.sked__Recurring_Schedule__c)) {
                        jobRecordId = scheduleToParentJobIdMap.get(curJobRecord.sked__Recurring_Schedule__c);  
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

                    if (curJobRecord.sked__Type__c != null && !curJobRecord.sked__Type__c.contains('Full Service')) {
                        if (String.isNotBlank(curJobRecord.sked__Location__c) && locationToILTLocationMap.containsKey(curJobRecord.sked__Location__c)) {
                            sessionRecord.redwing__Location__c = locationToILTLocationMap.get(curJobRecord.sked__Location__c);
                        } else {
                            sessionRecord.redwing__Location__c = null; // added as per DE1443
                        }
                    } else {
                        // DE1743 - Create location for full service classes (if required)
                        // Full service jobs do NOT have a location record created in Skedulo; must create one in Appinium
                        // as an ILTLocation record (locations are specific to an account)

                        if (curJobRecord.sked__Account__c != null && String.isNotBlank(curJobRecord.sked__Address__c)) {
                            Id fullServiceLocationId = convertSkedLocationToILTLocation(curJobRecord.sked__Account__c, curJobRecord.sked__Address__c);
                            if (fullServiceLocationId != null) {
                                sessionRecord.redwing__Location__c = fullServiceLocationId;
                            }
                        }
                    }

                    /*
                    if (curJobRecord.sked__Location__c != null) {
                        sessionRecord.redwing__Location__c = (!locationToILTLocationMap.IsEmpty() && locationToILTLocationMap.containsKey(curJobRecord.sked__Location__c)) ? locationToILTLocationMap.get(curJobRecord.sked__Location__c) : null;
                    } else sessionRecord.redwing__Location__c = null;
                    */

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

            for (Integer nILTClass = 0; nILTClass < results.size(); nILTClass++) {
                if (results[nILTClass].isSuccess()) {
                    redwing__ILT_Class__c clsRecord = lstILTClass[nILTClass];
                    newJobToClassMap.put(clsRecord.Skedulo_Job_Id__c, clsRecord);
                    // *** populate order items for FS class with the ILT class
                    // for every successful inserted class check if it is FS to get Set of order items
                    // iterate through order items, populate ILT class, add to the order items List
                    // update order items

                    if (clsRecord.Request_Type__c != null && clsRecord.Request_Type__c.contains('Full Service')) {
                        Set<ccrz__E_OrderItem__c> orderItemSet = jobIdOrderItems.get(clsRecord.Skedulo_Job_Id__c);
                        if (orderItemSet != null && !orderItemSet.isEmpty()) {
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

            // **************************************************************************************************
            // ** Manage Resource (Instructor) Allocations (Assignments)
            // **************************************************************************************************

            resourceToInstructorMap = getResourceInstructorMap(setJob);
            if (!resourceToInstructorMap.isEmpty()) {
                lstILTInstructor = assignInstructors(setJob);
            }

            // Voucher creation (newJobToClassMap now contains a mapping of Job Id to ILT Class for both new and existing classes)
            // We must iterate over old and new to determine if class size has changed based on job allocation or ratio change

            system.debug(newJobToClassMap);
            for (redwing__ILT_Class__c theClass : newJobToClassMap.values()) {

                // Skip full service classes:  Vouchers for full service-type classes are created using TE process (they
                // are created in process builder 'Create Voucher From TE' and associate a new voucher to an order, order line, and TE

                if (theClass.Request_Type__c != null && !theClass.Request_Type__c.contains('Full Service')) {
                    // Insure that the Learning Plan Id will be available if we need to create voucher, otherwise need to skip
                    if (catalogIds.get(jobCatalogMap.get(theClass.Skedulo_Job_Id__c)) != null) {
                        // For new ILT Class records use the previously calculated max seats(number of students) for voucher count
                        // For updated (existing) ILT Class records determine if voucher count is still valid (max seats)
                        Integer nTotalStudentsOld = 0;
                        Integer nTotalStudents = 0;
                        if (theClass.redwing__Max_Seats__c != null) {
                            nTotalStudents = Integer.valueOf(theClass.redwing__Max_Seats__c);
                        }
                        if (jobToClassMap.containsKey(theClass.Skedulo_Job_Id__c)) {
                            nTotalStudentsOld = Integer.valueOf(jobToClassMap.get(theClass.Skedulo_Job_Id__c).redwing__Max_Seats__c);
                        }

                        System.debug('*** nTotalStudentsOld=' + nTotalStudentsOld + ' nTotalStudents=' + nTotalStudents);
                        if (nTotalStudents > nTotalStudentsOld) {
                            for (Integer i = 0; i < (nTotalStudents - nTotalStudentsOld); i++) {
                                Voucher__c objVoucher = new Voucher__c();
                                objVoucher.ILT_Class__c = theClass.Id;
                                objVoucher.Learning_Plan__c = catalogIds.get(jobCatalogMap.get(theClass.Skedulo_Job_Id__c)).LMS_Learning_Plan__c;
                                voucherList.add(objVoucher);
                            }
                        }
                    }
                }
            }
        }

        if (lstILTInstructor.size() > 0) {
            System.debug('lstILTInstructor='+lstILTInstructor);
            Schema.SObjectField f = redwing__ILT_Instructor__c.Fields.Skedulo_Job_Id_External__c;
            Database.UpsertResult[] results = Database.upsert(lstILTInstructor, f, false);
            system.debug('lstILTInstructor Upsert Results =' + results);
        }

        if (lstILTSession.size() > 0) {
            System.debug('ListILTSession='+lstILTSession);
            Schema.SObjectField f = redwing__ILT_Session__c.Fields.Skedulo_Job_Id_External__c;
            Database.UpsertResult[] results = Database.upsert(lstILTSession, f, false);
            System.debug('ListILTSession Upsert Results='+results);
        }

        if (voucherList.size() > 0) {
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
        
        if (lstEventClass.size() > 0){
            System.debug(' Event Class record created');
            Schema.SObjectField f = redwing__ILT_Event_Class__c.Fields.Skedulo_Job_Id_External__c;
            Database.UpsertResult[] results = Database.upsert(lstEventClass, f, false);
            System.debug('get eventclass Id '+results[0].getId());            
        } 

        if (lstTrainingActivity.size() > 0){
            System.debug(' Learning Activity record created');
            Schema.SObjectField f = redwing__Training_Activity__c.Fields.Skedulo_Job_Id_External__c;
            Database.UpsertResult[] results = Database.upsert(lstTrainingActivity, f, false);
            System.debug('get learning activity Id '+results[0].getId());
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

    // Comment out for now since this is no longer being called - helps test class coverage
    /*
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
    */
    
    private Boolean checkSessionJobFields(sked__Job__c newJob, sked__Job__c oldJob) {
        Boolean sessionFieldChange = false; // true = at least one field value has changed between old and new records

        if (oldJob != null) {
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
        } else {
            sessionFieldChange = true; // Force true (could be dependent job (stacked class) added to job list)
        }

        return sessionFieldChange;
    }

    private Boolean checkEligibility() {
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
            if(Test.isRunningTest()) return true;            
            else return false; // Not eligible, profile not in included List
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
        } else if (jobType != null && jobType.contains('Full Service')) {
            if (PHSS_TriggerSettings__c.getOrgDefaults().skedJobtoILTClassFullServiceDisabled__c) {
                return false; // Ignore full service jobs if this custom setting disabled
            } else {
                // Check to see if this full service job has cloud craze order/order item numbers associated to it
                if (jobRecord.Training_Event__r.CC_Order__c == null || jobRecord.Training_Event__r.CC_Order_Item__c == null) {               
                    List<User>theUser = [Select Email From User Where Id = :jobRecord.LastModifiedById Limit 1];
                    String emailToAddress = theUser[0].Email;
                    if (String.isNotBlank(emailToAddress)) {                    
                        // Send email to scheduler that full service job is being processed without a cloud craze order associated to it
                        String emailBody = 'The full service job you have scheduled, Job ' + jobRecord.Name +
                                ', resulted in a ILT Class which does not have a Cloud Craze order associated to it.';
                        String emailSubject = 'ILT Class Created Without Cloud Craze Order - Job' + jobRecord.Name;
                        // Create email
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        email.setSubject(emailSubject);
                        email.setToAddresses(new String[]{
                                emailToAddress
                        });
                        email.setPlainTextBody(emailBody);
                        system.debug('=======email:'+email);
                        if (!Test.isRunningTest()) {
                            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
                        }
                    }
                }
                return true;  // Process this full service job
            }
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

    public static Id convertSkedLocationToILTLocation(Id accountId, String skedAddress) {
        String theLocName = '';
        String theAddress1 = '';
        String theAddress2 = '';
        String theCity = '';
        String theState = '';
        String theZip = '';
        String theCountry = '';
        Id theLocationId = null;

        if(String.IsNotBlank(skedAddress) && accountId != null) {
            List<String> parsedAddress = PHSS_skedLocationToILTLocation.parseAddress(skedAddress);
            theAddress1 = parsedAddress[0];
            theAddress2 = parsedAddress[1];
            theCity = parsedAddress[2];
            theState = parsedAddress[3];
            theZip = parsedAddress[4];
            theCountry = parsedAddress[5];

            theLocName = skedAddress.substring(0, Math.min(skedAddress.length(), 80));
            theLocationId = ILTInstructorCommunity.createIltLocation((String) accountId, theLocName, theAddress1, theAddress2, theZip, theState, theCity);
        }
        return theLocationId;
    }
}