trigger PHSS_User_Provisioning_Trigger on PHSS_User_Provisioning__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    PHSS_TriggerDispatcher.run(new PHSS_UserProvisioningHandler());
}