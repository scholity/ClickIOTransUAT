@isTest
private class updateInvCaseSubTypeTest{
    @isTest static void TestCase (){
        String dateString = String.valueof(Datetime.now()).replace(' ', '').replace(':', '').replace('-', '');
        String orgId = UserInfo.getOrganizationId();
        Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));
        String uniqueName = orgId + dateString + randomInt;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        
        User u = new User(Alias = 'standt', 
        Email = 'standarduser@testorg.com', 
        EmailEncodingKey = 'UTF-8', 
        LastName = 'Testing', 
        LanguageLocaleKey = 'en_US', 
        LocaleSidKey = 'en_US', 
        TimeZoneSidKey = 'America/Los_Angeles', 
        ProfileId = p.Id,
        Username = uniqueName + '@test' + orgId + '.org'); 
        insert u;
        
        Bucket_Account_Settings__c bas = new Bucket_Account_Settings__c();
        bas.Bucket_Account_Owner_ID__c ='005d0000001WOeV';
        bas.Bucket_Account_RecordTypeID__c = '012d000000098Wt';
        bas.Default_Bucket_Name__c = 'Bucket Account';
        bas.Maximum_Size_of_Bucket__c = 5000;
        insert bas;
        
        Account acc = new account(name = 'individual');
        insert acc;
        
        Contact con = new Contact(AccountId=acc.Id, lastname='testing', firstname='apex');
        insert con; 
            
        Switch__c cohstest = new Switch__c();
        cohstest.Switch__c = false;
        cohstest.Name = 'CaseOwnerHistorySwitch';
        insert cohstest;
        
        id strRecordTypeId = [Select Id From RecordType Where SobjectType = 'Case' and Name = 'Service Cases'].Id;
        
        Validation_Rules__c supportConfig = Validation_Rules__c.getOrgDefaults();
        supportConfig.Bypass_Rules__c = false;        
        upsert supportConfig Validation_Rules__c.Id;  
        
        System.runas(u){
                List<Case> CaseIns=new List<Case>();
            Case caseObj = new Case();
            caseObj.RecordTypeId  = strRecordTypeId; 
            caseObj.ContactId = con.Id;
            caseObj.AccountId  = acc.Id;
            caseObj.Type = 'Invoicing';
            caseObj.Subject = 'AR Exception Needed';
            caseObj.Status = 'New';
            caseObj.Origin = 'Web to Case';
            caseObj.Invoice_Case_Sub_Type__c = 'Product';
            
            CaseIns.add(caseObj); 
            
            Case caseObj1 = new Case();
            caseObj1.RecordTypeId  = strRecordTypeId; 
            caseObj1.ContactId = con.Id;
            caseObj1.AccountId  = acc.Id;
            caseObj1.Type = 'Invoicing';
            caseObj1.Subject = 'Bankruptcy Notice received';
            caseObj1.Status = 'New';
            caseObj1.Origin = 'Web to Case';
            caseObj1.Invoice_Case_Sub_Type__c = 'Product';
            
            CaseIns.add(caseObj1);
            
            Case caseObj2 = new Case();
            caseObj2.RecordTypeId  = strRecordTypeId; 
            caseObj2.ContactId = con.Id;
            caseObj2.AccountId  = acc.Id;
            caseObj2.Type = 'Invoicing';
            caseObj2.Subject = 'Duplicate invoice issue';
            caseObj2.Status = 'New';
            caseObj2.Origin = 'Web to Case';
            caseObj2.Invoice_Case_Sub_Type__c = 'Product';
            
            CaseIns.add(caseObj2);
            
            Case caseObj3 = new Case();
            caseObj3.RecordTypeId  = strRecordTypeId; 
            caseObj3.ContactId = con.Id;
            caseObj3.AccountId  = acc.Id;
            caseObj3.Type = 'Invoicing';
            caseObj3.Subject = 'Manual billing form submission';
            caseObj3.Status = 'New';
            caseObj3.Origin = 'Web to Case';
            caseObj3.Invoice_Case_Sub_Type__c = 'Product';
            
            CaseIns.add(caseObj3);
            
            Case caseObj4 = new Case();
                        caseObj4.RecordTypeId  = strRecordTypeId; 
            caseObj4.ContactId = con.Id;
            caseObj4.AccountId  = acc.Id;
            caseObj4.Type = 'Invoicing';
            caseObj4.Subject = 'Other';
            caseObj4.Status = 'New';
            caseObj4.Origin = 'Web to Case';
            caseObj4.Invoice_Case_Sub_Type__c = 'Product';
            
            CaseIns.add(caseObj4);
            
            Case caseObj5 = new Case();
                       caseObj5.RecordTypeId  = strRecordTypeId; 
            caseObj5.ContactId = con.Id;
            caseObj5.AccountId  = acc.Id;
            caseObj5.Type = 'Invoicing';
            caseObj5.Subject = 'Refund Credit Balance';
            caseObj5.Status = 'New';
            caseObj5.Origin = 'Web to Case';
            caseObj5.Invoice_Case_Sub_Type__c = 'Product';
            
            CaseIns.add(caseObj5);
            
            Case caseObj6 = new Case();
            caseObj6.RecordTypeId  = strRecordTypeId; 
            caseObj6.ContactId = con.Id;
            caseObj6.AccountId  = acc.Id;
            caseObj6.Type = 'Invoicing';
            caseObj6.Subject = 'Invoice presentation issue';
            caseObj6.Status = 'New';
            caseObj6.Origin = 'Web to Case';
            caseObj6.Invoice_Case_Sub_Type__c = 'Product';
            
            CaseIns.add(caseObj6);
            
            Case caseObj7 = new Case();
            caseObj7 .RecordTypeId  = strRecordTypeId; 
            caseObj7 .ContactId = con.Id;
            caseObj7 .AccountId  = acc.Id;
            caseObj7 .Type = 'Invoicing';
            caseObj7 .Subject = 'Payment Applied To Wrong Invoice/Account';
            caseObj7 .Status = 'New';
            caseObj7 .Origin = 'Web to Case';
            caseObj7 .Invoice_Case_Sub_Type__c = 'Product';
            
            CaseIns.add(caseObj7);
            
            Case caseObj8 = new Case();
            caseObj8 .RecordTypeId  = strRecordTypeId; 
            caseObj8 .ContactId = con.Id;
            caseObj8 .AccountId  = acc.Id;
            caseObj8.Type = 'Invoicing';
            caseObj8 .Subject = 'Vendor Forms';
            caseObj8 .Status = 'New';
            caseObj8 .Origin = 'Web to Case';
            caseObj8 .Invoice_Case_Sub_Type__c = 'Product';
            
            CaseIns.add(caseObj8);
            
            Insert CaseIns;
        }
        
                
        
    }
}