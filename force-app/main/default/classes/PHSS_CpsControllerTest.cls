@isTest
private class PHSS_CpsControllerTest {
    
    static testmethod void cpsTest() {
    	
        
        // Create community user record
        List<Profile> profList = [SELECT Id FROM Profile WHERE Name = 'SB PHSS-Partner-Community Plus Login' LIMIT 1];
        String profId;
        ccrz__E_Product__c ccprod;
        
        if(!profList.isEmpty()) {
        	Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Bucket Account').getRecordTypeId();
        
            //Bucket Custom settings
            Bucket_Account_Settings__c bas = Bucket_Account_Settings__c.getOrgDefaults();
            bas.Bucket_Account_Owner_ID__c = UserInfo.getUserID();
            bas.Bucket_Account_RecordTypeID__c = recordTypeId;
            bas.Default_Bucket_Name__c = 'Bucket Account';
            bas.Maximum_Size_of_Bucket__c = 5000;
            insert bas;
        
            profId = profList[0].Id;
        
            // Get an user with a role
            List<User> userWithRole = [SELECT id, UserRole.Name 
                                       FROM User 
                                       WHERE (NOT UserRole.Name LIKE '%Customer User') AND
                                       		 UserRoleId != null AND
                                       		 Profile.Name = 'System Administrator' AND
                                       		 isActive = true
                                       LIMIT 1];
            
            User partnerUser;
            
            
            Account acc = new Account();
            System.runAs(userWithRole[0]) {
                acc.Name = 'TestAccount';
                acc.BillingStreet = '24 Willie Mays Plaza';
                acc.BillingCity = 'San Francisco';
                acc.BillingState = 'California';
                acc.BillingPostalCode = '94017';
                acc.BillingCountry = 'USA';
                acc.Phone = '9876543210';
                insert acc;

                Contact con = new Contact();
                con.FirstName = 'Contact';
                con.LastName = 'Test';
                con.Email = 'testCon@gmail.com';
                con.Account = acc;
                insert con;

                partnerUser = new User(LastName = 'Test',
                                         FirstName = 'User',
                                         Alias = 'testU',
                                         Email = 'testCon@gmail.com',
                                         Username = 'testUser@redCross.com',
                                         ProfileId = profId,
                                         ContactId = con.id,
                                         TimeZoneSidKey = 'GMT',
                                         LanguageLocaleKey = 'en_US',
                                         EmailEncodingKey = 'UTF-8',
                                         LocaleSidKey = 'en_US'
                                        );
                insert partnerUser;
                
                ccprod = new ccrz__E_Product__c(
                    Name = 'Lifeguarding',
                    ccrz__SKU__c = 'HSSAQU402',
                    ccrz__Quantityperunit__c = 1,
                    ccrz__StartDate__c = Date.today(),
                    ccrz__EndDate__c = Date.today().addMonths(12)
                );
                insert ccprod;

            }
            
            // Create Learning Plan record to use it as a course in postClass method
            redwing__Training_Plan__c lPlan = new redwing__Training_Plan__c();
            lPlan.Name = 'Test Plan';
            insert lPlan;
        	
            // Create account 
            Account testAcc = new Account();
            testAcc.Name = 'Test Org';
            testAcc.OwnerId = partnerUser.Id;
            insert testAcc;
            
            Map<String, Object> testData = phss_cc_TestDataFactory.setupAccountAndProducts();
			Account testAccount = (Account) testData.get(phss_cc_TestDataFactory.TEST_ACCOUNT);
			Opportunity testOpportunity = phss_cc_TestDataFactory.createInsertTestOpportunity(testAccount);

            
            String jsonStr = '{'+
                                ' "accId": "' + testAcc.Id +'",'+
                                ' "accName": "' + testAcc.Name +'",'+
                                ' "address1":"add1",'+
                                ' "address2":"add2",'+
                                ' "city":"test city",'+
                                ' "classFormat":"Classroom",'+                    
                                ' "courseName": "' + lPlan.Name +'",'+
                                ' "sessionList":[{"classDate":"2018-12-09",'+
                                                ' "endTime":"01:00:00.000",'+
                                                ' "startTime":"00:15:00.000",'+
                                                ' "timeZone":"US/Eastern"}],'+
                                ' "siteName":"test site",'+
                                ' "state":"NY",'+
                				' "timeZoneList": {"US/Eastern":"America/New_York",'+
                									' "US/Central":"America/Chicago",'+
                									' "US/Mountain":"America/Denver",'+
                								    ' "US/Pacific":"America/Los_Angeles",'+
                									' "US/Alaska":"America/Anchorage",'+
                									' "US/Arizona":"America/Phoenix",'+
                									' "US/Hawaii":"Pacific/Honolulu",'+
                									' "America/Puerto_Rico":"America/Puerto_Rico"},'+
                                ' "zip":"12345",'+
                                ' "regEmail":"testreg@gmail.com",'+
                                ' "regPhone":"9876543210",'+
                                ' "regFee":"200",'+
                                ' "courseId": "' + lPlan.Id +'"'+
                              '}';
            
            

            
            Test.startTest();
            System.runAs(partnerUser) {
            	// Assign permission set 'LMS External user'
                List<PermissionSet> permSet = [Select Id,Name From PermissionSet Where Name = 'LMS_External_User'];
                    
                PermissionSetAssignment psa = new PermissionSetAssignment ();
                psa.PermissionSetId = permSet[0].Id;
                psa.AssigneeId = partnerUser.Id;
                insert psa;
                                
                PHSS_CpsController.initWrapper();

                String oppId = PHSS_CpsController.createOppForCCUpdate(testAcc.Id, 'CPS', testOpportunity.Id);
                
                //PHSS_CpsController.updateCartProducts(testOpportunity.Id, lPlan.CC_Product__c, '1');
                Map<String, Object> testMap = PHSS_CpsController.initProductQuantityMap();
                testMap = PHSS_CpsController.updateProductQuantityMap(testMap,lPlan.CC_Product__c, '1');
                testMap = PHSS_CpsController.updateCartProducts(ccprod.Id,testMap);
                
                PHSS_CpsController.getLearningPlanId(ccprod.Id);
               	PHSS_CpsController.getLearningPlanAttributes(ccprod.Id);
                
                PHSS_CpsController.createIltLocation(testAcc.Id, 'test site', 'add1', 'add2', '12345', 'NY', 'test city', '38.894878', '-77.0413765');
                
                PHSS_CpsController.getDisplayPaymentInfo(oppId);
                
                PHSS_CpsController.postClass(jsonStr);

            }
            Test.stopTest();
            List<redwing__ILT_Class__c> iltClass = [Select Id From redwing__ILT_Class__c Where Name = :lPlan.Name];
            System.assert(!iltClass.isEmpty());
        }
    }
  
}