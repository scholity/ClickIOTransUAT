@isTest
private class TestCTIScreenPopCtlr {

@testSetup static void methodName() {
    Switch__c cohstest = new Switch__c();
        cohstest.Switch__c = true;
        cohstest.name = 'CaseOwnerHistorySwitch';
        insert cohstest;
}  
    static Bucket_Account_Settings__c orgSettings;
    static void setup()
    {
        List<RecordType> accountRecordTypes =  [Select ID From RecordType Where SObjectType='Account' AND IsActive=TRUE];
        //Added from here
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        String userName = uniqueName + '@test' + orgId + '.org';
        //Till here
        //User bucketOwner = TestUtil.createUser('BucketOwner1@redcross.org',TestUtil.SYSTEM_ADMINISTRATOR_PROFILE.ID, true, null, 'Bee',  'Bob');
        User bucketOwner = TestUtil.createUser(userName,TestUtil.SYSTEM_ADMINISTRATOR_PROFILE.ID, true, null, 'Bee',  'Bob');
        orgSettings = new Bucket_Account_Settings__c(Bucket_Account_Owner_ID__c=bucketOwner.ID, 
                                                                             Default_Bucket_Name__c='Default Name',
                                                                             Maximum_Size_of_Bucket__c = 200,
                                                                             Bucket_Account_RecordTypeID__c = accountRecordTypes[0].ID,
                                                                             SetupOwnerId =UserInfo.getOrganizationId());                                             
        insert orgSettings;
    }

    static { setup(); }

    static testMethod void testSort() {
        Test.startTest();
        redcrossBiztalkIntegrationT2sfdc.RedCross_BizTalk_Integration_T2SFDC_Orc_TSFDC_FRQ_prt_FRF_GenericSoap stub = new redcrossBiztalkIntegrationT2sfdc.RedCross_BizTalk_Integration_T2SFDC_Orc_TSFDC_FRQ_prt_FRF_GenericSoap();             
        stub.timeout_x = 60000 ;  
        // uncomment once certificate is setup
        stub.clientCertName_x = 'BizTalk_Constituent_Search';
        redcrossBiztalkIntegrationT2sfdc.SortPaginateRequest sortPagination;    
        Test.setMock(WebServiceMock.class, new SortMockImpl());     
        redcrossBiztalkIntegrationT2sfdc.QueryResponse response =  stub.Sort(sortPagination);   
        Test.stopTest();
    }

    static testMethod void testCancelConfirmContactInfo() {
        CTIScreenPopCtlr pageController = new CTIScreenPopCtlr();
        PageReference pageRef = pageController.cancelConfirmContactInformation();
        
        // was the user redirected back to the CTIScreenPop page?
        System.AssertEquals(pageRef.getURL(), Page.CTIScreenPop.getURL());
    }


    
    static testMethod void testSearchForConstituent() {
        Test.startTest();
        PageReference pageRef = Page.CTIScreenPop;
        Test.setCurrentPage(pageRef);
        CTIScreenPopCtlr pageController = new CTIScreenPopCtlr();
        Test.setMock(WebServiceMock.class, new SearchConstituentsMockImpl());
        pageController.constituentSearchForm.Phone = '4151231234';
        pageController.constituentSearchForm.LastName = 'Smith';
        pageController.constituentSearchForm.City = '';
        pageController.constituentSearchForm.EmailAddress = '';
        pageController.constituentSearchForm.FirstName = '';
        pageController.constituentSearchForm.State = '';
        pageController.constituentSearchForm.Zip = '';
        pageController.searchForConstituent();
        Test.stopTest();

        // was a constituent found?     
        //System.assert(pageController.constituentSearchResults.size()>0);
    }


    static testMethod void testSearchForConstituentNegative() {
        PageReference pageRef = Page.CTIScreenPop;
        Test.setCurrentPage(pageRef);
        CTIScreenPopCtlr pageController = new CTIScreenPopCtlr();
        Test.setMock(WebServiceMock.class, new SearchConstituentsNoResultMockImpl());
        pageController.constituentSearchForm.Phone = '4151231234';
        pageController.constituentSearchForm.LastName = 'Smith';
        pageController.constituentSearchForm.City = '';
        pageController.constituentSearchForm.EmailAddress = '';
        pageController.constituentSearchForm.FirstName = '';
        pageController.constituentSearchForm.State = '';
        pageController.constituentSearchForm.Zip = '';
        pageController.searchForConstituent();

        // was a constituent found?     
        //System.assert(pageController.constituentSearchResults.size()>0);
    }


    static testMethod void testSearchByPhone() {
        Test.startTest();
        PageReference pageRef = Page.CTIScreenPop;
        Test.setCurrentPage(pageRef);
        CTIScreenPopCtlr pageController = new CTIScreenPopCtlr();   
        Test.setMock(WebServiceMock.class, new SearchConstituentsMockImpl());
        pageController.phone = '4155071234';
        pageController.searchForPhone();
        Test.stopTest();
        
        // was a constituent found?
        //System.assert(pageController.constituentSearchResults.size()>0);        
    }
    
    
    static testMethod void testConfirmContactInformation() {
        Test.startTest();
        PageReference pageRef = Page.CTIScreenPop;
        Test.setCurrentPage(pageRef);
        CTIScreenPopCtlr pageController = new CTIScreenPopCtlr();   
        Test.setMock(WebServiceMock.class, new GetConstituentDetailMockImpl());
        pageController.initConfirmContactInformation();             
        pageController.confirm();
        Test.stopTest();
        // was the contact created?// was the contact created?
        Contact contactCreated = [Select Id, LastName, Account.RecordTypeId From Contact LIMIT 1];
        
        System.assertEquals(orgSettings.Bucket_Account_RecordTypeID__c, contactCreated.Account.RecordTypeId,
            'Creating contact through quick create should assign the new contact to a Bucket Account (via trigger)');
    }
    
    
    static testMethod void testConfirmContactInformationNegative1() {
        Test.startTest();
        /* Test catch block around insert Contact */
        PageReference pageRef = Page.CTIScreenPop;
        Test.setCurrentPage(pageRef);
        CTIScreenPopCtlr pageController = new CTIScreenPopCtlr();   
        Test.setMock(WebServiceMock.class, new GetConstituentDetailMockImpl());
        pageController.initConfirmContactInformation();             
        // if the phone field is not valid a validation rule with cause the insert to fail
        pageController.confirmContactProxy.phone = '123123123123123';
        PageReference redirectPageRef = pageController.confirm();
        Test.stopTest();
        // if the page reference is null then there was an error
        //System.assertEquals(redirectPageRef, null); 
        
        
        
         
    }

    static testMethod void testQuickCreateConstituent() {
        Test.startTest();
        PageReference pageRef = Page.CTIScreenPop;
        Test.setCurrentPage(pageRef);
        CTIScreenPopCtlr pageController = new CTIScreenPopCtlr();
        pageController.qcContactProxy.firstName = 'Test';
        pageController.qcContactProxy.lastName = 'Contact';
        pageController.qcContactProxy.mailingCity = 'New York';
        pageController.qcContactProxy.mailingState = 'NY'; 
        pageController.qcContactProxy.mailingPostalCode = '12345';
        pageController.qcContactProxy.mailingStreet = '123 West 59th Street';
        pageController.quickCreateConstituent();
        Test.stopTest();

        // was the contact created?
        Contact contactCreated = [Select Id, LastName, Account.RecordTypeId From Contact LIMIT 1];
        
        System.assertEquals('Contact', contactCreated.LastName, 'Checking field consistency');
        System.assertEquals(orgSettings.Bucket_Account_RecordTypeID__c, contactCreated.Account.RecordTypeId,
            'Creating contact through quick create should assign the new contact to a Bucket Account (via trigger)');
    }
    
    static testMethod void testSelectConstituentByConstituentId() {
        Contact contact = new Contact();
        contact.FirstName = 'Test';
        contact.lastName = 'Contact';
        contact.MailingCity = 'New York';
        contact.MailingPostalCode = '12345';
        contact.MailingState = 'NY';
        contact.MailingStreet = '2121 W 59th Street';
        contact.Master_Constituent_ID__c = '99999999999z';
        Insert contact;
        
        PageReference pageRef = Page.CTIScreenPop;
        Test.setCurrentPage(pageRef);
        CTIScreenPopCtlr pageController = new CTIScreenPopCtlr();
        pageController.selectedConstituentId = '99999999999z';
        pageController.selectConstituent();     
    }
    
    static testMethod void testSelectConstituentBySalesforceContactId() {   
        Contact contact = new Contact();
        contact.FirstName = 'Test';
        contact.lastName = 'Contact';
        contact.MailingCity = 'New York';
        contact.MailingPostalCode = '12345';
        contact.MailingState = 'NY';
        contact.MailingStreet = '2121 W 59th Street';
        contact.Master_Constituent_ID__c = '99999999999z';
        Insert contact;
    
        PageReference pageRef = Page.CTIScreenPop;
        Test.setCurrentPage(pageRef);
        CTIScreenPopCtlr pageController = new CTIScreenPopCtlr();   
        pageController.selectedConstituentId = null;
        pageController.selectedContactId = contact.id;
        pageController.selectedManagedLearningFlag = 'Yes';
        pageController.selectConstituent();
    }
    
    static testMethod void testInitPageWithPhone() {
        PageReference pageRef = Page.CTIScreenPop;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('ANI', '3521231234');
        
        CTIScreenPopCtlr pageController = new CTIScreenPopCtlr();   
        
    }

    static Contact ghostContact;
    static void setupValidGhostCallSettings() {
        setupNonIDValidGhostCallSettings();
        CTIScreenPopCtlr.ghostCallSettings.add(new Ghost_Call_Settings__c( Name='ContactID', Default_Field_Value__c=ghostContact.Id ));
        CTIScreenPopCtlr.ghostCallSettings.add(new Ghost_Call_Settings__c( Name='RecordTypeId', Default_Field_Value__c=TestUtil.SERVICE_CASES_READ_ONLY.Id ));
    }

    static void setupNonIDValidGhostCallSettings() {
        ghostContact = TestUtil.createContacts(1, false)[0];
        ghostContact.AccountID = TestUtil.createAccount(true).ID;
        insert ghostContact;
        CTIScreenPopCtlr.ghostCallSettings = new List<Ghost_Call_Settings__c>();
        CTIScreenPopCtlr.ghostCallSettings.add(new Ghost_Call_Settings__c( Name='Ghost_Call__c', Default_Field_Value__c='true' ));
        CTIScreenPopCtlr.ghostCallSettings.add(new Ghost_Call_Settings__c( Name='Other__c', Default_Field_Value__c='Case created as a result of a ghost call' ));
        CTIScreenPopCtlr.ghostCallSettings.add(new Ghost_Call_Settings__c( Name='Status', Default_Field_Value__c='Closed - Unresolved' ));
        CTIScreenPopCtlr.ghostCallSettings.add(new Ghost_Call_Settings__c( Name='Type', Default_Field_Value__c='Other' ));
    }

    static testMethod void testLogGhostCallWithInvalidContactID() {
        setupNonIDValidGhostCallSettings();
        CTIScreenPopCtlr.ghostCallSettings.add(new Ghost_Call_Settings__c( Name='ContactID', Default_Field_Value__c='003110000aaaaaa' ));
        CTIScreenPopCtlr.ghostCallSettings.add(new Ghost_Call_Settings__c( Name='RecordTypeId', Default_Field_Value__c=TestUtil.SERVICE_CASES_READ_ONLY.Id ));
        CTIScreenPopCtlr pageController = new CTIScreenPopCtlr();
        pageController.constituentSearchForm.phone = '7815551234';
        Test.startTest();
            pageController.logGhostCall();
        Test.stopTest();

        List<Case> actualCase = [SELECT Id FROM Case];
        System.assertEquals(0, actualCase.size(), 'There should be no Cases created in the event where an invalid ID exists in the Custom Setting');
        System.assert(TestUtil.pageMessageContains('Fail'), 'Message about failing to create a Ghost Case should be displayed');
        System.assert(TestUtil.pageMessageContains(CTIScreenPopCtlr.ID_ERROR), 'Message about a potential invalid ID in the custom setting should be displayed');
    }

    static testMethod void testLogGhostCallWithInvalidRecordTypeID() {
        setupNonIDValidGhostCallSettings();
        CTIScreenPopCtlr.ghostCallSettings.add(new Ghost_Call_Settings__c( Name='ContactID', Default_Field_Value__c=ghostContact.Id ));
        CTIScreenPopCtlr.ghostCallSettings.add(new Ghost_Call_Settings__c( Name='RecordTypeId', Default_Field_Value__c='012d000000097aa' ));
        CTIScreenPopCtlr pageController = new CTIScreenPopCtlr();
        pageController.constituentSearchForm.phone = '7815551234';
        Test.startTest();
            pageController.logGhostCall();
        Test.stopTest();

        List<Case> actualCase = [SELECT Id FROM Case];
        System.assertEquals(0, actualCase.size(), 'There should be no Cases created in the event where an invalid ID exists in the Custom Setting');
        System.assert(TestUtil.pageMessageContains('Fail'), 'Message about failing to create a Ghost Case should be displayed');
        System.assert(TestUtil.pageMessageContains(CTIScreenPopCtlr.ID_ERROR), 'Message about a potential invalid ID in the custom setting should be displayed');
    }

    static testMethod void testLogGhostCallWithInvalidFieldNames() {
        setupValidGhostCallSettings();
        CTIScreenPopCtlr.ghostCallSettings.add(new Ghost_Call_Settings__c( Name='StatusBAD', Default_Field_Value__c='junk' ));
        CTIScreenPopCtlr.ghostCallSettings.add(new Ghost_Call_Settings__c( Name='TypeBAD', Default_Field_Value__c='junk' ));
        CTIScreenPopCtlr pageController = new CTIScreenPopCtlr();
        pageController.constituentSearchForm.phone = '7815551234';
        Test.startTest();
            pageController.logGhostCall();
        Test.stopTest();

        List<Case> actualCase = [SELECT Id FROM Case];
        System.assertEquals(0, actualCase.size(), 'There should be no Cases created in the event where an invalid ID exists in the Custom Setting');
        System.assert(TestUtil.pageMessageContains('Fail'), 'Message about failing to create a Ghost Case should be displayed');
        System.assert(TestUtil.pageMessageContains(CTIScreenPopCtlr.FIELD_ERROR), 'Message about a potential invalid field in the custom setting should be displayed');
    }

    static testMethod void testLogGhostCall() {
        setupValidGhostCallSettings();
        CTIScreenPopCtlr pageController = new CTIScreenPopCtlr();
        pageController.constituentSearchForm.phone = '(781) 555-1234'; // THIS IS THE RESULT OF THE JAVASCRIPT FORMATPHONE
        Test.startTest();
            pageController.logGhostCall();
        Test.stopTest();

        List<Case> actualCase = [SELECT Id, 
                                        CaseNumber,
                                        ContactID,
                                        Ghost_Call__c,
                                        Phone_Number_of_Ghost_Call__c,
                                        Other__c,
                                        RecordTypeId,
                                        Status,
                                        Type FROM Case];

        /*System.assertEquals(1, actualCase.size(), 'There should be exactly 1 Case created as a result of a call to logGhostCall');
        System.assertEquals('(781) 555-1234', actualCase[0].Phone_Number_of_Ghost_Call__c, 
            'Phone number from the VF page should be copied over to the new Case\'s Phone_Number_of_Ghost_Call__c field');
        System.assertEquals(ghostContact.Id, actualCase[0].ContactID, 
            'Default field value for ContactID specified in the customer setting should be set on the new Case');
        System.assertEquals(true, actualCase[0].Ghost_Call__c, 
            'Default field value for Ghost_Call__c specified in the customer setting should be set on the new Case');
        System.assertEquals('Case created as a result of a ghost call', actualCase[0].Other__c, 
            'Default field value for Other__c specified in the customer setting should be set on the new Case');
        System.assertEquals(TestUtil.SERVICE_CASES_READ_ONLY.Id, actualCase[0].RecordTypeId, 
            'Default field value for RecordTypeId specified in the customer setting should be set on the new Case');
        System.assertEquals('Closed - Unresolved', actualCase[0].Status, 
            'Default field value for Status specified in the customer setting should be set on the new Case');
        System.assertEquals('Other', actualCase[0].Type, 
            'Default field value for Type specified in the customer setting should be set on the new Case');
        System.assert(TestUtil.pageMessageContains('success'), 'Message about successfully creating a Ghost Case should be displayed');
        System.assert(TestUtil.pageMessageContains(actualCase[0].CaseNumber), 'Message about the newly created Case number should be displayed');
        System.assert(TestUtil.pageMessageContains('(781) 555-1234'), 'Message about the newly created Case number should be displayed');
        System.assert(String.isEmpty(pageController.constituentSearchForm.phone), 
            'Upon successful creation of ghost case, the phone field should be emptied out');*/
    }

    static testMethod void testLogGhostCallShortNumber() {
        setupValidGhostCallSettings();
        CTIScreenPopCtlr pageController = new CTIScreenPopCtlr();
        pageController.constituentSearchForm.phone = '1234'; // THIS IS THE RESULT OF THE JAVASCRIPT FORMATPHONE
        Test.startTest();
            pageController.logGhostCall();
        Test.stopTest();

        List<Case> actualCase = [SELECT Id, 
                                        CaseNumber,
                                        ContactID,
                                        Ghost_Call__c,
                                        Phone_Number_of_Ghost_Call__c,
                                        Other__c,
                                        RecordTypeId,
                                        Status,
                                        Type FROM Case];

        /*System.assertEquals(1, actualCase.size(), 'There should be exactly 1 Case created as a result of a call to logGhostCall');
        System.assertEquals('1234', actualCase[0].Phone_Number_of_Ghost_Call__c, 
            'Phone number from the VF page should be copied over to the new Case\'s Phone_Number_of_Ghost_Call__c field');
        System.assertEquals(ghostContact.Id, actualCase[0].ContactID, 
            'Default field value for ContactID specified in the customer setting should be set on the new Case');
        System.assertEquals(true, actualCase[0].Ghost_Call__c, 
            'Default field value for Ghost_Call__c specified in the customer setting should be set on the new Case');
        System.assertEquals('Case created as a result of a ghost call', actualCase[0].Other__c, 
            'Default field value for Other__c specified in the customer setting should be set on the new Case');
        System.assertEquals(TestUtil.SERVICE_CASES_READ_ONLY.Id, actualCase[0].RecordTypeId, 
            'Default field value for RecordTypeId specified in the customer setting should be set on the new Case');
        System.assertEquals('Closed - Unresolved', actualCase[0].Status, 
            'Default field value for Status specified in the customer setting should be set on the new Case');
        System.assertEquals('Other', actualCase[0].Type, 
            'Default field value for Type specified in the customer setting should be set on the new Case');
        System.assert(TestUtil.pageMessageContains('success'), 'Message about successfully creating a Ghost Case should be displayed');
        System.assert(TestUtil.pageMessageContains(actualCase[0].CaseNumber), 'Message about the newly created Case number should be displayed');
        System.assert(TestUtil.pageMessageContains('1234'), 'Message about the newly created Case number should be displayed');
        System.assert(String.isEmpty(pageController.constituentSearchForm.phone), 
            'Upon successful creation of ghost case, the phone field should be emptied out');*/
    }

    static testMethod void testSetGhostCaseField() {
        Case testCase = new Case();
        Ghost_Call_Settings__c testGcs = new Ghost_Call_Settings__c( Name='Status', Default_Field_Value__c='default' );
        Test.startTest();
            CTIScreenPopCtlr.setGhostCaseField(testCase, testGcs);
        Test.stopTest();

        System.assertEquals('default', testCase.Status, 'Default field value specified by the Ghost Call Setting should be set on the specified field');
    }

    static testMethod void testSetGhostCaseFieldInvalidFieldName() {
        Case testCase = new Case();
        Ghost_Call_Settings__c testGcs = new Ghost_Call_Settings__c( Name='StatusBAD', Default_Field_Value__c='default' );
        try {
            Test.startTest();
                CTIScreenPopCtlr.setGhostCaseField(testCase, testGcs);
            Test.stopTest();
            System.assert(false, 'Method should throw an invalid field exception for trying to set a value on a field that does not exist');
        } catch (CTIScreenPopCtlr.GhostCallSettingException e) {
            System.assert(e.getMessage().contains('Invalid field'), 'Method should throw an invalid field exception for trying to set a value on a field that does not exist');
        }
    }

}