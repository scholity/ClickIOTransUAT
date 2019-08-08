/************************************************************************************************************************************
** Author: Salesforce Services
************************************************************************************************************************************/
trigger VoucherTrigger on Voucher__c (after update) {
     if (!PHSS_TriggerSettings__c.getOrgDefaults().VoucherTriggerDisabled__c) {
         PHSS_VoucherTriggerHandler handler = new PHSS_VoucherTriggerHandler();
         if (Trigger.isAfter && Trigger.isUpdate) {
             if (!PHSS_VoucherTriggerHandler.hasAlreadyUpdatedVouchers()) {
             	handler.CheckTotalAvailableOnlineVouchers(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
                handler.BlockIssuedVouchersAndIssueBlockedVouchers(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
                handler.adjustAvailableSeats(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
             }
         }
  	 }
}