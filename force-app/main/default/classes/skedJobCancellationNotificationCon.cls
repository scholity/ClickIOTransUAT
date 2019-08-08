public class skedJobCancellationNotificationCon {
    
    public string resourceName {get;set;}
    public string jobName {get;set;}
    public string jobLocation {get;set;}
    public string jobStartDate {get;set;}
    public string jobStartTime {get;set;}
    public string jobDescription {get;set;}
    
    private string jobAllocationId;
    
    public string getJobAllocationId() {
        return this.jobAllocationId;
    }
    
    public void setJobAllocationId(string inputJobAllocationId) {
        if (!String.isEmpty(inputJobAllocationId)) {
            loadData(inputJobAllocationId);
        }
    }
    
    private void loadData(string inputJobAllocationId) {
        sked__Job_Allocation__c skedAlloc = [SELECT Id, sked__Resource__r.Name, sked__Job__r.Name, sked__Job__r.sked__Type__c,
                                             sked__Job__r.sked__Address__c, sked__Job__r.sked__Location__r.Name,
                                             sked__Job__r.sked__Start__c, sked__Job__r.sked__Description__c, sked__Job__r.sked__Timezone__c
                                             FROM sked__Job_Allocation__c
                                             WHERE Id = :inputJobAllocationId];
        this.resourceName = skedAlloc.sked__Resource__r.Name;
        this.jobName = skedAlloc.sked__Job__r.Name;
        this.jobLocation = skedAlloc.sked__Job__r.sked__Address__c;
        this.jobDescription = skedAlloc.sked__Job__r.sked__Description__c;
        this.jobStartDate = skedAlloc.sked__Job__r.sked__Start__c.format(skedDateTimeUtils.DATE_FORMAT, skedAlloc.sked__Job__r.sked__Timezone__c);
        this.jobStartTime = skedAlloc.sked__Job__r.sked__Start__c.format('h:mm a', skedAlloc.sked__Job__r.sked__Timezone__c);
    }
}