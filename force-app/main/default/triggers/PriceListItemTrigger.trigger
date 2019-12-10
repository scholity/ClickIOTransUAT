/************************************************************************************************************************************
** Author: Salesforce Services
************************************************************************************************************************************/
trigger PriceListItemTrigger on ccrz__E_PriceListItem__c (after insert, after update) {
     if (!PHSS_TriggerSettings__c.getOrgDefaults().PriceListItemTriggerDisabled__c) { 
         PHSS_PriceListItemTriggerHandler handler = new PHSS_PriceListItemTriggerHandler();
         if (Trigger.isAfter) {
             if (Trigger.isInsert) {
                 List<ccrz__E_PriceListItem__c> emptyList = new List<ccrz__E_PriceListItem__c>();
                 Map<Id, ccrz__E_PriceListItem__c> emptyMap = new Map<Id, ccrz__E_PriceListItem__c>();
                 handler.UpdatePriceOverridesInILTClassRecords(Trigger.new, emptyList, Trigger.newMap, emptyMap);
             }
             if (Trigger.isUpdate) {
                 handler.UpdatePriceOverridesInILTClassRecords(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
             }
         }
     }
}