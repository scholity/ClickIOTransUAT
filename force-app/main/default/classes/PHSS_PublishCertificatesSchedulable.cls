global class PHSS_PublishCertificatesSchedulable implements Schedulable {
   global void execute(SchedulableContext SC) {
      PHSS_PublishCertificates publishCertificates = new PHSS_PublishCertificates();
      publishCertificates.getCertificates();
   }
}