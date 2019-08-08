trigger PHSS_Certification_Provisioning_Trigger on PHSS_Certification_Provisioning__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    PHSS_TriggerDispatcher.run(new PHSS_CertificationProvisioningHandler());
}