global class PHSS_eCommerceIntegFilesSchedulable implements Schedulable {
   global void execute(SchedulableContext SC) {
      PHSS_eCommerceIntegrationFiles integrationFiles = new PHSS_eCommerceIntegrationFiles();
      integrationFiles.getCommunityClasses();
   }
}