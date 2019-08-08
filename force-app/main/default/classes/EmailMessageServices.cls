public without sharing class EmailMessageServices {
    
    public static String BILLING_FROM_KEY_WORD_1 = 'billing';
    public static String COLLECTIONS_EMAIL_KEY_WORD = 'collections';
    
    public static String STATUS_FOLLOW_UP_EMAIL = 'Follow Up - New Email';
    
    public static void billingRouting(Map<ID, EmailMessage> newMap ){
            
        System.Debug('*** in billingRouting rule...');
                
        try {
            if (newMap != null && newMap.size() > 0) {
                
                List<Case> casesNew = new List<Case>();
                List<Case> casesReplied = new List<Case>();
                
                /* Id = Case Id, EmailMessage -> Message corresponding to case */
                Map<Id, EmailMessage> caseToEmailMessageMap = new Map<Id, EmailMessage>();
                List<Case> casesToUpdate = new List<Case>();
                
                Set<Id> casesToCheck = new Set<Id>();
                
                for (EmailMessage em :newMap.values()) {            
                    if (em.ParentId != null && em.Status == '0') { //em.Status == New
                        casesToCheck.add(em.ParentId);
                        caseToEmailMessageMap.put(em.ParentId, em);
                    }
                }
                
                /* Query for all cases from EmailMessages to determine if this is the first email which creates the case or a subsequent email as an  reply */
                List<Case> casesTemp = [Select Id, (Select Id From EmailMessages limit 2) FROM Case Where Id in :casesToCheck]; 

                for (Case cTemp :casesTemp) { // Determine cases with 1 or many email message
                    
                    System.Debug('*** cTemp.EmailMessages: ' + cTemp.EmailMessages.size());
                    
                    if (cTemp.EmailMessages.size() <= 2) { // New Email
                        casesNew.add(new Case(Id = cTemp.Id));
                    } else {
                        casesReplied.add(new Case(Id = cTemp.Id));
                    }
                }
                
                /* START - Process New Cases as result of Emai-To-Case email - START */
                for (Case cNew :casesNew) {
                    
                    EmailMessage em = caseToEmailMessageMap.get(cNew.Id);
                    System.Debug('*** emailFrom: ' + em.ToAddress);
                    
                    if (em != null && String.isNotBlank(em.Subject) && em.ToAddress.contains(BILLING_FROM_KEY_WORD_1) && 
                                                        
                                                               (em.Subject.toLowerCase().contains('misdirected rdc deposit') ||
                                                                em.Subject.toLowerCase().contains('ach payment detail') ||
                                                                em.Subject.toLowerCase().contains('ach payment request') ||
                                                                em.Subject.toLowerCase().contains('mad') ||
                                                                em.Subject.toLowerCase().contains('bos request') ||
                                                                em.Subject.toLowerCase().contains('aquatics') ||
                                                                em.Subject.toLowerCase().contains('special inv') ||
                                                                em.Subject.toLowerCase().contains('voice message') ||
                                                                em.Subject.toLowerCase().contains('voicemail')
                            )) {
                            
                        System.Debug('*** SUBJECT MATCHED');
                        System.Debug('*** NOW updating case 1');
                        //Case caseTemp = new Case(Id = em.parentId);
                        
                        if ((String.isNotBlank(em.FromAddress) && em.FromAddress.equalsIgnoreCase('voicemessage@unityphone.com') ) ||
                                em.Subject.toLowerCase().contains('voice message') || em.Subject.toLowerCase().contains('voicemail') ) {
                            
                            cNew.Origin = 'Voicemail';
                            //TODO: remove hard coded value and expose via custom setting
                            cNew.OwnerId = '00Gd0000000SdP4'; // Finance COE - Queue
                        } else {
                            cNew.Origin = 'Email';
                        }
                        
                        System.Debug('*** UPDATING FIELDS...');
                        cNew.Subject = em.Subject;
                        cNew.Type = 'Invoicing';
                        
                        casesToUpdate.add(cNew);
                        
                    } else if (em.ToAddress.contains(BILLING_FROM_KEY_WORD_1)) { // IF SUBJECT Does not match
                            
                        System.Debug('*** SUBJECT DID NOT MATCH, updating fields...');
                        System.Debug('*** NOW updating case 1');

                        //TODO: Temporary fix, come up with more elequent fix
                        //cNew.Billing_Default_Queue__c = true;
                        cNew.Subject = em.Subject;
                        cNew.Type = 'Invoicing';
                        cNew.Origin = 'Email';
                        //TODO: remove hard coded queue id and replace by custom setting
                        //cNew.OwnerId = '00Gd0000000SdP6';//Finance COE / Billing - Queue
                        
                        casesToUpdate.add(cNew);
                    } else if (em.ToAddress.contains(COLLECTIONS_EMAIL_KEY_WORD)) {
                 
                        cNew.Collections_Email__c = true;
                        cNew.Subject = em.Subject;
                        cNew.Type = 'Invoicing';
                        cNew.Origin = 'Email';
                        casesToUpdate.add(cNew);
                    }   
                }
                /* END Process New Cases as result of Emai-To-Case email END */

                for (Case cReplied :casesReplied) {
                    
                    EmailMessage em = caseToEmailMessageMap.get(cReplied.Id);
                    
                    System.Debug('*** in billing rule em.Status: ' + em.Status);
                    
                    if (em != null && (em.ToAddress.contains(BILLING_FROM_KEY_WORD_1) || em.ToAddress.contains(COLLECTIONS_EMAIL_KEY_WORD))) {
                        System.Debug('*** now changing status to follow up email in billing rule');
                        cReplied.Status = STATUS_FOLLOW_UP_EMAIL;
            
                        casesToUpdate.add(cReplied);
                    }
                }
                
                // Update Cases
                if (casesToUpdate != null && casesToUpdate.size() > 0) {
                    update casesToUpdate;
                }
            } 
        }catch (System.Exception ex) {
            System.Debug('*** Exception: ' + ex.getMessage());
            ExLog.log(ex);
        }
    }
    
    public static void updateCaseWhenEmailIsReplied(Map<ID, EmailMessage> newMap ){
        
        System.Debug('*** IN updateCaseWhenEmailIsReplied');
        
        Set<Id> caseIds = new Set<Id>();
        
        try {
            
            if(newMap != null) {
                
                for(EmailMessage em : newMap.values()) {
                    
                    System.Debug('*** TOAddress in updateCaseWhenEmailIsReplied: ' + em.ToAddress);
                    
                    if (em.Status == '0' // 0 is New
                            && em.Incoming == true 
                            && em.ParentId != null &&
                            !em.ToAddress.contains(BILLING_FROM_KEY_WORD_1) && !em.ToAddress.contains(COLLECTIONS_EMAIL_KEY_WORD) ){
                        
                        caseIds.add(em.parentId);
                    }                   
                }           
            }

            List<Case> casesToUpdate = new List<Case>();
            
            if(!caseIds.isEmpty()){
                
                System.Debug('*** NOW updating case 2');
                
                /*TODO: move to custom setting */
                Id salesCaseReadOnlyRT = getCaseRtIdByName('Sales Case Read Only');
                Id salesCaseRT = getCaseRtIdByName('Sales Case');
                Id serviceCaseReadOnlyRT = getCaseRtIdByName('Service Case Read Only');
                Id serviceCaseRT = getCaseRtIdByName('Service Cases');
                /*TODO: move to custom setting */
                // Get a map of Case id and its Queue Owner Id
                
                /*Changes made on 13thNov, CaseOwnerHistory Object Issue, Capturing the Last Queue Owner in the field Instead.
                Map<Id,Id> mCaseIdQueueOwnerId = getQueueOwnerIdForCases(caseIds);
                
                system.debug('\n**** mCaseIdQueueOwnerId is: ' + mCaseIdQueueOwnerId);
                */
                
                for(Case ca : [select id, status, Type, RecordTypeId, RecordType.Name, Latest_Queue_Owner__c, Last_Case_Update_Time_Date__c, OwnerId 
                                FROM Case c WHERE id IN :caseIds AND Type != null]){                
                    
                    System.Debug('*** now changing status to follow up email in replied email rule');
                    system.debug('ca.Latest_Queue_Owner__c :'+ ca.Latest_Queue_Owner__c);
                    ca.Status = STATUS_FOLLOW_UP_EMAIL;
                    ca.Last_Case_Update_Time_Date__c = datetime.now();
                    Id ownerId;
                    
                    if(ca.Latest_Queue_Owner__c != null){                                           
                        ownerId = ca.Latest_Queue_Owner__c;                 // Update case owner Id to the latest previous queue owner through field.
                        system.debug('ownerId Queue:'+ownerId);
                    }else{
                        ownerId = '00Gd0000000SYVN';                        // Default to general customer queue
                        system.debug('ownerId Gen Cust :'+ownerId);
                    }
                    /*Changes made on 13thNov, CaseOwnerHistory Object Issue, Capturing the Last Queue Owner in the field Instead.
                    Id ownerId = mCaseIdQueueOwnerId.get(ca.Id);        // Update case owner Id to the latest previous queue owner through map(Helper method).
                    if (ownerId == null) {
                        ownerId = '00Gd0000000SYVN';// Default to general customer queue
                    } 
                    */
                    ca.OwnerId = ownerId;
                    
                    if (ca.RecordTypeId == salesCaseReadOnlyRT) ca.RecordTypeId = salesCaseRT;
                    if (ca.RecordTypeId == serviceCaseReadOnlyRT) ca.RecordTypeId = serviceCaseRT;
                    
                    casesToUpdate.add(ca);
                }
            }
            
            if(!casesToUpdate.isEmpty()){
                try {
                    update casesToUpdate; 
                } catch (DMLException e ){ 
                    ExLog.log(e);
                } 
            }
        }catch (Exception ex) {
            ExLog.log(ex);
        }

    }
    
    public static Id getCaseRtIdByName(String rtName){
        return Schema.SObjectType.Case.RecordTypeInfosByName.get(rtName).RecordTypeId;
    }       
    
    /*
    *   Need to get a distinct list of Case Owner History. Only interested in Queue Owner.
    *
    */
    public static Map<Id, Id> getQueueOwnerIdForCases(Set<Id> caseIds){
        
        Set<Id> cIds = new Set<Id>();
        Map<Id, Id> mCaseIdOwnerId = new Map<Id, Id>();
        
        for (Case_Owner_History__c c : [Select Case__c, Owner_Id__c, CreatedDate 
                                        From Case_Owner_History__c WHERE Owner_Id__c LIKE '00G%' AND Case__c IN :caseIds
                                        ORDER BY CreatedDate DESC] ) {
            
            if(cIds.contains(c.Case__c) == false){
                cIds.add(c.Case__c);
                mCaseIdOwnerId.put(c.Case__c, c.Owner_Id__c);
            }                                   
                        
        }
        
        return mCaseIdOwnerId;
    }
}