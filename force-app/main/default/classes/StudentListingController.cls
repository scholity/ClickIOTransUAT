public without sharing class StudentListingController
{
    @AuraEnabled
    public static List<sObject> getPicklistValues(String objName, String accId) 
    {
        User usr = [SELECT id, ContactId, Name, Profile.Name, Profile.UserLicense.Name FROM User WHERE id=: UserInfo.getUserId()];
        String sQuery = '';
        if(objName == 'Account')
        {
            sQuery =  'Select id, Name From ' +objName + ' Where id in (SELECT AccountId FROM AccountContactRelation WHERE ContactId = \'' +usr.ContactId+'\') Order By Name ASC';
        }
        else if(ObjName == 'User')
        {
            List<String> ListRolesName= new List<String> {'Administrator','Instructor'};
                Boolean isInstructor = isInstructor(accId);
            
            if(isInstructor) {
                sQuery =  'Select id, Name From ' +objName + ' Where ContactId in (SELECT ContactId FROM AccountContactRelation WHERE AccountId = \'' +accId +'\' and ContactId = \'' +usr.ContactId+'\' and Roles IN: ListRolesName) Order By Name ASC';    
            }
            else {
                sQuery =  'Select id, Name From ' +objName + ' Where ContactId in (SELECT ContactId FROM AccountContactRelation WHERE AccountId = \'' +accId +'\' and Roles IN: ListRolesName) Order By Name ASC';    
            }
        }        
        List <sObject> lstOfRecords = Database.query(sQuery);
        return lstOfRecords;
    }
    
    // Get logged in user details:
    public static User fetchUser()
    {      
        User u = [SELECT id, ContactId, Name, Profile.Name, Profile.UserLicense.Name FROM User WHERE id=: UserInfo.getUserId()];
        return u;
    }
    
    @AuraEnabled
    public static List<InstructorWrapper> fetchAchv(String accId, String instId,  String expirationDateFrom, String expirationDateTo, String certificateId) 
    {
        System.debug('instId idd'+instId);
        System.debug('Accountidd >>>>'+accId);
        
        //Get List of ILT Classes with Given Instructors
        String accName = '';
        Map<Id, user> userIdAndNameMap = new Map<Id, user>();
        if(((List<Id>)JSON.deserializeStrict(accId ,List<Id>.class)).size () > 0)
        {
            List<Id> accIdsFromClient = (List<Id>)JSON.deserializeStrict(accId ,List<Id>.class);
            List<Account> accList = [select id, Name from Account where Id In : accIdsFromClient];
            accName = accList[0].Name;
        }
        
        List<redwing__ILT_Instructor__c> instructorsList = new List<redwing__ILT_Instructor__c>();
        if(((List<Id>)JSON.deserializeStrict(instId ,List<Id>.class)).size () > 0)
        {
            List<Id> userIdsFromClient = (List<Id>)JSON.deserializeStrict(instId ,List<Id>.class);
            userIdAndNameMap = new Map<ID, user>([SELECT Id, Name FROM user where Id In : userIdsFromClient]);
            instructorsList = [select Id, redwing__ILT_Class__c, redwing__Instructor__c from redwing__ILT_Instructor__c where redwing__Instructor__c In: userIdsFromClient And Account__c =: accName];
        }
        Map<Id, List<Id>> classesIdWithInstructorsList = new Map<Id, List<Id>>();
        for(redwing__ILT_Instructor__c indInstructorRec : instructorsList)
        {
            if(classesIdWithInstructorsList.containsKey(indInstructorRec.redwing__ILT_Class__c))
                classesIdWithInstructorsList.get(indInstructorRec.redwing__ILT_Class__c).add(indInstructorRec.redwing__Instructor__c);
            else
            {
                List<Id> instructorsIdsList = new List<Id>();
                instructorsIdsList.add(indInstructorRec.redwing__Instructor__c);
                classesIdWithInstructorsList.put(indInstructorRec.redwing__ILT_Class__c, instructorsIdsList);
            }
        }
        //Till here
        
        String sObjectQuery = 'Select Id, Name, ILT_Class__c, Account__r.Name,redwing__Contact__r.Email,redwing__Contact__r.Phone, redwing__User__c ,redwing__User__r.Name, redwing__User__r.Phone, redwing__User__r.Email, redwing__Expiration_Date__c, QR_Code_Identifier__c, ILT_Class__r.redwing__Location__r.redwing__Address_1__c, ILT_Class__r.redwing__Location__r.redwing__City__c, ILT_Class__r.redwing__Location__r.redwing__Country__c, ILT_Class__r.redwing__Location__r.redwing__State__c, ILT_Class__r.redwing__Location__r.redwing__Postal_Code__c, ILT_Class__r.Name, ILT_Class__r.redwing__Start_Date__c, ILT_Class__r.redwing__End_Date__c, ILT_Class__r.Class_Closed_Date__c, redwing__Acquisition_Date__c, redwing__Achievement__r.Name, Firstname__c, Lastname__c, Email__c, Phone__c, ILT_Class__r.redwing__Location__c from redwing__Achievement_Assignment__c where  Id != null ';
        
        if(((List<Id>)JSON.deserializeStrict(accId ,List<Id>.class)).size () > 0)
        {
            List<Id> accIdsFromClient = (List<Id>)JSON.deserializeStrict(accId ,List<Id>.class);
            sObjectQuery  += ' And Account__c In: accIdsFromClient';
        }
        
        //Start Date Condition
        date dateExpirationDateFrom;
        If(!String.isBlank(expirationDateFrom))
        {
            dateExpirationDateFrom = date.valueOf(expirationDateFrom);
            sObjectQuery += ' AND redwing__Expiration_Date__c >= : dateExpirationDateFrom ';  
        }
        
        date dateExpirationDateTo;
        If(!String.isBlank(expirationDateTo))
        {
            dateExpirationDateTo = date.valueOf(expirationDateTo);
            sObjectQuery += ' AND redwing__Expiration_Date__c <= : dateExpirationDateTo ';  
        }
        
        //Course Id Condition
        if(!String.isBlank(certificateId))
            sObjectQuery += ' AND redwing__Achievement__c = : certificateId '; 
        
        sObjectQuery += ' And redwing__Status__c = \'Acquired\'';
        sObjectQuery += ' And Achievement_Type__c = \'Certifications\'';
        sObjectQuery += ' ORDER BY redwing__User__r.Name,redwing__Achievement__r.Name ASC';
        
        List<redwing__Achievement_Assignment__c> InstructorAchv = Database.query(sObjectQuery);
        
        // Add data to wrapper list and display the details in the table
        List<InstructorWrapper> InstructorList = new List<InstructorWrapper>();
        for(redwing__Achievement_Assignment__c key: InstructorAchv)
        {
            if(classesIdWithInstructorsList.containsKey(key.ILT_Class__c))
            {
                if(((List<Id>)JSON.deserializeStrict(instId ,List<Id>.class)).size () > 0)
                {
                    List<Id> userIdsFromClient = (List<Id>)JSON.deserializeStrict(instId ,List<Id>.class);
                    for(Id indUserIdFromClient : userIdsFromClient)
                    {
                        if(classesIdWithInstructorsList.get(key.ILT_Class__c).contains(indUserIdFromClient))
                        {
                            String Expdate = '';
                            if(Key.redwing__Expiration_Date__c != null)
                                Expdate = Key.redwing__Expiration_Date__c.format();
                            
                            // Location
                            LocationWrapper currentLocation = new LocationWrapper();
                            if(key.ILT_Class__r.redwing__Location__c != null){
                                currentLocation.city        = key.ILT_Class__r.redwing__Location__r.redwing__City__c;
                                currentLocation.address1    = key.ILT_Class__r.redwing__Location__r.redwing__Address_1__c;
                                currentLocation.country     = key.ILT_Class__r.redwing__Location__r.redwing__Country__c;
                                currentLocation.province    = key.ILT_Class__r.redwing__Location__r.redwing__State__c;
                                currentLocation.postalCode  = key.ILT_Class__r.redwing__Location__r.redwing__Postal_Code__c;
                            }
                            InstructorList.add(new InstructorWrapper(userIdAndNameMap.get(indUserIdFromClient).Name, Key.redwing__Achievement__r.Name, Expdate, Key.redwing__Contact__r.Email, Key.redwing__Contact__r.Phone, key.Account__r.Name, Key.QR_Code_Identifier__c, Key.Firstname__c, Key.Lastname__c, Key.Email__c, Key.Phone__c, Key.redwing__Achievement__r.Name, Key.redwing__Acquisition_Date__c, Key.ILT_Class__r.Name, Key.ILT_Class__r.redwing__Start_Date__c, currentLocation));
                        }
                    }
                }
            }
        }
        System.debug('InstructorList>>>>>>>>>>>>>>>>'+InstructorList);
        return InstructorList;
    }
    
    public static Boolean isInstructor(String accId) 
    {
        User usr = [Select Id,Name,Profile.Name, ContactId From User Where Id = :UserInfo.getUserId()];  
        if(usr.Profile.Name.containsIgnoreCase('partner')) 
        {
            List<AccountContactRelation> accountConRelation = [select id, Roles from AccountContactRelation where AccountId =: accId And ContactId =: usr.ContactId AND Roles includes ('Administrator')];
            if(accountConRelation.size() > 0)
                return false;
            else
                return true;
        }
        return true;
    }
    
    public class InstructorWrapper 
    {
        @AuraEnabled public string Key;
        @AuraEnabled public String Valuess;
        @AuraEnabled public String expDate;
        @AuraEnabled public String Email;
        @AuraEnabled public String Phonenumber;
        @AuraEnabled public String OrganizationName;
        @AuraEnabled public String QRCode;
        @AuraEnabled public String StudentFirstName;
        @AuraEnabled public String StudentLastName;
        @AuraEnabled public String StudentEmail;
        @AuraEnabled public String StudentPhone;
        @AuraEnabled public String AchievementName;
        @AuraEnabled public Date AcquisitionDate;
        @AuraEnabled public String ILTClass;
        @AuraEnabled public Date ILTClassStartDate;
        @AuraEnabled public locationWrapper location;
        public InstructorWrapper(string Key, String Valuess, String expDate, String Email, String Phonenumber, String OrganizationName, String QRCode, String StudentFirstName, String StudentLastName, String StudentEmail, String StudentPhone, String AchievementName, Date AcquisitionDate, String ILTClass, Date ILTClassStartDate, locationWrapper location) 
        {
            this.Key = Key;
            this.Valuess= Valuess;
            this.expDate=expDate;
            this.Email = Email;
            this.Phonenumber = Phonenumber;
            this.OrganizationName = OrganizationName;
            this.QRCode = QRCode;
            this.StudentFirstName = StudentFirstName;
            this.StudentLastName = StudentLastName;
            this.StudentEmail = StudentEmail;
            this.StudentPhone = StudentPhone;
            this.AchievementName = AchievementName;
            this.AcquisitionDate = AcquisitionDate;
            this.ILTClass = ILTClass;
            this.ILTClassStartDate = ILTClassStartDate;
            this.location = location;
        }
    }
    
    public with sharing class locationWrapper {
        @AuraEnabled public String city         = '';
        @AuraEnabled public String address1     = '';
        @AuraEnabled public String country      = '';
        @AuraEnabled public String province     = '';
        @AuraEnabled public String postalCode   = '';
    }
}