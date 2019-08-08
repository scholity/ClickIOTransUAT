global class PHSS_GenerateCCProductXMLSchedule implements Schedulable {
    global void execute (SchedulableContext SC){
        PHSS_GenerateCCProductXMLBatch ccProductXMLBatch = new  PHSS_GenerateCCProductXMLBatch(false);
        database.executeBatch(ccProductXMLBatch,100);
    }
}