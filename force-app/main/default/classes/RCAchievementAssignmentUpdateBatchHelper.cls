public class RCAchievementAssignmentUpdateBatchHelper {
    public Enum AAR_BATCH_TYPE {
        SET_EXPIRATION_STATUS
    }

    public static Database.QueryLocator startBatchMethod(AAR_BATCH_TYPE iteration, Object arguments, Database.BatchableContext BC) {
        String result ;
        String statusAcquired = 'Acquired';

        //if (iteration == AAR_BATCH_TYPE.SET_EXPIRATION_STATUS) {
            result = getAvailableAchievementAssignment();
        //}

        return Database.getQueryLocator(result);
    }

    public static void executeBatchMethod(AAR_BATCH_TYPE iteration, Object arguments, List<sObject> scope, Database.BatchableContext BC) {
        try {
            //if (iteration == AAR_BATCH_TYPE.SET_EXPIRATION_STATUS && scope.size() > 0) {
                calculateExpirationStatus(scope);
            //}
        } catch (Exception e) {
            handleUnexpectedException(e);
        }
    }

    public static String getAvailableAchievementAssignment() {
        String queryString   =
            'SELECT Id, Name, redwing__Status__c, ' +
            '    redwing__Achievement__c, ' +
            '    redwing__Expiration_Date__c, ' +
            '    redwing__Achievement__r.redwing__Expiration_Date__c ' +
            'FROM redwing__Achievement_Assignment__c ' +
            'WHERE redwing__Status__c = :statusAcquired';
        return queryString;
    }

    public static void calculateExpirationStatus(List<sObject> sObjs) {
        List<redwing__Achievement_Assignment__c> achievements = new List<redwing__Achievement_Assignment__c>();
        String statusExpired = 'Expired';
   
        for(sObject item : sObjs) {
            redwing__Achievement_Assignment__c achieve = (redwing__Achievement_Assignment__c) item;
            
            if(achieve.redwing__Expiration_Date__c != null && achieve.redwing__Expiration_Date__c <= Date.today()) {
                achieve.redwing__Status__c = statusExpired;
                
            } else if(achieve.redwing__Expiration_Date__c == null && achieve.redwing__Achievement__r.redwing__Expiration_Date__c <= Date.today()) {
                achieve.redwing__Status__c = statusExpired;
            }

            achievements.add(achieve); 
        }
        
        if (achievements.size() > 0) {
            update achievements;
        }
      
    }
    
    public static void handleUnexpectedException(Exception e) {}
}