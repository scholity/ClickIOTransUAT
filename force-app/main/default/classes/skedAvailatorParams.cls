global class skedAvailatorParams {
    
    public string timezoneSidId {get;set;}
    public Set<Id> regionIds {get;set;}
    public Set<Id> resourceIds {get;set;}
    public Set<Id> excludedJobIds {get;set;}
    public Set<string> allocationKeys {get;set;}
    public List<skedModels.job> inputJobs {get;set;}
    public boolean useGoogleService {get;set;}
    public boolean onlyKeepQualifiedResources {get;set;}
    
    public skedAvailatorParams() {
        this.timezoneSidId = UserInfo.getTimeZone().getID();
        this.regionIds = new Set<Id>();
        this.resourceIds = new Set<Id>();
        this.excludedJobIds = new Set<Id>();
        this.allocationKeys = new Set<string>();
        this.inputJobs = new List<skedModels.job>();
        this.useGoogleService = false;
        this.onlyKeepQualifiedResources = false;
    }

}