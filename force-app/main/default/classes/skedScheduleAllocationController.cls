global class skedScheduleAllocationController {

    global skedScheduleAllocationController(skedFullServiceBookingGridController ctrl) {}
    global skedScheduleAllocationController(skedCommunitySchedulingController ctrl) {}
    global skedScheduleAllocationController(skedCepSchedulingController ctrl) {}
    global skedScheduleAllocationController(skedNatSchedulingController ctrl) {}
    
    global skedScheduleAllocationController(){}

    @remoteAction
    global static skedRemoteResultModel getAllocationConfigData(string rootRecordId) {
        skedRemoteResultModel result = new skedRemoteResultModel();
        try {
            configDataModel configData = new configDataModel();
            string regionId;

            string rootRecordObjApiName = Id.valueOf(rootRecordId).getSobjectType().getDescribe().getName();

            if (rootRecordObjApiName == Training_Events__c.getSobjectType().getDescribe().getName()) {
                Training_Events__c skedTrainingEvent = [SELECT Id, Name, Region__c,
                                                        (SELECT Id
                                                         FROM Jobs__r
                                                         WHERE sked__Job_Status__c != :skedConstants.JOB_STATUS_CANCELLED)
                                                        FROM Training_Events__c
                                                        WHERE Id = :rootRecordId];
                if (skedTrainingEvent.Jobs__r == NULL || skedTrainingEvent.Jobs__r.isEmpty()) {
                    throw new skedException('This training event has not been scheduled yet.');
                }
                regionId = skedTrainingEvent.Region__c;
            }
            else if (rootRecordObjApiName == sked__Job__c.getSobjectType().getDescribe().getName()) {
                sked__Job__c skedJob = [SELECT Id, sked__Region__c FROM sked__Job__c WHERE Id = :rootRecordId];
                regionId = skedJob.sked__Region__c;
            }
            configData.regions = skedUtils.getRegions(regionId);
            configData.jobStatusSettings = skedUtils.getJobStatusSettings();
            configData.userPermission = getUserPermissions();
            configData.natClassSetting = skedARCUtils.getNatSetting();
            
            result.data = configData;
        }
        catch (Exception ex) {
            result.getError(ex);
        }
        return result;
    }
    
    @remoteAction
    global static skedRemoteResultModel getScheduleAllocationModel(string rootRecordId) {
        skedRemoteResultModel result = new skedRemoteResultModel();
        try {
            scheduleAllocationModel model = initializeScheduleAllocationModel(rootRecordId);
            getAvailableAllocations(model);
            populateScheduleInfo(model);
            calculateResourceHours(model);

            result.data = model;
        }
        catch (Exception ex) {
            result.getError(ex);
        }
        return result;
    }

    @remoteAction
    global static skedRemoteResultModel saveAllocations(List<jobModel> jobs, boolean notifyResourceOnSave) {
        skedRemoteResultModel result = new skedRemoteResultModel();
        SavePoint sp = Database.setSavePoint();
        try {
            List<sked__Job_Allocation__c> skedAllocsToInsert = new List<sked__Job_Allocation__c>();
            List<sked__Job_Allocation__c> skedAllocsToUpdate = new List<sked__Job_Allocation__c>();

            Map<Id, jobModel> mapJobModel = new Map<Id, jobModel>();
            for (jobModel job : jobs) {
                mapJobModel.put(job.id, job);
                for (skedModels.jobAllocation allocation : job.allocations) {
                    if (string.isBlank(allocation.action)) {
                        continue;
                    }
                    if (allocation.action == 'create') {
                        sked__Job_Allocation__c skedAlloc = new sked__Job_Allocation__c(
                            sked__Job__c = allocation.jobId,
                            sked__Resource__c = allocation.resourceId,
                            sked__Estimated_Travel_Time__c = allocation.travelTimeFrom,
                            Estimated_Travel_Distance__c = allocation.distance,
                            sked__Status__c = skedConstants.JOB_ALLOCATION_STATUS_PENDING_DISPATCH,
                            Number_of_Resources__c = allocation.numberOfResources
                        );
                        skedAllocsToInsert.add(skedAlloc);
                    }
                    else if (allocation.action == 'update') {
                        sked__Job_Allocation__c skedAlloc = new sked__Job_Allocation__c(
                            Id = allocation.id,
                            Number_of_Resources__c = allocation.numberOfResources
                        );
                        skedAllocsToUpdate.add(skedAlloc);
                    }
                    else if (allocation.action == 'delete') {
                        sked__Job_Allocation__c skedAlloc = new sked__Job_Allocation__c(
                            Id = allocation.id,
                            sked__Status__c = skedConstants.JOB_ALLOCATION_STATUS_DELETED
                        );
                        skedAllocsToUpdate.add(skedAlloc);
                    }
                }
            }

            if (!skedAllocsToInsert.isEmpty()) {
                insert skedAllocsToInsert;
            }
            if (!skedAllocsToUpdate.isEmpty()) {
                update skedAllocsToUpdate;
            }

            List<sked__Job__c> skedJobs = [SELECT Id, Number_of_Instructors__c, Number_of_Evaluators__c, Location_Confirmed__c, Ready_to_Publish__c,
                                           sked__Job_Status__c, sked__Job_Allocation_Count__c, sked__Type__c,
                                           (SELECT Id, sked__Team_Leader__c, sked__Status__c,
                                            sked__Resource__c, sked__Resource__r.Employment_Type__c
                                            FROM sked__Job_Allocations__r
                                            WHERE sked__Status__c != :skedConstants.JOB_ALLOCATION_STATUS_DELETED)
                                           FROM sked__Job__c
                                           WHERE Id IN :mapJobModel.keySet()];
            //update team leader
            skedAllocsToUpdate = new List<sked__Job_Allocation__c>();
            for (sked__Job__c skedJob : skedJobs) {
                jobModel job = mapJobModel.get(skedJob.Id);
                for (sked__Job_Allocation__c skedAlloc : skedJob.sked__Job_Allocations__r) {
                    boolean isUpdated = false;
                    if (skedAlloc.sked__Team_Leader__c == TRUE && skedAlloc.sked__Resource__c != job.teamLeadResourceId) {
                        skedAlloc.sked__Team_Leader__c = FALSE;
                        isUpdated = true;
                    }
                    if (skedAlloc.sked__Resource__c == job.teamLeadResourceId && skedAlloc.sked__Team_Leader__c == FALSE) {
                        skedAlloc.sked__Team_Leader__c = TRUE;
                        isUpdated = true;
                    }
                    if (skedAlloc.sked__Status__c == skedConstants.JOB_ALLOCATION_STATUS_PENDING_DISPATCH) {
                        if (skedAlloc.sked__Resource__r.Employment_Type__c == skedConstants.RESOURCE_EMPLOYMENT_TYPE_SUBCONTRACTOR) {
                            skedAlloc.sked__Status__c = skedConstants.JOB_ALLOCATION_STATUS_DISPATCHED;
                            isUpdated = true;
                        }
                    }

                    if (isUpdated == true) {
                        skedAllocsToUpdate.add(skedAlloc);
                    }
                }
            }
            if (!skedAllocsToUpdate.isEmpty()) {
                update skedAllocsToUpdate;
            }

            //update job status
            Map<Id, sked__Job__c> mapSkedJobsToUpdate = new Map<Id, sked__Job__c>();
            Set<Id> jobIdsToUpdateStatus = new Set<Id>();
            skedAllocsToUpdate = new List<sked__Job_Allocation__c>();
			
            for (sked__Job__c skedJob : skedJobs) {
                jobModel job = mapJobModel.get(skedJob.Id);
                if (skedJob.sked__Type__c == skedConstants.JOB_TYPE_COMMUNITY && skedJob.Location_Confirmed__c != job.locationConfirmed) {
                    skedJob.Location_Confirmed__c = job.locationConfirmed;
                    mapSkedJobsToUpdate.put(skedJob.Id, skedJob);
                }
                if (skedJob.sked__Type__c.contains(skedConstants.JOB_TYPE_NURSE_ASSISTANT_TESTING) && skedJob.Ready_to_Publish__c != job.readyToPublish) {
                    skedJob.Ready_to_Publish__c = job.readyToPublish;
                    mapSkedJobsToUpdate.put(skedJob.Id, skedJob);
                }
                if (notifyResourceOnSave) {
                    for (sked__Job_Allocation__c skedAlloc : skedJob.sked__Job_Allocations__r) {
                        if (skedAlloc.sked__Status__c == skedConstants.JOB_ALLOCATION_STATUS_PENDING_DISPATCH) {
                            skedAlloc.sked__Status__c = skedConstants.JOB_ALLOCATION_STATUS_DISPATCHED;
                            skedAllocsToUpdate.add(skedAlloc);
                        }
                    }
                }
                else {
                    jobIdsToUpdateStatus.add(skedJob.Id);
                }
            }
            if (!mapSkedJobsToUpdate.isEmpty()) {
                update mapSkedJobsToUpdate.values();
            }
            if (!jobIdsToUpdateStatus.isEmpty()) {
                skedJobService.updateJobStatus(jobIdsToUpdateStatus);
            }
            if (!skedAllocsToUpdate.isEmpty()) {
                update skedAllocsToUpdate;
            }
        }
        catch (Exception ex) {
            result.getError(ex);
            Database.rollback(sp);
        }
        return result;
    }
    
    /**************************************************************** Private methods ***********************************************************************/
    private static scheduleAllocationModel initializeScheduleAllocationModel(string rootRecordId) {
        scheduleAllocationModel result = new scheduleAllocationModel();
        result.jobIds = new Set<Id>();

        string rootRecordObjApiName = Id.valueOf(rootRecordId).getSobjectType().getDescribe().getName();
        if (rootRecordObjApiName == Training_Events__c.getSobjectType().getDescribe().getName()) {
            Training_Events__c skedTrainingEvent = [SELECT Id, Name, Region__r.sked__Timezone__c,
                                                    (SELECT Id, Pattern__c, Frequency__c
                                                     FROM Recurring_Schedules__r),
                                                    (SELECT Id 
                                                     FROM Jobs__r
                                                     WHERE sked__Job_Status__c != :skedConstants.JOB_STATUS_CANCELLED)
                                                    FROM Training_Events__c
                                                    WHERE Id = :rootRecordId];
            if (!skedTrainingEvent.Recurring_Schedules__r.isEmpty()) {
                result.scheduleId = skedTrainingEvent.Recurring_Schedules__r.get(0).Id;
            }
            for (sked__Job__c skedJob : skedTrainingEvent.Jobs__r) {
                result.jobIds.add(skedJob.Id);
            }
        }
        else if (rootRecordObjApiName == sked__Job__c.getSobjectType().getDescribe().getName()) {
            sked__Job__c skedJob = [SELECT Id, sked__Region__c, sked__Region__r.sked__Timezone__c, 
                                    sked__Recurring_Schedule__c, Course__c
                                    FROM sked__Job__c 
                                    WHERE Id = :rootRecordId];
            result.scheduleId = skedJob.sked__Recurring_Schedule__c;
            result.courseId = skedJob.Course__c;

            if (result.scheduleId == NULL) {
                result.jobIds.add(skedJob.Id);   
            }
            else {
                Map<Id, sked__Job__c> mapRecurringJobs = new Map<Id, sked__Job__c>([SELECT Id 
                                                                                    FROM sked__Job__c 
                                                                                    WHERE sked__Recurring_Schedule__c = :skedJob.sked__Recurring_Schedule__c]);
                result.jobIds = mapRecurringJobs.keySet();
            }
        }
        return result;
    }

    private static void getAvailableAllocations(scheduleAllocationModel model) {
        model.skedJobs = [SELECT Id, Name, sked__Region__c, sked__Address__c, sked__Contact__c, sked__Recurring_Schedule__c,
                          sked__Description__c, sked__GeoLocation__Latitude__s, sked__GeoLocation__Longitude__s, sked__GeoLocation__c,
                          sked__Timezone__c, sked__Start__c, sked__Finish__c, sked__Duration__c, sked__Type__c, sked__Job_Status__c,
                          sked__Location__c, sked__Location__r.Name, Number_of_Instructors__c, Number_of_Evaluators__c, Number_of_Students__c, 
                          Course_Catalog__r.Name, Location_Confirmed__c, Class_Type__c, Class_Type__r.Class_Type__c, 
                          Course__c, Before_class_duration__c, After_class_duration__c, Remaining_Resources_to_be_Allocated__c,
                          Ready_to_Publish__c,
                          (SELECT sked__Job__c, sked__Tag__c, sked__Tag__r.Name
                           FROM sked__JobTags__r),
                          (SELECT sked__Job__c, sked__Resource__c, sked__Resource__r.Name, sked__Resource__r.sked__User__r.SmallPhotoUrl,
                           sked__Team_Leader__c, Number_of_Resources__c
                           FROM sked__Job_Allocations__r
                           WHERE sked__Status__c != :skedConstants.JOB_ALLOCATION_STATUS_DELETED)
                          FROM sked__Job__c
                          WHERE Id IN :model.jobIds
                          AND sked__Job_Status__c != :skedConstants.JOB_STATUS_CANCELLED
                          ORDER BY sked__Start__c ASC];
        sked__Job__c firstSkedJob = model.skedJobs.get(0);
        model.timezoneSidId = firstSkedJob.sked__Timezone__c;
        Map<Id, jobModel> mapJob = new Map<Id, jobModel>();
        for (sked__Job__c skedJob : model.skedJobs) {
            jobModel job = new jobModel(skedJob);
            job.loadJobTags(skedJob.sked__JobTags__r);

            if (skedJob.Before_class_duration__c != NULL && skedJob.Before_class_duration__c > 0) {
                job.start = skedDateTimeUtils.addMinutes(job.start, -1 * integer.valueOf(skedJob.Before_class_duration__c), model.timezoneSidId);
            }
            if (skedJob.After_class_duration__c != NULL && skedJob.After_class_duration__c > 0) {
                job.finish = skedDateTimeUtils.addMinutes(job.finish, integer.valueOf(skedJob.After_class_duration__c), model.timezoneSidId);
            }
            
            for (sked__Job_Allocation__c skedAlloc : skedJob.sked__Job_Allocations__r) {
                skedModels.jobAllocation allocation = new skedModels.jobAllocation();
                allocation.id = skedAlloc.Id;
                allocation.jobId = skedAlloc.sked__Job__c;
                allocation.resourceId = skedAlloc.sked__Resource__c;
                allocation.resource = new skedModels.resource();
                allocation.resource.id = skedAlloc.sked__Resource__c;
                allocation.resource.name = skedAlloc.sked__Resource__r.Name;
                if (skedAlloc.sked__Resource__r.sked__User__c != NULL) {
                    allocation.resource.photoUrl = skedAlloc.sked__Resource__r.sked__User__r.SmallPhotoUrl;
                }
                
                allocation.numberOfResources = integer.valueOf(skedAlloc.Number_of_Resources__c);

                job.allocations.add(allocation);

                if (skedAlloc.sked__Team_Leader__c == TRUE) {
                    job.teamLeadResourceId = skedAlloc.sked__Resource__c;
                }
            }
            mapJob.put(skedJob.Id, job);
        }

        List<string> resourceCategories = new List<string>();
        if (firstSkedJob.sked__Type__c.contains(skedConstants.JOB_TYPE_NURSE_ASSISTANT_TESTING)) {
            resourceCategories.add(skedConstants.RESOURCE_CATEGORY_EVALUATOR);
            resourceCategories.add(skedConstants.RESOURCE_CATEGORY_CHARGE_NURSE);
            resourceCategories.add(skedConstants.RESOURCE_CATEGORY_PROCTOR);
        }
        else if (firstSkedJob.sked__Type__c.contains(skedConstants.JOB_TYPE_NURSE_ASSISTANT_TRAINING)) {
            resourceCategories.add(skedConstants.RESOURCE_CATEGORY_NURSE_INSTRUCTOR);
        }
        else {
            resourceCategories.add(skedConstants.RESOURCE_CATEGORY_INSTRUCTOR);
        }

        Map<Id, sked__Resource__c> mapSkedResource = skedUtils.getMapResources('all', resourceCategories);

        Set<Id> resourceIds = mapSkedResource.keySet();
        //get resources within 200 miles radius of first job only
        Location firstJobLocation = Location.newInstance(firstSkedJob.sked__GeoLocation__Latitude__s, firstSkedJob.sked__GeoLocation__Longitude__s);
        resourceIds = skedUtils.getResourceIdsByRadius(resourceIds, 200, firstJobLocation);
        
        skedAvailatorParams params = new skedAvailatorParams();
        params.timezoneSidId = model.timezoneSidId;
        params.resourceIds = mapSkedResource.keySet();
        params.inputJobs = mapJob.values();
        params.excludedJobIds = mapJob.keySet();
        
        skedAvailator availator = new skedAvailator(params);
        availator.validateJobs();
        
        model.availableAllocations = availator.getAvailableAllocations();
        Map<Id, skedModels.resource> mapResource = new Map<Id, skedModels.resource>();
        for (skedModels.jobAllocation availableAllocation : model.availableAllocations) {
            if (!mapResource.containsKey(availableAllocation.resourceId)) {
                mapResource.put(availableAllocation.resourceId, availableAllocation.resource);
            }
            availableAllocation.resource = null;
            
            jobModel job = mapJob.get(availableAllocation.jobId);
            job.possibleAllocations.add(availableAllocation);
            
            skedModels.resource resource = mapResource.get(availableAllocation.resourceId);
            resource.noOfAvailableClasses++;

            if (resource.firstJobAllocation == null || resource.firstJobAllocation.job.start > job.start) {
                resource.firstJobAllocation = availableAllocation;
            }
        }
        
        model.jobs = mapJob.values();
        model.resources = mapResource.values();

        sked_Admin_Setting__c adminSetting = sked_Admin_Setting__c.getOrgDefaults();
        if (adminSetting.Google_Travel_Time_Enabled__c == TRUE) {
            applyGoogleTravelTime(model.resources);
        }
        if (!firstSkedJob.sked__Type__c.contains(skedConstants.JOB_TYPE_NURSE_ASSISTANT_TESTING)
            && !firstSkedJob.sked__Type__c.contains(skedConstants.JOB_TYPE_NURSE_ASSISTANT_TRAINING)) {
            List<skedModels.resource> subcontractors = getSubcontractors();
            model.resources.addAll(subcontractors);
        }

        model.mapJob = mapJob;
        model.mapResource = mapResource;
    }

    private static void applyGoogleTravelTime(List<skedModels.resource> resources) {
        resources.sort();
        
        List<skedModels.resource> resourcesToApplyGoogle = new List<skedModels.resource>();
        for (integer i = 0; i < 50; i++) {
            if (i == resources.size()) {
                break;
            }
            resourcesToApplyGoogle.add(resources.get(i));
        }

        Map<Id, skedBaseModels.geometry> map_jobId_geometry = new Map<Id, skedBaseModels.geometry>();
        Map<Id, List<skedModels.jobAllocation>> map_jobId_allocations = new Map<Id, List<skedModels.jobAllocation>>();
        
        for (skedModels.resource resource : resourcesToApplyGoogle) {
            skedModels.jobAllocation allocation = resource.firstJobAllocation;
            if (!map_jobId_geometry.containsKey(allocation.jobId)) {
                skedBaseModels.geometry geometry = new skedBaseModels.geometry();
                geometry.lat = allocation.job.geoLocation.getLatitude();
                geometry.lng = allocation.job.geoLocation.getLongitude();

                map_jobId_geometry.put(allocation.jobId, geometry);
            }

            List<skedModels.jobAllocation> allocations;
            if (map_jobId_allocations.containsKey(allocation.jobId)) {
                allocations = map_jobId_allocations.get(allocation.jobId);
            }
            else {
                allocations = new List<skedModels.jobAllocation>();
                map_jobId_allocations.put(allocation.jobId, allocations);
            }
            allocations.add(allocation);
        }

        skedGoogleTravelTimeService travelTimeService = new skedGoogleTravelTimeService();

        List<skedGoogleTravelTimeService.distanceMatrixRequest> allRequests = new List<skedGoogleTravelTimeService.distanceMatrixRequest>();
        for (Id jobId : map_jobId_allocations.keySet()) {
            List<skedBaseModels.geometry> origins = new List<skedBaseModels.geometry>();
            List<skedModels.jobAllocation> allocations = map_jobId_allocations.get(jobId);
            for (skedModels.jobAllocation allocation : allocations) {
                if (allocation.startFromLocation != NULL) {
                    origins.add(allocation.startFromLocation);
                }
            }

            if (!origins.isEmpty()) {
                List<skedBaseModels.geometry> destinations = new List<skedBaseModels.geometry>();
                skedBaseModels.geometry jobGeometry = map_jobId_geometry.get(jobId);
                destinations.add(jobGeometry);
                List<skedGoogleTravelTimeService.distanceMatrixRequest> requests = travelTimeService.getRequestList(origins, destinations);
                allRequests.addAll(requests);
            }
        }

        travelTimeService.initialize(allRequests);

        for (skedModels.resource resource : resourcesToApplyGoogle) {
            skedModels.jobAllocation allocation = resource.firstJobAllocation;
            if (allocation.startFromLocation != NULL) {
                Location startFromGeoLocation = Location.newInstance(allocation.startFromLocation.lat, allocation.startFromLocation.lng);
                skedBaseModels.journeyModel journey = travelTimeService.getJourney(startFromGeoLocation, allocation.job.geoLocation);
                if (journey != NULL) {
                    if (journey.travelTime != NULL && journey.distance != NULL) {
                        allocation.travelTimeFrom = (journey.travelTime / 60);
                        allocation.distance = (journey.distance / 1609.34);
                        resource.isAppliedGoogle = true;
                    }
                }
            }
        }
    }

    private static void populateScheduleInfo(scheduleAllocationModel model) {
        sked__Job__c firstSkedJob = model.skedJobs.get(0);

        model.numberOfClasses = model.skedJobs.size();
        if (firstSkedJob.Number_of_Instructors__c != NULL) {
            model.numberOfInstructors = integer.valueOf(firstSkedJob.Number_of_Instructors__c);
        }
        if (firstSkedJob.Number_of_Evaluators__c != NULL) {
            model.numberOfEvaluators = integer.valueOf(firstSkedJob.Number_of_Evaluators__c);
        }
        model.numberOfStudents = integer.valueOf(firstSkedJob.Number_of_Students__c);
        model.classStartTime = integer.valueOf(firstSkedJob.sked__Start__c.format('Hmm', model.timezoneSidId));
        model.classDuration = integer.valueOf(firstSkedJob.sked__Duration__c);
        model.classStartDateIso = firstSkedJob.sked__Start__c.format(skedDateTimeUtils.DATE_ISO_FORMAT, model.timezoneSidId);
        model.address = firstSkedJob.sked__Address__c;
        model.lat = firstSkedJob.sked__GeoLocation__Latitude__s;
        model.lng = firstSkedJob.sked__GeoLocation__Longitude__s;
        model.courseCatalogName = firstSkedJob.Course_Catalog__r.Name;
        model.jobType = firstSkedJob.sked__Type__c;
        model.className = firstSkedJob.sked__Description__c;
        
        if (model.scheduleId != NULL) {
            sked__Recurring_Schedule__c skedSchedule = [SELECT Id, Pattern__c, Frequency__c
                                                        FROM sked__Recurring_Schedule__c
                                                        WHERE Id = :model.scheduleId];
            if (!string.isBlank(skedSchedule.Pattern__c)) {
                model.weekdays = skedSchedule.Pattern__c.split(';');
            }
            if (skedSchedule.Frequency__c != NULL) {
                model.frequency = integer.valueOf(skedSchedule.Frequency__c);
            }
        }

        if (model.courseId != NULL) {
            Course__c skedCourse = [SELECT Id, Start_Month__c, Course_Catalog__c 
                                    FROM Course__c 
                                    WHERE Id = :model.courseId];
            Course_Template__c courseTemplate = [SELECT Id, Course_Class_Days__c 
                                                 FROM Course_Template__c 
                                                 WHERE Course_Catalog__c = :skedCourse.Course_Catalog__c];
            model.startMonth = skedCourse.Start_Month__c;
            model.courseClassDays = courseTemplate.Course_Class_Days__c;
        }
    }

    private static void calculateResourceHours(scheduleAllocationModel model) {
        sked__Job__c firstSkedJob = model.skedJobs.get(0);

        Map<Id, sked__Job__c> mapSkedJob = new Map<Id, sked__Job__c>(model.skedJobs);

        Date firstWeekStartDate = firstSkedJob.sked__Start__c.date().addDays(1).toStartOfWeek().addDays(-1);
        DateTime firstWeekStartDt = skedDateTimeUtils.getStartOfDate(firstWeekStartDate, model.timezoneSidId);
        DateTime firstWeekEndDt = skedDateTimeUtils.addDays(firstWeekStartDt, 7, model.timezoneSidId);

        Map<Id, double> map_resource_duration = new Map<Id, double>();
        for (skedModels.jobAllocation availableAllocation : model.availableAllocations) {
            sked__Job__c skedJob = mapSkedJob.get(availableAllocation.jobId);
            if (skedJob.sked__Start__c < firstWeekEndDt && skedJob.sked__Finish__c > firstWeekStartDt) {
                double duration = 0;
                if (map_resource_duration.containsKey(availableAllocation.resourceId)) {
                    duration = map_resource_duration.get(availableAllocation.resourceId);
                }
                duration += addAssignedHours(firstWeekStartDt, firstWeekEndDt, skedJob.sked__Start__c, skedJob.sked__Finish__c);

                map_resource_duration.put(availableAllocation.resourceId, duration);
            }
        }

        List<sked__Resource__c> skedResources = [SELECT Id, sked__Weekly_Hours__c,
                                                 (SELECT Id, sked__Job__r.sked__Start__c, sked__Job__r.sked__Finish__c,
                                                  sked__Job__r.sked__Duration__c
                                                  FROM sked__Job_Allocations__r
                                                  WHERE sked__Status__c != :skedConstants.JOB_ALLOCATION_STATUS_DELETED
                                                  AND sked__Job__r.sked__Job_Status__c != :skedConstants.JOB_STATUS_CANCELLED
                                                  AND sked__Job__r.sked__Start__c < :firstWeekEndDt
                                                  AND sked__Job__r.sked__Finish__c > :firstWeekStartDt
                                                  AND sked__Job__c NOT IN :model.mapJob.keySet()),
                                                  (SELECT Id, sked__Start__c, sked__End__c
                                                   FROM sked__Activities__r
                                                   WHERE sked__Start__c < :firstWeekEndDt
                                                   AND sked__End__c > :firstWeekStartDt)
                                                 FROM sked__Resource__c
                                                 WHERE Id IN :model.mapResource.keySet()];
        for (sked__Resource__c skedResource : skedResources) {
            skedModels.resource resource = model.mapResource.get(skedResource.Id);
            if (skedResource.sked__Weekly_Hours__c != NULL) {
                resource.weeklyMinutes = skedResource.sked__Weekly_Hours__c * 60;
            }
            double assignedDuration = 0;
            for (sked__Job_Allocation__c skedAlloc : skedResource.sked__Job_Allocations__r) {
                assignedDuration += addAssignedHours(firstWeekStartDt, firstWeekEndDt, skedAlloc.sked__Job__r.sked__Start__c, skedAlloc.sked__Job__r.sked__Finish__c);
            }
            for (sked__Activity__c skedActivity : skedResource.sked__Activities__r) {
                assignedDuration += addAssignedHours(firstWeekStartDt, firstWeekEndDt, skedActivity.sked__Start__c, skedActivity.sked__End__c);
            }
            double firstWeekAvailableJobsDuration = 0;
            if (map_resource_duration.containsKey(skedResource.Id)) {
                firstWeekAvailableJobsDuration = map_resource_duration.get(skedResource.Id);
            }
            resource.assignedMinutes = assignedDuration + firstWeekAvailableJobsDuration;
        }
    }

    private static decimal addAssignedHours(DateTime weekStartDt, DateTime weekEndDt, DateTime startTime, DateTime endTime) {
        startTime = startTime < weekStartDt ? weekStartDt : startTime;
        endTime = endTime > weekEndDt ? weekEndDt : endTime;
        return (endTime.getTime() - startTime.getTime()) / 60000;
    }

    private static List<skedModels.resource> getSubcontractors() {
        List<sked__Resource__c> skedSubcontractors = [SELECT Id, Name, sked__Category__c, sked__Primary_Region__c,
                                                      sked__Primary_Region__r.Name, sked__Primary_Region__r.sked__Timezone__c,
                                                      sked__User__c, sked__User__r.SmallPhotoUrl, sked__Rating__c, 
                                                      sked__GeoLocation__c, sked__Home_Address__c,
                                                      sked__GeoLocation__Latitude__s, sked__GeoLocation__Longitude__s,
                                                      Employment_Type__c
                                                      FROM sked__Resource__c
                                                      WHERE sked__Is_Active__c = TRUE
                                                      AND Employment_Type__c = :skedConstants.RESOURCE_EMPLOYMENT_TYPE_SUBCONTRACTOR];
        List<skedModels.resource> subcontractors = new List<skedModels.resource>();
        for (sked__Resource__c skedSubcontractor : skedSubcontractors) {
            skedModels.resource subcontractor = new skedModels.resource(skedSubcontractor);
            subcontractors.add(subcontractor);
        }
        return subcontractors;
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
    global class configDataModel {
        public List<skedModels.selectOption> regions {get;set;}
        public List<skedModels.jobStatusSetting> jobStatusSettings {get;set;}
        public skedModels.permissionModel userPermission {get;set;}
        public skedModels.natClassSetting natClassSetting {get;set;}

        public configDataModel() {
            this.regions = new List<skedModels.selectOption>();
        }
    }

    global class scheduleAllocationModel {
        public string courseCatalogName {get;set;}
        public integer numberOfClasses {get;set;}
        public integer numberOfInstructors {get;set;}
        public integer numberOfEvaluators {get;set;}
        public integer numberOfStudents {get;set;}
        public List<string> weekdays {get;set;}
        public integer frequency {get;set;}
        public integer classDuration {get;set;}
        public string classStartDateIso {get;set;}
        public integer classStartTime {get;set;}
        public string jobType {get;set;}
        public string className {get;set;}
        public string address {get;set;}
        public decimal lat {get;set;}
        public decimal lng {get;set;}

        public string startMonth {get;set;}
        public string courseClassDays {get;set;}
        
        public List<jobModel> jobs {get;set;}
        public List<skedModels.resource> resources {get;set;}
        
        public transient List<skedModels.jobAllocation> availableAllocations {get;set;}
        public transient Map<Id, jobModel> mapJob {get;set;}
        public transient Map<Id, skedModels.resource> mapResource {get;set;}

        public transient string courseId {get;set;}
        public transient string scheduleId {get;set;}
        public transient Set<Id> jobIds {get;set;}
        public transient string timezoneSidId {get;set;}
        public transient List<sked__Job__c> skedJobs {get;set;}
        
        public scheduleAllocationModel() {
            this.jobs = new List<jobModel>();
            this.resources = new List<skedModels.resource>();
        }
    }
    
    global class jobModel extends skedModels.job {
        public string facilityName {get;set;}
        public integer numberOfInstructors {get;set;}
        public integer numberOfEvaluators {get;set;}
        public string teamLeadResourceId {get;set;}
        public string classType {get;set;}
        public string classTypeName {get;set;}
        public boolean locationConfirmed {get;set;}
        public boolean readyToPublish {get;set;}
        public boolean dispatch {get;set;}

        public List<skedModels.jobAllocation> possibleAllocations {get;set;}
        
        public jobModel(sked__Job__c skedJob) {
            super(skedJob);
            if (skedJob.Number_of_Instructors__c != NULL) {
                this.numberOfInstructors = integer.valueOf(skedJob.Number_of_Instructors__c);
            }
            if (skedJob.Number_of_Evaluators__c != NULL) {
                this.numberOfEvaluators = integer.valueOf(skedJob.Number_of_Evaluators__c);
            }
            this.classType = skedJob.Class_Type__c;
            this.classTypeName = skedJob.Class_Type__r.Class_Type__c;
            this.locationConfirmed = skedJob.Location_Confirmed__c;
            this.readyToPublish = skedJob.Ready_to_Publish__c;
            this.facilityId = skedJob.sked__Location__c;
            this.facilityName = skedJob.sked__Location__r.Name;

            this.allocations = new List<skedModels.jobAllocation>();
            this.possibleAllocations = new List<skedModels.jobAllocation>();
        }
    }

}