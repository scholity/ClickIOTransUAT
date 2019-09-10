@isTest
public class PHSS_VoucherListControllerTest {
	
    static testMethod void myUnitTest(){
        // Create community user record
        List<Profile> profList = [SELECT Id FROM Profile WHERE Name = 'SB PHSS-Partner-Community Plus Login' LIMIT 1];
        String profileId;
        
        profileId = profList[0].Id;
        
        String fileData = 'Name'+','+'LastName'+','+'Email'+','+'Phonenumber'+''+'test1'+','+'t'+','+'test1t@cfr.com'+','+'8888888888';
        String fileDateBase64 = EncodingUtil.base64Encode(Blob.valueOf(fileData));
        String mimetype = 'text/csv;base64,';
        String fileName = 'SampleTest.csv';
        String finalFileData = mimetype+fileDateBase64;
        
        
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Bucket Account').getRecordTypeId();
        
        //Bucket Custom settings
        Bucket_Account_Settings__c bas = Bucket_Account_Settings__c.getOrgDefaults();
        bas.Bucket_Account_Owner_ID__c = UserInfo.getUserID();
        bas.Bucket_Account_RecordTypeID__c = recordTypeId;
        bas.Default_Bucket_Name__c = 'Bucket Account';
        bas.Maximum_Size_of_Bucket__c = 5000;
        insert bas;
        
        Profile profileIdnew = [SELECT Id FROM Profile WHERE Name = 'Customer Community User' LIMIT 1];

        
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
        c.FirstName = 'New';
        c.LastName = 'Tetst';
        c.Email = 'Priyap@gmail.com';
        c.Account =a;
        insert c;
        
        Account acc = new Account();
        acc.Name = 'TestAccount';
        acc.BillingStreet = '24 Willie Mays Plaza kryan';
        acc.BillingCity = 'San Fran';
        acc.BillingState = 'Cali';
        acc.BillingPostalCode = '94018';
        acc.BillingCountry = 'US';
        acc.Phone = '9876543219';
        insert acc;
        
        Contact con = new Contact();
        con.FirstName = 'Contact';
        con.LastName = 'Test';
        con.Email = 'testCon@gmail.com';
        con.Account = acc;
        insert con;

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
                            LocaleSidKey = 'en_US'
                           );
        insert usr;
        
        User partnerUser = new User(LastName = 'Test',
                                    FirstName = 'User',
                                    Alias = 'testU',
                                    Email = 'testCon@gmail.com',
                                    Username = 'testUser@redCross.com',
                                    ProfileId = profileId,
                                    ContactId = con.id,
                                    TimeZoneSidKey = 'GMT',
                                    LanguageLocaleKey = 'en_US',
                                    EmailEncodingKey = 'UTF-8',
                                    LocaleSidKey = 'en_US'
                                   );
        insert partnerUser;
        //Opportunity Creation
        List<BGST_Profiles__c> ProfilesLists = new List<BGST_Profiles__c>();
        BGST_Profiles__c indivl = new BGST_Profiles__c();
        indivl.name = 'Owner Profile';
        indivl.Sales_User__c = 'ARC BGST Sales User';
        ProfilesLists.add(indivl);
        insert ProfilesLists;
        
        //create an opportunity To fire the trigger on insert
        Opportunity opp1 = TestUtil.createOpportunity(a.Id, 'Interview', false);
        opp1.OwnerId = partnerUser.Id;
        opp1.Pricing_Approval_Level__c = Constants.APPROVAL_LEVEL_MOM;
        insert opp1;
        
        sked__Resource__c objResource = new sked__Resource__c();
        objResource.Name = 'Test';
        objResource.sked__Is_Active__c = true;
        objResource.sked__Resource_Type__c = 'Person';
        objResource.sked__Category__c = 'Instructor';
        objResource.sked__User__c = UserInfo.getUserId();
        insert objResource;
        
        redwing__Instructor__c objResource2 = new redwing__Instructor__c();
        objResource2.Skedulo_Is_Active__c = true;
        objResource2.Skedulo_Instructor__c  = objResource.id ;
        objResource2.redwing__User__c = usr.id;
        insert objResource2;
        
        redwing__Learning__c learning = new redwing__Learning__c();
        learning.Name = 'Test learning';
        learning.redwing__Published__c = true;
        learning.RecordTypeId = Schema.SObjectType.redwing__Learning__c.getRecordTypeInfosByName().get('ILT Event').getRecordTypeId();
        insert learning;
        
        redwing__Learning__c learning2 = new redwing__Learning__c();
        learning.Name = 'Test learning 2';
        learning.redwing__Published__c = true;
        learning.RecordTypeId = Schema.SObjectType.redwing__Learning__c.getRecordTypeInfosByName().get('ILT Event').getRecordTypeId();
        insert learning2;
        
        redwing__ILT_Event__c ilEvent = new redwing__ILT_Event__c();
        ilEvent.redwing__Learning__c = learning.Id;
        insert ilEvent;
        
        sked__Location__c objLocation = new sked__Location__c();
        
        objLocation.Name = 'Test';
        objLocation.sked__Type__c = 'Community';
        objLocation.sked__Address__c = '401 S Monroe St, Little Rock, AR, 72206';
        insert objLocation;
        
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
        
        sked__Region__c region = new sked__Region__c();
        region.Name = 'Test Region';
        region.sked__Timezone__c = 'Indian/Coscos';
        insert region;

        // create learning assignment
        redwing__Learning_Assignment__c learningAssignment = new redwing__Learning_Assignment__c();
        learningAssignment.redwing__Learning__c = learning.id;
        learningAssignment.External_Id__c = 'priyalakshmi.pp@gmail.com'; //Can be chaged if needed
        learningAssignment.redwing__Training_Plan__c = lPlan.Id;
        insert learningAssignment;


        //Create ILT Class Record
        Redwing__ILT_Class__c clsRecord = new Redwing__ILT_Class__c();
        clsRecord.Skedulo_Account__c = a.id;
        clsRecord.redwing__End_Date__c = Date.Parse('12/19/2018');
        clsRecord.redwing__End_Time__c= '13:00';
        clsRecord.redwing__Start_Date__c = Date.Parse('12/19/2018');// Assuming Start date = End date
        clsRecord.redwing__Start_Time__c = '12:00';
        clsRecord.Name = 'Test';
        clsRecord.redwing__Learning__c = learning.Id;
        insert clsRecord;
        
        Voucher__c  v = new Voucher__c();
        v.ILT_Class__c = clsRecord.id;
        v.Learning_Plan__c = lPlan.Id;
        v.Status__c = 'Claimed';
        insert v;

        redwing__ILT_Roster__c roster = new redwing__ILT_Roster__c();
        roster.redwing__User__c = usr.Id;
        roster.Voucher_Id__c = v.Id;
        roster.redwing__Learning_Assignment__c = learningAssignment.Id;
        insert roster;

        List<Voucher__c> vouch = PHSS_VoucherListController.getVoucherList(clsRecord.Id);
    	System.assert(vouch.size()>0);

        String result = PHSS_VoucherListController.cancelEnrollment(v.Id);
        System.assertEquals('Enrollment Cancelled', result);
    }
}