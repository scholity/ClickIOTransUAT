trigger updateInvCaseSubType on Case bulk(after insert) {
    List<Case> newCase = Trigger.new;   
    List<Case> toUpdate = [select id,Subject,Origin,Customer_ID__c from Case where id In : newCase];   
    List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
    //List<Account> AccName = [SELECT id,SABA_LMS_Code__c from Account where SABA_LMS_Code__c =: toUpdate[0].Customer_ID__c];
    String profileName = PROFILE[0].Name; 
    
    //used to bypass validation rules on case object                
    Validation_Rules__c supportConfig = Validation_Rules__c.getOrgDefaults();      
    supportConfig.Bypass_Rules__c = true;    
    update supportConfig;
    //ends here.
    
    for (Case cs: toUpdate){        
        if(profileName == 'BillingRequestForm Profile' && (cs.Origin == 'Email' || cs.Origin == 'Web to Case') || Test.isRunningTest()){            
            System.debug('Subject===='+cs.Subject);
            String sub = cs.Subject;
            /*if(AccName != NULL && !AccName.isEmpty())
            {
            cs.AccountId = AccName[0].Id;
            }*/
            
            if(sub == 'AR Exception Needed' || sub == 'Temporary collections hold')
            {
                cs.Dispute_Issue__c = 'AR Exception';
                
            }   
            else if(sub == 'Bankruptcy Notice received')
            {
                cs.Dispute_Issue__c = 'Collections';
                
            }
            else if(sub == 'Change invoice delivery method to email' || sub == 'Change invoice delivery method to portal')
            {
                cs.Dispute_Issue__c = ' Invoice Delivery Method';
                
            }
            else if(sub == 'Duplicate invoice issue')
            {
                cs.Dispute_Issue__c = 'Duplicate Invoice';
                
            }
            else if(sub == 'Increase Credit Limit' || sub == 'Restore Invoicing Privileges' || sub == 'Submit Customer PO Form')
            {
                cs.Dispute_Issue__c = 'Invoicing Privileges';
                
            }
            else if(sub == 'Invoice Presentation Issue')
            {
                cs.Dispute_Issue__c = 'Invoice Presentation';
                
            }
            else if(sub == 'Manual Billing Form Submission')
            {
                cs.Dispute_Issue__c = 'Manual Billing Request';
                
            }
            else if(sub == 'Missing Payment Issue')
            {
                cs.Dispute_Issue__c ='Missing Payment';
                
            }
            else if(sub == 'Refund Credit Balance')
            {
                cs.Dispute_Issue__c ='Refund Credit Balance';
                
            }
            else if(sub == 'Request Billing/Payment History' || sub == 'Request Copy Of Invoice Or Credit Memo' || sub == ' Request Order Details For Invoice')
            {
                cs.Dispute_Issue__c ='Request Billing Docs';
                
            }
            else if(sub == 'Request To Pay By ACH')
            {
                cs.Dispute_Issue__c ='Invoice Payments';
                
            }           
            else if(sub == 'Update Billing Info' || sub == 'Update Tax Exemption Status')
            {
                cs.Dispute_Issue__c ='Customer Account Maintenance';
                
            }
            else if(sub == 'Wrong Organization Charged')
            {
                cs.Dispute_Issue__c ='Wrong Organization';
                
            }
            else if(sub == 'Payment Applied To Wrong Invoice/Account' || sub == 'Wrong Price On Invoice')
            {
                cs.Dispute_Issue__c ='Price';
            }
            else if(sub == 'Complete Vendor Forms')
            {
                cs.Dispute_Issue__c ='Vendor Forms';
            }
            else if(sub == 'Other')
            {
                cs.Dispute_Issue__c ='Other';
                
            }
        }
    }               
    update toUpdate;
    
    //revert back custom settings value to false
    supportConfig.Bypass_Rules__c = false;    
    update supportConfig;
}