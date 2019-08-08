public without sharing class UpdatedEmailMessageServices {
  
  
  private List<EmailMessage> EmailMsgLst;
  
  public static String BILLING_FROM_KEY_WORD_1 = 'billing';
  public static String COLLECTIONS_EMAIL_KEY_WORD = 'phsscollections'; 
  public static String BILLING_ADJUSTMENT_EMAIL_KEY_WORD = 'adjustment'; 
  public static String STATUS_FOLLOW_UP_EMAIL = 'Follow Up - New Email';
  public static String RCOLLECTIONS_EMAIL_KEY_WORD = 'retailcollections';
  
  //CASE RECORD TYPES Values from the Helper Method.
  public static Id salesCaseReadOnlyRT = getCaseRtIdByName('Sales Case Read Only'); 
  public static Id salesCaseRT = getCaseRtIdByName('Sales Case'); 
  public static Id serviceCaseReadOnlyRT = getCaseRtIdByName('Service Case Read Only');
  public static Id serviceCaseRT = getCaseRtIdByName('Service Cases');
  
/*********************************************************************************************/
/************************************PHSS COLLECTIONS*****************************************/
  
  public static void updateCaseWhenEmailIsRepliedCollections(Map<ID, EmailMessage> newMap ){
      Boolean CaseStatusFlag;//Used to set status as 'Follow Up - New Email'
      System.Debug('COLLECTIONS_EMAIL_KEY_WORD - phsscollections');
      Set<Id> caseIds = new Set<Id>();
      try {
          if(newMap != null) {
              for(EmailMessage em : newMap.values()) {
                  System.Debug('TOAddress in updateCaseWhenEmailIsReplied: ' + em.ToAddress);
                  System.Debug('em.ParentId :'+em.ParentId);
                  System.debug('em.Incoming :'+em.Incoming);
                  CaseStatusFlag = false;
                  if (em.Status == '0' // 0 is New.
                  && em.Incoming == true 
                  && em.ParentId != null &&
                  em.ToAddress.contains(COLLECTIONS_EMAIL_KEY_WORD) ){
                      CaseStatusFlag = true;
                      caseIds.add(em.parentId);
                  }          
              }      
          }
          system.debug(+salesCaseReadOnlyRT);
          if(!caseIds.isEmpty()){
              Set<Id> ExistingcaseIds = new Set<Id>();
              Set<Id> NewcaseIds = new Set<Id>();
              EmailMessageServiceQueues__c CSQueues = EmailMessageServiceQueues__c.getValues('Collections');
              system.debug('CSQueues.ID :'+CSQueues.Queue_Id__c);
              
              Set<String> ownerIdSet = new Set<String>(); //To capture the Case Owner.
              for(Case casesTemp :[Select Id,ownerId,AutoEmailSentDeleted__c,Status, (Select Id, Incoming, Subject From EmailMessages ORDER BY CreatedDate DESC) FROM Case Where Id in :caseIds]){
                  System.Debug('*** casesTemp.EmailMessages: ' + casesTemp.EmailMessages.size());
                  // New Email OR Existing Email.
                  if ((casesTemp.EmailMessages.size() <= 2 && casesTemp.AutoEmailSentDeleted__c == false) || (casesTemp.EmailMessages.size() <= 1 && casesTemp.AutoEmailSentDeleted__c == true)) { 
                      system.debug(+casesTemp.EmailMessages[0].subject.contains('Auto Reply:'));
                      system.debug(+casesTemp.EmailMessages[1].subject.contains('Auto Reply:'));
                      system.debug(+casesTemp.EmailMessages[1].id);
                      system.debug(+casesTemp.EmailMessages[0].id);
                                            
                      if(casesTemp.EmailMessages.size() == 2 && (!casesTemp.EmailMessages[0].subject.contains('Auto Reply:') && (!casesTemp.EmailMessages[1].subject.contains('Auto Reply:')))){
                          system.debug('MANUALLY CREATED CASE');
                          ExistingcaseIds.add(casesTemp.id);
                          ownerIdSet.add(casesTemp.ownerId); 
                      }else                      
                          NewcaseIds.add(casesTemp.id);
                  }else{
                      ExistingcaseIds.add(casesTemp.id);
                      ownerIdSet.add(casesTemp.ownerId);    
                  }  
              }
              
              Map<String,List<GroupMember>> owneQueueMap = new Map<String,List<GroupMember>>();
              System.debug('ownerIdSet : '+ownerIdSet);
              if(!ownerIdSet.isEmpty()){
                  for(GroupMember gm:[select Group.Id, Group.Name,UserOrGroupId from GroupMember where UserOrGroupId in: ownerIdSet AND Group.Type = 'Queue']){
                      if(owneQueueMap!=null && owneQueueMap.get(gm.UserOrGroupId)!=null){
                          List<GroupMember> tempList=owneQueueMap.get(gm.UserOrGroupId);
                          tempList.add(gm);
                          owneQueueMap.put(gm.UserOrGroupId,tempList); 
                      }else{
                         owneQueueMap.put(gm.UserOrGroupId,new List<GroupMember>{gm}); 
                      }
                  }
              }
              List<Case> casesToUpdate = new List<Case>();
              
              System.Debug('phsscollections EMAIL CASE UPDATE');
              System.debug('caseIds :'+caseIds);
              for(Case ca : [select id, status, Type, RecordTypeId,Collections_Email__c, RecordType.Name, Last_Case_Update_Time_Date__c, OwnerId FROM Case c WHERE id IN :caseIds]){        
                  System.Debug('*** now changing status to follow up email in replied email rule');
                  System.debug('owneQueueMap1 : '+owneQueueMap);
                  System.debug('cNew.OwnerId1 : '+ca.OwnerId);
                  //Customer’s reply is routed to the COLLECTIONS QUEUE (or the user that sent the email if they are in the Collections Queue).
                  Id ownerId=CSQueues.Queue_Id__c; //Getting Id of Collection Queue from Custom Setting.
                  if(ExistingcaseIds.contains(ca.id)){
                      system.debug('EXISTING CASE');
                      if(owneQueueMap!=null && owneQueueMap.get(ca.OwnerId)!=null && owneQueueMap.get(ca.OwnerId).size()>0){              
                          if(owneQueueMap.get(ca.OwnerId)[0].Group.Name=='Collections'){
                              ownerId=ca.OwnerId;
                          }
                      }
                  }else if(NewcaseIds.contains(ca.id)){
                      system.debug('NEW CASE');
                      CaseStatusFlag = false; //New Case - Set status as New Assigned
                      ca.Collections_Email__c = true;
                      
                  }         
              ca.OwnerId = ownerId;
              system.debug('ca.status :'+ca.status);
              
              if(ca.status.contains('Closed')){
                  ca.OwnerId = CSQueues.Queue_Id__c;
                  system.debug('ca.RecordTypeId :'+ca.RecordTypeId);
                  if (ca.RecordTypeId == salesCaseReadOnlyRT) ca.RecordTypeId = serviceCaseRT;
                  if (ca.RecordTypeId == serviceCaseReadOnlyRT) ca.RecordTypeId = serviceCaseRT;
              }else{
                  if (ca.RecordTypeId == salesCaseReadOnlyRT) ca.RecordTypeId = serviceCaseRT;
                  if (ca.RecordTypeId == salesCaseRT) ca.RecordTypeId = serviceCaseRT;
              }
          
              system.debug('Email Message CaseStatusFlag :'+CaseStatusFlag);
              if(CaseStatusFlag){
                  ca.Status = STATUS_FOLLOW_UP_EMAIL;
              }
              ca.Type = 'Invoicing';
              //ca.origin = 'Email'; 
              //ca.Last_Case_Update_Time_Date__c = datetime.now();Updating through the WF.
              casesToUpdate.add(ca);
            }
            
            system.debug(+casesToUpdate);
            if(!casesToUpdate.isEmpty()){
                try {
                    system.debug('CASE UPDATE FROM COLLECTIONS_EMAIL_KEY_WORD - phsscollections');
                    update casesToUpdate;
                     
                } catch (DMLException e ){ 
                 ExLog.log(e);
                } 
            }
        }
    }catch (Exception ex) {
      ExLog.log(ex);
      String ErrorMessage = ex.getMessage();
      
    }
  }
/*********************************************************************************************/
/**************************************BILLING************************************************/
  
  public static void updateCaseWhenEmailIsRepliedBilling(Map<ID, EmailMessage> newMap ){
      System.Debug('BILLING_FROM_KEY_WORD_1 - billing');
      Boolean CaseStatusFlag;//Used to set status as 'Follow Up - New Email'
      Boolean AssignOwnerFlag;//Used to not to assign User.
      Set<Id> caseIds = new Set<Id>();
      Map<Id, EmailMessage> caseToEmailMessageMap = new Map<Id, EmailMessage>();
      try {
          if(newMap != null) {
              for(EmailMessage em : newMap.values()) {
                  System.Debug('*** TOAddress in billing: ' + em.ToAddress);
                  CaseStatusFlag = false;
                  if (em.Status == '0' // 0 is New
                  && em.Incoming == true 
                  && em.ParentId != null &&
                  em.ToAddress.contains(BILLING_FROM_KEY_WORD_1)){
                      CaseStatusFlag = true;
                      caseIds.add(em.parentId);
                      caseToEmailMessageMap.put(em.ParentId, em);
                  }         
              }      
          }
          if(!caseIds.isEmpty()){
              Set<Id> ExistingcaseIds = new Set<Id>();
              Set<Id> NewcaseIds = new Set<Id>();
              EmailMessageServiceQueues__c CSQueuesCOEB = EmailMessageServiceQueues__c.getValues('Finance COE/Billing');
              
              system.debug('CSQueues.ID :'+CSQueuesCOEB.Queue_Id__c);
              List<EmailMessageServiceQueues__c> CSQueueId = EmailMessageServiceQueues__c.getall().values();
              Set<Id> IRTQueueId = new Set<Id>();
              
              for(EmailMessageServiceQueues__c loopa: CSQueueId){
                  if(loopa.IRT__c)
                  IRTQueueId.add(Id.valueOf(loopa.Queue_Id__c));
              }
              system.debug('IRTQueueId :'+IRTQueueId);
                           
              Set<String> ownerIdSet=new Set<String>(); //To capture the Case Owner.
              for(Case casesTemp :[Select Id,ownerId,AutoEmailSentDeleted__c,Status, (Select Id, Incoming, Subject From EmailMessages ORDER BY CreatedDate DESC) FROM Case Where Id in :caseIds]){
                  System.Debug('*** casesTemp.EmailMessages: ' + casesTemp.EmailMessages.size());
                  // New Email OR Existing Email.
                  if ((casesTemp.EmailMessages.size() <= 2 && casesTemp.AutoEmailSentDeleted__c == false) || (casesTemp.EmailMessages.size() <= 1 && casesTemp.AutoEmailSentDeleted__c == true)) { 
                      if(casesTemp.EmailMessages.size() == 2 && (!casesTemp.EmailMessages[0].subject.contains('Auto Reply:') && (!casesTemp.EmailMessages[1].subject.contains('Auto Reply:')))){
                          system.debug('MANUALLY CREATED CASE');
                          ExistingcaseIds.add(casesTemp.id);
                          ownerIdSet.add(casesTemp.ownerId); 
                      }else                      
                          NewcaseIds.add(casesTemp.id);
                  }else{
                      ExistingcaseIds.add(casesTemp.id);
                      ownerIdSet.add(casesTemp.ownerId);    
                  }
              }
              Map<String,List<GroupMember>> owneQueueMap=new Map<String,List<GroupMember>>();
              System.debug('ownerIdSet : '+ownerIdSet);
              //To figure out User belongs to which Queue.
              if(!ownerIdSet.isEmpty()){
                  for(GroupMember gm:[select Group.Id, Group.Name,UserOrGroupId from GroupMember where UserOrGroupId in: ownerIdSet AND Group.Type = 'Queue' AND Group.Id IN: IRTQueueId]){
                      if(owneQueueMap!=null && owneQueueMap.get(gm.UserOrGroupId)!=null){
                          List<GroupMember> tempList=owneQueueMap.get(gm.UserOrGroupId);
                          tempList.add(gm);
                          owneQueueMap.put(gm.UserOrGroupId,tempList); 
                      }else{
                         owneQueueMap.put(gm.UserOrGroupId,new List<GroupMember>{gm}); 
                      }
                      system.debug('INSIDE FOR LOOP :'+gm.Group.Name);
                  }
                  system.debug('owneQueueMap :'+owneQueueMap);
              }
              
              List<Case> casesToUpdate = new List<Case>();
               
              System.Debug('billing EMAIL CASE UPDATE');
              for(Case ca : [select id, subject, status, Type, RecordTypeId, RecordType.Name, Last_Case_Update_Time_Date__c, OwnerId FROM Case c WHERE id IN :caseIds]){        
                  System.Debug('*** now changing status to follow up email in replied email rule');
                  //Customer’s reply is routed to the FinanceCOEBilling QUEUE.
                  Id ownerId;
                  AssignOwnerFlag = true;
                  if(ExistingcaseIds.contains(ca.id)){
                      System.debug('owneQueueMap1 : '+owneQueueMap);
                      System.debug('cNew.OwnerId1 : '+ca.OwnerId);                  
                      //Setting the Owner for the Case if following criteria matches.
                      //If the User is a member of Finance COE/Billing Queue, Case is assigned to him/her.
                      //OR If the User is a member of any IRT Queues, it is been assigned to their Queue. 
                      ownerId=CSQueuesCOEB.Queue_Id__c;
                      if( owneQueueMap!=null && owneQueueMap.get(ca.OwnerId)!=null && owneQueueMap.get(ca.OwnerId).size()==1){
                          if(owneQueueMap.get(ca.OwnerId)[0].Group.Name == 'Finance COE/Billing'){
                                ownerId = ca.OwnerId;
                          }else{
                                ownerId = owneQueueMap.get(ca.OwnerId)[0].Group.Id; // Onwer - Queue
                               }
                      }         
         
                  }else if(NewcaseIds.contains(ca.id)){
                      EmailMessage em = caseToEmailMessageMap.get(ca.id);
                      system.debug('Email Message'+em);
                      system.debug('NEW BILLING CASE');
                      CaseStatusFlag = false;
                      AssignOwnerFlag = false;
                      if(String.isNotBlank(em.Subject) && 
                      (em.Subject.toLowerCase().contains('misdirected rdc deposit') ||
                      em.Subject.toLowerCase().contains('ach payment detail') ||
                      em.Subject.toLowerCase().contains('ach payment request') ||
                      em.Subject.toLowerCase().contains('mad') ||
                      em.Subject.toLowerCase().contains('bos request') ||
                      em.Subject.toLowerCase().contains('aquatics') ||
                      em.Subject.toLowerCase().contains('special inv') ||
                      em.Subject.toLowerCase().contains('voice message') ||
                      em.Subject.toLowerCase().contains('voicemail')
                       )){
                          system.debug('SUBJECT MATCHED');
                          if ((String.isNotBlank(em.FromAddress) &&
                              em.FromAddress.equalsIgnoreCase('voicemessage@unityphone.com') ) ||
                              em.Subject.toLowerCase().contains('voice message') || 
                              em.Subject.toLowerCase().contains('voicemail') ) {                            
                                    ca.Origin = 'Voicemail';
                                    //Owner is Assigned using Assignment Rule.                            
                          }else{
                              ca.Origin = 'Email';
                              
                              //Owner is Assigned using Assignment Rule.
                          }
                  }/*else{
                      system.debug('SUBJECT NOT MATCHED');
                      ca.Billing_Default_Queue__c = true;
                      AssignOwnerFlag = true;
                      OwnerId = CSQueuesCOEB.Queue_Id__c;                     
                      //Owner is Assigned using Assignment Rule.     
                  }*/
                  }
                  system.debug('ca.status :'+ca.status);
                  system.debug('owneQueueMap :'+owneQueueMap);
                  if(ca.status.contains('Closed')){
                      AssignOwnerFlag = true;
                      if(owneQueueMap.size() > 0){
                          if(owneQueueMap.get(ca.OwnerId).size() == 1){
                              system.debug(+owneQueueMap.get(ca.OwnerId)[0].Group.Id);
                              ownerId = owneQueueMap.get(ca.OwnerId)[0].Group.Id;
                          }
                      }else{
                          ownerId = CSQueuesCOEB.Queue_Id__c;
                      }
                      system.debug('ca.RecordTypeId :'+ca.RecordTypeId);
                      if (ca.RecordTypeId == salesCaseReadOnlyRT) ca.RecordTypeId = serviceCaseRT;
                      if (ca.RecordTypeId == serviceCaseReadOnlyRT) ca.RecordTypeId = serviceCaseRT;
                  }else{
                      if (ca.RecordTypeId == salesCaseReadOnlyRT) ca.RecordTypeId = serviceCaseRT;
                      if (ca.RecordTypeId == salesCaseRT) ca.RecordTypeId = serviceCaseRT;
                  }
                  if(AssignOwnerFlag)
                      ca.OwnerId = ownerId;
                  if(CaseStatusFlag)
                      ca.Status = STATUS_FOLLOW_UP_EMAIL;
                  //ca.Last_Case_Update_Time_Date__c = datetime.now();Updating through the WF.                  
                  ca.Type = 'Invoicing';
                  casesToUpdate.add(ca);
              }
              if(!casesToUpdate.isEmpty()){
                  try {
                      system.debug('CASE UPDATE FROM BILLING_FROM_KEY_WORD_1 - billing');
                      update casesToUpdate; 
                  } catch (DMLException e ){ 
                      ExLog.log(e);
                  } 
              }
          }
      }catch (Exception ex) {
      ExLog.log(ex);
      }
  }
/*********************************************************************************************/
/**************************************ADJUSTMENTS********************************************/
  
  public static void updateCaseWhenEmailIsRepliedAdjustment(Map<ID, EmailMessage> newMap ){
      System.Debug('BILLING_ADJUSTMENT_EMAIL_KEY_WORD - adjustment');
      Boolean CaseStatusFlag;
      Set<Id> caseIds = new Set<Id>();
      try {
          if(newMap != null) {
              for(EmailMessage em : newMap.values()) {
                  System.Debug('*** TOAddress in adjustment: ' + em.ToAddress);
                  CaseStatusFlag = false;
                  if (em.Status == '0' // 0 is New
                      && em.Incoming == true 
                      && em.ParentId != null &&
                      em.ToAddress.contains(BILLING_ADJUSTMENT_EMAIL_KEY_WORD) ){
                          CaseStatusFlag = true;
                          caseIds.add(em.parentId);
                  }          
              }      
          }
          if(!caseIds.isEmpty()){
              Set<Id> ExistingcaseIds = new Set<Id>();
              Set<Id> NewcaseIds = new Set<Id>();
              EmailMessageServiceQueues__c CSQueues = EmailMessageServiceQueues__c.getValues('Finance COE/Billing');
              EmailMessageServiceQueues__c FinanceRTC = EmailMessageServiceQueues__c.getValues('Finance COE - Ready to Close');
              system.debug('CSQueues.ID :'+CSQueues.Queue_Id__c);
              Set<String> ownerIdSet=new Set<String>(); 
              for(Case casesTemp :[Select Id,ownerId,AutoEmailSentDeleted__c,Status, (Select Id, Incoming, Subject From EmailMessages ORDER BY CreatedDate DESC) FROM Case Where Id in :caseIds]){
                  System.Debug('*** casesTemp.EmailMessages: ' + casesTemp.EmailMessages.size());
                  // New Email OR Existing Email.
                  if ((casesTemp.EmailMessages.size() <= 2 && casesTemp.AutoEmailSentDeleted__c == false) || (casesTemp.EmailMessages.size() <= 1 && casesTemp.AutoEmailSentDeleted__c == true)) { 
                      if(casesTemp.EmailMessages.size() == 2 && (!casesTemp.EmailMessages[0].subject.contains('Auto Reply:') && (!casesTemp.EmailMessages[1].subject.contains('Auto Reply:')))){
                          system.debug('MANUALLY CREATED CASE');
                          ExistingcaseIds.add(casesTemp.id);
                          ownerIdSet.add(casesTemp.ownerId); 
                      }else                      
                          NewcaseIds.add(casesTemp.id);
                  }else{
                      ExistingcaseIds.add(casesTemp.id);
                      ownerIdSet.add(casesTemp.ownerId);    
                  }   
              }
    
              Map<String,List<GroupMember>> owneQueueMap=new Map<String,List<GroupMember>>();
              System.debug('ownerIdSet : '+ownerIdSet);
              /*
              if(!ownerIdSet.isEmpty()){
                  for(GroupMember gm:[select Group.Id, Group.Name,UserOrGroupId from GroupMember where UserOrGroupId in: ownerIdSet AND Group.Type = 'Queue']){
                      if(owneQueueMap!=null && owneQueueMap.get(gm.UserOrGroupId)!=null){
                          List<GroupMember> tempList=owneQueueMap.get(gm.UserOrGroupId);
                          tempList.add(gm);
                          owneQueueMap.put(gm.UserOrGroupId,tempList); 
                      }else{
                         owneQueueMap.put(gm.UserOrGroupId,new List<GroupMember>{gm}); 
                      }
                  }
              }
              */
              List<Case> casesToUpdate = new List<Case>();
          
              System.Debug('adjustment EMAIL CASE UPDATE');
              for(Case ca : [select id, status, Type, RecordTypeId, RecordType.Name, Last_Case_Update_Time_Date__c, OwnerId FROM Case c WHERE id IN :caseIds]){        
                  System.Debug('*** now changing status to follow up email in replied email rule');
                  //System.debug('owneQueueMap1 : '+owneQueueMap);
                  System.debug('cNew.OwnerId1 : '+ca.OwnerId);
                  //Customer’s reply is routed to the FinanceCOEBilling QUEUE.
                  Id ownerId=CSQueues.Queue_Id__c;
                  /*if( owneQueueMap!=null && owneQueueMap.get(ca.OwnerId)!=null && owneQueueMap.get(ca.OwnerId).size()>0){              
                      if(owneQueueMap.get(ca.OwnerId)[0].Group.Name=='Finance COE/Billing'){
                          ownerId=ca.OwnerId;
                      }
                  }*/
                  if(ExistingcaseIds.contains(ca.id)){
                  if(FinanceRTC.Queue_Id__c == ca.OwnerId){
                      system.debug('FinanceRTC.Queue_Id__c :'+FinanceRTC.Queue_Id__c);
                      ownerId = FinanceRTC.Queue_Id__c;
                  }
                  }else if(NewcaseIds.contains(ca.id)){
                      CaseStatusFlag = false;//Status = New.
                      //owner is Finance COE/Billing.
                      ca.Adjustment_Email__c = true;                       
                      ownerId=CSQueues.Queue_Id__c;
                  }         
                  //Below code commented by Sudhir to address Case Routing issues - 13th Apr 2017
                  //ca.OwnerId = ownerId;
                  system.debug('ca.OwnerID:'+ca.OwnerId+':ownerId:'+ownerId);
                  system.debug('ca.status :'+ca.status);
                  if(ca.status.contains('Closed')){
                      system.debug('ca.RecordTypeId :'+ca.RecordTypeId);
                      if (ca.RecordTypeId == salesCaseReadOnlyRT) ca.RecordTypeId = serviceCaseRT;
                      if (ca.RecordTypeId == serviceCaseReadOnlyRT) ca.RecordTypeId = serviceCaseRT;
                  }else{
                      if (ca.RecordTypeId == salesCaseReadOnlyRT) ca.RecordTypeId = serviceCaseRT;
                      if (ca.RecordTypeId == salesCaseRT) ca.RecordTypeId = serviceCaseRT;
                  }
                  if(CaseStatusFlag)
                      ca.Status = STATUS_FOLLOW_UP_EMAIL;
                  ca.Type = 'Invoicing';
                  //ca.Last_Case_Update_Time_Date__c = datetime.now();Updating through the WF.
                  casesToUpdate.add(ca);
              }
              
          
              if(!casesToUpdate.isEmpty()){
                  try {
                      system.debug('CASE UPDATE FROM BILLING_ADJUSTMENT_EMAIL_KEY_WORD - adjustment');
                      update casesToUpdate; 
                  } catch (DMLException e ){ 
                      ExLog.log(e);
                  } 
              }
          }
      }catch (Exception ex) {
          ExLog.log(ex);
      }
  }
  
  
/*********************************************************************************************/ 
/*********************************RETAIL COLLECTIONS******************************************/
  
  public static void updateCaseWhenEmailIsRepliedRetailCollections(Map<ID, EmailMessage> newMap ){
      System.Debug('RCOLLECTIONS_EMAIL_KEY_WORD - retailcollections');
      Boolean CaseStatusFlag;
      Set<Id> caseIds = new Set<Id>();
      try {
          if(newMap != null) {
              for(EmailMessage em : newMap.values()) {
              System.Debug('*** TOAddress in retailcollections: ' + em.ToAddress);
              CaseStatusFlag = false;
                  if (em.Status == '0' // 0 is New
                  && em.Incoming == true 
                  && em.ParentId != null &&
                  em.ToAddress.contains(RCOLLECTIONS_EMAIL_KEY_WORD) ){
                      CaseStatusFlag = true;
                      caseIds.add(em.parentId);
                  }          
              }      
          }
          if(!caseIds.isEmpty()){
              Set<String> ownerIdSet=new Set<String>(); 
              Set<Id> ExistingcaseIds = new Set<Id>();
              Set<Id> NewcaseIds = new Set<Id>();
              
              for(Case casesTemp :[Select Id,ownerId,AutoEmailSentDeleted__c,Status, (Select Id, Incoming, Subject From EmailMessages ORDER BY CreatedDate DESC) FROM Case Where Id in :caseIds]){
                  System.Debug('*** casesTemp.EmailMessages: ' + casesTemp.EmailMessages.size());
                  // New Email OR Existing Email.
                  if ((casesTemp.EmailMessages.size() <= 2 && casesTemp.AutoEmailSentDeleted__c == false) || (casesTemp.EmailMessages.size() <= 1 && casesTemp.AutoEmailSentDeleted__c == true)) { 
                      if(casesTemp.EmailMessages.size() == 2 && (!casesTemp.EmailMessages[0].subject.contains('Auto Reply:') && (!casesTemp.EmailMessages[1].subject.contains('Auto Reply:')))){
                          system.debug('MANUALLY CREATED CASE');
                          ExistingcaseIds.add(casesTemp.id);
                          ownerIdSet.add(casesTemp.ownerId); 
                      }else                      
                          NewcaseIds.add(casesTemp.id);
                  }else{
                      ExistingcaseIds.add(casesTemp.id);
                      ownerIdSet.add(casesTemp.ownerId);    
                  }   
              }
              /*
              Map<String,List<GroupMember>> owneQueueMap=new Map<String,List<GroupMember>>();
              System.debug('ownerIdSet : '+ownerIdSet);
              
              for(GroupMember gm:[select Group.Id, Group.Name,UserOrGroupId from GroupMember where UserOrGroupId in: ownerIdSet AND Group.Type = 'Queue']){
                  if(owneQueueMap!=null && owneQueueMap.get(gm.UserOrGroupId)!=null){
                      List<GroupMember> tempList=owneQueueMap.get(gm.UserOrGroupId);
                      tempList.add(gm);
                      owneQueueMap.put(gm.UserOrGroupId,tempList); 
                  }else{
                      owneQueueMap.put(gm.UserOrGroupId,new List<GroupMember>{gm}); 
                  }
              }*/
          
              List<Case> casesToUpdate = new List<Case>();
          
              EmailMessageServiceQueues__c CSQueues = EmailMessageServiceQueues__c.getValues('Retail Collections');
              system.debug('CSQueues.ID :'+CSQueues.Queue_Id__c);
              System.Debug('retailcollections EMAIL CASE UPDATE');

              for(Case ca : [select id, status, subject, Type, RecordTypeId, RecordType.Name, Last_Case_Update_Time_Date__c, OwnerId FROM Case c WHERE id IN :caseIds]){        
                  System.Debug('*** now changing status to follow up email in replied email rule');                    
                  
                  System.debug('cNew.OwnerId1 : '+ca.OwnerId);
                  //Customer’s reply is routed to the RetailCollection QUEUE.
                  Id ownerId=CSQueues.Queue_Id__c;
                  if(NewcaseIds.contains(ca.id)){
                      CaseStatusFlag = false;//Status = New.
                  }    
                  system.debug('ca.subject :'+ca.subject);
                  
                  if(!ca.subject.toLowerCase().contains('retail collections')){
                      //ca.subject = 'Retail Collections - '+ca.subject;
                      ca.Retail_Collection_Email__c = true;
                  }
                  ca.OwnerId = ownerId;
                  system.debug('ca.status :'+ca.status);
                  
                  if(ca.status.contains('Closed')){
                      system.debug('ca.RecordTypeId :'+ca.RecordTypeId);
                      if (ca.RecordTypeId == salesCaseReadOnlyRT) ca.RecordTypeId = salesCaseRT;
                      if (ca.RecordTypeId == serviceCaseReadOnlyRT) ca.RecordTypeId = serviceCaseRT;
                  }
                  
                  if(CaseStatusFlag)
                      ca.Status = STATUS_FOLLOW_UP_EMAIL;
                  ca.Type = 'Invoicing';
                  //ca.Last_Case_Update_Time_Date__c = datetime.now();Updating through the WF.
                  casesToUpdate.add(ca);
              }
              
              if(!casesToUpdate.isEmpty()){
                  try {
                      system.debug('CASE UPDATE FROM RCOLLECTIONS_EMAIL_KEY_WORD - retailcollections');
                      update casesToUpdate; 
                  } catch (DMLException e ){ 
                      ExLog.log(e);
                  } 
              }
          }
      }catch (Exception ex) {
          ExLog.log(ex);
      }
  }
  
/*********************************************************************************************/
/**************************************OTHERS********************************************/
  
  public static void updateCaseWhenEmailIsRepliedothers(Map<ID, EmailMessage> newMap ){
      System.Debug('OTHER EMAIL');
      Boolean CaseStatusFlag;
      Set<Id> caseIds = new Set<Id>();
      try {
          if(newMap != null) {
              for(EmailMessage em : newMap.values()) {
                  System.Debug('*** TOAddress in others: ' + em.ToAddress);
                  CaseStatusFlag = false;
                  if (em.Status == '0' // 0 is New
                      && em.Incoming == true 
                      && em.ParentId != null &&
                      !em.ToAddress.contains(BILLING_ADJUSTMENT_EMAIL_KEY_WORD) &&
                      !em.ToAddress.contains(BILLING_FROM_KEY_WORD_1) &&
                      !em.ToAddress.contains(COLLECTIONS_EMAIL_KEY_WORD) &&
                      !em.ToAddress.contains(RCOLLECTIONS_EMAIL_KEY_WORD)){
                          CaseStatusFlag = true;
                          caseIds.add(em.parentId);
                  }          
              }      
          }
          if(!caseIds.isEmpty()){
              EmailMessageServiceQueues__c CSQueues = EmailMessageServiceQueues__c.getValues('General Customer');
              Set<Id> ExistingcaseIds = new Set<Id>();
              Set<Id> NewcaseIds = new Set<Id>(); 
              for(Case casesTemp :[Select Id,ownerId,AutoEmailSentDeleted__c,Status, (Select Id, Incoming, Subject From EmailMessages ORDER BY CreatedDate DESC) FROM Case Where Id in :caseIds]){
                  System.Debug('*** casesTemp.EmailMessages: ' + casesTemp.EmailMessages.size());
                  // New Email OR Existing Email.
                  if ((casesTemp.EmailMessages.size() <= 2 && casesTemp.AutoEmailSentDeleted__c == false) || (casesTemp.EmailMessages.size() <= 1 && casesTemp.AutoEmailSentDeleted__c == true)) { 
                      if(casesTemp.EmailMessages.size() == 2 && (!casesTemp.EmailMessages[0].subject.contains('Auto Reply:') && (!casesTemp.EmailMessages[1].subject.contains('Auto Reply:')))){
                          system.debug('MANUALLY CREATED CASE');
                          ExistingcaseIds.add(casesTemp.id);                          
                      }else                      
                          NewcaseIds.add(casesTemp.id);
                  }else{
                      ExistingcaseIds.add(casesTemp.id);                         
                  }   
              }

              List<Case> casesToUpdate = new List<Case>();
          
              System.Debug('OTHERS EMAIL CASE UPDATE');
              for(Case ca : [select id, status, Type, RecordTypeId, Latest_Queue_Owner__c, RecordType.Name, Last_Case_Update_Time_Date__c, OwnerId FROM Case c WHERE id IN :caseIds]){        
                  System.Debug('*** now changing status to follow up email in replied email rule');
                  
                  System.debug('cNew.OwnerId1 : '+ca.OwnerId);
                  //Customer’s reply is routed to the General Customer QUEUE.
                  
                  Id ownerId = CSQueues.Queue_Id__c;
                  if(ExistingcaseIds.contains(ca.id)){
                      if(ca.Latest_Queue_Owner__c != null){                                           
                        ownerId = ca.Latest_Queue_Owner__c;// Update case owner Id to the latest previous queue owner through field.
                        system.debug('ownerId Queue:'+ownerId);
                    }else{
                        // Default to general customer queue
                        system.debug('ownerId Gen Cust :'+ownerId);
                    }
                  }else if(NewcaseIds.contains(ca.id)){
                      CaseStatusFlag = false;//Status = New.
                      //Default owner is General Customer.                       
                  }         
                  ca.OwnerId = ownerId;
                  system.debug('ca.status :'+ca.status);
                  
                  system.debug('ca.RecordTypeId :'+ca.RecordTypeId);
                  if (ca.RecordTypeId == salesCaseReadOnlyRT) ca.RecordTypeId = salesCaseRT;
                  if (ca.RecordTypeId == serviceCaseReadOnlyRT) ca.RecordTypeId = serviceCaseRT;
                  
                  if(CaseStatusFlag)
                      ca.Status = STATUS_FOLLOW_UP_EMAIL;                 
                  //ca.Last_Case_Update_Time_Date__c = datetime.now(); Updating through the WF.
                  casesToUpdate.add(ca);
              }
              
          
              if(!casesToUpdate.isEmpty()){
                  try {
                      system.debug('CASE UPDATE FROM OTHERS');
                      update casesToUpdate; 
                  } catch (DMLException e ){ 
                      ExLog.log(e);
                  } 
              }
          }
      }catch (Exception ex) {
          ExLog.log(ex);
      }
  }
    
  
/*********************************************************************************************/
//Helper method to get the Record Type Id's.  
  
  public static Id getCaseRtIdByName(String rtName){
    return Schema.SObjectType.Case.RecordTypeInfosByName.get(rtName).RecordTypeId;
  }      
}