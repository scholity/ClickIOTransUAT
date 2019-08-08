@isTest
private class TestUserUtils 
{
    static testMethod void testAllMethods() {
        string userId= UserInfo.getUserId();
        UserUtils.getQueuesUserIsAMemberOf(userId);
        UserUtils.getPublicGroupsUserIsAMemberOf(userId);
        UserUtils.getQueuesUserRoleIsAMemberOf(userId);        
    }
}