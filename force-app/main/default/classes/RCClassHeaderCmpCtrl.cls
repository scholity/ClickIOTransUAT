public with sharing class RCClassHeaderCmpCtrl {

    private static RCClassHeaderCmpCtrl.WithoutSharingOps wosInstance;

    private static RCClassHeaderCmpCtrl.WithoutSharingOps getWOSInstance(){
        if(wosInstance != null){
            return wosInstance;
        }
        wosInstance = new RCClassHeaderCmpCtrl.WithoutSharingOps();
        return wosInstance;
    }

    @AuraEnabled
    public static ResultData getItemInfo(Id itemId, String planId) {
        ResultData outputData = new ResultData();

        outputData.lang          = UserInfo.getLanguage().substring(0, 2);
        if (itemId == null) {
            return outputData;
        }

        try {
            Boolean isInstructor    = RCUtils.isInstructor((String)itemId);
            String type = itemId.getSObjectType().getDescribe().getName();

            if (type == 'redwing__ILT_Class__c' && isInstructor) {
                getWOSInstance().getIltClassInfo(itemId, outputData, planId);
            } else if (!isInstructor) {
                outputData.status   = RCConstants.ANSWER_STATUS_ACCESS_DENIED;
                outputData.message  = System.Label.No_Permissions_To_View_Class;
            }
        } catch (Exception e) {
            outputData.status   = RCConstants.ANSWER_STATUS_ACCESS_DENIED;
            outputData.message  = e.getMessage();
        }

        return outputData;
    }



    public with sharing class ResultData {
        @AuraEnabled public String status   = RCConstants.ANSWER_STATUS_SUCCESS;
        @AuraEnabled public String message  = '';
        @AuraEnabled public String  lang    = '';

        @AuraEnabled public LearningItemWrapper item                                    = null;
        @AuraEnabled public List<Map<String,Object>> extraFields                        = new List<Map<String, Object>>();
        @AuraEnabled public List<RCUserWrapper> assignedUsers                             = new List<RCUserWrapper>();
        @AuraEnabled public String dueDate                                              = '';
        @AuraEnabled public String learningType                                         = '';

    }

    public with sharing class LearningItemWrapper {
        @AuraEnabled public String  name;
        @AuraEnabled public String  description;
        @AuraEnabled public String  status;
        @AuraEnabled public String  formatProgress;
        @AuraEnabled public String  formatDuration;
        @AuraEnabled public Decimal rating;
        @AuraEnabled public String  backgroundImageURL;
        @AuraEnabled public String  backgroundColor;
        @AuraEnabled public String  textColor;
        @AuraEnabled public String  assignedDate;
        @AuraEnabled public String  completionDate;

        @AuraEnabled public Boolean hasCustomReward;
        @AuraEnabled public String  customType;
        @AuraEnabled public String  customRewardAmount;

        @AuraEnabled public Date    startDate;
        @AuraEnabled public Date    endDate;
        @AuraEnabled public String  organization;
        @AuraEnabled public String  classSettings;
        @AuraEnabled public String  language;
        @AuraEnabled public Integer numberOfStudents;

        public LearningItemWrapper(redwing__ILT_Class__c iltClass) {
            this.name               = String.isNotBlank(iltClass.name) ? iltClass.name : '-';
            this.startDate          = iltClass.redwing__Start_Date__c;
            this.endDate            = iltClass.redwing__End_Date__c;
            this.organization       = String.isNotBlank(iltClass.Skedulo_Account__r.Name) ? iltClass.Skedulo_Account__r.Name : '-';
            this.classSettings      = '-';
            this.language           = '-';
            this.status             = '';
        }
    }

    private without sharing class WithoutSharingOps {

        public void getIltClassInfo(Id itemId, ResultData outputData, String planId) {
            outputData.learningType = 'iltClass';
            List<redwing__ILT_Roster__c> iltRosters = [SELECT
                                                                Id
                                                                ,redwing__User__c
                                                            FROM redwing__ILT_Roster__c
                                                            WHERE redwing__User__c != null
                                                            AND redwing__ILT_Class__c = : itemId];
            Integer numberOfStudents = 0;
            if(!iltRosters.isEmpty()){
                Set<String> userIds = new Set<String>();
                for(redwing__ILT_Roster__c item : iltRosters){
                    userIds.add(item.redwing__User__c);
                }
                numberOfStudents = userIds.size();
            }
            Set<String> neededFields = new Set<String>{
                'Id',
                'Name',
                'redwing__Start_Date__c',
                'redwing__End_Date__c',
                'redwing__Learning__c',
                RCConstants.APINAME_FIELD_ORGANIZATION
            };

            List<redwing__ILT_Class__c> iltCl = (List<redwing__ILT_Class__c>)Database.query(
                'SELECT ' + String.join(new List<String>(neededFields), ', ') + ' FROM redwing__ILT_Class__c WHERE Id = : itemId'
            );
            if(!iltCl.isEmpty()){
                outputData.item = new LearningItemWrapper(iltCl[0]);
                outputData.item.numberOfStudents = numberOfStudents;
                outputData.item.status = RCUtils.getStatus(iltCl[0].redwing__Start_Date__c, iltCl[0].redwing__End_Date__c);
                List<redwing__Training_Plan__c> tpaln = Database.query('SELECT Id, toLabel(redwing__Language__c), toLabel('+ RCConstants.APINAME_FIELD_CLASSSETTINGS + ') FROM redwing__Training_Plan__c WHERE Id =: planId');
                if(!tpaln.isEmpty()){
                    String classSet = (String)tpaln[0].get(RCConstants.APINAME_FIELD_CLASSSETTINGS);
                    outputData.item.classSettings = String.isNotBlank(classSet) ? classSet : '-';
                    outputData.item.classSettings = String.isNotBlank(classSet) ? classSet : '-';
                    outputData.item.language      = String.isNotBlank(tpaln[0].redwing__Language__c) ? tpaln[0].redwing__Language__c  : '-';
                }
            }
        }
    }

}