global class skedCepSchedulingController {

	@remoteAction
    global static skedRemoteResultModel getCEPConfigData() {
    	skedRemoteResultModel result = new skedRemoteResultModel();
        try {
    		configDataModel configData = new configDataModel();
            configData.regions = skedUtils.getRegions();
            configData.courseCatalogs = skedARCUtils.getCourseCatalogs(skedConstants.COURSE_CATALOG_TYPE_NURSE_ASSISTANT_TESTING);
            configData.tags = skedUtils.getTags();
            configData.jobStatusSettings = skedUtils.getJobStatusSettings();
            configData.mapHolidays = skedDateTimeUtils.getHolidayOptions();
            configData.userPermission = getUserPermissions();
            
            List<skedModels.selectOption> jobTypes = new List<skedModels.selectOption>();
            jobTypes.add(new skedModels.selectOption(skedConstants.JOB_TYPE_NURSE_ASSISTANT_TESTING, skedConstants.JOB_TYPE_NURSE_ASSISTANT_TESTING, true));
            jobTypes.add(new skedModels.selectOption(skedConstants.JOB_TYPE_NURSE_ASSISTANT_TESTING_FULL_SERVICE, skedConstants.JOB_TYPE_NURSE_ASSISTANT_TESTING_FULL_SERVICE));
            configData.jobTypes = jobTypes;
            
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

            List<string> locationTypes = new List<String>();
            locationTypes.add(skedConstants.LOCATION_TYPE_NURSE_ASSISTANT_TESTING);
            locationTypes.add(skedConstants.LOCATION_TYPE_NAT_AND_CEP);
            locationTypes.add(skedConstants.LOCATION_TYPE_INTERNAL);
            
            List<string> jobTypes = new List<string>();
            jobTypes.add(skedConstants.JOB_TYPE_NURSE_ASSISTANT_TESTING);
            jobTypes.add(skedConstants.JOB_TYPE_NURSE_ASSISTANT_TESTING_FULL_SERVICE);

        	List<sked__Location__c> skedLocations = [SELECT Id, Name, Facility_ID__c, Notes__c,
                                                     sked__Region__c, sked__Address__c, 
                                                     sked__GeoLocation__Latitude__s, sked__GeoLocation__Longitude__s,
        											 (SELECT Id, Name, sked__Region__c, sked__Address__c, sked__Contact__c, sked__Recurring_Schedule__c,
			                                          sked__GeoLocation__Latitude__s, sked__GeoLocation__Longitude__s, sked__GeoLocation__c,
			                                          sked__Timezone__c, sked__Start__c, sked__Finish__c, sked__Duration__c, sked__Type__c, 
                                                      sked__Job_Status__c, sked__Description__c, sked__Location__c, sked__Job_Allocation_Count__c,
                                                      Course_Catalog__c, Copy_Result_Message__c, Special_Instructions__c, Number_of_Evaluators__c,
                                                      Before_class_duration__c, After_class_duration__c, Remaining_Resources_to_be_Allocated__c,
                                                      Course_Code__c, Display_Order__c, sked__Parent__c, Is_Stacked_Class__c, Is_Master_Class__c,
                                                      Ready_to_Publish__c
        											  FROM sked__Jobs__r
        											  WHERE sked__Start__c < :endTime 
                                                      AND sked__Finish__c > :startTime
        											  AND sked__Type__c IN :jobTypes
                                                      AND (Is_Stacked_Class__c = FALSE OR Is_Master_Class__c = TRUE))
        											 FROM sked__Location__c
        											 WHERE sked__Region__c = :queryModel.regionId
                                                     AND sked__Type__c IN :locationTypes
                                                     AND Is_Active__c = TRUE
        											 ORDER BY Name ASC];
		    Map<Id, jobModel> mapJob = new Map<Id, jobModel>();
            List<facilityModel> facilityList = new List<facilityModel>();
        	for (sked__Location__c skedLocation : skedLocations) {
        		facilityModel facility = new facilityModel(skedLocation);

        		for (sked__Job__c skedJob : skedLocation.sked__Jobs__r) {
        			jobModel job = new jobModel(skedJob);
        			facility.jobs.add(job);
                    mapJob.put(job.id, job);
        		}
        		facilityList.add(facility);
        	}

            List<sked__Job__c> skedSubClasses = [SELECT Id, Name, sked__Description__c, sked__Region__c, sked__Address__c, sked__Contact__c, sked__Recurring_Schedule__c,
                                                 sked__GeoLocation__Latitude__s, sked__GeoLocation__Longitude__s, sked__GeoLocation__c,
                                                 sked__Timezone__c, sked__Start__c, sked__Finish__c, sked__Duration__c, sked__Type__c, 
                                                 sked__Job_Status__c, Copy_Result_Message__c, Number_of_Evaluators__c, Location_Confirmed__c,
                                                 sked__Location__c, Course_Catalog__c, Course_Catalog__r.Name,
                                                 Break_Duration__c, Number_of_Breaks__c, Special_Instructions__c,
                                                 Is_Queued__c, Is_Previously_Cancelled__c, sked__Job_Allocation_Count__c, Number_of_Students__c,
                                                 Before_class_duration__c, After_class_duration__c, ClasS_Sub_Type__c,
                                                 Remaining_Resources_to_be_Allocated__c, Course_Code__c, Display_Order__c, sked__Parent__c, 
                                                 Is_Stacked_Class__c, Is_Master_Class__c, Ready_to_Publish__c
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

            List<sked__Job_Allocation__c> skedAllocations = [SELECT Id, sked__Job__c, sked__Status__c, sked__Team_Leader__c,
                                                             sked__Resource__c, sked__Resource__r.Name, sked__Resource__r.sked__Category__c
                                                             FROM sked__Job_Allocation__c
                                                             WHERE sked__Job__c IN :mapJob.keySet()
                                                             AND sked__Status__c != :skedConstants.JOB_ALLOCATION_STATUS_DELETED];
            for (sked__Job_Allocation__c skedAllocation : skedAllocations) {
                skedModels.jobAllocation allocation = new skedModels.jobAllocation();
                allocation.status = skedAllocation.sked__Status__c;

                skedModels.resource resource = new skedModels.resource();
                resource.id = skedAllocation.sked__Resource__c;
                resource.name = skedAllocation.sked__Resource__r.Name;
                resource.category = skedAllocation.sked__Resource__r.sked__Category__c;
                allocation.resource = resource;

                jobModel job = mapJob.get(skedAllocation.sked__Job__c);
                job.allocations.add(allocation);
                if (skedAllocation.sked__Team_Leader__c == TRUE) {
                    job.teamLeadResourceId = skedAllocation.sked__Resource__c;
                }
            }   
        	result.data = facilityList;
    	}
        catch (Exception ex) {
            result.getError(ex);
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
                                    sked__Job_Status__c, sked__Description__c, Copy_Result_Message__c, sked__Job_Allocation_Count__c,
                                    sked__Location__c, Special_Instructions__c, Number_of_Evaluators__c, Course_Catalog__c,
                                    Before_class_duration__c, After_class_duration__c, Remaining_Resources_to_be_Allocated__c,
                                    Course_Code__c, Display_Order__c, sked__Parent__c, Is_Stacked_Class__c, Is_Master_Class__c,
                                    Ready_to_Publish__c,
                                    (SELECT sked__Job__c, sked__Tag__c, sked__Tag__r.Name
                                     FROM sked__JobTags__r),
                                    (SELECT Id, Name, sked__Description__c, sked__Region__c, sked__Address__c, sked__Contact__c, sked__Recurring_Schedule__c,
                                     sked__GeoLocation__Latitude__s, sked__GeoLocation__Longitude__s, sked__GeoLocation__c,
                                     sked__Timezone__c, sked__Start__c, sked__Finish__c, sked__Duration__c, sked__Type__c, 
                                     sked__Job_Status__c, Copy_Result_Message__c, Number_of_Evaluators__c, Location_Confirmed__c,
                                     sked__Location__c, Course_Catalog__c, Course_Catalog__r.Name, 
                                     Break_Duration__c, Number_of_Breaks__c, Number_of_Students__c,
                                     Special_Instructions__c, Is_Queued__c, Is_Previously_Cancelled__c, sked__Job_Allocation_Count__c,
                                     Before_class_duration__c, After_class_duration__c, ClasS_Sub_Type__c,
                                     Remaining_Resources_to_be_Allocated__c, Course_Code__c, Display_Order__c, sked__Parent__c, Is_Stacked_Class__c,
                                     Is_Master_Class__c, Ready_to_Publish__c
                                     FROM sked__Followups__r
                                     WHERE sked__Job_Status__c != :skedConstants.JOB_STATUS_CANCELLED
                                     ORDER BY sked__Start__c ASC)
                                    FROM sked__Job__c
                                    WHERE Id = :jobId];
            jobModel job = new jobModel(skedJob);
            job.loadJobTags(skedJob.sked__JobTags__r);

            if (skedJob.sked__Followups__r != NULL && !skedJob.sked__Followups__r.isEmpty()) {
                job.subclasses = new List<jobModel>();
                for (sked__Job__c skedSubclass : skedJob.sked__Followups__r) {
                    jobModel subclass = new jobModel(skedSubclass);
                    job.subclasses.add(subclass); 
                }
            }

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
            sked__Location__c skedLocation = [SELECT Id, sked__Region__r.sked__Timezone__c,
                                              sked__Address__c, sked__GeoLocation__Latitude__s, sked__GeoLocation__Longitude__s
                                              FROM sked__Location__c
                                              WHERE Id = :model.facilityId];
            model.timezoneSidId = skedLocation.sked__Region__r.sked__Timezone__c;
            
            Date selectedDate = skedDateTimeUtils.getDateFromIsoString(model.selectedDate);
            DateTime selectedDateStart = DateTime.newInstance(selectedDate, time.newInstance(0, 0, 0, 0));
            selectedDateStart = skedDateTimeUtils.toTimezone(selectedDateStart, model.timezoneSidId);
                
            integer startTimeInMinutes = skedDateTimeUtils.convertTimeNumberToMinutes(model.startTime);
            DateTime jobStart = skedDateTimeUtils.addMinutes(selectedDateStart, startTimeInMinutes, model.timezoneSidId);
            integer finishTimeInMinutes = skedDateTimeUtils.convertTimeNumberToMinutes(model.finishTime);
            DateTime jobFinish = skedDateTimeUtils.addMinutes(selectedDateStart, finishTimeInMinutes, model.timezoneSidId);
            integer jobDuration = finishTimeInMinutes - startTimeInMinutes;

            sked__Job__c skedJob = new sked__Job__c(
                sked__Region__c = model.regionId,
                sked__Description__c = model.className,
                sked__Start__c = jobStart,
                sked__Finish__c = jobFinish,
                sked__Duration__c = jobDuration,
                sked__Type__c = model.jobType,
                sked__Location__c = model.facilityId,
                sked__Address__c = skedLocation.sked__Address__c,
                sked__GeoLocation__Latitude__s = skedLocation.sked__GeoLocation__Latitude__s,
                sked__GeoLocation__Longitude__s = skedLocation.sked__GeoLocation__Longitude__s,
                Course_Catalog__c = model.courseCatalogId,
                Number_of_Evaluators__c = model.numberOfEvaluators,
                Special_Instructions__c = model.specialInstructions,
                Before_class_duration__c = model.beforeClassDuration,
                After_class_duration__c = model.afterClassDuration,
                Course_Code__c = model.courseCode,
                Is_Stacked_Class__c = model.isStackedClass,
                Is_Master_Class__c = model.isStackedClass,
                Ready_to_Publish__c = model.readyToPublish
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
            }
            else {
                skedJob.Id = model.id;
                update skedJob;

                skedJobService.editJobTags(skedJob, model.tagIds);
            }

            if (model.isStackedClass == TRUE) {
                List<sked__Job__c> skedSubclasses = new List<sked__Job__c>();
                for (sked__Job__c masterJob : allJobs) {
                    DateTime jobDateStart = skedDateTimeUtils.getStartOfDate(skedJob.sked__Start__c, model.timezoneSidId);
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
                            DateTime subClassStart = skedDateTimeUtils.addMinutes(jobDateStart, subclassStartMinutes, model.timezoneSidId);
                            integer subclassFinishMinutes = skedDateTimeUtils.convertTimeNumberToMinutes(subclass.finishTime);
                            DateTime subClassFinish = skedDateTimeUtils.addMinutes(jobDateStart, subclassFinishMinutes, model.timezoneSidId);
                            integer subClassDuration = subclassFinishMinutes - subclassStartMinutes;
                            
                            skedSubclass = skedJob.clone();
                            skedSubclass.sked__Parent__c = masterJob.id;
                            skedSubclass.sked__Start__c = subclassStart;
                            skedSubclass.sked__Finish__c = subclassFinish;
                            skedSubclass.sked__Duration__c = subClassDuration;
                            skedSubclass.sked__Recurring_Schedule__c = NULL;
                            skedSubclass.Is_Master_Class__c = FALSE;
                            skedSubclass.Course_Code__c = subclass.courseCode;
                            skedSubclass.Display_Order__c = subclass.displayOrder;
                            skedSubclass.Ready_to_Publish__c = FALSE;
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
            result.data = skedJobService.rescheduleJob(model, confirm);
        }
        catch (Exception ex) {
            result.getError(ex);
            Database.rollback(sp);
        }
        return result;
    }

    @remoteAction
    global static skedRemoteResultModel deleteJobs(List<string> jobIds) {
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
        public string className {get;set;}
        public integer numberOfEvaluators {get;set;}
        public boolean hasAllocation {get;set;}
        public string teamLeadResourceId {get;set;}
        public boolean isStackedClass {get;set;}
        public string courseCode {get;set;}
        public integer displayOrder {get;set;}
        public List<jobModel> subclasses {get;set;}
        public boolean readyToPublish {get;set;}

        public jobModel() {}

        public jobModel(sked__Job__c skedJob) {
            super(skedJob);
            this.facilityId = skedJob.sked__Location__c;
            this.className = skedJob.sked__Description__c;
            this.courseCatalogId = skedJob.Course_Catalog__c;
            this.numberOfEvaluators = integer.valueOf(skedJob.Number_of_Evaluators__c);
            this.specialInstructions = skedJob.Special_Instructions__c;
            this.beforeClassDuration = integer.valueOf(skedJob.Before_class_duration__c);
            this.afterClassDuration = integer.valueOf(skedJob.After_class_duration__c);
            this.hasAllocation = skedJob.sked__Job_Allocation_Count__c > 0;
            this.isStackedClass = skedJob.Is_Stacked_Class__c;
            this.courseCode = skedJob.Course_Code__c;
            if (skedJob.Display_Order__c != NULL) {
                this.displayOrder = integer.valueOf(skedJob.Display_Order__c);
            }
            this.parentId = skedJob.sked__Parent__c;
            this.readyToPublish = skedJob.Ready_to_Publish__c;
        }
    }
    
    global class jobSaveModel extends skedJobService.jobSaveModelBase {
        public string courseCatalogId {get;set;}
        public string className {get;set;}
        public integer numberOfEvaluators {get;set;}
        public boolean isStackedClass {get;set;}
        public string courseCode {get;set;}
        public integer displayOrder {get;set;}
        public List<jobModel> subclasses {get;set;}
        public string jobType {get;set;}
        public boolean readyToPublish {get;set;}

        //recurring options
        public boolean isRecurring {get;set;}
        public boolean skipHolidays {get;set;}
        public integer every {get;set;}
        public List<string> weekdays {get;set;} // sample data: ["mon", "tue", "fri"] note: lower case
        public integer numberOfClasses {get;set;}
    }

    global class configDataModel {
        public List<skedModels.courseCatalog> courseCatalogs {get;set;}
        public List<skedModels.selectOption> regions {get;set;}
        public List<skedModels.selectOption> tags {get;set;}
        public List<skedModels.jobStatusSetting> jobStatusSettings {get;set;}
        public Map<string, Set<skedModels.selectOption>> mapHolidays {get;set;}
        public skedModels.permissionModel userPermission {get;set;}
        public List<skedModels.selectOption> jobTypes {get;set;}

        public configDataModel() {
            this.regions = new List<skedModels.selectOption>();
            this.courseCatalogs = new List<skedModels.courseCatalog>();
            this.tags = new List<skedModels.selectOption>();
            this.jobStatusSettings = new List<skedModels.jobStatusSetting>();
            this.mapHolidays = new Map<string, Set<skedModels.selectOption>>();
        }
    }

}