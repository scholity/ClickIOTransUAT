global class skedFullServiceBookingGridController {
    
    public string trainingEventId {get;set;}
    
    public skedFullServiceBookingGridController() {
        Id rootRecordId = ApexPages.currentPage().getParameters().get('id');
        this.trainingEventId = rootRecordId;
    }

    @remoteAction
    global static skedRemoteResultModel getConfigData(string trainingEventId) {
        skedRemoteResultModel result = new skedRemoteResultModel();
        try {
            configDataModel configData = new configDataModel();
            configData.scheduledJobInfo = populateScheduledJobInfo(trainingEventId);
            
            configData.avEquipments = skedUtils.getPickListValues('Training_Events__c', 'Equipment__c');
            configData.courseCatalogs = skedARCUtils.getCourseCatalogs(skedConstants.COURSE_CATALOG_TYPE_FULL_SERVICE);
            configData.tags = skedUtils.getTags();
            configData.regions = skedUtils.getRegions();
            configData.jobStatusSettings = skedUtils.getJobStatusSettings();

            Set<string> excludedEmploymentTypes = new Set<string>();
            excludedEmploymentTypes.add(skedConstants.RESOURCE_EMPLOYMENT_TYPE_SUBCONTRACTOR);
            configData.employmentTypes = skedUtils.getPickListValues('sked__Resource__c', 'Employment_Type__c', excludedEmploymentTypes);
            
            Training_Events__c skedTrainingEvent = [SELECT Id, Name, Equipment__c, Special_Instructions__c, 
                                                    Region__c, Region__r.Name, Region__r.sked__Timezone__c,
                                                    Training_Address_1__c, Training_City__c, Training_Location_State__c, Training_Zip__c,
                                                    Account__c, Account__r.Name, 
                                                    Training_Contact__c, Training_Contact__r.Id, Training_Contact__r.FirstName, 
                                                    Training_Contact__r.LastName, Training_Contact__r.Phone, Training_Contact__r.Email,
                                                    Training_Contact__r.AccountId
                                                    FROM Training_Events__c
                                                    WHERE Id = :trainingEventId];
            configData.rootRecord = new trainingEventModel(skedTrainingEvent);

            List<sked__Job__c> skedJobs = [SELECT Id, Name, sked__Start__c, sked__Finish__c, sked__Job_Status__c, 
                                           sked__Type__c, sked__Timezone__c, Remaining_Resources_to_be_Allocated__c,
                                           (SELECT Id, sked__Status__c, sked__Resource__c, 
                                            sked__Resource__r.Name, sked__Resource__r.sked__Category__c,
                                            sked__Resource__r.sked__User__r.SmallPhotoUrl
                                            FROM sked__Job_Allocations__r
                                            WHERE sked__Status__c != :skedConstants.JOB_ALLOCATION_STATUS_DELETED)
                                           FROM sked__Job__c
                                           WHERE Training_Event__c = :trainingEventId
                                           AND sked__Job_Status__c != :skedConstants.JOB_STATUS_CANCELLED
                                           ORDER BY sked__Start__c ASC];
            if (!skedJobs.isEmpty()) {
                for (sked__Job__c skedJob : skedJobs) {
                    jobModel job = new jobModel();
                    job.id = skedJob.Id;
                    job.name = skedJob.Name;
                    job.startDate = skedJob.sked__Start__c.format(skedDateTimeUtils.DATE_ISO_FORMAT, skedJob.sked__Timezone__c);
                    job.endDate = skedJob.sked__Finish__c.format(skedDateTimeUtils.DATE_ISO_FORMAT, skedJob.sked__Timezone__c);
                    job.startTime = integer.valueOf(skedJob.sked__Start__c.format('Hmm', skedJob.sked__Timezone__c));
                    job.finishTime = integer.valueOf(skedJob.sked__Finish__c.format('Hmm', skedJob.sked__Timezone__c));
                    job.jobStatus = skedJob.sked__Job_Status__c;
                    job.jobType = skedJob.sked__Type__c;
                    job.numberOfRemainingResources = integer.valueOf(skedJob.Remaining_Resources_to_be_Allocated__c);
                    job.allocations = new List<skedModels.jobAllocation>();
                    for (sked__Job_Allocation__c skedAllocation : skedJob.sked__Job_Allocations__r) {
                        skedModels.jobAllocation allocation = new skedModels.jobAllocation();
                        allocation.status = skedAllocation.sked__Status__c;

                        skedModels.resource resource = new skedModels.resource();
                        resource.id = skedAllocation.sked__Resource__c;
                        resource.name = skedAllocation.sked__Resource__r.Name;
                        resource.category = skedAllocation.sked__Resource__r.sked__Category__c;
                        allocation.resource = resource;

                        job.allocations.add(allocation);
                    }
                    
                    configData.scheduledJobs.add(job);
                }
            }
            if (skedTrainingEvent.Equipment__c != NULL) {
                for (skedModels.selectOption equipment : configData.avEquipments) {
                    if (skedTrainingEvent.Equipment__c.contains(equipment.label)) {
                        configData.rootRecord.equipments.add(equipment);
                    }
                }
            }
            
            configData.gridSettings = new gridSettings();
            configData.userPermission = getUserPermissions();
            
            result.data = configData;
        }
        catch (Exception ex) {
            result.getError(ex);
        }
        return result;
    }
    
    @remoteAction
    global static skedRemoteResultModel searchContacts(string accountId, string query) {
        skedRemoteResultModel result = new skedRemoteResultModel();
        try {
            Map<Id, Account> mapAllAccount = skedUtils.getChildAccountsInHierarchy(accountId);
            query = '%' + query + '%';
            
            List<contactModel> options = new List<contactModel>();
            List<Contact> matchContacts = [SELECT Id, FirstName, LastName, Email, Phone, AccountId
                                           FROM Contact
                                           WHERE AccountId IN :mapAllAccount.keySet()
                                           AND (FirstName LIKE :query OR LastName LIKE :query)
                                           ORDER BY Name ASC];
            for (Contact matchContact : matchContacts) {
                contactModel option = new ContactModel(matchContact);
                options.add(option);
            }
            List<AccountContactRelation> accountContactRelations = [SELECT Id, Contact.FirstName, Contact.LastName, Contact.Email, 
                                                                    Contact.Phone, Contact.AccountId
                                                                    FROM AccountContactRelation
                                                                    WHERE AccountId IN :mapAllAccount.keySet()
                                                                    AND (Contact.FirstName LIKE :query OR Contact.LastName LIKE :query)];
            for (AccountContactRelation accountContactRelation : accountContactRelations) {
                contactModel option = new ContactModel(accountContactRelation.Contact);
                options.add(option);
            }
            result.data = options;
        }
        catch (Exception ex) {
            result.getError(ex);
        }
        return result;
    }
    
    @remoteACtion
    global static skedRemoteResultModel createContact(contactModel model) {
        skedRemoteResultModel result = new skedRemoteResultModel();
        SavePoint sp = Database.setSavePoint();
        try {
            Contact contact = new Contact(
                AccountId = model.accountId,
                FirstName = model.firstName,
                LastName = model.lastName,
                Email = model.email,
                Phone = model.phone
            );
            insert contact;
            model.id = contact.Id;
            result.data = model;
        }
        catch (Exception ex) {
            result.getError(ex);
            Database.rollback(sp);
        }
        return result;
    }
    
    @remoteAction
    global static skedRemoteResultModel getBookingGrid(bookingGridQueryModel queryModel) {
        skedRemoteResultModel result = new skedRemoteResultModel();
        try {
            sked__Region__c region = [SELECT Id, sked__Timezone__c
                                      FROM sked__Region__c
                                      WHERE Id = :queryModel.regionId];
            queryModel.timezoneSidId = region.sked__Timezone__c;

            Location jobLocation = Location.newInstance(queryModel.lat, queryModel.lng);

            Map<string, slotModel> mapSlot = getMapSlot(queryModel);
            
            List<string> resourceCategories = new List<string>();
            resourceCategories.add(skedConstants.RESOURCE_CATEGORY_INSTRUCTOR);

            string regionId = queryModel.regionId;
            if (queryModel.radius <= 0) {
                regionId = 'all';
            }
            Map<Id, sked__Resource__c> mapResource = skedUtils.getMapResources(regionId, resourceCategories, queryModel.tagIds);
            
            Set<Id> resourceIds = mapResource.keySet();
            if (queryModel.radius > 0) {
                resourceIds = skedUtils.getResourceIdsByRadius(resourceIds, queryModel.radius, jobLocation);
            }

            if (!resourceIds.isEmpty()) {
                List<skedBaseModels.tag> requiredTags = new List<skedBaseModels.tag>();
                for (string tagId : queryModel.tagIds) {
                    skedBaseModels.tag tag = new skedBaseModels.tag();
                    tag.id = tagId;
                    requiredTags.add(tag);
                }
                
                DateTime bufferTime = system.now();
                List<skedModels.job> possibleJobs = new List<skedModels.job>();
                for (slotModel slot : mapSlot.values()) {
                    if (slot.startTime < bufferTime) {
                        continue;
                    }
                    skedModels.job possibleJob = new skedModels.job();
                    possibleJob.geoLocation = jobLocation;
                    possibleJob.start = slot.startTime;
                    possibleJob.finish = skedDateTimeUtils.addMinutes(slot.startTime, queryModel.jobDuration, queryModel.timezoneSidId);
                    possibleJob.tags = new List<skedBaseModels.tag>();
                    possibleJob.tags.addAll(requiredTags);

                    possibleJob.start = skedDateTimeUtils.addMinutes(possibleJob.start, -1 * queryModel.beforeClassDuration, queryModel.timezoneSidId);
                    possibleJob.finish = skedDateTimeUtils.addMinutes(possibleJob.finish, queryModel.afterClassDuration, queryModel.timezoneSidId);
                    
                    possibleJobs.add(possibleJob);
                }
                
                if (possibleJobs.size() > 0) {
                    Map<Id, sked__Job__c> mapRescheduledJob = new Map<Id, sked__Job__c>([SELECT Id
                                                                                         FROM sked__Job__c
                                                                                         WHERE sked__Job_Status__c != :skedConstants.JOB_STATUS_CANCELLED
                                                                                         AND Training_Event__c = :queryModel.trainingEventId]);
                    skedAvailatorParams params = new skedAvailatorParams();
                    params.timezoneSidId = queryModel.timezoneSidId;
                    params.resourceIds = resourceIds;
                    params.inputJobs = possibleJobs;
                    params.excludedJobIds = mapRescheduledJob.keySet();
                    params.onlyKeepQualifiedResources = true;
                    
                    skedAvailator availator = new skedAvailator(params);
                    availator.countAvailableResources(50);

                    for (skedModels.job inputJob : params.inputJobs) {
                        DateTime classActualStart = skedDateTimeUtils.addMinutes(inputJob.start, queryModel.beforeClassDuration, queryModel.timezoneSidId);
                        string slotKey = Json.serialize(classActualStart);
                        slotModel slot = mapSlot.get(slotKey);
                        slot.noOfQualifiedResources = inputJob.noOfQualifiedResources;
                        slot.noOfAvailableResources = inputJob.noOfAvailableResources;
                    }

                    List<sked__Job__c> pendingAllocationJobs = [SELECT Id, sked__Start__c, sked__Finish__c, Number_of_Instructors__c
                                                                FROM sked__Job__c
                                                                WHERE sked__Region__c = :queryModel.regionId
                                                                AND (sked__Type__c = :skedConstants.JOB_TYPE_FULL_SERVICE 
                                                                     OR sked__Type__c = :skedConstants.JOB_TYPE_COMMUNITY)
                                                                AND sked__Job_Status__c = :skedConstants.JOB_STATUS_PENDING_ALLOCATION
                                                                AND sked__Start__c < :queryModel.endTime
                                                                AND sked__Finish__c > : queryModel.startTime
                                                                AND Id NOT IN:mapRescheduledJob.keySet()
                                                                ORDER BY sked__Start__c ASC];
                    for (sked__Job__c pendingAllocationJob : pendingAllocationJobs) {
                        for (slotModel slot : mapSlot.values()) {
                            if (slot.startTime >= pendingAllocationJob.sked__Finish__c) {
                                break;
                            }
                            if (slot.startTime < pendingAllocationJob.sked__Finish__c && slot.endTime > pendingAllocationJob.sked__Start__c) {
                                if (slot.noOfAvailableResources > 0 && pendingAllocationJob.Number_of_Instructors__c != NULL) {
                                    slot.noOfAvailableResources -= integer.valueOf(pendingAllocationJob.Number_of_Instructors__c);
                                }
                            }
                        }
                    }
                }
            }

            bookingGridModel bookingGrid = new bookingGridModel();
            bookingGrid.slots = mapSlot.values();
            bookingGrid.timezone = system.now().format('z', queryModel.timezoneSidId);
            
            Map<Id, sked__Resource__c> mapSubcontractor = new Map<Id, sked__Resource__c>([SELECT Id
                                                                                          FROM sked__Resource__c
                                                                                          WHERE Employment_Type__c = :skedConstants.RESOURCE_EMPLOYMENT_TYPE_SUBCONTRACTOR
                                                                                          AND sked__Is_Active__c = TRUE]);
            Set<Id> subcontractorIds = mapSubcontractor.keySet();
            //if (queryModel.radius > 0) {
            //    subcontractorIds = skedUtils.getResourceIdsByRadius(subcontractorIds, queryModel.radius, jobLocation);
            //}
                                        
            bookingGrid.noOfSubcontractors = subcontractorIds.size();

            result.data = bookingGrid;
        }
        catch (Exception ex) {
            result.getError(ex);
        }
        return result;
    }

    @remoteAction
    global static skedRemoteResultModel getResourceData(bookingGridQueryModel queryModel) {
        skedRemoteResultModel result = new skedRemoteResultModel();
        try {
            sked__Region__c region = [SELECT Id, sked__Timezone__c
                                      FROM sked__Region__c
                                      WHERE Id = :queryModel.regionId];
            queryModel.timezoneSidId = region.sked__Timezone__c;

            Location jobLocation = Location.newInstance(queryModel.lat, queryModel.lng);

            List<string> resourceCategories = new List<string>();
            resourceCategories.add(skedConstants.RESOURCE_CATEGORY_INSTRUCTOR);

            string regionId = 'all';

            Map<Id, sked__Resource__c> mapResource = skedUtils.getMapResources(regionId, resourceCategories, queryModel.tagIds);
            
            Set<Id> resourceIds = mapResource.keySet();
            if (queryModel.radius > 0) {
                resourceIds = skedUtils.getResourceIdsByRadius(resourceIds, queryModel.radius, jobLocation);
            }

            Date startDate = skedDateTimeUtils.getDateFromIsoString(queryModel.startDateIso);
            Date endDate = skedDateTimeUtils.getDateFromIsoString(queryModel.endDateIso);
            
            queryModel.startTime = skedDateTimeUtils.getStartOfDate(startDate, queryModel.timezoneSidId);
            queryModel.endTime = skedDateTimeUtils.getEndOfDate(endDate, queryModel.timezoneSidId);

            Map<Id, sked__Job__c> mapRescheduledJob = new Map<Id, sked__Job__c>([SELECT Id
                                                                                 FROM sked__Job__c
                                                                                 WHERE sked__Job_Status__c != :skedConstants.JOB_STATUS_CANCELLED
                                                                                 AND Training_Event__c = :queryModel.trainingEventId]);
            Set<Id> excludedJobIds = mapRescheduledJob.keySet();
            Map<Id, resourceModel> mapResourceData = initializeResourceList(resourceIds, excludedJobIds, queryModel.startTime, queryModel.endTime, queryModel.timezoneSidId);
            calculateResourceHours(mapResourceData, startDate, endDate, excludedJobIds, queryModel.timezoneSidId);
            List<resourceModel> resourceList = mapResourceData.values();

            List<sked__Job__c> pendingAllocationJobs = [SELECT Id, sked__Start__c, sked__Finish__c, sked__GeoLocation__c,
                                                        sked__GeoLocation__Latitude__s, sked__GeoLocation__Longitude__s,
                                                        Number_of_Instructors__c, Before_class_duration__c, After_class_duration__c,
                                                        (SELECT sked__Tag__c
                                                         FROM sked__JobTags__r),
                                                        (SELECT Id 
                                                         FROM sked__Job_Allocations__r
                                                         WHERE sked__Status__c != :skedConstants.JOB_ALLOCATION_STATUS_DELETED)
                                                        FROM sked__Job__c
                                                        WHERE sked__Region__c = :queryModel.regionId
                                                        AND (sked__Type__c = :skedConstants.JOB_TYPE_FULL_SERVICE
                                                             OR sked__Type__c = :skedConstants.JOB_TYPE_COMMUNITY)
                                                        AND sked__Job_Status__c = :skedConstants.JOB_STATUS_PENDING_ALLOCATION
                                                        AND sked__Start__c < :queryModel.endTime
                                                        AND sked__Finish__c > : queryModel.startTime
                                                        AND Id NOT IN:excludedJobIds
                                                        ORDER BY sked__Start__c ASC];
            List<jobModel> pendingJobs = new List<jobModel>();
            for (sked__Job__c skedJob : pendingAllocationJobs) {
                if (queryModel.radius > 0) {
                    double distanceFromBookingJob = jobLocation.getDistance(skedJob.sked__GeoLocation__c, 'mi');
                    if (distanceFromBookingJob >= queryModel.radius * 2 ) {
                        continue;
                    }
                }

                integer beforeClassDuration = skedJob.Before_class_duration__c == NULL 
                    ? 0 : integer.valueOf(skedJob.Before_class_duration__c);
                integer afterClassDuration = skedJob.After_class_duration__c == NULL 
                    ? 0 : integer.valueOf(skedJob.After_class_duration__c);
                
                DateTime jobStart = skedDateTimeUtils.addMinutes(skedJob.sked__Start__c, -1 * beforeClassDuration, queryModel.timezoneSidId);
                DateTime jobFinish = skedDateTimeUtils.addMinutes(skedJob.sked__Finish__c, afterClassDuration, queryModel.timezoneSidId);
                
                jobModel pendingJob = new jobModel();
                pendingJob.id = skedJob.Id;
                pendingJob.numberOfInstructors = integer.valueOf(skedJob.Number_of_Instructors__c);
                if (skedJob.sked__Job_Allocations__r != NULL && !skedJob.sked__Job_Allocations__r.isEmpty()) {
                    pendingJob.numberOfInstructors -= skedJob.sked__Job_Allocations__r.size();
                }
                pendingJob.startDate = jobStart.format(skedDateTimeUtils.DATE_ISO_FORMAT, queryModel.timezoneSidId);
                pendingJob.endDate = jobFinish.format(skedDateTimeUtils.DATE_ISO_FORMAT, queryModel.timezoneSidId);
                pendingJob.startTime = integer.valueOf(jobStart.format('Hmm', queryModel.timezoneSidId));
                pendingJob.finishTime = integer.valueOf(jobFinish.format('Hmm', queryModel.timezoneSidId));
                pendingJob.lat = skedJob.sked__GeoLocation__Latitude__s;
                pendingJob.lng = skedJob.sked__GeoLocation__Longitude__s;

                if (skedJob.sked__JobTags__r != NULL && !skedJob.sked__JobTags__r.isEmpty()) {
                    pendingJob.tagIds = new Set<Id>();
                    for (sked__Job_Tag__c skedJobTag : skedJob.sked__JobTags__r) {
                        pendingJob.tagIds.add(skedJobTag.sked__Tag__c);
                    }
                }

                pendingJobs.add(pendingJob);
            }

            Map<Id, sked__Resource__c> mapSubcontractor = new Map<Id, sked__Resource__c>([SELECT Id
                                                                                          FROM sked__Resource__c
                                                                                          WHERE Employment_Type__c = :skedConstants.RESOURCE_EMPLOYMENT_TYPE_SUBCONTRACTOR
                                                                                          AND sked__Is_Active__c = TRUE]);
            resourceDataModel returnedData = new resourceDataModel();
            returnedData.resources = resourceList;
            returnedData.pendingJobs = pendingJobs;
            returnedData.noOfSubcontractors = mapSubcontractor.size();
            returnedData.timezone = system.now().format('z', queryModel.timezoneSidId);
            returnedData.timezoneSidId = queryModel.timezoneSidId;

            result.data = returnedData;
        }
        catch (Exception ex) {
            result.getError(ex);
        }
        return result;
    }

    @remoteAction
    global static skedRemoteResultModel saveJob(jobSaveModel model, List<jobModel> scheduledJobs, boolean confirm) {
        skedRemoteResultModel result = new skedRemoteResultModel();
        
        prepareJobSaveModel(scheduledJobs, model);

        List<skedModels.jobAllocation> currentAllocations = validateCurrentAllocations(model, scheduledJobs);

        SavePoint sp = Database.setSavePoint();
        try {
            List<skedModels.jobAllocation> conflictAllocations = new List<skedModels.jobAllocation>();
            for (skedModels.jobAllocation allocation : currentAllocations) {
                if (!allocation.isQualified || !allocation.isAvailable) {
                    allocation.jobName = allocation.job.name;
                    conflictAllocations.add(allocation);
                }
            }
            boolean isConflict = !conflictAllocations.isEmpty();
            if (isConflict && !confirm) {
                result.data = conflictAllocations;
            }
            else {
                if (string.isBlank(model.scheduleId)) {
                    if (scheduledJobs.size() > 1) {
                        sked__Recurring_Schedule__c skedSchedule = new sked__Recurring_Schedule__c(
                            Training_Event__c = model.trainingEventId
                        );
                        insert skedSchedule;
                        model.scheduleId = skedSchedule.Id;
                    }
                }
                List<sked__Job__c> jobsToInsert = new List<sked__Job__c>();
                List<sked__Job__c> jobsToUpdate = new List<sked__Job__c>();
                List<string> jobIdsToCancel = new List<string>();
                
                for (jobModel job : scheduledJobs) {
                    if (string.isBlank(job.id)) {
                        sked__Job__c skedJob = new sked__Job__c();
                        populateJobData(model, job, skedJob);
                        jobsToInsert.add(skedJob);
                    }
                    else {
                        if (job.jobStatus == skedConstants.JOB_STATUS_CANCELLED) {
                            jobIdsToCancel.add(job.id);
                        }
                        else if (job.isChanged == true) {
                            sked__Job__c skedJob = new sked__Job__c(
                                Id = job.id
                            );
                            populateJobData(model, job, skedJob);
                            jobsToUpdate.add(skedJob);
                        }
                    }
                }
                if (isConflict) {//if conflict then remove conflict allocations
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
                else {//if not conflict then update estimated travel time on current allocations
                    Map<string, skedModels.jobAllocation> map_key_allocation = new Map<string, skedModels.jobAllocation>();
                    for (skedModels.jobAllocation currentAllocation : currentAllocations) {
                        map_key_allocation.put(currentAllocation.jobId + ':' + currentAllocation.resourceId, currentAllocation);
                    }
                    List<sked__Job_Allocation__c> currentSkedAllocations = [SELECT Id, sked__UniqueKey__c, sked__Estimated_Travel_Time__c
                                                                            FROM sked__Job_Allocation__c
                                                                            WHERE sked__UniqueKey__c IN :map_key_allocation.keySet()];
                    List<sked__Job_Allocation__c> allocationsToUpdate = new List<sked__Job_Allocation__c>();
                    for (sked__Job_Allocation__c currentSkedAllocation : currentSkedAllocations) {
                        skedModels.jobAllocation currentAllocation = map_key_allocation.get(currentSkedAllocation.sked__UniqueKey__c);
                        if (currentSkedAllocation.sked__Estimated_Travel_Time__c != currentAllocation.travelTimeFrom) {
                            currentSkedAllocation.sked__Estimated_Travel_Time__c = currentAllocation.travelTimeFrom;
                            allocationsToUpdate.add(currentSkedAllocation);
                        }
                    }
                    if (!allocationsToUpdate.isEmpty()) {
                        update allocationsToUpdate;
                    }
                }

                if (!jobsToInsert.isEmpty()) {
                    insert jobsToInsert;
                    skedJobService.insertJobTags(jobsToInsert, model.tagIds);
                }
                if (!jobsToUpdate.isEmpty()) {
                    update jobsToUpdate;
                    skedJobService.editJobTags(jobsToUpdate, model.tagIds);
                    skedJobService.updateJobStatus(jobsToUpdate);
                }
                if (!jobIdsToCancel.isEmpty()) {
                    skedJobService.cancelJobs(jobIdsToCancel);
                }

                updateTrainingEvent(model);

                result.data = new List<skedModels.jobAllocation>();
            }
        }
        catch (Exception ex) {
            result.getError(ex);
            Database.rollback(sp);
        }
        return result;
    }

    @remoteAction
    global static skedRemoteResultModel getScheduledJobIds(string trainingEventId) {
        skedRemoteResultModel result = new skedRemoteResultModel();
        SavePoint sp = Database.setSavePoint();
        try {
            Map<Id, sked__Job__c> mapSkedJob = new Map<Id, sked__Job__c>([SELECT Id
                                                                          FROM sked__Job__c
                                                                          WHERE Training_Event__c = :trainingEventId
                                                                          AND sked__Job_Status__c != :skedConstants.JOB_STATUS_CANCELLED
                                                                          AND sked__Job_Status__c != :skedConstants.JOB_STATUS_COMPLETE]);
            result.data = mapSkedJob.keySet();
        }
        catch (Exception ex) {
            result.getError(ex);
            Database.rollback(sp);
        }
        return result;
    }

    @remoteAction
    global static skedRemoteResultModel cancelJobs(string[] jobIds) {
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
    private static Map<string, slotModel> getMapSlot(bookingGridQueryModel queryModel) {
        Date startDate = skedDateTimeUtils.getDateFromIsoString(queryModel.startDateIso);
        Date endDate = skedDateTimeUtils.getDateFromIsoString(queryModel.endDateIso);
        
        queryModel.startTime = skedDateTimeUtils.getStartOfDate(startDate, queryModel.timezoneSidId);
        queryModel.endTime = skedDateTimeUtils.getEndOfDate(endDate, queryModel.timezoneSidId);
        
        integer firstSlotStartInMinutes = skedDateTimeUtils.convertTimeNumberToMinutes(queryModel.startTimeInt);
        integer lastSlotEndInMinutes = skedDateTimeUtils.convertTimeNumberToMinutes(queryModel.endTimeInt);
        
        Map<string, slotModel> mapSlot = new Map<string, slotModel>();
        
        DateTime tempDt = queryModel.startTime;
        DateTime currentTime = system.now();
        while (tempDt < queryModel.endTime) {
            DateTime firstSlotStart = skedDateTimeUtils.addMinutes(tempDt, firstSlotStartInMinutes, queryModel.timezoneSidId);
            DateTime lastSlotEnd = skedDateTimeUtils.addMinutes(tempDt, lastSlotEndInMinutes, queryModel.timezoneSidId);
            DateTime tempSlotStart = firstSlotStart;
            
            while (tempSlotStart < lastSlotEnd) {
                if (tempSlotStart > currentTime) {
                    slotModel slot = new slotModel();
                    slot.slotDate = tempSlotStart.format(skedDateTimeUtils.DATE_ISO_FORMAT, queryModel.timezoneSidId);
                    slot.slotTime = integer.valueOf(tempSlotStart.format('Hmm', queryModel.timezoneSidId));
                    slot.startTime = tempSlotStart;
                    slot.endTime = skedDateTimeUtils.addMinutes(tempSlotStart, queryModel.jobDuration, queryModel.timezoneSidId);
                    slot.slotKey = Json.serialize(tempSlotStart);
                    
                    mapSlot.put(slot.slotKey, slot);
                }

                integer count = 1;
                DateTime nextSlotStart = tempSlotStart;
                while (nextSlotStart <= tempSlotStart) {
                    nextSlotStart = skedDateTimeUtils.addMinutes(tempSlotStart, queryModel.timeslotStep * count, queryModel.timezoneSidId);
                    count++;
                }
                tempSlotStart = nextSlotStart;
            }
            tempDt = skedDateTimeUtils.addDays(tempDt, 1, queryModel.timezoneSidId);
        }
        return mapSlot;
    }

    private static skedModels.permissionModel getUserPermissions() {
        skedModels.permissionModel userPermission = new skedModels.permissionModel();

        User currentUser = [SELECT Id, ARC_User_Type__c
                            FROM User
                            WHERE Id = :UserInfo.getUserId()];
        if (currentUser.ARC_User_Type__c != NULL) {
            if (!currentUser.ARC_User_Type__c.contains(skedConstants.ARC_USER_TYPE_READ_ONLY_SCHEDULER)) {
                userPermission.canClone = true;
                userPermission.canCreate = true;
                userPermission.canDelete = true;
                userPermission.canCancel = true;
                userPermission.canEdit = true;
            }
        }
        return userPermission;
    }

    public static jobSaveModel populateScheduledJobInfo(Id trainingEventId) {
        jobSaveModel result = new jobSaveModel();

        Training_Events__c skedTrainingEvent = [SELECT Id, Name, Region__r.sked__Timezone__c,
                                                Training_Address_1__c, Training_Address_2__c, Training_City__c,
                                                Training_Location_State__c, Training_Zip__c, Service_Delivery_Territory__c,
                                                (SELECT Id, Pattern__c, Frequency__c
                                                 FROM Recurring_Schedules__r)
                                                FROM Training_Events__c
                                                WHERE Id = :trainingEventId];
        Map<Id, sked__Job__c> mapEventJobs = new Map<Id, sked__Job__c>([SELECT Id FROM sked__Job__c 
                                                                        WHERE Training_Event__c = :trainingEventId
                                                                        AND sked__Job_Status__c != :skedConstants.JOB_STATUS_CANCELLED]);
        if (mapEventJobs.isEmpty()) {
            return null;
        }

        string scheduleId;
        if (!skedTrainingEvent.Recurring_Schedules__r.isEmpty()) {
            scheduleId = skedTrainingEvent.Recurring_Schedules__r.get(0).Id;
        }

        List<sked__Job__c> skedJobs = [SELECT Id, Name, sked__Region__c, sked__Address__c, sked__Contact__c, sked__Recurring_Schedule__c,
                                        sked__Description__c, sked__GeoLocation__Latitude__s, sked__GeoLocation__Longitude__s, sked__GeoLocation__c,
                                        sked__Timezone__c, sked__Start__c, sked__Finish__c, sked__Duration__c, sked__Type__c, sked__Job_Status__c,
                                        Number_of_Instructors__c, Number_of_Students__c, Course_Catalog__c, 
                                        Course_Catalog__r.Name, Equipment__c,
                                        Break_Duration__c, Number_of_Breaks__c, Test__c, Special_Instructions__c,
                                        Before_class_duration__c, After_class_duration__c,
                                        Grid_Setting_Radius__c, Grid_Setting_Interval__c, Grid_Setting_Subconstractor__c,
                                        Grid_Setting_Show_24_Hours__c, Grid_Setting_Employment_Types__c, Grid_Setting_Scheduled_Hours__c,
                                        (SELECT sked__Job__c, sked__Tag__c, sked__Tag__r.Name
                                         FROM sked__JobTags__r)
                                        FROM sked__Job__c
                                        WHERE Training_Event__c = :trainingEventId
                                        AND sked__Job_Status__c != :skedConstants.JOB_STATUS_CANCELLED
                                        ORDER BY sked__Start__c ASC];
        sked__Job__c firstSkedJob = skedJobs.get(0);
        result.contactId = firstSkedJob.sked__Contact__c;
        result.regionId = firstSkedJob.sked__Region__c;
        result.trainingEventId = trainingEventId;
        result.courseCatalogId = firstSkedJob.Course_Catalog__c;
        result.courseCatalogName = firstSkedJob.Course_Catalog__r.Name;
        result.selectedAvEquipments = string.isBlank(firstSkedJob.Equipment__c) ? new List<string>() : firstSkedJob.Equipment__c.split(';');
        result.numberOfStudents = firstSkedJob.Number_of_Students__c == NULL ? 0 : integer.valueOf(firstSkedJob.Number_of_Students__c);
        result.numberOfInstructors = firstSkedJob.Number_of_Instructors__c == NULL ? 0 : integer.valueOf(firstSkedJob.Number_of_Instructors__c);
        result.classDuration = firstSkedJob.sked__Duration__c == NULL ? 0 : integer.valueOf(firstSkedJob.sked__Duration__c);
        result.breakDuration = firstSkedJob.Break_Duration__c == NULL ? 0 : integer.valueOf(firstSkedJob.Break_Duration__c);
        result.numberOfBreaks = firstSkedJob.Number_of_Breaks__c == NULL ? 0 : integer.valueOf(firstSkedJob.Number_of_Breaks__c);
        result.test = firstSkedJob.Test__c;
        result.specialInstructions = firstSkedJob.Special_Instructions__c;

        result.tagIds = new List<string>();
        for (sked__Job_Tag__c jobTag : firstSkedJob.sked__JobTags__r) {
            result.tagIds.add(jobTag.sked__Tag__c);
        }

        result.address = new addressModel();
        result.address.fullAddress = firstSkedJob.sked__Address__c;
        result.address.lat = firstSkedJob.sked__GeoLocation__Latitude__s;
        result.address.lng = firstSkedJob.sked__GeoLocation__Longitude__s;
        result.address.address1 = skedTrainingEvent.Training_Address_1__c;
        result.address.address2 = skedTrainingEvent.Training_Address_2__c;
        result.address.city = skedTrainingEvent.Training_City__c;
        result.address.state = skedTrainingEvent.Training_Location_State__c;
        result.address.zip = skedTrainingEvent.Training_Zip__c;
        result.address.territory = skedTrainingEvent.Service_Delivery_Territory__c;
        result.numberOfClasses = skedJobs.size();

        result.selectedDate = firstSkedJob.sked__Start__c.format(skedDateTimeUtils.DATE_ISO_FORMAT, firstSkedJob.sked__Timezone__c);
        result.selectedTime = integer.valueOf(firstSkedJob.sked__Start__c.format('Hmm', firstSkedJob.sked__Timezone__c));
        result.beforeClassDuration = integer.valueOf(firstSkedJob.Before_class_duration__c);
        result.afterClassDuration = integer.valueOf(firstSkedJob.After_class_duration__c);

        result.gridSettings = new gridSettingModel();
        if (firstSkedJob.Grid_Setting_Radius__c != NULL) {
            result.gridSettings.radius = integer.valueOf(firstSkedJob.Grid_Setting_Radius__c);
        }
        if (firstSkedJob.Grid_Setting_Interval__c != NULL) {
            result.gridSettings.interval = integer.valueOf(firstSkedJob.Grid_Setting_Interval__c);
        }
        result.gridSettings.show24Hours = firstSkedJob.Grid_Setting_Show_24_Hours__c;
        result.gridSettings.subcontractor = firstSkedJob.Grid_Setting_Subconstractor__c;
        if (firstSkedJob.Grid_Setting_Employment_Types__c != NULL) {
            result.gridSettings.employmentTypes = firstSkedJob.Grid_Setting_Employment_Types__c.split(';');
        }
        if (firstSkedJob.Grid_Setting_Scheduled_Hours__c != NULL) {
            result.gridSettings.scheduledHours = new List<integer>();
            List<string> scheduledHoursStrList = firstSkedJob.Grid_Setting_Scheduled_Hours__c.split(';');
            for (string scheduledHoursStr : scheduledHoursStrList) {
                result.gridSettings.scheduledHours.add(integer.valueOf(scheduledHoursStr));
            }
        }

        return result;
    }

    private static void prepareJobSaveModel(List<jobModel> scheduledJobs, jobSaveModel model) {
        sked__Region__c skedRegion = [SELECT Id, sked__Timezone__c FROM sked__Region__c WHERE Id = :model.regionId];
        model.timezoneSidId = skedRegion.sked__Timezone__c;

        Course_Catalog__c courseCatalog = [SELECT Id, Name
                                           FROM Course_Catalog__c
                                           WHERE Id = :model.courseCatalogId];
        model.courseCatalogName = courseCatalog.Name;

        Training_Events__c trainingEvent = [SELECT Id, Account__c,
                                            (SELECT Id
                                             FROM Recurring_Schedules__r)
                                            FROM Training_Events__c
                                            WHERE Id = :model.trainingEventId];
        model.accountId = trainingEvent.Account__c;

        for (jobModel job : scheduledJobs) {
            Date jobDate = skedDateTimeUtils.getDateFromIsoString(job.startDate);
            DateTime jobDateStart = DateTime.newInstance(jobDate, time.newInstance(0, 0, 0, 0));
            jobDateStart = skedDateTimeUtils.toTimezone(jobDateStart, model.timezoneSidId);
            integer startTimeInMinutes = skedDateTimeUtils.convertTimeNumberToMinutes(job.startTime);
            job.start = skedDateTimeUtils.addMinutes(jobDateStart, startTimeInMinutes, model.timezoneSidId);
            job.finish = job.start.addMinutes(model.classDuration);

            job.tags = new List<skedBaseModels.tag>();
            for (string tagId : model.tagIds) {
                skedBaseModels.tag tag = new skedBaseModels.tag();
                tag.id = tagId;
                job.tags.add(tag);
            }
        }

        if (trainingEvent.Recurring_Schedules__r != NULL && !trainingEvent.Recurring_Schedules__r.isEmpty()) {
            model.scheduleId = trainingEvent.Recurring_Schedules__r.get(0).Id;
        }
    }

    private static void populateJobData(jobSaveModel model, jobModel job, sked__Job__c skedJob) {
        skedJob.sked__Region__c = model.regionId;
        skedJob.sked__Account__c = model.accountId;
        skedJob.sked__Contact__c = model.contactId;
        skedJob.sked__Start__c = job.start;
        skedJob.sked__Finish__c = job.finish;
        skedJob.sked__Duration__c = model.classDuration;
        skedJob.sked__Type__c = skedConstants.JOB_TYPE_FULL_SERVICE;
        skedJob.sked__Address__c = model.address.fullAddress;
        skedJob.sked__GeoLocation__Latitude__s = model.address.lat;
        skedJob.sked__GeoLocation__Longitude__s = model.address.lng;
        skedJob.sked__Can_Be_Declined__c = FALSE;
        skedJob.sked__Recurring_Schedule__c = model.scheduleId;
        skedJob.Equipment__c = string.join(model.selectedAvEquipments, ';');
        skedJob.Training_Event__c = model.trainingEventId;
        skedJob.Course_Catalog__c = model.courseCatalogId;
        skedJob.Break_Duration__c = model.breakDuration;
        skedJob.Number_of_Breaks__c = model.numberOfBreaks;
        skedJob.Number_of_Instructors__c = model.numberOfInstructors;
        skedJob.Number_of_Students__c = model.numberOfStudents;
        skedJob.Special_Instructions__c = model.specialInstructions;
        skedJob.Test__c = model.test;
        skedJob.Before_class_duration__c = model.beforeClassDuration;
        skedJob.After_class_duration__c = model.afterClassDuration;
        skedJob.Grid_Setting_Radius__c = model.gridSettings.radius;
        skedJob.Grid_Setting_Interval__c = model.gridSettings.interval;
        skedJob.Grid_Setting_Show_24_Hours__c = model.gridSettings.show24Hours;
        skedJob.Grid_Setting_Subconstractor__c = model.gridSettings.subcontractor;
        skedJob.Grid_Setting_Scheduled_Hours__c = string.join(model.gridSettings.scheduledHours, ';');
        skedJob.Grid_Setting_Employment_Types__c = string.join(model.gridSettings.employmentTypes, ';');
        if (string.isBlank(skedJob.Id)) {
            skedJob.sked__Job_Status__c = skedConstants.JOB_STATUS_PENDING_ALLOCATION;
        }
    }

    private static void updateTrainingEvent(jobSaveModel model) {
        List<sked__Job__c> scheduledSkedJob = [SELECT Id, sked__Start__c, sked__Finish__c
                                               FROM sked__Job__c
                                               WHERE Training_Event__c = :model.trainingEventId
                                               AND sked__Job_Status__c != :skedConstants.JOB_STATUS_CANCELLED
                                               ORDER BY sked__Start__c ASC];
        sked__Job__c firstJob = scheduledSkedJob.get(0);
        sked__Job__c lastJob = scheduledSkedJob.get(scheduledSkedJob.size() - 1);
        string breakDurationTxt = model.breakDuration + 'm';
        Training_Events__c skedTrainingEvent = new Training_Events__c(
            Id = model.trainingEventId,
            Start_Date__c = skedDateTimeUtils.getDate(firstJob.sked__Start__c, model.timezoneSidId),
            End_Date__c = skedDateTimeUtils.getDate(lastJob.sked__Finish__c, model.timezoneSidId),
            Start_Time__c = firstJob.sked__Start__c.format('hh:mm a', model.timezoneSidId),
            End_Time__c = firstJob.sked__Finish__c.format('hh:mm a', model.timezoneSidId),
            Equipment__c = string.join(model.selectedAvEquipments, ';'),
            Special_Instructions__c = model.specialInstructions,
            Number_in_Class__c = model.numberOfStudents,
            Number_of_Instructors__c = model.numberOfInstructors,
            Training_Contact__c = model.contactId,
            Training_Address_1__c = model.address.address1,
            Training_Address_2__c = model.address.address2,
            Training_City__c = model.address.city,
            Training_Location_State__c = model.address.state,
            Training_Zip__c = model.address.zip,
            Region__c = model.regionId,
            Break_Times__c = breakDurationTxt,
            Written_Test__c = model.test == true ? skedConstants.TRAINING_EVENT_WRITTEN_TEST_YES : skedConstants.TRAINING_EVENT_WRITTEN_TEST_NO
        );
        update skedTrainingEvent;
    }

    private static List<skedModels.jobAllocation> validateCurrentAllocations(jobSaveModel model, List<jobModel> scheduledJobs) {
        List<skedModels.jobAllocation> currentAllocations = new List<skedModels.jobAllocation>();
        
        Map<Id, sked__Job__c> mapCurrentSkedJob = 
                new Map<Id, sked__Job__c>([SELECT Id, Name, sked__Start__c, sked__Finish__c, sked__Job_Allocation_Count__c,
                                           sked__Address__c, sked__GeoLocation__c, sked__Type__c,
                                           Before_class_duration__c, After_class_duration__c, Course_Catalog__c,
                                           (SELECT sked__Tag__c
                                            FROM sked__JobTags__r),
                                           (SELECT sked__Resource__c, sked__UniqueKey__c
                                            FROM sked__Job_Allocations__r
                                            WHERE sked__Status__c != :skedConstants.JOB_ALLOCATION_STATUS_DELETED
                                            AND sked__Resource__r.Employment_Type__c != :skedConstants.RESOURCE_EMPLOYMENT_TYPE_SUBCONTRACTOR)
                                           FROM sked__Job__c
                                           WHERE Training_Event__c = :model.trainingEventId
                                           AND sked__Job_Status__c != :skedConstants.JOB_STATUS_CANCELLED]);
        if (mapCurrentSkedJob.isEmpty()) {
            return currentAllocations;
        }

        List<jobModel> jobsToValidate = new List<jobModel>();
        Set<Id> rescheduledJobsResourceIds = new Set<Id>();
        Set<Id> excludedJobIds = new Set<Id>();
        Set<string> allocationKeys = new Set<string>();
        for (jobModel job : scheduledJobs) {
            if (!string.isBlank(job.id) && job.jobStatus != skedConstants.JOB_STATUS_CANCELLED) {
                sked__Job__c currentSkedJob = mapCurrentSkedJob.get(job.id);
                jobModel clonedJob = job.clone();
                if (model.beforeClassDuration != NULL) {
                    clonedJob.start = skedDateTimeUtils.addMinutes(clonedJob.start, -1 * integer.valueOf(model.beforeClassDuration), model.timezoneSidId);
                }
                if (model.afterClassDuration != NULL) {
                    clonedJob.finish = skedDateTimeUtils.addMinutes(clonedJob.finish, integer.valueOf(model.afterClassDuration), model.timezoneSidId);
                }
                clonedJob.geoLocation = currentSkedJob.sked__GeoLocation__c;
                clonedJob.jobType = currentSkedJob.sked__Type__c;
                jobsToValidate.add(clonedJob);
                excludedJobIds.add(job.id);

                for (sked__Job_Allocation__c skedAllocation : currentSkedJob.sked__Job_Allocations__r) {
                    rescheduledJobsResourceIds.add(skedAllocation.sked__Resource__c);
                    allocationKeys.add(skedAllocation.sked__UniqueKey__c);
                }
            }
        }

        if (!jobsToValidate.isEmpty()) {
            sked_Admin_Setting__c adminSetting = sked_Admin_Setting__c.getOrgDefaults();
            skedAvailatorParams params = new skedAvailatorParams();
            params.timezoneSidId = model.timezoneSidId;
            params.resourceIds = rescheduledJobsResourceIds;
            params.inputJobs = jobsToValidate;
            params.excludedJobIds = excludedJobIds;
            params.allocationKeys = allocationKeys;
            params.useGoogleService = adminSetting.Google_Travel_Time_Enabled__c == TRUE;
            
            skedAvailator availator = new skedAvailator(params);
            availator.validateJobs();

            currentAllocations = availator.getAllAllocations();
        }
        return currentAllocations;
    }

    /**************************************************************** Resource Availability ***********************************************************************/
    private static Map<Id, resourceModel> initializeResourceList(Set<Id> resourceIds, Set<Id> exlucdeJobIds, DateTime startTime, DateTime endTime, string timezoneSidId) {
        DateTime firstDateStart = skedDateTimeUtils.GetStartOfDate(startTime, timezoneSidId);
        DateTime lastDateEnd = skedDateTimeUtils.GetEndOfDate(endTime, timezoneSidId);
        Map<Id, sked__Resource__c> mapSkedResource = getResourceWithAvailabilities(resourceIds, exlucdeJobIds, firstDateStart, lastDateEnd);
        
        Map<Id, resourceModel> mapResource = new Map<Id, resourceModel>();
        for (sked__Resource__c skedResource : mapSkedResource.values()) {
            resourceModel resource = new resourceModel();
            resource.id = skedResource.Id;
            resource.employmentType = skedResource.Employment_Type__c;
            resource.lat = skedResource.sked__GeoLocation__Latitude__s;
            resource.lng = skedResource.sked__GeoLocation__Longitude__s;

            if (skedResource.Inactive_From__c != NULL) {
                DateTime inactiveFromDt = DateTime.newInstance(skedResource.Inactive_From__c, Time.newInstance(0, 0, 0, 0));
                resource.inactiveFrom = inactiveFromDt.format(skedDateTimeUtils.DATE_ISO_FORMAT);
            }

            resource.loadResourceTags(skedResource.sked__ResourceTags__r);
            resource.mapDateslot = new Map<string, dateslotModel>();
            
            DateTime tempDt = firstDateStart;
            while (tempDt < lastDateEnd) {
                dateslotModel dateslot = new dateslotModel();
                dateslot.stringValue = tempDt.format(skedDateTimeUtils.DATE_FORMAT, timezoneSidId);
                dateslot.dateValue = skedDateTimeUtils.getDate(tempDt, timezoneSidId);
                dateslot.weekday = tempDt.format('EEE', timezoneSidId).toUpperCase();
                dateslot.start = tempDt;
                dateslot.finish = skedDateTimeUtils.addDays(dateslot.start, 1, timezoneSidId);
                dateslot.addEvent(dateslot.start, dateslot.finish, 'non-working', false, timezoneSidId);
                
                resource.mapDateslot.put(dateslot.stringValue, dateslot);
                tempDt = skedDateTimeUtils.addDays(tempDt, 1, timezoneSidId);
            }
            mapResource.put(resource.Id, resource);
        }
        
        loadWorkingTime(mapResource, resourceIds, timezoneSidId);

        for (sked__Resource__c skedResource : mapSkedResource.values()) {
            resourceModel resource = mapResource.get(skedResource.Id);
            loadResourceEvents(skedResource, resource, timezoneSidId);
            
            resource.allEvents = new List<skedBaseModels.event>();
            for (dateslotModel dateslot : resource.mapDateslot.values()) {
                resource.allEvents.addAll(dateslot.events);
            }
            resource.allEvents.sort();
        }
        return mapResource;
    }

    private static void loadWorkingTime(Map<Id, resourceModel> mapResource, Set<Id> resourceIds, string timezoneSidId) {
        DateTime currentTime = system.now();
        
        List<sked__Availability_Template_Resource__c> templateResourceList = [SELECT sked__Resource__c, sked__Availability_Template__c
                                                                              FROM sked__Availability_Template_Resource__c
                                                                              WHERE sked__Resource__c IN :resourceIds];
        
        Map<Id, Id> map_ResourceId_TemplateId = new Map<Id, Id>();
        for (sked__Availability_Template_Resource__c atr : templateResourceList) {
            map_ResourceId_TemplateId.put(atr.sked__Resource__c, atr.sked__Availability_Template__c);
        }
        
        map<Id, sked__Availability_Template__c> mapTemplate 
            = new map<Id, sked__Availability_Template__c>([SELECT Id, 
                                                           (SELECT Id, sked__Finish_Time__c, sked__Is_Available__c, sked__Start_Time__c, sked__Weekday__c 
                                                            FROM sked__Availability_Template_Entries__r) 
                                                           FROM sked__Availability_Template__c 
                                                           WHERE Id IN :map_ResourceId_TemplateId.values()]);
        
        Map<string, Set<Date>> mapHolidays = skedDateTimeUtils.getHolidays();
        
        sked_Admin_Setting__c adminSetting = sked_Admin_Setting__c.getOrgDefaults();
        for (ResourceModel resource : mapResource.values()) {
            Set<Date> allHolidays = new Set<Date>();
            if (adminSetting.Respect_Holiday__c == TRUE) {
                if (mapHolidays.containsKey(skedConstants.HOLIDAY_GLOBAL)) {
                    Set<Date> globalHolidays = mapHolidays.get(skedConstants.HOLIDAY_GLOBAL);
                    allHolidays.addAll(globalHolidays);
                }
                if (mapHolidays.containsKey(resource.RegionId)) {
                    Set<Date> regionHolidays = mapHolidays.get(resource.RegionId);
                    allHolidays.addAll(regionHolidays);
                }
            }
            
            Id templateId = map_ResourceId_TemplateId.get(resource.Id);
            if (templateId == NULL) {
                continue;
            }
            sked__Availability_Template__c avaiTemplate = mapTemplate.get(templateId);
            
            Map<string, sked__Availability_Template_Entry__c> mapEntry = new Map<string, sked__Availability_Template_Entry__c>();
            for (sked__Availability_Template_Entry__c entry : avaiTemplate.sked__Availability_Template_Entries__r) {
                mapEntry.put(entry.sked__Weekday__c, entry);
            }
            for (dateslotModel dateslot : resource.mapDateslot.values()) {
                if (!mapEntry.containsKey(dateslot.weekday)) {
                    continue;
                }
                sked__Availability_Template_Entry__c entry = mapEntry.get(dateslot.Weekday);
                integer startWorkingInMinutes = integer.valueOf(integer.valueOf(entry.sked__Start_Time__c) / 100) * 60 + Math.mod(integer.valueOf(entry.sked__Start_Time__c), 100);
                integer endWorkingInMinutes = integer.valueOf(integer.valueOf(entry.sked__Finish_Time__c) / 100) * 60 + Math.mod(integer.valueOf(entry.sked__Finish_Time__c), 100);
                
                DateTime startWorkingTime = skedDateTimeUtils.addMinutes(dateslot.start, startWorkingInMinutes, timezoneSidId);
                DateTime endWorkingTime = skedDateTimeUtils.addMinutes(dateslot.start, endWorkingInMinutes, timezoneSidId);
                
                if (!allHolidays.contains(dateslot.dateValue)) {
                    if (currentTime < endWorkingTime) {
                        dateslot.AddEvent(startWorkingTime, endWorkingTime, null, true, timezoneSidId);
                    }
                }
            }
        }
    }
    
    private static void loadResourceEvents(sked__Resource__c skedResource, resourceModel resource, string timezoneSidId) {
        for (sked__Availability__c availableBlock : skedResource.sked__Availabilities1__r) {
            if (availableBlock.sked__Is_Available__c != TRUE) {
                continue;
            }
            DateTime availableStart = availableBlock.sked__Start__c;
            DateTime availableEnd = availableBlock.sked__Finish__c;
            
            dateslotModel firstDateSlot = resource.mapDateslot.values().get(0);
            if (availableStart < firstDateSlot.start) {
                availableStart = firstDateSlot.start;
            }
            dateslotModel lastDateSlot = resource.mapDateslot.values().get(resource.mapDateslot.values().size() - 1);
            if (availableEnd > lastDateSlot.finish) {
                availableEnd = lastDateSlot.finish;
            }
            
            string availableDateString = availableStart.format(skedDateTimeUtils.DATE_FORMAT, timezoneSidId);
            dateslotModel dateslot = resource.mapDateslot.get(availableDateString);
            dateslot.AddEvent(availableStart, availableEnd, null, true, timezoneSidId);
        }
        
        for (sked__Availability__c unavailableBlock : skedResource.sked__Availabilities1__r) {
            if (unavailableBlock.sked__Is_Available__c != FALSE) {
                continue;
            }
            DateTime unavailableStart = unavailableBlock.sked__Start__c;
            DateTime unavailableEnd = unavailableBlock.sked__Finish__c;
            
            for (dateslotModel dateslot : resource.mapDateslot.values()) {
                if (dateslot.finish <= unavailableStart || dateslot.start >= unavailableEnd) {
                    continue;
                }
                else {
                    DateTime tempStart = unavailableStart < dateslot.start ? dateslot.start : unavailableStart; 
                    DateTime tempEnd = unavailableEnd > dateslot.finish ? dateslot.finish : unavailableEnd;
                    skedBaseModels.event event = new skedBaseModels.event();
                    event.eventType = 'availability';
                    event.startDate = unavailableBlock.sked__Start__c.format(skedDateTimeUtils.DATE_ISO_FORMAT, timezoneSidId);
                    event.endDate = unavailableBlock.sked__Finish__c.format(skedDateTimeUtils.DATE_ISO_FORMAT, timezoneSidId);
                    event.startTime = integer.valueOf(unavailableBlock.sked__Start__c.format('Hmm', timezoneSidId));
                    event.finishTime = integer.valueOf(unavailableBlock.sked__Finish__c.format('Hmm', timezoneSidId));

                    dateslot.events.add(event);
                }
            }
        }
        for (sked__Job_Allocation__c skedAllocation : skedResource.sked__Job_Allocations__r) {
            string allocationDateString = skedAllocation.sked__Job__r.sked__Start__c.format(skedDateTimeUtils.DATE_FORMAT, timezoneSidId);
            if (resource.mapDateslot.containsKey(allocationDateString)) {
                dateslotModel dateslot = resource.mapDateslot.get(allocationDateString);

                integer beforeClassDuration = skedAllocation.sked__Job__r.Before_class_duration__c == NULL 
                    ? 0 : integer.valueOf(skedAllocation.sked__Job__r.Before_class_duration__c);
                integer afterClassDuration = skedAllocation.sked__Job__r.After_class_duration__c == NULL 
                    ? 0 : integer.valueOf(skedAllocation.sked__Job__r.After_class_duration__c);
                
                DateTime jobStart = skedDateTimeUtils.addMinutes(skedAllocation.sked__Job__r.sked__Start__c, -1 * beforeClassDuration, timezoneSidId);
                DateTime jobFinish = skedDateTimeUtils.addMinutes(skedAllocation.sked__Job__r.sked__Finish__c, afterClassDuration, timezoneSidId);

                skedBaseModels.event jobAllocation = new skedBaseModels.event();
                jobAllocation.eventType = 'jobAllocation';
                jobAllocation.startDate = jobStart.format(skedDateTimeUtils.DATE_ISO_FORMAT, timezoneSidId);
                jobAllocation.endDate = jobFinish.format(skedDateTimeUtils.DATE_ISO_FORMAT, timezoneSidId);
                jobAllocation.startTime = integer.valueOf(jobStart.format('Hmm', timezoneSidId));
                jobAllocation.finishTime = integer.valueOf(jobFinish.format('Hmm', timezoneSidId));
                if (skedAllocation.sked__Job__r.sked__GeoLocation__c != NULL) {
                    jobAllocation.geometry = new skedBaseModels.geometry('', skedAllocation.sked__Job__r.sked__GeoLocation__Latitude__s, skedAllocation.sked__Job__r.sked__GeoLocation__Longitude__s);
                }
                dateslot.events.add(jobAllocation);
            }
        }
        
        for (sked__Activity__c skedActivity : skedResource.sked__Activities__r) {
            string activityDateString = skedActivity.sked__Start__c.format(skedDateTimeUtils.DATE_FORMAT, timezoneSidId);
            if (resource.mapDateslot.containsKey(activityDateString)) {
                dateslotModel dateslot = resource.mapDateslot.get(activityDateString);
                skedBaseModels.event activity = new skedBaseModels.event();
                activity.eventType = 'activity';
                activity.startDate = skedActivity.sked__Start__c.format(skedDateTimeUtils.DATE_ISO_FORMAT, timezoneSidId);
                activity.endDate = skedActivity.sked__End__c.format(skedDateTimeUtils.DATE_ISO_FORMAT, timezoneSidId);
                activity.startTime = integer.valueOf(skedActivity.sked__Start__c.format('Hmm', timezoneSidId));
                activity.finishTime = integer.valueOf(skedActivity.sked__End__c.format('Hmm', timezoneSidId));
                if (skedActivity.sked__GeoLocation__c != NULL) {
                    activity.geometry = new skedBaseModels.geometry('', skedActivity.sked__GeoLocation__Latitude__s, skedActivity.sked__GeoLocation__Longitude__s);
                }
                dateslot.events.add(activity);
            }
        }
    }

    private static Map<Id, sked__Resource__c> getResourceWithAvailabilities(Set<Id> resourceIds, Set<Id> exlucdeJobIds, DateTime startTime, DateTime endTime) {
        return new Map<Id, sked__Resource__c>([SELECT Id, Name, sked__Category__c, Employment_Type__c, sked__GeoLocation__Latitude__s,
                                               sked__GeoLocation__Longitude__s, sked__GeoLocation__c, Inactive_From__c,
                                               
                                               (SELECT Id, sked__Tag__c, sked__Tag__r.Name, sked__Resource__c, sked__Expiry_Date__c
                                                FROM sked__ResourceTags__r),
                                               
                                               (SELECT Id, Name, sked__Job__c, sked__Job__r.Name, sked__Job__r.sked__Type__c, sked__Job__r.sked__Start__c, 
                                                sked__Job__r.sked__Finish__c, sked__Job__r.sked__Timezone__c, sked__Job__r.sked__GeoLocation__c, sked__Resource__c,
                                                sked__Job__r.sked__GeoLocation__Latitude__s, sked__Job__r.sked__GeoLocation__Longitude__s,
                                                sked__Job__r.After_class_duration__c, sked__Job__r.Before_class_duration__c
                                                FROM sked__Job_Allocations__r
                                                WHERE sked__Job__c NOT IN :exlucdeJobIds
                                                AND sked__Status__c != :skedConstants.JOB_ALLOCATION_STATUS_DELETED 
                                                AND sked__Job__r.sked__Job_Status__c != :skedConstants.JOB_STATUS_CANCELLED
                                                AND sked__Job__r.sked__Start__c < :endTime AND sked__Job__r.sked__Finish__c > :startTime
                                                ORDER BY sked__Job__r.sked__Start__c ASC),
                                               
                                               (SELECT Id, Name, sked__Start__c, sked__Finish__c, sked__Is_Available__c, sked__Status__c, sked__Timezone__c
                                                FROM sked__Availabilities1__r
                                                WHERE sked__Start__c < :endTime AND sked__Finish__c > :startTime
                                                AND sked__Status__c = 'Approved'
                                                ORDER BY sked__Start__c ASC),
                                               
                                               (SELECT Id, Name, sked__Start__c, sked__End__c, sked__Address__c, sked__GeoLocation__c,
                                                sked__GeoLocation__Latitude__s, sked__GeoLocation__Longitude__s, sked__Timezone__c
                                                FROM sked__Activities__r
                                                WHERE sked__Start__c < :endTime AND sked__End__c > :startTime
                                                ORDER BY sked__Start__c ASC)
                                               
                                               FROM sked__Resource__c
                                               WHERE Id IN :resourceIds]);
    }

    private static void calculateResourceHours(Map<Id, resourceModel> mapResource, Date startDate, Date endDate, Set<Id> excludedJobIds, string timezoneSidId) {
        Date firstWeekStartDate = skedDateTimeUtils.getArcWeekStartDate(startDate);
        Date lastWeekEndDate = skedDateTimeUtils.getArcWeekStartDate(endDate).addDays(6);

        DateTime startTime = skedDateTimeUtils.getStartOfDate(firstWeekStartDate, timezoneSidId);
        DateTime endTime = skedDateTimeUtils.getEndOfDate(lastWeekEndDate, timezoneSidId);

        DateTime tempDt = startTime;
        while (tempDt < endTime) {
            string weekStartDateStr = tempDt.format(skedDateTimeUtils.DATE_ISO_FORMAT, timezoneSidId);
            string weekEndDateStr = skedDateTimeUtils.addDays(tempDt, 6, timezoneSidId).format(skedDateTimeUtils.DATE_ISO_FORMAT, timezoneSidId);
            Date weekStartDate = skedDateTimeUtils.getDateFromIsoString(weekStartDateStr);

            for (resourceModel resource : mapResource.values()) {
                scheduledHoursModel scheduledHour = new scheduledHoursModel();
                scheduledHour.startDate = weekStartDateStr;
                scheduledHour.endDate = weekEndDateStr;
                scheduledHour.startDt = tempDt;
                scheduledHour.endDt = skedDateTimeUtils.addDays(tempDt, 7, timezoneSidId);
                resource.mapScheduledHours.put(weekStartDate, scheduledHour);
            }
            tempDt = skedDateTimeUtils.addDays(tempDt, 7, timezoneSidId);
        }

        List<sked__Resource__c> skedResources = [SELECT Id, sked__Weekly_Hours__c,
                                                 (SELECT Id, sked__Job__r.sked__Duration__c, sked__Job__r.sked__Start__c, sked__Job__r.sked__Finish__c
                                                  FROM sked__Job_Allocations__r
                                                  WHERE sked__Status__c != :skedConstants.JOB_ALLOCATION_STATUS_DELETED
                                                  AND sked__Job__r.sked__Job_Status__c != :skedConstants.JOB_STATUS_CANCELLED
                                                  AND sked__Job__r.sked__Start__c < :endTime
                                                  AND sked__Job__r.sked__Finish__c > :startTime
                                                  AND sked__Job__c NOT IN :excludedJobIds),
                                                  (SELECT Id, sked__Start__c, sked__End__c
                                                   FROM sked__Activities__r
                                                   WHERE sked__Start__c < :endTime
                                                   AND sked__End__c > :startTime)
                                                 FROM sked__Resource__c
                                                 WHERE Id IN :mapResource.keySet()];
        for (sked__Resource__c skedResource : skedResources) {
            resourceModel resource = mapResource.get(skedResource.Id);
            if (skedResource.sked__Weekly_Hours__c != NULL) {
                resource.weeklyMinutes = skedResource.sked__Weekly_Hours__c * 60;
            }
            for (sked__Job_Allocation__c skedAlloc : skedResource.sked__Job_Allocations__r) {
                addAssignedHours(resource.mapScheduledHours, skedAlloc.sked__Job__r.sked__Start__c, skedAlloc.sked__Job__r.sked__Finish__c);
            }
            for (sked__Activity__c skedActivity : skedResource.sked__Activities__r) {
                addAssignedHours(resource.mapScheduledHours, skedActivity.sked__Start__c, skedActivity.sked__End__c);
            }
            resource.scheduledHoursData = resource.mapScheduledHours.values();
        }
    }

    private static void addAssignedHours(Map<Date, scheduledHoursModel> mapScheduledHours, DateTime startTime, DateTime endTime) {
        Date weekStartDate = skedDateTimeUtils.getArcWeekStartDate(startTime.date());
        if (mapScheduledHours.containsKey(weekStartDate)) {
            scheduledHoursModel scheduledHour = mapScheduledHours.get(weekStartDate);
            decimal addedDuration;
            if (endTime > scheduledHour.endDt) {
                addedDuration = (scheduledHour.endDt.getTime() - startTime.getTime()) / 60000;
                scheduledHour.assignedMinutes += addedDuration;

                Date nextWeekStartDate = weekStartDate.addDays(7);
                if (mapScheduledHours.containsKey(nextWeekStartDate)) {
                    scheduledHoursModel nextScheduledHour = mapScheduledHours.get(nextWeekStartDate);
                    decimal addedDurationNextWeek = (endTime.getTime() - scheduledHour.endDt.getTime()) / 60000;
                    nextScheduledHour.assignedMinutes += addedDurationNextWeek;
                }
            }
            else {
                addedDuration = (endTime.getTime() - startTime.getTime()) / 60000;
                scheduledHour.assignedMinutes += addedDuration;
            }
        }
        else {
            weekStartDate = skedDateTimeUtils.getArcWeekStartDate(endTime.date());
            if (mapScheduledHours.containsKey(weekStartDate)) {
                scheduledHoursModel scheduledHour = mapScheduledHours.get(weekStartDate);
                decimal addedDuration = (endTime.getTime() - scheduledHour.startDt.getTime()) / 60000;
                scheduledHour.assignedMinutes += addedDuration;
            }
        }
    }
    
    /**************************************************************** Nested clases ***********************************************************************/
    global class configDataModel {
        public gridSettings gridSettings {get;set;}
        public trainingEventModel rootRecord {get;set;}
        public List<skedModels.courseCatalog> courseCatalogs {get;set;}
        public List<skedModels.selectOption> avEquipments {get;set;}
        public List<skedModels.selectOption> tags {get;set;}
        public List<skedModels.selectOption> regions {get;set;}
        public List<skedModels.selectOption> employmentTypes {get;set;}
        public jobSaveModel scheduledJobInfo {get;set;}
        public skedModels.permissionModel userPermission {get;set;}
        public List<skedModels.jobStatusSetting> jobStatusSettings {get;set;}
        public List<jobModel> scheduledJobs {get;set;}

        public configDataModel() {
            this.courseCatalogs = new List<skedModels.courseCatalog>();
            this.avEquipments = new List<skedModels.selectOption>();
            this.tags = new List<skedModels.selectOption>();
            this.regions = new List<skedModels.selectOption>();
            this.employmentTypes = new List<skedModels.selectOption>();
            this.scheduledJobs = new List<jobModel>();
        }
    }
    
    global class gridSettings {
        public integer gridStartTime {get;set;}
        public integer gridEndTime {get;set;}
        
        public gridSettings() {
            this.gridStartTime = 700;
            this.gridEndTime = 1900;
        }
    }
    
    global class bookingGridQueryModel {
        public string trainingEventId {get;set;}
        public string regionId {get;set;}
        public string startDateIso {get;set;}
        public string endDateIso {get;set;}
        public integer startTimeInt {get;set;}
        public integer endTimeInt {get;set;}
        public List<string> tagIds {get;set;}
        public integer jobDuration {get;set;}
        public integer timeslotStep {get;set;}
        public decimal radius {get;set;}
        public decimal lat {get;set;}
        public decimal lng {get;set;}
        public integer beforeClassDuration {get;set;}
        public integer afterClassDuration {get;set;}
        
        public transient string timezoneSidId {get;set;}
        public transient DateTime startTime {get;set;}
        public transient DateTime endTime {get;set;}
    }
    
    global class jobSaveModel {
        public string contactId {get;set;}
        public string regionId {get;set;}
        public string scheduleId {get;set;}
        public string trainingEventId {get;set;}
        public string courseCatalogId {get;set;}
        public string courseCatalogName {get;set;}
        public List<string> selectedAvEquipments {get;set;}
        public integer numberOfStudents {get;set;}
        public integer numberOfInstructors {get;set;}
        public integer classDuration {get;set;}
        public integer breakDuration {get;set;}
        public integer numberOfBreaks {get;set;}
        public boolean test {get;set;}
        public string specialInstructions {get;set;}
        public List<string> tagIds {get;set;}
        
        public addressModel address {get;set;}
        
        public string selectedDate {get;set;}
        public integer selectedTime {get;set;}
        public integer beforeClassDuration {get;set;}
        public integer afterClassDuration {get;set;}
        public integer numberOfClasses {get;set;}

        public gridSettingModel gridSettings {get;set;}
        
        public transient string timezoneSidId {get;set;}
        public transient string accountId {get;set;}
    }

    global class addressModel {
        public string fullAddress {get;set;}
        public decimal lat {get;set;}
        public decimal lng {get;set;}

        public string address1 {get;set;}
        public string address2 {get;set;}
        public string city {get;set;}
        public string state {get;set;}
        public string zip {get;set;}
        public string territory {get;set;}
    }
    
    global class contactModel {
        public string id {get;set;}
        public string accountId {get;set;}
        public string firstName {get;set;}
        public string lastName {get;set;}
        public string phone {get;set;}
        public string email {get;set;}

        public contactModel(Contact con) {
            this.id = con.Id;
            this.accountId = con.AccountId;
            this.firstName = con.FirstName;
            this.lastName = con.LastName;
            this.phone = con.Phone;
            this.email = con.Email;
        }
    }

    global class bookingGridModel {
        public integer noOfSubcontractors {get;set;}
        public string timezone {get;set;}
        public List<slotModel> slots {get;set;}
    }
    
    global class slotModel {
        public string slotDate {get;set;}
        public integer slotTime {get;set;}
        public integer noOfQualifiedResources {get;set;}
        public integer noOfAvailableResources {get;set;}
        
        public transient string slotKey {get;set;}
        public transient DateTime startTime {get;set;}
        public transient DateTime endTime {get;set;}
        
        public slotModel() {
            this.noOfQualifiedResources = 0;
            this.noOfAvailableResources = 0;
        }
    }

    global class jobModel extends skedModels.job {
        public integer numberOfInstructors {get;set;}
        public Set<Id> tagIds {get;set;}
        public boolean isChanged {get;set;}

        public jobModel() {}
    }

    global class gridSettingModel {
        public integer radius {get;set;}
        public integer interval {get;set;}
        public boolean subcontractor {get;set;}
        public boolean show24Hours {get;set;}
        public List<integer> scheduledHours {get;set;}
        public List<string> employmentTypes {get;set;}
    }
    
    global class trainingEventModel {
        public string id {get;set;}
        public string name {get;set;}
        public string regionId {get;set;}
        public string regionName {get;set;}
        public string accountId {get;set;}
        public string accountName {get;set;}
        public contactModel contact {get;set;}
        public string specialInstructions {get;set;}
        public string address {get;set;}
        public List<skedModels.selectOption> equipments {get;set;}
        
        public trainingEventModel(Training_Events__c skedTrainingEvent) {
            this.id = skedTrainingEvent.Id;
            this.name = skedTrainingEvent.Name;
            if (skedTrainingEvent.Account__c != NULL) {
                this.accountId = skedTrainingEvent.Account__c;
                this.accountName = skedTrainingEvent.Account__r.Name;
            }
            if (skedTrainingEvent.Training_Contact__c != NULL) {
                this.contact = new contactModel(skedTrainingEvent.Training_Contact__r);
            }
            this.equipments = new List<skedModels.selectOption>();
            this.specialInstructions = skedTrainingEvent.Special_Instructions__c;

            if (skedTrainingEvent.Region__c != NULL) {
                this.regionId = skedTrainingEvent.Region__c;
                this.regionName = skedTrainingEvent.Region__r.Name;
            }

            if (!string.isBlank(skedTrainingEvent.Training_Address_1__c)) {
                string address = skedTrainingEvent.Training_Address_1__c;
                if (!string.isBlank(skedTrainingEvent.Training_City__c)) {
                    address += ', ' + skedTrainingEvent.Training_City__c;
                }
                if (!string.isBlank(skedTrainingEvent.Training_Location_State__c)) {
                    address += ', ' + skedTrainingEvent.Training_Location_State__c;
                }
                if (!string.isBlank(skedTrainingEvent.Training_Zip__c)) {
                    address += ' ' + skedTrainingEvent.Training_Zip__c;
                }
                this.address = address;
            }
        }
    }

    global class resourceDataModel {
        public string timezoneSidId {get;set;}
        public string timezone {get;set;}
        public List<resourceModel> resources {get;set;}
        public List<jobModel> pendingJobs {get;set;}
        public integer noOfSubcontractors {get;set;}
    }

    global class scheduledHoursModel {
        public string startDate {get;set;}
        public string endDate {get;set;}
        public double assignedMinutes {get;set;}
        public transient DateTime startDt {get;set;}
        public transient DateTime endDt {get;set;}

        public scheduledHoursModel() {
            this.assignedMinutes = 0;
        }
    }

    global class dateslotModel {
        public string stringValue {get;set;}
        public Date dateValue {get;set;}
        public DateTime start {get;set;}
        public DateTime finish {get;set;}
        public string weekday {get;set;}
        public List<skedBaseModels.event> events {get;set;}
        
        public dateslotModel() {
            this.events = new List<skedBaseModels.event>();
        }
        
        public skedBaseModels.event addEvent(DateTime startTime, DateTime endTime, string eventType, boolean isAvailable, string timezoneSidId) {
            return addEvent(startTime, endTime, eventType, isAvailable, null, timezoneSidId);
        }
        
        public skedBaseModels.event addEvent(DateTime startTime, DateTime endTime, string eventType, boolean isAvailable, string relatedId, string timezoneSidId) {
            if (isAvailable == true) {
                addAvailableBlock(startTime, endTime, timezoneSidId);
            }
            else {
                skedBaseModels.event newEvent = new skedBaseModels.event();
                newEvent.start = startTime;
                newEvent.finish = endTime;
                newEvent.startDate = startTime.format(skedDateTimeUtils.DATE_ISO_FORMAT, timezoneSidId);
                newEvent.endDate = endTime.format(skedDateTimeUtils.DATE_ISO_FORMAT, timezoneSidId);
                newEvent.startTime = integer.valueOf(startTime.format('Hmm', timezoneSidId));
                newEvent.finishTime = integer.valueOf(endTime.format('Hmm', timezoneSidId));
                newEvent.eventType = eventType;
                this.events.add(newEvent);
                return newEvent;
            }
            return null;
        }
        
        private void addAvailableBlock(DateTime startTime, DateTime endTime, string timezoneSidId) {
            List<skedBaseModels.event> newEvents = new List<skedBaseModels.event>();
            Set<DateTime> removedEvents = new Set<DateTime>();
            
            for (skedBaseModels.event eventItem : this.events) {
                if (eventItem.start < startTime && startTime < eventItem.finish) {
                    if (endTime < eventItem.finish) {
                        skedBaseModels.event newEvent = new skedBaseModels.event();
                        newEvent.start = endTime;
                        newEvent.finish = eventItem.finish;
                        newEvent.eventType = eventItem.eventType;
                        newEvent.startDate = newEvent.start.format(skedDateTimeUtils.DATE_ISO_FORMAT, timezoneSidId);
                        newEvent.endDate = newEvent.finish.format(skedDateTimeUtils.DATE_ISO_FORMAT, timezoneSidId);
                        newEvent.startTime = integer.valueOf(newEvent.start.format('Hmm', timezoneSidId));
                        newEvent.finishTime = integer.valueOf(newEvent.finish.format('Hmm', timezoneSidId));
                        newEvents.add(newEvent);
                    }
                    eventItem.finish = startTime;
                    eventItem.finishTime = integer.valueOf(eventItem.finish.format('Hmm', timezoneSidId));
                    eventItem.endDate = eventItem.finish.format(skedDateTimeUtils.DATE_ISO_FORMAT, timezoneSidId);
                }
                else if (startTime <= eventItem.start) {
                    if (endTime >= eventItem.finish) {
                        removedEvents.add(eventItem.start);
                    }
                    else if (eventItem.start < endTime && endTime < eventItem.finish) {
                        eventItem.start = endTime;
                        eventItem.startTime = integer.valueOf(eventItem.start.format('Hmm', timezoneSidId));
                        eventItem.startDate = eventItem.start.format(skedDateTimeUtils.DATE_ISO_FORMAT, timezoneSidId);
                    }
                }
            }
            
            for (integer i = this.events.size() - 1; i >= 0; i--) {
                skedBaseModels.event eventItem = this.events.get(i);
                if (removedEvents.contains(eventItem.start)) {
                    this.events.remove(i);
                }
            }
            
            this.events.addAll(newEvents);
        }
    }

    global class resourceModel extends skedModels.resource {
        public transient Map<string, dateslotModel> mapDateslot {get;set;}
        public transient Map<Date, scheduledHoursModel> mapScheduledHours {get;set;}
        public List<skedBaseModels.event> allEvents {get;set;}
        public List<scheduledHoursModel> scheduledHoursData {get;set;}
        public string inactiveFrom {get;set;}

        public resourceModel() {
            this.mapScheduledHours = new Map<Date, scheduledHoursModel>();
        }
        
        public resourceModel(sked__Resource__c skedResource) {
            super(skedResource);
            this.mapScheduledHours = new Map<Date, scheduledHoursModel>();
        }
    }
    
}