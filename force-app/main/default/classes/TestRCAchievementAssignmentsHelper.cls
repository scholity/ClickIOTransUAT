@isTest
public class TestRCAchievementAssignmentsHelper {
    @isTest
    public static void AcquisitionDateWithILTClassOnline() {
        redwing__Learning__c learning = new redwing__Learning__c(Name = 'Test Learning', redwing__Description__c = 'test description');
        insert learning;
        redwing__ILT_Class__c iltClass = new redwing__ILT_Class__c(Name = 'Test ILT', redwing__Start_Date__c = Date.today(), redwing__End_Date__c = Date.today().addDays(2), redwing__Learning__c = learning.Id, Classroom_Setting__c = 'Online');
        redwing__Achievement__c achievement = new redwing__Achievement__c(Name = 'Test Achievement', redwing__Type__c = 'Achievement', redwing__Expiration_Term__c = 1, redwing__Expiration_Term_Basis__c = 'Days');
        insert iltClass;
        insert achievement;
        redwing__Achievement_Assignment__c achievementAssignment = new redwing__Achievement_Assignment__c();
        achievementAssignment.redwing__Achievement__c = achievement.Id;
        achievementAssignment.ILT_Class__c = iltClass.Id;
        achievementAssignment.redwing__Status__c = 'Acquired';
        List<redwing__Achievement_Assignment__c> listAchievementAssignments = new List<redwing__Achievement_Assignment__c>();
        listAchievementAssignments.add(achievementAssignment);
        insert listAchievementAssignments;

        Test.startTest();
            RCAchievementAssignmentsHelper.processBeforeInsertAchievementAssignment(listAchievementAssignments);
        Test.stopTest();
            System.assertEquals(listAchievementAssignments[0].redwing__Acquisition_Date__c, iltClass.redwing__End_Date__c);

    }

    @isTest
    public static void AcquisitionDateWithILTClassOffline() {
        redwing__Learning__c learning = new redwing__Learning__c(Name = 'Test Learning', redwing__Description__c = 'test description');
        insert learning;
        redwing__ILT_Class__c iltClass = new redwing__ILT_Class__c(Name = 'Test ILT', redwing__Start_Date__c = Date.today(), redwing__End_Date__c = Date.today().addDays(2), redwing__Learning__c = learning.Id, Classroom_Setting__c = 'Classroom');
        redwing__Achievement__c achievement = new redwing__Achievement__c(Name = 'Test Achievement', redwing__Type__c = 'Achievement', redwing__Expiration_Term__c = 1, redwing__Expiration_Term_Basis__c = 'Weeks');
        insert iltClass;
        insert achievement;
        redwing__Achievement_Assignment__c achievementAssignment = new redwing__Achievement_Assignment__c();
        achievementAssignment.redwing__Achievement__c = achievement.Id;
        achievementAssignment.ILT_Class__c = iltClass.Id;
        achievementAssignment.redwing__Status__c = 'Acquired';
        List<redwing__Achievement_Assignment__c> listAchievementAssignments = new List<redwing__Achievement_Assignment__c>();
        listAchievementAssignments.add(achievementAssignment);
        insert listAchievementAssignments;

        Test.startTest();
            RCAchievementAssignmentsHelper.processBeforeInsertAchievementAssignment(listAchievementAssignments);
        Test.stopTest();
            System.assertEquals(listAchievementAssignments[0].redwing__Acquisition_Date__c, Date.today());

    }

    @isTest
    public static void AcquisitionDateWithLearningPlanOffline() {
        redwing__Training_Plan__c tp = new redwing__Training_Plan__c(Name = 'Test LP', redwing__Status__c = 'Active', redwing__Start_Date__c = Date.today(), redwing__End_Date__c = Date.today().addDays(4), Classroom_Setting__c = 'Classroom');
        insert tp;
        redwing__Achievement__c achievement = new redwing__Achievement__c(Name = 'Test Achievement', redwing__Type__c = 'Achievement', redwing__Expiration_Term__c = 1, redwing__Expiration_Term_Basis__c = 'Months');
        redwing__Training_Plan_Achievement__c tpa = new redwing__Training_Plan_Achievement__c(redwing__Achievement__c = achievement.Id, redwing__Training_Plan__c = tp.Id);
        insert achievement;
        insert tpa;
        redwing__Achievement_Assignment__c achievementAssignment = new redwing__Achievement_Assignment__c();
        achievementAssignment.redwing__Achievement__c = achievement.Id;
        achievementAssignment.redwing__Training_Plan_Achievement__c = tpa.Id;
        achievementAssignment.redwing__Status__c = 'Acquired';
        List<redwing__Achievement_Assignment__c> listAchievementAssignments = new List<redwing__Achievement_Assignment__c>();
        listAchievementAssignments.add(achievementAssignment);
        insert listAchievementAssignments;

        Test.startTest();
            RCAchievementAssignmentsHelper.processBeforeInsertAchievementAssignment(listAchievementAssignments);
        Test.stopTest();
            System.assertEquals(listAchievementAssignments[0].redwing__Acquisition_Date__c, Date.today());

    }

    @isTest
    public static void AcquisitionDateWithLearningPlanOnline() {
        redwing__Training_Plan__c tp = new redwing__Training_Plan__c(Name = 'Test LP', redwing__Status__c = 'Active', redwing__Start_Date__c = Date.today(), redwing__End_Date__c = Date.today().addDays(4), Classroom_Setting__c = 'Online');
        insert tp;
        redwing__Learning__c learning = new redwing__Learning__c(Name = 'Test Learning', redwing__Description__c = 'test description');
        insert learning;
        redwing__ILT_Class__c iltClass = new redwing__ILT_Class__c(Name = 'Test ILT', redwing__Start_Date__c = Date.today(), redwing__End_Date__c = Date.today().addDays(2), redwing__Learning__c = learning.Id, Classroom_Setting__c = 'Classroom');
        insert iltClass;
        redwing__Achievement__c achievement = new redwing__Achievement__c(Name = 'Test Achievement', redwing__Type__c = 'Achievement', redwing__Expiration_Term__c = 1, redwing__Expiration_Term_Basis__c = 'Months');
        redwing__Training_Plan_Achievement__c tpa = new redwing__Training_Plan_Achievement__c(redwing__Achievement__c = achievement.Id, redwing__Training_Plan__c = tp.Id);
        insert achievement;
        insert tpa;
        redwing__Achievement_Assignment__c achievementAssignment = new redwing__Achievement_Assignment__c();
        achievementAssignment.redwing__Achievement__c = achievement.Id;
        achievementAssignment.redwing__Training_Plan_Achievement__c = tpa.Id;
        achievementAssignment.ILT_Class__c = iltClass.Id;
        achievementAssignment.redwing__Status__c = 'Acquired';
        List<redwing__Achievement_Assignment__c> listAchievementAssignments = new List<redwing__Achievement_Assignment__c>();
        listAchievementAssignments.add(achievementAssignment);
        insert listAchievementAssignments;

        Test.startTest();
            RCAchievementAssignmentsHelper.processBeforeInsertAchievementAssignment(listAchievementAssignments);
        Test.stopTest();
            System.assertEquals(listAchievementAssignments[0].redwing__Acquisition_Date__c, tp.redwing__End_Date__c);

    }

    @isTest
    public static void AcquisitionDateWithLearningPlanAndILTClassOnline() {
        redwing__Learning__c learning = new redwing__Learning__c(Name = 'Test Learning', redwing__Description__c = 'test description');
        insert learning;
        redwing__ILT_Class__c iltClass = new redwing__ILT_Class__c(Name = 'Test ILT', redwing__Start_Date__c = Date.today(), redwing__End_Date__c = Date.today().addDays(2), redwing__Learning__c = learning.Id, Classroom_Setting__c = 'Online');
        insert iltClass;
        redwing__Training_Plan__c tp = new redwing__Training_Plan__c(Name = 'Test LP', redwing__Status__c = 'Active', redwing__Start_Date__c = Date.today(), redwing__End_Date__c = Date.today().addDays(4), Classroom_Setting__c = 'Online');
        insert tp;
        redwing__Achievement__c achievement = new redwing__Achievement__c(Name = 'Test Achievement', redwing__Type__c = 'Achievement', redwing__Expiration_Term__c = 1, redwing__Expiration_Term_Basis__c = 'Years');
        redwing__Training_Plan_Achievement__c tpa = new redwing__Training_Plan_Achievement__c(redwing__Achievement__c = achievement.Id, redwing__Training_Plan__c = tp.Id);
        insert achievement;
        insert tpa;
        redwing__Achievement_Assignment__c achievementAssignment = new redwing__Achievement_Assignment__c();
        achievementAssignment.redwing__Achievement__c = achievement.Id;
        achievementAssignment.redwing__Training_Plan_Achievement__c = tpa.Id;
        achievementAssignment.redwing__Status__c = 'Acquired';
        achievementAssignment.ILT_Class__c = iltClass.Id;
        List<redwing__Achievement_Assignment__c> listAchievementAssignments = new List<redwing__Achievement_Assignment__c>();
        listAchievementAssignments.add(achievementAssignment);
        insert listAchievementAssignments;

        Test.startTest();
            RCAchievementAssignmentsHelper.processBeforeInsertAchievementAssignment(listAchievementAssignments);
        Test.stopTest();
            System.assertEquals(listAchievementAssignments[0].redwing__Acquisition_Date__c, iltClass.redwing__End_Date__c);

    }

    @isTest
    public static void AcquisitionDateWithLearningPlanAndILTClassOffline() {
        redwing__Learning__c learning = new redwing__Learning__c(Name = 'Test Learning', redwing__Description__c = 'test description');
        insert learning;
        redwing__ILT_Class__c iltClass = new redwing__ILT_Class__c(Name = 'Test ILT', redwing__Start_Date__c = Date.today(), redwing__End_Date__c = Date.today().addDays(2), redwing__Learning__c = learning.Id, Classroom_Setting__c = 'Classroom');
        insert iltClass;
        redwing__Training_Plan__c tp = new redwing__Training_Plan__c(Name = 'Test LP', redwing__Status__c = 'Active', redwing__Start_Date__c = Date.today(), redwing__End_Date__c = Date.today().addDays(4), Classroom_Setting__c = 'Classroom');
        insert tp;
        redwing__Achievement__c achievement = new redwing__Achievement__c(Name = 'Test Achievement', redwing__Type__c = 'Achievement', redwing__Expiration_Term__c = 1, redwing__Expiration_Term_Basis__c = 'Years');
        redwing__Training_Plan_Achievement__c tpa = new redwing__Training_Plan_Achievement__c(redwing__Achievement__c = achievement.Id, redwing__Training_Plan__c = tp.Id);
        insert achievement;
        insert tpa;
        redwing__Achievement_Assignment__c achievementAssignment = new redwing__Achievement_Assignment__c();
        achievementAssignment.redwing__Achievement__c = achievement.Id;
        achievementAssignment.redwing__Training_Plan_Achievement__c = tpa.Id;
        achievementAssignment.redwing__Status__c = 'Acquired';
        achievementAssignment.ILT_Class__c = iltClass.Id;
        List<redwing__Achievement_Assignment__c> listAchievementAssignments = new List<redwing__Achievement_Assignment__c>();
        listAchievementAssignments.add(achievementAssignment);
        insert listAchievementAssignments;

        Test.startTest();
            RCAchievementAssignmentsHelper.processBeforeInsertAchievementAssignment(listAchievementAssignments);
        Test.stopTest();
            System.assertEquals(listAchievementAssignments[0].redwing__Acquisition_Date__c, Date.today());

    }

    @IsTest
    public static void AcquisitionDateWithoutLearningPlanAndILTClass() {
        redwing__Achievement__c achievement = new redwing__Achievement__c(Name = 'Test Achievement', redwing__Type__c = 'Achievement', redwing__Expiration_Term__c = 1, redwing__Expiration_Term_Basis__c = 'Years');
        insert achievement;
        redwing__Achievement_Assignment__c achievementAssignment = new redwing__Achievement_Assignment__c();
        achievementAssignment.redwing__Achievement__c = achievement.Id;
        achievementAssignment.redwing__Status__c = 'Acquired';
        List<redwing__Achievement_Assignment__c> listAchievementAssignments = new List<redwing__Achievement_Assignment__c>();
        listAchievementAssignments.add(achievementAssignment);
        insert listAchievementAssignments;

        Test.startTest();
            RCAchievementAssignmentsHelper.processBeforeInsertAchievementAssignment(listAchievementAssignments);
        Test.stopTest();
            System.assertEquals(listAchievementAssignments[0].redwing__Acquisition_Date__c, Date.today());
    }
}