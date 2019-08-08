public without sharing class CommunitypageInstructors
{
    Public Static  List<InstructorWrapper> InstructorList;
    Public Static  Set<InstructorWrapper> Dupcheck;
    Public Static  List<InstructorWrapper> returnedlist;
    Public Static List<UserAccountWrapper> UserAccountlist;
    @AuraEnabled
    public static UserAccountWrapper getPicklistValues(String objName, String objInsName, String accId) {
        UserAccountlist = new list<UserAccountWrapper>();
        User usr = [SELECT id, ContactId, Name, Profile.Name, Profile.UserLicense.Name FROM User WHERE id=: UserInfo.getUserId()];
        String sQuery = '';
        String sUserQuery = '';
        List <sObject> returnList = new List <sObject> ();
        
        
        
        sQuery =  'Select id, Name From Account Where id in (SELECT AccountId FROM AccountContactRelation WHERE ContactId = \'' +usr.ContactId+'\') Order By Name ASC';
        List<Account> useracc = [Select id, Name From Account Where id in (SELECT AccountId FROM AccountContactRelation WHERE ContactId=:usr.ContactId)];
        
        List<String> ListRolesName= new List<String> {'Administrator','Instructor'};
            sUserQuery =  'Select id, Name From User Where ContactId in (SELECT ContactId FROM AccountContactRelation WHERE Roles IN: ListRolesName and AccountId IN:useracc) Order By Name ASC';    
        
        
        List <sObject> lstOfAccRecords = Database.query(sQuery);
        List <sObject> lstOfUsrRecords = Database.query(sUserQuery);
        UserAccountWrapper us = new UserAccountWrapper();
        us.Accountdetails=lstOfAccRecords;
        us.Userdetails=lstOfUsrRecords;
        System.debug('recprds..'+UserAccountlist);
        return Us;
    }
    
    // Get logged in user details:
    public static User fetchUser()
    {      
        User u = [SELECT id, ContactId, Name, Profile.Name, Profile.UserLicense.Name FROM User WHERE id=: UserInfo.getUserId()];
        System.debug('User--->'+u);
        return u;
        
    }
    @AuraEnabled
    public static List<InstructorWrapper> fetchAchv(String accId, String instId) {
        System.debug('instId idd'+instId);
        System.debug('Accountidd >>>>'+accId);
        // Declaration
        String sQuery = '';
        String sQueryAccount = '';
        Boolean Expiredate = false;
        String Dateformat;
        String Todaydate;
        String OrganizationName;
        String InstructorName;
        Boolean existUser = true;
        Boolean existAccount = true;
        System.debug('Accountid Retrieved'+accId);
        List < sObject > returnList = new List < sObject > ();
        List <String> Usernamelist = new list<String>();
        List <String> Organizationlist = new list<String>();
        //List <String> Accountlist = new list<String>();
        map<Id, string> MapUsrAccDupCheck=new map<Id, string>();
        map<Id, String> MapUsrCon=new map<Id, String>();
        map<String, string> MapUsrAcc=new map<String, string>();
        Set<String> userAccountList = new Set<String>();
        user u = fetchUser();
        
        
        // Retrieve a list of Accounts that belongs to logged in user
        sQueryAccount =  'select id, Name from Account where id in (SELECT AccountId FROM AccountContactRelation WHERE ContactId = \'' +u.ContactId+'\') order by createdDate DESC limit 200';
        List <Account> lstOfAccountRecords = Database.query(sQueryAccount);
        system.debug('lstOfAccountRecords ++++++++++++'+lstOfAccountRecords );
        Set<ID> SetAccIDs= new set<ID>();
        for(Account Acc:lstOfAccountRecords )
        {
            SetAccIDs.add(Acc.Id);
            System.debug('AccountIdssss>>>>>>>'+SetAccIDs);
        }
        List <user> lstOfRecords=new List <user>(); 
        // Query to fetch the User List when its a specific Account 
        if(accId != 'Not' && instId == 'Not' )
        {
            sQuery =  'select id, Name, ContactId from User where ContactId in (SELECT ContactId FROM AccountContactRelation WHERE AccountId = \'' +accId +'\' ) order by createdDate DESC limit 100';
            
        }
        else if(instId != 'Not' && accId =='Not')
        {
            sQuery =  'select id, Name,ContactId from User where ContactId in (SELECT ContactId FROM AccountContactRelation WHERE AccountId IN :SetAccIDs) and id = \'' +instId+'\' order by createdDate DESC limit 100';
            System.debug('Contactlist >>>>>>>>>>>'+Database.query(sQuery));
        }
        else
        {
            sQuery =  'select id, Name,ContactId from User where ContactId in (SELECT ContactId FROM AccountContactRelation WHERE AccountId = \'' +accId +'\') and id = \'' +instId+'\' order by createdDate DESC limit 100';
        }
        lstOfRecords = Database.query(sQuery);
        
        for(user Obj:lstOfRecords){
            MapUsrCon.put(Obj.ContactId,Obj.Name);
        }
        system.debug('MapUsrCon+++++++++++++'+MapUsrCon);
        User aUser;
        if(instId!='Not'){
            aUser = [SELECT id, ContactId, Name, Profile.Name, Profile.UserLicense.Name FROM User WHERE id=: instId];
        }
      
        if(accId != 'Not' && instId == 'Not')
        {
            
            for(AccountContactRelation AccCon:[SELECT ContactId,Account.Name FROM AccountContactRelation WHERE AccountId =:accId ORDER BY Account.Name]){
                String UsrId=MapUsrCon.get(AccCon.ContactId);
                MapUsrAcc.put(UsrId+'|'+AccCon.Account.Name,AccCon.Account.Name);
                userAccountList.add(AccCon.Account.Name);
            }
        } 
        else if(instId != 'Not' && accId =='Not')
        {
            
            for(AccountContactRelation AccCon:[SELECT ContactId,Account.Name FROM AccountContactRelation WHERE ContactId =:aUser.ContactId ORDER BY Account.Name]){
                String UsrId=MapUsrCon.get(AccCon.ContactId);
                MapUsrAcc.put(UsrId+'|'+AccCon.Account.Name,AccCon.Account.Name);
                userAccountList.add(AccCon.Account.Name);
            }
        }
        else
        {
            for(AccountContactRelation AccCon:[SELECT ContactId,Account.Name FROM AccountContactRelation WHERE ContactId =:aUser.ContactId and AccountId =:accId ORDER BY Account.Name]){
                String UsrId=MapUsrCon.get(AccCon.ContactId);
                MapUsrAcc.put(UsrId+'|'+AccCon.Account.Name,AccCon.Account.Name);
                userAccountList.add(AccCon.Account.Name);
            } 
        }
        system.debug('MapUsrAcc+++++++++++++'+MapUsrAcc);
        System.debug('List of account recordss>>>>>>>>'+lstOfRecords);
        // Query to fetch the Certified Instructors    
        List<redwing__Achievement_Assignment__c> InstructorAchv = [Select Id, Name, Account__r.Name,redwing__Contact__r.Email,redwing__Contact__r.Phone, redwing__Achievement__r.Name, redwing__User__c ,redwing__User__r.Name, redwing__User__r.Phone, redwing__User__r.Email, redwing__Expiration_Date__c from redwing__Achievement_Assignment__c where redwing__User__c in:lstOfRecords and redwing__Status__c = 'Acquired' and Achievement_Type__c = 'Certifications'  ORDER BY redwing__User__r.Name,redwing__Achievement__r.Name ASC ];
        System.debug('Achievement Assignment listt iddd>>>'+InstructorAchv);
        
        InstructorList = new List<InstructorWrapper>();
        Dupcheck = new Set<InstructorWrapper>();
        returnedlist = new List<InstructorWrapper>();
        // Add data to wrapper list and display the details in the table
        for(String a:userAccountList){
            
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
                
                
                if(Organizationlist.contains(key.redwing__User__r.Name+'|'+a))
                {
                    System.debug('Old');
                    existAccount =false;
                    existUser =false;
                    OrganizationName=MapUsrAcc.get(key.redwing__User__r.Name+'|'+a);
                    InstructorName=key.redwing__User__r.Name;
                    System.debug('Existing Account'+OrganizationName);
                }
                else
                {
                    System.debug('New');
                    if(MapUsrAcc.containsKey(key.redwing__User__r.Name+'|'+a)){
                        existAccount =true;
                        OrganizationName=MapUsrAcc.get(key.redwing__User__r.Name+'|'+a);
                        Organizationlist.add(key.redwing__User__r.Name+'|'+a);
                        InstructorName=key.redwing__User__r.Name;
                        System.debug('New Account'+OrganizationName);
                    }
                }
                
                // To confirm if the Organization is already available in the list
                
                
                InstructorList.add(new InstructorWrapper(InstructorName,Key.redwing__Achievement__r.Name,Expdate,Key.redwing__Contact__r.Email,Key.redwing__Contact__r.Phone,Expiredate,existUser,existAccount,OrganizationName));
            }
        }
        System.debug('Map assignmentsss>>>>>>>>>>>>>>>>'+InstructorList);
        Dupcheck.addAll(InstructorList);
        returnedlist.addAll(Dupcheck);
        //return InstructorAchv;
        return returnedlist;
    }
    
    
    public class InstructorWrapper {
        @AuraEnabled public string Key;
        @AuraEnabled public String Valuess;
        @AuraEnabled public String expDate;
        @AuraEnabled public String Email;
        @AuraEnabled public String Phonenumber;
        @AuraEnabled public boolean Expireflag;
        @AuraEnabled public boolean ExistUser;
        @AuraEnabled public boolean ExistAccount;
        @AuraEnabled public String OrganizationName;
        public InstructorWrapper(string Key, String Valuess, String expDate, String Email, String Phonenumber,Boolean Expireflag, Boolean ExistUser, Boolean ExistAccount, String OrganizationName) {
            this.Key = Key;
            this.Valuess= Valuess;
            this.expDate=expDate;
            this.Email = Email;
            this.Phonenumber = Phonenumber;
            this.Expireflag = Expireflag;
            this.ExistUser = ExistUser;
            this.ExistAccount = ExistAccount;
            this.OrganizationName = OrganizationName;
        }
    }
    public class UserAccountWrapper{
        @AuraEnabled public List<Account> Accountdetails;
        @AuraEnabled public List<User> Userdetails;
        /* public UserAccountWrapper(List<Account> Accountdetails,List<User> Userdetails) {
this.Accountdetails=Accountdetails;
this.Userdetails=Userdetails;
}*/
    }
    
}