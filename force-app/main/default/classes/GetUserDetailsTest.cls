@isTest(SeeAllData=true)
private class GetUserDetailsTest 
{
    
   @isTest static void findMatchingcontact_testNotEmpty()
    {      
        Contact u1  = [select id, email from contact where email like '%redcro%' limit 1 ];
        System.assertNotEquals('0030R000006Z54Q', GetUserDetails.findMatchingcontact(u1.Email));        
    }
      
    @isTest static void userRecordTest()
    {
        System.assertNotEquals(GetUserDetails.userRecord,null);
    }
    
    @isTest static void contactTest()
    {
        System.assertNotEquals(GetUserDetails.contact, null);
    }
  
    @isTest static void customerClassTest()
    {
        System.assertNotEquals(GetUserDetails.contact, null);
        System.assertNotEquals(GetUserDetails.getContactDetails(),null);
    }
    
 }