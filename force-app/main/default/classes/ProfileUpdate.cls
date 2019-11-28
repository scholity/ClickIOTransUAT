@RestResource(urlMapping='/ProfileUpdate/*')
global without sharing class ProfileUpdate {

    @HttpPatch
    global static String updateProfile(String  profileId, String userId)
    {   
        Id RoleId = [SELECT Id FROM UserRole WHERE PortalAccountOwnerId =: UserInfo.getUserId() LIMIT 1].Id;
        
        system.debug('RoleId%%%'+RoleId);
        
        update new User(Id=userId,ProfileId = profileId, UserRoleId = RoleId);
           
        return 'Profile Updated';
    }

}