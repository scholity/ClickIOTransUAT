/******************************************************************************************************
Class    :  TestWebToCasePageController
Developer:  Mickey Murphy / Blue Wolf Group LLC
Created  :  April 25, 2013
Modified :
Objective:  This class provides methods to test WebToCasePageController.cls.  

******************************************************************************************************/

@isTest
private class TestWebToCasePageController
{
    static testMethod void testController ()
    {
        //  variables declared in alphabetical order
        PageReference pageReference = Page.WebToCasePage;

        Test.setCurrentPageReference (pageReference);

        WebToCasePageController controller = new WebToCasePageController ();

        controller.validateCaseInput ();

        controller.email             = 'gabrielle.bluewolf.com';
        controller.firstName         = 'Gabrielle';
        controller.lastName          = 'Ewing';
        controller.mailingPostalCode = '75210';

        controller.validateCaseInput ();

        controller.caseDescription   = 'This is only a test!';
        controller.caseSubject       = 'BWG Web-to-Case Test';
        controller.email             = 'gabrielle@bluewolf.com';
        controller.firstName         = 'Gabrielle';
        controller.lastName          = 'Ewing';
        controller.mailingPostalCode = '75210';

        System.assertEquals (null, controller.validateCaseInput ());

    }   //  testController ()

}