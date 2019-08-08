global with sharing  class RCAchievementAssignmentUpdateBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable  {
    private RCAchievementAssignmentUpdateBatchHelper.AAR_BATCH_TYPE batchType;
    private Object arguments;

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return RCAchievementAssignmentUpdateBatchHelper.startBatchMethod(batchType, arguments, BC);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        RCAchievementAssignmentUpdateBatchHelper.executeBatchMethod(batchType, arguments, scope, BC);
    }

    global void finish(Database.BatchableContext BC) {
    }
    
    global void execute(SchedulableContext sc)    {
        DataBase.executeBatch(new RCAchievementAssignmentUpdateBatch(), 100);
    }
}