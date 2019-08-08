/**
    * Apex Class : TestUtil
    *   Description : Helper class For Test Classes
    * Created By : Sudhir Kr. Jagetiya
    * Created Date : April 17,2012
    */

//@isTest
public without sharing class TestUtil {
  public static UnitTest.DataGenerator accounts = new AccountDG();
  public static UnitTest.DataGenerator opportunities = new OpportunityDG();
  public static UnitTest.DataGenerator tasks = new TaskDG();
  public static UnitTest.DataGenerator events = new EventDG();
  public static UnitTest.DataGenerator attachments = new AttachmentDG();
  public static UnitTest.DataGenerator notes = new NoteDG();
  public static UnitTest.DataGenerator contacts = new ContactDG();
  public static UnitTest.DataGenerator cases = new CaseDG();
  public static UnitTest.DataGenerator contracts = new ContractDG();
  public static UnitTest.DataGenerator accountContactRoles = new AccountContactRoleDG();
  
  public static Profile SYSTEM_ADMINISTRATOR_PROFILE {
    get
    {
      if(SYSTEM_ADMINISTRATOR_PROFILE==null)
        SYSTEM_ADMINISTRATOR_PROFILE = [Select ID From Profile Where Name='System Administrator' LIMIT 1];
      return SYSTEM_ADMINISTRATOR_PROFILE;
    }
    private set;
  }
    public static User BGST_USER {
        get
        {
            if(BGST_USER == null)
                  BGST_USER = [SELECT ID FROM User WHERE Profile.Name LIKE '%ARC BGST Sales User' AND IsActive = True LIMIT 1];
            return BGST_USER;
        }
        private set;
    }
  public static RecordType SERVICE_CASES
    {
        get
        {
            if( SERVICE_CASES == null )
                SERVICE_CASES = [ Select Name, Id From RecordType r where Name = 'Service Cases' AND SobjectType = 'Case' ];
            return SERVICE_CASES;
        }
        private set;
    }

    public static RecordType SERVICE_CASES_READ_ONLY
    {
        get
        {
            if( SERVICE_CASES_READ_ONLY == null )
                SERVICE_CASES_READ_ONLY = [ Select Name, Id From RecordType r where Name = 'Service Case Read Only' AND SobjectType = 'Case' ];
            return SERVICE_CASES_READ_ONLY;
        }
        private set;
    }


  public class AccountContactRoleDG implements UnitTest.DataGenerator
  { 
    public List<SObject> generateData(Integer howMany)
    {
      List<SObject> retList = new List<SObject>();
      for(Integer i = 0; i < howMany; i++)
      {
        retList.add(createAccountContactRole(null,null,false));
      }
      return retList;
    }
  }
  
  public static AccountContactRole createAccountContactRole(ID accountID, ID contactID, Boolean doInsert)
  {
    AccountContactRole acr = new AccountContactRole(AccountID=accountID, ContactID=contactID);
    if(doInsert) insert acr;
    return acr;
  }
  
  public class ContractDG implements UnitTest.DataGenerator
  { 
    public List<SObject> generateData(Integer howMany)
    {
      return createContracts(null,howMany,false);
    }
  }
  
  public static List<Contract> createContracts(ID accountID, Integer howMany, Boolean doInsert)
  {
    List<Contract> retList = new List<Contract>();
    for(Integer i = 0; i < howMany; i++)
    {
      retList.add(new Contract(AccountID=accountID));
    }
    if(doInsert) insert retList;
    return retList;
  }

  public class CaseDG implements UnitTest.DataGenerator
  { 
    public List<SObject> generateData(Integer howMany)
    {
      return createCases(howMany,false);
    }
  }
  
  public static List<Case> createCases(Integer howMany, Boolean doInsert)
  {
    List<Case> retList = new List<Case>();
    for(Integer i = 0; i < howMany; i++)
    {
      retList.add(new Case());
    }
    if(doInsert) insert retList;
    return retList;
  }
  
  public class ContactDG implements UnitTest.DataGenerator
  { 
    public List<SObject> generateData(Integer howMany)
    {
      return createContacts(howMany,false);
    }
  }
  
  public static List<Contact> createContacts(Integer howMany, Boolean doInsert)
  {
    List<Contact> retList = new List<Contact>();
    for(Integer i = 0; i < howMany; i++)
    {
      retList.add(new Contact(LastName='Contact'+i,MailingPostalCode='28027'));
    }
    if(doInsert) insert retList;
    return retList;
  }
  
  public class NoteDG implements UnitTest.DataGenerator
  { 
    public List<SObject> generateData(Integer howMany)
    {
      return createNotes(null, howMany,false);
    }
  }
  
  public static List<Note> createNotes(ID parentID, Integer howMany, Boolean doInsert)
  {
    List<Note> retList = new List<Note>();
    for(Integer i = 0; i < howMany; i++)
    {
      retList.add(new Note(ParentID=parentID, Title='Title'+i));
    }
    if(doInsert) insert retList;
    return retList;
  }
  
  public class AttachmentDG implements UnitTest.DataGenerator
  { 
    public List<SObject> generateData(Integer howMany)
    {
      return createAttachments(null,howMany,false);
    }
  }
  
  public static List<Attachment> createAttachments(ID parentID, Integer howMany, Boolean doInsert)
  {
    List<Attachment> retList = new List<Attachment>();
    for(Integer i = 0; i < howMany; i++)
    {
      retList.add(new Attachment(ParentID=parentID, Name='A'+i, Body=Blob.valueOf('b'+i)));
    }
    if(doInsert) insert retList;
    return retList;
  }
  
  public class EventDG implements UnitTest.DataGenerator
  { 
    public List<SObject> generateData(Integer howMany)
    {
      return createEvents(howMany,false);
    }
  }
  
  public static List<Event> createEvents(Integer howMany, Boolean doInsert)
  {
    List<Event> retList = new List<Event>();
    for(Integer i = 0; i < howMany; i++)
    {
      retList.add(new Event(DurationInMinutes=1,ActivityDateTime=DateTime.now()));
    }
    if(doInsert) insert retList;
    return retList;
  }
  
  public class TaskDG implements UnitTest.DataGenerator
  { 
    public List<SObject> generateData(Integer howMany)
    {
      return createTasks(howMany,false);
    }
  }
  
  public static List<Task> createTasks(Integer howMany, Boolean doInsert)
  {
    List<Task> retList = new List<Task>();
    for(Integer i = 0; i < howMany; i++)
    {
      retList.add(new Task());
    }
    if(doInsert) insert retList;
    return retList;
  }
  
  public class AccountDG implements UnitTest.DataGenerator
  { 
    public List<SObject> generateData(Integer howMany)
    {
      return createAccounts(howMany, false);  
    }
  }

  public static List<Account> createBucketAccounts(Integer howMany, Integer spots, Bucket_Account_Settings__c bucketSetting, Boolean isInsert) {
    List<Account> retList = new List<Account>();
    for (Integer i = 0; i < howMany; i++) {
      retList.add(createBucketAccount(spots, bucketSetting, false));
    }
    if(isInsert) insert retList;
    return retList;
  }
  
   public static Account createBucketAccount(Integer spots, Bucket_Account_Settings__c bucketSetting, Boolean isInsert) {
      Account acct = new Account();
      acct.Name = 'Test Bucket Account';
      acct.RecordTypeID = bucketSetting.Bucket_Account_RecordTypeID__c;
      acct.Spots_Taken__c = spots;
      if (isInsert)
      insert acct;
      return acct;
    }

  public static List<Account> createAccounts(Integer howMany, Boolean isInsert)
  {
    List<Account> retList = new List<Account>();
    for(Integer i = 0; i < howMany; i++)
    {
      retList.add(createAccount(false));
    }
    if(isInsert) insert retList;
    return retList;
  }
    //A method that used To create an Account
    public static Account createAccount(Boolean isInsert) {
      Account acct = new Account();
      acct.Name = 'Test Account';
      if (isInsert)
      insert acct;
      return acct;
    }
  
  public class OpportunityDG implements UnitTest.DataGenerator
  { 
    public List<SObject> generateData(Integer howMany)
    {
      List<SObject> retList = new List<SObject>();
      for(Integer i = 0; i < howMany; i++)
      {
        retList.add(createOpportunity(null,'Approach',false));
      }
      return retList;
    }
  }
  
  //A method that used To create an Opportunity
  public static Opportunity createOpportunity(Id accId,String stageName, 
    Boolean isInsert) { 
    Opportunity opp = new Opportunity();
    opp.Name = 'Test opp';
    opp.AccountId = accId;
    opp.StageName = stageName;
    opp.CloseDate = Date.today();
    if (isInsert)
      insert opp;       
    return opp;
  }
  //A method that used to create an Opportunity for BGST
  public static Opportunity createBGSTOpportunity(Id accId, String stagename,
    Boolean isInsert){
     Opportunity opp = new Opportunity();
    opp.name = 'Test BGST Opp';
    opp.AccountId = accId;
    opp.StageName = stagename;
    opp.CloseDate = Date.today();
    opp.OwnerId = BGST_USER.Id;
    if (isInsert)
        insert opp;
    return opp;
  }
  //A method that used To create an Opportunity Product
  public static OpportunityLineItem createOpportunityLineItem(id oppId,Id pbeId ,Boolean isInsert){
    OpportunityLineItem oli = new OpportunityLineItem(opportunityId = oppId, 
                                                        pricebookentryId = pbeId, Quantity = 1, 
                                                        UnitPrice = 20, 
                                                        Description = '2007 CMR #4 - Anti-Infectives');
    if (isInsert)
      insert oli;       
    return oli;
  }
   //A method that used to create a user
  public static User createUser(String userName,Id profileId,Boolean isInsert, Id managerId, String lastName, String firstName){
        User user = new User(
            Username = userName,
            Email = 'john@acme.com',
            LastName = lastName,
            FirstName = firstName,
            Alias = 'sv',
            ProfileID = profileId,
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey='UTF-8',
            ManagerId = managerId
        );
        if(isInsert)
            insert user;
        return user;
    }

    /**
  * @author Michael Hendy
  * @date 08/21/2013
  * @description Determines if the pagemessages contains a certain string
  * @param String messageNeedle : the string we will search for in the pagemessages
  * @return Boolean : true if found, false otherwise
  */

  public static Boolean pageMessageContains(String messageNeedle)
  {
     if( ApexPages.getMessages().size() > 0 )
     {
             for (ApexPages.Message message : ApexPages.getMessages() ){

                 if(message.getSummary().contains(messageNeedle))
                         return true;
             }
     }

     return false;
  }

  public static void setupBucketAccountSettings()
  {
    if(Bucket_Account_Settings__c.getInstance().Bucket_Account_Owner_ID__c==null)
    {
      System.runAs(new User(ID=UserInfo.getUserID()))
      {
        List<RecordType> accountRecordTypes =  [Select ID From RecordType Where SObjectType='Account' AND IsActive=TRUE];
            insert (new Bucket_Account_Settings__c(Bucket_Account_Owner_ID__c=UserInfo.getUserID(), 
                                                       Default_Bucket_Name__c='Default Name',
                                                       Maximum_Size_of_Bucket__c = 1000,
                                                       Bucket_Account_RecordTypeID__c = accountRecordTypes[0].ID,
                                                       SetupOwnerId =UserInfo.getOrganizationId()));
      }
    }
  }
}