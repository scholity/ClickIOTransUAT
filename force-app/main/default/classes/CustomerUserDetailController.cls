public without sharing class CustomerUserDetailController
{
    private final User 	u;
    
    public CustomerUserDetailController()
    {
        u = [SELECT Id, ContactId
               FROM	User
              WHERE	ContactId =:ApexPages.currentPage().getParameters().get('id')
              LIMIT	1];
    }
    
    public PageReference redirect()
    {   
        system.debug('u***'+u);
        if (u != null && u.ContactId != null)
        {
            PageReference redirectSuccess = new PageReference('/lightning/r/User/'+u.Id+'/view');
            return redirectSuccess;
        }
        else
        {
            return null;
        }
    }
}