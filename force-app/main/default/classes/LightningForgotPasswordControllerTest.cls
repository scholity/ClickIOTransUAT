@IsTest
public with sharing class LightningForgotPasswordControllerTest {

 @testSetup
 static void createData() {
  // create user
  User u = new User();
  u.FirstName = 'Test';
  u.LastName = 'User';
  u.Alias = 'tstu';
  u.Username = 'testuser123@gmail124.de';
  u.Email = 'testuser123@gmail124.de';
  u.CommunityNickname = 'testuser123';
  u.TimeZoneSidKey = 'GMT';
  u.LocaleSidKey = 'en_US';
  u.EmailEncodingKey = 'ISO-8859-1';
  u.ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id;
  u.LanguageLocaleKey = 'en_US';
  insert u;
 }

 /* Verifies that ForgotPasswordController handles invalid usernames appropriately */
 @IsTest
 static void testLightningForgotPasswordControllerInvalidUserName() {
    System.assertEquals(LightningForgotPasswordController.forgotPassword('fakeUser', 'http://a.com'), Label.Site.invalid_email);
    System.assertEquals(LightningForgotPasswordController.forgotPassword(null, 'http://a.com'), Label.Site.invalid_email);
    System.assertEquals(LightningForgotPasswordController.forgotPassword('a', '/home/home.jsp'), Label.Site.invalid_email);
 }

 /* Verifies that null checkEmailRef url throws proper exception. */
 @IsTest
 static void testLightningForgotPasswordControllerWithNullCheckEmailRef() {
  System.assertEquals(LightningForgotPasswordController.forgotPassword('a', null), 'Argument 1 cannot be null');
  System.assertEquals(LightningForgotPasswordController.forgotPassword('a@salesforce.com', null), 'Argument 1 cannot be null');
 }

 /* Verifies that LightningForgotPasswordController object is instantiated correctly. */
 @IsTest
 static void LightningForgotPasswordControllerInstantiation() {
  LightningForgotPasswordController controller = new LightningForgotPasswordController();
  System.assertNotEquals(controller, null);
 }

 @isTest
 static void testForgotPassword_B2C() {

  // random startUrl
  String startUrl = 'asdasdasd12321';
  String baseUrl = 'placeholderfordynamiccommunitydomain';
  User u = [SELECT Id, Username FROM User WHERE Username = 'testuser123@gmail124.de' LIMIT 1];

  // call forgotPasswordB2C(String username, String startUrl)
  Boolean resetEamilSent = LightningForgotPasswordController.forgotPasswordB2C(u.Username, startUrl, baseUrl);

  System.assertEquals(true, resetEamilSent);
 }

 @isTest
 static void testForgotPassword() {

  User u = [SELECT Id, Username FROM User WHERE Username = 'testuser123@gmail124.de' LIMIT 1];
  
  String retString = LightningForgotPasswordController.forgotPassword( u.Username, null);
  System.debug('retString '+retString);
  System.assertNotEquals(null, retString);
 }

 @isTest
 static void testSetExpId() {

  String expId = 'ad034';
  String retString = LightningForgotPasswordController.setExperienceId(expId);
  System.debug(retString);
  System.assertNotEquals(null, retString);
 }

}