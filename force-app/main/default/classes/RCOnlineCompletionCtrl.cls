public class RCOnlineCompletionCtrl {

    private static RCOnlineCompletionCtrl.WithoutSharingOps wosInstance;
    private static RCOnlineCompletionCtrl.WithoutSharingOps getWOSInstance(){
        if(wosInstance != null){
            return wosInstance;
        }
        wosInstance = new RCOnlineCompletionCtrl.WithoutSharingOps();
        return wosInstance;
    }

    @AuraEnabled
    public static ResultData getData(String classId, String planId) {
        return getWOSInstance().getData(classId, planId);
    }
    public with sharing class ResultData {
        @AuraEnabled public String  status   = RCConstants.ANSWER_STATUS_SUCCESS;
        @AuraEnabled public String  message  = '';
        @AuraEnabled public Integer  allRosters  = 0;
        @AuraEnabled public Integer  completedRosters  = 0;
        @AuraEnabled public Boolean  isInstructor  = false;

    }

    private without sharing class WithoutSharingOps {

        public ResultData getData(String classId, String planId) {
            ResultData  result = new ResultData();
            if(String.isEmpty(classId) && String.isEmpty(planId)){
                return result;
            }
            try {
                result.isInstructor     = RCUtils.isInstructor(classId);
                String type             = Id.valueOf(classId).getSObjectType().getDescribe().getName();

                if(type == 'redwing__ILT_Class__c' && result.isInstructor) {
                    List<redwing__ILT_Roster__c> iltClasses = [SELECT
                            Id
                            ,redwing__User__c
                            ,redwing__User__r.Name
                            ,redwing__User__r.Email
                            ,redwing__User__r.Phone
                    FROM redwing__ILT_Roster__c
                    WHERE redwing__User__c != null
                    AND redwing__ILT_Class__c = : classId];
                    Set<String> userIds = new Set<string>();
                    if(!iltClasses.isEmpty()){
                        for(redwing__ILT_Roster__c item : iltClasses){
                            userIds.add(item.redwing__User__c);
                        }

                        Map<String, String> user_status = RCUtils.getUserOnlineStatus(userIds, planId);
                        for(String uId : userIds){
                            result.allRosters++;
                            if(user_status.get(uId) == RCConstants.STATUS_COMPLETED){
                                result.completedRosters++;
                            }
                        }
                    }
                }
            } catch (Exception e) {
                result.status   = RCConstants.ANSWER_STATUS_ACCESS_DENIED;
                result.message  = e.getMessage();
            }
            return result;
        }
    }
}