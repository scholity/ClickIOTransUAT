/************************************************************************************************************************************
** Author: Salesforce Services
** Description: Tests for UserTriggerHandler 
************************************************************************************************************************************/

@isTest
public class UserTriggerHandlerTest {
    @testSetup static void setup() {
        List<PHSS_Agent_Ordering_Permission_Setting__c>  cSettings = new List<PHSS_Agent_Ordering_Permission_Setting__c>();
        cSettings.add(new PHSS_Agent_Ordering_Permission_Setting__c(Name='Tier III Agent', Role_Name__c='Tier III Agent'));
        cSettings.add(new PHSS_Agent_Ordering_Permission_Setting__c(Name='TSC Management', Role_Name__c='TSC Management'));
        insert cSettings;
    }
    
    // Test User After Insert and After Update
    // Scenario 1: User is created with User Role listed in custom setting
    // Scenario 2: User is updated with User Role listed in custom setting, user already has permission set assigned
    // Scenario 3: User is updated with User Role set to null
    static testMethod void create_roleInCS_update_alreadyHasCS() {
        PermissionSet ps = [SELECT Id, Name FROM PermissionSet WHERE Name='PHSS_Agent_Ordering_Permissions'];
        // Scenario 1
        User user1 = new User(
            UserRoleId = [Select Id From UserRole Where PortalType = 'None' AND Name='Tier III Agent' LIMIT 1].Id,
            ProfileId = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1].Id,
            LastName = 'last_ops',
            Email = 'test_ops@testingARC.com',
            Username = 'test_ops@testingARC.com' + System.currentTimeMillis(),
            CompanyName = 'ARCops',
            Title = 'title_ops',
            Alias = 'test_ops',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8', 
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert user1;
        List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>([SELECT Id, PermissionSetId, AssigneeId FROM PermissionSetAssignment WHERE AssigneeId=:user1.Id AND PermissionSetId=:ps.Id]);
        System.assert(!psaList.isEmpty());
        System.assertEquals(user1.Id, psaList[0].AssigneeId);
        System.assertEquals(ps.Id, psaList[0].PermissionSetId);
        
        // Scenario 2        
        List<UserRole> usList = new List<UserRole>([SELECT Id FROM UserRole WHERE Name='TSC Management']);
        user1.UserRoleId = usList[0].Id;
        update user1;
        List<PermissionSetAssignment> psaList2 = new List<PermissionSetAssignment>([SELECT Id, PermissionSetId, AssigneeId FROM PermissionSetAssignment WHERE AssigneeId=:user1.Id AND PermissionSetId=:ps.Id]);
        System.assert(!psaList2.isEmpty());
        System.assertEquals(user1.Id, psaList2[0].AssigneeId);
        System.assertEquals(ps.Id, psaList2[0].PermissionSetId);
        
        // Scenario 3        
        user1.UserRoleId = null;
        system.debug('User: ' + user1);
        update user1;
        List<PermissionSetAssignment> psaList3 = new List<PermissionSetAssignment>([SELECT Id, PermissionSetId, AssigneeId FROM PermissionSetAssignment WHERE AssigneeId=:user1.Id AND PermissionSetId=:ps.Id]);
        system.debug('psaList3: ' + psaList3);
        System.assert(psaList3.isEmpty());
    } 
    
    // Test User After Insert and After Update
    // Scenario 1: User is created with User Role NOT listed in custom setting
    // Scenario 2: User is updated with User Role listed in custom setting
    // Scenario 3: User is updated with User Role NOT listed in custom setting
    static testMethod void create_roleNotInCS_update_roleInCS() {        
        PermissionSet ps = [SELECT Id, Name FROM PermissionSet WHERE Name='PHSS_Agent_Ordering_Permissions'];        
        // Scenario 1
        User user2 = new User(
            UserRoleId = [Select Id From UserRole Where PortalType = 'None' AND Name='CST' LIMIT 1].Id,
            ProfileId = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1].Id,
            LastName = 'last_ops1',
            Email = 'test_ops1@testingARC.com',
            Username = 'test_ops1@testingARC.com' + System.currentTimeMillis(),
            CompanyName = 'ARCops1',
            Title = 'title_ops1',
            Alias = 'testops1',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8', 
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert user2; 
        List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>([SELECT Id, PermissionSetId, AssigneeId FROM PermissionSetAssignment WHERE AssigneeId=:user2.Id AND PermissionSetId=:ps.Id]);
        System.assert(psaList.isEmpty());

        // Scenario 2        
        List<UserRole> usList = new List<UserRole>([SELECT Id FROM UserRole WHERE Name='TSC Management']);
        user2.UserRoleId = usList[0].Id;
        update user2;
        List<PermissionSetAssignment> psaList2 = new List<PermissionSetAssignment>([SELECT Id, PermissionSetId, AssigneeId FROM PermissionSetAssignment WHERE AssigneeId=:user2.Id AND PermissionSetId=:ps.Id]);
        System.assert(!psaList2.isEmpty());
        System.assertEquals(user2.Id, psaList2[0].AssigneeId);
        System.assertEquals(ps.Id, psaList2[0].PermissionSetId); 
        
        // Scenario 3
        List<User> uList = new List<User>([SELECT Id, UserRoleId FROM User WHERE Id=:user2.Id]);
        User user3 = uList[0];
        List<UserRole> usList3 = new List<UserRole>([SELECT Id FROM UserRole WHERE Name='CST']);
        user3.UserRoleId = usList3[0].Id;
        update user3;
        List<PermissionSetAssignment> psaList3 = new List<PermissionSetAssignment>([SELECT Id, PermissionSetId, AssigneeId FROM PermissionSetAssignment WHERE AssigneeId=:user3.Id AND PermissionSetId=:ps.Id]);
        System.assert(psaList3.isEmpty());
    }
    
    // Test User After Insert
    // Scenario 1: User is created with User Role set to null
    static testMethod void create_roleIsNull() {
        PermissionSet ps = [SELECT Id, Name FROM PermissionSet WHERE Name='PHSS_Agent_Ordering_Permissions'];       
        // Scenario 1
        User user4 = new User(
            UserRoleId = null,
            ProfileId = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1].Id,
            LastName = 'last_ops2',
            Email = 'test_ops2@testingARC.com',
            Username = 'test_ops2@testingARC.com' + System.currentTimeMillis(),
            CompanyName = 'ARCops2',
            Title = 'title_ops2',
            Alias = 'testops2',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8', 
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert user4;
        List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>([SELECT Id, PermissionSetId, AssigneeId FROM PermissionSetAssignment WHERE AssigneeId=:user4.Id AND PermissionSetId=:ps.Id]);
        System.assert(psaList.isEmpty());
    }
    
}