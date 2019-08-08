global class skedResourceReportController {
    
    public skedResourceReportController() {

    }
    
    @remoteAction
    global static skedRemoteResultModel runReport(reportCriteria criteria) {
        skedRemoteResultModel result = new skedRemoteResultModel();
        try {
            preProcessReportCriteria(criteria);

            Set<Id> resourceIds = getResourceIdsByCriteria(criteria);

            List<resourceModel> resources = new List<resourceModel>();
            if (!resourceIds.isEmpty()) {
                List<sked__Resource__c> skedResources = [SELECT Id, Name, sked__Primary_Region__c, sked__Primary_Region__r.Name, 
                                                         sked__User__r.SmallPhotoUrl, Employment_Type__c, Supervisor__r.Name,
                                                         
                                                         (SELECT Id, sked__Job__c, sked__Job__r.Name, sked__Job__r.sked__Start__c, sked__Job__r.sked__Finish__c, 
                                                          sked__Job__r.sked__Duration__c, sked__Job__r.sked__Type__c, sked__Job__r.sked__Job_Status__c,
                                                          sked__Job__r.sked__Description__c, sked__Job__r.sked__Account__r.Name, sked__Job__r.sked__Address__c
                                                          FROM sked__Job_Allocations__r
                                                          WHERE sked__Job__r.sked__Start__c < :criteria.endTime
                                                          AND sked__Job__r.sked__Finish__c > :criteria.startTime
                                                          AND sked__Job__r.sked__Job_Status__c IN :criteria.jobStatuses
                                                          AND sked__Job__r.sked__Type__c IN :criteria.jobTypes
                                                          AND sked__Status__c != :skedConstants.JOB_ALLOCATION_STATUS_DELETED
                                                          AND sked__Status__c != :skedConstants.JOB_ALLOCATION_STATUS_DECLINED
                                                          ORDER BY sked__Job__r.sked__Start__c ASC),
                                                         
                                                         (SELECT Id, Name, sked__Start__c, sked__End__c, sked__Type__c
                                                          FROM sked__Activities__r
                                                          WHERE sked__Start__c < :criteria.endTime
                                                          AND sked__End__c > :criteria.startTime
                                                          AND sked__Type__c IN :criteria.activityTypes
                                                          ORDER BY sked__Start__c ASC),
                                                         
                                                         (SELECT Id, Name, sked__Start__c, sked__Finish__c, sked__Type__c,
                                                          sked__Is_Available__c, sked__Status__c
                                                          FROM sked__Availabilities1__r
                                                          WHERE sked__Start__c < :criteria.endTime
                                                          AND sked__Finish__c > :criteria.startTime
                                                          AND sked__Type__c IN :criteria.availabilityTypes
                                                          ORDER BY sked__Start__c ASC)
                                                         
                                                         FROM sked__Resource__c
                                                         WHERE Id IN : resourceIds
                                                         AND sked__Is_Active__c = TRUE
                                                         ORDER BY Name ASC];
                
                for (sked__Resource__c skedResource : skedResources) {
                    resourceModel model = new resourceModel();
                    model.id = skedResource.Id;
                    model.name = skedResource.Name;
                    model.employmentType = skedResource.Employment_Type__c;
                    model.regionName = skedResource.sked__Primary_Region__r.Name;
                    model.supervisorName = skedResource.Supervisor__r.Name;
                    if (skedResource.sked__User__r != NULL) {
                        model.photoUrl = skedResource.sked__User__r.SmallPhotoUrl;
                    }
                    
                    model.totalJobDuration = model.totalActivityDuration = model.totalAvailabilityDuration = 0;

                    model.jobs = new List<jobModel>();
                    for (sked__Job_Allocation__c skedAllocation : skedResource.sked__Job_Allocations__r) {
                        jobModel job = new jobModel(skedAllocation);
                        model.jobs.add(job);
                        model.totalJobDuration += skedAllocation.sked__Job__r.sked__Duration__c;
                    }
                    
                    model.activities = new List<activityModel>();
                    for (sked__Activity__c skedActivity : skedResource.sked__Activities__r) {
                        activityModel activity = new activityModel(skedActivity);
                        model.activities.add(activity);
                        
                        decimal activityDuration = (skedActivity.sked__End__c.getTime() - skedActivity.sked__Start__c.getTime()) / 60000;
                        model.totalActivityDuration += activityDuration;
                    }
                    
                    model.availabilities = new List<availabilityModel>();
                    for (sked__Availability__c skedAvailability : skedResource.sked__Availabilities1__r) {
                        availabilityModel availability = new availabilityModel(skedAvailability);
                        model.availabilities.add(availability);
                        
                        if (skedAvailability.sked__Is_Available__c == false && skedAvailability.sked__Status__c != skedConstants.AVAILABILITY_STATUS_DECLINED) {
                            decimal availabilityDuration = (skedAvailability.sked__Finish__c.getTime() - skedAvailability.sked__Start__c.getTime()) / 60000;
                            model.totalAvailabilityDuration += availabilityDuration;
                        }
                    }

                    model.totalDuration = model.totalJobDuration + model.totalActivityDuration;
                    if (model.totalDuration > 0 || model.totalAvailabilityDuration > 0) {
                        model.totalDurationText = skedDateTimeUtils.getDurationText(model.totalDuration);
                        model.totalJobDurationText = skedDateTimeUtils.getDurationText(model.totalJobDuration);
                        model.totalActivityDurationText = skedDateTimeUtils.getDurationText(model.totalActivityDuration);
                        model.totalAvailabilityDurationText = skedDateTimeUtils.getDurationText(model.totalAvailabilityDuration);
                        resources.add(model);
                    }
                }
            }

            result.data = resources;
        }
        catch (Exception ex) {
            result.getError(ex);
        }
        return result;
    }
        
    @remoteAction
    global static skedRemoteResultModel getConfigData() {
        skedRemoteResultModel result = new skedRemoteResultModel();
        try {
        	configDataModel configData = new configDataModel();
            configData.activityTypeOptions = skedUtils.getPickListValues('sked__Activity__c', 'sked__Type__c');
            configData.availabilityTypeOptions = skedUtils.getPickListValues('sked__Availability__c', 'sked__Type__c');
            configData.employmentTypeOptions = skedUtils.getPickListValues('sked__Resource__c', 'Employment_Type__c');
            configData.jobTypeOptions = skedUtils.getPickListValues('sked__Job__c', 'sked__Type__c');
            
            Set<string> excludedJobStatuses = new Set<string>();
            excludedJobStatuses.add(skedConstants.JOB_STATUS_CANCELLED);
            configData.jobStatusOptions = skedUtils.getPickListValues('sked__Job__c', 'sked__Job_Status__c', excludedJobStatuses);
            
            configData.regionOptions = skedUtils.getRegions(null);
            configData.supervisorOptions = getSupervisorOptions();
                
            result.data = configData;
        }
        catch (Exception ex) {
            result.getError(ex);
        }
        return result;
    }
    
    /**************************************************************** Private methods ***********************************************************************/
    private static List<string> getPickListValues(string objectApiName, string fieldApiName) {
        List<string> picklistValues = new List<string>();
        
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objectApiName);
        DescribeSObjectResult objDescribe = targetType.getDescribe();
        map<String, SObjectField> mapFields = objDescribe.fields.getmap();
        SObjectField fieldType = mapFields.get(fieldApiName);
        DescribeFieldResult fieldResult = fieldType.getDescribe();
        
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple) {
            picklistValues.add(f.getValue());
        }
        return picklistValues;
    }
    
    private static void preProcessReportCriteria(reportCriteria criteria) {
        Date startDate = (Date)Json.deserialize('"' + criteria.startDateStr + '"', Date.class);
        Date endDate = (Date)Json.deserialize('"' + criteria.endDateStr + '"', Date.class);
        
        criteria.startTime = DateTime.newInstance(startDate, Time.newInstance(0, 0, 0, 0));
        criteria.endTime = DateTime.newInstance(endDate, Time.newInstance(0, 0, 0, 0));
        criteria.endTime = criteria.endTime.addDays(1);
        
        if (criteria.regionIds == NULL || criteria.regionIds.isEmpty()) {
            List<sked__Region__c> allRegions = [SELECT Id FROM sked__Region__c];
            criteria.regionIds = new List<string>();
            for (sked__Region__c skedRegion : allRegions) {
                criteria.regionIds.add(skedRegion.Id);
            }
        }
        if (criteria.activityTypes == NULL || criteria.activityTypes.isEmpty()) {
            criteria.activityTypes = getPickListValues('sked__Activity__c', 'sked__Type__c');
        }
        if (criteria.availabilityTypes == NULL || criteria.availabilityTypes.isEmpty()) {
            criteria.availabilityTypes = getPickListValues('sked__Availability__c', 'sked__Type__c');
        }
        if (criteria.employmentTypes == NULL || criteria.employmentTypes.isEmpty()) {
            criteria.employmentTypes = getPickListValues('sked__Resource__c', 'Employment_Type__c');
        }
        if (criteria.jobTypes == NULL || criteria.jobTypes.isEmpty()) {
            criteria.jobTypes = getPickListValues('sked__Job__c', 'sked__Type__c');
        }
        if (criteria.jobStatuses == NULL || criteria.jobStatuses.isEmpty()) {
            Set<string> excludedJobStatuses = new Set<string>();
            excludedJobStatuses.add(skedConstants.JOB_STATUS_CANCELLED);
            excludedJobStatuses.add(skedConstants.JOB_STATUS_COMPLETE);
            
            List<string> allJobStatuses = getPickListValues('sked__Job__c', 'sked__Job_Status__c');
            criteria.jobStatuses = new List<string>();
            for (string jobStatus : allJobStatuses) {
                if (!excludedJobStatuses.contains(jobStatus)) {
                    criteria.jobStatuses.add(jobStatus);
                }
            }
        }
    }
    
    private static Set<Id> getResourceIdsByCriteria(reportCriteria criteria) {
        List<sked__Job_Allocation__c> skedAllocationsInTime = [SELECT Id, sked__Resource__c, sked__Resource__r.Supervisor__c
                                                               FROM sked__Job_Allocation__c
                                                               WHERE sked__Job__r.sked__Start__c < :criteria.endTime
                                                               AND sked__Job__r.sked__Finish__c > :criteria.startTime
                                                               AND sked__Job__r.sked__Job_Status__c IN :criteria.jobStatuses
                                                               AND sked__Job__r.sked__Type__c IN :criteria.jobTypes
                                                               AND sked__Resource__r.sked__Primary_Region__c IN :criteria.regionIds
                                                               AND sked__Resource__r.Employment_Type__c IN :criteria.employmentTypes
                                                               AND sked__Status__c != :skedConstants.JOB_ALLOCATION_STATUS_DELETED
                                                               AND sked__Status__c != :skedConstants.JOB_ALLOCATION_STATUS_DECLINED];
        
        List<sked__Activity__c> skedActivitiesInTime = [SELECT Id, sked__Resource__c, sked__Resource__r.Supervisor__c
                                                        FROM sked__Activity__c
                                                        WHERE sked__Start__c < :criteria.endTime
                                                        AND sked__End__c > :criteria.startTime
                                                        AND sked__Type__c IN :criteria.activityTypes
                                                        AND sked__Resource__r.sked__Primary_Region__c IN :criteria.regionIds
                                                        AND sked__Resource__r.Employment_Type__c IN :criteria.employmentTypes];
        
        List<sked__Availability__c> skedAvailabilitiesInTime = [SELECT Id, sked__Resource__c, sked__Resource__r.Supervisor__c
                                                                FROM sked__Availability__c
                                                                WHERE sked__Start__c < :criteria.endTime
                                                                AND sked__Finish__c > :criteria.startTime
                                                                AND sked__Type__c IN :criteria.availabilityTypes
                                                                AND sked__Resource__r.sked__Primary_Region__c IN :criteria.regionIds
                                                                AND sked__Resource__r.Employment_Type__c IN :criteria.employmentTypes];
        
        Set<Id> resourceIds = new Set<Id>();
        Set<string> supervisorIds = new Set<string>();
        if (criteria.supervisorIds != NULL && !criteria.supervisorIds.isEmpty()) {
            supervisorIds.addAll(criteria.supervisorIds);
        }
        for (sked__Job_Allocation__c skedAllocation : skedAllocationsInTime) {
            if (!supervisorIds.isEmpty() && !supervisorIds.contains(skedAllocation.sked__Resource__r.Supervisor__c))  {
                continue;
            }
            resourceIds.add(skedAllocation.sked__Resource__c);
        }
        for (sked__Activity__c skedActivity : skedActivitiesInTime) {
            if (!supervisorIds.isEmpty() && !supervisorIds.contains(skedActivity.sked__Resource__r.Supervisor__c))  {
                continue;
            }
            resourceIds.add(skedActivity.sked__Resource__c);
        }
        for (sked__Availability__c skedAvailability : skedAvailabilitiesInTime) {
            if (!supervisorIds.isEmpty() && !supervisorIds.contains(skedAvailability.sked__Resource__r.Supervisor__c))  {
                continue;
            }
            resourceIds.add(skedAvailability.sked__Resource__c);
        }
        return resourceIds;
    }
    
    private static Set<Id> getSupervisorIds() {
        AggregateResult[] groupedResults = [SELECT Supervisor__c FROM sked__Resource__c WHERE Supervisor__c != NULL GROUP BY Supervisor__c];
        Set<Id> supervisorIds = new Set<Id>();
        for (AggregateResult ar : groupedResults) {
            string supervisorId = string.valueOf(ar.get('Supervisor__c'));
            supervisorIds.add(Id.valueOf(supervisorId));
        }
        return supervisorIds;
    }
    
    private static List<skedModels.selectOption> getSupervisorOptions() {
        List<skedModels.selectOption> result = new List<skedModels.selectOption>();
        
        Set<Id> supervisorIds = getSupervisorIds();
        
        List<User> supervisors = [SELECT Id, Name FROM User WHERE Id IN :supervisorIds ORDER BY Name ASC];
        for (User supervisor : supervisors) {
            result.add(new skedModels.selectOption(string.valueOf(supervisor.Id), supervisor.Name));
        }
        
        return result;
    }
    
    /**************************************************************** Nested clases ***********************************************************************/
    global class configDataModel {
        public List<skedModels.selectOption> activityTypeOptions {get;set;}
        public List<skedModels.selectOption> availabilityTypeOptions {get;set;}
        public List<skedModels.selectOption> employmentTypeOptions {get;set;}
        public List<skedModels.selectOption> jobTypeOptions {get;set;}
        public List<skedModels.selectOption> jobStatusOptions {get;set;}
        public List<skedModels.selectOption> regionOptions {get;set;}
        public List<skedModels.selectOption> supervisorOptions {get;set;}
    }
    
    global class reportCriteria {
        public string startDateStr {get;set;}
        public string endDateStr {get;set;}
        public List<string> activityTypes {get;set;}
        public List<string> availabilityTypes {get;set;}
        public List<string> employmentTypes {get;set;}
        public List<string> jobTypes {get;set;}
        public List<string> jobStatuses {get;set;}
        public List<string> regionIds {get;set;}
        public List<string> supervisorIds {get;set;}
        public DateTime startTime {get;set;}
        public DateTime endTime {get;set;}
    }
    
    global class resourceModel {
        public string id {get;set;}
        public string name {get;set;}
        public string employmentType {get;set;}
        public string regionName {get;set;}
        public string supervisorName {get;set;}
        public string photoUrl {get;set;}
        public decimal totalDuration {get;set;}
        public string totalDurationText {get;set;}
        public decimal totalJobDuration {get;set;}
        public string totalJobDurationText {get;set;}
        public decimal totalActivityDuration {get;set;}
        public string totalActivityDurationText {get;set;}
        public decimal totalAvailabilityDuration {get;set;}
        public string totalAvailabilityDurationText {get;set;}
        public List<jobModel> jobs {get;set;}
        public List<activityModel> activities {get;set;}
        public List<availabilityModel> availabilities {get;set;}
    }
    
    global class jobModel {
        public string id {get;set;}
        public string name {get;set;}
        public string description {get;set;}
        public string accountName {get;set;}
        public string dateStr {get;set;}
        public string startTimeStr {get;set;}
        public string endTimeStr {get;set;}
        public string jobLocation {get;set;}
        public string jobType {get;set;}
        public string status {get;set;}
        
        public jobModel(sked__Job_Allocation__c skedAllocation) {
            this.id = skedAllocation.sked__Job__c;
            this.name = skedAllocation.sked__Job__r.Name;
            this.description = skedAllocation.sked__Job__r.sked__Description__c;
            this.accountName = skedAllocation.sked__Job__r.sked__Account__r.Name;
            this.dateStr = skedAllocation.sked__Job__r.sked__Start__c.format(skedDateTimeUtils.DATE_FORMAT);
            this.startTimeStr = skedAllocation.sked__Job__r.sked__Start__c.format('h:mma');
            this.endTimeStr = skedAllocation.sked__Job__r.sked__Finish__c.format('h:mma');
            this.jobLocation = skedAllocation.sked__Job__r.sked__Address__c;
            this.jobType = skedAllocation.sked__Job__r.sked__Type__c;
            this.status = skedAllocation.sked__Job__r.sked__Job_Status__c;
        }
    }
    
    global class activityModel {
        public string id {get;set;}
        public string name {get;set;}
        public string dateStr {get;set;}
        public string startTimeStr {get;set;}
        public string endTimeStr {get;set;}
        public string activityType {get;set;}
        
        public activityModel(sked__Activity__c skedActivity) {
            this.id = skedActivity.Id;
            this.name = skedActivity.Name;
            this.dateStr = skedActivity.sked__Start__c.format(skedDateTimeUtils.DATE_FORMAT);
            this.startTimeStr = skedActivity.sked__Start__c.format('h:mma');
            this.endTimeStr = skedActivity.sked__End__c.format('h:mma');
            this.activityType = skedActivity.sked__Type__c;
        }
    }
    
    global class availabilityModel {
        public string id {get;set;}
        public string name {get;set;}
        public string dateStr {get;set;}
        public string startTimeStr {get;set;}
        public string endTimeStr {get;set;}
        public string availabilityType {get;set;}
        public boolean isAvailable {get;set;}
        public string status {get;set;}
        
        public availabilityModel(sked__Availability__c skedAvailability) {
            this.id = skedAvailability.Id;
            this.name = skedAvailability.Name;
            this.dateStr = skedAvailability.sked__Start__c.format(skedDateTimeUtils.DATE_FORMAT);
            this.startTimeStr = skedAvailability.sked__Start__c.format('h:mma');
            this.endTimeStr = skedAvailability.sked__Finish__c.format('h:mma');
            this.availabilityType = skedAvailability.sked__Type__c;
            this.isAvailable = skedAvailability.sked__Is_Available__c;
            this.status = skedAvailability.sked__Status__c;
        }
    }
    
}