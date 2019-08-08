global class skedJobService {

	public static void insertJobTags(List<sked__Job__c> allJobs, List<string> tagIds) {
		if (tagIds != NULL && !tagIds.isEmpty()) {
            List<sked__Job_Tag__c> skedJobTags = new  List<sked__Job_Tag__c>();
            for (sked__Job__c newJob : allJobs) {
                for (string tagId : tagIds) {
                    sked__Job_Tag__c skedJobTag = new sked__Job_Tag__c(
                        sked__Job__c = newJob.Id,
                        sked__Tag__c = tagId
                    );
                    skedJobTags.add(skedJobTag);
                }
            }
            insert skedJobTags;
        }
	}

    public static void editJobTags(sked__Job__c skedJob, List<string> tagIds) {
        Set<Id> jobIds = new Set<Id>();
        jobIds.add(skedJob.Id);
        editJobTags(jobIds, tagIds);
    }

    public static void editJobTags(List<sked__Job__c> skedJobs, List<string> tagIds) {
        Set<Id> jobIds = new Set<Id>();
        for (sked__Job__c skedJob : skedJobs) {
            jobIds.add(skedJob.Id);
        }
        editJobTags(jobIds, tagIds);
    }

    public static void editJobTags(Set<Id> jobIds, List<string> tagIds) {
        Set<string> setTagIds = new Set<string>();
        setTagIds.addAll(tagIds);

        List<sked__Job__c> skedJobs = [SELECT Id,
                                       (SELECT Id, sked__Tag__c
                                        FROM sked__JobTags__r)
                                       FROM sked__Job__c
                                       WHERE Id IN :jobIds];
        List<sked__Job_Tag__c> skedJobTagsToDelete = new List<sked__Job_Tag__c>();
        List<sked__Job_Tag__c> skedJobTagsInsert = new List<sked__Job_Tag__c>();
        for (sked__Job__c skedJob : skedJobs) {
            Set<string> currentTagIds = new Set<string>();
            for (sked__Job_Tag__c skedJobTag : skedJob.sked__JobTags__r) {
                currentTagIds.add(skedJobTag.sked__Tag__c);
                if (!setTagIds.contains(skedJobTag.sked__Tag__c)) {
                    skedJobTagsToDelete.add(skedJobTag);
                }
            }

            for (string tagId : tagIds) {
                if (!currentTagIds.contains(tagId)) {
                    sked__Job_Tag__c skedJobTag = new sked__Job_Tag__c(
                        sked__Job__c = skedJob.Id,
                        sked__Tag__c = tagId
                    );
                    skedJobTagsInsert.add(skedJobTag);
                }
            }
        }
        if (!skedJobTagsInsert.isEmpty()) {
            insert skedJobTagsInsert;
        }
        if (!skedJobTagsToDelete.isEmpty()) {
            delete skedJobTagsToDelete;
        }
    }

    public static void cancelJobs(List<string> jobIds) {
        List<sked__Job__c> skedJobs = [SELECT Id,
                                       (SELECT Id
                                        FROM sked__Job_Allocations__r
                                        WHERE sked__Status__c != :skedConstants.JOB_ALLOCATION_STATUS_DELETED
                                        AND sked__Status__c != :skedConstants.JOB_ALLOCATION_STATUS_DECLINED)
                                       FROM sked__Job__c
                                       WHERE Id IN :jobIds];
        List<sked__Job_Allocation__c> skedAllocs = new List<sked__Job_Allocation__c>();
        for (sked__Job__c skedJob : skedJobs) {
            skedJob.sked__Job_Status__c = skedConstants.JOB_STATUS_CANCELLED;
            for (sked__Job_Allocation__c skedAlloc : skedJob.sked__Job_Allocations__r) {
                skedAlloc.sked__Status__c = skedConstants.JOB_ALLOCATION_STATUS_DELETED;
                skedAllocs.add(skedAlloc);
            }
        }
        update skedJobs;
        update skedAllocs;
    }

	public static void deleteJobs(List<string> jobIds) {
		List<sked__Job__c> skedJobs = new List<sked__Job__c>();
        for (string jobId : jobIds) {
            sked__Job__c skedJob = new sked__Job__c(
                Id = jobId
            );
            skedJobs.add(skedJob);
        }
        delete skedJobs;
	}

    public static List<skedModels.jobAllocation> rescheduleJob(jobSaveModelBase model, boolean confirm) {
        sked__Job__c skedJob = [SELECT Id, sked__Timezone__c, Before_class_duration__c, After_class_duration__c,
                                (SELECT sked__Job__c, sked__Tag__c, sked__Tag__r.Name
                                 FROM sked__JobTags__r),
                                (SELECT Id, sked__Resource__c, sked__Resource__r.Employment_Type__c
                                 FROM sked__Job_Allocations__r
                                 WHERE sked__Status__c != :skedConstants.JOB_ALLOCATION_STATUS_DELETED)
                                FROM sked__Job__c 
                                WHERE Id = :model.id];
        model.timezoneSidId = skedJob.sked__Timezone__c;
        
        Date selectedDate = skedDateTimeUtils.getDateFromIsoString(model.selectedDate);
        DateTime selectedDateStart = DateTime.newInstance(selectedDate, time.newInstance(0, 0, 0, 0));
        selectedDateStart = skedDateTimeUtils.toTimezone(selectedDateStart, model.timezoneSidId);
            
        integer startTimeInMinutes = skedDateTimeUtils.convertTimeNumberToMinutes(model.startTime);
        DateTime jobStart = skedDateTimeUtils.addMinutes(selectedDateStart, startTimeInMinutes, model.timezoneSidId);
        integer finishTimeInMinutes = skedDateTimeUtils.convertTimeNumberToMinutes(model.finishTime);
        DateTime jobFinish = skedDateTimeUtils.addMinutes(selectedDateStart, finishTimeInMinutes, model.timezoneSidId);
        integer jobDuration = finishTimeInMinutes - startTimeInMinutes;

        List<skedModels.jobAllocation> conflictAllocations = new List<skedModels.jobAllocation>();

        List<skedBaseModels.tag> requiredTags = new List<skedBaseModels.tag>();
        for (string tagId : model.tagIds) {
            skedBaseModels.tag tag = new skedBaseModels.tag();
            tag.id = tagId;
            requiredTags.add(tag);
        }

        skedModels.job job = new skedModels.job();
        job.id = skedJob.Id;
        job.start = jobStart;
        job.finish = jobFinish;
        job.tags = new List<skedBaseModels.tag>();
        job.tags.addAll(requiredTags);

        job.start = skedDateTimeUtils.addMinutes(job.start, -1 * integer.valueOf(skedJob.Before_class_duration__c), model.timezoneSidId);
        job.finish = skedDateTimeUtils.addMinutes(job.finish, integer.valueOf(skedJob.After_class_duration__c), model.timezoneSidId);

        List<skedModels.job> inputJobs = new List<skedModels.job>();
        inputJobs.add(job);

        Set<Id> resourceIds = new Set<Id>();
        for (sked__Job_Allocation__c skedAlloc : skedJob.sked__Job_Allocations__r) {
            if (skedAlloc.sked__Resource__r.Employment_Type__c != skedConstants.RESOURCE_EMPLOYMENT_TYPE_SUBCONTRACTOR) {
                resourceIds.add(skedAlloc.sked__Resource__c);
            }
        }
        Set<Id> excludedJobIds = new Set<Id>();
        excludedJobIds.add(model.id);

        skedAvailatorParams params = new skedAvailatorParams();
        params.timezoneSidId = model.timezoneSidId;
        params.resourceIds = resourceIds;
        params.inputJobs = inputJobs;
        params.excludedJobIds = excludedJobIds;
        
        skedAvailator availator = new skedAvailator(params);
        availator.validateJobs();

        List<skedModels.jobAllocation> allAllocations = availator.getAllAllocations();
        
        if (allAllocations != NULL) {
            for (skedModels.jobAllocation allocation : allAllocations) {
                if (!allocation.isQualified || !allocation.isAvailable) {
                    conflictAllocations.add(allocation);
                }
            }
        }

        boolean isConflict = conflictAllocations.size() > 0;
        if (confirm || !isConflict) {
            sked__Location__c skedLocation = [SELECT Id, sked__Address__c, sked__GeoLocation__Latitude__s, sked__GeoLocation__Longitude__s
                                              FROM sked__Location__c
                                              WHERE Id = :model.facilityId];
            skedJob.sked__Start__c = jobStart;
            skedJob.sked__Finish__c = jobFinish;
            skedJob.sked__Duration__c = jobDuration;
            skedJob.sked__Location__c = model.facilityId;
            skedJob.sked__Address__c = skedLocation.sked__Address__c;
            skedJob.sked__GeoLocation__Latitude__s = skedLocation.sked__GeoLocation__Latitude__s;
            skedJob.sked__GeoLocation__Longitude__s = skedLocation.sked__GeoLocation__Longitude__s;

            update skedJob;

            if (isConflict) {
                List<string> allocationKeys = new List<string>();
                for (skedModels.jobAllocation conflictAllocation : conflictAllocations) {
                    allocationKeys.add(conflictAllocation.jobId + ':' + conflictAllocation.resourceId);
                }

                List<sked__Job_Allocation__c> conflictSkedAllocs = [SELECT Id
                                                                    FROM sked__Job_Allocation__c
                                                                    WHERE sked__UniqueKey__c IN :allocationKeys];
                for (sked__Job_Allocation__c conflictSkedAlloc : conflictSkedAllocs) {
                    conflictSkedAlloc.sked__Status__c = skedConstants.JOB_ALLOCATION_STATUS_DELETED;
                }
                update conflictSkedAllocs;
            }
            Set<Id> jobIdsToUpdateStatus = new Set<Id>();
            jobIdsToUpdateStatus.add(skedJob.Id);
            updateJobStatus(jobIdsToUpdateStatus);

            return new List<skedModels.jobAllocation>();
        }
        else {
            return conflictAllocations;
        }
    }

    public static void updateJobStatus(List<sked__Job__c> skedJobs) {
        Set<Id> jobIds = new Set<Id>();
        for (sked__Job__c skedJob : skedJobs) {
            jobIds.add(skedJob.Id);
        }
        updateJobStatus(jobIds);
    }

    public static void updateJobStatus(Set<Id> jobIds) {
        List<sked__Job__c> skedJobs = [SELECT Id, sked__Job_Allocation_Count__c, sked__Job_Status__c
                                       FROM sked__Job__c 
                                       WHERE Id IN :jobIds];
        List<sked__Job__c> skedJobsToUpdate = new List<sked__Job__c>();
        for (sked__Job__c skedJob : skedJobs) {
            if (skedJob.sked__Job_Allocation_Count__c == 0) {
                skedJob.sked__Job_Status__c = skedConstants.JOB_STATUS_PENDING_ALLOCATION;
                skedJobsToUpdate.add(skedJob);
            }
            else if (skedJob.sked__Job_Allocation_Count__c > 0 && skedJob.sked__Job_Status__c == skedConstants.JOB_STATUS_PENDING_ALLOCATION) {
                skedJob.sked__Job_Status__c = skedConstants.JOB_STATUS_PENDING_DISPATCH;
                skedJobsToUpdate.add(skedJob);
            }
        }
        if (!skedJobsToUpdate.isEmpty()) {
            update skedJobsToUpdate;
        }
        if (!skedJobsToUpdate.isEmpty()) {
            update skedJobsToUpdate;
        }
    }

    public virtual class jobSaveModelBase {
        public string id {get;set;}
        public string regionId {get;set;}
        public string specialInstructions {get;set;}
        public List<string> tagIds {get;set;}
        public string facilityId {get;set;}
        
        public string selectedDate {get;set;}
        public integer startTime {get;set;}
        public integer finishTime {get;set;}
        public integer beforeClassDuration {get;set;}
        public integer afterClassDuration {get;set;}
        
        public transient string timezoneSidId {get;set;}

        public boolean isRescheduling(sked__Job__c skedJob) {
            boolean isRescheduling = false;
            if (!string.isBlank(this.id)) {
                sked__Job__c currentSkedJob = [SELECT Id, sked__Start__c, sked__Finish__c, sked__Address__c,
                                               (SELECT sked__Job__c, sked__Tag__c, sked__Tag__r.Name
                                                FROM sked__JobTags__r)
                                               FROM sked__Job__c
                                               WHERE Id = :this.id];
                if (skedJob.sked__Start__c != currentSkedJob.sked__Start__c 
                    || skedJob.sked__Finish__c != currentSkedJob.sked__Finish__c
                    || skedJob.sked__Address__c != currentSkedJob.sked__Address__c) {
                    isRescheduling = true;
                }
                if (isRescheduling == false) {
                    Set<string> currentTagIds = new Set<string>();
                    for (sked__Job_Tag__c skedJobTag : currentSkedJob.sked__JobTags__r) {
                        currentTagIds.add(skedJobTag.sked__Tag__c);
                    }

                    isRescheduling = currentTagIds.size() != this.tagIds.size() || !currentTagIds.containsAll(this.tagIds);
                }
            }
            return isRescheduling;
        }
    }

}