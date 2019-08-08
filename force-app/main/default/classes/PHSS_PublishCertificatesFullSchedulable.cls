global class PHSS_PublishCertificatesFullSchedulable implements Schedulable {
   global void execute(SchedulableContext SC) {
      PHSS_PublishCertificates publishCertificates = new PHSS_PublishCertificates();
      publishCertificates.getAllCertificates();
   }
}