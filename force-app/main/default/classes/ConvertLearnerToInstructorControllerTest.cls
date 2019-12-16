@isTest(SeeAllData = true)
public class ConvertLearnerToInstructorControllerTest
{
    static testmethod void testConvertLearnerToInstructorController()
    {
        User u = [SELECT     Id,
                      		 ContactID,
							 FirstName,
                      		 LastName,
                      		 ProfileId
                        FROM User
                       WHERE ContactId != null
                       LIMIT 1];
        AccountContactRelation acr = [SELECT Id, ContactId, AccountId FROM AccountContactRelation WHERE ContactId = :u.ContactId LIMIT 1];

        system.debug(acr);

        Test.startTest();
            ApexPages.currentPage().getParameters().put('id', String.valueOf(acr.Id));
            ConvertLearnerToInstructorController ct = new ConvertLearnerToInstructorController();
            //ct.redirect();

            Test.setMock(HttpCalloutMock.class, new ProfileUpdateMock());
            ct.redirect();
            /*
            HttpResponse response = ConvertLearnerToInstructorController.sendRequest().makePostCallout();
            String contentType = response.getHeader('Content-Type');
            System.assert(contentType == 'application/json');
            String actualValue = response.getBody();
            System.debug(response.getBody());*/
        Test.stopTest();
    }
}