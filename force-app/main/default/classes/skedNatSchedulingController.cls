global class skedNatSchedulingController {

    @remoteAction
    global static skedRemoteResultModel getNATConfigData() {
        skedRemoteResultModel result = new skedRemoteResultModel();
        try {
            configDataModel configData = new configDataModel();
            configData.regions = skedUtils.getRegions();
            configData.courseCatalogs = skedARCUtils.getCourseCatalogs(skedConstants.COURSE_CATALOG_TYPE_NURSE_ASSISTANT_TRAINING);
            configData.tags = skedUtils.getTags();
            configData.jobStatusSettings = skedUtils.getJobStatusSettings();
            configData.mapHolidays = skedDateTimeUtils.getHolidayOptions();
            configData.courseTemplates = skedARCUtils.getCourseTemplates();
            configData.userPermission = getUserPermissions();
            
            List<skedModels.selectOption> jobTypes = new List<skedModels.selectOption>();
            jobTypes.add(new skedModels.selectOption(skedConstants.JOB_TYPE_NURSE_ASSISTANT_TRAINING, skedConstants.JOB_TYPE_NURSE_ASSISTANT_TRAINING, true));
            jobTypes.add(new skedModels.selectOption(skedConstants.JOB_TYPE_NURSE_ASSISTANT_TRAINING_FULL_SERVICE, skedConstants.JOB_TYPE_NURSE_ASSISTANT_TRAINING_FULL_SERVICE));
            configData.jobTypes = jobTypes;

            List<string> locationTypes = new List<String>();
            locationTypes.add(skedConstants.LOCATION_TYPE_NURSE_ASSISTANT_TRAINING);
            locationTypes.add(skedConstants.LOCATION_TYPE_NAT_AND_CEP);
            locationTypes.add(skedConstants.LOCATION_TYPE_NAT_AND_COMMUNITY);
            locationTypes.add(skedConstants.LOCATION_TYPE_INTERNAL);
            
            configData.locations = skedUtils.getLocations(locationTypes);

            configData.natClassSetting = skedARCUtils.getNatSetting();
            
            result.data = configData;
        }
        catch (Exception ex) {
            result.getError(ex);
        }
        return result;
    }

    @remoteAction
    global static skedRemoteResultModel getCourses(courseQueryModel queryModel) {
        skedRemoteResultModel result = new skedRemoteResultModel();
        try {
            sked__Region__c skedRegion = [SELECT Id, sked__Timezone__c FROM sked__Region__c 
                                          WHERE Id = :queryModel.regionId];
            string timezoneSidId = skedRegion.sked__Timezone__c;

            Date startDate = skedDateTimeUtils.getDateFromIsoString(queryModel.startDateIso);
            DateTime startTime = skedDateTimeUtils.getStartOfDate(startDate, timezoneSidId);

            Date endDate = skedDateTimeUtils.getDateFromIsoString(queryModel.endDateIso);
            DateTime endTime = skedDateTimeUtils.getEndOfDate(endDate, timezoneSidId);
            
            List<string> jobTypes = new List<string>();
            jobTypes.add(skedConstants.JOB_TYPE_NURSE_ASSISTANT_TRAINING);
            jobTypes.add(skedConstants.JOB_TYPE_NURSE_ASSISTANT_TRAINING_FULL_SERVICE);

            List<sked__Job__c> skedJobsInTimeRange = [SELECT Id, Course__c
                                                      FROM sked__Job__c
                                                      WHERE sked__Type__c IN :jobTypes
                                                      AND sked__Region__c = :queryModel.regionId
                                                      AND sked__Start__c < :endTime 
                                                      AND sked__Finish__c > :startTime
                                                      AND Course__c != NULL];

            Set<Id> courseIds = new Set<Id>();
            for (sked__Job__c skedJob : skedJobsInTimeRange) {
                courseIds.add(skedJob.Course__c);
            }
            List<Course__c> skedCourses = [SELECT Id, Name, Max_Hours_Per_Day__c, Course_Catalog__c,
                                           Course_Catalog__r.Name,
                                           Recurring_Schedule__c, Recurring_Schedule__r.Pattern__c,
                                           Recurring_Schedule__r.Skip_Holidays__c,
                                           Start_Month__c, Region__c, 
                                           (SELECT Id, Name, sked__Region__c, sked__Address__c, sked__Contact__c, sked__Recurring_Schedule__c,
                                            sked__GeoLocation__Latitude__s, sked__GeoLocation__Longitude__s, sked__GeoLocation__c,
                                            sked__Timezone__c, sked__Start__c, sked__Finish__c, sked__Duration__c, sked__Type__c, 
                                            sked__Job_Status__c, sked__Description__c, sked__Location__c, sked__Job_Allocation_Count__c,
                                            Special_Instructions__c, Number_of_Instructors__c, Course__c,  Course__r.Name,
                                            Class_Type__c, Course_Catalog__c, Course_Catalog__r.Name,
                                            Number_of_Students__c, Before_class_duration__c, After_class_duration__c,
                                            Remaining_Resources_to_be_Allocated__c
                                            FROM Jobs__r
                                            ORDER BY sked__Start__c, sked__Finish__c ASC)
                                           FROM Course__c
                                           WHERE Id IN :courseIds];
            
            Map<Id, courseModel> mapCourse = new Map<Id, courseModel>();
            Map<Id, jobModel> mapJob = new Map<Id, jobModel>();
            DateTime currentTime = system.now();

            for (Course__c skedCourse : skedCourses) {
                courseModel course = new courseModel(skedCourse);

                if (skedCourse.Jobs__r != NULL && !skedCourse.Jobs__r.isEmpty()) {
                    sked__Job__c firstSkedJob, lastSkedJob;
                    for (sked__Job__c skedJob : skedCourse.Jobs__r) {
                        if (skedJob.sked__Job_Status__c != skedConstants.JOB_STATUS_CANCELLED) {
                            if (firstSkedJob == NULL || firstSkedJob.sked__Start__c > skedJob.sked__Start__c) {
                                firstSkedJob = skedJob;
                            }
                            if (lastSkedJob == NULL || lastSkedJob.sked__Start__c < skedJob.sked__Start__c) {
                                lastSkedJob = skedJob;
                            }
                        }
                        if (skedJob.sked__Start__c < endTime && skedJob.sked__Finish__c > startTime) {
                            jobModel job = new jobModel(skedJob);
                            course.jobs.add(job);
                            mapJob.put(job.id, job);
                        }
                    }

                    if (firstSkedJob == NULL && lastSkedJob == NULL) {
                        course.status = skedConstants.JOB_STATUS_CANCELLED;
                    }
                    else {
                        course.firstJob = new jobModel(firstSkedJob);
                        course.lastJob = new jobModel(lastSkedJob);

                        if (firstSkedJob.sked__Start__c > currentTime) {
                            course.status = skedConstants.JOB_STATUS_DISPATCHED;
                        }
                        else {
                            if (lastSkedJob.sked__Start__c > currentTime) {
                                course.status = skedConstants.JOB_STATUS_IN_PROGRESS;
                            }
                            else {
                                course.status = skedConstants.JOB_STATUS_COMPLETE;   
                            }
                        }
                    }
                }
                
                mapCourse.put(skedCourse.Id, course);
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

            result.data = mapCourse.values();
        }
        catch (Exception ex) {
            result.getError(ex);
        }
        return result;
    }

    @remoteAction
    global static skedRemoteResultModel getCourseDetails(string courseId) {
        skedRemoteResultModel result = new skedRemoteResultModel();
        try {
            Course__c skedCourse = [SELECT Id, Name, Region__c, Max_Hours_Per_Day__c, Course_Catalog__c, 
                                    Course_Catalog__r.Name, Recurring_Schedule__c, Recurring_Schedule__r.Pattern__c, 
                                    Recurring_Schedule__r.Skip_Holidays__c, Start_Month__c,
                                    (SELECT Id, Name, sked__Start__c, sked__Finish__c, sked__Location__c,
                                     sked__Type__c, sked__Job_Status__c, Class_Type__c, 
                                     Number_of_Students__c, Number_of_Instructors__c
                                     FROM Jobs__r
                                     ORDER BY sked__Start__c, sked__Finish__c ASC)
                                    FROM Course__c
                                    WHERE Id = :courseId];
            sked__Region__c skedRegion = [SELECT Id, sked__Timezone__c FROM sked__Region__c 
                                          WHERE Id = :skedCourse.Region__c];
            string timezoneSidId = skedRegion.sked__Timezone__c;

            courseModel course = new courseModel(skedCourse);
            for (sked__Job__c skedJob : skedCourse.Jobs__r) {
                jobModel job = new jobModel();
                job.id = skedJob.Id;
                job.name = skedJob.Name;
                job.classType = skedJob.Class_Type__c;
                job.startTime = integer.valueOf(skedJob.sked__Start__c.format('Hmm', timezoneSidId));
                job.finishTime = integer.valueOf(skedJob.sked__Finish__c.format('Hmm', timezoneSidId));
                job.jobDate = skedJob.sked__Start__c.format(skedDateTimeUtils.DATE_ISO_FORMAT, timezoneSidId);
                job.jobType = skedJob.sked__Type__c;
                job.classType = skedJob.Class_Type__c;
                job.jobStatus = skedJob.sked__Job_Status__c;
                job.numberOfStudents = integer.valueOf(skedJob.Number_of_Students__c);
                job.numberOfInstructors = integer.valueOf(skedJob.Number_of_Instructors__c);
                job.facilityId = skedJob.sked__Location__c;
                course.jobs.add(job);
            }
            result.data = course;
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
                                    sked__Job_Status__c, sked__Description__c, sked__Location__c, sked__Job_Allocation_Count__c,
                                    Special_Instructions__c, Number_of_Instructors__c, Course__c, Course__r.Name,
                                    Class_Type__c, Course_Catalog__c, Course_Catalog__r.Name, 
                                    Number_of_Students__c, Before_class_duration__c, After_class_duration__c,
                                    Remaining_Resources_to_be_Allocated__c,
                                    (SELECT sked__Job__c, sked__Tag__c, sked__Tag__r.Name
                                     FROM sked__JobTags__r)
                                    FROM sked__Job__c
                                    WHERE Id = :jobId];
            jobModel job = new jobModel(skedJob);
            job.loadJobTags(skedJob.sked__JobTags__r);

            result.data = job;
        }
        catch (Exception ex) {
            result.getError(ex);
        }
        return result;
    }

    @remoteAction
    global static skedRemoteResultModel saveJob(jobSaveModel model) {
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
                sked__Start__c = jobStart,
                sked__Finish__c = jobFinish,
                sked__Duration__c = jobDuration,
                sked__Type__c = model.jobType,
                sked__Location__c = model.facilityId,
                sked__Address__c = skedLocation.sked__Address__c,
                sked__GeoLocation__Latitude__s = skedLocation.sked__GeoLocation__Latitude__s,
                sked__GeoLocation__Longitude__s = skedLocation.sked__GeoLocation__Longitude__s,
                Class_Type__c = model.classType,
                Number_of_Instructors__c = model.numberOfInstructors,
                Number_of_Students__c = model.numberOfStudents,
                Special_Instructions__c = model.specialInstructions,
                Before_class_duration__c = model.beforeClassDuration,
                After_class_duration__c = model.afterClassDuration
            );
            
            if (string.isBlank(model.id)) {
                Course__c skedCourse = [SELECT Id, Name, Recurring_Schedule__c
                                        FROM Course__c WHERE Id = :model.courseId];
                skedJob.Course__c = skedCourse.Id;
                skedJob.sked__Description__c = skedCourse.Name;
                skedJob.sked__Recurring_Schedule__c = skedCourse.Recurring_Schedule__c;
                skedJob.sked__Job_Status__c = skedConstants.JOB_STATUS_PENDING_ALLOCATION;
                skedJob.sked__Can_Be_Declined__c = FALSE;
                insert skedJob;
                
                if (model.tagIds != NULL && !model.tagIds.isEmpty()) {
                    List<sked__Job_Tag__c> skedJobTags = new  List<sked__Job_Tag__c>();
                    for (string tagId : model.tagIds) {
                        sked__Job_Tag__c skedJobTag = new sked__Job_Tag__c(
                            sked__Job__c = skedJob.Id,
                            sked__Tag__c = tagId
                        );
                        skedJobTags.add(skedJobTag);
                    }
                    insert skedJobTags;
                }
            }
            else {
                skedJob.Id = model.id;
                update skedJob;
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

    @remoteAction
    global static skedRemoteResultModel calculateDays(courseSaveModel model) {
        skedRemoteResultModel result = new skedRemoteResultModel();
        SavePoint sp = Database.setSavePoint();
        try {
            sked__Region__c skedRegion = [SELECT Id, sked__Timezone__c FROM sked__Region__c WHERE Id = :model.regionId];
            model.timezoneSidId = skedRegion.sked__Timezone__c;
            
            model.courseTemplate.courseClassTypes.sort();
            Set<string> setSameDayClassTypes = getSetSameDayClassTypes(model);

            integer durationToHaveBreak = 300;
            integer durationToHave2ndClass = 120;
            integer breakTime = 30;

            sked_Admin_Setting__c skedSetting = sked_Admin_Setting__c.getOrgDefaults();
            if (skedSetting.NAT_Min_Duration_to_have_break__c != NULL) {
                durationToHaveBreak = integer.valueOf(skedSetting.NAT_Min_Duration_to_have_break__c);
            }
            if (skedSetting.NAT_Min_Duration_for_2nd_class__c != NULL) {
                durationToHave2ndClass = integer.valueOf(skedSetting.NAT_Min_Duration_for_2nd_class__c);
            }
            if (skedSetting.NAT_Break_Time__c != NULL) {
                breakTime = integer.valueOf(skedSetting.NAT_Break_Time__c);
            }
            breakTime = model.maxHoursPerDay * 60 <= durationToHaveBreak ? 0 : breakTime;

            Map<Date, classDayModel> mapClassDay = new Map<Date, classDayModel>();
            classDayModel currentClassDay;

            Date dateIndex = system.today();
            
            for (integer i = 0; i < model.courseTemplate.courseClassTypes.size(); i++) {
                skedModels.courseClassType courseClassType = model.courseTemplate.courseClassTypes.get(i);
                integer classTypeStartInMinutes = skedDateTimeUtils.convertTimeNumberToMinutes(courseClassType.startTime);
                integer classTypeEndInMinutes = skedDateTimeUtils.convertTimeNumberToMinutes(courseClassType.endTime);
                integer classDuration = classTypeEndInMinutes - classTypeStartInMinutes;
                integer durationToCreateJob = integer.valueOf(courseClassType.totalHours * 60);
                
                jobModel sourceJob = new jobModel();
                sourceJob.classType = courseClassType.id;
                sourceJob.beforeClassDuration = model.beforeClassDuration;
                sourceJob.afterClassDuration = model.afterClassDuration;

                if (currentClassDay != NULL && !currentClassDay.jobs.isEmpty()) {
                    jobModel lastJob = currentClassDay.jobs.get(currentClassDay.jobs.size() - 1);
                    string samedayKey = courseClassType.id + '_' + lastJob.classType;
                    if (setSameDayClassTypes.contains(samedayKey)) {
                        integer jobDuration = currentClassDay.remainDuration - (lastJob.afterClassDuration + breakTime + sourceJob.beforeClassDuration);

                        if (jobDuration >= durationToHave2ndClass) {                        
                            if (jobDuration > durationToCreateJob) {
                                jobDuration = durationToCreateJob;
                            }

                            if (jobDuration > currentClassDay.remainDuration) {
                                jobDuration = currentClassDay.remainDuration;
                            }

                            if (jobDuration > durationToHaveBreak) {
                                if ((currentClassDay.remainDuration - jobDuration) >= breakTime) {
                                    jobDuration += breakTime;
                                }
                                durationToCreateJob += breakTime;
                            }

                            jobModel job = sourceJob.copy();
                            job.start = skedDateTimeUtils.addMinutes(lastJob.finish, lastJob.afterClassDuration + breakTime + job.beforeClassDuration, model.timezoneSidId);
                            job.finish = skedDateTimeUtils.addMinutes(job.start, jobDuration, model.timezoneSidId);
                            
                            integer jobEndTime = integer.valueOf(job.finish.format('Hmm', model.timezoneSidId));
                            integer jobEndTimeInMinutes = skedDateTimeUtils.convertTimeNumberToMinutes(jobEndTime);
                            if (jobEndTimeInMinutes > currentClassDay.endInMinutes) {
                                job.finish = skedDateTimeUtils.addMinutes(job.finish, currentClassDay.endInMinutes - jobEndTimeInMinutes, model.timezoneSidId);
                                jobDuration = jobDuration - (jobEndTimeInMinutes - currentClassDay.endInMinutes);
                            }

                            job.startTime = integer.valueOf(job.start.format('Hmm', model.timezoneSidId));
                            job.finishTime = integer.valueOf(job.finish.format('Hmm', model.timezoneSidId));
                            job.jobDate = job.start.format(skedDateTimeUtils.DATE_ISO_FORMAT, model.timezoneSidId);

                            currentClassDay.jobs.add(job);
                            currentClassDay.classTypes.add(job.classType);
                            currentClassDay.remainDuration -= jobDuration;
                            
                            durationToCreateJob -= jobDuration;

                            if (durationToCreateJob > 0) {
                                currentClassDay.remainDuration = 0;
                            }
                        }
                    }
                }

                while (durationToCreateJob > 0) {
                    if (currentClassDay == NULL || currentClassDay.remainDuration == 0 || !currentClassDay.classTypes.contains(courseClassType.id)) {
                        Date dateValue = dateIndex.addDays(mapClassDay.size());
                        currentClassDay = new classDayModel();
                        currentClassDay.dateValue = dateValue;
                        currentClassDay.dateStart = skedDateTimeUtils.getStartOfDate(dateValue, model.timezoneSidId);
                        currentClassDay.remainDuration = integer.valueOf(model.maxHoursPerDay * 60);
                        //currentClassDay.remainDuration = classTypeEndInMinutes - classTypeStartInMinutes;
                        currentClassDay.startInMinutes = classTypeStartInMinutes;
                        //currentClassDay.endInMinutes = classTypeEndInMinutes;
                        currentClassDay.endInMinutes = classTypeStartInMinutes + integer.valueOf(model.maxHoursPerDay * 60);
                        mapClassDay.put(dateValue, currentClassDay);
                    }

                    integer jobDuration = classDuration;
                    if (jobDuration > durationToCreateJob) {
                        jobDuration = durationToCreateJob;
                    }
                    if (jobDuration > currentClassDay.remainDuration) {
                        jobDuration = currentClassDay.remainDuration;
                    }
                    if (jobDuration > durationToHaveBreak) {
                        if ((currentClassDay.remainDuration - jobDuration) >= breakTime) {
                            jobDuration += breakTime;
                        }
                        durationToCreateJob += breakTime;
                    }

                    jobModel job = sourceJob.copy();
                    job.start = skedDateTimeUtils.addMinutes(currentClassDay.dateStart, classTypeStartInMinutes, model.timezoneSidId);
                    job.finish = skedDateTimeUtils.addMinutes(job.start, jobDuration, model.timezoneSidId);
                    
                    integer jobEndTime = integer.valueOf(job.finish.format('Hmm', model.timezoneSidId));
                    integer jobEndTimeInMinutes = skedDateTimeUtils.convertTimeNumberToMinutes(jobEndTime);
                    if (jobEndTimeInMinutes > classTypeEndInMinutes) {
                        job.finish = skedDateTimeUtils.addMinutes(job.finish, classTypeEndInMinutes - jobEndTimeInMinutes, model.timezoneSidId);
                        jobDuration = jobDuration - (jobEndTimeInMinutes - classTypeEndInMinutes);
                    }

                    job.duration = jobDuration;
                    job.startTime = integer.valueOf(job.start.format('Hmm', model.timezoneSidId));
                    job.finishTime = integer.valueOf(job.finish.format('Hmm', model.timezoneSidId));
                    job.jobDate = job.start.format(skedDateTimeUtils.DATE_ISO_FORMAT, model.timezoneSidId);

                    currentClassDay.jobs.add(job);
                    currentClassDay.classTypes.add(job.classType);
                    currentClassDay.remainDuration -= jobDuration;
                    durationToCreateJob -= jobDuration;

                    if (durationToCreateJob > 0) {
                        currentClassDay.remainDuration = 0;
                    }
                }
            }
            result.data = mapClassDay.size();
        }
        catch (Exception ex) {
            result.getError(ex);
            Database.rollback(sp);
        }
        return result;
    }

    @remoteAction
    global static skedRemoteResultModel getSuggestion(courseSaveModel model) {
        skedRemoteResultModel result = new skedRemoteResultModel();
        SavePoint sp = Database.setSavePoint();
        try {
            sked__Region__c skedRegion = [SELECT Id, sked__Timezone__c FROM sked__Region__c WHERE Id = :model.regionId];
            model.timezoneSidId = skedRegion.sked__Timezone__c;

            courseModel course = new courseModel();
            course.name = model.name;
            course.maxHoursPerDay = model.maxHoursPerDay;
            course.courseCatalogId = model.courseCatalogId;
            course.startMonth = model.startMonth;
            course.jobs = new List<jobModel>();

            jobModel sourceJob = new jobModel();
            sourceJob.courseCatalogId = model.courseCatalogId;
            sourceJob.specialInstructions = model.specialInstructions;
            sourceJob.numberOfStudents = model.numberOfStudents;
            sourceJob.beforeClassDuration = model.beforeClassDuration;
            sourceJob.afterClassDuration = model.afterClassDuration;

            //generating jobs
            model.courseTemplate.courseClassTypes.sort();
            Set<string> setSameDayClassTypes = getSetSameDayClassTypes(model);
            integer durationToHaveBreak = 300;
            integer durationToHave2ndClass = 120;
            integer breakTime = 30;

            sked_Admin_Setting__c skedSetting = sked_Admin_Setting__c.getOrgDefaults();
            if (skedSetting.NAT_Min_Duration_to_have_break__c != NULL) {
                durationToHaveBreak = integer.valueOf(skedSetting.NAT_Min_Duration_to_have_break__c);
            }
            if (skedSetting.NAT_Min_Duration_for_2nd_class__c != NULL) {
                durationToHave2ndClass = integer.valueOf(skedSetting.NAT_Min_Duration_for_2nd_class__c);
            }
            if (skedSetting.NAT_Break_Time__c != NULL) {
                breakTime = integer.valueOf(skedSetting.NAT_Break_Time__c);
            }
            breakTime = model.maxHoursPerDay * 60 <= durationToHaveBreak ? 0 : breakTime;

            Map<Date, classDayModel> mapClassDay = new Map<Date, classDayModel>();
            classDayModel currentClassDay;

            List<Date> selectedDates = new List<Date>();
            for (string dateIso : model.selectedDates) {
                Date dateValue = skedDateTimeUtils.getDateFromIsoString(dateIso);
                selectedDates.add(dateValue);
            }
            selectedDates.sort();

            Set<Id> locationIds = new Set<Id>();
            for (skedModels.courseClassType courseClassType : model.courseTemplate.courseClassTypes) {
                locationIds.add(courseClassType.facilityId);
            }

            Map<Id, sked__Location__c> mapLocation = new Map<Id, sked__Location__c>([SELECT Id, sked__Address__c, sked__GeoLocation__Latitude__s, sked__GeoLocation__Longitude__s
                                                                                     FROM sked__Location__c
                                                                                     WHERE Id IN :locationIds]);
            for (integer i = 0; i < model.courseTemplate.courseClassTypes.size(); i++) {
                skedModels.courseClassType courseClassType = model.courseTemplate.courseClassTypes.get(i);
                integer classTypeStartInMinutes = skedDateTimeUtils.convertTimeNumberToMinutes(courseClassType.startTime);
                integer classTypeEndInMinutes = skedDateTimeUtils.convertTimeNumberToMinutes(courseClassType.endTime);
                integer classDuration = classTypeEndInMinutes - classTypeStartInMinutes;
                integer durationToCreateJob = integer.valueOf(courseClassType.totalHours * 60);

                sked__Location__c skedLocation = mapLocation.get(courseClassType.facilityId);

                sourceJob.classType = courseClassType.id;
                sourceJob.numberOfInstructors = courseClassType.numberOfInstructors;
                sourceJob.facilityId = courseClassType.facilityId;
                sourceJob.address = skedLocation.sked__Address__c;
                sourceJob.lat = skedLocation.sked__GeoLocation__Latitude__s;
                sourceJob.lng = skedLocation.sked__GeoLocation__Longitude__s;

                if (currentClassDay != NULL && !currentClassDay.jobs.isEmpty()) {
                    jobModel lastJob = currentClassDay.jobs.get(currentClassDay.jobs.size() - 1);
                    string samedayKey = courseClassType.id + '_' + lastJob.classType;
                    
                    if (setSameDayClassTypes.contains(samedayKey)) {
                        integer jobDuration = currentClassDay.remainDuration - (lastJob.afterClassDuration + breakTime + sourceJob.beforeClassDuration);
                        
                        if (jobDuration >= durationToHave2ndClass) {
                            if (jobDuration > durationToCreateJob) {
                                jobDuration = durationToCreateJob;
                            }

                            if (jobDuration > currentClassDay.remainDuration) {
                                jobDuration = currentClassDay.remainDuration;
                            }
        
                            if (jobDuration > durationToHaveBreak) {
                                if ((currentClassDay.remainDuration - jobDuration) >= breakTime) {
                                    jobDuration += breakTime;
                                }
                                durationToCreateJob += breakTime;
                            }

                            jobModel job = sourceJob.copy();
                            job.start = skedDateTimeUtils.addMinutes(lastJob.finish, lastJob.afterClassDuration + breakTime + job.beforeClassDuration, model.timezoneSidId);
                            job.finish = skedDateTimeUtils.addMinutes(job.start, jobDuration, model.timezoneSidId);
                            
                            integer jobEndTime = integer.valueOf(job.finish.format('Hmm', model.timezoneSidId));
                            integer jobEndTimeInMinutes = skedDateTimeUtils.convertTimeNumberToMinutes(jobEndTime);
                            if (jobEndTimeInMinutes > currentClassDay.endInMinutes) {
                                job.finish = skedDateTimeUtils.addMinutes(job.finish, currentClassDay.endInMinutes - jobEndTimeInMinutes, model.timezoneSidId);
                                jobDuration = jobDuration - (jobEndTimeInMinutes - currentClassDay.endInMinutes);
                            }

                            job.duration = jobDuration;
                            job.startTime = integer.valueOf(job.start.format('Hmm', model.timezoneSidId));
                            job.finishTime = integer.valueOf(job.finish.format('Hmm', model.timezoneSidId));
                            job.jobDate = job.start.format(skedDateTimeUtils.DATE_ISO_FORMAT, model.timezoneSidId);

                            currentClassDay.jobs.add(job);
                            currentClassDay.classTypes.add(job.classType);
                            currentClassDay.remainDuration -= jobDuration;
                            durationToCreateJob -= jobDuration;

                            if (durationToCreateJob > 0) {
                                currentClassDay.remainDuration = 0;
                            }
                        }
                    }
                }

                while (durationToCreateJob > 0) {
                    if (currentClassDay == NULL || currentClassDay.remainDuration == 0 
                        || !currentClassDay.classTypes.contains(courseClassType.id)) {
                        Date dateValue = selectedDates.get(mapClassDay.size());
                        currentClassDay = new classDayModel();
                        currentClassDay.dateValue = dateValue;
                        currentClassDay.dateStart = skedDateTimeUtils.getStartOfDate(dateValue, model.timezoneSidId);
                        currentClassDay.remainDuration = integer.valueOf(model.maxHoursPerDay * 60);
                        //currentClassDay.remainDuration = classTypeEndInMinutes - classTypeStartInMinutes;
                        currentClassDay.startInMinutes = classTypeStartInMinutes;
                        //currentClassDay.endInMinutes = classTypeEndInMinutes;
                        currentClassDay.endInMinutes = classTypeStartInMinutes + integer.valueOf(model.maxHoursPerDay * 60);
                        mapClassDay.put(dateValue, currentClassDay);
                    }

                    integer jobDuration = classDuration;
                    if (jobDuration > durationToCreateJob) {
                        jobDuration = durationToCreateJob;
                    }
                    if (jobDuration > currentClassDay.remainDuration) {
                        jobDuration = currentClassDay.remainDuration;
                    }
                    if (jobDuration > durationToHaveBreak) {
                        if ((currentClassDay.remainDuration - jobDuration) >= breakTime) {
                            jobDuration += breakTime;
                        }
                        durationToCreateJob += breakTime;
                    }

                    jobModel job = sourceJob.copy();
                    job.start = skedDateTimeUtils.addMinutes(currentClassDay.dateStart, classTypeStartInMinutes, model.timezoneSidId);
                    job.finish = skedDateTimeUtils.addMinutes(job.start, jobDuration, model.timezoneSidId);
                    
                    integer jobEndTime = integer.valueOf(job.finish.format('Hmm', model.timezoneSidId));
                    integer jobEndTimeInMinutes = skedDateTimeUtils.convertTimeNumberToMinutes(jobEndTime);
                    if (jobEndTimeInMinutes > classTypeEndInMinutes) {
                        job.finish = skedDateTimeUtils.addMinutes(job.finish, classTypeEndInMinutes - jobEndTimeInMinutes, model.timezoneSidId);
                        jobDuration = jobDuration - (jobEndTimeInMinutes - classTypeEndInMinutes);
                    }
                    
                    job.duration = jobDuration;
                    job.startTime = integer.valueOf(job.start.format('Hmm', model.timezoneSidId));
                    job.finishTime = integer.valueOf(job.finish.format('Hmm', model.timezoneSidId));
                    job.jobDate = job.start.format(skedDateTimeUtils.DATE_ISO_FORMAT, model.timezoneSidId);

                    currentClassDay.jobs.add(job);
                    currentClassDay.classTypes.add(job.classType);
                    currentClassDay.remainDuration -= jobDuration;
                    durationToCreateJob -= jobDuration;

                    if (durationToCreateJob > 0) {
                        currentClassDay.remainDuration = 0;
                    }
                    
                    system.debug('#currentClassDay.remainDuration#' + currentClassDay.remainDuration);
                }
            }

            List<jobModel> allJobs = new List<jobModel>();
            for (classDayModel classDay : mapClassDay.values()) {
                allJobs.addAll(classDay.jobs);
            }
            course.jobs = allJobs;

            result.data = course;
        }
        catch (Exception ex) {
            result.getError(ex);
            Database.rollback(sp);
        }
        return result;
    }

    @remoteAction
    global static skedRemoteResultModel createCourse(courseModel course, courseSaveModel model) {
        skedRemoteResultModel result = new skedRemoteResultModel();
        SavePoint sp = Database.setSavePoint();
        try {
            sked__Region__c skedRegion = [SELECT Id, sked__Timezone__c FROM sked__Region__c WHERE Id = :model.regionId];
            string timezoneSidId = skedRegion.sked__Timezone__c;

            Course__c skedCourse = new Course__c(
                Name = model.name,
                Max_Hours_Per_Day__c = model.maxHoursPerDay,
                Course_Catalog__c = model.courseCatalogId,
                Start_Month__c = model.startMonth,
                Region__c = model.regionId
            );

            if (string.isBlank(course.id)) {
                sked__Recurring_Schedule__c skedSchedule = new sked__Recurring_Schedule__c(
                    Pattern__c = model.classPattern,
                    Skip_Holidays__c = model.skipHolidays
                );
                insert skedSchedule;

                skedCourse.Recurring_Schedule__c = skedSchedule.Id;
            }
            if (!string.isBlank(course.id)) {
                skedCourse.Id = course.id;
            }
            upsert skedCourse;

            Set<Id> facilityIds = new Set<Id>();
            for (jobModel job : course.jobs) {
                facilityIds.add(job.facilityId);
            }

            Map<Id, sked__Location__c> mapSkedLocation = 
                new Map<Id, sked__Location__c>([SELECT Id, sked__Address__c, sked__GeoLocation__Latitude__s,
                                                sked__GeoLocation__Longitude__s
                                                FROM sked__Location__c
                                                WHERE Id IN :facilityIds]);

            List<sked__Job__c> allSkedJobs = new List<sked__Job__c>();
            for (jobModel job : course.jobs) {
                Date jobDate = skedDateTimeUtils.getDateFromIsoString(job.jobDate);
                DateTime jobDateStart = skedDateTimeUtils.getStartOfDate(jobDate, timezoneSidId);
                    
                integer startTimeInMinutes = skedDateTimeUtils.convertTimeNumberToMinutes(job.startTime);
                DateTime jobStart = skedDateTimeUtils.addMinutes(jobDateStart, startTimeInMinutes, timezoneSidId);
                integer finishTimeInMinutes = skedDateTimeUtils.convertTimeNumberToMinutes(job.finishTime);
                DateTime jobFinish = skedDateTimeUtils.addMinutes(jobDateStart, finishTimeInMinutes, timezoneSidId);
                integer jobDuration = finishTimeInMinutes - startTimeInMinutes;

                sked__Location__c skedLocation = mapSkedLocation.get(job.facilityId);
                
                sked__Job__c skedJob = new sked__Job__c(
                    Course__c = skedCourse.Id,
                    Course_Catalog__c = model.courseCatalogId,
                    sked__Can_Be_Declined__c = false,
                    sked__Description__c = model.name,
                    sked__Region__c = model.regionId,
                    sked__Recurring_Schedule__c = skedCourse.Recurring_Schedule__c,
                    sked__Type__c = model.jobType,
                    sked__Job_Status__c = skedConstants.JOB_STATUS_PENDING_ALLOCATION,
                    sked__Start__c = jobStart,
                    sked__Finish__c = jobFinish,
                    sked__Duration__c = jobDuration,
                    sked__Location__c = job.facilityId,
                    sked__Address__c = skedLocation.sked__Address__c,
                    sked__GeoLocation__Latitude__s = skedLocation.sked__GeoLocation__Latitude__s,
                    sked__GeoLocation__Longitude__s = skedLocation.sked__GeoLocation__Longitude__s,
                    Class_Type__c = job.classType,
                    Special_Instructions__c = model.specialInstructions,
                    Number_of_Students__c = job.numberOfStudents,
                    Number_of_Instructors__c = job.numberOfInstructors,
                    Before_class_duration__c = model.beforeClassDuration,
                    After_class_duration__c = model.afterClassDuration
                );
                allSkedJobs.add(skedJob);
            }
            insert allSkedJobs;

            if (string.isBlank(course.id)) {
                skedJobService.insertJobTags(allSkedJobs, model.tagIds);
            }

            result.data = allSkedJobs.get(0).Id;
        }
        catch (Exception ex) {
            result.getError(ex);
            Database.rollback(sp);
        }
        return result;
    }

    @remoteAction
    global static skedRemoteResultModel editCourse(courseModel course, boolean confirm) {
        skedRemoteResultModel result = new skedRemoteResultModel();
        SavePoint sp = Database.setSavePoint();
        try {
            sked__Region__c skedRegion = [SELECT Id, sked__Timezone__c FROM sked__Region__c WHERE Id = :course.regionId];
            string timezoneSidId = skedRegion.sked__Timezone__c;

            Map<Id, sked__Job__c> mapCurrentSkedJob = 
                new Map<Id, sked__Job__c>([SELECT Id, Name, sked__Start__c, sked__Finish__c, sked__Job_Allocation_Count__c,
                                           sked__Location__c, Before_class_duration__c, After_class_duration__c,
                                           (SELECT sked__Tag__c
                                            FROM sked__JobTags__r),
                                           (SELECT sked__Resource__c, sked__UniqueKey__c
                                            FROM sked__Job_Allocations__r
                                            WHERE sked__Status__c != :skedConstants.JOB_ALLOCATION_STATUS_DELETED)
                                           FROM sked__Job__c
                                           WHERE Course__c = :course.id
                                           AND sked__Job_Status__c != :skedConstants.JOB_STATUS_CANCELLED]);
            Set<Id> facilityIds = new Set<Id>();
            for (jobModel job : course.jobs) {
                facilityIds.add(job.facilityId);
            }

            Map<Id, sked__Location__c> mapSkedLocation = 
                new Map<Id, sked__Location__c>([SELECT Id, sked__Address__c, sked__GeoLocation__Latitude__s,
                                                sked__GeoLocation__Longitude__s
                                                FROM sked__Location__c
                                                WHERE Id IN :facilityIds]);

            List<sked__Job__c> skedJobsToUpsert = new List<sked__Job__c>();
            List<sked__Job_Allocation__c> skedAllocsToUpdate = new List<sked__Job_Allocation__c>();
            
            Map<Id, skedModels.job> mapRescheduledJob = new Map<Id, skedModels.job>();
            Set<Id> rescheduledJobsResourceIds = new Set<Id>();
            Set<Id> excludedJobIds = new Set<Id>();
            Set<string> allocationKeys = new Set<string>();

            for (jobModel job : course.jobs) {
                Date jobDate = skedDateTimeUtils.getDateFromIsoString(job.jobDate);
                DateTime jobDateStart = skedDateTimeUtils.getStartOfDate(jobDate, timezoneSidId);
                    
                integer startTimeInMinutes = skedDateTimeUtils.convertTimeNumberToMinutes(job.startTime);
                DateTime jobStart = skedDateTimeUtils.addMinutes(jobDateStart, startTimeInMinutes, timezoneSidId);
                integer finishTimeInMinutes = skedDateTimeUtils.convertTimeNumberToMinutes(job.finishTime);
                DateTime jobFinish = skedDateTimeUtils.addMinutes(jobDateStart, finishTimeInMinutes, timezoneSidId);
                integer jobDuration = finishTimeInMinutes - startTimeInMinutes;

                sked__Location__c skedLocation = mapSkedLocation.get(job.facilityId);

                sked__Job__c skedJob = new sked__Job__c(
                    sked__Start__c = jobStart,
                    sked__Finish__c = jobFinish,
                    sked__Duration__c = jobDuration,
                    sked__Location__c = job.facilityId,
                    sked__Address__c = skedLocation.sked__Address__c,
                    sked__GeoLocation__Latitude__s = skedLocation.sked__GeoLocation__Latitude__s,
                    sked__GeoLocation__Longitude__s = skedLocation.sked__GeoLocation__Longitude__s,
                    sked__Type__c = job.jobType,
                    Special_Instructions__c = job.specialInstructions,
                    Number_of_Students__c = job.numberOfStudents,
                    Number_of_Instructors__c = job.numberOfInstructors,
                    Before_class_duration__c = job.beforeClassDuration,
                    After_class_duration__c = job.afterClassDuration,
                    Class_Type__c = job.classType
                );
                if (string.isBlank(job.id)) {
                    skedJob.Course__c = course.id;
                    skedJob.Course_Catalog__c = course.courseCatalogId;
                    skedJob.sked__Can_Be_Declined__c = false;
                    skedJob.sked__Description__c = course.name;
                    skedJob.sked__Region__c = course.regionId;
                    skedJob.sked__Recurring_Schedule__c = course.scheduleId;
                    skedJob.sked__Job_Status__c = skedConstants.JOB_STATUS_PENDING_ALLOCATION;
                }
                else {
                    skedJob.Id = job.id;
                    skedJob.sked__Job_Status__c = job.jobStatus;

                    if (mapCurrentSkedJob.containsKey(skedJob.Id)) {
                        sked__Job__c currentSkedJob = mapCurrentSkedJob.get(skedJob.Id);

                        if (currentSkedJob.sked__Job_Allocation_Count__c > 0) {
                            if (job.jobStatus == skedConstants.JOB_STATUS_CANCELLED) {
                                for (sked__Job_Allocation__c skedAlloc : currentSkedJob.sked__Job_Allocations__r) {
                                    skedAlloc.sked__Status__c = skedConstants.JOB_ALLOCATION_STATUS_DELETED;
                                    skedAllocsToUpdate.add(skedAlloc);
                                }
                            }
                            else if (currentSkedJob.sked__Start__c != skedJob.sked__Start__c || currentSkedJob.sked__Finish__c != skedJob.sked__Finish__c) {
                                skedModels.job rescheduledJob = new skedModels.job();
                                rescheduledJob.id = skedJob.Id;
                                rescheduledJob.name = currentSkedJob.Name;
                                rescheduledJob.start = skedJob.sked__Start__c;
                                rescheduledJob.finish = skedJob.sked__Finish__c;
                                rescheduledJob.geoLocation = Location.newInstance(skedJob.sked__GeoLocation__Latitude__s, skedJob.sked__GeoLocation__Longitude__s);

                                if (currentSkedJob.Before_class_duration__c != NULL) {
                                    rescheduledJob.start = skedDateTimeUtils.addMinutes(rescheduledJob.start, -1 * integer.valueOf(currentSkedJob.Before_class_duration__c), timezoneSidId);
                                }
                                if (currentSkedJob.After_class_duration__c != NULL) {
                                    rescheduledJob.finish = skedDateTimeUtils.addMinutes(rescheduledJob.finish, integer.valueOf(currentSkedJob.After_class_duration__c), timezoneSidId);
                                }

                                rescheduledJob.tags = new List<skedBaseModels.tag>();
                                for (sked__Job_Tag__c skedJobTag : currentSkedJob.sked__JobTags__r) {
                                    skedBaseModels.tag tag = new skedBaseModels.tag();
                                    tag.id = skedJobTag.sked__Tag__c;
                                    rescheduledJob.tags.add(tag);
                                }

                                mapRescheduledJob.put(rescheduledJob.id, rescheduledJob);

                                for (sked__Job_Allocation__c skedAlloc : currentSkedJob.sked__Job_Allocations__r) {
                                    rescheduledJobsResourceIds.add(skedAlloc.sked__Resource__c);
                                    allocationKeys.add(skedAlloc.sked__UniqueKey__c);
                                }
                                excludedJobIds.add(currentSkedJob.Id);
                            }
                        }
                    }
                }
                skedJobsToUpsert.add(skedJob);
            }

            List<skedModels.jobAllocation> conflictAllocations = new List<skedModels.jobAllocation>();
            if (!mapRescheduledJob.isEmpty()) {
                skedAvailatorParams params = new skedAvailatorParams();
                params.timezoneSidId = timezoneSidId;
                params.resourceIds = rescheduledJobsResourceIds;
                params.inputJobs = mapRescheduledJob.values();
                params.excludedJobIds = excludedJobIds;
                params.allocationKeys = allocationKeys;

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
            }

            boolean isConflict = !conflictAllocations.isEmpty();
            if (confirm || !isConflict) {
                upsert skedJobsToUpsert;

                if (!skedAllocsToUpdate.isEmpty()) {
                    update skedAllocsToUpdate;
                }

                if (isConflict) {
                    List<string> conflictAllocationKeys = new List<string>();
                    for (skedModels.jobAllocation conflictAllocation : conflictAllocations) {
                        conflictAllocationKeys.add(conflictAllocation.jobId + ':' + conflictAllocation.resourceId);
                    }

                    List<sked__Job_Allocation__c> conflictSkedAllocs = [SELECT Id
                                                                        FROM sked__Job_Allocation__c
                                                                        WHERE sked__UniqueKey__c IN :conflictAllocationKeys];
                    for (sked__Job_Allocation__c conflictSkedAlloc : conflictSkedAllocs) {
                        conflictSkedAlloc.sked__Status__c = skedConstants.JOB_ALLOCATION_STATUS_DELETED;
                    }
                    update conflictSkedAllocs;
                }
                skedJobService.updateJobStatus(mapRescheduledJob.keySet());

                result.data = new List<skedModels.jobAllocation>();
            }
            else {
                result.data = conflictAllocations;
            }
        }
        catch (Exception ex) {
            result.getError(ex);
            Database.rollback(sp);
        }
        return result;
    }

    @remoteAction
    global static skedRemoteResultModel cancelCourse(string courseId) {
        skedRemoteResultModel result = new skedRemoteResultModel();
        SavePoint sp = Database.setSavePoint();
        try {
            List<sked__Job__c> skedJobs = [SELECT Id, sked__Start__c, sked__Job_Status__c,
                                           (SELECT Id
                                            FROM sked__Job_Allocations__r
                                            WHERE sked__Status__c != :skedConstants.JOB_ALLOCATION_STATUS_DELETED)
                                           FROM sked__Job__c
                                           WHERE Course__c = :courseId
                                           ORDER BY sked__Start__c ASC];
            sked__Job__c firstSkedJob = skedJobs.get(0);
            DateTime currentTime = system.now();
            if (firstSkedJob.sked__Start__c < currentTime) {
                throw new skedException('Cannot cancel courses that already started.');
            }
            List<sked__Job__c> skedJobsToUpdate = new List<sked__Job__c>();
            List<sked__Job_Allocation__c> skedAllocationsToUpdate = new List<sked__Job_Allocation__c>();
            for (sked__Job__c skedJob : skedJobs) {
                if (skedJob.sked__Job_Status__c != skedConstants.JOB_STATUS_CANCELLED) {
                    skedJob.sked__Job_Status__c = skedConstants.JOB_STATUS_CANCELLED;
                    skedJobsToUpdate.add(skedJob);
                    for (sked__Job_Allocation__c skedAlloc : skedJob.sked__Job_Allocations__r) {
                        skedAlloc.sked__Status__c = skedConstants.JOB_ALLOCATION_STATUS_DELETED;
                        skedAllocationsToUpdate.add(skedAlloc);
                    }
                }
            }
            if (!skedJobsToUpdate.isEmpty()) {
                update skedJobsToUpdate;
            }
            if (!skedAllocationsToUpdate.isEmpty()) {
                update skedAllocationsToUpdate;
            }
        }
        catch (Exception ex) {
            result.getError(ex);
            Database.rollback(sp);
        }
        return result;
    }

    /**************************************************************** Private methods ***********************************************************************/
    private static Set<string> getSetSameDayClassTypes(courseSaveModel model) {
        Set<string> setSameDayClassTypes = new Set<string>();
        for (integer i = 1; i < model.courseTemplate.courseClassTypes.size(); i++) {
            skedModels.courseClassType classType = model.courseTemplate.courseClassTypes.get(i);
            if (classType.canBeSameDay == true) {
                skedModels.courseClassType previousClassType = model.courseTemplate.courseClassTypes.get(i - 1);
                setSameDayClassTypes.add(classType.id + '_' + previousClassType.id);    
            }
        }
        return setSameDayClassTypes;
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
    global class courseQueryModel {
        public string regionId {get;set;}
        public string startDateIso {get;set;} 
        public string endDateIso {get;set;}
    }

    global class courseModel {
        public string id {get;set;}
        public string name {get;set;}
        public string regionId {get;set;}
        public double maxHoursPerDay {get;set;}
        public string courseCatalogId {get;set;}
        public string courseCatalogName {get;set;}
        public string scheduleId {get;set;}
        public string classPattern {get;set;}
        public boolean skipHolidays {get;set;}
        public string startMonth {get;set;}
        public string status {get;set;}
        public List<jobModel> jobs {get;set;}
        public jobModel firstJob {get;set;}
        public jobModel lastJob {get;set;}

        public courseModel() {}

        public courseModel(Course__c skedCourse) {
            this.id = skedCourse.Id;
            this.name = skedCourse.Name;
            this.regionId = skedCourse.Region__c;
            this.maxHoursPerDay = skedCourse.Max_Hours_Per_Day__c;
            this.courseCatalogId = skedCourse.Course_Catalog__c;
            this.courseCatalogName = skedCourse.Course_Catalog__r.Name;
            this.scheduleId = skedCourse.Recurring_Schedule__c;
            this.classPattern = skedCourse.Recurring_Schedule__r.Pattern__c;
            this.skipHolidays = skedCourse.Recurring_Schedule__r.Skip_Holidays__c;
            this.startMonth = skedCourse.Start_Month__c;

            this.jobs = new List<jobModel>();
        }
    }

    global class jobModel extends skedModels.job {
        public string courseId {get;set;}
        public string courseName {get;set;}
        public string classType {get;set;}
        public string facilityId {get;set;}
        public integer numberOfInstructors {get;set;}
        public boolean hasAllocation {get;set;}
        public integer numberOfStudents {get;set;}

        public jobModel() {}

        public jobModel(sked__Job__c skedJob) {
            super(skedJob);
            this.courseId = skedJob.Course__c;
            this.courseName = skedJob.Course__r.Name;
            this.classType = skedJob.Class_Type__c;
            this.facilityId = skedJob.sked__Location__c;
            this.courseCatalogId = skedJob.Course_Catalog__c;
            this.courseCatalogName = skedJob.Course_Catalog__r.Name;
            this.numberOfStudents = integer.valueOf(skedJob.Number_of_Students__c);
            this.numberOfInstructors = integer.valueOf(skedJob.Number_of_Instructors__c);
            this.specialInstructions = skedJob.Special_Instructions__c;
            this.beforeClassDuration = integer.valueOf(skedJob.Before_class_duration__c);
            this.afterClassDuration = integer.valueOf(skedJob.After_class_duration__c);
            this.hasAllocation = skedJob.sked__Job_Allocation_Count__c > 0;
        }

        public jobModel copy() {
            jobModel copied = new jobModel();
            copied.timezoneSidId = this.timezoneSidId;
            copied.courseCatalogId = this.courseCatalogId;
            copied.specialInstructions = this.specialInstructions;
            copied.beforeClassDuration = this.beforeClassDuration;
            copied.afterClassDuration = this.afterClassDuration;
            copied.regionId = this.regionId;
            copied.jobType = this.jobType;
            copied.address = this.address;
            copied.facilityId = this.facilityId;
            copied.lat = this.lat;
            copied.lng = this.lng;
            copied.classType = this.classType;
            copied.numberOfStudents = this.numberOfStudents;
            copied.numberOfInstructors = this.numberOfInstructors;

            return copied;
        }
    }

    global class jobSaveModel {
        public string id {get;set;}
        public string regionId {get;set;}
        public string courseId {get;set;}
        public string courseCatalogId {get;set;}
        public string classType {get;set;}
        public string jobType {get;set;}
        public string specialInstructions {get;set;}
        public string facilityId {get;set;}
        public integer numberOfInstructors {get;set;}
        public integer numberOfStudents {get;set;}
        public List<string> tagIds {get;set;}
        
        public string selectedDate {get;set;}
        public integer startTime {get;set;}
        public integer finishTime {get;set;}
        public integer beforeClassDuration {get;set;}
        public integer afterClassDuration {get;set;}
        
        public transient string timezoneSidId {get;set;}
    }

    global class courseSaveModel {
        //creation step 1
        public string name {get;set;}
        public string jobType {get;set;}
        public string courseCatalogId {get;set;}
        public List<string> tagIds {get;set;}
        public string specialInstructions {get;set;}
        public string regionId {get;set;}
        public integer numberOfStudents {get;set;}
        public string startMonth {get;set;}
        public integer beforeClassDuration {get;set;}
        public integer afterClassDuration {get;set;}

        //creation step 2
        public skedModels.courseTemplate courseTemplate {get;set;}
        public decimal maxHoursPerDay {get;set;}

        //creation step 3
        public string classPattern {get;set;}
        public List<string> selectedDates {get;set;}
        public string notes {get;set;}
        public boolean skipHolidays {get;set;}

        //for backend only
        public transient string scheduleId {get;set;}
        public transient string courseId {get;set;}
        public transient string timezoneSidId {get;set;}
    }

    global class classDayModel {
        public Date dateValue {get;set;}
        public DateTime dateStart {get;set;}
        public Set<string> classTypes {get;set;}
        public integer remainDuration {get;set;}
        public List<jobModel> jobs {get;set;}
        public integer startInMinutes {get;set;}
        public integer endInMinutes {get;set;}

        public classDayModel() {
            this.jobs = new List<jobModel>();
            this.classTypes = new Set<string>();
        }
    }

    global class configDataModel {
        public List<skedModels.courseCatalog> courseCatalogs {get;set;}
        public List<skedModels.selectOption> regions {get;set;}
        public List<skedModels.selectOption> tags {get;set;}
        public List<skedModels.jobStatusSetting> jobStatusSettings {get;set;}
        public Map<string, Set<skedModels.selectOption>> mapHolidays {get;set;}
        public List<skedModels.facility> locations {get;set;}
        public List<skedModels.courseTemplate> courseTemplates {get;set;}
        public skedModels.permissionModel userPermission {get;set;}
        public skedModels.natClassSetting natClassSetting {get;set;}
        public List<skedModels.selectOption> jobTypes {get;set;}

        public configDataModel() {
            this.regions = new List<skedModels.selectOption>();
            this.courseCatalogs = new List<skedModels.courseCatalog>();
            this.tags = new List<skedModels.selectOption>();
            this.jobStatusSettings = new List<skedModels.jobStatusSetting>();
            this.mapHolidays = new Map<string, Set<skedModels.selectOption>>();
            this.locations = new List<skedModels.facility>();
            this.courseTemplates = new List<skedModels.courseTemplate>();
        }
    }
    
}