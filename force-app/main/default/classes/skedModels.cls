global class skedModels {

    public virtual class courseTemplate {
        public string id {get;set;}
        public string name {get;set;}
        public string courseCatalogId {get;set;}
        public string courseClassDays {get;set;}
        public decimal maxHoursPerDay {get;set;}
        public boolean isDefaultTemplate {get;set;}
        public List<courseClassType> courseClassTypes {get;set;}

        public courseTemplate(Course_Template__c skedCourseTemplate) {
            this.id = skedCourseTemplate.Id;
            this.name = skedCourseTemplate.Name;
            this.courseCatalogId = skedCourseTemplate.Course_Catalog__c;
            this.courseClassDays = skedCourseTemplate.Course_Class_Days__c;
            this.maxHoursPerDay = skedCourseTemplate.Maximum_Hours_Per_Day__c;
            this.isDefaultTemplate = skedCourseTemplate.Default_Template__c;

            this.courseClassTypes = new List<courseClassType>();
            for (Course_Class_Type__c skedCourseClassType : skedCourseTemplate.Course_Class_Types__r) {
                courseClassType classType = new courseClassType(skedCourseClassType);
                this.courseClassTypes.add(classType);
            }
        }
    }

    global virtual class courseClassType implements Comparable {
        public string id {get;set;}
        public string name {get;set;}
        public integer displayOrder {get;set;}
        public decimal totalHours {get;set;}
        public integer startTime {get;set;}
        public integer endTime {get;set;}
        public string facilityId {get;set;}
        public integer ratioToInstructor {get;set;}
        public boolean canBeSameDay {get;set;}

        //to be removed
        public integer numberOfInstructors {get;set;}

        public courseClassType(Course_Class_Type__c skedCourseClassType) {
            this.id = skedCourseClassType.Id;
            this.name = skedCourseClassType.Class_Type__c;
            this.displayOrder = integer.valueOf(skedCourseClassType.Display_Order__c);
            this.totalHours = skedCourseClassType.Total_Hours__c;
            this.startTime = integer.valueOf(skedCourseClassType.Start_Time__c);
            this.endTime = integer.valueOf(skedCourseClassType.End_Time__c);
            this.facilityId = skedCourseClassType.Location__c;
            this.ratioToInstructor = integer.valueOf(skedCourseClassType.Ratio_to_Instructor__c);
            this.canBeSameDay = false;
        }

        global Integer compareTo(Object compareTo) {
            courseClassType compareToRecord = (courseClassType)compareTo;
            if (displayOrder < compareToRecord.displayOrder) {
                return -1;
            } 
            else {
                return 1;
            }
        }
    }

    public virtual class facility {
        public string id {get;set;}
        public string name {get;set;}
        public string regionId {get;set;}
        public string address {get;set;}
        public decimal lat {get;set;}
        public decimal lng {get;set;}
        public string facilityID {get;set;}
        public string notes {get;set;}

        public facility(sked__Location__c skedLocation) {
            this.id = skedLocation.Id;
            this.name = skedLocation.Name;
            this.regionId = skedLocation.sked__Region__c;
            this.address = skedLocation.sked__Address__c;
            this.lat = skedLocation.sked__GeoLocation__Latitude__s;
            this.lng = skedLocation.sked__GeoLocation__Longitude__s;
            this.facilityID = skedLocation.Facility_ID__c;
            this.notes = skedLocation.Notes__c;
        }
    }
    
    public virtual class courseCatalog {
        public string id {get;set;}
        public string name {get;set;}
        public integer numberOfStudents {get;set;}
        public integer numberOfInstructors {get;set;}
        public integer classDuration {get;set;}
        public integer numberOfClasses {get;set;}
        public integer breakDuration {get;set;}
        public integer numberOfBreaks {get;set;}
        public List<selectOption> neededSkills {get;set;}
        public string ratioToInstructor {get;set;}
        public boolean isActive {get;set;}
        public string masterClassName {get;set;}
        public List<subclassSetting> subclassSettings {get;set;}
        
        public courseCatalog(Course_Catalog__c skedCourseCatalog) {
            this.id = skedCourseCatalog.Id;
            this.name = skedCourseCatalog.Name;
            if (skedCourseCatalog.Number_of_Students__c != NULL) {
                this.numberOfStudents = integer.valueOf(skedCourseCatalog.Number_of_Students__c);
            }
            if (skedCourseCatalog.Number_of_Instructors__c != NULL) {
                this.numberOfInstructors = integer.valueOf(skedCourseCatalog.Number_of_Instructors__c);
            }
            if (skedCourseCatalog.Class_Duration__c != NULL) {
                this.classDuration = integer.valueOf(skedCourseCatalog.Class_Duration__c);
            }
            if (skedCourseCatalog.Number_of_Classes__c != NULL) {
                this.numberOfClasses = integer.valueOf(skedCourseCatalog.Number_of_Classes__c);
            }
            if (skedCourseCatalog.Break_Duration__c != NULL) {
                this.breakDuration = integer.valueOf(skedCourseCatalog.Break_Duration__c);
            }
            if (skedCourseCatalog.Number_of_Breaks__c != NULL) {
                this.numberOfBreaks = integer.valueOf(skedCourseCatalog.Number_of_Breaks__c);
            }
            if (skedCourseCatalog.Course_Catalog_Tags__r != NULL && !skedCourseCatalog.Course_Catalog_Tags__r.isEmpty()) {
                this.neededSkills = new List<selectOption>();
                for (Course_Catalog_Tag__c courseCatalogTag : skedCourseCatalog.Course_Catalog_Tags__r) {
                    selectOption neededSkill = new selectOption(courseCatalogTag.Tag__c, courseCatalogTag.Tag__r.Name);
                    this.neededSkills.add(neededSkill);
                }
            }
            this.isActive = skedCourseCatalog.Is_Active__c;
            this.ratioToInstructor = skedCourseCatalog.Ratio_to_Instructor__c;
            this.masterClassName = skedCourseCatalog.Master_Class_Name__c;
            if (skedCourseCatalog.Sub_Class_Settings__r != NULL && !skedCourseCatalog.Sub_Class_Settings__r.isEmpty()) {
                this.subclassSettings = new List<subclassSetting>();
                for (Sub_Class_Setting__c skedSubClassSetting : skedCourseCatalog.Sub_Class_Settings__r) {
                    subclassSetting setting = new subclassSetting(skedSubClassSetting);
                    this.subclassSettings.add(setting);
                }
            }
        }
    }
    
    public virtual class subclassSetting {
        public string courseCatalogId {get;set;}
        public string courseCode {get;set;}
        public integer displayOrder {get;set;}
        public integer duration {get;set;}
        
        public subclassSetting(Sub_Class_Setting__c skedSubClassSetting) {
            this.courseCatalogId = skedSubClassSetting.Course_Catalog__c;
            this.courseCode = skedSubClassSetting.Course_Code__c;
            if (skedSubClassSetting.Display_Order__c != NULL) {
                this.displayOrder = integer.valueOf(skedSubClassSetting.Display_Order__c);
            }
            if (skedSubClassSetting.Duration__c != NULL) {
                this.duration = integer.valueOf(skedSubClassSetting.Duration__c);
            }
        }
    }

    public virtual class offering {
        public string id {get;set;}
        public string name {get;set;}

        public offering(){}

        public offering(Offering__c skedOffering) {
            this.id = skedOffering.Id;
            this.name = skedOffering.Name;
        }
    }
    
    public virtual class job extends skedBaseModels.job {
        public string facilityId {get;set;}
        public string courseCatalogId {get;set;}
        public string courseCatalogName {get;set;}
        public integer numberOfBreaks {get;set;}
        public integer breakDuration {get;set;}
        public List<job> followups {get;set;}
        public List<jobAllocation> allocations {get;set;}
        public List<offering> offerings {get;set;}
        public string specialInstructions {get;set;}
        public integer beforeClassDuration {get;set;}
        public integer afterClassDuration {get;set;}
        public integer numberOfRemainingResources {get;set;}

        public integer noOfQualifiedResources {get;set;}
        public integer noOfAvailableResources {get;set;}

        public job() {}
        
        public job(sked__Job__c skedJob) {
            super(skedJob);
            this.numberOfRemainingResources = integer.valueOf(skedJob.Remaining_Resources_to_be_Allocated__c);
            this.allocations = new List<jobAllocation>();
            this.followups = new List<job>();
            this.offerings = new List<offering>();
        }
    }
    
    public virtual class availability extends skedBaseModels.availability {
        public availability(sked__Availability__c skedAvailability) {
            super(skedAvailability);
        }
    }
    
    public virtual class activity extends skedBaseModels.activity {
        public activity(sked__Activity__c skedActivity) {
            super(skedActivity);
        }
    }
    
    public virtual class jobAllocation extends skedBaseModels.jobAllocation {
        public skedBaseModels.geometry startFromLocation {get;set;}
        public decimal distance {get;set;}
        public integer travelTimeFrom {get;set;}
        public integer noOfAvailableClasses {get;set;}
        
        public boolean isQualified {get;set;}
        public boolean isAvailable {get;set;}
        public string conflictDetails {get;set;}

        public string jobName {get;set;}
        public string resourceName {get;set;}
        public integer numberOfResources {get;set;}

        public string action {get;set;}
        
        public transient job job {get;set;}
        public resource resource {get;set;}

        public transient skedBaseModels.event previousEvent {get;set;}
        public transient skedBaseModels.event nextEvent {get;set;}
        
        public jobAllocation() {
            this.isQualified = true;
            this.isAvailable = true;
        }
        
        public jobAllocation(sked__Job_Allocation__c skedAllocation) {
            super(skedAllocation);
            this.isQualified = true;
            this.isAvailable = true;
        }
    }
    
    global virtual class resource extends skedBaseModels.resource implements Comparable {
        public string employmentType {get;set;}
        public integer noOfAvailableClasses {get;set;}
        public jobAllocation firstJobAllocation {get;set;}
        public double assignedMinutes {get;set;}
        public double weeklyMinutes {get;set;}
        public boolean isAppliedGoogle {get;set;}

        public resource() {
            this.isAppliedGoogle = false;
        }

        public resource(sked__Resource__c skedResource) {
         	super(skedResource);
            this.employmentType = skedResource.Employment_Type__c;
            this.noOfAvailableClasses = 0;
            this.isAppliedGoogle = false;
        }

        global Integer compareTo(Object compareTo) {
            resource compareToRecord = (resource)compareTo;
            if (noOfAvailableClasses > compareToRecord.noOfAvailableClasses) {
                return -1;
            } 
            else if (noOfAvailableClasses < compareToRecord.noOfAvailableClasses) {
                return 1;
            }
            else {
                if (firstJobAllocation != NULL && compareToRecord.firstJobAllocation != NULL) {
                    if (firstJobAllocation.travelTimeFrom < compareToRecord.firstJobAllocation.travelTimeFrom) {
                        return -1;
                    }
                    else {
                        return 1;
                    }
                }
                else {
                    if (firstJobAllocation == NULL) {
                        return 1;
                    }
                    else {
                        return -1;
                    }
                }
            }
        }
    }

    public virtual class selectOption {
        public string id {get;set;}
        public string label {get;set;}
        public boolean selected {get;set;}
        
        public selectOption(string value, string text) {
            this.id = value;
            this.label = text;
            this.selected = false;
        }
        
        public selectOption(string value, string text, boolean selected) {
            this.id = value;
            this.label = text;
            this.selected = selected;
        }
    }

    public virtual class jobStatusSetting {
        public string jobStatus {get;set;}
        public string backgroundColor {get;set;}
        public string textColor {get;set;}
    }

    public virtual class permissionModel {
        public boolean canClone {get;set;}
        public boolean canCreate {get;set;}
        public boolean canEdit {get;set;}
        public boolean canDelete {get;set;}
        public boolean canCancel {get;set;}

        public permissionModel() {
            this.canClone = false;
            this.canCreate = false;
            this.canEdit = false;
            this.canDelete = false;
            this.canCancel = false;
        }
    }

    public virtual class natClassSetting {
        public integer durationToHaveBreak {get;set;}
        public integer durationToHave2ndClass {get;set;}
        public integer breakTime {get;set;}
        public List<natClassTypeSetting> classTypeSettings {get;set;}
    }

    public virtual class natClassTypeSetting {
        public string classType {get;set;}
        public string backgroundColor {get;set;}
        public string textColor {get;set;}
    }
}