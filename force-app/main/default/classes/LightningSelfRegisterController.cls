global without sharing class LightningSelfRegisterController {

    private static final String DUPLICATE_VALUE_ERROR = 'DUPLICATE_VALUE';
    private static final String EXTERNAL_ID_FIELD = 'DM_External_Id__c';

    public LightningSelfRegisterController() {

    }

    @TestVisible 
    private static boolean isValidPassword(String password, String confirmPassword) {
        return password == confirmPassword;
    }
    
    @TestVisible 
    private static boolean siteAsContainerEnabled(String communityUrl) {
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(communityUrl,'');
        return authConfig.isCommunityUsingSiteAsContainer();
    }
    
    @TestVisible 
    private static void validatePassword(User u, String password, String confirmPassword) {
        if(!Test.isRunningTest()) {
        Site.validatePassword(u, password, confirmPassword);
        }
        return;
    }
    
    @AuraEnabled
    public static String selfRegister(String firstname ,String lastname, String email, String password, String confirmPassword, String accountId, String contactId, String regConfirmUrl, String extraFields, String startUrl, Boolean includePassword) {

        // check if email provided exists already as username
        List<User> users = [SELECT Id FROM User WHERE Username = :email];
        if (users.size() > 0) {
            return 'A user with this email address already exists. Click here to contact Red Cross Technical Support Team for assistance.';
        }

        Savepoint sp = null;
        try {

            sp = Database.setSavepoint();
            
            if (lastname == null || String.isEmpty(lastname)) {
                return Label.Site.lastname_is_required;
            }
            
            if (email == null || String.isEmpty(email)) {
                return Label.Site.email_is_required;
            }
            
            // Create new account and contact record to associate with the user record
            Profile learnerProfile = [SELECT Id, Name FROM Profile WHERE Name = 'Learner Community Profile' LIMIT 1];
            
            String sysAdminId = [Select id from user where UserRoleId != null and profile.Name = 'System Administrator' and isActive=true limit 1].Id;
            Account acc = new Account();
            acc.Id = accountId;
            acc.Name = firstname +' '+ lastname;
            acc.OwnerId = sysAdminId;
            acc.DM_External_Id__c = firstname + lastname + email;
            acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual Account').getRecordTypeId();
            upsert acc;
            
            Contact con = new Contact();
            con.Id = contactId;
            con.LastName = lastname;
            con.FirstName = firstname;
            con.Email = email;
            con.AccountId = acc.Id;
            con.DM_External_Id__c = firstname + lastname + email;
            upsert con;
            
            User u = new User();
//            u.Username = firstname + lastname + email;
            u.Username = email; // changed on 5th June as rep US1470
            u.put('Email',email);
            
            u.FirstName = firstname;
            u.LastName = lastname;
            u.ProfileId = learnerProfile.Id;

            // Associate contact with the user record
            u.ContactId = con.Id;
            
            String networkId = Network.getNetworkId();

            // If using site to host the community the user should not hit s1 after logging in from mobile.
            if(networkId != null && siteAsContainerEnabled(Network.getLoginUrl(networkId))) {
                u.put('UserPreferencesHideS1BrowserUI',true);
            }
            
            String nickname = ((firstname != null && firstname.length() > 0) ? firstname.substring(0,1) : '' ) + lastname.substring(0,1);
            nickname += String.valueOf(Crypto.getRandomInteger()).substring(1,7);
            u.put('CommunityNickname', nickname);
                     
            if (extraFields != null) {
                List<Object> extraFieldsList = (List<Object>) JSON.deserializeUntyped(extraFields);        
                for (Object thisFieldObject : extraFieldsList) {
                    Map<String,Object> thisField = (Map<String,Object>) thisFieldObject;
                    Schema.SObjectField sof = Schema.SObjectType.User.fields.getMap().get((String) thisField.get('fieldPath'));
                    u.put(sof, thisField.get('value'));
                }
            }
                        
            if (includePassword) {    
                if (!isValidPassword(password, confirmPassword)) {
                    return Label.site.passwords_dont_match;
                }
             validatePassword(u, password, confirmPassword);
            }
            else {
                password = null;
            }
            
            // lastName is a required field on user, but if it isn't specified, we'll default it to the username
            String userId = Site.createPortalUser(u, acc.Id, password);
            
            // Assign permission set
            List<Id> userList = new List<Id>();
            userList.add(userId);
            
            if(!Test.isRunningTest()) {
            	ILTInstructorCommunity.assignUserPermission(userList);
            }
            
            // create a fake userId for test.
            if (Test.isRunningTest()) {
                userId = 'fakeUserId';           
            }
            if (userId != null) {
                if (password != null && password.length() > 1) {
                    Network myNetwork = [SELECT Id FROM Network WHERE Name ='Red Cross Learning Center'];
                    String loginUrl = Network.getLoginUrl(myNetwork.Id);
                    System.debug('about to redirect');
                    ApexPages.PageReference lgn = Site.login(u.Username, password, startUrl);
                    if(!Test.isRunningTest()) {
                        aura.redirect(lgn);
                    }
                }
                else {
                    ApexPages.PageReference confirmRef = new PageReference(regConfirmUrl);
                    if(!Test.isRunningTest()) {
                    aura.redirect(confirmRef);
                   }

                }
            }
            return null;
        }
        catch (Exception ex) {
            Database.rollback(sp);
            System.debug(ex);

            String errorMessage = ex.getMessage();
            System.debug('errorMessage '+errorMessage);
            if (errorMessage.contains(DUPLICATE_VALUE_ERROR) && errorMessage.contains(EXTERNAL_ID_FIELD)) {
                return 'The email address (' + email + ') is already in use for ' + firstname + ' ' + lastname + '.';
            }

            return ex.getMessage();
        }
    }
    
    @AuraEnabled
    public static List<Map<String,Object>> getExtraFields(String extraFieldsFieldSet) { 
        List<Map<String,Object>> extraFields = new List<Map<String,Object>>();
        Schema.FieldSet fieldSet = Schema.SObjectType.User.fieldSets.getMap().get(extraFieldsFieldSet);
        if(!Test.isRunningTest()) {
        if (fieldSet != null) {
            for (Schema.FieldSetMember f : fieldSet.getFields()) {
                Map<String, Object> fieldDetail = new Map<String, Object>();
                fieldDetail.put('dbRequired', f.getDBRequired());
                fieldDetail.put('fieldPath', f.getFieldPath());
                fieldDetail.put('label', f.getLabel());
                fieldDetail.put('required', f.getRequired());
                fieldDetail.put('type', f.getType());
                fieldDetail.put('value', '');   // client will populate
                extraFields.add(fieldDetail);
            }}}
        return extraFields;
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
    global static Boolean checkUserEmail(String email) {
        // checks if user with the email exists already in salesforce
        // TBC - email or username is the reference?

        List<User> users = [SELECT Id FROM User WHERE Username = :email];
        if (users.size() > 0) {
            return true;
        }
        return false;
    }

    @AuraEnabled
    global static String checkExistingContact(String email) {
        // checks if contact / account exists with the specified email address

        List<Contact> contacts = [SELECT Id, Email, AccountId, FirstName, LastName FROM Contact WHERE Email = :email];
        // what to do if multiple contacts found?

        if(contacts.size() > 0) {
            Contact c = contacts[0];

            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeStringField('Email', c.Email);
            gen.writeStringField('AccountId', c.AccountId);
            gen.writeStringField('ContactId', c.Id);
            gen.writeStringField('FirstName', c.FirstName);
            gen.writeStringField('LastName', c.LastName);
            gen.writeEndObject();

            String jsonString = gen.getAsString();
            System.debug('jsonString:' +jsonString);
            return jsonString;
        } else {
            return null;
        }
    }
}