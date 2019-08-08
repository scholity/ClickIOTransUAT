public class skedJobAllocationHandler {

    public static void beforeInsert(List<sked__Job_Allocation__c> newRecords) {
        populateData(newRecords);
    }
    
    public static void afterInsert(List<sked__Job_Allocation__c> newRecords) {
        updateWeeklyScheduledHours(newRecords);
        captureEventsOnInsert(newRecords);
    }
    
    public static void afterUpdate(List<sked__Job_Allocation__c> newRecords, Map<Id, sked__Job_Allocation__c> updatedRecords) {
        updateWeeklyScheduledHours(newRecords, updatedRecords);
        captureEventsOnUpdate(newRecords, updatedRecords);
        sendJobNotification(newRecords, updatedRecords);
        handleDispatchAllocations(newRecords, updatedRecords);
    }
    
    public static void beforeDelete(List<sked__Job_Allocation__c> oldRecords) {
        captureEventsOnDelete(oldRecords);
    }

    private static void handleDispatchAllocations(List<sked__Job_Allocation__c> newRecords, Map<Id, sked__Job_Allocation__c> updatedRecords) {
        List<sked__Job_Allocation__c> allocationsToDispatch = new List<sked__Job_Allocation__c>();
        for (sked__Job_Allocation__c allocation : newRecords) {
            sked__Job_Allocation__c oldData = updatedRecords.get(allocation.Id);
            if (allocation.sked__Status__c != oldData.sked__Status__c && allocation.sked__Status__c == skedConstants.JOB_ALLOCATION_STATUS_DISPATCHED) {
                allocationsToDispatch.add(allocation);
            }
        }
        if (!allocationsToDispatch.isEmpty()) {
            skedNotifyDispatchedJobsBatch batch = new skedNotifyDispatchedJobsBatch(allocationsToDispatch);
            Database.executeBatch(batch, 20);
        }
    }

    private static void populateData(List<sked__Job_Allocation__c> newRecords) {
        Set<Id> resourceIds = new Set<Id>();
        for (sked__Job_Allocation__c newRecord : newRecords) {
            if (newRecord.Number_of_Resources__c == NULL) {
                newRecord.Number_of_Resources__c = 1;
            }
            resourceIds.add(newRecord.sked__Resource__c);
        }
        Map<Id, sked__Resource__c> mapResource = new Map<Id, sked__Resource__c>([SELECT Id, Employment_Type__c
                                                                                 FROM sked__Resource__c
                                                                                 WHERE Id IN :resourceIds]);
        for (sked__Job_Allocation__c newRecord : newRecords) {
            sked__Resource__c skedResource = mapResource.get(newRecord.sked__Resource__c);
            newRecord.Is_Subcontractor__c = skedResource.Employment_Type__c == skedConstants.RESOURCE_EMPLOYMENT_TYPE_SUBCONTRACTOR;
        }
    }

    private static void captureEventsOnInsert(List<sked__Job_Allocation__c> newRecords) {
        Map<Id, sked__Job_Allocation__c> mapAllocation = new Map<Id, sked__Job_Allocation__c>(newRecords);
        skedEventFactory.captureJobAllocationEvents(mapAllocation.keySet());
    }

    private static void captureEventsOnUpdate(List<sked__Job_Allocation__c> newRecords, Map<Id, sked__Job_Allocation__c> oldRecords) {
        Set<Id> allocationIdsToSyncDelete = new Set<Id>();
        for (sked__Job_Allocation__c skedAllocation : newRecords) {
            sked__Job_Allocation__c oldData = oldRecords.get(skedAllocation.Id);
            if (skedAllocation.sked__Status__c == skedConstants.JOB_ALLOCATION_STATUS_DELETED && oldData.sked__Status__c != skedAllocation.sked__Status__c) {
                allocationIdsToSyncDelete.add(skedAllocation.Id);
            }
        }
        if (!allocationIdsToSyncDelete.isEmpty()) {
            skedEventFactory.removeJobAllocationEvents(allocationIdsToSyncDelete);
        }
    }
    
    private static void captureEventsOnDelete(List<sked__Job_Allocation__c> oldRecords) {
        Map<Id, sked__Job_Allocation__c> mapAllocation = new Map<Id, sked__Job_Allocation__c>(oldRecords);
        skedEventFactory.removeJobAllocationEvents(mapAllocation.keySet());
    }
    
    private static void updateWeeklyScheduledHours(List<sked__Job_Allocation__c> newRecords) {
        Set<Id> resourceIds = new Set<Id>();
        for (sked__Job_Allocation__c newRecord : newRecords) {
            resourceIds.add(newRecord.sked__Resource__c);
        }
        skedUtils.updateResourceScheduledHours(resourceIds);
    }
    
    private static void updateWeeklyScheduledHours(List<sked__Job_Allocation__c> newRecords, Map<Id, sked__Job_Allocation__c> updatedRecords) {
        Set<Id> resourceIds = new Set<Id>();
        for (sked__Job_Allocation__c newRecord : newRecords) {
            sked__Job_Allocation__c oldData = updatedRecords.get(newRecord.Id);
            if (oldData.sked__Status__c != skedConstants.JOB_ALLOCATION_STATUS_DELETED && newRecord.sked__Status__c == skedConstants.JOB_ALLOCATION_STATUS_DELETED) {
                resourceIds.add(newRecord.sked__Resource__c);
            }
        }
        if (!resourceIds.isEmpty()) {
            skedUtils.updateResourceScheduledHours(resourceIds);
        }
    }
    
    private static void sendJobNotification(List<sked__Job_Allocation__c> newRecords, Map<Id, sked__Job_Allocation__c> updatedRecords) {
        Set<Id> jobAllocationIds = new Set<Id>();
        Set<Id> jobIds = new Set<Id>();
        
        Set<string> activeStatusList = new Set<string>();
        activeStatusList.add(skedConstants.JOB_ALLOCATION_STATUS_CONFIRMED);
        activeStatusList.add(skedConstants.JOB_ALLOCATION_STATUS_IN_PROGRESS);
        activeStatusList.add(skedConstants.JOB_ALLOCATION_STATUS_EN_ROUTE);
        activeStatusList.add(skedConstants.JOB_ALLOCATION_STATUS_CHECKED_IN);
        
        for (sked__Job_Allocation__c newRecord : newRecords) {
            sked__Job_Allocation__c oldData = updatedRecords.get(newRecord.Id);
            if (oldData.sked__Status__c != newRecord.sked__Status__c) {
                if (newRecord.sked__Status__c == skedConstants.JOB_ALLOCATION_STATUS_DELETED && activeStatusList.contains(oldData.sked__Status__c)) {
                    jobAllocationIds.add(newRecord.Id);
                    jobIds.add(newRecord.sked__Job__c);
                }
            }
        }
        
        if (!jobAllocationIds.isEmpty()) {
            Map<Id, sked__Job_Allocation__c> mapNewData = new Map<Id, sked__Job_Allocation__c>(newRecords);
            Map<Id, sked__Job__c> mapJob 
                = new Map<Id, sked__Job__c>([SELECT Id, Name, sked__Start__c, sked__Finish__c, sked__Type__c,
                                             sked__Address__c, sked__Timezone__c, sked__Job_Status__c
                                             FROM sked__Job__c
                                             WHERE Id IN :jobIds]);
            Set<Id> allocationIdsToNotify = new Set<Id>();
            Map<Id, Set<Id>> map_resourceId_allocationIds = new Map<Id, Set<Id>>();
            for (Id jobAllocationId : jobAllocationIds) {
                sked__Job_Allocation__c newData = mapNewData.get(jobAllocationId);
                sked__Job__c relatedJob = mapJob.get(newData.sked__Job__c);
                if (relatedJob.sked__Job_Status__c == skedConstants.JOB_STATUS_CANCELLED) {
                    allocationIdsToNotify.add(jobAllocationId);
                    continue;
                }
                
                Set<Id> allocationIds;
                if (map_resourceId_allocationIds.containsKey(newData.sked__Resource__c)) {
                    allocationIds = map_resourceId_allocationIds.get(newData.sked__Resource__c);
                }
                else {
                    allocationIds = new Set<Id>();
                    map_resourceId_allocationIds.put(newData.sked__Resource__c, allocationIds);
                }
                allocationIds.add(jobAllocationId);
            }
            
            Map<Id, sked__Resource__c> mapResource 
                = new Map<Id, sked__Resource__c>([SELECT Id, Name, sked__User__c, sked__Email__c
                                                  FROM sked__Resource__c
                                                  WHERE Id IN :map_resourceId_allocationIds.keySet()
                                                  AND sked__User__c != NULL
                                                  AND sked__Email__c != NULL]);
            
            string fromAddress = skedEmailUtils.getSchedulingEmail();
            Id orgWideEmailId;
            List<OrgWideEmailAddress> orgEmailResult = [SELECT Id, Address 
                                                        FROM OrgWideEmailAddress
                                                        WHERE Address =: fromAddress];
            if (orgEmailResult != NULL && orgEmailResult.size() > 0) {
                OrgWideEmailAddress fromAddressEmail = orgEmailResult.get(0);
                orgWideEmailId = fromAddressEmail.Id;
            }
            
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
            string jobInfoTemplate = '{{jobName}} - {{jobType}} - {{jobAddress}} - {{jobDate}} - {{jobStartTime}} - {{jobFinishTime}}';
            
            string bodyHtmlTemplate = '<p>Hi {{resourceName}},</p>';
            bodyHtmlTemplate += '<p>The following class information has been modified.</p>';
            
            for (Id resourceId : map_resourceId_allocationIds.keySet()) {
                if (!mapResource.containsKey(resourceId)) {
                    continue;
                }
                Set<Id> allocationIds = map_resourceId_allocationIds.get(resourceId);
                sked__Resource__c skedResource = mapResource.get(resourceId);
                
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                List<string> toRecipients = new List<string>();
                toRecipients.add(skedResource.sked__Email__c);
                email.setToAddresses(toRecipients);
                email.setTargetObjectId(skedResource.sked__User__c);
                if (skedEmailUtils.useSchedulingEmail == true) {
                    email.setorgWideEmailAddressId(orgWideEmailId);
                }
                email.setSaveAsActivity(false);
                email.setSubject('Assignment Change - Please Review.');
                
                string bodyHtml = bodyHtmlTemplate.replace('{{resourceName}}', skedResource.Name);
                
                for (Id allocationId : allocationIds) {
                    sked__Job_Allocation__c newData = mapNewData.get(allocationId);
                    sked__Job__c relatedJob = mapJob.get(newData.sked__Job__c);
                    
                    string originalAllocationStatus, changedToAllocationStatus;
                    changedToAllocationStatus = 'Changed to UNASSIGNED';
                    
                    string originalInfo = jobInfoTemplate;
                    originalInfo = originalInfo.replace('{{jobName}}', relatedJob.Name);
                    originalInfo = originalInfo.replace('{{jobType}}', relatedJob.sked__Type__c);
                    originalInfo = originalInfo.replace('{{jobAddress}}', relatedJob.sked__Address__c);
                    originalInfo = originalInfo.replace('{{jobDate}}', relatedJob.sked__Start__c.format(skedDateTimeUtils.DATE_FORMAT, relatedJob.sked__Timezone__c));
                    originalInfo = originalInfo.replace('{{jobStartTime}}', relatedJob.sked__Start__c.format('h:mm a', relatedJob.sked__Timezone__c));
                    originalInfo = originalInfo.replace('{{jobFinishTime}}', relatedJob.sked__Finish__c.format('h:mm a', relatedJob.sked__Timezone__c));
                    string originalData = 'Original - ' + originalInfo;
                    
                    string changeToData = changedToAllocationStatus;
                    
                    bodyHtml += '<p>';
                    bodyHtml += '<span>' + originalData + '</span>' +'<br />';
                    bodyHtml += '<span>' + changeToData + '</span>';
                    bodyHtml += '</p>';
                }
                bodyHtml += '<p>Please review and contact your Supervisor for any questions.</p>';
                email.setHtmlBody(bodyHtml);
                
                emailList.add(email);
            }
            
            if (emailList.size() > 0) {
                Messaging.sendEmail(emailList);
            }
            
            if (!allocationIdsToNotify.isEmpty()) {
                skedEmailUtils.sendJobNotification(jobAllocationIds);
            }
        }
    }
    
}