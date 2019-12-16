public class PHSS_eCommerceIntegFilesFullSchedulable implements Schedulable {
   public void execute(SchedulableContext SC) {
      // Parameter 1 : true=Full Export, false=Incremental Export
      // Parameter 2 : flags {C=Classes/Courses/CPS, L=Location, I=Inventory, P=Price, S=Site Catalog}
      PHSS_eCommerceIntegrationFilesBatch bp = new PHSS_eCommerceIntegrationFilesBatch(true, 'CLIPS');
      Database.executeBatch(bp, 100);
   }
}