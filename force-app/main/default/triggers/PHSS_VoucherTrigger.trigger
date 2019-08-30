/************************************************************************************************************************************
** Author: Salesforce Services
************************************************************************************************************************************/
trigger PHSS_VoucherTrigger on Voucher__c (after insert, after update) {
     if (!PHSS_TriggerSettings__c.getOrgDefaults().VoucherTriggerDisabled__c) {
         PHSS_VoucherTriggerHandler handler = new PHSS_VoucherTriggerHandler();
         if (Trigger.isAfter && Trigger.isInsert) {
             // Create dummy old list and map to support one common entry point in voucher trigger handler
             List<Voucher__c> oldVouchers = new List<Voucher__c>();
             Map<Id,Voucher__c> oldVoucherMap = new Map<Id,Voucher__c>();
             handler.CheckTotalAvailableOnlineVouchers(Trigger.new, oldVouchers, Trigger.newMap, oldVoucherMap);
         }
         if (Trigger.isAfter && Trigger.isUpdate) {
             if (!PHSS_VoucherTriggerHandler.hasAlreadyUpdatedVouchers()) {
                handler.CheckTotalAvailableOnlineVouchers(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
                handler.BlockIssuedVouchersAndIssueBlockedVouchers(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
                handler.adjustAvailableSeats(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
             }
         }
     }
}