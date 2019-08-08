trigger trgr_Channel_Compensation on Channel_Compensation__c (before insert, before update) {	
    
    if (!PHSS_TriggerSettings__c.getOrgDefaults().trgr_Channel_Compensation_Disabled__c) {
        /* 
         * Author: Salesforce Services
         * Date Added: 2/21/2019
         */
        if (Trigger.isBefore && Trigger.isInsert) {
            cls_Channel_Compensation.onBeforeInsert(Trigger.new);
        } else if (Trigger.isBefore && Trigger.isUpdate) {
            cls_Channel_Compensation.onBeforeUpdate(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
        } 

        if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {		
            cls_Channel_Compensation.updateUniqueIdentifier(Trigger.new);
            cls_Channel_Compensation.uniqueRecordConstraint(Trigger.new);
            cls_Channel_Compensation.updateTerritoryCodeLookup(Trigger.new);	
        }
    }	
}