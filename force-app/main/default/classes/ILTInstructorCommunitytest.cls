@isTest
private without sharing class ILTInstructorCommunitytest {

    @testSetup
    static void createTestData() {

        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Bucket Account').getRecordTypeId();

        //Bucket Custom settings
        Bucket_Account_Settings__c bas = Bucket_Account_Settings__c.getOrgDefaults();
        bas.Bucket_Account_Owner_ID__c = UserInfo.getUserID();
        bas.Bucket_Account_RecordTypeID__c = recordTypeId;
        bas.Default_Bucket_Name__c = 'Bucket Account';
        bas.Maximum_Size_of_Bucket__c = 5000;
        insert bas;

        List<BGST_Profiles__c> ProfilesLists = new List<BGST_Profiles__c>();
        BGST_Profiles__c indivl = new BGST_Profiles__c();
        indivl.name = 'Owner Profile';
        indivl.Sales_User__c = 'ARC BGST Sales User';
        ProfilesLists.add(indivl);
        insert ProfilesLists;
        
		Switch__c esettings = new Switch__c();
        esettings.Name = 'EmailMessageServiceSwitch';
        esettings.Switch_Description__c = 'some desc';
        esettings.Switch__c = false;
        insert esettings;


    }

    static testMethod void myUnitTest(){

        /********Test Data Started*************/
        // create user to run as in order to make sure the user has a role assigned - essential when creating community users
        // SJC - Abandoned this approach - must use an existing user to avoid bucket account assignment of new account created below

        /*
        User u = new User();
        u.FirstName = 'Admin';
        u.LastName = 'User';
        u.Alias = 'admu';
        u.Email = 'admin@user.usr';
        u.Username = '232343admin@user.de';
        u.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
        u.UserRoleId = [Select Id From UserRole Where PortalType = 'None' LIMIT 1].Id;
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';
        insert u;
        */

        User runAsUser = [Select Id,FirstName,LastName,Alias,Email,Username,ProfileId,UserRoleId,TimeZoneSidKey,
                EmailEncodingKey,LanguageLocaleKey,LocaleSidKey from User Where IsActive = True And
                Name != 'Salesforce Automation Account' And UserRoleId != NULL
                And Profile.Name = 'System Administrator' Limit 1];

        System.RunAs(runAsUser) {

            // Create community user record
            // Partner user profile
            Profile partnerProfile = [SELECT Id FROM Profile WHERE Name = 'SB PHSS-Partner-Community Plus Login' LIMIT 1];

            String fileData = 'Name' + ',' + 'LastName' + ',' + 'Email' + ',' + 'Phonenumber' + '' + 'test1' + ',' + 't' + ',' + 'test1t@cfr.com' + ',' + '8888888888';

            String fileDateBase64 = EncodingUtil.base64Encode(Blob.valueOf(fileData));
            String mimetype = 'text/csv;base64,';
            String fileName = 'SampleTest.csv';
            String finalFileData = mimetype + fileDateBase64;

            // Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Bucket Account').getRecordTypeId();

            // Bucket_Account_Settings__c bas = [SELECT Bucket_Account_Owner_ID__c, Bucket_Account_RecordTypeID__c, Default_Bucket_Name__c, Maximum_Size_of_Bucket__c FROM Bucket_Account_Settings__c WHERE Default_Bucket_Name__c = 'Bucket Account'];

            Profile customerProfile = [SELECT Id FROM Profile WHERE Name = 'SB PHSS-IC-Community Plus Login' LIMIT 1];

            Account a = new Account();
            a.Name = 'SalesforcetestOrg';
            a.BillingStreet = '24 Willie Mays Plaza';
            a.BillingCity = 'San Francisco';
            a.BillingState = 'California';
            a.BillingPostalCode = '94017';
            a.BillingCountry = 'USA';
            a.Phone = '9934200234';
            //a.email='Salesforceredcross@cross.com';
            insert a;

            Contact c = new Contact();
            c.FirstName = 'New';
            c.LastName = 'Tetst';
            c.Email = 'Priyap@gmail.com';
            c.AccountId = a.Id;
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
            con.AccountId = acc.Id;
            insert con;

            User usr = new User(LastName = 'LIVESTON',
                    FirstName = 'JASON',
                    Alias = 'jliv',
                    Email = 'jason.liveston@asdf.com',
                    Username = 'jason.liveston@asdf.com',
                    ProfileId = customerProfile.id,
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
                    ProfileId = partnerProfile.Id,
                    ContactId = con.id,
                    TimeZoneSidKey = 'GMT',
                    LanguageLocaleKey = 'en_US',
                    EmailEncodingKey = 'UTF-8',
                    LocaleSidKey = 'en_US'
            );
            insert partnerUser;
            //Opportunity Creation
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
            objResource2.Skedulo_Instructor__c = objResource.id ;
            objResource2.redwing__User__c = usr.id;
            insert objResource2;

            // ****
            redwing__Learning__c learning0 = new redwing__Learning__c();
            learning0.Name = 'Test learning 0';
            learning0.redwing__Published__c = true;
            learning0.RecordTypeId = Schema.SObjectType.redwing__Learning__c.getRecordTypeInfosByName().get('ILT Event').getRecordTypeId();
            insert learning0;
            // ****

            redwing__Learning_Version__c learnVersion = new redwing__Learning_Version__c();
            learnVersion.redwing__Learning__c = learning0.Id;
            insert learnVersion;


            redwing__Learning__c learning = new redwing__Learning__c();
            learning.Name = 'Test learning';
            learning.redwing__Published__c = true;
            learning.RecordTypeId = Schema.SObjectType.redwing__Learning__c.getRecordTypeInfosByName().get('ILT Event').getRecordTypeId();
            learning.redwing__Current_Published_Version__c = learnVersion.Id;
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

            redwing__ILT_Location__c rdwngLocation = new redwing__ILT_Location__c();
            rdwngLocation.Skedulo_Location__c = objLocation.Id;
            rdwngLocation.Account__c = a.Id;
            rdwngLocation.redwing__Address_1__c = '401 S Monroe St';
            rdwngLocation.redwing__City__c = 'Little Rock';
            rdwngLocation.redwing__Postal_Code__c = '72206';
            rdwngLocation.redwing__State__c = 'AR';
            insert rdwngLocation;

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
            /* Student Test Data*/
            //Create ILT Class Record
            Redwing__ILT_Class__c clsRecord = new Redwing__ILT_Class__c();
            clsRecord.Skedulo_Account__c = a.id;
//            clsRecord.redwing__End_Date__c = Date.Parse('12/19/2018');
            clsRecord.redwing__End_Date__c = Date.today().addDays(1);
            clsRecord.redwing__End_Time__c = '23:00';
            clsRecord.redwing__Start_Date__c = Date.today().addDays(1);// Assuming Start date = End date
            clsRecord.redwing__Start_Time__c = '00:00';
            clsRecord.Name = 'Test';
            clsRecord.redwing__Learning__c = learning.Id;
            insert clsRecord;


            //Create ILT Session record
            redwing__ILT_Session__c sessionRecord = new redwing__ILT_Session__c();
            sessionRecord.redwing__ILT_Class__c = clsRecord.Id;
            sessionRecord.Skedulo_Account__c = a.id;
            sessionRecord.Skedulo_Address__c = objLocation.id;
            //End Time is defaulted to "20:00"
            sessionRecord.redwing__End_Time__c = '20:00';
            sessionRecord.redwing__Date__c = Date.today().addDays(1);
            //Start Time is defaulted to "08:00"
            sessionRecord.redwing__Start_Time__c = '08:00';
            insert sessionRecord;

            redwing__ILT_Instructor__c instructorrecord = new redwing__ILT_Instructor__c();
            instructorrecord.redwing__Instructor__c = usr.id;
            instructorrecord.redwing__ILT_Class__c = clsRecord.id;
            insert instructorrecord;


            redwing__Training_Plan_Assignment__c planAssignment = new redwing__Training_Plan_Assignment__c();
            planAssignment.redwing__Training_Plan__c = lPlan.id; // Retrieved learning plan id based on the course selected in page 1
            //planAssignment.redwing__Contact__r = con;
            planAssignment.redwing__User__c = UserInfo.getUserId();
            planAssignment.External_Id__c = 'priyalakshmi.pp@gmail.com' + clsRecord.id;
            insert planAssignment;

            redwing__Learning_Assignment__c learningAssignment = new redwing__Learning_Assignment__c();
            //learningAssignment.redwing__Contact__c = planAssignment.redwing__Contact__c;
            learningAssignment.redwing__Learning__c = learning.id; // Retrieve learning id from page 1
            learningAssignment.External_Id__c = 'priyalakshmi.pp@gmail.com'; //Can be chaged if needed
            learningAssignment.redwing__Training_Plan__c = lPlan.Id;
            insert learningAssignment;


            redwing__Learning_Assignment__c learningAssignmentupdate = new redwing__Learning_Assignment__c();
            learningAssignmentupdate.id = learningAssignment.id;
            learningAssignmentupdate.redwing__Evaluation_Result__c = 'Passed';
            learningAssignmentupdate.Grade_Reason__c = 'Reason 2'; // Retrieve learning id from page 1
            learningAssignmentupdate.Grade_Additional_Info__c = 'Reason 2'; //Can be chaged if needed
            update learningAssignmentupdate;
            System.debug(learningAssignmentupdate);

            redwing__Training_Plan_Section_Assignment__c rp = new redwing__Training_Plan_Section_Assignment__c();
            rp.redwing__User__c = planAssignment.redwing__User__c;
            rp.redwing__Training_Plan_Section__c = lPlanSection.id;
            rp.External_Id__c = 'priyalakshmi.pp@gmail.com' + clsRecord.id;
            insert rp;

            redwing__Achievement_Category__c rac = new redwing__Achievement_Category__c();
            rac.name = 'Skill';
            insert rac;

            redwing__Achievement_Category__c rac2 = new redwing__Achievement_Category__c();
            rac.name = 'Skill';
            insert rac2;

            redwing__Achievement_Category__c rac3 = new redwing__Achievement_Category__c();
            rac.name = 'CEU';
            insert rac3;


            redwing__Achievement__c ra = new redwing__Achievement__c();
            ra.redwing__Achievement_Category__c = rac.id;
            ra.redwing__Type__c = 'Certifications';
            insert ra;

            redwing__Achievement__c ra2 = new redwing__Achievement__c();
            ra2.redwing__Achievement_Category__c = rac2.id;
            ra2.redwing__Type__c = 'Skill';
            insert ra2;

            redwing__Achievement__c ra3 = new redwing__Achievement__c();
            ra3.redwing__Achievement_Category__c = rac3.id;
            ra3.redwing__Type__c = 'CEU';
            insert ra3;


            redwing__Training_Plan_Achievement__c tpa = new redwing__Training_Plan_Achievement__c();
            tpa.redwing__Achievement__c = ra.id;
            tpa.redwing__Training_Plan__c = lPlan.Id;
            insert tpa;

            redwing__Training_Plan_Achievement__c tpa2 = new redwing__Training_Plan_Achievement__c();
            tpa2.redwing__Achievement__c = ra2.id;
            tpa2.redwing__Training_Plan__c = lPlan.Id;
            insert tpa2;

            redwing__Training_Plan_Achievement__c tpa3 = new redwing__Training_Plan_Achievement__c();
            tpa3.redwing__Achievement__c = ra3.id;
            tpa3.redwing__Training_Plan__c = lPlan.Id;
            insert tpa3;


            //Creating Roster Record
            redwing__ILT_Roster__c objRoster = new redwing__ILT_Roster__c();
            objRoster.redwing__ILT_Class__c = clsRecord.id;
            objRoster.redwing__ILT_Session__c = sessionRecord.id;
            objRoster.redwing__User__c = planAssignment.redwing__User__c;
            objRoster.redwing__Learning_Assignment__c = learningAssignmentupdate.id;

            insert objRoster;

            //Create Achievement Assignment
            redwing__Achievement_Assignment__c raa = new redwing__Achievement_Assignment__c();
            raa.ILT_Class__c = clsRecord.id;
            raa.redwing__Training_Plan_Achievement__c = tpa.Id;
            raa.External_Id__c = 'priyalakshmi.pp@gmail.com' + clsRecord.id;
            insert raa;

            ccrz__E_Product__c product1 = new ccrz__E_Product__c();
            product1.Name = 'Test Prod';
            product1.ccrz__SKU__c = String.ValueOf(System.Now());
            product1.ccrz__Quantityperunit__c = 2.0;
            product1.ccrz__StartDate__c = System.Today().addDays(2);
            product1.ccrz__EndDate__c = System.Today().addDays(20);
            product1.LMS_Learning_Plan__c = lPlan.id;
            insert product1;

            Voucher__c v = new Voucher__c();
            v.ILT_Class__c = clsRecord.id;
            v.Learning_Plan__c = lPlan.Id;
            v.Status__c = 'Claimed';
            insert v;

            v = [select Id, Voucher_Claim__c from Voucher__c where id = :v.id];
            /*Student Test Data*/

            String stringDate = ((DateTime) Date.today().addDays(1)).format('MM/dd/yyyy');

            String json = '{' +
                    '   "ClassDetails": {' +
                    '   "Account": "' + a.id + '",' +
                    '   "Course": "' + lPlan.Id + '",' +
                    '   "StartDate": "' + stringDate + '",' +
                    '   "EndDate": "'+ stringDate +'",' +
                    '   "Students": "10",' +
                    '   "Voucher": "2",' +
                    '   "Address1": "no 4",' +
                    '   "Address2": "Western",' +
                    '   "City": "chei",' +
                    '   "State": "TN",' +
                    '   "Zip": "88888",' +
                    '   "Address": "",' +
                    '   "OpportunityId": "' + opp1.id + '",' +
                    '   "CloudCrazeProdId": "' + product1.id + '",' +
                    '   "Instructor1": "' + UserInfo.getUserId() + '",' +
                    '   "Instructor2": "",' +
                    '   "Location": "' + rdwngLocation.id + '"' +
                    '    }' +
                    '}';

            String json1 = '{' +
                    '    "Students": [' +
                    '        {' +
                    '               "FirstName": "Rajii",' +
                    '               "LastName": "R",' +
                    '               "Email": "Rajissfdc@gmail.com",' +
                    '               "Grade": "Successful",' +
                    '               "Fail Reason": "fail reason",' +
                    '               "AdditionalInfo": "additional info"' +
                    '       },' +
                    '' +
                    '        {' +
                    '               "FirstName": "New",' +
                    '               "LastName": "Tetst",' +
                    '               "Email": "Ashwiisf@gmail.com",' +
                    '               "Phone": "(999) 999-9999",' +
                    '               "Grade": "Successful",' +
                    '               "Fail Reason": "fail reason",' +
                    '               "AdditionalInfo": "additional info"' +
                    '' +
                    '   }' +
                    '   ]' +
                    '}';

            String json2 = '{' +
                    '    "Students": [' +
                    '        {' +
                    '               "Roster": "' + objRoster.id + '",' +
                    '               "Grade": "Successful",' +
                    '               "Reason": "Passed with Distinction",' +
                    '               "AdditionalInfo": "Additional info"' +
                    '       }' +
                    '   ]' +
                    '}';

            /********Test Data Completed*************/

            Test.startTest();
            System.debug('json values' + json);
            System.debug('json1 values' + json1);

            // test isLTSClass method
            ILTInstructorCommunity.isLTSClass(clsRecord.Id);

            // initialize cspWrapper
//            RBCWrapper wrapper = ILTInstructorCommunity.initWrapper();
            RBCWrapper wrapper = populateRBCWrapper(clsRecord.redwing__Start_Date__c, lPlan.Id );

            ILTInstructorCommunity.invokeMethodswithboolean(json, json1, true, wrapper);

            List<redwing__Learning_Assignment__c> LearningAssignmenttest = [Select id, name, Learning_Record_Type__c, redwing__Learning__r.RecordType.Name from redwing__Learning_Assignment__c where redwing__User__r.name = 'Rajii R'];
            System.debug(LearningAssignmenttest);
            System.debug([Select id, name, Learning_Record_Type__c, redwing__Learning__r.RecordType.Name, redwing__User__r.name from redwing__Learning_Assignment__c]);

            System.assertEquals(2, LearningAssignmenttest.size());
            //System.assertEquals('ILT Class',LearningAssignmenttest[0].Learning_Record_Type__c); //Assert to check wthr learning assignments are created properly with proper record type
            //System.assertEquals('ILT Event',LearningAssignmenttest[1].Learning_Record_Type__c);
            ILTInstructorCommunity.assigngrades(json2, 'Supinfo', true);
            System.runAs(partnerUser) {


                List<PermissionSet> permSet = [Select Id,Name From PermissionSet Where Name = 'LMS_External_User'];

                PermissionSetAssignment psa = new PermissionSetAssignment ();
                psa.PermissionSetId = permSet[0].Id;
                psa.AssigneeId = partnerUser.Id;
                insert psa;
                //try {
                ILTInstructorCommunity.savechunk(fileDateBase64, mimetype, false);
                ILTInstructorCommunity.insertVouchers(10, clsRecord.id, lPlan.id);
                ILTInstructorCommunity.validateVourcher(v.id, 'New', 'Tetst');
                ILTInstructorCommunity.initializeStudents(3);
                ILTInstructorCommunity.fetchUser();
                ILTInstructorCommunity.getAccountList();
                ILTInstructorCommunity.fetchLookupValues('Raji', 'Account');
                ILTInstructorCommunity.fetchLookupValues('Priya', 'Course');

                //}catch (Exception e){}
            }
            Test.stopTest();
        }
    }

    private static RBCWrapper populateRBCWrapper(Date classDate, Id lPlanId ) {
        String sessionDate = ( (DateTime) classDate).format('yyyy-MM-dd');
        String wrapperStr = '{"address1":"","address2":"","city":"","classFormat":"","courseName":"Lifeguarding","regType":"","sessionList":[{"classDate":"' + sessionDate + '","endTime":"10:30:00.000","startTime":"09:30:00.000","timeZone":"US/Mountain","formattedStartTime":"12:30 AM","formattedEndTime":"01:30 AM"}],"siteName":"","state":"","timeZoneList":{"US/Eastern":"America/New_York","US/Central":"America/Chicago","US/Mountain":"America/Denver","US/Pacific":"America/Los_Angeles","US/Alaska":"America/Anchorage","US/Arizona":"America/Phoenix","US/Hawaii":"Pacific/Honolulu","America/Puerto_Rico":"America/Puerto_Rico"},"zip":"","courseId":"' + lPlanId + '"}';
//        String wrapperStr = '{"address1":"","address2":"","city":"","classFormat":"","courseName":"Lifeguarding","regType":"","sessionList":[{"classDate":"2019-08-12","endTime":"01:30:00.000","startTime":"00:30:00.000","timeZone":"US/Mountain","formattedStartTime":"12:30 AM","formattedEndTime":"01:30 AM"}],"siteName":"","state":"","timeZoneList":{"US/Eastern":"America/New_York","US/Central":"America/Chicago","US/Mountain":"America/Denver","US/Pacific":"America/Los_Angeles","US/Alaska":"America/Anchorage","US/Arizona":"America/Phoenix","US/Hawaii":"Pacific/Honolulu","America/Puerto_Rico":"America/Puerto_Rico"},"zip":"","courseId":"a3r5B000000AfWdQAK"}';
        RBCWrapper wrapper = (RBCWrapper) JSON.deserialize(wrapperStr, RBCWrapper.class);
        return wrapper;
    }

    static testMethod void addstudentstest() {

        /********Test Data Started*************/

        // create user to run as in order to make sure the user has a role assigned - essential when creating community users
        // SJC - Abandoned this approach - must use an existing user to avoid bucket account assignment of new account created below
        /*
        User u = new User();
        u.FirstName = 'Admin';
        u.LastName = 'User';
        u.Alias = 'admu';
        u.Email = 'admin@user.usr';
        u.Username = '232343admin@user.de';
        u.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
        u.UserRoleId = [Select Id From UserRole Where PortalType = 'None' LIMIT 1].Id;
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';
        insert u;
        */

        User runAsUser = [Select Id,FirstName,LastName,Alias,Email,Username,ProfileId,UserRoleId,TimeZoneSidKey,
                EmailEncodingKey,LanguageLocaleKey,LocaleSidKey from User
                Where IsActive = True And
                    Name != 'Salesforce Automation Account' And UserRoleId != Null
                    And Profile.Name = 'System Administrator' Limit 1];

        //      Where Id = '0050V000006m443' Limit 1];

        System.RunAs(runAsUser) {

            List<id> assp = new list<id>();

            // Bucket_Account_Settings__c bas = [SELECT Bucket_Account_Owner_ID__c, Bucket_Account_RecordTypeID__c, Default_Bucket_Name__c, Maximum_Size_of_Bucket__c FROM Bucket_Account_Settings__c WHERE Default_Bucket_Name__c = 'Bucket Account'];

            // Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Customer Community User' LIMIT 1];

            //Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Development').getRecordTypeId();


            Account a2 = new Account();
            a2.Name = 'SalesforcetestOrg';
            a2.BillingStreet = '24 Willie Mays Plaza';
            a2.BillingCity = 'San Francisco';
            a2.BillingState = 'California';
            a2.BillingPostalCode = '94017';
            a2.BillingCountry = 'USA';
            a2.Phone = '9934200234';
            //a.email='Salesforceredcross@cross.com';
            insert a2;

            Contact c2 = new Contact();
            c2.FirstName = 'New';
            c2.LastName = 'Ttst';
            c2.Email = 'Priyap@gmail.com';
            c2.Account = a2;
            insert c2;

            a2.OwnerId = runAsUser.Id;
            update a2;

            Profile customerProfile = [SELECT Id FROM Profile WHERE Name = 'SB PHSS-IC-Community Plus Login' LIMIT 1];
            //Profile profileId2 = [SELECT Id FROM Profile WHERE Name = 'Learner Community Profile' LIMIT 1];

            User salesRep = new User(LastName = 'Pran',
                    FirstName = 'JASON',
                    Alias = 'pran',
                    Email = 'jason.pran@asdf.com',
                    Username = 'jason.liveston@asdf.com',
                    ProfileId = customerProfile.id,
                    ContactId = c2.Id,
                    TimeZoneSidKey = 'GMT',
                    LanguageLocaleKey = 'en_US',
                    EmailEncodingKey = 'UTF-8',
                    LocaleSidKey = 'en_US'
            );
            insert salesRep;
            assp.add(salesRep.id);

            //Opportunity Creation
            List<BGST_Profiles__c> ProfilesList = new List<BGST_Profiles__c>();
            BGST_Profiles__c indiv = new BGST_Profiles__c();
            indiv.name = 'Owner Profile';
            indiv.Sales_User__c = 'ARC BGST Sales User';
            ProfilesList.add(indiv);
            insert ProfilesList;

            //create an opportunity To fire the trigger on insert
            Opportunity opp = TestUtil.createOpportunity(a2.Id, 'Interview', false);
            opp.OwnerId = salesRep.Id;
            opp.Pricing_Approval_Level__c = Constants.APPROVAL_LEVEL_MOM;
            insert opp;


            redwing__Training_Plan__c lPlan2 = new redwing__Training_Plan__c();
            lPlan2.Name = 'Plan2';
            insert lPlan2;

            System.debug('learning plan id' + lplan2.id);

            redwing__Learning__c learning2 = new redwing__Learning__c();
            learning2.Name = 'Test learning 2';
            learning2.redwing__Published__c = true;
            learning2.RecordTypeId = Schema.SObjectType.redwing__Learning__c.getRecordTypeInfosByName().get('ILT Event').getRecordTypeId();
            insert learning2;


            ccrz__E_Product__c product = new ccrz__E_Product__c();
            product.Name = 'Test Prod';
            product.ccrz__SKU__c = String.ValueOf(System.Now());
            product.ccrz__Quantityperunit__c = 2.0;
            product.ccrz__StartDate__c = System.Today().addDays(2);
            product.ccrz__EndDate__c = System.Today().addDays(20);
            product.LMS_Learning_Plan__c = lPlan2.id;
            insert product;

            Opportunity o = new Opportunity();

            o.Name = 'Community Opportunity';
            o.AccountId = a2.Id;
            o.StageName = 'Approach';
            o.CloseDate = date.today();
            o.Type = 'New Business - FS';
            o.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Order Opportunity').getRecordTypeId();
            o.Source_System__c = 'GeneralStore';

            insert o;

            ccrz__E_Cart__c cartcc = new ccrz__E_Cart__c();
            cartcc.Opportunity__c = o.id;
            cartcc.ccrz__ActiveCart__c = true;
            cartcc.ccrz__EncryptedId__c = 'testId1234';
            insert cartcc;

            redwing__Training_Plan_Section__c lPlanSection2 = new redwing__Training_Plan_Section__c();
            lPlanSection2.Name = 'Test Plan Section';
            lPlanSection2.redwing__Training_Plan__c = lPlan2.Id;
            insert lPlanSection2;

            redwing__Training_Plan_Section_Item__c lPlanSectionItem2 = new redwing__Training_Plan_Section_Item__c();
            lPlanSectionItem2.redwing__Learning__c = learning2.Id;
            lPlanSectionItem2.redwing__Training_Plan_Section__c = lPlanSection2.Id;
            insert lPlanSectionItem2;

            redwing__ILT_Event__c ilEvent2 = new redwing__ILT_Event__c();
            ilEvent2.redwing__Learning__c = learning2.Id;
            insert ilEvent2;
            //Create ILT Class Record
            Redwing__ILT_Class__c clsRecord2 = new Redwing__ILT_Class__c();
            clsRecord2.Skedulo_Account__c = a2.id;
            clsRecord2.redwing__End_Date__c = Date.Parse('12/19/2018');
            clsRecord2.redwing__End_Time__c = '13:00';
            clsRecord2.redwing__Start_Date__c = Date.Parse('12/19/2018');// Assuming Start date = End date
            clsRecord2.redwing__Start_Time__c = '12:00';
            clsRecord2.Name = 'Test';
            clsRecord2.Request_Type__c = 'Community';
            clsRecord2.redwing__Learning__c = learning2.Id;
            insert clsRecord2;

            redwing__ILT_Session__c sessionRecord2 = new redwing__ILT_Session__c();
            sessionRecord2.redwing__ILT_Class__c = clsRecord2.Id;
            sessionRecord2.Skedulo_Account__c = a2.id;
            //End Time is defaulted to "20:00"
            sessionRecord2.redwing__End_Time__c = '13:00';
            sessionRecord2.redwing__Date__c = Date.Parse('12/19/2018');
            //Start Time is defaulted to "08:00"
            sessionRecord2.redwing__Start_Time__c = '12:00';
            insert sessionRecord2;

            redwing__ILT_Instructor__c instructorrecord2 = new redwing__ILT_Instructor__c();
            instructorrecord2.redwing__Instructor__c = salesRep.id;
            instructorrecord2.redwing__ILT_Class__c = clsRecord2.id;
            insert instructorrecord2;

            redwing__Learning_Assignment__c learningAssignmentnew = new redwing__Learning_Assignment__c();
            //learningAssignment.redwing__Contact__c = planAssignment.redwing__Contact__c;
            learningAssignmentnew.redwing__Learning__c = learning2.id; // Retrieve learning id from page 1
            learningAssignmentnew.External_Id__c = 'priyalakshmi.pr@gmail.com'; //Can be chaged if needed
            learningAssignmentnew.redwing__Training_Plan__c = lPlan2.Id;
            insert learningAssignmentnew;

            redwing__Training_Plan_Assignment__c planAssignment2 = new redwing__Training_Plan_Assignment__c();
            planAssignment2.redwing__Training_Plan__c = lPlan2.id; // Retrieved learning plan id based on the course selected in page 1
            //planAssignment.redwing__Contact__r = con;
            planAssignment2.redwing__User__c = UserInfo.getUserId();
            planAssignment2.External_Id__c = 'priyalakshmi.pp@gmail.com';
            insert planAssignment2;

            redwing__ILT_Roster__c objRoster2 = new redwing__ILT_Roster__c();
            objRoster2.redwing__ILT_Class__c = clsRecord2.id;
            objRoster2.redwing__ILT_Session__c = sessionRecord2.id;
            objRoster2.redwing__User__c = planAssignment2.redwing__User__c;
            objRoster2.redwing__Learning_Assignment__c = learningAssignmentnew.id;
            objRoster2.redwing__Status__c = 'Passed';
            insert objRoster2;

            redwing__Achievement_Category__c rac = new redwing__Achievement_Category__c();
            rac.name = 'Skill';
            insert rac;


            redwing__Achievement__c ra = new redwing__Achievement__c();
            ra.redwing__Achievement_Category__c = rac.id;
            ra.redwing__Type__c = 'Certifications';
            insert ra;

            redwing__Prerequisite__c rp = new redwing__Prerequisite__c();
            insert rp;


            redwing__Learning_Prerequisite__c rlp = new redwing__Learning_Prerequisite__c();
            rlp.redwing__Learning__c = lPlanSectionItem2.redwing__Learning__c;
            rlp.redwing__Prerequisite__c = rp.id;
            insert rlp;

            redwing__Achievement_Assignment__c raa = new redwing__Achievement_Assignment__c();
            raa.redwing__Achievement__c = ra.id;
            raa.redwing__User__c = planAssignment2.redwing__User__c;
            raa.redwing__Status__c = 'Acquired';
            insert raa;

            redwing__Prerequisite_Item__c rpi = new redwing__Prerequisite_Item__c();
            rpi.redwing__Prerequisite__c = rp.id;
            rpi.redwing__Required_Status__c = 'Acquired';
            rpi.redwing__Achievement__c = ra.id;
            insert rpi;

            Voucher__c v = new Voucher__c();
            v.ILT_Class__c = clsRecord2.id;
            v.Learning_Plan__c = lPlan2.Id;
            //v.Status__c = 'Claimed';
            insert v;

            String voucheid = v.id;
            String voucherclaimnumber = voucheid.substring(0, voucheid.length() - 3);

            Voucher__c objVoucher = [Select Id from Voucher__c limit 1];


            String json4 = '{' +
                    '    "Students": [' +
                    '        {' +
                    '               "FirstName": "New",' +
                    '               "LastName": "learn3",' +
                    '               "Email": "testlearn3@gmail.com",' +
                    '               "Grade": "",' +
                    '               "Grade": "",' +
                    '               "Fail Reason": "",' +
                    '               "Voucherid": "' + voucherclaimnumber + '",' +
                    '               "AdditionalInfo": "additional info"' +
                    '       },' +
                    '' +
                    '        {' +
                    '               "FirstName": "New1",' +
                    '               "LastName": "t",' +
                    '               "Email": "testlearn4@gmail.com",' +
                    '               "Phone": "(999) 999-9999",' +
                    '               "Grade": "",' +
                    '               "Fail Reason": "",' +
                    '               "AdditionalInfo": "additional info"' +
                    '' +
                    '   }' +
                    '   ]' +
                    '}';
            /********Test Data Completed*************/
            Test.startTest();
            try {

                redwing__Training_Plan_Section_Item__c learningPlanILTEventItem = [
                        Select Id, redwing__Learning__c, redwing__Learning__r.recordtype.Name, redwing__Training_Plan_Section__c
                        from redwing__Training_Plan_Section_Item__c
                        where redwing__Training_Plan_Section__r.redwing__Training_Plan__c = :product.LMS_Learning_Plan__c and redwing__Learning__c != null
                        and redwing__Learning__r.recordtype.Name = 'ILT Event'
                        Limit 1
                ];
                System.debug('Query Answer Retrieved>>>>' + learningPlanILTEventItem);
                ILTInstructorCommunity.auraException = false;
                ILTInstructorCommunity.createOppForCCUpdate(a2.Id, 'GeneralStore', o.id);
                ILTInstructorCommunity.cre = true;
                ILTInstructorCommunity.UserExisting('JASON', 'Pran', 'jason.pran@asdf.com');
                ILTInstructorCommunity.courseInfo(clsRecord2.id);
                ILTInstructorCommunity.CourseInfo objcourse = ILTInstructorCommunity.courseInfo(clsRecord2.id);
                System.assertEquals(1, objcourse.lstStudents.size()); //Assert to check course details are available to sent to close class
                ILTInstructorCommunity.assignUserPermission(assp);
                ILTInstructorCommunity.isValidCourse(lPlan2.id);
                Boolean b = ILTInstructorCommunity.isValidCourse(lPlan2.id);
                ILTInstructorCommunity.IsCartActive(o.id);
                ILTInstructorCommunity.validateVoucher(voucheid);
                ILTInstructorCommunity.checkPrereq(Product.id);
                ILTInstructorCommunity.isCommunityClass(clsRecord2.Id);
                System.assertEquals(true, b);// Assert to confirm if the learning plan section contains ILTEvent type record
                ILTInstructorCommunity.createOppForCC(a2.id, 'GeneralStore');
                ILTInstructorCommunity.getDisplayPaymentInfo(opp.id);
                //IltInstructorCommunity.updateCartProducts(String.valueof(o.id),String.valueof(Product.id),'2');
                ILTInstructorCommunity.getLearningPlanId(Product.id);


            } catch (Exception e) {
                System.assertEquals(e.getMessage(), 'Invalid details');
            }
            Test.stopTest();
        }
    }

    static testMethod void myunittest3(){

        /********Test Data Started*************/

        Account a3 = new Account();
        a3.Name='SalesforcetestOrg';
        a3.BillingStreet='24 Willie Mays Plaza';
        a3.BillingCity='San Francisco';
        a3.BillingState='California';
        a3.BillingPostalCode='94017';
        a3.BillingCountry='USA';
        a3.Phone='9934200234';
        //a.email='Salesforceredcross@cross.com';
        insert a3;

        redwing__Learning__c learning3 = new redwing__Learning__c();
        learning3.Name = 'Test learning 2';
        learning3.redwing__Published__c = true;
        learning3.RecordTypeId = Schema.SObjectType.redwing__Learning__c.getRecordTypeInfosByName().get('ILT Event').getRecordTypeId();
        insert learning3;

        redwing__Training_Plan__c lPlan3 = new redwing__Training_Plan__c();
        lPlan3.Name = 'Plan3';
        insert lPlan3;

        Redwing__ILT_Class__c clsRecord3 = new Redwing__ILT_Class__c();
        clsRecord3.Skedulo_Account__c = a3.id;
        clsRecord3.redwing__End_Date__c = Date.Parse('12/19/2018');
        clsRecord3.redwing__End_Time__c= '13:00';
        clsRecord3.redwing__Start_Date__c = Date.Parse('12/19/2018');// Assuming Start date = End date
        clsRecord3.redwing__Start_Time__c = '12:00';
        clsRecord3.Name = 'Test';
        clsRecord3.redwing__Learning__c = learning3.Id;
        insert clsRecord3;

        Voucher__c  v = new Voucher__c();
        v.ILT_Class__c = clsRecord3.id;
        v.Learning_Plan__c = lPlan3.Id;
        v.Status__c = 'Issued';
        insert v;

        String voucheid= v.id;
        String voucherclaimnumber = voucheid.substring(0,voucheid.length()-3);

        String json1 = '{'+
                ' "Students": ['+
                ' {'+
                ' "FirstName": "test",'+
                ' "LastName": "learn3",'+
                ' "Email": "testlearn3@gmail.com",'+
                ' "Phone": "1234567890",'+
                ' "Voucherid": "'+voucherclaimnumber +'"'+
                ' }'+
                ' ]'+
                '}';
        /********Test Data Completed*************/

        try{
            ILTInstructorCommunity.addStudents(json1);
        }
        Catch(Exception e)
        {
        }
    }
    static testmethod void test_Changecartowner() {

        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Bucket Account').getRecordTypeId();
        
        //Bucket Custom settings
//        Bucket_Account_Settings__c bas = Bucket_Account_Settings__c.getOrgDefaults();
//        bas.Bucket_Account_Owner_ID__c = UserInfo.getUserID();
//        bas.Bucket_Account_RecordTypeID__c = recordTypeId;
//        bas.Default_Bucket_Name__c = 'Bucket Account';
//        bas.Maximum_Size_of_Bucket__c = 5000;
//        insert bas;

        // Bucket_Account_Settings__c bas = [SELECT Bucket_Account_Owner_ID__c, Bucket_Account_RecordTypeID__c, Default_Bucket_Name__c, Maximum_Size_of_Bucket__c FROM Bucket_Account_Settings__c WHERE Default_Bucket_Name__c = 'Bucket Account' ];

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
        
        Opportunity o = new Opportunity();

        o.Name          = 'Community Opportunity';
        o.AccountId     = a.Id;
        o.StageName     = 'Approach';
        o.CloseDate     = date.today();
        o.Type          = 'New Business - FS';
        o.RecordTypeId  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Order Opportunity').getRecordTypeId();
        o.Source_System__c = 'GeneralStore';

        insert o;

        ccrz__E_Cart__c cartcc = new ccrz__E_Cart__c();
        cartcc.Opportunity__c = o.id;
        cartcc.ccrz__ActiveCart__c = true;
        cartcc.ccrz__EncryptedId__c = 'testId1234';
        insert cartcc;

        Test.startTest();

        // call isactiveCart on ILT comm class

        ccrz__E_Cart__c cart = ILTInstructorCommunity.Changecartowner(o.Id, 'testId1234');
        Test.stopTest();
        System.debug(cart);

        System.assertEquals(UserInfo.getUserId(), cart.OwnerId);

    }

    static testMethod void test_updateCartProducts() {

        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Bucket Account').getRecordTypeId();

        //Bucket Custom settings
        // Bucket_Account_Settings__c bas = [SELECT Bucket_Account_Owner_ID__c, Bucket_Account_RecordTypeID__c, Default_Bucket_Name__c, Maximum_Size_of_Bucket__c FROM Bucket_Account_Settings__c WHERE Default_Bucket_Name__c = 'Bucket Account' ];

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

        Opportunity o = new Opportunity();

        o.Name          = 'Community Opportunity';
        o.AccountId     = a.Id;
        o.StageName     = 'Approach';
        o.CloseDate     = date.today();
        o.Type          = 'New Business - FS';
        o.RecordTypeId  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Order Opportunity').getRecordTypeId();
        o.Source_System__c = 'GeneralStore';
        insert o;

        ccrz__E_Cart__c cartcc = new ccrz__E_Cart__c();
        cartcc.Opportunity__c = o.id;
        cartcc.ccrz__ActiveCart__c = true;
        cartcc.ccrz__EncryptedId__c = 'testId1234';
        insert cartcc;

        // create cloud craze product.
        ccrz__E_Product__c ccprod = new ccrz__E_Product__c(
                Name = 'Lifeguarding',
                ccrz__SKU__c = 'HSSAQU402',
                ccrz__Quantityperunit__c = 1,
                ccrz__StartDate__c = Date.today(),
                ccrz__EndDate__c = Date.today().addMonths(12)
        );

        insert ccprod;

        Test.startTest();
        Map<String, Object> retMap = ILTInstructorCommunity.updateCartProducts(o.Id, ccprod.Id, '3');
        Test.stopTest();

        System.debug(retMap);
    }

    static testMethod void test_SendEmail() {

        Test.startTest();
        ILTInstructorCommunity.sendEmail();
        Test.stopTest();
    }

    static testMethod void test_isLTSProduct() {

        ccrz__E_Product__c ccprod = new ccrz__E_Product__c(
                Name = 'Lifeguarding',
                ccrz__SKU__c = 'HSSAQU402',
                ccrz__Quantityperunit__c = 1,
                ccrz__StartDate__c = Date.today(),
                ccrz__EndDate__c = Date.today().addMonths(12)
        );
        insert ccprod;

        ccrz__E_Spec__c spec = new ccrz__E_Spec__c(
                Name = 'Class'
        );
        insert spec;

        ccrz__E_ProductSpec__c prodSpecs = new ccrz__E_ProductSpec__c(
                ccrz__SpecValue__c = 'LTS',
                ccrz__Product__c = ccprod.Id,
                ccrz__Spec__c = spec.Id
        );
        insert prodSpecs;

        Test.startTest();
        Map<String, Object>  retMap = ILTInstructorCommunity.isLTSProduct(ccprod.Id);
        Test.stopTest();
        System.debug(retMap);
    }

    static testMethod void test_fetchUserName() {
        // test else condition in fetch username

        // add email address to the map in ILTInstructorCommunity
        ILTInstructorCommunity.userNameEmailMap = new Map<String, String>();
        ILTInstructorCommunity.userNameEmailMap.put('existingUser@redcross.org', 'existingUser@redcross.org');


        JSONWrapper.Students student = new JSONWrapper.Students();
        student.FirstName = 'Joseph';
        student.LastName = 'Drummond';
        student.Email = 'existingUser@redcross.org';

        String username = ILTInstructorCommunity.fetchUserName(student);
        System.debug(username);
        System.assertNotEquals('existingUser@redcross.org', username);
    }

    static testMethod void test_enrollStudents () {

        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Bucket Account').getRecordTypeId();

        //Bucket Custom settings
        // Bucket_Account_Settings__c bas = [SELECT Bucket_Account_Owner_ID__c, Bucket_Account_RecordTypeID__c, Default_Bucket_Name__c, Maximum_Size_of_Bucket__c FROM Bucket_Account_Settings__c WHERE Default_Bucket_Name__c = 'Bucket Account' ];

        redwing__Training_Plan__c lPlan = new redwing__Training_Plan__c();
        lPlan.Name = 'Test Plan';
        insert lPlan;

        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('Students');
        gen.writeStartArray();
        gen.writeStartObject();
        gen.writeStringField('FirstName', 'Guadalupe');
        gen.writeStringField('LastName', 'Zamora');
        gen.writeStringField('Email', 'someemail@sdfsdf.de');
        gen.writeEndObject();
        gen.writeEndArray();
        gen.writeEndObject();

        String jsonStr = gen.getAsString();

        IlTInstructorCommunity.enrollStudents(jsonStr, lPlan.Id, 'Online', 'vbg203');

    }

    static testMethod void test_saveChunk() {

        String fileData = 'Name' + ',' + 'LastName' + ',' + 'Email' + ',' + 'Phonenumber' + '\n' + 'test1' + ',' + 't' + ',' + 'test1t@cfr.com' + ',' + '8888888888';
        String fileDateBase64 = EncodingUtil.base64Encode(Blob.valueOf(fileData));
        String mimetype = 'text/csv;base64,';
        String fileName = 'SampleTest.csv';
        String finalFileData = mimetype + fileDateBase64;

        ILTInstructorCommunity.saveChunk(fileDateBase64, mimetype, true);
    }

    static testMethod void test_isCartActive() {

        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Bucket Account').getRecordTypeId();

        //Bucket Custom settings

        // Bucket_Account_Settings__c bas = [SELECT Bucket_Account_Owner_ID__c, Bucket_Account_RecordTypeID__c, Default_Bucket_Name__c, Maximum_Size_of_Bucket__c FROM Bucket_Account_Settings__c WHERE Default_Bucket_Name__c = 'Bucket Account' ];


        Account a2 = new Account();
        a2.Name='SalesforcetestOrg';
        a2.BillingStreet='24 Willie Mays Plaza';
        a2.BillingCity='San Francisco';
        a2.BillingState='California';
        a2.BillingPostalCode='94017';
        a2.BillingCountry='USA';
        a2.Phone='9934200234';
        insert a2;

        Opportunity o = new Opportunity();
        o.Name          = 'Community Opportunity';
        o.AccountId     = a2.Id;
        o.StageName     = 'Approach';
        o.CloseDate     = date.today();
        o.Type          = 'New Business - FS';
        o.RecordTypeId  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Order Opportunity').getRecordTypeId();
        o.Source_System__c = 'GeneralStore';
        insert o;

        List<ccrz__E_Cart__c> carts = new List<ccrz__E_Cart__c>();
        ccrz__E_Cart__c cartcc = new ccrz__E_Cart__c();
        cartcc.Opportunity__c = o.id;
        cartcc.ccrz__ActiveCart__c = false;
        cartcc.ccrz__EncryptedId__c = 'testId1234';
        carts.add(cartcc);

        ccrz__E_Cart__c cartcc2 = new ccrz__E_Cart__c();
        cartcc2.Opportunity__c = o.id;
        cartcc2.ccrz__ActiveCart__c = false;
        cartcc2.ccrz__EncryptedId__c = 'testId1235';
        carts.add(cartcc2);

        ccrz__E_Cart__c cartcc3 = new ccrz__E_Cart__c();
        cartcc3.Opportunity__c = o.id;
        cartcc3.ccrz__ActiveCart__c = false;
        cartcc3.ccrz__EncryptedId__c = 'testId1236';
        carts.add(cartcc3);

        insert carts;

        Object obj = ILTInstructorCommunity.IsCartActive(o.Id);
        System.debug(obj);
    }

    static testMethod void test_fetchUser() {
        // cover if scenario fetchUser(JSONWrapper.Students student, Boolean boolRetVal) != null

        IlTInstructorCommunity.userMap = new Map<String, User>();

        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Bucket Account').getRecordTypeId();

        //Bucket Custom settings
        // Bucket_Account_Settings__c bas = [SELECT Bucket_Account_Owner_ID__c, Bucket_Account_RecordTypeID__c, Default_Bucket_Name__c, Maximum_Size_of_Bucket__c FROM Bucket_Account_Settings__c WHERE Default_Bucket_Name__c = 'Bucket Account' ];

        Account a = new Account();
        a.Name='SalesforcetestOrg';
        a.BillingStreet='24 Willie Mays Plaza';
        a.BillingCity='San Francisco';
        a.BillingState='California';
        a.BillingPostalCode='94017';
        a.BillingCountry='USA';
        a.Phone='9934200234';
        insert a;

        Contact c = new Contact();
        c.FirstName = 'Joseph';
        c.LastName = 'Drummond';
        c.Email = 'existingUser@redcross.org';
        c.AccountId = a.Id;
        insert c;


        JSONWrapper.Students student = new JSONWrapper.Students();
        student.FirstName = 'Joseph';
        student.LastName = 'Drummond';
        student.Email = 'existingUser@redcross.org';


        User u = IlTInstructorCommunity.fetchUser(student, true);

        System.debug(u);
    }
    
    static testMethod void test_createILTLocation() {

        Account a = new Account(Name='Test Account');
        insert a;

        String name = 'Site0';
        String address1 = '30 John Court';
        String address2 = '';
        String postcode = '33428';
        String state = 'FL';
        String city = 'Boca Raton';

        // ILTInstructorCommunity.isLTSClass(String classId);
        Test.startTest();
        Id locationId = ILTInstructorCommunity.createIltLocation(a.Id, name, address1, address2, postcode, state, city);
        Test.stopTest();
        System.assertNotEquals(null, locationId);

        // calling the method with the same address data, should not create new record but return Id of the existing one
        Id locationId2 = ILTInstructorCommunity.createIltLocation(a.Id, 'Other name for the site', address1, address2, postcode, state, city);
        System.assertEquals(locationId, locationId2);
    }

    static testMethod void test_initWrapper() {

        Test.startTest();
        RBCWrapper wrapper = ILTInstructorCommunity.initWrapper();
        Test.stopTest();
    }

    static testMethod void test_handleFullServiceClass() {


        Map<String, Object> data = phss_cc_TestDataFactory.createInsertTestLearningObjects();
        redwing__ILT_Class__c iltClass = (redwing__ILT_Class__c) data.get(phss_cc_TestDataFactory.TEST_ILT_CLASS);

        // FS test data - obtain training event
        Map<String, Object> fsMapData = skedDataSetup.setupFullServiceTestData();

        // TO DO: create transaction payment

        Training_Events__c te = [SELECT Id FROM Training_Events__c LIMIT 1];

        Test.startTest();
        ILTInstructorCommunity.handleFullServiceClass(iltClass.Id, 2, te.Id);
        Test.stopTest();

    }
}