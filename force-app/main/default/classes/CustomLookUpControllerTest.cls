@isTest
public class CustomLookUpControllerTest
{
    public static final Integer actCount = 20;
    
    @testSetup 
    public static void initTestData()
    {
        createTestAccounts(actCount);   
    }
     
    static testMethod void testCustomLookupAccount()
    {
        List<Account> accounts = [SELECT Id, Name FROM Account];
        
        test.startTest();
        
        List<sObject> sObj = CustomLookUpController.fetchLookUpValues('Testing','Account','','');
                
        test.stopTest();
        
        //system.assertEquals(5, sObj.size());      
    }
    
    static testMethod void testCustomLookupCommunity()
    {
        List<Account> accounts = [SELECT Id, Name FROM Account];
        
        User u = [Select Id From User Where Profile.Name Like '%Community Profile%' AND isActive=true Limit 1];
        System.runAs(u){ 
            test.startTest();
            
            List<sObject> sObj = CustomLookUpController.fetchLookUpValues('Testing','Account','','');
                    
            test.stopTest();
            
            //system.assertEquals(5, sObj.size());  
        }
    }
    
    static testMethod void testCustomLookupUser()
    {
        List<Account> accounts = [SELECT Id, Name FROM Account];
        Profile profileIdInstructor = [SELECT Id FROM Profile WHERE Name = 'SB PHSS-Partner-Community Plus Login' LIMIT 1];
        //User u = [Select Id From User Where Profile.Name Like '%Community Plus%' AND isActive=true AND Profile Limit 1];
         Profile profileIdnew = [SELECT Id FROM Profile WHERE Name = 'Learner Community Profile' LIMIT 1];
         
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Bucket Account').getRecordTypeId();
         
          //Bucket Custom settings
        Bucket_Account_Settings__c bas = Bucket_Account_Settings__c.getOrgDefaults();
        bas.Bucket_Account_Owner_ID__c = UserInfo.getUserID();
        bas.Bucket_Account_RecordTypeID__c = recordTypeId;
        bas.Default_Bucket_Name__c = 'Bucket Account';
        bas.Maximum_Size_of_Bucket__c = 5000;
        insert bas;
        
         Account a = new Account();
        a.Name='SalesforcetestOrg';
        a.BillingStreet='24 Willie Mays Plaza';
        a.BillingCity='San Francisco';
        a.BillingState='California';
        a.BillingPostalCode='94017';
        a.BillingCountry='USA';
        a.Phone='9934200234';
        //a.email='Salesforceredcross@cross.com';
        insert a;
        
        Contact c = new Contact();
        c.FirstName = 'JASON';
        c.LastName = 'LIVESTON';
        c.Email = 'jason.liveston@asdf.com';
        c.Account =a;
        c.MailingStreet = '100 Main st';
        c.Mailingcity = 'Melbourne';
        c.MailingPostalCode = '32901';
        c.MailingState = 'FL';
        c.Phone = '9998887777';
        c.NSSCCConnector__Contact_Status__c  = 'Created';
        insert c;
        
        Contact c1 = new Contact();
        c1.FirstName = 'jan';
        c1.LastName = 'hunt';
        c1.Email = 'jhunt@gmail.com';
        c1.Account =a;
        c1.NSSCCConnector__Contact_Status__c  = 'Created';
        insert c1;
        
           User usr = new User(LastName = 'LIVESTON',
                            FirstName='JASON',
                            Alias = 'jliv',
                            Email = 'jason.liveston@asdf.com',
                            Username = 'jason.liveston@asdf.com',
                            ProfileId = profileIdnew.id,
                            ContactId = c.id,
                            TimeZoneSidKey = 'GMT',
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US',
                            street = '100 Main st',
                            city = 'Melbourne',
                            PostalCode = '32901',
                            State = 'FL',
                            Phone = '9998887777'
                           );
        insert usr;
        
       
        
           User u1 = new User(LastName = 'Hunter',
                            FirstName='Jane',
                            Alias = 'jhant',
                            Email = 'jhant.hunter@asdf.com',
                            Username = 'jhant.hunter@asdf.com',
                            ProfileId = profileIdInstructor.id,
                            ContactId = c1.id,
                            TimeZoneSidKey = 'GMT',
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US'
                           );
        insert u1;
        
        AccountContactRelation acr = new AccountContactRelation(); 
        acr.Accountid = a.id;
        acr.Contactid = c1.id;
        acr.roles='Administrator';
        insert acr;
        
        redwing__Learning__c learning = new redwing__Learning__c();
        learning.Name = 'Test learning';
        learning.redwing__Published__c = true;
        learning.RecordTypeId = Schema.SObjectType.redwing__Learning__c.getRecordTypeInfosByName().get('ILT Event').getRecordTypeId();
        insert learning;
        
        redwing__Training_Plan__c lPlan = new redwing__Training_Plan__c();
        lPlan.Name = 'Test Plan';
        insert lPlan;
        
        redwing__Training_Plan_Section__c lPlanSection = new redwing__Training_Plan_Section__c();
        lPlanSection.Name = 'Test Plan Section';
        lPlanSection.redwing__Training_Plan__c = lPlan.Id;
        insert lPlanSection;
        
        redwing__Training_Plan_Section_Item__c lPlanSectionItem = new redwing__Training_Plan_Section_Item__c();
        lPlanSectionItem.redwing__Learning__c = learning.Id;
        lPlanSectionItem.redwing__Training_Plan_Section__c = lPlanSection.Id;
        insert lPlanSectionItem;
        
        redwing__Prerequisite__c rp = new redwing__Prerequisite__c();
        insert rp;
        
        redwing__Learning_Prerequisite__c rlp = new redwing__Learning_Prerequisite__c();
        rlp.redwing__Learning__c=lPlanSectionItem.redwing__Learning__c;
        rlp.redwing__Prerequisite__c = rp.id;
        insert rlp;
        
        
        redwing__Achievement_Category__c rac = new redwing__Achievement_Category__c();
        rac.name = 'Skill';
        insert rac;
        
        redwing__Achievement__c ra = new redwing__Achievement__c();
        ra.redwing__Achievement_Category__c = rac.id;
        ra.redwing__Type__c = 'Certifications';
        insert ra;
        
        redwing__Achievement_Assignment__c raa= new redwing__Achievement_Assignment__c();
        raa.redwing__Achievement__c = ra.id;
        raa.redwing__User__c = u1.id;
        raa.redwing__Status__c = 'Acquired';
        raa.redwing__Contact__c = c1.id;
        raa.Evaluation_Result__c = 'Successful';
        insert raa;
        
        redwing__Prerequisite_Item__c rpi = new redwing__Prerequisite_Item__c();
        rpi.redwing__Prerequisite__c=rp.id;
        rpi.redwing__Required_Status__c='Acquired';
        rpi.redwing__Achievement__c=ra.id;
        insert rpi;
        
        sked__Location__c objLocation = new sked__Location__c();
        objLocation.Name = 'Test';
        objLocation.sked__Type__c = 'Community';
        objLocation.sked__Address__c = '401 S Monroe St, Little Rock, AR, 72206';
        insert objLocation;
        
        redwing__Training_Plan__c lPlan2 = new redwing__Training_Plan__c();
        lPlan2.Name = 'Plan2';
        insert lPlan2;
        
        redwing__Learning__c learning1 = new redwing__Learning__c();
        learning1.Name = 'Test learning';
        learning1.redwing__Published__c = true;
        learning1.RecordTypeId = Schema.SObjectType.redwing__Learning__c.getRecordTypeInfosByName().get('Media').getRecordTypeId();
        insert learning1;
        
        Redwing__ILT_Class__c clsRecord = new Redwing__ILT_Class__c();
        clsRecord.Skedulo_Account__c = a.id;
        clsRecord.redwing__End_Date__c = Date.Parse('12/12/2019');
        clsRecord.redwing__End_Time__c= '13:00';
        clsRecord.redwing__Start_Date__c = Date.Parse('12/12/2019');// Assuming Start date = End date
        clsRecord.redwing__Start_Time__c = '12:00';
        clsRecord.Name = 'Test';
        clsRecord.Learning_Plan__c = lPlan2.Id;
        clsRecord.redwing__Learning__c = learning1.Id;
        insert clsRecord;
        
        //User u = [Select Id From User Where Profile.Name Like '%Community Profile%' AND isActive=true Limit 1];
        
        test.startTest();
        System.Runas(u1){
        
        List<sObject> sObj = CustomLookUpController.fetchLookUpValues('jane','User',a.id,lPlan.id);
                }
        test.stopTest();
        
        //system.assertEquals(5, sObj.size());      
    }
    
    static testMethod void testCustomLookup()
    {
        List<Account> accounts = [SELECT Id, Name FROM Account];
        
        test.startTest();
        
        List<sObject> sObj = CustomLookUpController.fetchLookUpValues('Salesforce','Contact','','');
                
        test.stopTest();
        
        //system.assertEquals(5, sObj.size());      
    }
    
    static testMethod void testCustomLookup1()
    {
        List<Account> accounts = [SELECT Id, Name FROM Account];
        
        redwing__Learning__c learning1 = new redwing__Learning__c();
        learning1.Name = 'Test learning';
        learning1.redwing__Published__c = true;
        learning1.RecordTypeId = Schema.SObjectType.redwing__Learning__c.getRecordTypeInfosByName().get('Media').getRecordTypeId();
        insert learning1;
        
        Redwing__ILT_Class__c clsRecord = new Redwing__ILT_Class__c();
        clsRecord.Skedulo_Account__c = accounts[0].id;
        clsRecord.redwing__End_Date__c = Date.Parse('12/12/2019');
        clsRecord.redwing__End_Time__c= '13:00';
        clsRecord.redwing__Start_Date__c = Date.Parse('12/12/2019');// Assuming Start date = End date
        clsRecord.redwing__Start_Time__c = '12:00';
        clsRecord.Name = 'Test';
        //clsRecord.Learning_Plan__c = lPlan2.Id;
        clsRecord.redwing__Learning__c = learning1.Id;
        insert clsRecord;
        
        test.startTest();
        
        List<sObject> sObj = CustomLookUpController.fetchLookUpValues('Test','redwing__ILT_Class__c','','');
                
        test.stopTest();
        
        //system.assertEquals(5, sObj.size());      
    }
    
    static testMethod void testCustomLookup2()
    {
        List<Account> accounts = [SELECT Id, Name FROM Account];
        
        test.startTest();
        
        List<sObject> sObj = CustomLookUpController.fetchLookUpValues('Salesforce','redwing__ILT_Location__c','','');
                
        test.stopTest();    
    }
    
    public static void createTestAccounts(Integer accounts)
    {
        Database.DMLOptions dml = new Database.DMLOptions();
        
        dml.DuplicateRuleHeader.allowSave = true;
        
        List<account> accountList = new List<Account>();
        
        for(Integer a = 0; a< accounts; a++)
        {
            accountList.add(new Account(Name='Testing Company'+ String.ValueOf(a)));
        }
        
        database.insert( accountList, dml);
    }
}