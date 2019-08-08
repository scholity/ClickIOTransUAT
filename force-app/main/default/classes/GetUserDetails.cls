global class GetUserDetails {
   global static User userRecord {get{
        if(userRecord == Null){
        Id userId = UserInfo.getUserId();
          userRecord = [Select Id, Email,ContactId from User where Id=:userId];
        }
        return userRecord;
        }set;}
   global static Id findMatchingcontact(String email){
         Id contactIdTemp = '0030R000006Z54Q';
         //Id contactIdTemp = '';
         List<contact> contactList = [SELECT Id FROM Contact where Email=:email ];  
                if (contactList.size() != 0) {
                 Contact cont = contactList.get(0);
                 contactIdTemp = cont.Id;
               } 
               
        return contactIdTemp;       
    }
    global static Contact contact {get{
        if(contact == Null){
            Id contactIdTemp = userRecord.ContactId; 
            if(contactIdTemp == null){
                contactIdTemp = findMatchingcontact(userRecord.Email);
                //contactIdTemp = '0034100000kLV52';
            } 
            
            System.debug('Contact id is:'+contactIdTemp);
            
            List<contact> contactList = [SELECT Id, Email, FirstName,LastName,Phone, Name FROM Contact where Id=:contactIdTemp ]; 
            
            contact = contactList.get(0); 
            
            system.debug(contactList);
        }
        return contact;
    }set;}
    
    // Get Contact Info
    @RemoteAction
    global static customerClass getContactDetails(){
        customerClass CC = new customerClass();
        CC.FirstName = contact.FirstName;
        CC.LastName = contact.LastName;
        CC.Email = contact.Email;
        CC.Phone = contact.Phone;
        CC.Id = contact.Id;
        return CC;
    }
    
    global class customerClass{
        String FirstName;
        String LastName;
        String Email;
        String Phone;
        String Id; 
    }
}