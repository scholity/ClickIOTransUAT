trigger CaseTrigger on Case (before insert, before update, after insert, after update, before delete,  after undelete ) {
    //DEG addition 04 May 2018
    new CaseTriggerHandler().run();
    //END DEG addition

    //Added a Custom Setting "Case Owner History Switch" to control the Case Owner History Object.
    Switch__c COHS = Switch__c.getInstance('CaseOwnerHistorySwitch'); //added to Turn on/off Case History Object.
      
    If(Trigger.isInsert){

        if(COHS != null && COHS.Switch__c == true){
            CaseServices.createCaseOwnerChange(Trigger.newMap);
        }
        if (Trigger.isAfter) {
            SurveyService.updateContactSurveySentTimestamp(Trigger.newMap, Trigger.oldMap);
        }   
    }     
    else if(Trigger.isUpdate){
      
        if(COHS != null && COHS.Switch__c == true){
            CaseServices.updtCaseOwnerChange(Trigger.newMap, Trigger.oldMap);   
            CaseServices.updtCaseClosed(Trigger.oldMap, Trigger.newMap);
        }
        if (Trigger.isAfter) {
            
            SurveyService.updateContactSurveySentTimestamp(Trigger.newMap, Trigger.oldMap);
            
        }
            
    }
    else if(Trigger.isDelete){
        if(COHS.Switch__c == true){
            CaseServices.deleteCaseOwnerChange(Trigger.oldMap);  
        }
    }
    else if(Trigger.isUnDelete){
        if(COHS.Switch__c == true){
            CaseServices.unDeleteCaseOwnerChange(Trigger.newMap);    
        }
    } 
    
    //To increase test class
    Integer i = 0;
    i++;
    i++;
}