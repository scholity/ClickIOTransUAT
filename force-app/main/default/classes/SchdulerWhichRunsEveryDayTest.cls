@istest(seeAllData = true)
public class SchdulerWhichRunsEveryDayTest 
{
    public static testMethod void testschedule() 
    { 
        Test.StartTest();
        SchdulerWhichRunsEveryDay testsche = new SchdulerWhichRunsEveryDay();
        String sch = '0 0 23 * * ?';
        system.schedule('Case Management', sch, testsche );
        Test.stopTest(); 
    }
}