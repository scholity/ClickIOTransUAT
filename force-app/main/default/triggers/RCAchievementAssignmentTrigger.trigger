trigger RCAchievementAssignmentTrigger on redwing__Achievement_Assignment__c (before insert, before update) {
    
    Boolean isActive = RCAchievementAssignmentsHelper.getAchievementAssignmentDisableTrigger();
    
    if(!isActive) {
        
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            RCAchievementAssignmentsHelper.processBeforeInsertAchievementAssignment(Trigger.new);
        } else if (Trigger.isUpdate) {            
            RCAchievementAssignmentsHelper.processBeforeUpdateAchievementAssignment(Trigger.oldMap, Trigger.new);
            }
        }
    }
}