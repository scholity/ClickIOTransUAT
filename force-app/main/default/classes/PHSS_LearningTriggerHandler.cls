/**
 * Created by scholity on 2019-08-27.
 */

public with sharing class PHSS_LearningTriggerHandler {
    public PHSS_LearningTriggerHandler(){}

    public void initializeOnlineVoucher(List<redwing__Learning__c> newLearningObjects) {
        Set<Id> newOnlineLearningId = new Set<Id>();
        List<Voucher__c> newVouchers = new List<Voucher__c>();
        Map<Id, Integer> voucherCountMap = new Map<Id, Integer>();

        Id mediaRecordTypeId = Schema.SObjectType.redwing__Learning__c.getRecordTypeInfosByName().get('Media').getRecordTypeId();
        for (redwing__Learning__c theLearningObject : newLearningObjects) {
            if (theLearningObject.RecordTypeId == mediaRecordTypeId && theLearningObject.redwing__Published__c == true) {
                newOnlineLearningId.add(theLearningObject.Id);
            }
        }

        if (!newOnlineLearningId.isEmpty()) {
            List<redwing__Training_Plan_Section_Item__c> newOnlineTPSI = [
                    SELECT Id, redwing__Learning__c, redwing__Training_Plan_Section__r.redwing__Training_Plan__c
                    FROM redwing__Training_Plan_Section_Item__c
                    WHERE redwing__Learning__c IN :newOnlineLearningId
            ];
            if (!newOnlineTPSI.isEmpty()) {
                // Determine if we need to create the first Issued voucher for this class
                List<AggregateResult> issuedVoucherCounts = [
                        SELECT Online_Class__c, COUNT(Id) vCount
                        FROM Voucher__c
                        WHERE Online_Class__c IN :newOnlineLearningId AND Status__c = 'Issued'
                        GROUP BY Online_Class__c
                ];

                for (AggregateResult theCount : issuedVoucherCounts) {
                    voucherCountMap.put((Id) theCount.get('Online_Class__c'), (Integer) theCount.get('vCount'));
                }
                // If no count exists then no Issued voucher exists for this Learning object so we must create first one
                for (redwing__Training_Plan_Section_Item__c theTPSI : newOnlineTPSI) {
                    if (!voucherCountMap.containsKey(theTPSI.redwing__Learning__c)) {
                        Voucher__c theNewVoucher = new Voucher__c();
                        theNewVoucher.Status__c = 'Issued';
                        theNewVoucher.Online_Class__c = theTPSI.redwing__Learning__c;
                        theNewVoucher.Learning_Plan__c = theTPSI.redwing__Training_Plan_Section__r.redwing__Training_Plan__c;
                        newVouchers.add(theNewVoucher);
                    }
                }
                if (!newVouchers.isEmpty()) {
                    insert newVouchers;
                }
            }
        }
    }
}