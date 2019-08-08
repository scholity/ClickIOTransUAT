public class PHSS_CpsWrapper {
	@AuraEnabled
    public String accName {get;set;}
    @AuraEnabled
    public String courseName {get;set;}
    @AuraEnabled
    public String accId {get;set;}
    @AuraEnabled
    public String courseId {get;set;}
    @AuraEnabled
    public String classFormat {get;set;}
    @AuraEnabled
    public List<String> classFormatList {get;set;}
    @AuraEnabled
    public List<SessionWrapper> sessionList {get;set;}
    @AuraEnabled
    public Map<String,String> timeZoneList {get;set;}
    @AuraEnabled
    public String siteName {get;set;}
    @AuraEnabled
    public String address1 {get;set;}
    @AuraEnabled
    public String address2 {get;set;}
    @AuraEnabled
    public String city {get;set;}
    @AuraEnabled
    public String state {get;set;}
    @AuraEnabled
    public String zip {get;set;}
    @AuraEnabled
    public String regType {get;set;}
    @AuraEnabled
    public Decimal regFee {get;set;}
    @AuraEnabled
    public String regUrl {get;set;}
    @AuraEnabled
    public String regPhone {get;set;}
	
    public PHSS_CpsWrapper() {
        this.courseName = '';
        this.courseName = '';
        this.classFormat = '';
        this.siteName = '';
        this.address1 = '';
        this.address2 = '';
        this.city = '';
        this.state = '';
        this.zip = '';
        this.regType = '';
    }    
    
    public class SessionWrapper {
        @AuraEnabled
        public String classDate {get;set;}
        @AuraEnabled
        public String startTime {get;set;}
        @AuraEnabled
        public String endTime {get;set;}
        @AuraEnabled
        public String timeZone {get;set;}
   		
        public SessionWrapper() {
            this.classDate = '';
            this.startTime = '';
            this.endTime = '';
            this.timeZone = '';
        }
    }
}