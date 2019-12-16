trigger BulkStudentUpdateTrigger on Student_Bulk_Upload__c (before insert, before update) 
{
    if (!PHSS_TriggerSettings__c.getOrgDefaults().StudentBulkUploadTriggerDisable__c) {
        if (Trigger.isBefore && Trigger.isInsert)
        {
            BulkStudentUpdateTriggerHandler.updateILTClassLoookup(Trigger.new);
        }
    
        if (Trigger.isBefore && Trigger.isUpdate)
        {
            BulkStudentUpdateTriggerHandler.enrollLearner(Trigger.new);
        }
    }
}