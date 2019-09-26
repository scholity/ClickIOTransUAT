public class skedUtils {
    
    public static void updateResourceScheduledHours(Set<Id> resourceIds) {
        Date currentWeekStartDate = system.today().addDays(1).toStartOfWeek().addDays(-1);
        DateTime currentWeekStartDt = DateTime.newInstance(currentWeekStartDate, time.newInstance(0, 0, 0, 0));
        DateTime currentWeekEndDt = skedDateTimeUtils.addDays(currentWeekStartDt, 7, UserInfo.getTimeZone().getID());
        
        List<sked__Resource__c> skedResources = [SELECT Id,
                                                 (SELECT Id, Weekly_Scheduled_Hours__c
                                                  FROM Resource_Extensions__r),
                                                 (SELECT Id, sked__Job__r.sked__Duration__c
                                                  FROM sked__Job_Allocations__r
                                                  WHERE sked__Job__r.sked__Start__c < :currentWeekEndDt
                                                  AND sked__Job__r.sked__Finish__c > :currentWeekStartDt
                                                  AND sked__Status__c != :skedConstants.JOB_ALLOCATION_STATUS_DELETED
                                                  AND sked__Status__c != :skedConstants.JOB_ALLOCATION_STATUS_DECLINED
                                                  AND sked__Job__r.sked__Job_Status__c != :skedConstants.JOB_STATUS_CANCELLED),
                                                 (SELECT Id, sked__Start__c, sked__End__c
                                                  FROM sked__Activities__r
                                                  WHERE sked__Start__c < :currentWeekEndDt
                                                  AND sked__End__c > :currentWeekStartDt)
                                                 FROM sked__Resource__c
                                                 WHERE Id IN :resourceIds];
        List<Resource_Extension__c> upsertList = new List<Resource_Extension__c>();
        for (sked__Resource__c skedResource : skedResources) {
            Resource_Extension__c extension;
            if (skedResource.Resource_Extensions__r != NULL && !skedResource.Resource_Extensions__r.isEmpty()) {
                extension = skedResource.Resource_Extensions__r.get(0);
            }
            else {
                extension = new Resource_Extension__c(
                    Resource__c = skedResource.Id
                );
            }
            upsertList.add(extension);

            extension.Weekly_Scheduled_Hours__c = 0;
            if (skedResource.sked__Job_Allocations__r != NULL) {
                decimal totalDuration = 0;
                for (sked__Job_Allocation__c skedAlloc : skedResource.sked__Job_Allocations__r) {
                    totalDuration += skedAlloc.sked__Job__r.sked__Duration__c;
                }
                for (sked__Activity__c skedActivity : skedResource.sked__Activities__r) {
                    decimal activityDuration = (skedActivity.sked__End__c.getTime() - skedActivity.sked__Start__c.getTime()) / 60000;
                    totalDuration += activityDuration;
                }
                extension.Weekly_Scheduled_Hours__c = (totalDuration / 60);
            }
        }
        if (!upsertList.isEmpty()) {
            upsert upsertList;
        }
    }

    public static void populateJobLocation(string locationId, sked__Job__c skedJob) {
        if (!string.isBlank(locationId)) {
            sked__Location__c skedLocation = [SELECT Id, sked__Address__c, sked__GeoLocation__Latitude__s, sked__GeoLocation__Longitude__s
                                              FROM sked__Location__c
                                              WHERE Id = :locationId];
            skedJob.sked__Location__c = skedLocation.Id;
            skedJob.sked__Address__c = skedLocation.sked__Address__c; 
            skedJob.sked__GeoLocation__Latitude__s = skedLocation.sked__GeoLocation__Latitude__s; 
            skedJob.sked__GeoLocation__Longitude__s = skedLocation.sked__GeoLocation__Longitude__s;                                
        }
    }

    public static List<skedModels.selectOption> getRegions() {
        return getRegions(null);
    }

    public static List<skedModels.facility> getLocations(List<string> locationTypes) {
        List<sked__Location__c> skedLocations = [SELECT Id, Name, Facility_ID__c, Notes__c,
                                                 sked__Region__c, sked__Address__c, 
                                                 sked__GeoLocation__Latitude__s, sked__GeoLocation__Longitude__s
                                                 FROM sked__Location__c 
                                                 WHERE sked__Type__c IN :locationTypes
                                                 AND Is_Active__c = TRUE
                                                 ORDER BY Name];
        List<skedModels.facility> result = new List<skedModels.facility>();
        for (sked__Location__c skedLocation : skedLocations) {
            skedModels.facility facility = new skedModels.facility(skedLocation);
            result.add(facility);
        }
        return result;
    }

    public static List<skedModels.selectOption> getRegions(string selectedRegionId) {
        List<sked__Region__c> skedRegions = [SELECT Id, Name FROM sked__Region__c ORDER BY Name];
        List<skedModels.selectOption> result = new List<skedModels.selectOption>();
        for (sked__Region__c skedRegion : skedRegions) {
            skedModels.selectOption option = new skedModels.selectOption(skedRegion.Id, skedRegion.Name);
            option.selected = skedRegion.Id == selectedRegionId;
            result.add(option);
        }
        return result;
    }

    public static List<skedModels.selectOption> getTags() {
        List<sked__Tag__c> skedTags = [SELECT Id, Name FROM sked__Tag__c ORDER BY Name];
        List<skedModels.selectOption> result = new List<skedModels.selectOption>();
        for (sked__Tag__c skedTag : skedTags) {
            skedModels.selectOption option = new skedModels.selectOption(skedTag.Id, skedTag.Name);
            result.add(option);
        }
        return result;
    }

    public static List<skedModels.jobStatusSetting> getJobStatusSettings() {
        List<skedModels.jobStatusSetting> result = new List<skedModels.jobStatusSetting>();

        skedModels.jobStatusSetting queuedSetting = new skedModels.jobStatusSetting();
        queuedSetting.jobStatus = skedConstants.JOB_STATUS_QUEUED;
        queuedSetting.backgroundColor = '#c9cacc';
        queuedSetting.textColor = '#fff';
        result.add(queuedSetting);

        skedModels.jobStatusSetting pendingAllocationSetting = new skedModels.jobStatusSetting();
        pendingAllocationSetting.jobStatus = skedConstants.JOB_STATUS_PENDING_ALLOCATION;
        pendingAllocationSetting.backgroundColor = '#787878';
        pendingAllocationSetting.textColor = '#fff';
        result.add(pendingAllocationSetting);

        skedModels.jobStatusSetting pendingDispatchSetting = new skedModels.jobStatusSetting();
        pendingDispatchSetting.jobStatus = skedConstants.JOB_STATUS_PENDING_DISPATCH;
        pendingDispatchSetting.backgroundColor = '#faa928';
        pendingDispatchSetting.textColor = '#fff';
        result.add(pendingDispatchSetting);

        skedModels.jobStatusSetting dispatchedSetting = new skedModels.jobStatusSetting();
        dispatchedSetting.jobStatus = skedConstants.JOB_STATUS_DISPATCHED;
        dispatchedSetting.backgroundColor = '#74b1d4';
        dispatchedSetting.textColor = '#fff';
        result.add(dispatchedSetting);

        skedModels.jobStatusSetting readySetting = new skedModels.jobStatusSetting();
        readySetting.jobStatus = skedConstants.JOB_STATUS_READY;
        readySetting.backgroundColor = '#286091';
        readySetting.textColor = '#fff';
        result.add(readySetting);

        skedModels.jobStatusSetting enRouteSetting = new skedModels.jobStatusSetting();
        enRouteSetting.jobStatus = skedConstants.JOB_STATUS_EN_ROUTE;
        enRouteSetting.backgroundColor = '#bc8ebe';
        enRouteSetting.textColor = '#fff';
        result.add(enRouteSetting);

        skedModels.jobStatusSetting onSiteSetting = new skedModels.jobStatusSetting();
        onSiteSetting.jobStatus = skedConstants.JOB_STATUS_ON_SITE;
        onSiteSetting.backgroundColor = '#944292';
        onSiteSetting.textColor = '#fff';
        result.add(onSiteSetting);

        skedModels.jobStatusSetting inProgressSetting = new skedModels.jobStatusSetting();
        inProgressSetting.jobStatus = skedConstants.JOB_STATUS_IN_PROGRESS;
        inProgressSetting.backgroundColor = '#620c5f';
        inProgressSetting.textColor = '#fff';
        result.add(inProgressSetting);

        skedModels.jobStatusSetting completeSetting = new skedModels.jobStatusSetting();
        completeSetting.jobStatus = skedConstants.JOB_STATUS_COMPLETE;
        completeSetting.backgroundColor = '#19cf5e';
        completeSetting.textColor = '#fff';
        result.add(completeSetting);

        skedModels.jobStatusSetting cancelledSetting = new skedModels.jobStatusSetting();
        cancelledSetting.jobStatus = skedConstants.JOB_STATUS_CANCELLED;
        cancelledSetting.backgroundColor = '#df4040';
        cancelledSetting.textColor = '#fff';
        result.add(cancelledSetting);

        return result;
    }

    public static Set<string> getInprogressStatuses() {
        Set<string> result = new Set<string>();
        result.add(skedConstants.JOB_STATUS_IN_PROGRESS);
        result.add(skedConstants.JOB_STATUS_EN_ROUTE);
        result.add(skedConstants.JOB_STATUS_ON_SITE);
        result.add(skedConstants.JOB_STATUS_COMPLETE);

        return result;
    }
    
    public static Map<Id, sked__Resource__c> getMapResources(string regionId, List<string> categories) {
        return getMapResources(regionId, categories, new List<string>());
    }

    public static Map<Id, sked__Resource__c> getMapResources(string regionId, List<string> categories, List<string> tagIds) {
        List<string> fields = new List<string>();
        fields.add('Id');
        fields.add('Employment_Type__c');
        fields.add('(SELECT sked__Tag__c, sked__Resource__c FROM sked__ResourceTags__r)');

        string subcontractorType = skedConstants.RESOURCE_EMPLOYMENT_TYPE_SUBCONTRACTOR;

        List<string> conditions = new List<string>();
        conditions.add('sked__Category__c IN :categories');
        conditions.add('Employment_Type__c != :subcontractorType');
        conditions.add('sked__Is_Active__c = TRUE');
        if (regionId != 'all') {
            conditions.add('sked__Primary_Region__c = :regionId');            
        }
        string queryString = 'SELECT ' + string.join(fields, ', ') +
                             ' FROM sked__Resource__c ' +
                             ' WHERE ' + string.join(conditions, ' AND ');
                             
        List<sked__Resource__c> skedResources = (List<sked__Resource__c>)Database.query(queryString);

        List<sked__Resource__c> matchedSkedResources = new List<sked__Resource__c>();
        if (tagIds != NULL && tagIds.size() > 0) {
            for (sked__Resource__c skedResource : skedResources) {
                Set<string> resourceTagIds = new Set<string>();
                for (sked__Resource_Tag__c resourceTag : skedResource.sked__ResourceTags__r) {
                    resourceTagIds.add(resourceTag.sked__Tag__c);
                }
                if (resourceTagIds.containsAll(tagIds)) {
                    matchedSkedResources.add(skedResource);
                }
            }
        }
        else {
            matchedSkedResources = skedResources;
        }

        Map<Id, sked__Resource__c> mapResult = new Map<Id, sked__Resource__c>(matchedSkedResources);
        return mapResult;
    }

    public static Set<Id> getResourceIdsByRadius(Set<Id> resourceIds, decimal radius, Location destination) {
        List<sked__Resource__c> resources = [SELECT Id, Name, sked__GeoLocation__c
                                             FROM sked__Resource__c
                                             WHERE Id IN :resourceIds
                                             AND sked__GeoLocation__Latitude__s != NULL];
        Set<Id> result = new Set<Id>();
        for (sked__Resource__c resource : resources) {
            decimal distance = destination.getDistance(resource.sked__GeoLocation__c, 'mi');
            if (distance <= radius) {
                result.add(resource.Id);
            }
        }
        return result;
    }
    
    public static List<skedModels.selectOption> getPickListValues(string objectApiName, string fieldApiName) {
        return getPickListValues(objectApiName, fieldApiName, new Set<string>());
    }
    
    public static List<skedModels.selectOption> getPickListValues(string objectApiName, string fieldApiName, Set<string> excludedValues) {
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

        List<skedModels.selectOption> result = new List<skedModels.selectOption>();
        for (string picklistValue : picklistValues) {
            if (!excludedValues.contains(picklistValue)) {
                result.add(new skedModels.selectOption(picklistValue, picklistValue));
            }
        }
        return result;
    }
    
    public static Map<Id, Account> getChildAccountsInHierarchy(Id accountId) {
        Account acc = [SELECT Id, HQ_Account__c FROM Account WHERE Id = :accountId];
        Id hqAccountId = acc.HQ_Account__c != NULL ? acc.HQ_Account__c : accountId;
        return new Map<Id, Account>([SELECT Id FROM Account WHERE Id = :hqAccountId OR HQ_Account__c = :hqAccountId]);
    }

}