global class PHSS_GenerateCCProductXMLFullSchedulable implements Schedulable {
    global void execute (SchedulableContext SC){
        PHSS_GenerateCCProductXMLBatch ccProductXMLBatch = new  PHSS_GenerateCCProductXMLBatch(true);
        database.executeBatch(ccProductXMLBatch,100);
    }
}