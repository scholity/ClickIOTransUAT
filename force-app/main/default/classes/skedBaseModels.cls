global class skedBaseModels {
    
    public virtual class event implements Comparable {
    	public string eventType {get;set;}
        public string id {get;set;}
        public string name {get;set;}
        public string timezoneSidId {get;set;}
        public integer startTime {get;set;}
        public integer finishTime {get;set;}
        public string startDate {get;set;}
        public string endDate {get;set;}
        public string startTimeStr {get;set;}
        public string endTimeStr {get;set;}
        public geometry geometry {get;set;}
        
        public transient DateTime start {get;set;}
        public transient DateTime finish {get;set;}
        public transient Location geoLocation {get;set;}
        
        public Integer compareTo(Object compareTo) {
            event compareToRecord = (event)compareTo;
            Integer returnValue = 0;
            
            if (start > compareToRecord.start) {
                returnValue = 1;
            } else if (start < compareToRecord.start) {
                returnValue = -1;
            }
            return returnValue;   
        }
    }
    
    public virtual class job extends event {
        public string address {get;set;}
        public string contactId {get;set;}
        public integer duration {get;set;}
        public boolean isRecurring {get;set;}
        public string jobDate {get;set;}
        public string jobStatus {get;set;}
        public string jobType {get;set;}
        public decimal lat {get;set;}
        public decimal lng {get;set;}
        public string regionId {get;set;}
        public string parentId {get;set;}
        public string scheduleId {get;set;}
        public List<tag> tags {get;set;}
        
        public job() {}
        
        public job(sked__Job__c skedJob) {
            this.eventType = 'job';
            this.id = skedJob.Id;
            this.name = skedJob.Name;
            this.address = skedJob.sked__Address__c;
            this.lat = skedJob.sked__GeoLocation__Latitude__s;
            this.lng = skedJob.sked__GeoLocation__Longitude__s;
            this.jobType = skedJob.sked__Type__c;
            this.jobStatus = skedJob.sked__Job_Status__c;
            this.duration = integer.valueOf(skedJob.sked__Duration__c);
            this.contactId = skedJob.sked__Contact__c;
            this.scheduleId = skedJob.sked__Recurring_Schedule__c;
            this.isRecurring = !string.isBlank(this.scheduleId);
            this.regionId = skedJob.sked__Region__c;
            
            this.timezoneSidId = skedJob.sked__Timezone__c;
            this.start = skedJob.sked__Start__c;
            this.finish = skedJob.sked__Finish__c;
            this.startTime = integer.valueOf(this.start.format('Hmm', this.timezoneSidId));
            this.finishTime = integer.valueOf(this.finish.format('Hmm', this.timezoneSidId));
            this.jobDate = this.start.format(skedDateTimeUtils.DATE_ISO_FORMAT, this.timezoneSidId);
            this.startTimeStr = this.start.format('h:mma', this.timezoneSidId);
            this.endTimeStr = this.finish.format('h:mma', this.timezoneSidId);
            this.geoLocation = skedJob.sked__GeoLocation__c;
        }
        
        public void loadJobTags(List<sked__Job_Tag__c> jobTags) {
            this.tags = new List<tag>();
            for (sked__Job_Tag__c jobTag : jobTags) {
                tag tagItem = new tag();
                tagItem.id = jobTag.sked__Tag__c;
                tagItem.name = jobTag.sked__Tag__r.Name;
                tagItem.relatedId = jobTag.sked__Job__c;
                this.tags.add(tagItem);
            }
        }
    }
    
    public virtual class availability extends event {
        public availability(sked__Availability__c skedAvailability) {
            this.eventType = 'availability';
            this.id = skedAvailability.Id;
            this.name = skedAvailability.Name;
            this.timezoneSidId = skedAvailability.sked__Timezone__c;
            this.start = skedAvailability.sked__Start__c;
            this.finish = skedAvailability.sked__Finish__c;
            this.startTime = integer.valueOf(this.start.format('Hmm', this.timezoneSidId));
            this.finishTime = integer.valueOf(this.finish.format('Hmm', this.timezoneSidId));
            this.startTimeStr = this.start.format('h:mma', this.timezoneSidId);
            this.endTimeStr = this.finish.format('h:mma', this.timezoneSidId);
        }
    }
    
    public virtual class activity extends event {
        public activity(sked__Activity__c skedActivity) {
            this.eventType = 'activity';
            this.id = skedActivity.Id;
            this.name = skedActivity.Name;
            this.timezoneSidId = skedActivity.sked__Timezone__c;
            this.start = skedActivity.sked__Start__c;
            this.finish = skedActivity.sked__End__c;
            this.startTime = integer.valueOf(this.start.format('Hmm', this.timezoneSidId));
            this.finishTime = integer.valueOf(this.finish.format('Hmm', this.timezoneSidId));
            this.startTimeStr = this.start.format('h:mma', this.timezoneSidId);
            this.endTimeStr = this.finish.format('h:mma', this.timezoneSidId);
            this.geoLocation = skedActivity.sked__GeoLocation__c;
        }
    }
    
    public virtual class jobAllocation extends event {
        public string jobId {get;set;}
        public string resourceId {get;set;}
        public string status {get;set;}
        
        public jobAllocation() {}
        
        public jobAllocation(sked__Job_Allocation__c skedAllocation) {
            this.eventType = 'jobAllocation';
            this.id = skedAllocation.Id;
            this.name = skedAllocation.Name;
            this.jobId = skedAllocation.sked__Job__c;
            this.resourceId = skedAllocation.sked__Resource__c;
            
            this.timezoneSidId = skedAllocation.sked__Job__r.sked__Timezone__c;
            this.start = skedAllocation.sked__Job__r.sked__Start__c;
            this.finish = skedAllocation.sked__Job__r.sked__Finish__c;
            this.startTime = integer.valueOf(this.start.format('Hmm', this.timezoneSidId));
            this.finishTime = integer.valueOf(this.finish.format('Hmm', this.timezoneSidId));
            this.startTimeStr = this.start.format('h:mma', this.timezoneSidId);
            this.endTimeStr = this.finish.format('h:mma', this.timezoneSidId);
            this.geoLocation = skedAllocation.sked__Job__r.sked__GeoLocation__c;
        }
    }
    
    public virtual class resource {
        public string id {get;set;}
        public string name {get;set;}
        public string category {get;set;}
        public string photoUrl {get;set;}
        public string regionId {get;set;}
        public string regionName {get;set;}
        public string userId {get;set;}
        public string timezoneSidId {get;set;}
        public integer rating {get;set;}
        public string address {get;set;}
        public decimal lat {get;set;}
        public decimal lng {get;set;}
        public List<tag> tags {get;set;}
        
        public transient Location geoLocation {get;set;}

        public resource() {}
        
        public resource(sked__Resource__c skedResource) {
            this.id = skedResource.Id;
            this.name = skedResource.Name;
            this.category = skedResource.sked__Category__c;
            this.regionId = skedResource.sked__Primary_Region__c;
            this.regionName = skedResource.sked__Primary_Region__r.Name;
            this.timezoneSidId = skedResource.sked__Primary_Region__r.sked__Timezone__c;
            if (skedResource.sked__User__c != NULL) {
                this.userId = skedResource.sked__User__c;
                this.photoUrl = skedResource.sked__User__r.SmallPhotoUrl;
            }
            if (skedResource.sked__Rating__c != NULL) {
                this.rating = integer.valueOf(skedResource.sked__Rating__c);
            }
            this.geoLocation = skedResource.sked__GeoLocation__c;
            this.address = skedResource.sked__Home_Address__c;
            this.lat = skedResource.sked__GeoLocation__Latitude__s;
            this.lng = skedResource.sked__GeoLocation__Longitude__s;
        }

        public void loadResourceTags(List<sked__Resource_Tag__c> resourceTags) {
            this.tags = new List<tag>();
            for (sked__Resource_Tag__c resourceTag : resourceTags) {
                tag tagItem = new tag();
                tagItem.id = resourceTag.sked__Tag__c;
                tagItem.name = resourceTag.sked__Tag__r.Name;
                tagItem.relatedId = resourceTag.sked__Resource__c;
                tagItem.expiryTime = resourceTag.sked__Expiry_Date__c;
                this.tags.add(tagItem);
            }
        }
    }
    
    public virtual class tag {
        public string id {get;set;}
        public string name {get;set;}
        public string relatedId {get;set;}
        public transient DateTime expiryTime {get;set;}
    }
    
    public virtual class geometry {
        public string address {get;set;}
        public decimal lat {get;set;}
        public decimal lng {get;set;}

        public geometry(){}
        
        public geometry(string address, decimal lat, decimal lng) {
            this.address = address;
            this.lat = lat;
            this.lng = lng;
        }
        
        public geometry(Location geoLocation) {
            this.lat = geoLocation.getLatitude();
            this.lng = geoLocation.getLongitude();
        }
    }
    
    public virtual class journeyModel {
        public geometry originGeometry {get;set;}
        public geometry destinationGeometry {get;set;}
        public integer travelTime {get;set;}
        public decimal distance {get;set;}
    }
    
}