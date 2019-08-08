public with sharing class PHSS_TriggerUtility {
    public static PHSS_TriggerSettings__c getSettings(){
        PHSS_TriggerSettings__c profileSettings = PHSS_TriggerSettings__c.getInstance(UserInfo.getProfileId());
        return profileSettings.Id == null ? PHSS_TriggerSettings__c.getOrgDefaults() : profileSettings;
    }
}