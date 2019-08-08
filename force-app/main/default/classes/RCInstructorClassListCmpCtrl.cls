public class RCInstructorClassListCmpCtrl {

    private static RCInstructorClassListCmpCtrl.WithoutSharingOps wosInstance;
    private static RCInstructorClassListCmpCtrl.WithoutSharingOps getWOSInstance(){
        if(wosInstance != null){
            return wosInstance;
        }
        wosInstance = new RCInstructorClassListCmpCtrl.WithoutSharingOps();
        return wosInstance;
    }


    @AuraEnabled
    public static ResultData getData(String instructorId, Integer offset, Integer limitOffset, Boolean isHistory) {
        return getWOSInstance().getData(instructorId, offset, limitOffset, isHistory);
    }

    public with sharing class ResultData {
        @AuraEnabled public String  status   = RCConstants.ANSWER_STATUS_SUCCESS;
        @AuraEnabled public String  message  = '';
        @AuraEnabled public String  lang      = '';

        @AuraEnabled public List<classWrapper> classWrappers  = new List<classWrapper>();
    }

    public with sharing class classWrapper {
        @AuraEnabled public String classId          = '';
        @AuraEnabled public String className        = '';
        @AuraEnabled public String lpName           = '';
        @AuraEnabled public String lplanId          = '';
        @AuraEnabled public Date startDate;
        @AuraEnabled public String startTime        = '';
        @AuraEnabled public String endTime          = '';
        @AuraEnabled public Integer days            = 0;
        @AuraEnabled public String company          = '';
        @AuraEnabled public locationWrapper location;
        @AuraEnabled public String classSettings    = '';
        @AuraEnabled public String status           = '';

        public classWrapper(redwing__ILT_Instructor__c instructor, redwing__Training_Plan__c plan, locationWrapper currentLocation, String classStatus, Integer duration){
            this.classId      = instructor.redwing__ILT_Class__c;
            this.className    = instructor.redwing__ILT_Class__r.Name;
            this.startDate    = instructor.redwing__ILT_Class__r.redwing__Start_Date__c;
            this.startTime    = instructor.redwing__ILT_Class__r.ltui__Start_Time_Formatted__c;
            this.endTime      = instructor.redwing__ILT_Class__r.ltui__End_Time_Formatted__c;
            this.location     = currentLocation;
            this.status       = classStatus;
            this.days         = duration;
            String tempCompany = instructor.redwing__ILT_Class__r.Skedulo_Account__r.Name;
            this.company      = String.isNotBlank(tempCompany) ? tempCompany : '';

            if(plan != null) {
                Set<String> fieldNameSet = plan.getPopulatedFieldsAsMap().keySet();

                this.lplanId = plan.Id;
                if(fieldNameSet.contains('Name')) {
                    this.lpName = plan.Name;
                }
                if(fieldNameSet.contains(RCConstants.APINAME_FIELD_CLASSSETTINGS)) {
                    this.classSettings = (String)plan.get(RCConstants.APINAME_FIELD_CLASSSETTINGS);
                }
            }
        }
    }

    public with sharing class locationWrapper {
        @AuraEnabled public String city         = '';
        @AuraEnabled public String address1     = '';
        @AuraEnabled public String country      = '';
        @AuraEnabled public String province     = '';
        @AuraEnabled public String postalCode   = '';
    }
    private without sharing class WithoutSharingOps {

        public ResultData getData(String instructorId, Integer offset, Integer limitOffset, Boolean isHistory) {

            System.debug('> InstructorClassListCmpCtrl');
            System.debug('>> getData value - ' + instructorId + ' - ' + offset + ' - ' + limitOffset + ' - ' + isHistory);

            if(String.isBlank(instructorId)){
                instructorId = UserInfo.getUserId();
            }
            limitOffset = Integer.valueOf(limitOffset);
            offset = Integer.valueOf(offset);
            ResultData  result   = new ResultData();
            result.lang          = UserInfo.getLanguage().substring(0, 2);

            Set<String> neededFields = new Set<String>{
                'Id'
                ,'redwing__ILT_Class__c'
                ,'redwing__ILT_Class__r.Name'
                ,'redwing__ILT_Class__r.ltui__Start_Time_Formatted__c'
                ,'redwing__ILT_Class__r.ltui__End_Time_Formatted__c'
                ,'redwing__ILT_Class__r.redwing__End_Date__c'
                ,'redwing__ILT_Class__r.redwing__Learning__c'
                ,'redwing__ILT_Class__r.redwing__Location__c'
                ,'redwing__ILT_Class__r.redwing__Location__r.redwing__Address_1__c'
                ,'redwing__ILT_Class__r.redwing__Location__r.redwing__City__c'
                ,'redwing__ILT_Class__r.redwing__Location__r.redwing__Country__c'
                ,'redwing__ILT_Class__r.redwing__Location__r.redwing__State__c'
                ,'redwing__ILT_Class__r.redwing__Location__r.redwing__Postal_Code__c'
                ,'redwing__ILT_Class__r.redwing__Start_Date__c'
                ,'redwing__ILT_Class__r.Class_Closed_Date__c'
                ,'redwing__ILT_Class__r.' + RCConstants.APINAME_FIELD_ORGANIZATION
                ,'redwing__ILT_Session__c'
                ,'redwing__Instructor__c'
                ,'redwing__Primary__c '
            };
            String query = 'SELECT ' + String.join(new List<String>(neededFields), ', ') + ' FROM redwing__ILT_Instructor__c WHERE redwing__Instructor__c = : instructorId AND redwing__ILT_Class__c != null ';
            if(isHistory){
                query +=  'AND redwing__ILT_Class__r.redwing__End_Date__c < TODAY ';
            }else{
                query +=  'AND redwing__ILT_Class__r.redwing__End_Date__c >= TODAY ';
                // query +=  'AND redwing__ILT_Class__r.redwing__End_Date__c > TODAY ';
            }
            query +=  'ORDER BY redwing__ILT_Class__r.Name ASC ';
            if(Integer.valueOf(limitOffset) != 0){
                query +=  'LIMIT :limitOffset OFFSET :offset';
            }
            System.debug('query - ' + query);
            List<redwing__ILT_Instructor__c> instructors = Database.query(query);

                System.debug('>> instructors - ' + instructors);

            Set<String> classIds = new Set<String>();
            if(!instructors.isEmpty()){
                Set<String> learningIds = new Set<String>();
                for(redwing__ILT_Instructor__c item : instructors){
                    learningIds.add(item.redwing__ILT_Class__r.redwing__Learning__c);
                }
                Map<String,  Map<String, redwing__Training_Plan__c>> learningId_tpaln = RCUtils.getPlanToLearningIds(learningIds);
                for(redwing__ILT_Instructor__c item : instructors){
                    if(!classIds.contains(item.redwing__ILT_Class__c)){
                        String classStatus = RCConstants.STATUS_UPCOMING;
                        if(item.redwing__ILT_Class__r.redwing__Start_Date__c <= Date.today()){
                        // if(item.redwing__ILT_Class__r.redwing__Start_Date__c <= datetime.now()){
                            classStatus = RCConstants.STATUS_IN_PROGRESS;
                        }
                        if(item.redwing__ILT_Class__r.redwing__End_Date__c < Date.today()){
                        // if(item.redwing__ILT_Class__r.redwing__End_Date__c <= datetime.now()){
                            classStatus = RCConstants.STATUS_COMPLETED;
                        }
                        if(item.redwing__ILT_Class__r.Class_Closed_Date__c != null) {
                            classStatus = RCConstants.STATUS_REPORTED;
                        }
                        Integer duration = 0;
                        if(item.redwing__ILT_Class__r.redwing__Start_Date__c != null && item.redwing__ILT_Class__r.redwing__End_Date__c != null){
                            duration = getCountDays(item.redwing__ILT_Class__r.redwing__Start_Date__c, item.redwing__ILT_Class__r.redwing__End_Date__c);
                        }
                        locationWrapper currentLocation = new locationWrapper();
                        if(item.redwing__ILT_Class__r.redwing__Location__c != null){
                            currentLocation.city        = item.redwing__ILT_Class__r.redwing__Location__r.redwing__City__c;
                            currentLocation.address1    = item.redwing__ILT_Class__r.redwing__Location__r.redwing__Address_1__c;
                            currentLocation.country     = item.redwing__ILT_Class__r.redwing__Location__r.redwing__Country__c;
                            currentLocation.province    = item.redwing__ILT_Class__r.redwing__Location__r.redwing__State__c;
                            currentLocation.postalCode  = item.redwing__ILT_Class__r.redwing__Location__r.redwing__Postal_Code__c;
                        }
                        String currentLearnId = item.redwing__ILT_Class__r.redwing__Learning__c;
                        if(learningId_tpaln.containsKey(currentLearnId)){
                            Map<String, redwing__Training_Plan__c> plansById = learningId_tpaln.get(currentLearnId);
                            for(String pId : plansById.keySet()){
                                classWrapper tempClassWrap = new classWrapper(item, plansById.get(pId), currentLocation, classStatus, duration);
                                result.classWrappers.add(tempClassWrap);
                            }
                        } else{
                            classWrapper tempClassWrap = new classWrapper(item, null, currentLocation, classStatus, duration);
                            result.classWrappers.add(tempClassWrap);
                        }
                    }
                }
                System.debug('>>> learningId_tpaln - ' + learningId_tpaln);
            }
                System.debug('>>> result - ' + result.classWrappers);

            return result;
        }

        public Integer getCountDays(Date startDate, Date endDate){
            Integer result = startDate.daysBetween(endDate);
            result += 1;
            return result;
        }
    }
}