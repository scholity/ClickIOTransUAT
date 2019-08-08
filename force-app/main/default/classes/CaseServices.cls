public without sharing class CaseServices {

    public static Set<Id> updatedCases = new Set<Id>(); //the set of cases that have already been updated in this context

    public static void createCaseOwnerChange(Map<ID,Case> newMap ){
        if(newMap != null) {
            
            // get list of all users
            List<User> userList = [Select id,
                                        name
                                        From User];
            
            
            // get list of all queues
            List<Group> queueList = [Select id,
                                        name
                                        From Group];
                
            
            List<Case_Owner_History__c> caseHistInsrts = new List<Case_Owner_History__c>();
            for(Case cs: newMap.values()) {
                if(cs.OwnerID != null ) {
                    
                    String ownerName='';
                    // find owner
                    for ( User usr : userList ) {
                        if (usr.id == cs.OwnerId) {
                            ownerName = usr.name;
                        }
                    }
                    
                    // find queue
                    for ( Group grp : queueList ) {
                        if ( grp.id == cs.OwnerId ) {
                            ownerName = grp.name;
                        }
                    }
                    
                    
                    
                    Case_Owner_History__c csHist = new Case_Owner_History__c(
                                                        Case__c = cs.ID, 
                                                        Owner_Id__c = cs.OwnerId ,
                                                        Owner_Name__c = ownerName,
                                                        Received__c = cs.CreatedDate 
                                                        );
                    caseHistInsrts.add(csHist);
                }
            }
            
            if(caseHistInsrts.size() > 0){
                try{
                    insert caseHistInsrts;
                }catch (DMLException e ){ 
                    System.debug('Exception: '+e.getDmlMessage(0)); 
                } 
                
            }
         }
        
    }   
    
    /*
        If a case is closed, capture the current data and time in the Handed_Off field
        in the last Case Owner History record
    */
    public static void updtCaseClosed(Map<Id,Case> oldMap, Map<Id,Case> newMap) {
        List<Case_Owner_History__c> caseHistUpdates = new List<Case_Owner_History__c>();
        Set<ID> casesToProcess = new Set<ID>();
        
        // build a list of case ids that need to be procesed by this trigger
        for (Case cs: newMap.values()) {

            //if the owner has changed then add it to the list of cases that need new history records and store its
            //id in the set of cases already updated in this context to prevent recursion
            if ( cs.IsClosed != oldMap.get(cs.Id).IsClosed && cs.IsClosed && !CaseServices.updatedCases.contains(cs.Id)) 
            {
                casesToProcess.add(cs.Id);
                CaseServices.updatedCases.add(cs.Id);    
            }
        }
        
        // get the last Case_Owner_History record so we can update it
        // -- last = Handed_Off__c == null
        caseHistUpdates = [Select ID ,
                                Case__C,
                                Handed_Off__c 
                                from Case_Owner_History__c
                                where Case__c in:casesToProcess and 
                                        Handed_Off__c = null] ;  
    
        // update case owner history
        for (Case_Owner_History__c historyItem: caseHistUpdates) {
            historyItem.Handed_Off__c = System.now();   
        }
        
        try {
            update caseHistUpdates;         
        } catch (DMLException e ){ 
            System.debug('Exception: '+e.getDmlMessage(0)); 
        } 
    
    }
    
    
    public static void updtCaseOwnerChange(Map<ID,Case> newMap, Map<ID,Case> oldMap){
        List<Case> updtOwners = new List<Case>();
        Set<ID> updtCases = new Set<ID>();
        List<Case_Owner_History__c> caseHistInsrts = new List<Case_Owner_History__c>();
        List<Case_Owner_History__c> caseHistUpdts ;
        
        if(oldMap!= null ) {            
            for(Case cs: newMap.values()) {

                //if the owner has changed then add it to the list of cases that need new history records and store its
                //id in the set of cases already updated in this context to prevent recursion
                if (cs.OwnerID != oldMap.get(cs.ID).OwnerID && !cs.isClosed && !CaseServices.updatedCases.contains(cs.Id))
                {     
                    updtOwners.add(cs);  
                    updtCases.add(cs.ID);
                    CaseServices.updatedCases.add(cs.Id); 
                }   
            }           
        }
        
         
        if(updtOwners != null){
            caseHistUpdts = [Select ID ,
                                Case__C,
                                Handed_Off__c 
                                from Case_Owner_History__c
                                where Case__c in:updtCases and 
                                                Handed_Off__c = null ] ;                                                    
        }
        
        for(Case_Owner_History__c csHist : caseHistUpdts){
            csHist.Handed_Off__c = System.now() ;           
        }
    

        // get list of all users
        List<User> userList = [Select id,
                                    name
                                    From User];
        
        // get list of all queues
        List<Group> queueList = [Select id,
                                    name
                                    From Group];
        
        
        // add Case Owner History records
        for(Case cs: updtOwners) {                  
            
            if(cs.OwnerID != null)  {
                
                String ownerName='';
                // find owner
                for ( User usr : userList ) {
                    if (usr.id == cs.OwnerId) {
                        ownerName = usr.name;
                    }
                }
                
                // find queue
                for ( Group grp : queueList ) {
                    if ( grp.id == cs.OwnerId ) {
                        ownerName = grp.name;
                    }
                }
                
                
                Case_Owner_History__c csHist = new Case_Owner_History__c(
                                Case__c = cs.ID, 
                                Owner_Name__c = ownerName,
                                Owner_Id__c = cs.ownerId,
                                Received__c = System.now() 
                                );
                                
                caseHistInsrts.add(csHist);                       
            }
        }
        
       
        if(caseHistInsrts.size()>0) {
            try{
                insert caseHistInsrts;          
            }catch (DMLException e ){ 
                    System.debug('Exception: '+e.getDmlMessage(0)); 
            } 
        }
        try{
            update caseHistUpdts ;      
        }catch (DMLException e ){ 
            System.debug('Exception: '+e.getDmlMessage(0)); 
        } 
    }
    
    
    public static void deleteCaseOwnerChange(Map<ID,Case> oldMap ){
        if(oldMap != null){                       
            List<Case_Owner_History__c> caseHistDeletes = [Select ID 
                                                            from Case_Owner_History__c 
                                                            where Case__c in: oldMap.keyset() ];   
            if(caseHistDeletes.size() > 0) delete caseHistDeletes; 
        }
    }   
    
    
    public static void unDeleteCaseOwnerChange(Map<ID,Case> newMap ){
        if(newMap != null) {
            List<Case_Owner_History__c> caseHistUnDeletes = [Select ID 
                                                                from Case_Owner_History__c 
                                                                where Case__c in:newMap.keySet() ALL ROWS];
            if(caseHistUnDeletes.size() > 0) undelete caseHistUnDeletes;
        } 
    }   

}