/*
Controller responsible for serving Broadcast Message data to community component
*/
public with sharing class BroadcastMessageApexController {
    /**
     * Method returns list of active messages
     *
     * @return Messages
     */     
    @AuraEnabled
    public static List<Broadcast_Message__c> getBroadcastMessages() {
		System.debug('>>>>>>>>>> BroadcastMessageApexController.getBroadcastMessages');
        List<Broadcast_Message__c> msgs = [SELECT 
                    Id, Name, Sequence__c, Message__c, Clickable_Link__c 
                FROM 
                    Broadcast_Message__c 
                WHERE 
                    Active__c = true
                ORDER BY 
                    Sequence__c ASC
                ];
        System.debug('>>>>>>>>>> BroadcastMessageApexController.msgs ' + msgs);
        if (msgs != null) {
            System.debug('>>>>>>>>>> BroadcastMessageApexController.msgs.size ' + msgs.size());
        }
        return msgs;
    }    
}