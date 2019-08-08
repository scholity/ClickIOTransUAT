global class PHSS_GenerateCSVFileBatchSchedule implements Schedulable {
    global void execute (SchedulableContext SC){
        PHSS_GenerateCSVFileBatch csvBatch = new  PHSS_GenerateCSVFileBatch();
        database.executeBatch(csvBatch,100);
    }
}