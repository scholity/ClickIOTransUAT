@IsTest
public with sharing class LightningLoginFormControllerTest {

    @IsTest
    static void testLoginWithInvalidCredentials() {
        System.assertEquals('Argument 1 cannot be null', LightningLoginFormController.login('testUser', 'fakepwd', null));
    }
    
    @IsTest
    static void LightningLoginFormControllerInstantiation() {
        LightningLoginFormController controller = new LightningLoginFormController();
        System.assertNotEquals(controller, null);
    }
    
    @IsTest
    static void testIsUsernamePasswordEnabled() {
        System.assertEquals(true, LightningLoginFormController.getIsUsernamePasswordEnabled());
    }
    
    @IsTest
    static void testIsSelfRegistrationEnabled() {
        System.assertEquals(false, LightningLoginFormController.getIsSelfRegistrationEnabled());
    }
    
    @IsTest
    static void testGetSelfRegistrationURL() {
        System.assertEquals(null, LightningLoginFormController.getSelfRegistrationUrl());
    }
    
    @IsTest
    static void testAuthConfig() {
        Auth.AuthConfiguration authConfig = LightningLoginFormController.getAuthConfig();
        System.assertNotEquals(null, authConfig);
    }
    /*
    @isTest
    static void testForgottenPasswd() {
        User u = [SELECT Id, Name, Username FROM User WHERE isPortalEnabled = true AND ContactId != null AND Name = 'Bartosz Test1641' LIMIT 1];
        System.debug(u);
        String passwdUrl = LightningLoginFormController.getForgotPasswordUrl();
        System.debug(passwdUrl);
    }
    */
 	@isTest
    static void testCheckUserEmail() {
        
        // call method with unexistant username
        Boolean firstCall = LightningLoginFormController.checkUserEmail('testuser123@gamil124.de');
        System.assertEquals(false, firstCall);
        
    	// create user
        User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Alias = 'tstu';
        u.Username = 'testuser123@gamil124.de';
        u.Email = 'testuser123@gamil124.de';
        u.CommunityNickname = 'testuser123';
        u.TimeZoneSidKey = 'GMT';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id;
        u.LanguageLocaleKey = 'en_US';
        insert u;
        
        Boolean secondCall = LightningLoginFormController.checkUserEmail('testuser123@gamil124.de');
        System.assertEquals(true, secondCall);
    }
    
    @isTest
    static void testSetExpId() {
        String result = LightningLoginFormController.setExperienceId('asd24');
        System.assertNotEquals(null, result);
    }
}