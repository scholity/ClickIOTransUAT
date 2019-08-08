public without sharing class myCertifications
{
    Public Static  List<myCertWrapper> myCertList;
    public static User fetchUser()
        {      
            User u = [SELECT id, ContactId, Name, Profile.Name, Profile.UserLicense.Name FROM User WHERE id=: UserInfo.getUserId()];
            System.debug('User--->'+u);
            return u;
            
        }
    @AuraEnabled
    public static List<myCertWrapper> fetchAchv(Integer pagelimit,boolean more,boolean few) {
            Boolean Expiredate = false;
            Integer pge;
            user u = fetchUser();
            System.debug('valuee of more>>>'+more);
            System.debug('valuee of few>>>'+few);
            List<redwing__Achievement_Assignment__c> InstructorAchvlistSize = [Select Id, Name, Account__r.Name,redwing__Contact__r.Email,redwing__Contact__r.Phone, redwing__Achievement__r.Name,QR_Code_Identifier__c, redwing__User__c ,redwing__User__r.Name, redwing__User__r.Phone, redwing__User__r.Email, redwing__Expiration_Date__c from redwing__Achievement_Assignment__c where redwing__Contact__c =:u.ContactId and redwing__Status__c = 'Acquired' and Achievement_Type__c = 'Certifications'  ORDER BY redwing__Contact__r.Name,redwing__Achievement__r.Name ASC ];
            
            if(InstructorAchvlistSize.size()>10 && (more==true))
            {
                System.debug('valuee of more>>>'+more);
                pge=pagelimit+10;
            }
            else if(InstructorAchvlistSize.size()>10 && (few==true))
            {
            System.debug('valuee of few>>>'+more);
                pge=pagelimit-10;
            }
            else
            {
                pge=pagelimit;
            }
            Integer pglimit=integer.valueof(pge);
            System.debug('Value of Pge'+pge);
            
            List<redwing__Achievement_Assignment__c> InstructorAchv = [Select Id, Name, Account__r.Name,redwing__Contact__r.Email,redwing__Contact__r.Phone, redwing__Achievement__r.Name,QR_Code_Identifier__c, redwing__User__c ,redwing__User__r.Name, redwing__User__r.Phone, redwing__User__r.Email, redwing__Expiration_Date__c from redwing__Achievement_Assignment__c where redwing__Contact__c =:u.ContactId and redwing__Status__c = 'Acquired' and Achievement_Type__c = 'Certifications'  ORDER BY redwing__Contact__r.Name,redwing__Achievement__r.Name ASC limit :pglimit];
            myCertList = new List<myCertWrapper>();
            for(redwing__Achievement_Assignment__c key: InstructorAchv)
            {
                
                Datetime dtExpDate = (Datetime)Key.redwing__Expiration_Date__c;
                String Expdate = dtExpDate.format('MM/dd/yyyy');
                
                if(Key.redwing__Expiration_Date__c < date.today())
                {
                    Expiredate = true;
                }
                else
                {
                  Expiredate = false;
                }
                
               myCertList.add(new myCertWrapper(pglimit,Key.redwing__Achievement__r.Name,Key.QR_Code_Identifier__c,Expdate,Expiredate));
        }
        return myCertList;
        }
       
    
        public class  myCertWrapper{
        @AuraEnabled public Integer pageLimit;
        @AuraEnabled public String Valuess;
        @AuraEnabled public String QRCodeIdentifier;
        @AuraEnabled public String expDate;
        @AuraEnabled public boolean Expireflag;
        public myCertWrapper(Integer Pagelimit, String Valuess,String QRCodeIdentifier,String expDate,Boolean Expireflag) {
            this.Pagelimit = Pagelimit;
            this.Valuess= Valuess;
            this.QRCodeIdentifier=QRCodeIdentifier;
            this.expDate=expDate;
            this.Expireflag = Expireflag;
            
        }
    }
}