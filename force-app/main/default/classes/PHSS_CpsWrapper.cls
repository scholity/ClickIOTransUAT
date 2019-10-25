public class PHSS_CpsWrapper {
    @AuraEnabled
    public String offeringId {get;set;}
	@AuraEnabled
    public String accName {get;set;}
    @AuraEnabled
    public String courseName {get;set;}
    @AuraEnabled
    public String accId {get;set;}
    @AuraEnabled
    public String ccProductId {get;set;}
    @AuraEnabled
    public String courseId {get;set;}    
    @AuraEnabled
    public String oppId {get;set;}
    @AuraEnabled
    public String locationId {get;set;}
    @AuraEnabled
    public String classFormat {get;set;}
    @AuraEnabled
    public String classDuration {get;set;}
    @AuraEnabled
    public String quantity {get;set;}
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
    public String geoLat {get;set;}
    @AuraEnabled
    public String geoLng {get;set;}
    @AuraEnabled
    public String regType {get;set;}
    @AuraEnabled
    public Decimal regFee {get;set;}
    @AuraEnabled
    public String regUrl {get;set;}
    @AuraEnabled
    public String regPhone {get;set;}
    @AuraEnabled
    public OfferingInformation accountInformation {get;set;}
	
    public PHSS_CpsWrapper() {
        this.offeringId = '0';
        this.courseName = '';
        this.classFormat = '';
        this.locationId = '';
        this.siteName = '';
        this.address1 = '';
        this.address2 = '';
        this.city = '';
        this.state = '';
        this.zip = '';
        this.geoLat = '';
        this.geoLng = '';
        this.regType = '';
        this.quantity = '1';
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
    
    public class OfferingInformation {
        @AuraEnabled
        public sObject selectedAccount {get;set;}
        @AuraEnabled
        public sObject selectedFacility {get;set;}
   		
        public OfferingInformation() {
            this.selectedAccount 	= null;
            this.selectedFacility 	= null;
        }
    }
}