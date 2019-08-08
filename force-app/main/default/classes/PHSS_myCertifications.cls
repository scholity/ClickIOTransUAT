public without sharing class PHSS_myCertifications
{
    Public Static  List<myCertWrapper> myCertList;
    public static User fetchUser()
        {      
            User u = [SELECT id, ContactId, Name, Profile.Name, Profile.UserLicense.Name FROM User WHERE id=: UserInfo.getUserId()];
            System.debug('User--->'+u);
            return u;
            
        }
    @AuraEnabled
    public static List<myCertWrapper> fetchAchv() {
         Boolean expiredAchievement = false;
            user u = fetchUser();            
            List<redwing__Achievement_Assignment__c> achievementAssignments = [Select Id, Name, Account__r.Name, redwing__Contact__r.Email, redwing__Contact__r.Phone,
            	redwing__Achievement__r.Name, QR_Code_Web_Address__c, redwing__User__c , redwing__User__r.Name, redwing__User__r.Phone, redwing__User__r.Email, 
            	redwing__Expiration_Date__c 
            	From redwing__Achievement_Assignment__c 
            	Where redwing__Contact__c =:u.ContactId and redwing__Status__c = 'Acquired' and Achievement_Type__c = 'Certifications'  
            	ORDER BY redwing__Contact__r.Name,redwing__Achievement__r.Name ASC];
            	
            myCertList = new List<myCertWrapper>();
            for(redwing__Achievement_Assignment__c theAssignment: achievementAssignments)
            {
                
                Datetime dtExpDate = (Datetime)theAssignment.redwing__Expiration_Date__c;
                String Expdate = dtExpDate.format('MM/dd/yyyy');
                
                if(theAssignment.redwing__Expiration_Date__c < date.today())
                {
                    expiredAchievement = true;
                }
                else
                {
                  	expiredAchievement = false;
                }
                
               myCertList.add(new myCertWrapper(theAssignment.redwing__Achievement__r.Name, theAssignment.QR_Code_Web_Address__c, theAssignment.redwing__Expiration_Date__c, expiredAchievement));
        }
        return myCertList;
        }
       
    
        public class  myCertWrapper{
        @AuraEnabled public String achievementName;
        @AuraEnabled public String QRCodeWebAddress;
        @AuraEnabled public Date expDate;
        @AuraEnabled public boolean expireFlag;
        public myCertWrapper(String achievementName, String QRCodeWebAddress, date expDate, Boolean expireFlag) {
            this.achievementName=achievementName;
            this.QRCodeWebAddress=QRCodeWebAddress;
            this.expDate=expDate;
            this.Expireflag=expireFlag;
            
        }
    }
}