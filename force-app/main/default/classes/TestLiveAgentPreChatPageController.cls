/******************************************************************************************************
Class    :  TestLiveAgentPreChatPageController
Developer:  Mickey Murphy / Blue Wolf Group LLC
Created  :  April 25, 2013
Modified :
Objective:  This class provides methods to test LiveAgentPreChatPageController.cls.  

******************************************************************************************************/

@isTest
private class TestLiveAgentPreChatPageController
{
    static testMethod void testController ()
    {
        //  variables declared in alphabetical order
        PageReference pageReference = Page.LiveAgentPreChatPage;
        String endpoint = 'https%3A%2F%2F1.la8cs.salesforceliveagent.com';

        Test.setCurrentPage (pageReference);
        ApexPages.currentPage ().getParameters ().put ('endpoint', endpoint);   
        LiveAgentPreChatPageController controller = new LiveAgentPreChatPageController ();

        controller.validateContactInput ();

        controller.email             = 'gabrielle.bluewolf.com';
        controller.firstName         = 'Gabrielle';
        controller.lastName          = 'Ewing';
        controller.mailingPostalCode = '75210';

        controller.validateContactInput ();

        controller.email             = 'gabrielle@bluewolf.com';
        controller.firstName         = 'Gabrielle';
        controller.lastName          = 'Ewing';
        controller.mailingPostalCode = '75210';

        System.assertEquals (null, controller.validateContactInput ());

    }   //  testController ()

}