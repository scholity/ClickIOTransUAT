trigger sendMailWebCases on Case(after insert) 
{
    //This is to handle web to case email response
    try
    {   
        System.debug('Inside sendMailWebCases::::');
        if(Trigger.isInsert || Test.isRunningTest())
        {
            System.debug('Inside Insert Send Email sendMailWebCases:');
            //To get targetObjectId
            String targetObjectId;
            List<Contact> contactList = new List<Contact>();
            contactList = [Select Id, Name from Contact where Name = 'webauto reply' and Email != null];
            if(contactList.size() == 0)
            {
                Contact con = new Contact();
                con.firstName = 'webauto';
                con.lastName = 'reply';
                con.Email = 'no-reply@redcrosstraining.org';
                insert con;
                targetObjectId = con.Id;
            }   
            else
                targetObjectId = contactList[0].Id;
            
            // To Email Address
            Set<String> toEmailAddress = new Set<String>();
            toEmailAddress.add('billing@redcross.org');
            toEmailAddress.add('sudhir.dakshinamurth@redcross.org');
            toEmailAddress.add('no-reply@redcross.org');
            List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
            Map<String, Id> emailAddressIdMap = new Map<String, Id>();
            if(toEmailAddress.size() > 0)
            {
                owea = [select Id, Address from OrgWideEmailAddress where Address In : toEmailAddress];
                for(OrgWideEmailAddress oweaInd : owea)
                    emailAddressIdMap.put(oweaInd.Address, oweaInd.Id);
            }
                    
            List<Case> caseList = [select id, Status, Origin, Type, SuppliedEmail from Case where id In : Trigger.newMap.keySet() And Origin = 'Web to Case']; 
            List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
            List<EmailTemplate> templateList =  [SELECT Id, DeveloperName, FolderId, Folder.DeveloperName from EmailTemplate where DeveloperName = 'Case_Auto_Reply'];
            System.debug('caseList::::'+caseList);
            for(Case caseRec : caseList)
            {
                if(caseRec.Type == 'Invoicing')
                {
                    System.debug('Inside send mail web to case Billing:');
                    if((templateList.size() > 0 && emailAddressIdMap.containsKey('billing@redcross.org') && caseRec.SuppliedEmail != null) || Test.isRunningTest())
                    {
                        Messaging.SingleEmailMessage theMessage = new Messaging.SingleEmailMessage();
    
                        theMessage.setTemplateId(templateList[0].Id);
    
                        theMessage.setTargetObjectId(targetObjectId);
                        theMessage.setTreatTargetObjectAsRecipient(false);
    
                        List<String> toAddress = new List<String>();
                        toAddress.add(caseRec.SuppliedEmail);
                        
                        theMessage.setOrgWideEmailAddressId(emailAddressIdMap.get('billing@redcross.org'));
                        
                        theMessage.setToAddresses(toAddress);
                        theMessage.setWhatId(caseRec.Id); 
                        theMessage.setSaveAsActivity(true); 
                        messages.add(theMessage);  
                    }
                }
                else
                {
                    System.debug('Inside send mail web to case else:');
                    if((templateList.size() > 0 && (emailAddressIdMap.containsKey('sudhir.dakshinamurth@redcross.org') || emailAddressIdMap.containsKey('no-reply@redcross.org')) && caseRec.SuppliedEmail != null) || Test.isRunningTest())
                    {
                        Messaging.SingleEmailMessage theMessage = new Messaging.SingleEmailMessage();
    
                        theMessage.setTemplateId(templateList[0].Id);
    
                        theMessage.setTargetObjectId(targetObjectId);
                        theMessage.setTreatTargetObjectAsRecipient(false);
    
                        List<String> toAddress = new List<String>();
                        toAddress.add(caseRec.SuppliedEmail);
                        
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
            
            if(messages.size() > 0 && !Test.isRunningTest())
            {
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            }
            
            //RCSPO Account populate for Email case
            Id rcsPoRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('RCS PO').getRecordTypeId();
            List<String> redCrossEmailList = new List<String>();
            List<Case> rcspoCaseList = [select id, Status, Origin, Type, SuppliedEmail, AccountId from Case where id In : Trigger.newMap.keySet() And Origin = 'Email' And recordTypeId =: rcsPoRecordTypeId]; 
            for(Case caseRec : rcspoCaseList)
            {
                redCrossEmailList.add(caseRec.SuppliedEmail);
            }
            
            if(redCrossEmailList.size() > 0)
            {
                Map<String, String> emailAndAccountIdMap = new Map<String, String>();
                List<Account> accountList = [select Id, Log_In_Email__c from Account where Log_In_Email__c In : redCrossEmailList];
                for(Account accRec : accountList)
                {
                    emailAndAccountIdMap.put(accRec.Log_In_Email__c, accRec.Id);
                }
                
                for(Case caseRec : rcspoCaseList)
                {
                    if(emailAndAccountIdMap.containsKey(caseRec.SuppliedEmail.trim()) && caseRec.AccountId == null)
                        caseRec.AccountId = emailAndAccountIdMap.get(caseRec.SuppliedEmail.trim());
                }
                
                if(rcspoCaseList.size() > 0)
                    update rcspoCaseList;
            }
            //Till Here
        }   
    }
    Catch(Exception ex)
    {
        System.debug('Exception in sending Mail:'+ex);
    } 
}