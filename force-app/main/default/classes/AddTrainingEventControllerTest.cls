@isTest (SeeAllData = true)
public class AddTrainingEventControllerTest
{
    static testMethod void myTest()
    {
        Id oppId = [SELECT Id FROM OpportunityLineItem LIMIT 1].Id;
        
        Test.StartTest();
        
        ApexPages.currentPage().getParameters().put('id', String.valueOf(oppId));
        AddTrainingEventController atec = new AddTrainingEventController();
        atec.save();
        atec.cancel();
        
        Test.StopTest();

    }       
}