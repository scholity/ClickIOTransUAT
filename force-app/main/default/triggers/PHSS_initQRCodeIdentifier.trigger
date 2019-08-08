trigger PHSS_initQRCodeIdentifier on redwing__Achievement_Assignment__c (after insert, before update) {
    if (!PHSS_TriggerSettings__c.getOrgDefaults().PHSSinitQRCodeIdentifierDisabled__c) {
        PHSS_initQRCodeIdentifierTriggerHandler handler = new PHSS_initQRCodeIdentifierTriggerHandler();
                
        if (Trigger.isAfter && Trigger.isInsert) {
            handler.PHSS_initQRCodeIdentifierafterInsert(Trigger.new);
        }  
        
        if (Trigger.isBefore && Trigger.isUpdate) {
            handler.PHSS_initQRCodeIdentifierBeforeUpdate(Trigger.new);
        }
    }
}