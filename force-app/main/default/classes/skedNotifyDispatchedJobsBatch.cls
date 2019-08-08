global class skedNotifyDispatchedJobsBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
    protected list<sked__Job_Allocation__c> allocationsToDispatch;
    
    global skedNotifyDispatchedJobsBatch(List<sked__Job_Allocation__c> inputAllocations) {
        allocationsToDispatch = inputAllocations;
    }
    
    global List<sObject> start(Database.BatchableContext BC) {        
        return allocationsToDispatch;
    }
    
    global void execute(Database.BatchableContext BC, List<sked__Job_Allocation__c> scope) {
        Set<Id> allocationIds = new Set<Id>();
        
        for (sked__Job_Allocation__c allocation : scope) {
            allocationIds.add(allocation.Id);
        }
        if (!allocationIds.isEmpty()) {
            skedSkeduloApiManager.dispatchJobAllocations(allocationIds);
        }        
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }   
    
}