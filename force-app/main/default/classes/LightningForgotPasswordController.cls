global class LightningForgotPasswordController {

    public LightningForgotPasswordController() {

    }

    @AuraEnabled
    public static String forgotPassword(String username, String checkEmailUrl) {
        try {
            Site.forgotPassword(username);
            ApexPages.PageReference checkEmailRef = new PageReference(checkEmailUrl);
            if(!Site.isValidUsername(username)) {
                return Label.Site.invalid_email;
            }
            aura.redirect(checkEmailRef);
            return null;
        }
        catch (Exception ex) {
            return ex.getMessage();
        }
    }

    @AuraEnabled
    global static String setExperienceId(String expId) {    
        // Return null if there is no error, else it will return the error message 
        try {
            if (expId != null) {
                Site.setExperienceId(expId);               
            }
            return null; 
        } catch (Exception ex) {
            return ex.getMessage();            
        }        
    }

    @AuraEnabled
    public static Boolean forgotPasswordB2C(String username, String startUrl, String baseUrl) {

        // encrypt username - the encrupted value will appear as query string parameter in password reset link
        String keyString = LightningSetPasswordController.KEYSTRING;
        Blob key = EncodingUtil.convertFromHex(keyString);
        Blob blobUsername = Blob.valueOf(username);
        Blob encrypted = Crypto.encryptWithManagedIV('AES128', key, blobUsername);
        String encryptedString = EncodingUtil.convertToHex(encrypted);
        String encryptedUrlEncoded = EncodingUtil.urlEncode(encryptedString, 'UTF-8');


        // URL TO BE CHANGED TO DYNAMIC
        //String resetPasswdUrl = 'https://transdev1-americanredcross.cs52.force.com/learner/s/set-new-password-b2c?startURL='+ startUrl + '&src=' + encryptedUrlEncoded;
        String resetPasswdUrl = 'https://' + baseUrl + '/learner/s/set-new-password-b2c?startURL='+ startUrl + '&src=' + encryptedUrlEncoded;

        List<EmailTemplate> emailTemplates = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = 'PHSS_ICommunity_Forgot_Password_B2C'];
        EmailTemplate template = emailTemplates[0];

        List<User> users = [SELECT Id, FirstName FROM User WHERE Username =:username];
        String firstName = users[0].FirstName;
        Id userId = users[0].Id;

        // pass relevant link to email body
        String subject = template.Subject;
        String htmlBody = template.HtmlValue;
        htmlBody = htmlBody.replace('{!resetPasswdUrl}', resetPasswdUrl);
        htmlBody = htmlBody.replace('{!FirstName}', firstName);
        
        // filter out spurious HTML inserted by Salesforce (appears to be a platform bug!!)
        htmlBody = htmlBody.replace('<![CDATA[','');        
        htmlBody = htmlBody.replace(']]>','');

        String plainBody = template.Body;
        plainBody = plainBody.replace('{!resetPasswdUrl}', resetPasswdUrl);
        plainBody = plainBody.replace('{!FirstName}', firstName);

        // send email to user
        Messaging.Singleemailmessage email = new Messaging.Singleemailmessage();
        email.setTargetObjectId(userId);
        email.setSaveAsActivity(false);
        email.setSubject(subject);
        email.setHtmlBody(htmlBody);
        email.setPlainTextBody(plainBody);

        try {
            Messaging.sendEmail(new Messaging.SingleEmailmessage[] {email});
            return true;
        } catch (Exception e) {
            System.debug(e.getMessage());
            return false;
        }
    }
}