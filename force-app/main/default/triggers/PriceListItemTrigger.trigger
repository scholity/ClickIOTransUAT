/************************************************************************************************************************************
** Author: Salesforce Services
************************************************************************************************************************************/
trigger PriceListItemTrigger on ccrz__E_PriceListItem__c (after update) {
     if (!PHSS_TriggerSettings__c.getOrgDefaults().PriceListItemTriggerDisabled__c) { 
         PHSS_PriceListItemTriggerHandler handler = new PHSS_PriceListItemTriggerHandler();
         if (Trigger.isAfter && Trigger.isUpdate) {
                handler.UpdatePriceOverridesInILTClassRecords(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
         }
     }
}