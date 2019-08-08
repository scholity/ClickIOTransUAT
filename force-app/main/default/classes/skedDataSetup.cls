public class skedDataSetup {
    
    public static Map<string, sObject> setupCommonTestData() {
        /***********************************************************Set up cusstom settings*************************************************/
        sked_Admin_Setting__c adminSetting = sked_Admin_Setting__c.getOrgDefaults();
        adminSetting.Google_Travel_Time_Enabled__c = TRUE;
        adminSetting.API_Token__c = 'skeduloapitoken';
        upsert adminSetting;

        /***********************************************************End of Set up cusstom settings*************************************************/

        string timezoneSidId = UserInfo.getTimeZone().getId();
        
        Date nextMonthStartDate = system.today().toStartOfMonth().addMonths(1);
        
        Date startDate = nextMonthStartDate.addDays(7).toStartOfWeek();
        DateTime startTime = DateTime.newInstance(startDate, time.newInstance(0, 0, 0, 0));
        
        Date nextWeekStartDate = startDate.addDays(7);
        DateTime nextWeekStartTime = DateTime.newInstance(nextWeekStartDate, time.newInstance(0, 0, 0, 0));
        
        Map<string, sObject> mapTestData = new Map<string, sObject>();
        List<sObject> firstList = new List<sObject>();

        /***********************************************************Bucket Account Settings*************************************************/
        Bucket_Account_Settings__c bucketSetting = new Bucket_Account_Settings__c(
            Bucket_Account_Owner_ID__c = '005d0000001WOeV',
            Bucket_Account_RecordTypeID__c = '012d000000098Wt',
            Maximum_Size_of_Bucket__c = 5000,
            Default_Bucket_Name__c = 'Bucket Account',
            Name = 'Test Bucket'
        );
        firstList.add(bucketSetting);

        BGST_Approvers__c approver = new BGST_Approvers__c(
            Approver_1__c = UserInfo.getUserId(),
            Approver_2__c = UserInfo.getUserId(),
            Name = 'Approvers Id'
        );
        firstList.add(approver);

        BGST_Profiles__c profile = new BGST_Profiles__c(
            Sales_Admin__c = 'ARC BGST Sales Admin',
            Sales_User__c = 'ARC BGST Sales User',
            Name = 'Owner Profile'
        );
        firstList.add(profile);
        
        /***********************************************************Course_Catalog__c******************************************************/
        Course_Catalog__c courseCatalog1 = new Course_Catalog__c(
            name = 'Adult First Aid/CPR/AED',
            Type__c = 'Full Service;Community;Nurse Assistant Training;Nurse Assistant Testing'
        );
        firstList.add(courseCatalog1);
        mapTestData.put('courseCatalog1', courseCatalog1);

        Course_Catalog__c courseCatalog2 = new Course_Catalog__c(
            name = 'Basic life support',
            Type__c = 'Full Service;Community;Nurse Assistant Training;Nurse Assistant Testing'
        );
        firstList.add(courseCatalog2);
        mapTestData.put('courseCatalog2', courseCatalog2);

        /***********************************************************Account****************************************************************/
        Account testAccount = new Account (
            name='test',
            Status__c='Active',
            BillingPostalcode='94102',
            BillingCity='San Francisco',
            Billingstreet='6850 Geary Blvd',
            BillingCountry='USA',
            BillingState='CA',
            Shippingstreet='6850 Geary Blvd',
            ShippingCountry='USA',
            ShippingCity='San Francisco',
            ShippingState='CA',
            ShippingPostalCode='94102',
            Agreement_Covers__c = 'Single Location',
            Phone = '(864) 884-3766'
            );
        firstList.add(testAccount);
        mapTestData.put('testAccount', testAccount);
        
        /***********************************************************Skedulo Regions****************************************************************/
        sked__Region__c sanFranciscoRegion = new sked__Region__c(
            Name = 'San Francisco',
            sked__Timezone__c = timezoneSidId,
            sked__Country_Code__c = 'US'
        );
        firstList.add(sanFranciscoRegion);
        mapTestData.put('sanFranciscoRegion', sanFranciscoRegion);
        
        /*********************************************************Tag**************************************************/
        sked__Tag__c tagPickup = new sked__Tag__c(
            Name = 'PickUp',
            sked__Type__c = 'Skill',
            sked__Classification__c = 'Global'
        );
        firstList.add(tagPickup);
        mapTestData.put('tagPickup', tagPickup);
        
        sked__Tag__c tagDelivery = new sked__Tag__c(
            Name = 'Delivery',
            sked__Type__c = 'Skill',
            sked__Classification__c = 'Global'
        );
        firstList.add(tagDelivery);
        mapTestData.put('tagDelivery', tagDelivery);
        
        /***********************************************************Availability Template****************************************************************/
        sked__Availability_Template__c availabilityTemplate = new sked__Availability_Template__c();
        firstList.add(availabilityTemplate);
        
        /*********************************************************Holidays**************************************************/
        sked__Holiday__c globalHoliday = new sked__Holiday__c(
            Name = 'Global Holidays',
            sked__Start_Date__c = startDate,
            sked__End_Date__c = startDate,
            sked__Global__c = true
        );
        firstList.add(globalHoliday);
        
        sked__Holiday__c sanFranciscoRegionHoliday = new sked__Holiday__c(
            Name = 'Test Region Holidays',
            sked__Start_Date__c = startDate,
            sked__End_Date__c = startDate,
            sked__Global__c = false
        );
        firstList.add(sanFranciscoRegionHoliday);
        
        insert firstList;
        List<sObject> secondList = new List<sObject>();

        /*********************************************************Locations**************************************************/
        sked__Location__c communityLocation1 = new sked__Location__c(
            Name = 'Community Location 1',
            sked__Address__c = 'Cole Valley, San Francisco, CA 94117',
            sked__GeoLocation__Latitude__s = 37.768130,
            sked__GeoLocation__Longitude__s = -122.450445,
            sked__Type__c = skedConstants.LOCATION_TYPE_COMMUNITY,
            Is_Active__c = TRUE,
            Facility_ID__c = 'community1',
            sked__Region__c = sanFranciscoRegion.Id
        );
        secondList.add(communityLocation1);
        mapTestData.put('communityLocation1', communityLocation1);

        sked__Location__c communityLocation2 = new sked__Location__c(
            Name = 'Community Location 2',
            sked__Address__c = 'Cole Valley, San Francisco, CA 94117',
            sked__GeoLocation__Latitude__s = 37.768130,
            sked__GeoLocation__Longitude__s = -122.450445,
            sked__Type__c = skedConstants.LOCATION_TYPE_COMMUNITY,
            Is_Active__c = TRUE,
            Facility_ID__c = 'community2',
            sked__Region__c = sanFranciscoRegion.Id
        );
        secondList.add(communityLocation2);
        mapTestData.put('communityLocation2', communityLocation2);

        sked__Location__c cepLocation1 = new sked__Location__c(
            Name = 'CEP Location 1',
            sked__Address__c = 'Cole Valley, San Francisco, CA 94117',
            sked__GeoLocation__Latitude__s = 37.768130,
            sked__GeoLocation__Longitude__s = -122.450445,
            sked__Type__c = skedConstants.LOCATION_TYPE_NURSE_ASSISTANT_TESTING,
            Is_Active__c = TRUE,
            Facility_ID__c = 'cep1',
            sked__Region__c = sanFranciscoRegion.Id
        );
        secondList.add(cepLocation1);
        mapTestData.put('cepLocation1', cepLocation1);

        sked__Location__c cepLocation2 = new sked__Location__c(
            Name = 'CEP Location 2',
            sked__Address__c = 'Cole Valley, San Francisco, CA 94117',
            sked__GeoLocation__Latitude__s = 37.768130,
            sked__GeoLocation__Longitude__s = -122.450445,
            sked__Type__c = skedConstants.LOCATION_TYPE_NURSE_ASSISTANT_TESTING,
            Is_Active__c = TRUE,
            Facility_ID__c = 'cep2',
            sked__Region__c = sanFranciscoRegion.Id
        );
        secondList.add(cepLocation2);
        mapTestData.put('cepLocation2', cepLocation2);

        sked__Location__c natLocation1 = new sked__Location__c(
            Name = 'NAT Location 1',
            sked__Address__c = 'Cole Valley, San Francisco, CA 94117',
            sked__GeoLocation__Latitude__s = 37.768130,
            sked__GeoLocation__Longitude__s = -122.450445,
            sked__Type__c = skedConstants.LOCATION_TYPE_NURSE_ASSISTANT_TRAINING,
            Is_Active__c = TRUE,
            Facility_ID__c = 'nat1',
            sked__Region__c = sanFranciscoRegion.Id
        );
        secondList.add(natLocation1);
        mapTestData.put('natLocation1', natLocation1);

        sked__Location__c natLocation2 = new sked__Location__c(
            Name = 'CEP Location 2',
            sked__Address__c = 'Cole Valley, San Francisco, CA 94117',
            sked__GeoLocation__Latitude__s = 37.768130,
            sked__GeoLocation__Longitude__s = -122.450445,
            sked__Type__c = skedConstants.LOCATION_TYPE_NURSE_ASSISTANT_TRAINING,
            Is_Active__c = TRUE,
            Facility_ID__c = 'nat2',
            sked__Region__c = sanFranciscoRegion.Id
        );
        secondList.add(natLocation2);
        mapTestData.put('natLocation2', natLocation2);
        /*********************************************************Region holidays**************************************************/
        sked__Holiday_Region__c sanFranciscoRegionHolidayRegion = new sked__Holiday_Region__c(
            sked__Holiday__c = sanFranciscoRegionHoliday.Id,
            sked__Region__c = sanFranciscoRegion.Id
        );
        secondList.add(sanFranciscoRegionHolidayRegion);
        mapTestData.put('sanFranciscoRegionHolidayRegion', sanFranciscoRegionHolidayRegion);

        /***********************************************************Contact****************************************************************/
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            AccountId = testAccount.Id,
            Phone = '(999) 999-9999',
            Email = 'qvuong@ceo.com.test'
        );
        secondList.add(testContact);
        mapTestData.put('testContact', testContact);
        
        /***********************************************************Availability Template Entry****************************************************************/
        sked__Availability_Template_Entry__c monEntry = new sked__Availability_Template_Entry__c(sked__Availability_Template__c = availabilityTemplate.Id, sked__Weekday__c = 'MON', sked__Start_Time__c = 700, sked__Finish_Time__c = 1900, sked__Is_Available__c = true);
        secondList.add(monEntry);
        sked__Availability_Template_Entry__c tueEntry = new sked__Availability_Template_Entry__c(sked__Availability_Template__c = availabilityTemplate.Id, sked__Weekday__c = 'TUE', sked__Start_Time__c = 700, sked__Finish_Time__c = 1900, sked__Is_Available__c = true);
        secondList.add(tueEntry);
        sked__Availability_Template_Entry__c wedEntry = new sked__Availability_Template_Entry__c(sked__Availability_Template__c = availabilityTemplate.Id, sked__Weekday__c = 'WED', sked__Start_Time__c = 700, sked__Finish_Time__c = 1900, sked__Is_Available__c = true);
        secondList.add(wedEntry);
        sked__Availability_Template_Entry__c thuEntry = new sked__Availability_Template_Entry__c(sked__Availability_Template__c = availabilityTemplate.Id, sked__Weekday__c = 'THU', sked__Start_Time__c = 700, sked__Finish_Time__c = 1900, sked__Is_Available__c = true);
        secondList.add(thuEntry);
        sked__Availability_Template_Entry__c friEntry = new sked__Availability_Template_Entry__c(sked__Availability_Template__c = availabilityTemplate.Id, sked__Weekday__c = 'FRI', sked__Start_Time__c = 700, sked__Finish_Time__c = 1900, sked__Is_Available__c = true);
        secondList.add(friEntry);
        sked__Availability_Template_Entry__c satEntry = new sked__Availability_Template_Entry__c(sked__Availability_Template__c = availabilityTemplate.Id, sked__Weekday__c = 'SAT', sked__Start_Time__c = 700, sked__Finish_Time__c = 1900, sked__Is_Available__c = true);
        secondList.add(satEntry);
        sked__Availability_Template_Entry__c sunEntry = new sked__Availability_Template_Entry__c(sked__Availability_Template__c = availabilityTemplate.Id, sked__Weekday__c = 'SUN', sked__Start_Time__c = 700, sked__Finish_Time__c = 1900, sked__Is_Available__c = true);
        secondList.add(sunEntry);
        
        insert secondList;
        
        List<sObject> thirdList = new List<sObject>();
        /***********************************************************Opportunity****************************************************************/
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            CloseDate = system.today().addDays(14),
            StageName = 'Prospecting',
            AccountId = testAccount.Id
            //npsp__Primary_Contact__c = testContact.Id
        );
        thirdList.add(testOpportunity);
        mapTestData.put('testOpportunity', testOpportunity);
        /***********************************************************Resource****************************************************************/
        sked__Resource__c instructor1 = new sked__Resource__c(
            Name = 'instructor 1',
            sked__Category__c = skedConstants.RESOURCE_CATEGORY_INSTRUCTOR,
            sked__Home_Address__c = '50 Moraga Ave, San Francisco, CA 94129',
            sked__GeoLocation__Latitude__s = 37.787866,
            sked__GeoLocation__Longitude__s = -122.441803,
            sked__Primary_Region__c = sanFranciscoRegion.Id,
            sked__Notification_Type__c = 'push',
            sked__Country_Code__c = 'US',
            sked__Is_Active__c = true,
            Employment_Type__c = 'FT',
            sked__User__c = UserInfo.getUserId(),
            sked__Email__c = 'instructor1@email.com.test'
        );
        thirdList.add(instructor1);
        mapTestData.put('instructor1', instructor1);
        
        sked__Resource__c instructor2 = new sked__Resource__c(
            Name = 'instructor 2',
            sked__Category__c = skedConstants.RESOURCE_CATEGORY_INSTRUCTOR,
            sked__Home_Address__c = '347 Presidio Ave, San Francisco, CA 94115',
            sked__GeoLocation__Latitude__s = 37.788400,
            sked__GeoLocation__Longitude__s = -122.447064,
            sked__Primary_Region__c = sanFranciscoRegion.Id,
            sked__Notification_Type__c = 'push',
            sked__Country_Code__c = 'US',
            sked__Is_Active__c = true,
            Employment_Type__c = 'FT',
            sked__Email__c = 'instructor2@email.com.test'
        );
        thirdList.add(instructor2);
        mapTestData.put('instructor2', instructor2);
        
        sked__Resource__c instructor3 = new sked__Resource__c(
            Name = 'instructor 3',
            sked__Category__c = skedConstants.RESOURCE_CATEGORY_INSTRUCTOR,
            sked__Home_Address__c = '514 Presidio Ave, San Francisco, CA 94115',
            sked__GeoLocation__Latitude__s = 37.786896,
            sked__GeoLocation__Longitude__s = -122.446684,
            sked__Primary_Region__c = sanFranciscoRegion.Id,
            sked__Notification_Type__c = 'push',
            sked__Country_Code__c = 'US',
            sked__Is_Active__c = true,
            Employment_Type__c = 'FT',
            sked__Email__c = 'instructor3@email.com.test'
        );
        thirdList.add(instructor3);
        mapTestData.put('instructor3', instructor3);
        
        sked__Resource__c subcontractor1 = new sked__Resource__c(
            Name = 'subcontractor 1',
            sked__Category__c = skedConstants.RESOURCE_CATEGORY_INSTRUCTOR,
            sked__Home_Address__c = '514 Presidio Ave, San Francisco, CA 94115',
            sked__GeoLocation__Latitude__s = 37.786896,
            sked__GeoLocation__Longitude__s = -122.446684,
            sked__Primary_Region__c = sanFranciscoRegion.Id,
            sked__Notification_Type__c = 'push',
            sked__Country_Code__c = 'US',
            sked__Is_Active__c = true,
            Employment_Type__c = skedConstants.RESOURCE_EMPLOYMENT_TYPE_SUBCONTRACTOR,
            sked__Email__c = 'subcontractor1@email.com.test'
        );
        thirdList.add(subcontractor1);
        mapTestData.put('subcontractor1', subcontractor1);
        insert thirdList;
        
        List<sObject> forthList = new List<sObject>();
        /***********************************************************Availability Template Resource****************************************************************/
        sked__Availability_Template_Resource__c avaiTempInstructor1 = new sked__Availability_Template_Resource__c(sked__Availability_Template__c = availabilityTemplate.Id, sked__Resource__c = instructor1.Id);
        forthList.add(avaiTempInstructor1);
        sked__Availability_Template_Resource__c avaiTempInstructor2 = new sked__Availability_Template_Resource__c(sked__Availability_Template__c = availabilityTemplate.Id, sked__Resource__c = instructor2.Id);
        forthList.add(avaiTempInstructor2);
        sked__Availability_Template_Resource__c avaiTempInstructor3 = new sked__Availability_Template_Resource__c(sked__Availability_Template__c = availabilityTemplate.Id, sked__Resource__c = instructor3.Id);
        forthList.add(avaiTempInstructor3);
        /*********************************************************Resource Tags**************************************************/
        sked__Resource_Tag__c instructor1_pickup = new sked__Resource_Tag__c(
            sked__Resource__c = instructor1.Id,
            sked__Tag__c = tagPickup.Id
        );
        forthList.add(instructor1_pickup);
        
        sked__Resource_Tag__c instructor1_delivery = new sked__Resource_Tag__c(
            sked__Resource__c = instructor1.Id,
            sked__Tag__c = tagDelivery.Id
        );
        forthList.add(instructor1_delivery);
        
        sked__Resource_Tag__c instructor2_pickup = new sked__Resource_Tag__c(
            sked__Resource__c = instructor2.Id,
            sked__Tag__c = tagPickup.Id
        );
        forthList.add(instructor2_pickup);
        
        sked__Resource_Tag__c instructor2_delivery = new sked__Resource_Tag__c(
            sked__Resource__c = instructor2.Id,
            sked__Tag__c = tagDelivery.Id
        );
        forthList.add(instructor2_delivery);
        
        sked__Resource_Tag__c instructor3_pickup = new sked__Resource_Tag__c(
            sked__Resource__c = instructor3.Id,
            sked__Tag__c = tagPickup.Id
        );
        forthList.add(instructor3_pickup);
        
        sked__Resource_Tag__c instructor3_delivery = new sked__Resource_Tag__c(
            sked__Resource__c = instructor3.Id,
            sked__Tag__c = tagDelivery.Id
        );
        forthList.add(instructor3_delivery);
        /***********************************************************Resource's Events****************************************************************/
        sked__Availability__c instructor1Avail1 = new sked__Availability__c(
            sked__Start__c = startTime.addHours(7),
            sked__Finish__c = startTime.addHours(8),
            sked__Is_Available__c = FALSE,
            sked__Resource__c = instructor1.Id,
            sked__Status__c = 'Approved'
        );
        forthList.add(instructor1Avail1);
        
        sked__Availability__c instructor1Avail2 = new sked__Availability__c(
            sked__Start__c = startTime.addHours(7),
            sked__Finish__c = startTime.addHours(8),
            sked__Is_Available__c = TRUE,
            sked__Resource__c = instructor1.Id,
            sked__Status__c = 'Approved'
        );
        forthList.add(instructor1Avail2);
        
        List<skedModels.selectOption> activityTypes = skedUtils.getPickListValues('sked__Activity__c', 'sked__Type__c');
        sked__Activity__c instructor1Activity = new sked__Activity__c(
            sked__Start__c = startTime.addHours(9),
            sked__End__c = startTime.addHours(10),
            sked__Address__c = instructor1.sked__Home_Address__c,
            sked__GeoLocation__Latitude__s = instructor1.sked__GeoLocation__Latitude__s,
            sked__GeoLocation__Longitude__s = instructor1.sked__GeoLocation__Longitude__s,
            sked__Resource__c = instructor1.Id,
            sked__Type__c = activityTypes.get(0).id
        );
        forthList.add(instructor1Activity);
        
        sked__Activity__c instructor2Activity = new sked__Activity__c(
            sked__Start__c = startTime.addDays(1).addHours(9),
            sked__End__c = startTime.addDays(1).addHours(10),
            sked__Address__c = instructor2.sked__Home_Address__c,
            sked__GeoLocation__Latitude__s = instructor2.sked__GeoLocation__Latitude__s,
            sked__GeoLocation__Longitude__s = instructor2.sked__GeoLocation__Longitude__s,
            sked__Resource__c = instructor2.Id,
            sked__Type__c = activityTypes.get(0).id
        );
        forthList.add(instructor2Activity);
        
        sked__Activity__c instructor2Activity2 = new sked__Activity__c(
            sked__Start__c = startTime.addDays(2).addHours(16),
            sked__End__c = startTime.addDays(2).addHours(17),
            sked__Address__c = instructor2.sked__Home_Address__c,
            sked__GeoLocation__Latitude__s = instructor2.sked__GeoLocation__Latitude__s,
            sked__GeoLocation__Longitude__s = instructor2.sked__GeoLocation__Longitude__s,
            sked__Resource__c = instructor2.Id,
            sked__Type__c = activityTypes.get(0).id
        );
        forthList.add(instructor2Activity2);
        /***********************************************************Availability Template Resource****************************************************************/
        sked__Availability_Template_Resource__c avaiTempSiteSurveyor1 = new sked__Availability_Template_Resource__c(sked__Availability_Template__c = availabilityTemplate.Id, sked__Resource__c = instructor1.Id);
        forthList.add(avaiTempSiteSurveyor1);
        
        insert forthList;
        
        return mapTestData;
    }

    public static Map<string, sObject> setupFullServiceTestData() {
        string timezoneSidId = UserInfo.getTimeZone().getId();
        
        Date nextMonthStartDate = system.today().toStartOfMonth().addMonths(1);
        
        Date startDate = nextMonthStartDate.addDays(7).toStartOfWeek();
        DateTime startTime = DateTime.newInstance(startDate, time.newInstance(0, 0, 0, 0));
        
        Date nextWeekStartDate = startDate.addDays(7);
        DateTime nextWeekStartTime = DateTime.newInstance(nextWeekStartDate, time.newInstance(0, 0, 0, 0));
        
        Map<string, sObject> mapTestData = setupCommonTestData();
        
        Account testAccount = (Account)mapTestData.get('testAccount');
        Contact testContact = (Contact)mapTestData.get('testContact');
        Opportunity testOpportunity = (Opportunity)mapTestData.get('testOpportunity');
        sked__Region__c sanFranciscoRegion = (sked__Region__c)mapTestData.get('sanFranciscoRegion');
        sked__Resource__c instructor1 = (sked__Resource__c)mapTestData.get('instructor1');
        sked__Resource__c instructor2 = (sked__Resource__c)mapTestData.get('instructor2');
        Course_Catalog__c courseCatalog1 = (Course_Catalog__c)mapTestData.get('courseCatalog1');

        //traning event
        Training_Events__c trainingEvent1 = new Training_Events__c(
            Equipment__c = 'DVD and TV on site', 
            Special_Instructions__c = 'Test Special Instructions',
            Region__c = sanFranciscoRegion.Id, 
            Training_Address_1__c = '2951 Bush St #C, San Francisco, CA 94115', 
            Training_City__c = 'San Francisco', 
            Training_Location_State__c = 'CA', 
            Training_Zip__c = '94115',
            Account__c = testAccount.Id, 
            Training_Contact__c = testContact.Id,
            Opportunity__c = testOpportunity.id
        );

        insert trainingEvent1;
        mapTestData.put('trainingEvent1', trainingEvent1);

        /***********************************************************Recurring_Schedules__c*************************************************/
        sked__Recurring_Schedule__c recurringSchedule = new sked__Recurring_Schedule__c(
            Pattern__c = 'mon;tue;wed;thu;fri', 
            Frequency__c = 1
        );
        insert recurringSchedule;
        mapTestData.put('recurringSchedule', recurringSchedule);
        
        //assume that every job last for 30 minutes and require 10 minute travel to next job
        List<sked__Job__c> allJobs = new List<sked__Job__c>();
        
        sked__Job__c pendingDispatchjob = new sked__Job__c(
            sked__Address__c = '2951 Bush St #C, San Francisco, CA 94115',
            sked__GeoLocation__Latitude__s = 37.785504, 
            sked__GeoLocation__Longitude__s = -122.445256,
            sked__Account__c = testAccount.Id,
            sked__Contact__c = testContact.Id,
            sked__Region__c = sanFranciscoRegion.Id,
            sked__Type__c = skedConstants.JOB_TYPE_FULL_SERVICE,
            sked__Start__c = startTime.addHours(8),
            sked__Finish__c = startTime.addHours(11),
            sked__Job_Status__c = skedConstants.JOB_STATUS_PENDING_DISPATCH,
            Training_Event__c = trainingEvent1.Id,
            Equipment__c = 'DVD and TV on site',
            Number_of_Students__c = 10,
            Number_of_Instructors__c = 1,
            Course_Catalog__c = courseCatalog1.Id,
            sked__Duration__c = 180,
            Break_Duration__c = 30,
            Number_of_Breaks__c = 1,
            Test__c = false,
            Special_Instructions__c = 'None', 
            sked__Recurring_Schedule__c = recurringSchedule.id
        );
        allJobs.add(pendingDispatchjob);
        mapTestData.put('pendingDispatchjob', pendingDispatchjob);

        sked__Job__c dispatchjob = new sked__Job__c(
            sked__Address__c = '2951 Bush St #C, San Francisco, CA 94115',
            sked__GeoLocation__Latitude__s = 37.785504, 
            sked__GeoLocation__Longitude__s = -122.445256,
            sked__Account__c = testAccount.Id,
            sked__Contact__c = testContact.Id,
            sked__Region__c = sanFranciscoRegion.Id,
            sked__Type__c = skedConstants.JOB_TYPE_FULL_SERVICE,
            sked__Start__c = startTime.addHours(8),
            sked__Finish__c = startTime.addHours(11),
            sked__Job_Status__c = skedConstants.JOB_STATUS_DISPATCHED,
            Training_Event__c = trainingEvent1.Id,
            Equipment__c = 'DVD and TV on site',
            Number_of_Students__c = 10,
            Number_of_Instructors__c = 1,
            Course_Catalog__c = courseCatalog1.Id,
            sked__Duration__c = 180,
            Break_Duration__c = 30,
            Number_of_Breaks__c = 1,
            Test__c = false,
            Special_Instructions__c = 'None', 
            sked__Recurring_Schedule__c = recurringSchedule.id
        );
        allJobs.add(dispatchjob);
        mapTestData.put('dispatchjob', dispatchjob);
        
        sked__Job__c pendingAllocationJob = new sked__Job__c(
            sked__Address__c = '2951 Bush St #C, San Francisco, CA 94115',
            sked__GeoLocation__Latitude__s = 37.785504, 
            sked__GeoLocation__Longitude__s = -122.445256,
            sked__Account__c = testAccount.Id,
            sked__Contact__c = testContact.Id,
            sked__Region__c = sanFranciscoRegion.Id,
            sked__Type__c = skedConstants.JOB_TYPE_FULL_SERVICE,
            sked__Start__c = startTime.addDays(1).addHours(8),
            sked__Finish__c = startTime.addDays(1).addHours(11),
            sked__Job_Status__c = skedConstants.JOB_STATUS_PENDING_DISPATCH,
            Equipment__c = 'DVD and TV on site',
            Number_of_Students__c = 10,
            Number_of_Instructors__c = 1,
            Course_Catalog__c = courseCatalog1.Id,
            sked__Duration__c = 180,
            Break_Duration__c = 30,
            Number_of_Breaks__c = 1,
            Test__c = false,
            Special_Instructions__c = 'None',
            sked__Recurring_Schedule__c = recurringSchedule.id
        );
        allJobs.add(pendingAllocationJob);
        mapTestData.put('pendingAllocationJob', pendingAllocationJob);
        insert allJobs;

        List<sked__Job_Allocation__c> jobAllocs = new List<sked__Job_Allocation__c>();
        sked__Job_Allocation__c jobAlloc1 = new sked__Job_Allocation__c(
            sked__Resource__c = instructor1.Id,
            sked__Job__c = pendingDispatchJob.Id,
            sked__Status__c = skedConstants.JOB_ALLOCATION_STATUS_PENDING_DISPATCH
        );
        jobAllocs.add(jobAlloc1);
        sked__Job_Allocation__c jobAlloc2 = new sked__Job_Allocation__c(
            sked__Resource__c = instructor1.Id,
            sked__Job__c = dispatchJob.Id,
            sked__Status__c = skedConstants.JOB_ALLOCATION_STATUS_DISPATCHED
        );
        jobAllocs.add(jobAlloc2);
        sked__Job_Allocation__c jobAlloc3 = new sked__Job_Allocation__c(
            sked__Resource__c = instructor1.Id,
            sked__Job__c = pendingAllocationJob.Id,
            sked__Status__c = skedConstants.JOB_ALLOCATION_STATUS_PENDING_DISPATCH
        );
        jobAllocs.add(jobAlloc3);
        
        insert jobAllocs;

        return mapTestData;
    }
    
    public static Map<string, sObject> setupCommunitySchedulingData() {
        string timezoneSidId = UserInfo.getTimeZone().getId();
        
        Date nextMonthStartDate = system.today().toStartOfMonth().addMonths(1);
        
        Date startDate = nextMonthStartDate.addDays(7).toStartOfWeek();
        DateTime startTime = DateTime.newInstance(startDate, time.newInstance(0, 0, 0, 0));
        
        Date nextWeekStartDate = startDate.addDays(7);
        DateTime nextWeekStartTime = DateTime.newInstance(nextWeekStartDate, time.newInstance(0, 0, 0, 0));
        
        Map<string, sObject> mapTestData = setupCommonTestData();
        
        Account testAccount = (Account)mapTestData.get('testAccount');
        Contact testContact = (Contact)mapTestData.get('testContact');
        Opportunity testOpportunity = (Opportunity)mapTestData.get('testOpportunity');
        sked__Region__c sanFranciscoRegion = (sked__Region__c)mapTestData.get('sanFranciscoRegion');
        sked__Resource__c instructor1 = (sked__Resource__c)mapTestData.get('instructor1');
        sked__Resource__c instructor2 = (sked__Resource__c)mapTestData.get('instructor2');
        Course_Catalog__c courseCatalog1 = (Course_Catalog__c)mapTestData.get('courseCatalog1');
        sked__Location__c communityLocation1 = (sked__Location__c)mapTestData.get('communityLocation1');
        sked__Tag__c tagDelivery = (sked__Tag__c)mapTestData.get('tagDelivery');

        /***********************************************************Recurring_Schedules__c*************************************************/
        sked__Recurring_Schedule__c recurringSchedule = new sked__Recurring_Schedule__c(
            Pattern__c = 'mon;tue;wed;thu;fri', 
            Frequency__c = 1
        );
        insert recurringSchedule;
        mapTestData.put('recurringSchedule', recurringSchedule);

        //assume that every job last for 30 minutes and require 10 minute travel to next job
        List<sked__Job__c> allJobs = new List<sked__Job__c>();
        
        sked__Job__c dispatchjob = new sked__Job__c(
            sked__Address__c = '2951 Bush St #C, San Francisco, CA 94115',
            sked__GeoLocation__Latitude__s = 37.785504, 
            sked__GeoLocation__Longitude__s = -122.445256,
            sked__Account__c = testAccount.Id,
            sked__Contact__c = testContact.Id,
            sked__Region__c = sanFranciscoRegion.Id,
            sked__Type__c = skedConstants.JOB_TYPE_COMMUNITY,
            sked__Start__c = startTime.addHours(8),
            sked__Finish__c = startTime.addHours(11),
            sked__Duration__c = 180,
            sked__Job_Status__c = skedConstants.JOB_STATUS_DISPATCHED,
            sked__Location__c = communityLocation1.Id,
            ClasS_Sub_Type__c = skedConstants.COMMUNITY_CLASS_SUB_TYPE_BASE,
            Number_of_Students__c = 10,
            Number_of_Instructors__c = 1,
            Course_Catalog__c = courseCatalog1.Id,
            Break_Duration__c = 30,
            Number_of_Breaks__c = 1,
            Special_Instructions__c = 'None',
            Location_Confirmed__c = true,
            sked__Recurring_Schedule__c = recurringSchedule.id
        );
        allJobs.add(dispatchjob);
        mapTestData.put('dispatchjob', dispatchjob);
        
        sked__Job__c pendingAllocationJob = new sked__Job__c(
            sked__Address__c = '2951 Bush St #C, San Francisco, CA 94115',
            sked__GeoLocation__Latitude__s = 37.785504, 
            sked__GeoLocation__Longitude__s = -122.445256,
            sked__Account__c = testAccount.Id,
            sked__Contact__c = testContact.Id,
            sked__Region__c = sanFranciscoRegion.Id,
            sked__Type__c = skedConstants.JOB_TYPE_COMMUNITY,
            sked__Start__c = startTime.addDays(1).addHours(8),
            sked__Finish__c = startTime.addDays(1).addHours(11),
            sked__Duration__c = 180,
            sked__Job_Status__c = skedConstants.JOB_STATUS_PENDING_ALLOCATION,
            sked__Location__c = communityLocation1.Id,
            ClasS_Sub_Type__c = skedConstants.COMMUNITY_CLASS_SUB_TYPE_BASE,
            Number_of_Students__c = 10,
            Number_of_Instructors__c = 1,
            Course_Catalog__c = courseCatalog1.Id,
            Break_Duration__c = 30,
            Number_of_Breaks__c = 1,
            Special_Instructions__c = 'None',
            Location_Confirmed__c = false,
            sked__Recurring_Schedule__c = recurringSchedule.id
        );
        allJobs.add(pendingAllocationJob);
        mapTestData.put('pendingAllocationJob', pendingAllocationJob);
        insert allJobs;

        List<sked__Job_Allocation__c> jobAllocs = new List<sked__Job_Allocation__c>();
        sked__Job_Allocation__c jobAlloc = new sked__Job_Allocation__c(
            sked__Resource__c = instructor2.Id,
            sked__Job__c = dispatchJob.Id,
            sked__Status__c = skedConstants.JOB_ALLOCATION_STATUS_DISPATCHED
        );
        jobAllocs.add(jobAlloc);
        
        insert jobAllocs;

        sked__Job_Tag__c dispatchJobTag1 = new sked__Job_Tag__c(
            sked__Job__c = dispatchjob.Id,
            sked__Tag__c = tagDelivery.Id
        );
        insert dispatchJobTag1;

        list<Offering__c> offferings = new List<Offering__c>();
        Offering__c offferingDispatch = new Offering__c(
            Job__c = dispatchjob.Id,
            No_of_Attendees__c = 10
        );
        offferings.add(offferingDispatch);
        mapTestData.put('offferingDispatch', offferingDispatch);

        Offering__c offeringPendingAllocation = new Offering__c(
            Job__c = pendingAllocationJob.Id,
            No_of_Attendees__c = 10
        );        
        offferings.add(offeringPendingAllocation);
        mapTestData.put('offeringPendingAllocation', offeringPendingAllocation);

        insert offferings;
        
        return mapTestData;
    }

    public static Map<string, sObject> setupCepSchedulingData() {
        string timezoneSidId = UserInfo.getTimeZone().getId();
        
        Date nextMonthStartDate = system.today().toStartOfMonth().addMonths(1);
        
        Date startDate = nextMonthStartDate.addDays(7).toStartOfWeek();
        DateTime startTime = DateTime.newInstance(startDate, time.newInstance(0, 0, 0, 0));
        
        Date nextWeekStartDate = startDate.addDays(7);
        DateTime nextWeekStartTime = DateTime.newInstance(nextWeekStartDate, time.newInstance(0, 0, 0, 0));
        
        Map<string, sObject> mapTestData = setupCommonTestData();
        
        Account testAccount = (Account)mapTestData.get('testAccount');
        Contact testContact = (Contact)mapTestData.get('testContact');
        Opportunity testOpportunity = (Opportunity)mapTestData.get('testOpportunity');
        sked__Region__c sanFranciscoRegion = (sked__Region__c)mapTestData.get('sanFranciscoRegion');
        Course_Catalog__c courseCatalog1 = (Course_Catalog__c)mapTestData.get('courseCatalog1');
        sked__Location__c cepLocation1 = (sked__Location__c)mapTestData.get('cepLocation1');
        sked__Resource__c instructor2 = (sked__Resource__c)mapTestData.get('instructor2');

        /***********************************************************Recurring_Schedules__c*************************************************/
        sked__Recurring_Schedule__c recurringSchedule = new sked__Recurring_Schedule__c(
            Pattern__c = 'mon;tue;wed;thu;fri', 
            Frequency__c = 1
        );
        insert recurringSchedule;
        mapTestData.put('recurringSchedule', recurringSchedule);

        //assume that every job last for 30 minutes and require 10 minute travel to next job
        List<sked__Job__c> allJobs = new List<sked__Job__c>();
        
        sked__Job__c dispatchjob = new sked__Job__c(
            sked__Address__c = '2951 Bush St #C, San Francisco, CA 94115',
            sked__GeoLocation__Latitude__s = 37.785504, 
            sked__GeoLocation__Longitude__s = -122.445256,
            sked__Account__c = testAccount.Id,
            sked__Contact__c = testContact.Id,
            sked__Region__c = sanFranciscoRegion.Id,
            sked__Type__c = skedConstants.JOB_TYPE_NURSE_ASSISTANT_TESTING,
            sked__Start__c = startTime.addHours(8),
            sked__Finish__c = startTime.addHours(11),
            sked__Job_Status__c = skedConstants.JOB_STATUS_DISPATCHED,
            sked__Location__c = cepLocation1.Id,
            Number_of_Students__c = 10,
            Number_of_Instructors__c = 1,
            Course_Catalog__c = courseCatalog1.Id,
            sked__Duration__c = 180,
            Break_Duration__c = 30,
            Number_of_Breaks__c = 1,
            Special_Instructions__c = 'None',
            Location_Confirmed__c = true,
            sked__Recurring_Schedule__c = recurringSchedule.id
        );
        allJobs.add(dispatchjob);
        mapTestData.put('dispatchjob', dispatchjob);
        
        sked__Job__c pendingAllocationJob = new sked__Job__c(
            sked__Address__c = '2951 Bush St #C, San Francisco, CA 94115',
            sked__GeoLocation__Latitude__s = 37.785504, 
            sked__GeoLocation__Longitude__s = -122.445256,
            sked__Account__c = testAccount.Id,
            sked__Contact__c = testContact.Id,
            sked__Region__c = sanFranciscoRegion.Id,
            sked__Type__c = skedConstants.JOB_TYPE_NURSE_ASSISTANT_TESTING,
            sked__Start__c = startTime.addDays(1).addHours(8),
            sked__Finish__c = startTime.addDays(1).addHours(11),
            sked__Job_Status__c = skedConstants.JOB_STATUS_PENDING_ALLOCATION,
            sked__Location__c = cepLocation1.Id,
            Number_of_Students__c = 10,
            Number_of_Instructors__c = 1,
            Course_Catalog__c = courseCatalog1.Id,
            sked__Duration__c = 180,
            Break_Duration__c = 30,
            Number_of_Breaks__c = 1,
            Special_Instructions__c = 'None',
            Location_Confirmed__c = false,
            sked__Recurring_Schedule__c = recurringSchedule.id
        );
        allJobs.add(pendingAllocationJob);
        mapTestData.put('pendingAllocationJob', pendingAllocationJob);
        insert allJobs;

        List<sked__Job_Allocation__c> jobAllocs = new List<sked__Job_Allocation__c>();
        sked__Job_Allocation__c jobAlloc = new sked__Job_Allocation__c(
            sked__Resource__c = instructor2.Id,
            sked__Job__c = dispatchJob.Id,
            sked__Status__c = skedConstants.JOB_ALLOCATION_STATUS_DISPATCHED
        );
        jobAllocs.add(jobAlloc);
        
        insert jobAllocs;
        return mapTestData;
    }

    public static Map<string, sObject> setupNatSchedulingData() {
        string timezoneSidId = UserInfo.getTimeZone().getId();
        
        Date nextMonthStartDate = system.today().toStartOfMonth().addMonths(1);
        
        Date startDate = nextMonthStartDate.addDays(7).toStartOfWeek();
        DateTime startTime = DateTime.newInstance(startDate, time.newInstance(0, 0, 0, 0));
        
        Date nextWeekStartDate = startDate.addDays(7);
        DateTime nextWeekStartTime = DateTime.newInstance(nextWeekStartDate, time.newInstance(0, 0, 0, 0));
        
        Map<string, sObject> mapTestData = setupCommonTestData();
        
        Account testAccount = (Account)mapTestData.get('testAccount');
        Contact testContact = (Contact)mapTestData.get('testContact');
        Opportunity testOpportunity = (Opportunity)mapTestData.get('testOpportunity');
        sked__Region__c sanFranciscoRegion = (sked__Region__c)mapTestData.get('sanFranciscoRegion');
        Course_Catalog__c courseCatalog1 = (Course_Catalog__c)mapTestData.get('courseCatalog1');
        Course_Catalog__c courseCatalog2 = (Course_Catalog__c)mapTestData.get('courseCatalog2');
        sked__Location__c natLocation1 = (sked__Location__c)mapTestData.get('natLocation1');
        sked__Resource__c instructor2 = (sked__Resource__c)mapTestData.get('instructor2');

        /***********************************************************Course_Template__c*************************************************/
        Course_Template__c courseTemplate1 = new Course_Template__c(
            Course_Class_Days__c = 'Monday to Friday',
            Course_Catalog__c = courseCatalog1.id,
            Name = 'California NAT Course 1'
        );
        insert courseTemplate1;

        list<Course_Class_Type__c> classTypes = new list<Course_Class_Type__c>();
        Course_Class_Type__c classType1 = new Course_Class_Type__c(
            Class_Type__c = 'Orientation',
            Course_Template__c = courseTemplate1.id,
            Display_Order__c = 1,
            End_Time__c = 1400,
            Location__c = natLocation1.id,
            Ratio_to_Instructor__c = 10,
            Start_Time__c = 800,
            Total_Hours__c = 8.00
        );
        classTypes.add(classType1);

        Course_Class_Type__c classType2 = new Course_Class_Type__c(
            Class_Type__c = 'CPR',
            Course_Template__c = courseTemplate1.id,
            Display_Order__c = 2,
            Start_Time__c = 1300,
            End_Time__c = 1700,
            Location__c = natLocation1.id,
            Ratio_to_Instructor__c = 10,
            Total_Hours__c = 4
        );
        classTypes.add(classType2);

        Course_Class_Type__c classType3 = new Course_Class_Type__c(
            Class_Type__c = 'Theory',
            Course_Template__c = courseTemplate1.id,
            Display_Order__c = 3,
            Start_Time__c = 730,
            End_Time__c = 1430,
            Location__c = natLocation1.id,
            Ratio_to_Instructor__c = 15,
            Total_Hours__c = 60
        );
        classTypes.add(classType3);

        Course_Class_Type__c classType4 = new Course_Class_Type__c(
            Class_Type__c = 'Lab',
            Course_Template__c = courseTemplate1.id,
            Display_Order__c = 4,
            End_Time__c = 1100,
            Location__c = natLocation1.id,
            Ratio_to_Instructor__c = 30,
            Start_Time__c = 730,
            Total_Hours__c = 7.5
        );
        classTypes.add(classType4);

        Course_Class_Type__c classType5 = new Course_Class_Type__c(
            Class_Type__c = 'Clinical',
            Course_Template__c = courseTemplate1.id,
            Display_Order__c = 5,
            End_Time__c = 1400,
            Location__c = natLocation1.id,
            Ratio_to_Instructor__c = 20,
            Start_Time__c = 700,
            Total_Hours__c = 100
        );
        classTypes.add(classType5);

        Course_Class_Type__c classType6 = new Course_Class_Type__c(
            Class_Type__c = 'Make Up',
            Course_Template__c = courseTemplate1.id,
            Display_Order__c = 6,
            End_Time__c = 1400,
            Location__c = natLocation1.id,
            Ratio_to_Instructor__c = 10,
            Start_Time__c = 730,
            Total_Hours__c = 6.5
        );
        classTypes.add(classType6);

        Course_Class_Type__c classType7 = new Course_Class_Type__c(
            Class_Type__c = 'Graduation',
            Course_Template__c = courseTemplate1.id,
            Display_Order__c = 7,
            End_Time__c = 1400,
            Location__c = natLocation1.id,
            Ratio_to_Instructor__c = 50,
            Start_Time__c = 900,
            Total_Hours__c = 5
        );
        classTypes.add(classType7);

        insert classTypes;

        /***********************************************************Recurring_Schedules__c*************************************************/
        sked__Recurring_Schedule__c recurringSchedule = new sked__Recurring_Schedule__c(
            Pattern__c = 'mon;tue;wed;thu;fri', 
            Frequency__c = 1
        );
        insert recurringSchedule;
        mapTestData.put('recurringSchedule', recurringSchedule);

        /***********************************************************Course__c*************************************************/
        Course__c course1 = new Course__c(
            Name ='Adult First Aid/CPR/AED',
            Course_Catalog__c = courseCatalog1.id,
            Max_Hours_per_day__c = 8,
            Recurring_Schedule__c = recurringSchedule.id,
            Start_Month__c = Json.serialize(nextMonthStartDate).replace('"', '')
        );
        insert course1;
        mapTestData.put('course1', course1);

        /***********************************************************sked__Job__c*************************************************/
        //assume that every job last for 30 minutes and require 10 minute travel to next job
        List<sked__Job__c> allJobs = new List<sked__Job__c>();
        
        sked__Job__c dispatchjob = new sked__Job__c(
            sked__Address__c = '2951 Bush St #C, San Francisco, CA 94115',
            sked__GeoLocation__Latitude__s = 37.785504, 
            sked__GeoLocation__Longitude__s = -122.445256,
            sked__Account__c = testAccount.Id,
            sked__Contact__c = testContact.Id,
            sked__Region__c = sanFranciscoRegion.Id,
            sked__Type__c = skedConstants.JOB_TYPE_NURSE_ASSISTANT_TRAINING,
            sked__Start__c = startTime.addHours(8),
            sked__Finish__c = startTime.addHours(11),
            sked__Job_Status__c = skedConstants.JOB_STATUS_DISPATCHED,
            sked__Location__c = natLocation1.Id,
            Number_of_Students__c = 10,
            Number_of_Instructors__c = 1,
            Course_Catalog__c = courseCatalog1.Id,
            sked__Duration__c = 180,
            Break_Duration__c = 30,
            Number_of_Breaks__c = 1,
            Special_Instructions__c = 'None',
            Location_Confirmed__c = true,
            sked__Recurring_Schedule__c = recurringSchedule.id,
            Course__c = course1.id
        );
        allJobs.add(dispatchjob);
        mapTestData.put('dispatchjob', dispatchjob);
        
        sked__Job__c pendingAllocationJob = new sked__Job__c(
            sked__Address__c = '2951 Bush St #C, San Francisco, CA 94115',
            sked__GeoLocation__Latitude__s = 37.785504, 
            sked__GeoLocation__Longitude__s = -122.445256,
            sked__Account__c = testAccount.Id,
            sked__Contact__c = testContact.Id,
            sked__Region__c = sanFranciscoRegion.Id,
            sked__Type__c = skedConstants.JOB_TYPE_NURSE_ASSISTANT_TRAINING,
            sked__Start__c = startTime.addDays(1).addHours(8),
            sked__Finish__c = startTime.addDays(1).addHours(11),
            sked__Job_Status__c = skedConstants.JOB_STATUS_PENDING_ALLOCATION,
            sked__Location__c = natLocation1.Id,
            Number_of_Students__c = 10,
            Number_of_Instructors__c = 1,
            Course_Catalog__c = courseCatalog1.Id,
            sked__Duration__c = 180,
            Break_Duration__c = 30,
            Number_of_Breaks__c = 1,
            Special_Instructions__c = 'None',
            Location_Confirmed__c = false,
            sked__Recurring_Schedule__c = recurringSchedule.id,
            Course__c = course1.id
        );
        allJobs.add(pendingAllocationJob);
        mapTestData.put('pendingAllocationJob', pendingAllocationJob);
        insert allJobs;

        List<sked__Job_Allocation__c> jobAllocs = new List<sked__Job_Allocation__c>();
        sked__Job_Allocation__c jobAlloc = new sked__Job_Allocation__c(
            sked__Resource__c = instructor2.Id,
            sked__Job__c = dispatchJob.Id,
            sked__Status__c = skedConstants.JOB_ALLOCATION_STATUS_DISPATCHED
        );
        jobAllocs.add(jobAlloc);
        
        insert jobAllocs;
        
        return mapTestData;
    }

    public static Map<string, sObject> setupScheduleAllocationTestData() {
        string timezoneSidId = UserInfo.getTimeZone().getId();
        
        Date nextMonthStartDate = system.today().toStartOfMonth().addMonths(1);
        
        Date startDate = nextMonthStartDate.addDays(7).toStartOfWeek();
        DateTime startTime = DateTime.newInstance(startDate, time.newInstance(0, 0, 0, 0));
        
        Date nextWeekStartDate = startDate.addDays(7);
        DateTime nextWeekStartTime = DateTime.newInstance(nextWeekStartDate, time.newInstance(0, 0, 0, 0));
        
        Map<string, sObject> mapTestData = setupCommonTestData();
        
        Account testAccount = (Account)mapTestData.get('testAccount');
        Contact testContact = (Contact)mapTestData.get('testContact');
        Opportunity testOpportunity = (Opportunity)mapTestData.get('testOpportunity');
        sked__Region__c sanFranciscoRegion = (sked__Region__c)mapTestData.get('sanFranciscoRegion');
        sked__Resource__c instructor1 = (sked__Resource__c)mapTestData.get('instructor1');
        sked__Resource__c instructor2 = (sked__Resource__c)mapTestData.get('instructor2');
        Course_Catalog__c courseCatalog1 = (Course_Catalog__c)mapTestData.get('courseCatalog1');
        sked__Tag__c tagPickup = (sked__Tag__c)mapTestData.get('tagPickup');

        //traning event
        Training_Events__c trainingEvent1 = new Training_Events__c(
            Equipment__c = 'DVD and TV on site', 
            Special_Instructions__c = 'Test Special Instructions',
            Region__c = sanFranciscoRegion.Id, 
            Training_Address_1__c = '2951 Bush St #C, San Francisco, CA 94115', 
            Training_City__c = 'San Francisco', 
            Training_Location_State__c = 'CA', 
            Training_Zip__c = '94115',
            Account__c = testAccount.Id, 
            Training_Contact__c = testContact.Id,
            Opportunity__c = testOpportunity.id
        );

        insert trainingEvent1;
        mapTestData.put('trainingEvent1', trainingEvent1);

        /***********************************************************Recurring_Schedules__c*************************************************/
        sked__Recurring_Schedule__c recurringSchedule = new sked__Recurring_Schedule__c(
            Pattern__c = 'mon;tue;wed;thu;fri', 
            Frequency__c = 1
        );
        insert recurringSchedule;
        mapTestData.put('recurringSchedule', recurringSchedule);
        
        //assume that every job last for 30 minutes and require 10 minute travel to next job
        List<sked__Job__c> allJobs = new List<sked__Job__c>();
        for (integer i = 0; i < 5; i++) {
            sked__Job__c pendingDispatchJob = new sked__Job__c(
                sked__Address__c = '2951 Bush St #C, San Francisco, CA 94115',
                sked__GeoLocation__Latitude__s = 37.785504, 
                sked__GeoLocation__Longitude__s = -122.445256,
                sked__Account__c = testAccount.Id,
                sked__Contact__c = testContact.Id,
                sked__Region__c = sanFranciscoRegion.Id,
                sked__Type__c = skedConstants.JOB_TYPE_FULL_SERVICE,
                sked__Start__c = startTime.addDays(i).addHours(11),
                sked__Finish__c = startTime.addDays(i).addHours(14),
                sked__Job_Status__c = skedConstants.JOB_STATUS_PENDING_DISPATCH,
                Equipment__c = 'DVD and TV on site',
                Number_of_Students__c = 10,
                Number_of_Instructors__c = 1,
                Course_Catalog__c = courseCatalog1.Id,
                sked__Duration__c = 180,
                Break_Duration__c = 30,
                Number_of_Breaks__c = 1,
                Test__c = false,
                Special_Instructions__c = 'None',
                sked__Recurring_Schedule__c = recurringSchedule.id,
                Training_Event__c = trainingEvent1.Id
            );
            allJobs.add(pendingDispatchJob);
            mapTestData.put('pendingDispatchJob' + i, pendingDispatchJob);
        }
        insert allJobs;

        List<sked__Job_Allocation__c> jobAllocs = new List<sked__Job_Allocation__c>();
        for (sked__Job__c job : allJobs) {
            sked__Job_Allocation__c jobAlloc = new sked__Job_Allocation__c(
                sked__Resource__c = instructor2.Id,
                sked__Job__c = job.Id,
                sked__Status__c = skedConstants.JOB_ALLOCATION_STATUS_PENDING_DISPATCH
            );
            jobAllocs.add(jobAlloc);
        }
        insert jobAllocs;

        List<sked__Job_Tag__c> jobTags = new List<sked__Job_Tag__c>();
        for (sked__Job__c job : allJobs) {
            sked__Job_Tag__c jobTag = new sked__Job_Tag__c(
                sked__Tag__c = tagPickup.Id,
                sked__Job__c = job.Id
            );
            jobTags.add(jobTag);
        }
        insert jobTags;

        return mapTestData;
    }
    
}