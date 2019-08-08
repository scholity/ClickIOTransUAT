@isTest
public class RCAchievementAssignmentUpdateBatchTest {
 @testSetup static void setup() {
        List<redwing__Achievement_Assignment__c> achievements = new List<redwing__Achievement_Assignment__c>();
        for(Integer i = 0; i < 100; i++) {
            redwing__Achievement_Assignment__c achieve = new redwing__Achievement_Assignment__c();
            achieve.redwing__Status__c = 'Acquired';
            achieve.redwing__Expiration_Date__c = Date.today().addDays(-1);
            achievements.add(achieve);
        }
        insert achievements;
    }

    @isTest static void testExpirationStatus() {
        redwing__Achievement__c achive = new redwing__Achievement__c (
            Name = 'Achiev', 
            redwing__Expiration_Date__c = Date.today().addDays(-2)
        );
        insert achive;
        redwing__Achievement_Assignment__c achievement = [
            SELECT Id, redwing__Status__c, redwing__Achievement__c, redwing__Expiration_Date__c
            FROM redwing__Achievement_Assignment__c 
            WHERE redwing__Status__c = 'Acquired'
            LIMIT 1
        ];
        achievement.redwing__Expiration_Date__c = null;
        achievement.redwing__Achievement__c = achive.Id;
        update achievement;
        
        String statusExpired = 'Expired';
        Test.startTest();
        RCAchievementAssignmentUpdateBatch obj = new RCAchievementAssignmentUpdateBatch();
        DataBase.executeBatch(obj); 
        List<redwing__Achievement_Assignment__c> achievements = [
            SELECT Id, redwing__Status__c 
            FROM redwing__Achievement_Assignment__c 
            WHERE redwing__Status__c = :statusExpired
        ];
        System.assertNotEquals(null, achievements);
        Test.stopTest();
    }
}