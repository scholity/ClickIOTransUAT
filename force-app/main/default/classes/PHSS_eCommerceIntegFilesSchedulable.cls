global class PHSS_eCommerceIntegFilesSchedulable implements Schedulable {
   global void execute(SchedulableContext SC) {
        PHSS_eCommerceIntegrationFilesBatch bp = new PHSS_eCommerceIntegrationFilesBatch();
        Database.executeBatch(bp, 500);
   }
}