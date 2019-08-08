global class skedCommunitySchedulingController {

	@remoteAction
    global static skedRemoteResultModel getCSCConfigData() {
    	skedRemoteResultModel result = new skedRemoteResultModel();
        try {
    		configDataModel configData = new configDataModel();
            configData.regions = skedUtils.getRegions();
            configData.courseCatalogs = skedARCUtils.getCourseCatalogs(skedConstants.COURSE_CATALOG_TYPE_COMMUNITY);
            configData.tags = skedUtils.getTags();
            configData.jobStatusSettings = skedUtils.getJobStatusSettings();
            configData.mapHolidays = skedDateTimeUtils.getHolidayOptions();
            configData.userPermission = getUserPermissions();
            configData.communityClassSubTypes = skedUtils.getPickListValues('sked__Job__c', 'Class_Sub_Type__c');

            result.data = configData;
		}
        catch (Exception ex) {
            result.getError(ex);
        }
        return result;
    }

    @remoteAction
    global static skedRemoteResultModel getFacilityList(facilityQueryModel queryModel) {
    	skedRemoteResultModel result = new skedRemoteResultModel();
        try {
        	sked__Region__c skedRegion = [SELECT Id, sked__Timezone__c FROM sked__Region__c 
        								  WHERE Id = :queryModel.regionId];
        	string timezoneSidId = skedRegion.sked__Timezone__c;

        	Date startDate = skedDateTimeUtils.getDateFromIsoString(queryModel.startDateIso);
        	DateTime startTime = skedDateTimeUtils.getStartOfDate(startDate, timezoneSidId);

        	Date endDate = skedDateTimeUtils.getDateFromIsoString(queryModel.endDateIso);
        	DateTime endTime = skedDateTimeUtils.getEndOfDate(endDate, timezoneSidId);

            Date monthStartDate = startDate.toStartOfMonth();

        	List<sked__Location__c> skedLocations = [SELECT Id, Name, Facility_ID__c, Notes__c,
                                                     sked__Region__c, sked__Address__c,
                                                     sked__GeoLocation__Latitude__s, sked__GeoLocation__Longitude__s,
        											 (SELECT Id, Name, sked__Region__c, sked__Address__c, sked__Contact__c, sked__Recurring_Schedule__c,
			                                          sked__GeoLocation__Latitude__s, sked__GeoLocation__Longitude__s, sked__GeoLocation__c,
			                                          sked__Timezone__c, sked__Start__c, sked__Finish__c, sked__Duration__c, sked__Type__c, 
                                                      sked__Job_Status__c, Copy_Result_Message__c, Number_of_Instructors__c, Location_Confirmed__c,
                                                      sked__Location__c, Course_Catalog__c, Course_Catalog__r.Name,
                                                      Break_Duration__c, Number_of_Breaks__c, Special_Instructions__c,
                                                      Is_Queued__c, Is_Previously_Cancelled__c, sked__Job_Allocation_Count__c, Number_of_Students__c,
                                                      Before_class_duration__c, After_class_duration__c, ClasS_Sub_Type__c,
                                                      Remaining_Resources_to_be_Allocated__c, Course_Code__c, Display_Order__c, sked__Parent__c, 
                                                      Is_Stacked_Class__c, Is_Master_Class__c
        											  FROM sked__Jobs__r
        											  WHERE (Job_Month__c = :monthStartDate OR (sked__Start__c < :endTime AND sked__Finish__c > :startTime))
        											  AND sked__Type__c = :skedConstants.JOB_TYPE_COMMUNITY
                                                      AND (Is_Stacked_Class__c = FALSE OR Is_Master_Class__c = TRUE))
        											 FROM sked__Location__c
        											 WHERE sked__Region__c = :queryModel.regionId
                                                     AND (sked__Type__c = :skedConstants.LOCATION_TYPE_COMMUNITY
                                                     	  OR sked__Type__c = :skedConstants.LOCATION_TYPE_COMMUNITY_TEMP
                                                          OR sked__Type__c = :skedConstants.LOCATION_TYPE_INTERNAL
                                                          OR sked__Type__c = :skedConstants.LOCATION_TYPE_NAT_AND_COMMUNITY)
                                                     AND Is_Active__c = TRUE
        											 ORDER BY Name ASC];
		    Map<Id, jobModel> mapJob = new Map<Id, jobModel>();
            List<facilityModel> facilityList = new List<facilityModel>();
        	for (sked__Location__c skedLocation : skedLocations) {
        		facilityModel facility = new facilityModel(skedLocation);

        		for (sked__Job__c skedJob : skedLocation.sked__Jobs__r) {
        			jobModel job = new jobModel(skedJob);
                    job.allocations = new List<skedModels.jobAllocation>();
        			facility.jobs.add(job);
                    mapJob.put(job.id, job);
        		}
        		facilityList.add(facility);
        	}

            List<sked__Job__c> skedSubClasses = [SELECT Id, Name, sked__Region__c, sked__Address__c, sked__Contact__c, sked__Recurring_Schedule__c,
                                                 sked__GeoLocation__Latitude__s, sked__GeoLocation__Longitude__s, sked__GeoLocation__c,
                                                 sked__Timezone__c, sked__Start__c, sked__Finish__c, sked__Duration__c, sked__Type__c, 
                                                 sked__Job_Status__c, Copy_Result_Message__c, Number_of_Instructors__c, Location_Confirmed__c,
                                                 sked__Location__c, Course_Catalog__c, Course_Catalog__r.Name,
                                                 Break_Duration__c, Number_of_Breaks__c, Special_Instructions__c,
                                                 Is_Queued__c, Is_Previously_Cancelled__c, sked__Job_Allocation_Count__c, Number_of_Students__c,
                                                 Before_class_duration__c, After_class_duration__c, ClasS_Sub_Type__c,
                                                 Remaining_Resources_to_be_Allocated__c, Course_Code__c, Display_Order__c, sked__Parent__c, 
                                                 Is_Stacked_Class__c, Is_Master_Class__c
                                                 FROM sked__Job__c
                                                 WHERE sked__Parent__c IN :mapJob.keySet()
                                                 AND sked__Job_Status__c != :skedConstants.JOB_STATUS_CANCELLED
                                                 ORDER BY sked__Start__c ASC];
            for (sked__Job__c skedSubClass : skedSubClasses) {
                jobModel job = mapJob.get(skedSubClass.sked__Parent__c);
                jobModel subclass = new jobModel(skedSubClass);
                if (job.subclasses == NULL) {
                    job.subclasses = new List<jobModel>();
                }
                job.subclasses.add(subclass);
            }

            List<Offering__c> skedOfferings = [SELECT Id, Name, Job__c
                                               FROM Offering__c
                                               WHERE Job__c IN :mapJob.keySet()];
            for (Offering__c skedOffering : skedOfferings) {
                offeringModel offering = new offeringModel(skedOffering);
                jobModel job = mapJob.get(skedOffering.Job__c);
                job.offerings.add(offering);
            }

            List<sked__Job_Allocation__c> skedAllocations = [SELECT Id, sked__Job__c, sked__Status__c, 
                                                             sked__Resource__c, sked__Resource__r.Name, sked__Resource__r.sked__Category__c
                                                             FROM sked__Job_Allocation__c
                                                             WHERE sked__Job__c IN :mapJob.keySet()
                                                             AND sked__Status__c != :skedConstants.JOB_ALLOCATION_STATUS_DELETED];
            for (sked__Job_Allocation__c skedAllocation : skedAllocations) {
                skedModels.jobAllocation allocation = new skedModels.jobAllocation();
                allocation.status = skedAllocation.sked__Status__c;

                skedModels.resource resource = new skedModels.resource();
                resource.name = skedAllocation.sked__Resource__r.Name;
                resource.category = skedAllocation.sked__Resource__r.sked__Category__c;
                allocation.resource = resource;

                jobModel job = mapJob.get(skedAllocation.sked__Job__c);
                job.allocations.add(allocation);
            }                                                 
        	result.data = facilityList;
    	}
        catch (Exception ex) {
            result.getError(ex);
        }
        return result;
    }

    @remoteAction
    global static skedRemoteResultModel copyClassPattern(string sourceDateIso, string destinationDateIso, string regionId, boolean isIncludingSubclasses) {
        skedRemoteResultModel result = new skedRemoteResultModel();
        SavePoint sp = Database.setSavePoint();
        try {
            sked__Region__c skedRegion = [SELECT Id, sked__Timezone__c FROM sked__Region__c WHERE Id = :regionId];
            string timezoneSidId = skedRegion.sked__Timezone__c;
            integer defaultBeforeDuration = 30;
            integer defaultAfterDuration = 30;

            Date selectedSourceDate = skedDateTimeUtils.getDateFromIsoString(sourceDateIso);
            Date sourceStartDate = selectedSourceDate.toStartOfMonth();
            DateTime sourceStartTime = skedDateTimeUtils.getStartOfDate(sourceStartDate, timezoneSidId);
            DateTime sourceEndTime = skedDateTimeUtils.addMonths(sourceStartTime, 1, timezoneSidId);

            Date selectedDestinationDate = skedDateTimeUtils.getDateFromIsoString(destinationDateIso);
            Date destinationStartDate = selectedDestinationDate.toStartOfMonth();
            DateTime destinationStartTime = skedDateTimeUtils.getStartOfDate(destinationStartDate, timezoneSidId);
            DateTime destinationEndTime = skedDateTimeUtils.addMonths(destinationStartTime, 1, timezoneSidId);

            List<sked__Job__c> sourceJobs = [SELECT Id, Name, sked__Region__c, sked__Address__c, sked__Contact__c, sked__Recurring_Schedule__c,
                                             sked__GeoLocation__Latitude__s, sked__GeoLocation__Longitude__s, sked__GeoLocation__c,
                                             sked__Timezone__c, sked__Start__c, sked__Finish__c, sked__Duration__c, sked__Type__c, 
                                             sked__Job_Status__c, sked__Location__c, Course_Catalog__c, Course_Catalog__r.Name,
                                             Number_of_Instructors__c, Break_Duration__c, Number_of_Breaks__c, 
                                             Special_Instructions__c, Number_of_Students__c, Before_class_duration__c,
                                             After_class_duration__c, ClasS_Sub_Type__c, sked__Description__c, Course_Code__c, Display_Order__c,
                                             sked__Parent__c, Is_Stacked_Class__c, Is_Master_Class__c,
                                             (SELECT sked__Job__c, sked__Tag__c, sked__Tag__r.Name
                                              FROM sked__JobTags__r),
                                             (SELECT Id, Name, sked__Region__c, sked__Address__c, sked__Contact__c, sked__Recurring_Schedule__c,
                                              sked__GeoLocation__Latitude__s, sked__GeoLocation__Longitude__s, sked__GeoLocation__c,
                                              sked__Timezone__c, sked__Start__c, sked__Finish__c, sked__Duration__c, sked__Type__c, 
                                              sked__Job_Status__c, Copy_Result_Message__c, Number_of_Instructors__c, Location_Confirmed__c,
                                              sked__Location__c, Course_Catalog__c, Course_Catalog__r.Name, 
                                              Break_Duration__c, Number_of_Breaks__c, Number_of_Students__c,
                                              Special_Instructions__c, Is_Queued__c, Is_Previously_Cancelled__c, sked__Job_Allocation_Count__c,
                                              Before_class_duration__c, After_class_duration__c, ClasS_Sub_Type__c,
                                              Remaining_Resources_to_be_Allocated__c, Course_Code__c, Display_Order__c, sked__Parent__c, 
                                              Is_Stacked_Class__c, Is_Master_Class__c
                                              FROM sked__Followups__r
                                              WHERE sked__Job_Status__c != :skedConstants.JOB_STATUS_CANCELLED
                                              ORDER BY sked__Start__c ASC)
                                             FROM sked__Job__c
                                             WHERE sked__Region__c = :regionId
                                             AND sked__Type__c = :skedConstants.JOB_TYPE_COMMUNITY
                                             AND (ClasS_Sub_Type__c = :skedConstants.COMMUNITY_CLASS_SUB_TYPE_BASE
                                                  OR ClasS_Sub_Type__c = :skedConstants.COMMUNITY_CLASS_SUB_TYPE_BASE_ADD_ON)
                                             AND sked__Start__c < :sourceEndTime
                                             AND sked__Finish__c > :sourceStartTime
                                             AND Is_Queued__c = FALSE
                                             AND (Is_Stacked_Class__c = FALSE OR Is_Master_Class__c = TRUE)
                                             AND sked__Location__r.sked__Type__c != :skedConstants.LOCATION_TYPE_INTERNAL
                                             ORDER BY sked__Start__c ASC];
            if (sourceJobs.isEmpty()) {
                return result;
            }
            Set<Id> sourceScheduleIds = new Set<Id>();
            Set<Id> sourceCourseCatalogIds = new Set<Id>();
            for (sked__Job__c sourceJob : sourceJobs) {
                if (sourceJob.sked__Recurring_Schedule__c != NULL) {
                    sourceScheduleIds.add(sourceJob.sked__Recurring_Schedule__c);
                }
                sourceCourseCatalogIds.add(sourceJob.Course_Catalog__c);
            }
            Map<Id, Course_Catalog__c> mapSourceCourseCatalog 
                = new Map<Id, Course_Catalog__c>([SELECT Id, Number_of_Students__c, Number_of_Instructors__c, 
                                                  Break_Duration__c, Number_of_Breaks__c,
                                                  (SELECT Tag__c, Tag__r.Name
                                                   FROM Course_Catalog_Tags__r)
                                                  FROM Course_Catalog__c
                                                  WHERE Id IN :sourceCourseCatalogIds]);

            //find recurring schedules which were within the source month
            Map<Id, sked__Recurring_Schedule__c> mapEligibleSchedule = new Map<Id, sked__Recurring_Schedule__c>();
            if (!sourceScheduleIds.isEmpty()) {
                List<sked__Recurring_Schedule__c> sourceSchedules = [SELECT Id, Frequency__c, Pattern__c, sked__Summary__c,
                                                                     (SELECT Id, sked__Start__c, sked__Finish__c
                                                                      FROM sked__Jobs__r
                                                                      ORDER BY sked__Start__c ASC)
                                                                     FROM sked__Recurring_Schedule__c
                                                                     WHERE Id IN :sourceScheduleIds];
                for (sked__Recurring_Schedule__c sourceSchedule : sourceSchedules) {
                    if (sourceSchedule.sked__Jobs__r != NULL && !sourceSchedule.sked__Jobs__r.isEmpty()) {
                        sked__Job__c firstJob = sourceSchedule.sked__Jobs__r.get(0);
                        sked__Job__c lastJob = sourceSchedule.sked__Jobs__r.get(sourceSchedule.sked__Jobs__r.size() - 1);
                        if (sourceStartTime > firstJob.sked__Start__c || lastJob.sked__Finish__c >= sourceEndTime) {
                            continue;
                        }
                        mapEligibleSchedule.put(sourceSchedule.Id, sourceSchedule);
                    }
                }
            }
            Set<Id> eligibleScheduleIds = mapEligibleSchedule.keySet();

            Map<Id, sked__Recurring_Schedule__c> map_sourceId_copiedSchedules = new Map<Id, sked__Recurring_Schedule__c>();
            for (sked__Recurring_Schedule__c sourceSchedule : mapEligibleSchedule.values()) {
                sked__Recurring_Schedule__c copiedSchedule = sourceSchedule.clone();
                map_sourceId_copiedSchedules.put(sourceSchedule.Id, copiedSchedule);
            }
            insert map_sourceId_copiedSchedules.values();

            //do copying 
            Set<string> sourceMonth_firstWeek_days = new Set<string>();
            DateTime tempDt = sourceStartTime;
            DateTime tempDtEnd = skedDateTimeUtils.addDays(tempDt, 7, timezoneSidId);
            while (tempDt < tempDtEnd) {
                string weekday = tempDt.format('EEE', timezoneSidId);
                if (tempDt != sourceStartTime && weekday == 'Sun') {
                    break;
                }
                sourceMonth_firstWeek_days.add(weekday);
                tempDt = skedDateTimeUtils.addDays(tempDt, 1, timezoneSidId);
            }
            sked__Job__c firstSourceJob = sourceJobs.get(0);

            string firstSourceJob_weekday = firstSourceJob.sked__Start__c.format('EEE', timezoneSidId);
            integer firstSourceJob_nthWeekday = integer.valueOf(firstSourceJob.sked__Start__c.format('W', timezoneSidId));
            if (!sourceMonth_firstWeek_days.contains(firstSourceJob_weekday)) {
                firstSourceJob_nthWeekday = firstSourceJob_nthWeekday - 1;
            }

            tempDt = destinationStartTime;
            string tempWeekday = tempDt.format('EEE', timezoneSidId);
            while (tempWeekday != firstSourceJob_weekday) {
                tempDt = skedDateTimeUtils.addDays(tempDt, 1, timezoneSidId);
                tempWeekday = tempDt.format('EEE', timezoneSidId);
            }
            DateTime firstDestinationJob_DateStart = skedDateTimeUtils.addDays(tempDt, 7 * (firstSourceJob_nthWeekday - 1), timezoneSidId);
            Date firstDestinationJobDate = skedDateTimeUtils.getDate(firstDestinationJob_DateStart, timezoneSidId);
            Date firstSourceJobDate = skedDateTimeUtils.getDate(firstSourceJob.sked__Start__c, timezoneSidId);

            integer daysDifferent = firstSourceJobDate.daysBetween(firstDestinationJobDate);

            List<sked__Job__c> copiedJobs = new List<sked__Job__c>();
            for (sked__Job__c sourceJob : sourceJobs) {
                if (sourceJob.sked__Recurring_Schedule__c != NULL && !eligibleScheduleIds.contains(sourceJob.sked__Recurring_Schedule__c)) {
                    continue;
                }

                Course_Catalog__c skedCourseCatalog = mapSourceCourseCatalog.get(sourceJob.Course_Catalog__c);

                sked__Job__c copiedJob = sourceJob.clone();
                copiedJob.Source_Job__c = sourceJob.Id;
                copiedJob.sked__Can_Be_Declined__c = FALSE;
                copiedJob.Job_Month__c = destinationStartDate;
                copiedJob.sked__Job_Status__c = skedConstants.JOB_STATUS_QUEUED;
                copiedJob.Is_Queued__c = TRUE;
                copiedJob.Is_Previously_Cancelled__c = sourceJob.sked__Job_Status__c == skedConstants.JOB_STATUS_CANCELLED;
                copiedJob.sked__Start__c = skedDateTimeUtils.addDays(copiedJob.sked__Start__c, daysDifferent, timezoneSidId);
                copiedJob.sked__Finish__c = skedDateTimeUtils.addDays(copiedJob.sked__Finish__c, daysDifferent, timezoneSidId);
                if (copiedJob.Before_class_duration__c == NULL || copiedJob.Before_class_duration__c == 0) {
                    copiedJob.Before_class_duration__c = defaultBeforeDuration;
                }
                if (copiedJob.After_class_duration__c == NULL || copiedJob.After_class_duration__c == 0) {
                    copiedJob.After_class_duration__c = defaultAfterDuration;
                }
                if (skedCourseCatalog != NULL) {
                    copiedJob.Break_Duration__c = skedCourseCatalog.Break_Duration__c;
                    copiedJob.Number_of_Breaks__c = skedCourseCatalog.Number_of_Breaks__c;
                    copiedJob.Number_of_Instructors__c = skedCourseCatalog.Number_of_Instructors__c;
                    copiedJob.Number_of_Students__c = skedCourseCatalog.Number_of_Students__c;
                }
                if (destinationEndTime <= copiedJob.sked__Finish__c) {
                    copiedJob.Copy_Result_Message__c = skedConstants.COMMUNITY_COPY_OUT_OF_MONTH;
                }

                if (sourceJob.sked__Recurring_Schedule__c != NULL) {
                    sked__Recurring_Schedule__c copiedSchedule = map_sourceId_copiedSchedules.get(sourceJob.sked__Recurring_Schedule__c);
                    copiedJob.sked__Recurring_Schedule__c = copiedSchedule.Id;
                }

                copiedJobs.add(copiedJob);
            }

            if (!copiedJobs.isEmpty()) {
                insert copiedJobs;

                Map<Id, sked__Job__c> mapSourceJob = new Map<Id, sked__Job__c>(sourceJobs);
                if (isIncludingSubclasses == TRUE) {
                    List<sked__Job__c> subClasses = new List<sked__Job__c>();
                    for (sked__Job__c copiedJob : copiedJobs) {
                        sked__Job__c sourceJob = mapSourceJob.get(copiedJob.Source_Job__c);
                        if (sourceJob.Is_Stacked_Class__c == TRUE && sourceJob.sked__Followups__r != NULL) {
                            for (sked__Job__c sourceSubClass : sourceJob.sked__Followups__r) {
                                sked__Job__c subClass = sourceSubClass.clone();
                                subClass.sked__Parent__c = copiedJob.Id;
                                subClass.sked__Start__c = skedDateTimeUtils.addDays(subClass.sked__Start__c, daysDifferent, timezoneSidId);
                                subClass.sked__Finish__c = skedDateTimeUtils.addDays(subClass.sked__Finish__c, daysDifferent, timezoneSidId);
                                subClass.sked__Job_Status__c = skedConstants.JOB_STATUS_QUEUED;
                                subClass.sked__Recurring_Schedule__c = NULL;
                                subClasses.add(subClass);
                            }
                        }
                    }
                    if (!subClasses.isEmpty()) {
                        insert subClasses;
                    }
                }

                List<sked__Job_Tag__c> copiedJobTags = new List<sked__Job_Tag__c>();
                for (sked__Job__c copiedJob : copiedJobs) {
                    Course_Catalog__c skedCourseCatalog = mapSourceCourseCatalog.get(copiedJob.Course_Catalog__c);

                    for (Course_Catalog_Tag__c courseCatalogTag : skedCourseCatalog.Course_Catalog_Tags__r) {
                        sked__Job_Tag__c copiedJobTag = new sked__Job_Tag__c(
                            sked__Job__c = copiedJob.Id,
                            sked__Tag__c = courseCatalogTag.Tag__c
                        );
                        copiedJobTags.add(copiedJobTag);
                    }
                }
                if (!copiedJobTags.isEmpty()) {
                    insert copiedJobTags;
                }
            }

            validateQueuedJobs(regionId, copiedJobs);
        }
        catch (Exception ex) {
            result.getError(ex);
            Database.rollback(sp);
        }
        return result;
    }

    @remoteAction
    global static skedRemoteResultModel getJobDetails(string jobId) {
        skedRemoteResultModel result = new skedRemoteResultModel();
        try {
            sked__Job__c skedJob = [SELECT Id, Name, sked__Region__c, sked__Address__c, sked__Contact__c, sked__Recurring_Schedule__c,
                                    sked__GeoLocation__Latitude__s, sked__GeoLocation__Longitude__s, sked__GeoLocation__c,
                                    sked__Timezone__c, sked__Start__c, sked__Finish__c, sked__Duration__c, sked__Type__c, 
                                    sked__Job_Status__c, Copy_Result_Message__c, Number_of_Instructors__c, Location_Confirmed__c,
                                    sked__Location__c, Course_Catalog__c, Course_Catalog__r.Name, 
                                    Break_Duration__c, Number_of_Breaks__c, Number_of_Students__c,
                                    Special_Instructions__c, Is_Queued__c, Is_Previously_Cancelled__c, sked__Job_Allocation_Count__c,
                                    Before_class_duration__c, After_class_duration__c, ClasS_Sub_Type__c,
                                    Remaining_Resources_to_be_Allocated__c, Course_Code__c, Display_Order__c, sked__Parent__c, Is_Stacked_Class__c,
                                    Is_Master_Class__c,
                                    (SELECT sked__Job__c, sked__Tag__c, sked__Tag__r.Name
                                     FROM sked__JobTags__r),
                                    (SELECT Id, Name, sked__Region__c, sked__Address__c, sked__Contact__c, sked__Recurring_Schedule__c,
                                     sked__GeoLocation__Latitude__s, sked__GeoLocation__Longitude__s, sked__GeoLocation__c,
                                     sked__Timezone__c, sked__Start__c, sked__Finish__c, sked__Duration__c, sked__Type__c, 
                                     sked__Job_Status__c, Copy_Result_Message__c, Number_of_Instructors__c, Location_Confirmed__c,
                                     sked__Location__c, Course_Catalog__c, Course_Catalog__r.Name, 
                                     Break_Duration__c, Number_of_Breaks__c, Number_of_Students__c,
                                     Special_Instructions__c, Is_Queued__c, Is_Previously_Cancelled__c, sked__Job_Allocation_Count__c,
                                     Before_class_duration__c, After_class_duration__c, ClasS_Sub_Type__c,
                                     Remaining_Resources_to_be_Allocated__c, Course_Code__c, Display_Order__c, sked__Parent__c, Is_Stacked_Class__c,
                                     Is_Master_Class__c
                                     FROM sked__Followups__r
                                     WHERE sked__Job_Status__c != :skedConstants.JOB_STATUS_CANCELLED
                                     ORDER BY sked__Start__c ASC)
                                    FROM sked__Job__c
                                    WHERE Id = :jobId];
            List<Offering__c> skedOfferings = [SELECT Id, Name, Job__c
                                               FROM Offering__c
                                               WHERE Job__c = :skedJob.Id];
            jobModel job = new jobModel(skedJob);
            job.loadJobTags(skedJob.sked__JobTags__r);

            if (skedJob.sked__Followups__r != NULL && !skedJob.sked__Followups__r.isEmpty()) {
                job.subclasses = new List<jobModel>();
                for (sked__Job__c skedSubclass : skedJob.sked__Followups__r) {
                    jobModel subclass = new jobModel(skedSubclass);
                    job.subclasses.add(subclass); 
                }
            }

            List<offeringModel> offerings = new List<offeringModel>();
            for (Offering__c skedOffering : skedOfferings) {
                offeringModel offering = new offeringModel(skedOffering);
                offerings.add(offering);
            }
            job.offerings = offerings;

            result.data = job;
        }
        catch (Exception ex) {
            result.getError(ex);
        }
        return result;
    }

    @remoteAction
    global static skedRemoteResultModel saveJob(jobSaveModel model, boolean confirm) {
        skedRemoteResultModel result = new skedRemoteResultModel();
        SavePoint sp = Database.setSavePoint();
        try {
            sked__Region__c skedRegion = [SELECT Id, sked__Timezone__c FROM sked__Region__c 
                                          WHERE Id = :model.regionId];
            sked__Location__c skedLocation = [SELECT Id, sked__Address__c, sked__GeoLocation__Latitude__s, sked__GeoLocation__Longitude__s
                                              FROM sked__Location__c
                                              WHERE Id = :model.facilityId];
            model.timezoneSidId = skedRegion.sked__Timezone__c;
            
            Date selectedDate = skedDateTimeUtils.getDateFromIsoString(model.selectedDate);
            DateTime selectedDateStart = DateTime.newInstance(selectedDate, time.newInstance(0, 0, 0, 0));
            selectedDateStart = skedDateTimeUtils.toTimezone(selectedDateStart, model.timezoneSidId);
                
            integer startTimeInMinutes = skedDateTimeUtils.convertTimeNumberToMinutes(model.startTime);
            DateTime jobStart = skedDateTimeUtils.addMinutes(selectedDateStart, startTimeInMinutes, model.timezoneSidId);
            integer finishTimeInMinutes = skedDateTimeUtils.convertTimeNumberToMinutes(model.finishTime);
            DateTime jobFinish = skedDateTimeUtils.addMinutes(selectedDateStart, finishTimeInMinutes, model.timezoneSidId);
            integer jobDuration = finishTimeInMinutes - startTimeInMinutes;

            Course_Catalog__c courseCatalog = [SELECT Id, Name
                                               FROM Course_Catalog__c
                                               WHERE Id = :model.courseCatalogId];
            
            sked__Job__c skedJob = new sked__Job__c(
                sked__Region__c = model.regionId,
                sked__Description__c = courseCatalog.Name,
                sked__Start__c = jobStart,
                sked__Finish__c = jobFinish,
                sked__Duration__c = jobDuration,
                sked__Type__c = skedConstants.JOB_TYPE_COMMUNITY,
                sked__Location__c = model.facilityId,
                sked__Address__c = skedLocation.sked__Address__c,
                sked__GeoLocation__Latitude__s = skedLocation.sked__GeoLocation__Latitude__s,
                sked__GeoLocation__Longitude__s = skedLocation.sked__GeoLocation__Longitude__s,
                Course_Catalog__c = model.courseCatalogId,
                Break_Duration__c = model.breakDuration,
                Number_of_Breaks__c = model.numberOfBreaks,
                Number_of_Instructors__c = model.numberOfInstructors,
                Number_of_Students__c = model.numberOfStudents,
                Special_Instructions__c = model.specialInstructions,
                Location_Confirmed__c = model.locationConfirmed,
                Before_class_duration__c = model.beforeClassDuration,
                After_class_duration__c = model.afterClassDuration,
                ClasS_Sub_Type__c = model.communityClassSubType,
                Course_Code__c = model.courseCode,
                Is_Stacked_Class__c = model.isStackedClass,
                Is_Master_Class__c = model.isStackedClass
            );

            boolean isRescheduling = model.isRescheduling(skedJob);
            if (isRescheduling) {
                List<skedModels.jobAllocation> conflictAllocations = skedJobService.rescheduleJob(model, confirm);
                if (!conflictAllocations.isEmpty()) {
                    result.data = conflictAllocations;
                    return result;
                }
            }
            
            List<sked__Job__c> allJobs = new List<sked__Job__c>();
            allJobs.add(skedJob);
            if (string.isBlank(model.id)) {
                skedJob.sked__Job_Status__c = skedConstants.JOB_STATUS_PENDING_ALLOCATION;
                skedJob.sked__Can_Be_Declined__c = FALSE;
                
                
                if (model.isRecurring) {
                    sked__Recurring_Schedule__c schedule = prepareScheduleData(model);
                    insert schedule;

                    skedJob.sked__Recurring_Schedule__c = schedule.Id;

                    List<sked__Job__c> recurringJobs = processRecurring(skedJob, model);
                    allJobs.addAll(recurringJobs);
                }

                insert allJobs;

                skedJobService.insertJobTags(allJobs, model.tagIds);

                if (model.offerings != NULL && !model.offerings.isEmpty()) {
                    List<Offering__c> skedOfferings = new List<Offering__c>();
                    for (sked__Job__c newJob : allJobs) {
                        for (offeringModel offering : model.offerings) {
                            Offering__c skedOffering = new Offering__c(
                                Job__c = newJob.Id,
                                Name = offering.name
                            );
                            skedOfferings.add(skedOffering);
                        }
                    }
                    insert skedOfferings;
                }
            }
            else {
                skedJob.Id = model.id;
                update skedJob;

                skedJobService.editJobTags(skedJob, model.tagIds);

                if (model.offerings != NULL && !model.offerings.isEmpty()) {
                    List<Offering__c> skedOfferingsToUpsert = new List<Offering__c>();
                    List<Offering__c> skedOfferingsToDelete = new List<Offering__c>();

                    for (offeringModel offering : model.offerings) {
                        if (string.isBlank(offering.id)) {
                            Offering__c skedOffering = new Offering__c(
                                Job__c = skedJob.Id,
                                Name = offering.name
                            );
                            skedOfferingsToUpsert.add(skedOffering);
                        }
                        else {
                            if (offering.isDeleted) {
                                Offering__c skedOffering = new Offering__c(
                                    Id = offering.id
                                );
                                skedOfferingsToDelete.add(skedOffering);
                            }
                            else if (offering.isChanged) {
                                Offering__c skedOffering = new Offering__c(
                                    Id = offering.id,
                                    Name = offering.name
                                );
                                skedOfferingsToUpsert.add(skedOffering);   
                            }
                        }
                    }
                    if (!skedOfferingsToUpsert.isEmpty()) {
                        upsert skedOfferingsToUpsert;
                    }
                    if (!skedOfferingsToDelete.isEmpty()) {
                        delete skedOfferingsToDelete;
                    }
                }
            }

            if (model.isStackedClass == TRUE) {
                List<sked__Job__c> skedSubclasses = new List<sked__Job__c>();
                for (sked__Job__c masterJob : allJobs) {
                    DateTime jobDateStart = skedDateTimeUtils.getStartOfDate(masterJob.sked__Start__c, model.timezoneSidId);
                    for (jobModel subclass : model.subclasses) {
                        sked__Job__c skedSubclass;
                        if (subclass.action == 'delete') {
                            skedSubclass = new sked__Job__c(
                                Id = subclass.id,
                                sked__Job_Status__c = skedConstants.JOB_STATUS_CANCELLED
                            );
                        }
                        else {
                            integer subclassStartMinutes = skedDateTimeUtils.convertTimeNumberToMinutes(subclass.startTime);
                            DateTime subclassStart = skedDateTimeUtils.addMinutes(jobDateStart, subclassStartMinutes, model.timezoneSidId);
                            DateTime subclassFinish = skedDateTimeUtils.addMinutes(subclassStart, subclass.duration, model.timezoneSidId);
                            
                            skedSubclass = masterJob.clone();
                            skedSubclass.sked__Parent__c = masterJob.Id;
                            skedSubclass.sked__Start__c = subclassStart;
                            skedSubclass.sked__Finish__c = subclassFinish;
                            skedSubclass.sked__Duration__c = subclass.duration;
                            skedSubclass.sked__Recurring_Schedule__c = NULL;
                            skedSubclass.Is_Master_Class__c = FALSE;
                            skedSubclass.Course_Code__c = subclass.courseCode;
                            skedSubclass.Display_Order__c = subclass.displayOrder;
                            if (!string.isBlank(subclass.id)) {
                                skedSubclass.Id = subclass.id;
                            }
                        }

                        skedSubclasses.add(skedSubclass);
                    }
                }
                if (!skedSubclasses.isEmpty()) {
                    upsert skedSubclasses;
                }
            }

            Date jobMonth = selectedDate.toStartOfMonth();
            validateQueuedJobsInMonth(model.regionId, jobMonth);

            result.data = skedJob.Id;
        }
        catch (Exception ex) {
            result.getError(ex);
            Database.rollback(sp);
        }
        return result;
    }

    @remoteAction
    global static skedRemoteResultModel rescheduleJob(jobSaveModel model, boolean confirm) {
        skedRemoteResultModel result = new skedRemoteResultModel();
        SavePoint sp = Database.setSavePoint();
        try {
            List<skedModels.jobAllocation> conflictAllocations = new List<skedModels.jobAllocation>();
            conflictAllocations = skedJobService.rescheduleJob(model, confirm);

            if (conflictAllocations.size() == 0) {
                sked__Job__c skedJob = [SELECT Id, sked__Region__c, Job_Month__c, sked__Timezone__c,
                                        (SELECT sked__Job__c, sked__Tag__c, sked__Tag__r.Name
                                         FROM sked__JobTags__r)
                                        FROM sked__Job__c 
                                        WHERE Id = :model.id];
                validateQueuedJobsInMonth(skedJob.sked__Region__c, skedJob.Job_Month__c);
            }

            result.data = conflictAllocations;
        }
        catch (Exception ex) {
            result.getError(ex);
            Database.rollback(sp);
        }
        return result;
    }

    @remoteAction
    global static skedRemoteResultModel resolveQueuedJobs(string[] jobIds) {
        skedRemoteResultModel result = new skedRemoteResultModel();
        SavePoint sp = Database.setSavePoint();
        try {
            List<sked__Job__c> skedJobs = [SELECT Id, Job_Month__c, sked__Region__c 
                                           FROM sked__Job__c 
                                           WHERE Id IN :jobIds];
            sked__Job__c firstJob = skedJobs.get(0);

            List<sked__Job__c> validatedQueuedJobs = validateQueuedJobsInMonth(firstJob.sked__Region__c, firstJob.Job_Month__c);
            Map<Id, sked__Job__c> mapValidatedQueuedJobs = new Map<Id, sked__Job__c>(validatedQueuedJobs);
            Set<Id> errorRecurringScheduleIds = new Set<Id>();
            for (sked__Job__c validatedQueuedJob : validatedQueuedJobs) {
                if (!string.isBlank(validatedQueuedJob.Copy_Result_Message__c) && validatedQueuedJob.sked__Recurring_Schedule__c != NULL) {
                    errorRecurringScheduleIds.add(validatedQueuedJob.sked__Recurring_Schedule__c);
                }
            }

            List<sked__Job__c> jobsToUpdate = new List<sked__Job__c>();

            for (sked__Job__c skedJob : skedJobs) {
                if (mapValidatedQueuedJobs.containsKey(skedJob.Id)) {
                    sked__Job__c validatedQueuedJob = mapValidatedQueuedJobs.get(skedJob.Id);
                    if (string.isBlank(validatedQueuedJob.Copy_Result_Message__c) 
                        || (validatedQueuedJob.Copy_Result_Message__c == skedConstants.COMMUNITY_COPY_OUT_OF_MONTH + '. ')) {
                        if (validatedQueuedJob.sked__Recurring_Schedule__c == NULL || !errorRecurringScheduleIds.contains(validatedQueuedJob.sked__Recurring_Schedule__c)) {
                            skedJob.sked__Job_Status__c = skedConstants.JOB_STATUS_PENDING_ALLOCATION;
                            skedJob.Is_Queued__c = FALSE;
                            skedJob.Job_Month__c = NULL;
                            jobsToUpdate.add(skedJob);
                        }
                    }
                }
            }
            if (!jobsToUpdate.isEmpty()) {
                update jobsToUpdate;
            }
        }
        catch (Exception ex) {
            result.getError(ex);
            Database.rollback(sp);
        }
        return result;
    }

    @remoteAction
    global static skedRemoteResultModel deleteJobs(string[] jobIds) {
        skedRemoteResultModel result = new skedRemoteResultModel();
        SavePoint sp = Database.setSavePoint();
        try {
            skedJobService.deleteJobs(jobIds);
        }
        catch (Exception ex) {
            result.getError(ex);
            Database.rollback(sp);
        }
        return result;
    }

    @remoteAction
    global static skedRemoteResultModel cancelJobs(List<string> jobIds) {
        skedRemoteResultModel result = new skedRemoteResultModel();
        SavePoint sp = Database.setSavePoint();
        try {
            skedJobService.cancelJobs(jobIds);
        }
        catch (Exception ex) {
            result.getError(ex);
            Database.rollback(sp);
        }
        return result;
    }
    
    /**************************************************************** Private methods ***********************************************************************/
    private static List<sked__Job__c> validateQueuedJobsInMonth(string regionId, Date jobMonth) {
        List<sked__Job__c> queuedJobs = [SELECT Id, Name, sked__Region__c, sked__Address__c, sked__Contact__c, sked__Recurring_Schedule__c,
                                         sked__GeoLocation__Latitude__s, sked__GeoLocation__Longitude__s, sked__GeoLocation__c,
                                         sked__Timezone__c, sked__Start__c, sked__Finish__c, sked__Duration__c, sked__Type__c, 
                                         sked__Job_Status__c, Copy_Result_Message__c, Number_of_Instructors__c, Job_Month__c,
                                         sked__Location__c, Course_Catalog__c, Course_Catalog__r.Name, Break_Duration__c, 
                                         Number_of_Breaks__c, Special_Instructions__c, ClasS_Sub_Type__c, Course_Code__c, Display_Order__c,
                                         sked__Parent__c, Is_Stacked_Class__c, Is_Master_Class__c
                                         FROM sked__Job__c
                                         WHERE Job_Month__c = :jobMonth
                                         AND sked__Region__c = :regionId
                                         AND Is_Queued__c = TRUE
                                         AND (Is_Stacked_Class__c = FALSE OR Is_Master_Class__c = TRUE)];
        return validateQueuedJobs(regionId, queuedJobs);
    }

    private static List<sked__Job__c> validateQueuedJobs(string regionId, List<sked__Job__c> queuedJobs) {
        if (queuedJobs.size() == 0) {
            return queuedJobs;
        }
        DateTime startTime, endTime;
        for (sked__Job__c queuedJob : queuedJobs) {
            if (startTime == NULL || startTime > queuedJob.sked__Start__c) {
                startTime = queuedJob.sked__Start__c;
            }
            if (endTime == NULL || endTime < queuedJob.sked__Finish__c) {
                endTime = queuedJob.sked__Finish__c;
            }
        }
        sked__Region__c skedRegion = [SELECT Id, sked__Timezone__c FROM sked__Region__c WHERE Id = :regionId];
        string timezoneSidId = skedRegion.sked__Timezone__c;
        startTime = skedDateTimeUtils.getStartOfDate(startTime, timezoneSidId);
        endTime = skedDateTimeUtils.getEndOfDate(endTime, timezoneSidId);

        List<sked__Job__c> activeJobs = [SELECT Id, Name, sked__Start__c, sked__Finish__c, sked__Location__c, sked__Recurring_Schedule__c
                                         FROM sked__Job__c
                                         WHERE sked__Region__c = :regionId
                                         AND sked__Type__c = :skedConstants.JOB_TYPE_COMMUNITY
                                         AND sked__Job_Status__c != :skedConstants.JOB_STATUS_CANCELLED
                                         AND Is_Queued__c = FALSE
                                         AND sked__Start__c < :endTime
                                         AND sked__Finish__c > :startTime
                                         AND (Is_Stacked_Class__c = FALSE OR Is_Master_Class__c = TRUE)
                                         ORDER BY sked__Start__c];
        List<sked__Job__c> jobsToUpdate = new List<sked__Job__c>();
        for (sked__Job__c queuedJob : queuedJobs) {
            queuedJob.Copy_Result_Message__c = '';

            Date jobMonthStart = queuedJob.Job_Month__c;
            Date jobMonthEnd = jobMonthStart.addMonths(1).addDays(-1);
            if (queuedJob.sked__Start__c.date() > jobMonthEnd) {
                queuedJob.Copy_Result_Message__c = skedConstants.COMMUNITY_COPY_OUT_OF_MONTH + '. ';
            }

            for (sked__Job__c activeJob : activeJobs) {
                if (queuedJob.sked__Location__c == activeJob.sked__Location__c) {
                    if (queuedJob.sked__Start__c < activeJob.sked__Finish__c && queuedJob.sked__Finish__c > activeJob.sked__Start__c) {
                        queuedJob.Copy_Result_Message__c += skedConstants.COMMUNITY_COPY_ROOM_CONFLICT + '. ';
                        break;
                    }
                }
            }
        }
        update queuedJobs;

        return queuedJobs;
    }

    private static List<sked__Job__c> processRecurring(sked__Job__c sourceJob, jobSaveModel model) {
        List<sked__Job__c> recurringJobs;

        Map<string, Set<Date>> mapHolidays = skedDateTimeUtils.getHolidays();
        Set<Date> allHolidays = new Set<Date>();
        if (mapHolidays.containsKey(skedConstants.HOLIDAY_GLOBAL)) {
            Set<Date> globalHolidays = mapHolidays.get(skedConstants.HOLIDAY_GLOBAL);
            allHolidays.addAll(globalHolidays);
        }
        if (mapHolidays.containsKey(sourceJob.sked__Region__c)) {
            Set<Date> regionHolidays = mapHolidays.get(sourceJob.sked__Region__c);
            allHolidays.addAll(regionHolidays);
        }

        recurringJobs = getWeeklyRecurringJobs(sourceJob, model, allHolidays);
        
        return recurringJobs;
    }
    
    private static List<sked__Job__c> getWeeklyRecurringJobs(sked__Job__c sourceJob, jobSaveModel model, Set<Date> allHolidays) {
        List<sked__Job__c> recurringJobs = new List<sked__Job__c>();
        
        Set<string> setWeekdays = new Set<string>();
        setWeekdays.addAll(model.weekdays);

        string weekFirstDay = 'sun';
        integer count = 1;
        integer dayCount = 1;
        while (count < model.numberOfClasses) {
            DateTime recurringJobStart = skedDateTimeUtils.addDays(sourceJob.sked__Start__c, dayCount, model.timezoneSidId);
            string recurringJobWeekday = recurringJobStart.format('E', model.timezoneSidId).toLowerCase();

            Date recurringDate = skedDateTimeUtils.getDate(recurringJobStart, model.timezoneSidId);
            if (model.skipHolidays && allHolidays.contains(recurringDate)) {
                dayCount++;
                continue;
            }

            if (recurringJobWeekday == weekFirstDay) {
                recurringJobStart = skedDateTimeUtils.addDays(recurringJobStart, 7 * (model.every - 1), model.timezoneSidId);
                dayCount = dayCount + 7 * (model.every - 1);
            }
            
            if (setWeekdays.contains(recurringJobWeekday)) {
                sked__Job__c recurringJob = sourceJob.clone();
                recurringJob.sked__Start__c = recurringJobStart;
                recurringJob.sked__Finish__c = skedDateTimeUtils.addDays(sourceJob.sked__Finish__c, dayCount, model.timezoneSidId);
                recurringJobs.add(recurringJob);
                count++;
            }
            dayCount++;
        }
        return recurringJobs;
    }

    private static sked__Recurring_Schedule__c prepareScheduleData(jobSaveModel model) {
        string summary = '';
        string weekdaysStr = string.join(model.weekdays, '-');

        if (model.every == 1) {
            summary = 'Repeats weekly on ' + weekdaysStr;
        } else {
            summary = 'Repeats every ' + model.every + ' weeks on ' + weekdaysStr;
        }
        
        sked__Recurring_Schedule__c schedule = new sked__Recurring_Schedule__c(
            sked__Summary__c = summary,
            Pattern__c = string.join(model.weekdays, ';'),
            Frequency__c = model.every
        );
        return schedule;
    }

    private static skedModels.permissionModel getUserPermissions() {
        skedModels.permissionModel userPermission = new skedModels.permissionModel();

        User currentUser = [SELECT Id, ARC_User_Type__c
                            FROM User
                            WHERE Id = :UserInfo.getUserId()];
        if (currentUser.ARC_User_Type__c != NULL) {
            if (currentUser.ARC_User_Type__c.contains(skedConstants.ARC_USER_TYPE_DIVISION_SCHEDULER)) {
                userPermission.canClone = true;
                userPermission.canCreate = true;
                userPermission.canDelete = true;
                userPermission.canCancel = true;
                userPermission.canEdit = true;
            }
            else if (currentUser.ARC_User_Type__c.contains(skedConstants.ARC_USER_TYPE_SECONDARY_SCHEDULER)) {
                userPermission.canClone = false;
                userPermission.canCreate = true;
                userPermission.canDelete = false;
                userPermission.canCancel = true;
                userPermission.canEdit = true;
            }
        }
        return userPermission;
    }

    /**************************************************************** Nested clases ***********************************************************************/
    global class facilityQueryModel {
    	public string regionId {get;set;}
    	public string startDateIso {get;set;} 
    	public string endDateIso {get;set;}
    }

    global class facilityModel extends skedModels.facility {
    	public List<jobModel> jobs {get;set;}

    	public facilityModel(sked__Location__c skedLocation) {
            super(skedLocation);
    		this.jobs = new List<jobModel>();
    	}
    }

    global class jobModel extends skedModels.job {
        public string action {get;set;}
        public boolean isQueued {get;set;}
        public boolean isPreviouslyCancelled {get;set;}
        public integer numberOfStudents {get;set;}
        public integer numberOfInstructors {get;set;}
        public boolean locationConfirmed {get;set;}
        public boolean hasAllocation {get;set;}
        public string communityClassSubType {get;set;}
        public copyResultModel copyResult {get;set;}
        public boolean isStackedClass {get;set;}
        public string courseCode {get;set;}
        public integer displayOrder {get;set;}
        public List<jobModel> subclasses {get;set;}

        public jobModel() {}

        public jobModel(sked__Job__c skedJob) {
            super(skedJob);
            this.copyResult = new copyResultModel();
            this.copyResult.message = skedJob.Copy_Result_Message__c;
            this.copyResult.success = string.isBlank(this.copyResult.message);
            this.facilityId = skedJob.sked__Location__c;
            this.courseCatalogId = skedJob.Course_Catalog__c;
            this.courseCatalogName = skedJob.Course_Catalog__r.Name;
            this.breakDuration = skedJob.Break_Duration__c == NULL ? 0 : integer.valueOf(skedJob.Break_Duration__c);
            this.numberOfBreaks = skedJob.Number_of_Breaks__c == NULL ? 0 : integer.valueOf(skedJob.Number_of_Breaks__c);
            this.numberOfInstructors = skedJob.Number_of_Instructors__c == NULL ? 0 : integer.valueOf(skedJob.Number_of_Instructors__c);
            this.numberOfStudents = skedJob.Number_of_Students__c == NULL ? 0 : integer.valueOf(skedJob.Number_of_Students__c);
            this.isQueued = skedJob.Is_Queued__c;
            this.isPreviouslyCancelled = skedJob.Is_Previously_Cancelled__c;
            this.specialInstructions = skedJob.Special_Instructions__c;
            this.locationConfirmed = skedJob.Location_Confirmed__c;
            this.hasAllocation = skedJob.sked__Job_Allocation_Count__c > 0;
            if (this.isQueued) {
                this.jobStatus = skedConstants.JOB_STATUS_QUEUED;
            }
            this.beforeClassDuration = skedJob.Before_class_duration__c == NULL ? 0 : integer.valueOf(skedJob.Before_class_duration__c);
            this.afterClassDuration = skedJob.After_class_duration__c == NULL ? 0 : integer.valueOf(skedJob.After_class_duration__c);
            this.communityClassSubType = skedJob.ClasS_Sub_Type__c;
            this.isStackedClass = skedJob.Is_Stacked_Class__c;
            this.courseCode = skedJob.Course_Code__c;
            if (skedJob.Display_Order__c != NULL) {
                this.displayOrder = integer.valueOf(skedJob.Display_Order__c);
            }
            this.parentId = skedJob.sked__Parent__c;
        }
    }

    global class offeringModel extends skedModels.offering {
        public boolean isChanged {get;set;}
        public boolean isDeleted {get;set;}

        public offeringModel(){
            this.isChanged = false;
            this.isDeleted = false;
        }

        public offeringModel(Offering__c skedOffering) {
            super(skedOffering);
            this.isChanged = false;
            this.isDeleted = false;
        }
    }

    global class copyResultModel {
        public boolean success {get;set;}
        public string message {get;set;}
    }
    
    global class jobSaveModel extends skedJobService.jobSaveModelBase {
        public string courseCatalogId {get;set;}
        public integer numberOfInstructors {get;set;}
        public integer numberOfStudents {get;set;}
        public integer classDuration {get;set;}
        public integer breakDuration {get;set;}
        public integer numberOfBreaks {get;set;}
        public boolean locationConfirmed {get;set;}
        public string communityClassSubType {get;set;}
        public boolean isStackedClass {get;set;}
        public string courseCode {get;set;}
        public integer displayOrder {get;set;}
        public List<jobModel> subclasses {get;set;}
        
        //recurring options
        public boolean isRecurring {get;set;}
        public boolean skipHolidays {get;set;}
        public integer every {get;set;}
        public List<string> weekdays {get;set;} // sample data: ["mon", "tue", "fri"] note: lower case
        public integer numberOfClasses {get;set;}

        public List<offeringModel> offerings {get;set;}
    }

    global class configDataModel {
        public List<skedModels.courseCatalog> courseCatalogs {get;set;}
        public List<skedModels.selectOption> communityClassSubTypes {get;set;}
        public List<skedModels.selectOption> regions {get;set;}
        public List<skedModels.selectOption> tags {get;set;}
        public List<skedModels.jobStatusSetting> jobStatusSettings {get;set;}
        public Map<string, Set<skedModels.selectOption>> mapHolidays {get;set;}
        public skedModels.permissionModel userPermission {get;set;}

        public configDataModel() {
            this.regions = new List<skedModels.selectOption>();
            this.courseCatalogs = new List<skedModels.courseCatalog>();
            this.communityClassSubTypes = new List<skedModels.selectOption>();
            this.tags = new List<skedModels.selectOption>();
            this.jobStatusSettings = new List<skedModels.jobStatusSetting>();
            this.mapHolidays = new Map<string, Set<skedModels.selectOption>>();
        }
    }

}