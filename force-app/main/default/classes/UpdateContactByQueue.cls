public class UpdateContactByQueue implements Queueable {    
    public List<Id> contactIds;
    
    public UpdateContactByQueue(List<Id> contIds) {
        this.contactIds = contIds;
    }

    public void execute(QueueableContext context) {
        List<Contact> contacts = [select Id, Email, Fax, Department, MobilePhone, Phone from contact where Id IN : contactIds];
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