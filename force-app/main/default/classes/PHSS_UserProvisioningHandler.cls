public with sharing class PHSS_UserProvisioningHandler implements PHSS_TriggerHandler {
    public static Boolean isDisabled = false;

    public Boolean isDisabled() {
        return isDisabled || PHSS_TriggerUtility.getSettings().UserProvisioningDisabled__c;
    }

    public void beforeInsert(List<SObject> newItems) {
        List<PHSS_User_Provisioning__c> userProvisionings = (List<PHSS_User_Provisioning__c>) newItems;
        System.debug(userProvisionings);
        this.setFields(userProvisionings);
        System.debug(userProvisionings);
    }

    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}

    public void beforeDelete(Map<Id, SObject> oldItems) {}

    public void afterInsert(Map<Id, SObject> newItems){
        PHSS_ProcessUserProvisioning_BATCH.schedule();
    }

    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}

    public void afterDelete(Map<Id, SObject> oldItems) {}

    public void afterUndelete(Map<Id, SObject> oldItems) {}

    private void setFields(List<PHSS_User_Provisioning__c> userProvisionings) {
        PHSS_Custom_Metadata__mdt defaults = [SELECT Username_Suffix__c FROM PHSS_Custom_Metadata__mdt WHERE DeveloperName = 'PHSS_Instructors_Corner' LIMIT 1];
        for(PHSS_User_Provisioning__c userProvisioning: userProvisionings) {
            String sabaUsername = userProvisioning.Username__c;
            System.debug(userProvisioning.Username__c);
            if(sabaUsername == null) {
                userProvisioning.Username__c = sabaUsername;
            } else if(String.isBlank(defaults.Username_Suffix__c)) {
                userProvisioning.Username__c = sabaUsername.toLowerCase();
            } else {
                userProvisioning.Username__c = (sabaUsername + '.' + defaults.Username_Suffix__c).toLowerCase();
            }
            System.debug(userProvisioning.Username__c);
            userProvisioning.Email__c = userProvisioning.Email__c == null ? userProvisioning.Email__c : userProvisioning.Email__c.toLowerCase();
        }
    }
}