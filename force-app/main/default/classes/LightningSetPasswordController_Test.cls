/**
 * Created by bjarmolinski on 2019-06-17.
 */

@IsTest
private class LightningSetPasswordController_Test {

    @testSetup
    static void createDate() {
        // create user
        User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Alias = 'tstu';
        u.Username = 'imaginative.user123@redcross.org';
        u.Email = 'imaginative.user123@redcross.org';
        u.CommunityNickname = 'testuser123';
        u.TimeZoneSidKey = 'GMT';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id;
        u.LanguageLocaleKey = 'en_US';
        insert u;
    }

    @IsTest
    static void test1() {
        // scenario 1 - password changed successfully

        //encrypt email and provide to the class
        String email = 'imaginative.user123@redcross.org';

        String keyString = LightningSetPasswordController.KEYSTRING;
        Blob key = EncodingUtil.convertFromHex(keyString);
        Blob blobUsername = Blob.valueOf(email);
        Blob encrypted = Crypto.encryptWithManagedIV('AES128', key, blobUsername);
        String encryptedString = EncodingUtil.convertToHex(encrypted);
        String encryptedUrlEncoded = EncodingUtil.urlEncode(encryptedString, 'UTF-8');


        // password - meeting criteria
        String password = 'RedCross123!';

        // provide sample start url
        String startUrl = 'sometextimitatingencodedstarturl';

        // call LightningSetPasswordController.resetPassword(String password, String encryptedEmail, String startUrl)
        String retValue = LightningSetPasswordController.resetPassword( password, encryptedUrlEncoded, startUrl);
        System.debug(retValue);

        System.assertEquals('Password has been changed', retValue);
    }

    @isTest
    static void test2() {
        // scenario 2 - there is no user with the username passed to the class

        // cause error - no user found
        //encrypt email and provide to the class
        String email = 'nonexistant.user123@redcross.org';

        String keyString = LightningSetPasswordController.KEYSTRING;
        Blob key = EncodingUtil.convertFromHex(keyString);
        Blob blobUsername = Blob.valueOf(email);
        Blob encrypted = Crypto.encryptWithManagedIV('AES128', key, blobUsername);
        String encryptedString = EncodingUtil.convertToHex(encrypted);
        String encryptedUrlEncoded = EncodingUtil.urlEncode(encryptedString, 'UTF-8');

        // provide some password
        String password = 'RedCross123!';

        // provide sample start url
        String startUrl = 'sometextimitatingencodedstarturl';

        // call LightningSetPasswordController.resetPassword(String password, String encryptedEmail, String startUrl)
        String retValue = LightningSetPasswordController.resetPassword( password, encryptedUrlEncoded, startUrl);

        System.assertEquals('An error occured. Please contact Technical Support.', retValue);

    }

    @isTest
    static void test3() {
        // password does not meet criteria

        //encrypt email and provide to the class
        String email = 'imaginative.user123@redcross.org';

        String keyString = LightningSetPasswordController.KEYSTRING;
        Blob key = EncodingUtil.convertFromHex(keyString);
        Blob blobUsername = Blob.valueOf(email);
        Blob encrypted = Crypto.encryptWithManagedIV('AES128', key, blobUsername);
        String encryptedString = EncodingUtil.convertToHex(encrypted);
        String encryptedUrlEncoded = EncodingUtil.urlEncode(encryptedString, 'UTF-8');


        // password that does not meet criteria
        String password = 'redcross';

        // provide sample start url
        String startUrl = 'sometextimitatingencodedstarturl';

        // call LightningSetPasswordController.resetPassword(String password, String encryptedEmail, String startUrl)
        String retValue = LightningSetPasswordController.resetPassword( password, encryptedUrlEncoded, startUrl);

        System.assertEquals('An error occured. Please contact Technical Support.', retValue);
    }
}