@isTest
public class skedCourseCatalogTrigger_Test {
    
    static testmethod void mainTest() {
        Map<string, sObject> mapTestData = skedDataSetup.setupNatSchedulingData();
        Course_Catalog__c courseCatalog1 = (Course_Catalog__c)mapTestData.get('courseCatalog1');
        
        Test.startTest();
        
        try {
            courseCatalog1.Is_Active__c = FALSE;
            update courseCatalog1;
        }
        catch (Exception ex) {
            System.Assert(ex.getMessage().contains('This Course has classes scheduled in the future, please update these classes to a different course before marking this course as inactive.'));
        }
        
        Test.stopTest();
    }

}