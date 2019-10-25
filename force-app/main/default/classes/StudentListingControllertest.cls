@isTest
public class StudentListingControllertest{
    @isTest
    static void  StudentListingControllertest(){
        
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
        
        Account accRecord = new account();
        accRecord.Name = 'Test Acc123';
        insert accRecord;
        
        Contact conRecord = new Contact();
        conRecord.LastName = 'Munn';
        conRecord.FirstName = 'Paul';
        conRecord.Email = 'Paulmunn@gmail.com';
        conRecord.Account = accRecord;
        insert conRecord;
        
        User u1 = new User(Alias = 'newUser', Email='newuser@testorg.com',
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = profileId.Id,ContactId = conRecord.Id,
                           TimeZoneSidKey='America/Los_Angeles', UserName='newuser@testorg.com');
        insert u1;
        
        User u3 =[SELECT Name from User Where Id =: u1.Id];
        
        redwing__Training_Plan__c lPlan = new redwing__Training_Plan__c();
        lPlan.Name = 'Test Plan';
        insert lPlan;
        
        // create redwing__Learning
        redwing__Learning__c learning = new redwing__Learning__c();
        learning.Name = 'Test learning';
        learning.redwing__Published__c = true;
        learning.RecordTypeId = Schema.SObjectType.redwing__Learning__c.getRecordTypeInfosByName().get('ILT Class').getRecordTypeId();
        insert learning;
        
        redwing__ILT_Location__c loc = new redwing__ILT_Location__c();
        loc.redwing__City__c = 'Berlin';
        loc.redwing__Address_1__c = 'Kurfurstendamm 194';
        loc.redwing__Country__c = 'Germany';
        loc.redwing__State__c = 'Berlin';
        loc.redwing__Postal_Code__c = '10707';
        insert loc;
        
        //Create ILT Class Record
        Redwing__ILT_Class__c classRecord = new Redwing__ILT_Class__c();
        classRecord.Skedulo_Account__c = accRecord.Id;
        classRecord.Skedulo_Account__c = accRecord.Id;
        classRecord.redwing__End_Date__c = system.today() + 6;
        classRecord.redwing__End_Time__c = '13:00';
        classRecord.redwing__Start_Date__c = system.today() + 2;// Assuming Start date = End date
        classRecord.redwing__Start_Time__c = '12:00';
        classRecord.Name = 'Test';
        classRecord.Request_Type__c = 'CPS';
        classRecord.redwing__Learning__c = learning.Id;
        classRecord.redwing__Location__c = loc.Id;
        insert classRecord;
        
        redwing__ILT_Instructor__c instructorrecord = new redwing__ILT_Instructor__c();
        instructorrecord.redwing__Instructor__c = u1.id;
        instructorrecord.redwing__ILT_Class__c = classRecord.id;
        insert instructorrecord;
        
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
        //raa.Achievement_Type__c = 'Certifications';
        raa.redwing__User__c =u3.id;
        raa.redwing__Expiration_Date__c = System.today() + 100;
        raa.redwing__Training_Plan_Achievement__c = tpa.id;
        raa.ILT_Class__c = classRecord.Id;
        raa.Account__c = accRecord.Id;
        insert raa;
        
        System.debug('Achievement Assignment acquired'+u3.Name);
        
        test.starttest();
        System.runAs(u3) 
        {
            StudentListingController.getPicklistValues('Account', null);
            StudentListingController.getPicklistValues('User', accRecord.id);
            StudentListingController.fetchUser();
            List<Id> accListFromClient = new List<Id>();
            accListFromClient.add(accRecord.id);
            String accString = JSON.serialize(accListFromClient);
            
            List<Id> userListFromClient = new List<Id>();
            userListFromClient.add(u3.id);
            String userString = JSON.serialize(userListFromClient);
            
            //Filtered by both Account and user
            StudentListingController.fetchAchv(accString, userString, '', '', '');
            
            //Filtered by only Account
            List<Id> emptyUserList = new List<Id>();
            String emptyUserString = JSON.serialize(emptyUserList);
            StudentListingController.fetchAchv(accString, emptyUserString, '', '', '');
            
            //Filtered by only Instructor
            List<Id> emptyAccountList = new List<Id>();
            String emptyAccountString = JSON.serialize(emptyAccountList);
            StudentListingController.fetchAchv(emptyAccountString, userString, '', '', '');
            
            System.AssertEquals(u3.id,raa.redwing__User__c);
            System.AssertEquals(u3.id,UserInfo.getUserId());
        }
        test.stoptest();
    }
}