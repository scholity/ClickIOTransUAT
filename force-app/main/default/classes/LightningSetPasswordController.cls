/**
 * Created by bjarmolinski on 2019-06-13.
 */

global without sharing class LightningSetPasswordController {

    public static final String KEYSTRING = '9e9328f99b7d933fdc7d3787c727d887';
    static final String GENERIC_ERROR = 'An error occured. Please contact Technical Support.';

    @AuraEnabled
    public static String resetPassword(String password, String encryptedEmail, String startUrl) {

//        String startUrl = 'dev01-shop-arc.demandware.net/on/demandware.store/Sites-RedCross-Site'; // to be corrected for dynamic link instance independent
        Blob key = EncodingUtil.convertFromHex(KEYSTRING);
        Blob encrypted = EncodingUtil.convertFromHex(encryptedEmail);

        Blob decrypted = Crypto.decryptWithManagedIV('AES128', key, encrypted);
        System.debug(decrypted);

        String email = decrypted.toString();
        System.debug(email);

        // check if email exists
        List<User> users = [SELECT Id FROM User WHERE Username = :email];

        System.debug(users);
        if (users.size() > 0) {
            // set password
            try {
                System.setPassword(users[0].Id, password );
                System.debug(password);
                System.debug(users[0].Id);
                loginUser(email, password, startUrl);
                return 'Password has been changed';

            } catch (Exception e){
                System.debug(e.getMessage());
                return GENERIC_ERROR;
            }
        } else {
            return GENERIC_ERROR;
        }
    }
    

    @AuraEnabled
    public static void loginUser (String username, String password, String startUrl) {

        try{
            ApexPages.PageReference lgn = Site.login(username, password, startUrl);
            System.debug(lgn);
            aura.redirect(lgn);
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }

    }
}