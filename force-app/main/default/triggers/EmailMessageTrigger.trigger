/**
*       Author: Sonny Le <sonny.le@bluewolf.com>
*       Created: 8th August 2013        
*       Description :  
*       Last Modified : Shubhanshu Verma - Trigger Made Inactive - Implemented new funtionality with the new Trigger. 
*           Use trigger after insert on the EmailMessage object. 
*           When a user replies to a case email, the trigger will assign the case owner back to the queue 
*           it was in before an agent took ownership, as well as update the case fields.
*               
*/
// 
trigger EmailMessageTrigger on EmailMessage (after insert) {
    //Added a Custom Setting "Case Owner History Switch" to control the Email Message Service Class.
    Switch__c COHS = Switch__c.getInstance('EmailMessageServiceSwitch'); //added to Turn on/off Case History Object.
    
    system.assertNotEquals(COHS, null, 'You must create a Switch__c Custom Setting record for the EmailMessageTrigger trigger');
    
    System.debug(Switch__c.getOrgDefaults());
    if(COHS.Switch__c == true){
        EmailMessageServices.updateCaseWhenEmailIsReplied(trigger.newMap);
        EmailMessageServices.billingRouting(trigger.newMap);
    }else{
        UpdatedEmailMessageServices.updateCaseWhenEmailIsRepliedBilling(trigger.newMap);
        UpdatedEmailMessageServices.updateCaseWhenEmailIsRepliedCollections(trigger.newMap);
        UpdatedEmailMessageServices.updateCaseWhenEmailIsRepliedAdjustment(trigger.newMap);
        UpdatedEmailMessageServices.updateCaseWhenEmailIsRepliedRetailCollections(trigger.newMap);
        UpdatedEmailMessageServices.updateCaseWhenEmailIsRepliedothers(trigger.newMap);
    }
}