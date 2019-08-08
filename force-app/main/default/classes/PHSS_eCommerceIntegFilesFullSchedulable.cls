global class PHSS_eCommerceIntegFilesFullSchedulable implements Schedulable {
   global void execute(SchedulableContext SC) {
      PHSS_eCommerceIntegrationFiles integrationFiles = new PHSS_eCommerceIntegrationFiles();
      integrationFiles.getAllCommunityClasses();
   }
}