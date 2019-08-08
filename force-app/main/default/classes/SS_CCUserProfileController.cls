public class SS_CCUserProfileController {
    @AuraEnabled
    // Get Current User Profile.
    public static User getUserProfile(String userId){ 
        if(userId == null){
            userId = UserInfo.getUserId();
        }
        List<User> userList = [SELECT Id, LanguageLocaleKey, CommunityNickName, FirstName, 
                               LastName, Name, Email, CompanyName, IsPortalEnabled ,
                               Profile.UserLicense.LicenseDefinitionKey,  SmallPhotoUrl, 
                               Contact.Email, Contact.Phone, Contact.HomePhone, Contact.MobilePhone, 
                               Contact.Account.Id, Contact.Account.Name,  
                               Profile.Name From User Where Id=:userId];
        if(userList.size()>0){
            return userList[0];
        }
        return null;
    } 
}