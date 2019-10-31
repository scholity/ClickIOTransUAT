global class skedDeleteJobBatch implements Database.Batchable<sked__Job__c> {
    
    protected string[] jobIds;
    
    global skedDeleteJobBatch(string[] jobIds) {
        this.jobIds = jobIds;
    }
    
    global List<sked__Job__c> start(Database.BatchableContext BC) {        
        return [SELECT Id FROM sked__Job__c WHERE Id IN :jobIds];
    }
    
    global void execute(Database.BatchableContext BC, List<sked__Job__c> skedJobs) {
        delete skedJobs;
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
}