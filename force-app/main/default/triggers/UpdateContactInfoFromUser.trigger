trigger UpdateContactInfoFromUser on User bulk(after insert, after update) {
    Set<Id> contactIds = new Set<Id>();
    for (User u : Trigger.new) {
      if (u.ContactId != null){
        contactIds.add(u.ContactId);
      }   
    }
    if (contactIds.size() > 0) {
      List<Contact> contacts = [select id, Phone,Email,MobilePhone from Contact where Id in :contactIds];
      List<User> userListToFetchExtraInfo = [select Id, Email, Fax, Department, MobilePhone, Phone, ContactId, Name, ProfileId, UserType, UserRoleId, IsPortalEnabled, PortalRole from User where contactId IN : contactIds and IsPortalEnabled = true];      
      
      for(Contact cnt :contacts){  
        for(User temp : userListToFetchExtraInfo){                   
            cnt.Phone = temp.Phone;
            cnt.Email  = temp.Email;                
            cnt.MobilePhone = temp.MobilePhone;
        }           
      }    
      update contacts;
    }
}