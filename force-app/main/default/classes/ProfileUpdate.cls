@RestResource(urlMapping='/ProfileUpdate/*')
global without sharing class ProfileUpdate {

    @HttpPatch
    global static String updateProfile(String  profileId, String userId)
    {   
        //Id RoleId = [SELECT Id FROM UserRole WHERE PortalAccountOwnerId =: UserInfo.getUserId() LIMIT 1].Id;

        List<UserRole> role = [SELECT Id FROM UserRole WHERE PortalAccountOwnerId =: UserInfo.getUserId() LIMIT 1];
        
        if(role.size() > 0)
        {
            system.debug('RoleId%%%'+role[0].Id);
        
            update new User(Id=userId,ProfileId = profileId, UserRoleId = role[0].Id);
        }
        else
        {
            update new User(Id=userId,ProfileId = profileId);
        }
           
        return 'Profile Updated';
    }

}