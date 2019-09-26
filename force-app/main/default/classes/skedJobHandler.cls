public class skedJobHandler {

    public static void beforeInsert(List<sked__Job__c> newRecords) {
        supportImportDate(newRecords);
        populateJobData(newRecords);
    }
    
    public static void beforeUpdate(List<sked__Job__c> newRecords, Map<Id, sked__Job__c> updatedRecords) {
        logConfirmedDateTime(updatedRecords, newRecords);
        populateJobData(updatedRecords, newRecords);
    }
    
    public static void beforeDelete(Map<Id, sked__Job__c> oldMap) {
        deleteSubClasses(oldMap);
    }

    public static void afterInsert(List<sked__Job__c> newRecords) {
        updateGeoLocation(newRecords);
    }
    
    public static void afterUpdate(List<sked__Job__c> newRecords, Map<Id, sked__Job__c> updatedRecords) {
        updateGeoLocation(updatedRecords, newRecords);
        updateResourceScheduledHours(updatedRecords, newRecords);
        captureEventsOnUpdate(updatedRecords, newRecords);
        updateSubClassDetails(updatedRecords, newRecords);
        notifyJobUpdates(updatedRecords, newRecords);
    }
    
    /******************************************* Private methods ******************************************/
    private static void captureEventsOnUpdate(Map<Id, sked__Job__c> updatedRecords, List<sked__Job__c> newRecords) {
        Set<Id> jobIdsToCaptureUpdate = new Set<Id>();
        Set<Id> jobIdsToCaptureDelete = new Set<Id>();
        for (sked__Job__c job : newRecords) {
            sked__Job__c oldData = updatedRecords.get(job.Id);
            if (job.sked__Job_Status__c != oldData.sked__Job_Status__c && job.sked__Job_Status__c == skedConstants.JOB_STATUS_CANCELLED) {
                jobIdsToCaptureDelete.add(job.Id);
            }
            else if (job.sked__Start__c != oldData.sked__Start__c || job.sked__Finish__c != oldData.sked__Finish__c || job.sked__Address__c != oldData.sked__Address__c || job.sked__Description__c != oldData.sked__Description__c) {
                jobIdsToCaptureUpdate.add(job.Id);
            }
        }
        if (!jobIdsToCaptureUpdate.isEmpty()) {
            skedEventFactory.captureJobEvents(jobIdsToCaptureUpdate);
        }
        if (!jobIdsToCaptureDelete.isEmpty()) {
            skedEventFactory.removeJobEvents(jobIdsToCaptureDelete);
        }
    }
    
    private static void populateJobData(List<sked__Job__c> newRecords) {
        Set<Id> locationIds = new Set<Id>();
        Set<Id> courseCatalogIds = new Set<Id>();
        for (sked__Job__c newRecord : newRecords) {
            if (newRecord.Job_Month__c == NULL) {
                newRecord.Job_Month__c = newRecord.sked__Start__c.date().toStartOfMonth();
            }
            if (newRecord.sked__Location__c != NULL) {
                locationIds.add(newRecord.sked__Location__c);
            }
            if (newRecord.Course_Catalog__c != NULL) {
                courseCatalogIds.add(newRecord.Course_Catalog__c);
            }
            newRecord.Job_Time__c = newRecord.sked__Start__c.format('hh:mma', newRecord.sked__Timezone__c) 
                                    + ' - ' + newRecord.sked__Finish__c.format('h:mma z', newRecord.sked__Timezone__c);
        }
        if (!locationIds.isEmpty()) {
            Map<Id, sked__Location__c> mapLocation = new Map<Id, sked__Location__c>([SELECT Id, Notes__c
                                                                                     FROM sked__Location__c
                                                                                     WHERE Id IN :locationIds]);
            for (sked__Job__c newRecord : newRecords) {
                if (newRecord.sked__Location__c != NULL) {
                    sked__Location__c skedLocation = mapLocation.get(newRecord.sked__Location__c);
                    newRecord.Location_Notes__c = skedLocation.Notes__c;
                }
            }
        }
        
        Map<Id, Course_Catalog__c> mapCourseCatalog;
        if (!courseCatalogIds.isEmpty()) {
            mapCourseCatalog = new Map<Id, Course_Catalog__c>([SELECT Id, Name
                                                               FROM Course_Catalog__c
                                                               WHERE Id IN :courseCatalogIds]);
        }
        for (sked__Job__c newRecord : newRecords) {
            newRecord.sked__Description__c = '';
            if (mapCourseCatalog != NULL && newRecord.Course_Catalog__c != NULL) {
                Course_Catalog__c courseCatalog = mapCourseCatalog.get(newRecord.Course_Catalog__c);
                newRecord.sked__Description__c = courseCatalog.Name + ', ';
            }
            string startTimeStr = newRecord.sked__Start__c.format('hh:mma z', newRecord.sked__Timezone__c);
            newRecord.sked__Description__c += startTimeStr;
        }
    }

    private static void populateJobData(Map<Id, sked__Job__c> updatedRecords, List<sked__Job__c> newRecords) {
        Set<Id> locationIds = new Set<Id>();
        Set<Id> courseCatalogIds = new Set<Id>();
        boolean repopulateJobInfo = false;
        for (sked__Job__c newRecord : newRecords) {
            sked__Job__c oldData = updatedRecords.get(newRecord.Id);
            if (newRecord.sked__Location__c != NULL && newRecord.sked__Location__c != oldData.sked__Location__c) {
                locationIds.add(newRecord.sked__Location__c);
            }
            if (newRecord.sked__Start__c != oldData.sked__Start__c || newRecord.sked__Finish__c != oldData.sked__Finish__c) {
                newRecord.Job_Time__c = newRecord.sked__Start__c.format('hh:mma', newRecord.sked__Timezone__c) 
                                        + ' - ' + newRecord.sked__Finish__c.format('h:mma z', newRecord.sked__Timezone__c);
            }
            if (repopulateJobInfo == FALSE) {
                repopulateJobInfo = newRecord.sked__Start__c != oldData.sked__Start__c 
                    || newRecord.sked__Finish__c != oldData.sked__Finish__c 
                    || newRecord.Course_Catalog__c != oldData.Course_Catalog__c;
            }
            if (newRecord.Course_Catalog__c != NULL) {
                courseCatalogIds.add(newRecord.Course_Catalog__c);
            }
        }
        if (!locationIds.isEmpty()) {
            Map<Id, sked__Location__c> mapLocation = new Map<Id, sked__Location__c>([SELECT Id, Notes__c
                                                                                     FROM sked__Location__c
                                                                                     WHERE Id IN :locationIds]);
            for (sked__Job__c newRecord : newRecords) {
                sked__Job__c oldData = updatedRecords.get(newRecord.Id);
                if (newRecord.sked__Location__c != NULL && newRecord.sked__Location__c != oldData.sked__Location__c) {
                    sked__Location__c skedLocation = mapLocation.get(newRecord.sked__Location__c);
                    newRecord.Location_Notes__c = skedLocation.Notes__c;
                }
            }
        }
        
        if (repopulateJobInfo == TRUE) {
            Map<Id, Course_Catalog__c> mapCourseCatalog;
            if (!courseCatalogIds.isEmpty()) {
                mapCourseCatalog = new Map<Id, Course_Catalog__c>([SELECT Id, Name
                                                                   FROM Course_Catalog__c
                                                                   WHERE Id IN :courseCatalogIds]);
            }
            for (sked__Job__c newRecord : newRecords) {
                newRecord.sked__Description__c = '';
                if (mapCourseCatalog != NULL && newRecord.Course_Catalog__c != NULL) {
                    Course_Catalog__c courseCatalog = mapCourseCatalog.get(newRecord.Course_Catalog__c);
                    newRecord.sked__Description__c = courseCatalog.Name + ', ';
                }
                string startTimeStr = newRecord.sked__Start__c.format('hh:mma z', newRecord.sked__Timezone__c);
                newRecord.sked__Description__c += startTimeStr;
            }
        }
    }
    
    private static void updateGeoLocation(List<sked__Job__c> newRecords) {
        string recordIds = '';
        list<string> resIds = new list<string>();
        for (sked__Job__c job : newRecords) {
            if (!job.From_Migration__c && job.sked__GeoLocation__Latitude__s == NULL) {
                recordIds += job.Id + ';';
                resIds.add(job.id);
            }
        }
        if (resIds.size() > 1) {
            if (!Test.isRunningTest()) {
                skedFillResourceGeoLocationBatch b = new skedFillResourceGeoLocationBatch(resIds, 'job');
                Database.executeBatch(b, 10);
            }
        }
        else if (resIds.size() == 1) {
            recordIds = recordIds.substring(0, recordIds.length() - 1);
            skedLocationService.updateGeoLocation(recordIds, 'job');
        }
    }
    
    private static void updateGeoLocation(Map<Id, sked__Job__c> updatedRecords, List<sked__Job__c> newRecords) {
        string recordIds = '';
        list<string> resIds = new list<string>();
        for (sked__Job__c job : newRecords) {
            sked__Job__c oldData = updatedRecords.get(job.Id);
            if (job.sked__Address__c != oldData.sked__Address__c && 
                    (job.sked__GeoLocation__Latitude__s == NULL || job.sked__GeoLocation__Latitude__s == oldData.sked__GeoLocation__Latitude__s)) {
                recordIds += job.Id + ';';
                resIds.add(job.id);
            }
        }
        if (resIds.size() > 1) {
            if (!Test.isRunningTest()) {
                skedFillResourceGeoLocationBatch b = new skedFillResourceGeoLocationBatch(resIds, 'job');
                Database.executeBatch(b, 10);
            }
        }
        else if (resIds.size() == 1) {
            recordIds = recordIds.substring(0, recordIds.length() - 1);
            skedLocationService.updateGeoLocation(recordIds, 'job');
        }
    }

    private static void supportImportDate(list<sked__Job__c> newRecords){
        map<string,sked__Location__c> mapNameLocation = new map<string,sked__Location__c>();
        map<string,Course_Catalog__c> mapNameCourse = new map<string,Course_Catalog__c>();
        set<string> setLocationName = new set<string>();
        set<string> setCourseName = new set<string>();
        for(sked__Job__c job : newRecords){
            if(string.isNotBlank(job.Temp_Location__c)){setLocationName.add(job.Temp_Location__c);}
            if(string.isNotBlank(job.Temp_Course__c)){setCourseName.add(job.Temp_Course__c);}
        }
        if(setLocationName.size()==0 || setCourseName.size()==0) return;
        for(sked__Location__c loc : [select id, sked__Region__c,sked__Region__r.sked__Timezone__c, sked__Address__c, sked__GeoLocation__Latitude__s, sked__GeoLocation__Longitude__s,Name from sked__Location__c where Name in:setLocationName]){
            mapNameLocation.put(loc.Name,loc);
        }
        for(Course_Catalog__c cc : [select id, Name from Course_Catalog__c where Name in:setCourseName]){
            mapNameCourse.put(cc.Name,cc);
        }
        for(sked__Job__c job : newRecords){
            if(!mapNameLocation.containsKey(job.Temp_Location__c) || !mapNameCourse.containsKey(job.Temp_Course__c))
            {
                job.addError('There is no Location or Course existing for this Job');
            }else{
                sked__Location__c loc = mapNameLocation.get(job.Temp_Location__c);
                Course_Catalog__c cou = mapNameCourse.get(job.Temp_Course__c);
                job.sked__Region__c = loc.sked__Region__c;
                job.sked__Address__c = loc.sked__Address__c;
                job.sked__GeoLocation__Latitude__s = loc.sked__GeoLocation__Latitude__s;
                job.sked__GeoLocation__Longitude__s = loc.sked__GeoLocation__Longitude__s;
                job.sked__Location__c = loc.id;
                job.Course_Catalog__c = cou.id;
                Datetime sDT = convertStringDT(job.Start_Date__c,job.Start_Time__c);
                Datetime fDT = convertStringDT(job.End_Date__c,job.End_Time__c);
                job.sked__Start__c = skedDateTimeUtils.toTimezone(sDT, loc.sked__Region__r.sked__Timezone__c);
                job.sked__Finish__c = skedDateTimeUtils.toTimezone(fDT, loc.sked__Region__r.sked__Timezone__c);
                long lDuration = fdt.getTime() - sdt.getTime();
                job.sked__Duration__c = (double)(lDuration/1000/60);
                job.From_Migration__c = true;
            }
        }
    }

    private static DateTime convertStringDT(string sdate,string stime){
        list<string> tempTime = stime.split(':');
        Datetime DT =  Datetime.newInstance(Date.parse(sdate), Time.newInstance(Integer.valueOf(tempTime.get(0)), Integer.valueOf(tempTime.get(1)), 0, 0));
        return DT;
    }

    private static void logConfirmedDateTime(Map<Id, sked__Job__c> updatedRecords, List<sked__Job__c> newRecords) {
        for (sked__Job__c job : newRecords) {
            sked__Job__c oldData = updatedRecords.get(job.Id);
            if (oldData.Confirmed__c == FALSE && job.Confirmed__c == TRUE) {
                job.Confirmed_Time_Stamp__c = system.now();
            }
        }
    }
    
    private static void updateResourceScheduledHours(Map<Id, sked__Job__c> updatedRecords, List<sked__Job__c> newRecords) {
        Set<Id> jobIds = new Set<Id>();
        for (sked__Job__c newRecord : newRecords) {
            sked__Job__c oldData = updatedRecords.get(newRecord.Id);
            if (newRecord.sked__Start__c != oldData.sked__Start__c || newRecord.sked__Finish__c != oldData.sked__Finish__c) {
                jobIds.add(newRecord.Id);
            }
        }
        if (!jobIds.isEmpty()) {
            List<sked__Job_Allocation__c> skedAllocs = [SELECT Id, sked__Resource__c
                                                        FROM sked__Job_Allocation__c
                                                        WHERE sked__Job__c IN :jobIds];
            Set<Id> resourceIds = new Set<Id>();
            for (sked__Job_Allocation__c skedAlloc : skedAllocs) {
                resourceIds.add(skedAlloc.sked__Resource__c);
            }
            skedUtils.updateResourceScheduledHours(resourceIds);
        }
    }

    private static void notifyJobUpdates(Map<Id, sked__Job__c> updatedRecords, List<sked__Job__c> newRecords) {
        Set<string> activeStatusList = new Set<string>();
        activeStatusList.add(skedConstants.JOB_STATUS_READY);
        activeStatusList.add(skedConstants.JOB_STATUS_IN_PROGRESS);
        activeStatusList.add(skedConstants.JOB_STATUS_EN_ROUTE);
        activeStatusList.add(skedConstants.JOB_STATUS_ON_SITE);

        Map<Id, sked__Job__c> mapJobToNotify = new Map<Id, sked__Job__c>();
        Set<string> fieldsToTrackChange = new Set<string>();
        fieldsToTrackChange.add('sked__Start__c');
        fieldsToTrackChange.add('sked__Finish__c');
        fieldsToTrackChange.add('sked__Location__c');
        fieldsToTrackChange.add('sked__Address__c');

        Map<Id, List<string>> map_job_changedFields = new Map<Id, List<string>>();

        for (sked__Job__c newRecord : newRecords) {
            if (newRecord.sked__Job_Allocation_Count__c > 0 && activeStatusList.contains(newRecord.sked__Job_Status__c)) {
                sked__Job__c oldData = updatedRecords.get(newRecord.Id);
                List<string> changedFields = new List<string>();
                for (string field : fieldsToTrackChange) {
                    if (newRecord.get(field) != oldData.get(field)) {
                        mapJobToNotify.put(newRecord.Id, newRecord);
                        changedFields.add(field);
                    }
                }
                map_job_changedFields.put(newRecord.Id, changedFields);
            }
        }
        if (mapJobToNotify.isEmpty()) {
            return;
        }

        Map<Id, sked__Job__c> mapNewData = new Map<Id, sked__Job__c>(newRecords);
        List<sked__Job_Allocation__c> skedAllocs = [SELECT Id, sked__Job__c, sked__Resource__c
                                                    FROM sked__Job_Allocation__c
                                                    WHERE sked__Job__c IN :mapJobToNotify.keySet()
                                                    AND sked__Status__c != :skedConstants.JOB_ALLOCATION_STATUS_DELETED
                                                    AND sked__Resource__r.sked__User__c != NULL
                                                    AND sked__Resource__r.sked__Email__c != NULL];
        Map<Id, Set<Id>> map_resourceId_jobIds = new Map<Id, Set<Id>>();
        for (sked__Job_Allocation__c skedAlloc : skedAllocs) {
            Set<Id> jobIds;
            if (map_resourceId_jobIds.containsKey(skedAlloc.sked__Resource__c)) {
                jobIds = map_resourceId_jobIds.get(skedAlloc.sked__Resource__c);
            }
            else {
                jobIds = new Set<Id>();
                map_resourceId_jobIds.put(skedAlloc.sked__Resource__c, jobIds);
            }
            jobIds.add(skedAlloc.sked__Job__c);
        }

        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();

        Map<Id, sked__Resource__c> mapResource 
            = new Map<Id, sked__Resource__c>([SELECT Id, Name, sked__User__c, sked__Email__c
                                              FROM sked__Resource__c
                                              WHERE Id IN :map_resourceId_jobIds.keySet()]);
        
        string jobInfoTemplate = '{{jobName}} - {{jobType}} - {{jobAddress}} - {{jobDate}} - {{jobStartTime}} - {{jobFinishTime}} - ASSIGNED';
        string jobAddressChangedTemplate = 'Address changed to: {{jobAddress}}';
        string jobStartTimeChangedTemplate = 'Start time changed to: {{jobStartTime}}';
        string jobFinishTimeChangedTemplate = 'Finish time changed to: {{jobFinishTime}}';

        string bodyHtmlTemplate = '<p>Hi {{resourceName}},</p>';
        bodyHtmlTemplate += '<p>The following class information has been modified.</p>';

        for (Id resourceId : map_resourceId_jobIds.keySet()) {
            Set<Id> jobIds = map_resourceId_jobIds.get(resourceId);
            sked__Resource__c skedResource = mapResource.get(resourceId);

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            List<string> toRecipients = new List<string>();
            toRecipients.add(skedResource.sked__Email__c);
            email.setToAddresses(toRecipients);
            email.setTargetObjectId(skedResource.sked__User__c);
            email.setSaveAsActivity(false);
            email.setSubject('Assignment Change - Please Review.');

            string bodyHtml = bodyHtmlTemplate.replace('{{resourceName}}', skedResource.Name);

            for (Id jobId : jobIds) {
                sked__Job__c newData = mapNewData.get(jobId);
                sked__Job__c oldData = updatedRecords.get(jobId);

                string originalInfo = jobInfoTemplate;
                originalInfo = originalInfo.replace('{{jobName}}', oldData.Name);
                originalInfo = originalInfo.replace('{{jobType}}', oldData.sked__Type__c);
                originalInfo = originalInfo.replace('{{jobAddress}}', oldData.sked__Address__c);
                originalInfo = originalInfo.replace('{{jobDate}}', oldData.sked__Start__c.format(skedDateTimeUtils.DATE_FORMAT, oldData.sked__Timezone__c));
                originalInfo = originalInfo.replace('{{jobStartTime}}', oldData.sked__Start__c.format('h:mm a', oldData.sked__Timezone__c));
                originalInfo = originalInfo.replace('{{jobFinishTime}}', oldData.sked__Finish__c.format('h:mm a', oldData.sked__Timezone__c));
                string originalData = 'Original - ' + originalInfo;

                List<string> changedInfo = new List<string>();
                List<string> changedFields = map_job_changedFields.get(jobId);

                for (string changedField : changedFields) {
                    if (changedField == 'sked__Address__c') {
                        changedInfo.add(jobAddressChangedTemplate.replace('{{jobAddress}}', newData.sked__Address__c));
                    }
                    else if (changedField == 'sked__Start__c') {
                        changedInfo.add(jobStartTimeChangedTemplate.replace('{{jobStartTime}}', newData.sked__Start__c.format(skedDateTimeUtils.DATE_TIME_FORMAT, newData.sked__Timezone__c)));
                    }
                    else if (changedField == 'sked__Finish__c') {
                        changedInfo.add(jobFinishTimeChangedTemplate.replace('{{jobFinishTime}}', newData.sked__Finish__c.format(skedDateTimeUtils.DATE_TIME_FORMAT, newData.sked__Timezone__c)));
                    }
                }

                bodyHtml += '<p>';
                bodyHtml += '<span>' + originalData + '</span><br />';
                for (string changedInfoItem : changedInfo) {
                    bodyHtml += '<span>' + changedInfoItem + '</span><br />';
                }
                bodyHtml += '<br /><br />';
                bodyHtml += '</p>';
            }
            bodyHtml += '<p>Please review and contact your Supervisor for any questions.</p>';
            email.setHtmlBody(bodyHtml);

            emailList.add(email);
        }

        if (emailList.size() > 0) {
            Messaging.sendEmail(emailList);
        }
    }
    
    private static void updateSubClassDetails(Map<Id, sked__Job__c> updatedRecords, List<sked__Job__c> newRecords) {
        Map<Id, sked__Job__c> mapMasterClass = new Map<Id, sked__Job__c>();
        for (sked__Job__c newRecord : newRecords) {
            sked__Job__c oldData = updatedRecords.get(newRecord.Id);
            if (newRecord.Is_Master_Class__c == TRUE) {
                if (newRecord.sked__Start__c != oldData.sked__Start__c
                   || newRecord.sked__Finish__c != oldData.sked__Finish__c
                   || newRecord.sked__Location__c != oldData.sked__Location__c
                   || newRecord.sked__GeoLocation__Latitude__s != oldData.sked__GeoLocation__Latitude__s
                   || newRecord.sked__GeoLocation__Longitude__s != oldData.sked__GeoLocation__Longitude__s
                   || newRecord.sked__Address__c != oldData.sked__Address__c
                   || newRecord.sked__Job_Status__c != oldData.sked__Job_Status__c
                   || newRecord.Location_Confirmed__c != oldData.Location_Confirmed__c) {
                    mapMasterClass.put(newRecord.Id, newRecord);
                }
            }
        }
        if (!mapMasterClass.isEmpty()) {
            List<sked__Job__c> skedSubClasses = [SELECT Id, sked__Start__c, sked__Finish__c, sked__Job_Status__c, sked__Parent__c, sked__Timezone__c,
                                                 sked__Address__c, sked__Location__c, sked__GeoLocation__Latitude__s, sked__GeoLocation__Longitude__s,
                                                 Location_Confirmed__c
                                                 FROM sked__Job__c
                                                 WHERE sked__Parent__c IN :mapMasterClass.keySet()];
            if (!skedSubClasses.isEmpty()) {
                for (sked__Job__c skedSubClass : skedSubClasses) {
                    sked__Job__c skedMasterClass = mapMasterClass.get(skedSubClass.sked__Parent__c);
                    sked__Job__c oldMasterClass = updatedRecords.get(skedMasterClass.Id);
                    
                    integer startDifferentMinutes = integer.valueOf((skedMasterClass.sked__Start__c.getTime() - oldMasterClass.sked__Start__c.getTime()) / 60000);
                    integer finishDifferentMinutes = integer.valueOf((skedMasterClass.sked__Finish__c.getTime() - oldMasterClass.sked__Finish__c.getTime()) / 60000);
                    
                    skedSubClass.sked__Start__c = skedDateTimeUtils.addMinutes(skedSubClass.sked__Start__c, startDifferentMinutes, skedSubClass.sked__Timezone__c);
                    skedSubClass.sked__Finish__c = skedDateTimeUtils.addMinutes(skedSubClass.sked__Finish__c, finishDifferentMinutes, skedSubClass.sked__Timezone__c);
                    skedSubClass.sked__Duration__c = integer.valueOf((skedSubClass.sked__Finish__c.getTime() - skedSubClass.sked__Start__c.getTime()) / 60000);
                    
                    skedSubClass.sked__Address__c = skedMasterClass.sked__Address__c;
                    skedSubClass.sked__Location__c = skedMasterClass.sked__Location__c;
                    skedSubClass.sked__GeoLocation__Latitude__s = skedMasterClass.sked__GeoLocation__Latitude__s;
                    skedSubClass.sked__GeoLocation__Longitude__s = skedMasterClass.sked__GeoLocation__Longitude__s;
                    skedSubClass.sked__Job_Status__c = skedMasterClass.sked__Job_Status__c;
                    skedSubClass.Location_Confirmed__c = skedMasterClass.Location_Confirmed__c;
                }
                update skedSubClasses;
            }
        }
    }
    
    private static void deleteSubClasses(Map<Id, sked__Job__c> oldMap) {
        delete [SELECT Id FROM sked__Job__c WHERE sked__Parent__c IN :oldMap.keySet()];
    }

}