global class PHSS_FutureActions {
    public static void removeGroupMembership(List<Id> exGroupMemberIds){
        Savepoint sp = Database.setSavepoint();
        try {
            delete [SELECT Id FROM GroupMember WHERE Id IN :exGroupMemberIds ORDER BY Id];
        } catch(Exception e) {
            Database.rollback(sp);
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
        }
    }

    public static void createGroupMembership(Map<Id, Set<Id>> data){
        List<GroupMember> membershipsToCreate = new List<GroupMember>();
        for(Id userId: data.keySet()) {
            if(userId != null){
                for(Id groupId: data.get(userId)) {
                    if(groupId != null){
                        membershipsToCreate.add(new GroupMember(UserOrGroupId = userId, GroupId = groupId));
                    }
                }
            }
        }
        Savepoint sp = Database.setSavepoint();
        try {
            insert membershipsToCreate;
        } catch(Exception e) {
            Database.rollback(sp);
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
        }
    }

    public static void deactivateUsers(Set<Id> usersToDeactivate, Map<Id, String> toUpdateUsername){
        Set<Id> usersIds = new Set<Id>();
        usersIds.addAll(usersToDeactivate);
        usersIds.addAll(toUpdateUsername.keySet());
        List<User> users = [SELECT Id FROM User WHERE Id IN :usersIds];
        for(User us: users) {
            if(usersToDeactivate.contains(us.Id)) {
                us.IsActive = false;
            }
            if(toUpdateUsername.containsKey(us.Id)) {
                us.Username = toUpdateUsername.get(us.Id);
            }
        }
        try {
            update users;
        } catch(Exception e){
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
        }
    }
}