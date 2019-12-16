public class PHSS_PublishCertificatesBatchSchedulable implements Schedulable {
    public void execute(SchedulableContext SC) {
        PHSS_PublishCertificatesBatch bp = new PHSS_PublishCertificatesBatch();
        Database.executeBatch(bp, 1000);
    }
}