@isTest 
public class CustomerUserDetailControllerTest
{
    static testMethod void testCustomerUserDetailController()
    {
        User u = [SELECT Id, ContactId FROM User WHERE ContactId != null AND IsActive = true LIMIT 1];
        
        Test.StartTest();
        
            
                ApexPages.currentPage().getParameters().put('id', String.valueOf(u.ContactId));
                CustomerUserDetailController ctrl = new CustomerUserDetailController();
                ctrl.redirect();
            

        Test.StopTest();
    }
    
    static testMethod void testCustomerUserDetailControllerForNull()
    {
        CustomerUserDetailController ctrl = new CustomerUserDetailController();
        ctrl.redirect();
    }
}