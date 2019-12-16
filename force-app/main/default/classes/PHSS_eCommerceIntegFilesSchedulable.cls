public class PHSS_eCommerceIntegFilesSchedulable implements Schedulable {
   public void execute(SchedulableContext SC) {
      // Parameter 1 : true=Full Export, false=Incremental Export
      // Parameter 2 : flags {C=Classes/Courses/CPS, L=Location, I=Inventory, P=Price, S=Site Catalog}
      PHSS_eCommerceIntegrationFilesBatch bp = new PHSS_eCommerceIntegrationFilesBatch(false, 'CLIPS');
      Database.executeBatch(bp, 100);
   }
}