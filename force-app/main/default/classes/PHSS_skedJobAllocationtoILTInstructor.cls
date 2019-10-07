public without sharing class PHSS_skedJobAllocationtoILTInstructor {
    public Boolean updateRecords = false;
    public static Set<Id> insertedRecords = new Set<Id>();
    public static Set<Id> updatedRecords = new Set<Id>();

    public void afterInsert(List<sked__Job_Allocation__c> newRecords) {
        Id resourceId;
        Id jobId;
        Id scheduleId;

        Set<Id> jobResources;
        Set<Id> scheduleResources;
        Set<Id> resourceIds = new Set<Id>();
        Set<Id> jobIds = new Set<Id>();
        Set<redwing__ILT_Instructor__c> ILTInstructorSet = new Set<redwing__ILT_Instructor__c>();

        List<sked__Job_Allocation__c> newAllocations = new List<sked__Job_Allocation__c>();
        List<sked__Job__c> jobList = new List<sked__Job__c>();

        Map<Id, sked__Job__c> jobMap = new Map<Id, sked__Job__c>();
        Map<Id, Id> jobAllocationMap = new Map<Id, Id>();
        Map<Id, Set<Id>> scheduleAllocationMap = new Map<Id, Set<Id>>();
        Map<Id, Id> resourceToInstructorMap = new Map<Id, Id>();
        Map<Id, redwing__ILT_Class__c> jobToClassMap = new Map<Id, redwing__ILT_Class__c>();
        Map<Id, sked__Job_Allocation__c> allocationMap = new Map<Id, sked__Job_Allocation__c>();
        Map<Id, Id> jobParentJobMap = new Map<Id, Id>();
        Map<Id, redwing__ILT_Class__c> scheduleToClassMap = new Map<Id, redwing__ILT_Class__c>();

        updateRecords = false;

        for (sked__Job_Allocation__c theAllocation : newRecords) {
            if (!insertedRecords.contains(theAllocation.Id)) {
                newAllocations.add(theAllocation);
                insertedRecords.add(theAllocation.Id);
            }
        }

        if (!newAllocations.isEmpty()) {
            for (sked__Job_Allocation__c theJobAllocation : newAllocations) {
                if (!'Deleted,Declined'.contains(theJobAllocation.sked__Status__c)) {
                    resourceIds.add(theJobAllocation.sked__Resource__c);
                    jobIds.add(theJobAllocation.sked__Job__c);
                    // !! job is one to many on allocation !!
                    jobAllocationMap.put(theJobAllocation.sked__Job__c, theJobAllocation.Id);
                }
            }

            resourceToInstructorMap = getResourceInstructorMap(resourceIds);
            // Add jobs related both to stack (if applicable) or schedule (if applicable)
            jobList = getJobList(jobIds);
            // Map recurring job to existing ILT Class (if applicable)
            scheduleToClassMap = getScheduleToClassMap(jobList);
            // Map all current and related/dependent jobs to existing ILT Class
            jobToClassMap = getJobToClassMap(jobList);

            for (sked__job__c theJob : jobList) {
                jobMap.put(theJob.Id, theJob);
            }

            // Iterate across inserted Job Allocations
            for (sked__Job_Allocation__c theJobAllocation : newAllocations) {
                resourceId = theJobAllocation.sked__Resource__c;
                jobId = theJobAllocation.sked__Job__c;

                // Adjust jobId to parent class (job) for recurring classes (jobs)
                scheduleId = jobMap.get(jobId).sked__Recurring_Schedule__c;
                if (scheduleId != null && scheduleToClassMap.containsKey(scheduleId)) {
                    jobId = scheduleToClassMap.get(scheduleId).Skedulo_Job_Id__c;
                }

                if (resourceId != null && resourceToInstructorMap.containsKey(resourceId) && jobToClassMap.containsKey(jobId)) {
                    // Create new instructor assignment for this class (will use upsert in case this already exists)
                    redwing__ILT_Instructor__c theILTInstructor = new redwing__ILT_Instructor__c();

                    // USxxxx - Instructors are always to be associated to the ILT Class record (rather than ILT Session)
                    // in order to provide support for community pages (session-level assignments don't display instructor in community)
                    // Can only assign an Instructor to a Session **OR** a Class (not both)

                    // The external Id insures that if the same instructor is assigned to multiple sessions
                    // that they are only associated once at the ILT Class level

                    theILTInstructor.Skedulo_Job_Id_External__c = jobId + ':' + resourceId;
                    theILTInstructor.redwing__Instructor__c = resourceToInstructorMap.get(resourceId);
                    theILTInstructor.redwing__ILT_Class__c = jobToClassMap.get(jobId).Id;

                    System.debug('Creating ILTInstructor:' + theILTInstructor);

                    ILTInstructorSet.add(theILTInstructor);

                    // Now loop around related stacked classes to insure instructor is added for these, too
                    for (sked__Job__c theJob : jobList) {
                        if (theJob.Is_Stacked_Class__c && !theJob.Is_Master_Class__c && theJob.sked__Parent__c == jobId) {
                            Id relatedJobId = theJob.Id;

                            if (jobToClassMap.containsKey(relatedJobId)) {
                                theILTInstructor = new redwing__ILT_Instructor__c();

                                theILTInstructor.Skedulo_Job_Id_External__c = relatedJobId + ':' + resourceId;
                                theILTInstructor.redwing__Instructor__c = resourceToInstructorMap.get(resourceId);
                                theILTInstructor.redwing__ILT_Class__c = jobToClassMap.get(relatedJobId).Id;

                                System.debug('Creating related ILTInstructor:' + theILTInstructor);

                                ILTInstructorSet.add(theILTInstructor);
                            }
                        }
                    }
                }
            }
            upsertILTInstructors(ILTInstructorSet);
        }
    }

    public void afterUpdate(List<sked__Job_Allocation__c> newRecords, Map<Id, sked__Job_Allocation__c> oldRecords) {
        List<sked__Job__c> jobList = new List<sked__Job__c>();
        List<sked__Job_Allocation__c> deletedAllocations = new List<sked__Job_Allocation__c>();
        List<sked__Job_Allocation__c> updatedAllocations = new List<sked__Job_Allocation__c>();
        List<sked__Job_Allocation__c> newAllocations = new List<sked__Job_Allocation__c>();

        Set<String> deletedExternalIds = new Set<String>();
        Set<Id> relatedJobIds = new Set<Id>();

        Map<Id, sked__Job_Allocation__c> jobAllocationMap = new Map<Id, sked__Job_Allocation__c>();
        Map<Id, redwing__ILT_Class__c> scheduleToClassMap = new Map<Id, redwing__ILT_Class__c>();
        Map<Id, redwing__ILT_Class__c> jobToClassMap = new Map<Id, redwing__ILT_Class__c>();

        updateRecords = true;

        for (sked__Job_Allocation__c theAllocation : newRecords) {
            if (!updatedRecords.contains(theAllocation.Id)) {
                newAllocations.add(theAllocation);
                updatedRecords.add(theAllocation.Id);
            }
        }

        if (!newAllocations.isEmpty()) {
            for (sked__Job_Allocation__c theAllocation : newAllocations) {
                if (theAllocation.sked__Status__c == 'Deleted') {
                    deletedAllocations.add(theAllocation);
                    jobAllocationMap.put(theAllocation.sked__Job__c, theAllocation);
                    relatedJobIds.add(theAllocation.sked__Job__c);
                } else {
                    updatedAllocations.add(theAllocation);
                }
            }

            // Add jobs related both to stack (if applicable) or schedule (if applicable)
            jobList = getJobList(relatedJobIds);
            // Map recurring job to existing ILT Class (if applicable)
            scheduleToClassMap = getScheduleToClassMap(jobList);
            // Map all current and related/dependent jobs to existing ILT Class
            jobToClassMap = getJobToClassMap(jobList);

            System.debug(jobList);
            System.debug(scheduleToClassMap);

            // Step 1 - Remove deleted instructors from all parent/related ILT class records
            // If recurring, then remove instructor assignment from parent (defined in scheduleToClqssMap)
            // If stacked, then remove from all members of stack (already added to jobList)
            // Note that instructors are never directly assigned to dependent classes in a stack (this is assumed)
            for (sked__Job__c theJob : jobList) {
                Id jobId = theJob.Id;
                if (jobAllocationMap.containsKey(JobId)) {
                    Id allocationId = jobAllocationMap.get(jobId).sked__Resource__c;

                    // If this is a recurring schedule class (job), need to adjust jobId to that of parent (first) class (job)
                    if (theJob.sked__Recurring_Schedule__c != null &&
                            scheduleToClassMap.containsKey(theJob.sked__Recurring_Schedule__c)) {
                        jobId = scheduleToClassMap.get(theJob.sked__Recurring_Schedule__c).Skedulo_Job_Id__c;
                    }

                    deletedExternalIds.add(jobId + ':' + allocationId);

                    // Now loop around related stacked classes to insure instructor is deleted for these, too
                    if (theJob.Is_Stacked_Class__c && theJob.Is_Master_Class__c) {
                        for (sked__Job__c theRelatedJob : jobList) {
                            if (theRelatedJob.Is_Stacked_Class__c && !theRelatedJob.Is_Master_Class__c && theRelatedJob.sked__Parent__c == jobId) {
                                Id relatedJobId = theRelatedJob.Id;

                                if (jobToClassMap.containsKey(relatedJobId)) {
                                    deletedExternalIds.add(relatedJobId + ':' + allocationId);
                                }
                            }
                        }
                    }
                }
            }
            System.debug(deletedExternalIds);

            if (!deletedExternalIds.isEmpty()) {
                deleteILTInstructors(deletedExternalIds);
            }

            afterInsert(updatedAllocations); // Process updated allocations
        }
    }

    public Map<Id, Id> getResourceInstructorMap(Set<Id> resourceIds) {
        Map<Id, Id> resourceToInstructorMap = new Map<Id, Id>();

        if(!resourceIds.isEmpty()){
            for (redwing__Instructor__c instructor : [SELECT Id, Skedulo_Instructor__c, redwing__User__c, Skedulo_Instructor_External__c FROM redwing__Instructor__c WHERE Skedulo_Instructor__c IN :resourceIds]) {
                resourceToInstructorMap.put(instructor.Skedulo_Instructor__c, instructor.redwing__User__c);
            }
            System.debug('resourceToInstructorMap='+resourceToInstructorMap);
        }
        return resourceToInstructorMap;
    }

    public Map<Id, redwing__ILT_Class__c> getJobToClassMap(List<sked__Job__c> jobList) {
        Set<Id> jobIds = new Set<Id>();
        Map<Id, redwing__ILT_Class__c> jobToClassMap = new Map<Id, redwing__ILT_Class__c>();

        for (sked__Job__c theJob : jobList) {
            jobIds.add(theJob.Id);
        }
        if(!jobIds.isEmpty()){
            for (redwing__ILT_Class__c theClass : [SELECT Id, Name, Skedulo_Job_Id__c, Skedulo_Job_Id__r.sked__Recurring_Schedule__c
            FROM redwing__ILT_Class__c
            WHERE Skedulo_Job_Id__c IN :jobIds]) {
                jobToClassMap.put(theClass.Skedulo_Job_Id__c, theClass);
            }
            System.debug('jobToClassMap='+jobToClassMap);
        }
        return jobToClassMap;
    }

    public Map<Id, redwing__ILT_Class__c> getScheduleToClassMap(List<sked__Job__c> jobList) {
        Set<Id> recurringScheduleIds = new Set<Id>();
        Map<Id, redwing__ILT_Class__c> scheduleToClassMap = new Map<Id, redwing__ILT_Class__c>();

        for (sked__Job__c theJob : jobList) {
            if(theJob.sked__Recurring_Schedule__c != null) {
                recurringScheduleIds.add(theJob.sked__Recurring_Schedule__c);
            }
        }

        List<redwing__ILT_Class__c> classList = [SELECT Id, Skedulo_Job_Id__c, Skedulo_Job_Id__r.sked__Recurring_Schedule__c
            FROM redwing__ILT_Class__c
            WHERE Skedulo_Job_Id__r.sked__Recurring_Schedule__c IN :recurringScheduleIds];

        // Retrieve the ILT Class for this recurring schedule.  This design presumes that the class
        // has already been created and is unique to the recurring schedule Id (handled in
        // separate integration (skedToILTClass)).  While all related jobs (sessions) share same
        // recurring schedule Id, there is only one ILT Class record for the entire recurring series.

        if (!classList.isEmpty()) {
            for (redwing__ILT_Class__c theClass : classList) {
                scheduleToClassMap.put(theClass.Skedulo_Job_Id__r.sked__Recurring_Schedule__c, theClass);
            }
        }

        return scheduleToClassMap;
    }

    public void upsertILTInstructors(Set<redwing__ILT_Instructor__c> SetILTInstructor) {
        if(!SetILTInstructor.isEmpty()) {
            System.debug('SetILTInstructor='+SetILTInstructor);
            List<redwing__ILT_Instructor__c> lstILTInstructor = new List<redwing__ILT_Instructor__c>(SetILTInstructor);

            Schema.SObjectField f = redwing__ILT_Instructor__c.fields.Skedulo_Job_Id_External__c;
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
        }
    }

    public void deleteILTInstructors(Set<String> deletedExternalIds) {
        if(!deletedExternalIds.isEmpty()) {
            List<Id> lstILTInstructorIds = new List<Id>();

            List<redwing__ILT_Instructor__c> lstILTInstructors = [SELECT Id, Skedulo_Job_Id_External__c
                    FROM redwing__ILT_Instructor__c
                    WHERE Skedulo_Job_Id_External__c IN :deletedExternalIds];

            for (redwing__ILT_Instructor__c theILTInstructor : lstILTInstructors) {
                lstILTInstructorIds.add(theILTInstructor.Id);
            }
            System.debug('lstILTInstructorIds(delete)='+lstILTInstructorIds);

            Database.DeleteResult[] results = Database.delete(lstILTInstructorIds, false);
            System.debug('Delete ILTinstructor>>>>'+results);

            for(Integer index = 0, size = results.size(); index < size; index++) {
                if(results[index].isSuccess()) {
                    System.debug(lstILTInstructorIds[index] +' was deleted');
                } else {
                    System.debug(lstILTInstructorIds[index] + ' delete failed');
                }
            }
        }
    }

    public List<sked__Job__c> getJobList(Set<Id> jobIds) {
        // Get related job records
        List<sked__Job__c> jobList = [
            SELECT Id, Name, Is_Stacked_Class__c, Is_Master_Class__c, sked__Parent__c, sked__Recurring_Schedule__c
            FROM sked__Job__c
            WHERE Id IN :jobIds
        ];

        // Add dependent (stacked) classes to Job list
        jobList = addDependentStackedClasses(jobList);
        jobList = addRecurringClasses(jobList);

        return jobList;
    }

    public List<sked__Job__c> addDependentStackedClasses(List<sked__Job__c> jobList) {
        // Augment both updated and deleted job Lists as they may contain master classes for stacked classes
        // Workaround: Skedulo only assigns instructors to the master (parent) class in a stacked class.
        // This code block forces the child (dependent) classes to be updated when the master class is updated,
        // resulting in an assignment of an instructor to these dependent classes when an updated allocation
        // is received from Skedulo

        Set<Id> stackedJobIds = new Set<Id>();

        // If this job is a stacked master job, then we need to add all related dependent jobs
        for (sked__Job__c theJob : jobList) {
            if (theJob.Is_Stacked_Class__c && theJob.Is_Master_Class__c) {
                stackedJobIds.add(theJob.Id);
            }
        }

        // Build a query to return all of the dependent classes for each class contained in master job List
        if (!stackedJobIds.isEmpty()) {
            List <sked__Job__c> dependentJobs = [
                SELECT Id, Name, Is_Stacked_Class__c, Is_Master_Class__c, sked__Parent__c, sked__Recurring_Schedule__c
                FROM sked__Job__c
                WHERE Is_Stacked_Class__c = TRUE AND Is_Master_Class__c = FALSE AND sked__Parent__c IN :stackedJobIds
            ];

            if (!dependentJobs.isEmpty()) {
                for (sked__Job__c theDependentJob : dependentJobs) {
                    jobList.add(theDependentJob);
                }
            }
        }
        return jobList;
    }

    public List<sked__Job__c> addRecurringClasses(List<sked__Job__c> jobList) {
        Set<Id> recurringSchedules = new Set<Id>();
        Set<Id> recurringClasses = new Set<Id>();

        for (sked__Job__c theJob : jobList) {
            if (theJob.sked__Recurring_Schedule__c != null) {
                recurringSchedules.add(theJob.sked__Recurring_Schedule__c);
            }
        }

        // Get list of parent classes for recurring jobs (assumes that the ILT Class record represents parent class
        // for this recurring series)
        if (!recurringSchedules.isEmpty()) {
            List<redwing__ILT_Class__c> recurringClassList = [
                    SELECT Id, Skedulo_Job_Id__c, Skedulo_Job_Id__r.sked__Recurring_Schedule__c
                    FROM redwing__ILT_Class__c
                    WHERE Skedulo_Job_Id__r.sked__Recurring_Schedule__c IN :recurringSchedules
            ];

            // Build a query to return all of the parent classes for each class contained in master job List
            if (!recurringClassList.isEmpty()) {
                for (redwing__ILT_Class__c theClass : recurringClassList) {
                    recurringClasses.add(theClass.Skedulo_Job_Id__c);
                }

                if (!recurringClasses.isEmpty()) {
                    List <sked__Job__c> recurringClassJobList = [
                            SELECT Id, Name, Is_Stacked_Class__c, Is_Master_Class__c, sked__Parent__c, sked__Recurring_Schedule__c
                            FROM sked__Job__c
                            WHERE Id IN :recurringClasses
                    ];

                    if (!recurringClassJobList.isEmpty()) {
                        for (sked__Job__c theRecurringClassJob : recurringClassJobList) {
                            jobList.add(theRecurringClassJob);
                        }
                    }
                }
            }
        }

        return jobList;
    }
}