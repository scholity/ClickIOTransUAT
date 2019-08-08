public without sharing class RCILTViewerCmpCtrl {
    private static RCILTViewerCmpCtrl.WithoutSharingOps wosInstance;
    private static RCILTViewerCmpCtrl.WithoutSharingOps getWOSInstance(){
        if(wosInstance != null){
            return wosInstance;
        }
        wosInstance = new RCILTViewerCmpCtrl.WithoutSharingOps();
        return wosInstance;
    }

    @AuraEnabled
    public static ResultData getRecord(String itemId, String planId) {
        ResultData outputData = new ResultData();

        outputData.lang          = UserInfo.getLanguage().substring(0, 2);
        try {
            Id recId                = itemId;
            String recType          = recId.getSobjectType().getDescribe().getLocalName();
            Boolean isInstructor    = RCUtils.isInstructor((String)recId);

            if (recType == 'redwing__ILT_Class__c' && isInstructor) {
                redwing__ILT_Class__c iltClass                              = null;
                redwing__Training_Plan__c plan                              = null;

                iltClass            = getWOSInstance().getILTClassRecord(recId);
                outputData.record   = new ILTClassWrapper(iltClass, recId);
                plan                = getWOSInstance().getPlanWithAchievements(planId);
                outputData.record.setCourseData(plan);
            }
        } catch (Exception e) {
            outputData.status       = RCConstants.ANSWER_STATUS_ERROR;
            outputData.message      = e.getMessage();
        }

        return outputData;
    }

    public without sharing class ILTClassWrapper {
        @AuraEnabled public String id;
        @AuraEnabled public String offeringId;
        @AuraEnabled public String name;
        @AuraEnabled public String courseName;
        @AuraEnabled public String organization;
        @AuraEnabled public String classSetting;
        @AuraEnabled public String status;
        @AuraEnabled public String language;
        @AuraEnabled public String numberOfStudents;
        @AuraEnabled public String certificates;
        @AuraEnabled public String instructors;
        @AuraEnabled public Date startDate;
        @AuraEnabled public Date endDate;

        public ILTClassWrapper(redwing__ILT_Class__c rec, Id recId) {
            Set<String> fieldNames = rec.getPopulatedFieldsAsMap().keySet();

            if(fieldNames.contains('Id')) {
                this.id = rec.Id;
            }
            if(fieldNames.contains('Offering_Id__c')) {
                this.offeringId = rec.Offering_Id__c;
            }            
            if(fieldNames.contains('Name')) {
                this.name = rec.Name;
            }
            if(fieldNames.contains('redwing__Start_Date__c')) {
                this.startDate = rec.redwing__Start_Date__c;
            }
            if(fieldNames.contains('redwing__End_Date__c')) {
                this.endDate = rec.redwing__End_Date__c;
            }
            //if(fieldNames.contains(RCConstants.APINAME_FIELD_ORGANIZATION)) {
                this.organization = rec.Skedulo_Account__r.Name;
            //}
            if(fieldNames.contains('redwing__Start_Date__c') && fieldNames.contains('redwing__End_Date__c')) {
                DateTime targetTime = DateTime.now();
                DateTime startTime = DateTime.newInstance(
                        rec.redwing__Start_Date__c.year()
                        ,rec.redwing__Start_Date__c.month()
                        ,rec.redwing__Start_Date__c.day()
                        ,(fieldNames.contains('redwing__Start_Time__c') && rec.redwing__Start_Time__c != null) ? Integer.valueOf(rec.redwing__Start_Time__c.split(':')[0]) : 0
                        ,(fieldNames.contains('redwing__Start_Time__c') && rec.redwing__Start_Time__c != null) ? Integer.valueOf(rec.redwing__Start_Time__c.split(':')[1]) : 0
                        ,0
                );
                DateTime endTime = DateTime.newInstance(
                        rec.redwing__End_Date__c.year()
                        ,rec.redwing__End_Date__c.month()
                        ,rec.redwing__End_Date__c.day()
                        ,(fieldNames.contains('redwing__End_Time__c') && rec.redwing__End_Time__c != null) ? Integer.valueOf(rec.redwing__End_Time__c.split(':')[0]) : 0
                        ,(fieldNames.contains('redwing__End_Time__c') && rec.redwing__End_Time__c != null) ? Integer.valueOf(rec.redwing__End_Time__c.split(':')[1]) : 0
                        ,0
                );

                if (rec.redwing__Cancelled__c == true) {
                    this.status = RCConstants.STATUS_CANCELLED;
                } else if (endTime <= targetTime) {
                    this.status = RCConstants.STATUS_COMPLETED;
                } else if (targetTime > startTime && targetTime < endTime) {
                    this.status = RCConstants.STATUS_IN_PROGRESS;
                } else if (targetTime < startTime) {
                    this.status = RCConstants.STATUS_UPCOMING;
                }
            }
            
            if(fieldNames.contains('redwing__ILT_Rosters__r')) {
                this.numberOfStudents = String.valueOf(rec.redwing__ILT_Rosters__r.size());
            }
            // DE1079 - For Learn-To-Swim (and possibly others), display student counts from aggregate count fields if available and defined
            else if (fieldNames.contains('Successful_Evaluations__c') && fieldNames.contains('Unsuccessful_Evaluations__c') && 
            	fieldNames.contains('Not_Evaluated__c') && (rec.Successful_Evaluations__c + rec.Unsuccessful_Evaluations__c + rec.Not_Evaluated__c > 0)) {
            		this.numberOfStudents = 'Successful '+rec.Successful_Evaluations__c+', Unsuccessful '+rec.Unsuccessful_Evaluations__c +
            			', Not Evaluated '+rec.Not_Evaluated__c;
            	}
            	else {
            		// DE712 - CRE does not create roster records.  Need to calculate number of student from query on Achievement Assignment object            		
	            	Integer nStudents = database.Query('Select count(Id) From redwing__Achievement_Assignment__c Where ILT_Class__c = :recId Group By External_Id__c').size();
	            	this.numberOfStudents = (nStudents > 0) ? this.numberOfStudents = String.valueOf(nStudents) : 'N/A';
            	}

            if(fieldNames.contains('redwing__ILT_Instructors__r')) {
                Set<String> names = new Set<String>();

                for(redwing__ILT_Instructor__c inst: rec.redwing__ILT_Instructors__r) {
                    names.add(inst.redwing__Instructor__r.Name);
                }

                this.instructors = String.join(new List<String>(names), ', ');
            }
        }

        public void setCourseData(redwing__Training_Plan__c course) {
            if(course != null) {
                Set<String> fieldNameSet = course.getPopulatedFieldsAsMap().keySet();

                if(fieldNameSet.contains('Name')) {
                    this.courseName = course.Name;
                }
                if(fieldNameSet.contains(RCConstants.APINAME_FIELD_CLASSSETTINGS)) {
                    this.classSetting = String.valueOf(course.get(RCConstants.APINAME_FIELD_CLASSSETTINGS));
                }
                if(fieldNameSet.contains('redwing__Language__c')) {
                    this.language = course.redwing__Language__c;
                }
                if(fieldNameSet.contains('redwing__Training_Plan_Achievements__r')) {
                    List<String> achievementNames = new List<String>();

                    for(redwing__Training_Plan_Achievement__c tpa: course.redwing__Training_Plan_Achievements__r) {
                        achievementNames.add(tpa.redwing__Achievement__r.Name);
                    }

                    this.certificates = String.join(achievementNames, ', ');
                }
            }
        }
    }

    public without sharing class ResultData {
        @AuraEnabled public String status   = RCConstants.ANSWER_STATUS_SUCCESS;
        @AuraEnabled public String message  = '';
        @AuraEnabled public String  lang    = '';

        @AuraEnabled public ILTClassWrapper record;
    }

    private without sharing class WithoutSharingOps {
        public redwing__ILT_Class__c getILTClassRecord(Id recId) {
            redwing__ILT_Class__c iltClass = null;
            List<redwing__ILT_Class__c> classes = new List<redwing__ILT_Class__c>();
            String queryString = 'SELECT Id, Name, ' +
            		// DE712 - CRE does not create roster records.  Need to calculate number of student from query on Achievement Assignment object
            		// DE1079 - Learn To Swim does not use roster or achievement assignment records.  Need to disoplay student count from LTS fields in class record
            		'Offering_Id__c, Successful_Evaluations__c, Unsuccessful_Evaluations__c, Not_Evaluated__c, ' +
                    'redwing__Start_Date__c, redwing__End_Date__c, redwing__Start_Time__c, redwing__End_Time__c, ' +
                    'redwing__Cancelled__c, redwing__Learning__r.Id, ' + RCConstants.APINAME_FIELD_ORGANIZATION + ', ' +
                    '(SELECT Id, redwing__Instructor__r.Name FROM redwing__ILT_Instructors__r), ' +
                    '(SELECT Id FROM redwing__ILT_Rosters__r WHERE redwing__ILT_Session__c = NULL) ' +
                    'FROM redwing__ILT_Class__c ' +
                    'WHERE Id = :recId ' +
                    'LIMIT 1';

            classes = Database.query(queryString);
            if(!classes.isEmpty()) {
                iltClass = classes[0];
            }

            return iltClass;
        }

        public redwing__Training_Plan__c getPlanWithAchievements(String planId) {
            redwing__Training_Plan__c plan = null;
            List<redwing__Training_Plan__c> plans = new List<redwing__Training_Plan__c>();
            String queryString = 'SELECT Id, Name, toLabel(redwing__Language__c), ' +
                    'toLabel(' + RCConstants.APINAME_FIELD_CLASSSETTINGS + '), ' +
                    // DE986 - Insure that achievements displayed are only certificates (not skills or CEUs)
                    '(SELECT Id, redwing__Achievement__r.Name FROM redwing__Training_Plan_Achievements__r WHERE redwing__Achievement__r.redwing__Type__c = \'Certifications\') ' +
                    'FROM redwing__Training_Plan__c ' +
                    'WHERE Id = :planId';

            plans = Database.query(queryString);

            if(!plans.isEmpty()) {
                plan = plans[0];
            }

            return plan;
        }
    }
}