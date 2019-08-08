public without sharing class RCILTClassRosterListCmpCtrl {

    private static RCILTClassRosterListCmpCtrl.WithoutSharingOps wosInstance;
    private static RCILTClassRosterListCmpCtrl.WithoutSharingOps getWOSInstance(){
        if(wosInstance != null){
            return wosInstance;
        }
        wosInstance = new RCILTClassRosterListCmpCtrl.WithoutSharingOps();
        return wosInstance;
    }

    @AuraEnabled
    public static ResultData getData(String classId, String planId) {
        return getWOSInstance().getData(classId, planId);
    }
    public without sharing class ResultData {
        @AuraEnabled public String  status   = RCConstants.ANSWER_STATUS_SUCCESS;
        @AuraEnabled public String  message  = '';

        @AuraEnabled public List<RCUserWrapper> RCUserWrappers  = new List<RCUserWrapper>();
    }

    public without sharing class RCUserWrapper {
        @AuraEnabled public String classId      = '';
        @AuraEnabled public String userId       = '';
        @AuraEnabled public String name         = '';
        @AuraEnabled public String email        = '';
        @AuraEnabled public String phone        = '';
        @AuraEnabled public String status       = '';
    }

    private without sharing class WithoutSharingOps {

        public ResultData getData(String classId, String planId) {
            ResultData  result              = new ResultData();
            if(String.isEmpty(classId) && String.isEmpty(planId)){
                return result;
            }
            try {
                String recType          = Id.valueOf(classId).getSobjectType().getDescribe().getLocalName();
                Boolean isInstructor    = RCUtils.isInstructor(classId);

                if(recType == 'redwing__ILT_Class__c' && isInstructor) {  
                   List<redwing__ILT_Roster__c> iltClasses = [SELECT
                            Id
                            ,redwing__User__c
                            ,redwing__User__r.Name
                            ,redwing__User__r.Email
                            ,redwing__User__r.Phone
                            ,redwing__Learning_Assignment__c
                            ,redwing__Learning_Assignment__r.redwing__Learning__c
                            ,redwing__Learning_Assignment__r.redwing__Progress__c
                    FROM redwing__ILT_Roster__c
                    WHERE redwing__User__c != null
                    AND redwing__ILT_Class__c = : classId];

                    Map<String, RCUserWrapper> userWrapps = new Map<string, RCUserWrapper>();
                    Set<String> userIds = new Set<string>();
                    if(!iltClasses.isEmpty()){
                        for(redwing__ILT_Roster__c item : iltClasses){
                            userIds.add(item.redwing__User__c);
                        }
                        Map<String, String> user_status = RCUtils.getUserOnlineStatus(userIds, planId);
                        for(redwing__ILT_Roster__c item : iltClasses){
                            RCUserWrapper tempUser = new RCUserWrapper();
                            tempUser.classId        = item.Id;
                            tempUser.userId         = item.redwing__User__c;
                            tempUser.name           = item.redwing__User__r.Name;
                            tempUser.email          = item.redwing__User__r.Email;
                            tempUser.phone          = item.redwing__User__r.Phone;
                            tempUser.status         = RCConstants.STATUS_NOT_STARTED;
                            if(user_status.containsKey(item.redwing__User__c)){
                                tempUser.status = user_status.get(item.redwing__User__c);
                            } else if (item.redwing__Learning_Assignment__r.redwing__Progress__c != null) {
                                tempUser.status = item.redwing__Learning_Assignment__r.redwing__Progress__c;
                            }
                            userWrapps.put(item.redwing__User__c, tempUser);
                        }
                        result.RCUserWrappers.addAll(userWrapps.values());
                    }
                }
            } catch (Exception e) {
                result.status       = RCConstants.ANSWER_STATUS_ACCESS_DENIED;
                result.message      = e.getMessage();
            }

            return result;
        }
    }
}