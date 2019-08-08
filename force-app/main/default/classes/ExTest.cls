@isTest
private class ExTest {

	private static final String THIS_CLASS_NAME = 'ExTest';
	private static final String CLASS_QUAL_NAME = 'Class.' + THIS_CLASS_NAME;
	
	private static final String NULL_EX_TYPE = 	'System.NullPointerException';
	private static final String DML_EX_TYPE = 	'System.DmlException';

	/////////////////////////////////////////////////////////////////
	//				Unit Tests
	/////////////////////////////////////////////////////////////////



	/////////////////////////////////////////////////////////////////
	//				"End to End" Tests
	/////////////////////////////////////////////////////////////////
	
	
    private static testMethod void testClassResolutionOnLowLevel() {
    	
    	System.runAs( createUser( 't3ts', getSystemAdministratorProfileId(), true ) ) {
    	
		
			Test.startTest();
			
				try {
					
					nullPointerException(); 
				
				} catch( System.Exception ex ) {
					
					ExLog.log( ex );
					
				}
				
				try {
					
					dmlException();
				
				} catch( System.Exception ex ) {
					
					ExLog.log( ex );
					
				}				
					

			Test.stopTest();
			
			List<Logged_Exception__c> resolvedExceptions = [ SELECT Id, Type__c, Class_Name__c, Class_Id__c FROM Logged_Exception__c WHERE CreatedById = :UserInfo.getUserId() ];
			
			Id thisClassesId = [ SELECT Id FROM ApexClass WHERE Name = :THIS_CLASS_NAME ].Id;
			
			System.assertEquals( 2, resolvedExceptions.size(), 'Logged Exception not properly created.' );

			Boolean foundClasslessDml = false;

			for ( Logged_Exception__c aLoggedEx : resolvedExceptions ) {
				
				if ( aLoggedEx.Type__c == DML_EX_TYPE ) {
					 
					foundClasslessDml = true;
					System.assertEquals( CLASS_QUAL_NAME, aLoggedEx.Class_Name__c);
					System.assertEquals( thisClassesId, aLoggedEx.Class_Id__c);
					
				}
			}
			
			System.assert( foundClasslessDml, 'Logged DML Exception with Class info not found' );
			
    	}
		
    }
	
	private static testMethod void testCustomAttributesException() {
		
			
		System.runAs( createUser( 't3ts', getSystemAdministratorProfileId(), true ) ) {
    	String myCustomMessage  = 'My Custom Exception Message!';
    	String testClassName = 'MyTestClassName';
    	
		Test.startTest();
		
			try {
				
				dmlException();
			
			} catch( System.Exception ex ) {
				
				ExLog.log(myCustomMessage, testClassName);
			}
					
			Test.stopTest();
			
			Logged_Exception__c resolvedException = [ SELECT Id, Class_Name__c, Exception_Description__c FROM Logged_Exception__c WHERE CreatedById = :UserInfo.getUserId() order by CreatedDate desc limit 1][0];
			
			System.assertEquals(resolvedException.Exception_Description__c, myCustomMessage);
			System.assertEquals(resolvedException.Class_Name__c, testClassName);
		}
	}
	
    private static testMethod void testSingleDmlException() {
    	
    	System.runAs( createUser( 't3ts', getSystemAdministratorProfileId(), true ) ) {
    	
			Test.startTest();
			
				try {
					
					dmlException();
				
				} catch( System.Exception ex ) {
					
					ExLog.log( ex );
					
				}
					
			Test.stopTest();
			
			List<Logged_Exception__c> resolvedExceptions = [ SELECT Id, Type__c FROM Logged_Exception__c WHERE CreatedById = :UserInfo.getUserId() ];
			
			System.assertEquals( 1, resolvedExceptions.size(), 'Logged Exception not properly created.' );
			System.assertEquals( DML_EX_TYPE, resolvedExceptions[0].Type__c, 'Logged Exception of incorrect type.' );
			
    	}
		
    }
	
    private static testMethod void testSingleNullException() {
    	
    	System.runAs( createUser( 't3ts', getSystemAdministratorProfileId(), true ) ) {
    	
			Test.startTest();
			
				try {
					
					nullPointerException();
				
				} catch( System.Exception ex ) {
					
					ExLog.log( ex );
					
				}
					
			Test.stopTest();
			
			List<Logged_Exception__c> resolvedExceptions = [ SELECT Id, Type__c FROM Logged_Exception__c WHERE CreatedById = :UserInfo.getUserId() ];
			
			System.assertEquals( 1, resolvedExceptions.size(), 'Logged Exception not properly created.' );
			System.assertEquals( NULL_EX_TYPE, resolvedExceptions[0].Type__c, 'Logged Exception of incorrect type.' );
			
    	}
		
    }
	


	/////////////////////////////////////////////////////////////////
	//				Error-generating helper methods
	/////////////////////////////////////////////////////////////////
    
    private static void nullPointerException() {
    	
    	String testString;
    	Boolean testBool = testString.startsWith( 'text' );
    	
    }
    
    private static void dmlException() {
    	
    	update new Account();
    	
    }
    
    /////////////////////////////////////////////////////////////////
	//				test data helper methods
	/////////////////////////////////////////////////////////////////
    
    private static User ADMIN_USER {
		get {
			if ( ADMIN_USER == null ){
				ADMIN_USER = [SELECT Id FROM User WHERE Profile.Name ='System Administrator' AND isActive = true LIMIT 1];
			}
			return ADMIN_USER;
		}
	}
    
    private static Id getSystemAdministratorProfileId() {
    	return [SELECT Id FROM Profile WHERE Name ='System Administrator' LIMIT 1].Id;
    } 
    
    private static User createUser ( String uname, Id profileId,  Boolean willInsert ) {

			User testUser = new User();
			testUser.LastName = uname ;
			testUser.Alias = uname;
			testUser.Email = uname +'@test.com';
			testUser.Username = uname +'@test.com';
			testUser.CommunityNickname = 'atest'+ uname;
			testUser.TimeZoneSidKey = 'America/New_York';
			testUser.LocaleSidKey = 'en_US';
			testUser.EmailEncodingKey = 'ISO-8859-1';
			testUser.ProfileId = profileId;
			testUser.LanguageLocaleKey = 'en_US';
			testUser.IsActive = true;

			if ( willInsert ) {
				System.runAs( ADMIN_USER ){
					insert testUser;
				}
			}
		return testUser; 
	}
    
    
}