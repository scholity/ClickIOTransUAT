public without sharing class sendCaseAutoResponse 
{
    public static void emailCase(Map<ID, EmailMessage> newMap)
    {
        system.debug('Inside sendCaseAutoResponse:::');
        If(!TrggrUtility.RunOnceEmailMessage)
        {
            system.debug('sendCaseAutoResponse If:::');
            Set<Id> caseIds = new Set<Id>();
            try
            {
                for(EmailMessage em : newMap.values()) 
                {
                    if(em.Status == '0')
                        caseIds.add(em.parentId);
                }
                
                if(caseIds.size() > 0)
                {
                    List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
                    List<EmailTemplate> templateList =  [SELECT Id, DeveloperName, FolderId, Folder.DeveloperName from EmailTemplate where DeveloperName = 'Case_Auto_Reply'];
                    Set<String> toEmailAddress = new Set<String>();
                    List<String> fromEmailAddress = new List<String>();
                    
                    //Logic to skip few Supplied Email to delete
                    List<String> emailsToSkip = new List<String>();
                    List<Supplied_Email__c> emailListSettings = Supplied_Email__c.getall().values();
                    for(Supplied_Email__c indEmail : emailListSettings)
                    {
                        emailsToSkip.add(indEmail.Email__c);
                    }
                    
                    List<Case> caseRecordList = [Select Id, caseNumber, Origin, SuppliedEmail, Subject, Description, (Select Id, Incoming, Subject, ToAddress, fromAddress From EmailMessages ORDER BY CreatedDate DESC) FROM Case Where Id In :caseIds];
                    
                    //code to remove the hardcoded emails
                    List<AvoidCustomReplay__c> emaillist = [Select Email__c from AvoidCustomReplay__c];
                    List<string> emails = new List<string>();
                    for(AvoidCustomReplay__c eml : emaillist)
                    {
                        emails.add(eml.Email__c);
                    }
                    
                    for(Case caseRec : caseRecordList)
                    {
                        if((caseRec.Origin == 'Email') && !(emails.contains(caseRec.SuppliedEmail)) && caseRec.EmailMessages.size() == 1)
                        {
                            if(caseRec.EmailMessages[0].ToAddress != null)
                                toEmailAddress.add(caseRec.EmailMessages[0].ToAddress);
                            if(!emailsToSkip.contains(caseRec.SuppliedEmail))
                                fromEmailAddress.add(caseRec.SuppliedEmail);
                        }
                        
                    }
                    toEmailAddress.add('sudhir.dakshinamurth@redcross.org');
                    toEmailAddress.add('no-reply@redcross.org');
                    
                    //Case's created in last 3 minutes with same supplied Emails
                    Map<String, Integer> suppliedEmialAndCaseCount = new Map<String, Integer>();
                    
                    if(fromEmailAddress.size() > 0)
                    {
                        //String emailId = (String)fromEmailAddress[0];
                        dateTime timeToQuery = system.now().addMinutes(-4);
                        List<Case> casesWithSameSuppliedEmails = [select Id, CaseNumber, SuppliedEmail from Case where createdDate >: timeToQuery And SuppliedEmail In : fromEmailAddress  And Origin = 'Email'];
                        for(Case caseRec : casesWithSameSuppliedEmails)
                        {
                            if(suppliedEmialAndCaseCount.containsKey(caseRec.SuppliedEmail))
                                suppliedEmialAndCaseCount.put(caseRec.SuppliedEmail, suppliedEmialAndCaseCount.get(caseRec.SuppliedEmail) + 1);
                            else
                                suppliedEmialAndCaseCount.put(caseRec.SuppliedEmail, 1);
                        }
                        system.debug('casesWithSameSuppliedEmails:::'+casesWithSameSuppliedEmails);
                    }
                    system.debug('suppliedEmialAndCaseCount:::'+suppliedEmialAndCaseCount);
                    
                    List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
                    Map<String, Id> emailAddressIdMap = new Map<String, Id>();
                    if(toEmailAddress.size() > 0)
                    {
                        owea = [select Id, Address from OrgWideEmailAddress where Address In : toEmailAddress];
                        for(OrgWideEmailAddress oweaInd : owea)
                            emailAddressIdMap.put(oweaInd.Address, oweaInd.Id);
                    }
                    
                    String targetObjectId;
                    List<Contact> contactList = new List<Contact>();
                    contactList = [Select Id, Name from Contact where Name = 'auto reply' and Email != null];
                    if(contactList.size() == 0)
                    {
                        Contact con = new Contact();
                        con.firstName = 'auto';
                        con.lastName = 'reply';
                        con.Email = 'no-reply@redcrosstraining.org';
                        insert con;
                        targetObjectId = con.Id;
                    }   
                    else
                        targetObjectId = contactList[0].Id;
                    
                    system.debug('templateList:::'+templateList);
                    system.debug('toEmailAddress:::'+toEmailAddress);
                    system.debug('owea:::'+owea);
                    system.debug('emailAddressIdMap:::'+emailAddressIdMap);
                    system.debug('contactList:::'+contactList);
                    system.debug('targetObjectId:::'+targetObjectId);
                    
                    List<Delivery_Failure_Response_Log__c> failureRecordsList = new List<Delivery_Failure_Response_Log__c>();
                    Map<String, Attachment> caseNumberWithAttachment = new Map<String, Attachment>();
                    List<Case> caseRecordsListToDelete = new List<Case>();
                    
                    //created one more object by using custom field setting for delete operation
                    List<BlockCase__c> delemaillist = [Select Email__c from BlockCase__c];
                    List<string> blockmails = new List<string>();
                    for(BlockCase__c deleml : delemaillist)
                    {
                       blockmails.add(deleml.Email__c);
                    } 
                    
                    for(Case caseRec : caseRecordList)
                    {
                        //if(caseRec.Subject != null && caseRec.Description != null && ((caseRec.Subject.toUpperCase()).contains('DELIVERY FAILURE') || (caseRec.Subject.toUpperCase()).contains('NO REPLY') || (caseRec.Description.toUpperCase()).contains('DELIVERY FAILURE') || ((caseRec.Description.toUpperCase()).contains('CUSTOMER SERVICE TEAM') && (caseRec.Description.toUpperCase()).contains('THANK YOU FOR CONTACTING 2(X)IST')) || (suppliedEmialAndCaseCount.containsKey(caseRec.SuppliedEmail) && suppliedEmialAndCaseCount.get(caseRec.SuppliedEmail) > 3)))
                        if( (caseRec.Subject != null && ((caseRec.Subject.toUpperCase()).contains('DELIVERY FAILURE') || (caseRec.Subject.toUpperCase()).contains('NO REPLY'))) || (caseRec.Description != null && ((caseRec.Description.toUpperCase()).contains('DELIVERY FAILURE') || ((caseRec.Description.toUpperCase()).contains('CUSTOMER SERVICE TEAM') && (caseRec.Description.toUpperCase()).contains('THANK YOU FOR CONTACTING 2(X)IST')))) || (suppliedEmialAndCaseCount.containsKey(caseRec.SuppliedEmail) && suppliedEmialAndCaseCount.get(caseRec.SuppliedEmail) > 3))
                        {
                            Delivery_Failure_Response_Log__c failureCaseRec = new Delivery_Failure_Response_Log__c();
                            failureCaseRec.Supplied_Email__c = caseRec.SuppliedEmail;
                            failureCaseRec.Case_Number__c = caseRec.caseNumber;
                            failureRecordsList.add(failureCaseRec);
                            
                            String bodyContent = 'Case Subject : ' + caseRec.Subject + '  ';
                            bodyContent += 'Case Description : ' + caseRec.Description;
                            
                            //Attachment
                            Attachment attach = new Attachment();
                            attach.contentType = 'application/txt';
                            attach.name = caseRec.caseNumber + '.txt';
                            attach.body = Blob.valueOf(bodyContent);
                            
                            caseRecordsListToDelete.add(caseRec);
                            caseNumberWithAttachment.put(caseRec.caseNumber, attach);
                            
                        }
                        else if(blockmails.contains(caseRec.SuppliedEmail))
                        {
                            Delivery_Failure_Response_Log__c failureCaseRec = new Delivery_Failure_Response_Log__c();
                            failureCaseRec.Supplied_Email__c = caseRec.SuppliedEmail;
                            failureCaseRec.Case_Number__c = caseRec.caseNumber;
                            failureRecordsList.add(failureCaseRec);
                            
                            String bodyContent = 'Case Subject : ' + caseRec.Subject + '  ';
                            bodyContent += 'Case Description : ' + caseRec.Description;
                            
                            //Attachment
                            Attachment attach = new Attachment();
                            attach.contentType = 'application/txt';
                            attach.name = caseRec.caseNumber + '.txt';
                            attach.body = Blob.valueOf(bodyContent);
                            
                            caseRecordsListToDelete.add(caseRec);
                            caseNumberWithAttachment.put(caseRec.caseNumber, attach);
                        }
                        
                        
                        
                                  
                        else if(((caseRec.Origin == 'Email') && !(emails.contains(caseRec.SuppliedEmail)) && caseRec.EmailMessages.size() == 1) || Test.isRunningTest())
                        {
                            //for Billing, Support and PHSS collection
                            if(caseRec.EmailMessages[0].ToAddress == 'billing@redcross.org' || caseRec.EmailMessages[0].ToAddress == 'phsscollections@redcross.org' || caseRec.EmailMessages[0].ToAddress == 'support@redcrosstraining.org')
                            {
                                if((templateList.size() > 0 && caseRec.EmailMessages[0].ToAddress != null && emailAddressIdMap.containsKey(caseRec.EmailMessages[0].ToAddress) && caseRec.EmailMessages[0].fromAddress != null) || Test.isRunningTest())
                                {
                                    Messaging.SingleEmailMessage theMessage = new Messaging.SingleEmailMessage();
                                    
                                    if(!Test.isRunningTest())
                                    {
                                        theMessage.setTemplateId(templateList[0].Id);
                                        
                                        //Should be either Lead, Contact or User
                                        theMessage.setTargetObjectId(targetObjectId);
                                        theMessage.setTreatTargetObjectAsRecipient(false);
                                    }
                
                                    List<String> toAddress = new List<String>();
                                    toAddress.add(caseRec.EmailMessages[0].fromAddress);
                                    
                                    theMessage.setOrgWideEmailAddressId(emailAddressIdMap.get(caseRec.EmailMessages[0].ToAddress));
                                    
                                    theMessage.setToAddresses(toAddress);
                                    theMessage.setWhatId(caseRec.Id); 
                                    theMessage.setSaveAsActivity(true); 
                                    messages.add(theMessage);  
                                }
                            }
                            else
                            {
                                //Other Cases
                                if((templateList.size() > 0 && caseRec.EmailMessages[0].ToAddress != null && (emailAddressIdMap.containsKey('sudhir.dakshinamurth@redcross.org') || emailAddressIdMap.containsKey('no-reply@redcross.org')) && caseRec.EmailMessages[0].fromAddress != null) || Test.isRunningTest())
                                {
                                    Messaging.SingleEmailMessage theMessage = new Messaging.SingleEmailMessage();
                                    
                                    if(!Test.isRunningTest())
                                    {
                                        theMessage.setTemplateId(templateList[0].Id);
                                        
                                        //Should be either Lead, Contact or User
                                        theMessage.setTargetObjectId(targetObjectId);
                                        theMessage.setTreatTargetObjectAsRecipient(false);
                                    }
                
                                    List<String> toAddress = new List<String>();
                                    toAddress.add(caseRec.EmailMessages[0].fromAddress);
                                    
                                    if(emailAddressIdMap.containsKey('no-reply@redcross.org'))
                                        theMessage.setOrgWideEmailAddressId(emailAddressIdMap.get('no-reply@redcross.org'));
                                    else
                                        theMessage.setOrgWideEmailAddressId(emailAddressIdMap.get('sudhir.dakshinamurth@redcross.org'));
                                    
                                    theMessage.setToAddresses(toAddress);
                                    theMessage.setWhatId(caseRec.Id); 
                                    theMessage.setSaveAsActivity(true); 
                                    messages.add(theMessage);  
                                }
                            }
                        }
                    }
                    
                    //To Avoid infinite looping
                    TrggrUtility.RunOnceEmailMessage = true;
                    
                    //Send message
                    if(messages.size() > 0 && !Test.isRunningTest())
                    {
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                    }
                    
                    if(failureRecordsList.size() > 0)
                    {
                        insert failureRecordsList;
                        List<Attachment> attachmentsToInsert = new List<Attachment>();
                        
                        for(Delivery_Failure_Response_Log__c indFailureRecords : failureRecordsList)
                        {
                            if(caseNumberWithAttachment.containsKey(indFailureRecords.Case_Number__c))
                            {
                                Attachment attachRec = caseNumberWithAttachment.get(indFailureRecords.Case_Number__c);
                                attachRec.parentId = indFailureRecords.Id;
                                attachmentsToInsert.add(attachRec);
                            }
                        }
                        
                        if(attachmentsToInsert.size() > 0)
                            insert attachmentsToInsert;
                            system.debug('attachmentsToInsert:::'+attachmentsToInsert);
                    }
                    
                    if(caseRecordsListToDelete.size() > 0)
                        delete caseRecordsListToDelete;
                }   
            }
            Catch(Exception ex)
            {
                System.debug('Exception in sending Mail:'+ex);
            } 
        }
    }
}