public with sharing class RCUserWrapper {

    @AuraEnabled public String userId;
    @AuraEnabled public String userName;
    @AuraEnabled public String userPhoto;
    @AuraEnabled public String userLink;

    public RCUserWrapper (User userItem) {
        userId      = userItem.Id;
        userName    = userItem.Name;
        userPhoto   = userItem.MediumPhotoUrl;
        userLink    = RCUtils.getDetailLink('', userItem.Id);
    }

    public RCUserWrapper () {
        User userItem = [ SELECT Name, MediumPhotoUrl
                FROM User
                WHERE Id = :RCConstants.USER_ID
                LIMIT 1];

        this.UserId     = userItem.Id;
        this.userName   = userItem.Name;
        this.userPhoto  = userItem.MediumPhotoUrl;
        this.userLink   = RCUtils.getDetailLink('', userItem.Id);
    }

}