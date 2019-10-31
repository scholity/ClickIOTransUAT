@isTest
public class CommunitypageInstructorstest{
    @isTest
    static void  CommunitypageInstructorstest(){
        
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Bucket Account').getRecordTypeId();
        //Bucket Custom settings
        Bucket_Account_Settings__c bas = Bucket_Account_Settings__c.getOrgDefaults();
        bas.Bucket_Account_Owner_ID__c = UserInfo.getUserID();
        bas.Bucket_Account_RecordTypeID__c = recordTypeId;
        bas.Default_Bucket_Name__c = 'Bucket Account';
        bas.Maximum_Size_of_Bucket__c = 5000;
        insert bas;
        
        // User Credentials:
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'SB PHSS-Partner-Community Plus Login' LIMIT 1];
        
        
        Account accRecord=new account();
        accRecord.Name='Test Acc123';
        insert accRecord;
        
        Contact conRecord= new Contact();
        conRecord.LastName = 'Munn';
        conRecord.FirstName = 'Paul';
        conRecord.Email='Paulmunn@gmail.com';
        conRecord.Account = accRecord;
        insert conRecord;
        
        
        User u1 = new User(Alias = 'newUser', Email='newuser@testorg.com',
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = profileId.Id,ContactId = conRecord.Id,
                           TimeZoneSidKey='America/Los_Angeles', UserName='newuser@testorg.com');
        insert u1;
        
        
        
        User u3 =[SELECT Name from User Where Id =: u1.Id];
        
        AccountContactRelation acr = new AccountContactRelation(); 
        acr.Accountid = accRecord.id;
        acr.Contactid = conRecord.id;
        insert acr;
        
        redwing__Training_Plan__c lPlan = new redwing__Training_Plan__c();
        lPlan.Name = 'Test Plan';
        insert lPlan;
        
        // Create Achievement Assignemnt
        
        redwing__Achievement_Category__c rac = new redwing__Achievement_Category__c();
        rac.name = 'Skill';
        insert rac;
        
        redwing__Achievement__c ra = new redwing__Achievement__c();
        ra.redwing__Achievement_Category__c = rac.id;
        ra.redwing__Type__c = 'Certifications';
        insert ra;
        
        redwing__Training_Plan_Achievement__c tpa = new redwing__Training_Plan_Achievement__c();
        tpa.redwing__Achievement__c = ra.id;
        tpa.redwing__Training_Plan__c = lPlan.Id;
        insert tpa;
        
        redwing__Achievement_Assignment__c raa = new redwing__Achievement_Assignment__c();
        raa.redwing__Achievement__c = ra.Id;
        raa.redwing__Status__c = 'Acquired';
        raa.redwing__User__c =u3.id;
        raa.redwing__Expiration_Date__c = System.today() + 100;
        raa.redwing__Training_Plan_Achievement__c = tpa.id;
        raa.redwing__Contact__c=conRecord.id;
        raa.Evaluation_Result__c = 'Successful';
        insert raa;
        
        System.debug('Achievement Assignment acquired'+u3.Name);
        
        test.starttest();
        System.runAs(u3) {
            CommunitypageInstructors.getPicklistValues('Account', null);
            CommunitypageInstructors.getPicklistValues('User', accRecord.id);
            CommunitypageInstructors.fetchUser();
            List<Id> accListFromClient = new List<Id>();
            accListFromClient.add(accRecord.id);
            String accString = JSON.serialize(accListFromClient);
            
            List<Id> userListFromClient = new List<Id>();
            userListFromClient.add(u3.id);
            String userString = JSON.serialize(userListFromClient);
            
            //Filtered by both Account and user
            CommunitypageInstructors.fetchAchv(accString,userString);
            
            //Filtered by only Account
            List<Id> emptyUserList = new List<Id>();
            String emptyUserString = JSON.serialize(emptyUserList);
            CommunitypageInstructors.fetchAchv(accString,emptyUserString);
            
            //Filtered by only Instructor
            List<Id> emptyAccountList = new List<Id>();
            String emptyAccountString = JSON.serialize(emptyAccountList);
            CommunitypageInstructors.fetchAchv(emptyAccountString, userString);
            
            System.AssertEquals(u3.id,raa.redwing__User__c);
            System.AssertEquals(u3.id,UserInfo.getUserId());
        }
        test.stoptest();
    }
}