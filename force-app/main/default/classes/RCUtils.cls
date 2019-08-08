public with sharing class RCUtils {

    private static RCUtils.WithoutSharingOps wosInstance;

    private static RCUtils.WithoutSharingOps getWOSInstance(){
        if(wosInstance != null){
            return wosInstance;
        }
        wosInstance = new RCUtils.WithoutSharingOps();
        return wosInstance;
    }

    public static String getBaseUrlLink(String linkToPage) {
        String baseUrl = '';

        if (!RCConstants.IS_EXPERIENCE) {
            baseUrl = Url.getSalesforceBaseUrl().toExternalForm() + Site.getPathPrefix();
            baseUrl += (String.isBlank(linkToPage))
                ? '/detail'
                : '/' + EncodingUtil.urlEncode(linkToPage, 'UTF-8');
        }

        return baseUrl;
    }

    public static String getDetailLink(String linkToPage, String itemId) {

        return getBaseUrlLink(linkToPage) + '/' + itemId;
    }

    public static Map<String,  Map<String, redwing__Training_Plan__c>> getPlanToLearningIds(Set<String> learningIds) {
        Map<String, String> learningIdsToLearningIdsMap = new Map<String, String>();
        Map<String,  Map<String, redwing__Training_Plan__c>> planToLearningIdsMap = new Map<String,  Map<String, redwing__Training_Plan__c>>();

        learningIdsToLearningIdsMap = getWOSInstance().getParentEventIds(learningIds);
        planToLearningIdsMap = getWOSInstance().getPlanToLearningIds(learningIdsToLearningIdsMap);

        return planToLearningIdsMap;
    }

    public static String getStatus(DateTime startDate, DateTime endDate){
        String classStatus = RCConstants.STATUS_UPCOMING;
        if(startDate <= Date.today()){
            classStatus = RCConstants.STATUS_IN_PROGRESS;
        }
        if(endDate < Date.today()){
            classStatus = RCConstants.STATUS_COMPLETED;
        }
        return classStatus;
    }

    public static Map<String, String> getUserOnlineStatus(Set<String> userIds, String tPlanId) {
        return getWOSInstance().getUserOnlineStatus(userIds, tPlanId);
    }

    public static String getStatus(String currentStatus, String lAssignmentStatus){
        String status = currentStatus;
        if( (currentStatus == RCConstants.STATUS_NOT_STARTED && lAssignmentStatus != RCConstants.STATUS_NOT_STARTED)
            || (currentStatus == RCConstants.STATUS_COMPLETED && lAssignmentStatus != RCConstants.STATUS_COMPLETED)
        ){
            status = RCConstants.STATUS_IN_PROGRESS;
        }
        return status;
    }
    public static Boolean isInstructor(String classId) {
        return true; //getWOSInstance().isInstructor(classId);
    }

    private without sharing class WithoutSharingOps {
        public Map<String, String> getParentEventIds(Set<String> learningIds) {
            Map<String, String> learningIdsToLearningIdsMap = new Map<String, String>();
            List<redwing__ILT_Event_Class__c> eventClasses = new List<redwing__ILT_Event_Class__c>();

            for(String lid: learningIds) {
                learningIdsToLearningIdsMap.put(lid, lid);
            }

            eventClasses = [
                    SELECT Id, redwing__ILT_Event__r.redwing__Learning__c, redwing__Learning__c
                    FROM redwing__ILT_Event_Class__c
                    WHERE redwing__Learning__c IN :learningIdsToLearningIdsMap.values()
            ];

            for(redwing__ILT_Event_Class__c ec: eventClasses) {
                learningIdsToLearningIdsMap.put(ec.redwing__Learning__c, ec.redwing__ILT_Event__r.redwing__Learning__c);
            }

            return learningIdsToLearningIdsMap;
        }

        public Map<String, Map<String, redwing__Training_Plan__c>> getPlanToLearningIds(Map<String, String> learningIdsToLearningIdsMap) {
            Map<String, Set<String>> revertedLearningIdsMap = new Map<String, Set<String>>();
            Map<String, Map<String, redwing__Training_Plan__c>> planToLearningIdsMap = new Map<String, Map<String, redwing__Training_Plan__c>>();
            List<redwing__Training_Plan_Section_Item__c> sectionItems = new List<redwing__Training_Plan_Section_Item__c>();
            Set<String> learningIds = new Set<String>();
            String queryString = 'SELECT Id, redwing__Learning__c, ' +
                    'redwing__Training_Plan_Section__r.redwing__Training_Plan__r.Id, ' +
                    'redwing__Training_Plan_Section__r.redwing__Training_Plan__r.Name, ' +
                    'toLabel(redwing__Training_Plan_Section__r.redwing__Training_Plan__r.' + RCConstants.APINAME_FIELD_CLASSSETTINGS + ') ' +
                    'FROM redwing__Training_Plan_Section_Item__c ' +
                    'WHERE redwing__Learning__c IN :learningIds';

            for (String lid: learningIdsToLearningIdsMap.keySet()) {
                if(revertedLearningIdsMap.containsKey(learningIdsToLearningIdsMap.get(lid))){
                    revertedLearningIdsMap.get(learningIdsToLearningIdsMap.get(lid)).add(lid);
                }else{
                    revertedLearningIdsMap.put(learningIdsToLearningIdsMap.get(lid), new Set<String>{lid});
                }
            }
            learningIds.addAll(revertedLearningIdsMap.keySet());

            sectionItems = Database.query(queryString);


            for(redwing__Training_Plan_Section_Item__c tpsi: sectionItems) {
                for(String item : revertedLearningIdsMap.get(tpsi.redwing__Learning__c)){
                    if(planToLearningIdsMap.containsKey(item)){
                        planToLearningIdsMap.get(item).put(
                                tpsi.redwing__Training_Plan_Section__r.redwing__Training_Plan__c ,
                                tpsi.redwing__Training_Plan_Section__r.redwing__Training_Plan__r
                        );
                    } else{
                        planToLearningIdsMap.put(
                                item,
                                new Map<String, redwing__Training_Plan__c> {tpsi.redwing__Training_Plan_Section__r.redwing__Training_Plan__c => tpsi.redwing__Training_Plan_Section__r.redwing__Training_Plan__r}
                        );
                    }
                }
            }
            return planToLearningIdsMap;
        }

        public Map<String, String> getUserOnlineStatus(Set<String> userIds, String tPlanId){
            Map<String, String> user_status = new Map<String, String>();
            Set<String> existRecordName = new Set<String>{'ILT Class', 'ILT Event'};
            List<redwing__Learning_Assignment__c> lAssignments = [
                                                            SELECT Id
                                                            ,redwing__Training_Plan__c
                                                            ,redwing__Progress__c
                                                            ,redwing__User__c
                                                            ,redwing__Learning__c
                                                            ,redwing__Learning__r.RecordType.Name
                                                            FROM redwing__Learning_Assignment__c
                                                            WHERE redwing__User__c IN : userIds
                                                            AND redwing__Training_Plan__c = : tPlanId
                                                            AND redwing__Learning__r.RecordType.Name NOT IN : existRecordName];
            for(redwing__Learning_Assignment__c lAssign : lAssignments){
                String tUserId = lAssign.redwing__User__c;
                String lAssignmentStatus = lAssign.redwing__Progress__c;
                if(user_status.containsKey(tUserId)){
                    user_status.put(tUserId, getStatus(user_status.get(tUserId), lAssignmentStatus));
                } else{
                    user_status.put(tUserId, lAssignmentStatus);
                }
            }
            return user_status;
        }

        public Boolean isInstructor(String classId) {
            Boolean isInstructor = false;
            List<redwing__ILT_Instructor__c> instructors = new List<redwing__ILT_Instructor__c>();

            instructors = [
                    SELECT Id
                    FROM redwing__ILT_Instructor__c
                    WHERE redwing__ILT_Class__c = :classId
                    AND redwing__Instructor__c = :UserInfo.getUserId()
                    LIMIT 1
            ];

            isInstructor = !instructors.isEmpty();

            return isInstructor;
        }
    }
}