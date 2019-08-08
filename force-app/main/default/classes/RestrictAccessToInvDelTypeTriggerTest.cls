@isTest
private class RestrictAccessToInvDelTypeTriggerTest{        
       
    @isTest static void TestAccount (){
        
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
        
        User u1 = new User(Alias = 'standt1', 
        Email = 'standarduser@testorg.com', 
        EmailEncodingKey = 'UTF-8', 
        LastName = 'Testing', 
        LanguageLocaleKey = 'en_US', 
        LocaleSidKey = 'en_US', 
        TimeZoneSidKey = 'America/Los_Angeles', 
        ProfileId = p.Id,
        Username = uniqueName + '@test1' + orgId + '.org'); 
        insert u1; 
        
        User u2 = new User(Alias = 'standt2', 
        Email = 'standarduser@testorg.com', 
        EmailEncodingKey = 'UTF-8', 
        LastName = 'Testing', 
        LanguageLocaleKey = 'en_US', 
        LocaleSidKey = 'en_US', 
        TimeZoneSidKey = 'America/Los_Angeles', 
        ProfileId = p.Id,
        Username = uniqueName + '@test2' + orgId + '.org'); 
        insert u2; 
        
        User u3 = new User(Alias = 'standt3', 
        Email = 'standarduser@testorg.com', 
        EmailEncodingKey = 'UTF-8', 
        LastName = 'Testing', 
        LanguageLocaleKey = 'en_US', 
        LocaleSidKey = 'en_US', 
        TimeZoneSidKey = 'America/Los_Angeles', 
        ProfileId = p.Id,
        Username = uniqueName + '@test3' + orgId + '.org'); 
        insert u3;

        User u4 = new User(Alias = 'standt4', 
        Email = 'standarduser@testorg.com', 
        EmailEncodingKey = 'UTF-8', 
        LastName = 'Testing', 
        LanguageLocaleKey = 'en_US', 
        LocaleSidKey = 'en_US', 
        TimeZoneSidKey = 'America/Los_Angeles', 
        ProfileId = p.Id,
        Username = uniqueName + '@test4' + orgId + '.org'); 
        insert u4; 
                              
        /*id userId = UserInfo.getUserId();
        Validation_Rules__c supportConfig = Validation_Rules__c.getInstance(userId);
        supportConfig.Bypass_Rules__c = false;
        upsert supportConfig Validation_Rules__c.Id;        
        //upsert supportConfig;
        System.debug('supportConfig Id=='+supportConfig.Id);*/
        System.runAs(u1){                                
            try{
                Account accInd2 = new account(name = 'individual',Payment_Status__c = 'Suspended',Termination_Reason__c ='Non Payment',Invoice_Delivery_Type__c = 'Email');
                insert accInd2; 
                accInd2.Preferred_Payment_type__c = 'Invoice';
                accInd2.Red_Cross_PO_expiration_Date__c = system.today();
                accInd2.Payment_Status__c = 'Terminated';
                accInd2.Termination_Reason__c = 'Non-Payment sent to collections agency';
                accInd2.Red_Cross_PO__c = '123';            
                accInd2.Invoice_Delivery_Type__c = 'Postal Mail';
                accInd2.Inv_Del_Assign_Date__c = System.today() + 1;                
                accInd2.Terminate_Reinstate_Date__c  = System.today() + 1;
                update accInd2; 
            }catch(Exception ex){
                Boolean expectedExceptionThrown = ex.getMessage().contains('Script-thrown exception') ? true : false; 
                System.assertEquals(expectedExceptionThrown, false);
            }            
        }
        System.runAs(u1){                                
            try{
                Account accInd2 = new account(name = 'individual',Payment_Status__c = 'Suspended',Termination_Reason__c ='Non Payment',Invoice_Delivery_Type__c = 'Email');
                insert accInd2; 
                accInd2.Preferred_Payment_type__c = 'Invoice';
                accInd2.Red_Cross_PO_expiration_Date__c = system.today();
                accInd2.Payment_Status__c = 'Reinstated';
                accInd2.Termination_Reason__c = 'Exception Granted';
                accInd2.Red_Cross_PO__c = '123';          
                accInd2.Invoice_Delivery_Type__c = 'Postal Mail';
                accInd2.Inv_Del_Assign_Date__c = System.today() + 1;                
                accInd2.Terminate_Reinstate_Date__c  = System.today() + 1;
                update accInd2; 
            }catch(Exception ex){
                Boolean expectedExceptionThrown = ex.getMessage().contains('Script-thrown exception') ? true : false; 
                System.assertEquals(expectedExceptionThrown, false);
            }            
        }
        System.runAs(u2){                                 
            try{                
                Account accInd3 = new account(name = 'individual',Payment_Status__c = 'Suspended',Termination_Reason__c ='Non Payment',Invoice_Delivery_Type__c = 'Email');
                insert accInd3;
                accInd3.Red_Cross_PO__c = '123';
                update accInd3;
            }catch(Exception ex){
                Boolean expectedExceptionThrown = ex.getMessage().contains('Script-thrown exception') ? true : false; 
                System.assertEquals(expectedExceptionThrown, false);
            }            
        }       
        System.runAs(u){                                 
            try{
                Account accInd = new account(name = 'individual2',Payment_Status__c = 'Granted',Red_Cross_PO__c = '123',Terminate_Reinstate_Date__c = System.today(), Termination_Reason__c ='Non Payment');
                insert accInd;
                accInd.Payment_Status__c = 'Reinstated';
                accInd.Termination_Reason__c = 'Exception Granted';
                accInd.Red_Cross_PO__c = '123';
                update accInd;              
            }catch(Exception ex){
                Boolean expectedExceptionThrown = ex.getMessage().contains('Script-thrown exception') ? true : false; 
                System.assertEquals(expectedExceptionThrown, false);
            }            
        }
        System.runAs(u3){                                 
            try{
                Account accInd = new account(name = 'individual2',Payment_Status__c = 'Terminated',Preferred_Payment_type__c = 'ACH/Electronic Payment',Red_Cross_PO__c = '123',Terminate_Reinstate_Date__c = System.today(), Termination_Reason__c ='Non Payment');
                insert accInd;              
            }catch(Exception ex){
                Boolean expectedExceptionThrown = ex.getMessage().contains('Script-thrown exception') ? true : false; 
                System.assertEquals(expectedExceptionThrown, false);
            }            
        }
        System.runAs(u3){                                 
            try{
                Account accInd = new account(name = 'individual2',Payment_Status__c = 'Terminated',Preferred_Payment_type__c = 'ACH/Electronic Payment',Red_Cross_PO__c = '123',Terminate_Reinstate_Date__c = System.today(), Termination_Reason__c ='');
                insert accInd;              
            }catch(Exception ex){
                Boolean expectedExceptionThrown = ex.getMessage().contains('Script-thrown exception') ? true : false; 
                System.assertEquals(expectedExceptionThrown, false);
            }            
        }           
    }
    
    @isTest static void TestAccountTwo (){        
        String dateString = String.valueof(Datetime.now()).replace(' ', '').replace(':', '').replace('-', '');
        String orgId = UserInfo.getOrganizationId();
        Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));
        String uniqueName = orgId + dateString + randomInt;
       
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        
        User u2 = new User(Alias = 'standt2', 
        Email = 'standarduser@testorg.com', 
        EmailEncodingKey = 'UTF-8', 
        LastName = 'Testing', 
        LanguageLocaleKey = 'en_US', 
        LocaleSidKey = 'en_US', 
        TimeZoneSidKey = 'America/Los_Angeles', 
        ProfileId = p.Id,
        Username = uniqueName + '@test2' + orgId + '.org'); 
        insert u2;

        User u3 = new User(Alias = 'standt2', 
        Email = 'standarduser@testorg.com', 
        EmailEncodingKey = 'UTF-8', 
        LastName = 'Testing', 
        LanguageLocaleKey = 'en_US', 
        LocaleSidKey = 'en_US', 
        TimeZoneSidKey = 'America/Los_Angeles', 
        ProfileId = p.Id,
        Username = uniqueName + '@test3' + orgId + '.org'); 
        insert u3; 
                
        Group g = new Group(
            Name = 'Finance COE - Acct Mntce',
            DeveloperName = 'Finance_COE_Acct_Mntce',
            Type = 'Regular'
        );
        insert g;
        
        Group g1 = new Group(
            Name = 'Invoice Escalations',
            DeveloperName = 'Invoice_Escalations',
            Type = 'Regular'
        );
        insert g1;
                
        GroupMember gp1 = new GroupMember(
            GroupId = g1.Id,
            UserOrGroupId = u2.Id            
        );
        insert gp1;      

        GroupMember gp2 = new GroupMember(
            GroupId = g.Id,
            UserOrGroupId = u3.Id            
        );
        insert gp2; 
       
        System.runAs(u2){                                 
            try{
                Account accInd4 = new account(name = 'individual1',Payment_Status__c = 'Suspended',Preferred_Payment_type__c = 'Invoice',Termination_Reason__c ='Non Payment',Inv_Del_Assign_Date__c = System.today(),Invoice_Delivery_Type__c = 'Postal Mail');
                insert accInd4;                 
                accInd4.Invoice_Delivery_Type__c = 'Email';
                accInd4.Inv_Del_Assign_Date__c = System.today() + 1;
                update accInd4;             
                    
            }catch(Exception ex){
                Boolean expectedExceptionThrown = ex.getMessage().contains('Script-thrown exception') ? true : false; 
                System.assertEquals(expectedExceptionThrown, false);
            }            
        }
        System.runAs(u3){                                 
            try{
                Account accInd4 = new account(name = 'individual1',Payment_Status__c = 'Suspended',Preferred_Payment_type__c = 'Invoice',Termination_Reason__c ='Non Payment',Inv_Del_Assign_Date__c = System.today(),Invoice_Delivery_Type__c = 'Postal Mail');
                insert accInd4;                 
                accInd4.Invoice_Delivery_Type__c = 'Email';
                accInd4.Inv_Del_Assign_Date__c = System.today() + 1;
                update accInd4;             
            }catch(Exception ex){
                Boolean expectedExceptionThrown = ex.getMessage().contains('Script-thrown exception') ? true : false; 
                System.assertEquals(expectedExceptionThrown, false);
            }            
        }       
    }
    
    @isTest static void TestAccountThree(){
        String dateString = String.valueof(Datetime.now()).replace(' ', '').replace(':', '').replace('-', '');
        String orgId = UserInfo.getOrganizationId();
        Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));
        String uniqueName = orgId + dateString + randomInt;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        
        User u9 = new User(Alias = 'standt', 
        Email = 'standarduser@testorg.com', 
        EmailEncodingKey = 'UTF-8', 
        LastName = 'Testing', 
        LanguageLocaleKey = 'en_US', 
        LocaleSidKey = 'en_US', 
        TimeZoneSidKey = 'America/Los_Angeles', 
        ProfileId = p.Id,
        Username = uniqueName + '@test' + orgId + '.org'); 
        insert u9; 
        
        User u10 = new User(Alias = 'stan', 
        Email = 'standarduser1@testorg.com', 
        EmailEncodingKey = 'UTF-8', 
        LastName = 'Testing', 
        LanguageLocaleKey = 'en_US', 
        LocaleSidKey = 'en_US', 
        TimeZoneSidKey = 'America/Los_Angeles', 
        ProfileId = p.Id,
        Username = uniqueName + '@test123' + orgId + '.org'); 
        insert u10; 
        
        System.runAs(u9){                                 
            try{
                Account accInd123 = new account(name = 'individual2',Payment_Status__c = 'Suspended');
                insert accInd123;
                accInd123.Payment_Status__c = 'Terminated';
                accInd123.Preferred_Payment_type__c = 'ACH/Electronic Payment';                                         
                update accInd123;  
            }catch(Exception ex){
                Boolean expectedExceptionThrown = ex.getMessage().contains('Script-thrown exception') ? true : false; 
                System.assertEquals(expectedExceptionThrown, false);
            }            
        }
        System.runAs(u9){                                 
            try{
                Account accInd123 = new account(name = 'individual2',Payment_Status__c = 'Terminated',Terminate_Reinstate_Date__c = System.today(), Termination_Reason__c ='Non Payment');
                insert accInd123;
                accInd123.Payment_Status__c = 'Suspended';
                accInd123.Terminate_Reinstate_Date__c = System.today() + 1;
                //accInd123.Preferred_Payment_type__c = 'ACH/Electronic Payment';                                           
                update accInd123;  
            }catch(Exception ex){
                Boolean expectedExceptionThrown = ex.getMessage().contains('Script-thrown exception') ? true : false; 
                System.assertEquals(expectedExceptionThrown, false);
            }            
        }
        System.runAs(u10){                                 
            try{
                Account accInd1234 = new account(name = 'individual2',Payment_Status__c = 'Reinstated',Red_Cross_PO__c = '123',Terminate_Reinstate_Date__c = System.today(), Termination_Reason__c ='Non Payment');
                insert accInd1234;
                accInd1234.Payment_Status__c = 'Suspended';
                //accInd1234.Preferred_Payment_type__c = 'ACH/Electronic Payment';                                          
                update accInd1234;  
            }catch(Exception ex){
                Boolean expectedExceptionThrown = ex.getMessage().contains('Script-thrown exception') ? true : false; 
                System.assertEquals(expectedExceptionThrown, false);
            }            
        }       
    }

}