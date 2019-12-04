public class PHSS_eCommerceIntegFilesSchedulable implements Schedulable {
   public void execute(SchedulableContext SC) {
      PHSS_eCommerceIntegrationFilesBatch bp = new PHSS_eCommerceIntegrationFilesBatch();
      Database.executeBatch(bp, 500);
   }
}