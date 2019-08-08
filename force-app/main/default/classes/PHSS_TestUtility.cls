@isTest
public with sharing class PHSS_TestUtility {
	public static final String BUCKET_ACCOUNT_SETTINGS_RECORD_TYPE_NAME = 'Bucket_Account';

	private static final String SWITCH_NAME_CASE_HISTORY = 'CaseOwnerHistorySwitch';
	public static final Integer NUMBER_OF_RECORDS = 80;

	public static Map<String, String> getPicklistValues(String objectName, String picklistFieldName) {
		Map<String, String> picklist = new Map<String, String>();
		for(Schema.PicklistEntry picklistEntry: Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(picklistFieldName).getDescribe().getPicklistValues()) {
			picklist.put(picklistEntry.getValue(), picklistEntry.getLabel());
		}
		return picklist;
	}

	public static UserRole getRandomUserRole(String name) {
		return [SELECT Id, Name FROM UserRole WHERE Name = :name LIMIT 1];
	}

	public static User createUser(Id userRoleId, Id profileId) {
		PHSS_Custom_Metadata__mdt defaults = getCustomMetadata();
		User usr = new User();
		usr.Firstname = PHSS_Utility.getRandomString(10);
        usr.LastName = PHSS_Utility.getRandomString(10);
        usr.Email = PHSS_Utility.getRandomEmail();
        usr.Username = PHSS_Utility.getRandomEmail();
        usr.Alias = usr.LastName.left(8);
        usr.Employee_ID__c = PHSS_Utility.getRandomString(10);
        usr.City = PHSS_Utility.getRandomString(10);
        usr.Country = PHSS_Utility.getRandomString(10);
        usr.State = PHSS_Utility.getRandomString(2);
        usr.PostalCode = PHSS_Utility.getRandomString(10);
        usr.Phone = PHSS_Utility.getRandomString(10);
        usr.Street = PHSS_Utility.getRandomString(10);
        usr.TimeZoneSidKey = defaults.Default_Timezone_Key__c;
	    usr.LanguageLocaleKey = defaults.Default_Language_Key__c;
	    usr.LocaleSidKey = defaults.Default_Locale_Key__c;
	    usr.EmailEncodingKey = defaults.Default_Email_Encoding_Key__c;
	    usr.ProfileId = profileId;
	    usr.UserRoleId = userRoleId;
	    return usr;
	}

	public static PHSS_User_Provisioning__c createUserProvisioningRecord(String sabaInternalId, Boolean isGoodStanding, Boolean isMarkedAsResource, Boolean isInternal){
		PHSS_User_Provisioning__c up = new PHSS_User_Provisioning__c();
		up.Firstname__c = PHSS_Utility.getRandomString(10);
		up.Employee_ID__C = isInternal ? PHSS_Utility.getRandomString(10) : null;
		up.SABA_Internal_ID__c = sabaInternalId;
		up.Lastname__c = PHSS_Utility.getRandomString(10);
		up.Email__c = PHSS_Utility.getRandomEmail();
		up.Username__c = PHSS_Utility.getRandomEmail();
		up.SABA_Person_Number__c = PHSS_Utility.getRandomString(10);
		up.Good_Standing__c = isGoodStanding;
		up.Marked_as_Resource__c = isMarkedAsResource;
		return up;
	}

	public static PHSS_User_Provisioning__c createUserProvisioningRecord(Boolean isGoodStanding, Boolean isMarkedAsResource, Boolean isInternal){
		return createUserProvisioningRecord(PHSS_Utility.getRandomString(10), isGoodStanding, isMarkedAsResource, isInternal);
	}

	public static PHSS_Certification_Provisioning__c createCertificationProvisioningRecord(String sabaInternalId, String status, PHSS_Custom_Certification_Mapping__mdt mapping){
		PHSS_Certification_Provisioning__c cp = new PHSS_Certification_Provisioning__c();
		cp.Certification_Name__c = mapping.Certification_Name__c;
		cp.Acquired_On__c = Date.today().addDays(-10);
		cp.Certification_Version__c = PHSS_Utility.getRandomString(5);
		cp.Expired_On__c = Date.today().addDays(10);
		cp.SABA_Internal_ID__c = sabaInternalId;
		cp.Status__c = status;
		cp.SABA_Certificate_Number__c = PHSS_Utility.getRandomString(10);
		return cp;
	}

	public static Bucket_Account_Settings__c createBucketAccountSettings(String accountOwner, String accountRecordTypeId){
		Bucket_Account_Settings__c bas = new Bucket_Account_Settings__c();
		bas.Maximum_Size_of_Bucket__c = 300;
		bas.Default_Bucket_Name__c = PHSS_Utility.getRandomString(10);
		bas.Bucket_Account_Owner_ID__c = accountOwner.substring(0, 15);
		bas.Bucket_Account_RecordTypeID__c = accountRecordTypeId.substring(0, 15);
		return bas;
	}

	public static RecordType getRecordType(String developerName){
		List<RecordType> recordTypes = [SELECT Id, Name FROM RecordType WHERE DeveloperName = :developerName];
		return recordTypes.size() == 0 ? null : recordTypes.get(0);
	}

	public static Profile getProfile(String developerName){
		List<Profile> prof = [SELECT Id FROM Profile WHERE name = :developerName LIMIT 1];
		return prof.size() == 0 ? null : prof.get(0);
	}

	public static User createUser(Id profileId, Id contactId, String sabaInternalId, PHSS_Custom_Metadata__mdt defaults){
		User usr = new User();
		usr.Firstname = PHSS_Utility.getRandomString(10);
        usr.LastName = PHSS_Utility.getRandomString(10);
        usr.Email = PHSS_Utility.getRandomEmail();
        usr.Username = PHSS_Utility.getRandomEmail();
        String strAlias = usr.LastName.left(8);
        usr.Alias = strAlias;
        usr.CommunityNickname = strAlias + '_' + PHSS_Utility.getRandomString(10);
        usr.SABA_Internal_ID__c = sabaInternalId;
        usr.SABA_Person_Number__c = PHSS_Utility.getRandomString(10);
        usr.Employee_ID__c = PHSS_Utility.getRandomString(10);
        usr.ProfileId = profileId;
        usr.ContactId = contactId;
        usr.TimeZoneSidKey = defaults.Default_Timezone_Key__c;
        usr.LanguageLocaleKey = defaults.Default_Language_Key__c;
        usr.LocaleSidKey = defaults.Default_Locale_Key__c;
        usr.EmailEncodingKey = defaults.Default_Email_Encoding_Key__c;
        return usr;
	}

	public static Contact createContact(Id accountId){
		Contact con = new Contact();
		con.LastName = PHSS_Utility.getRandomString(10);
        con.SABA_Internal_ID__c = PHSS_Utility.getRandomString(10);
        return con;
	}

	public static Account createAccount(){
		Account acc = new Account();
		acc.Name = PHSS_Utility.getRandomString(10);
		return acc;
	}

	public static PHSS_Custom_Metadata__mdt getCustomMetadata(){
		return [
                SELECT
                Bucket_Account_Name_Prefix__c, Default_Email_Encoding_Key__c, Default_Language_Key__c, Default_Locale_Key__c,
                Default_Timezone_Key__c, Maximum_Contacts_Per_Account__c, ProfileName__c, Marked_As_Resource_Group_Name__c, UserProvisioningTriggerDebug__c, Username_Suffix__c,
                Certification_Error_Message__c, User_Error_Message__c
                FROM
                PHSS_Custom_Metadata__mdt
                WHERE DeveloperName = 'PHSS_Instructors_Corner_Test'
                LIMIT 1];
	}

	public static Group createGroup(String groupName){
		Group gr = new Group();
		gr.Name = groupName;
		return gr;
	}

	public static PHSS_TriggerSettings__c createTriggerSettings(){
		return new PHSS_TriggerSettings__c();
	}

	public static List<PHSS_Custom_Certification_Mapping__mdt> getCustomCertificationMapping(){
		return [SELECT Access_Level__c, Certification_Name__c FROM PHSS_Custom_Certification_Mapping__mdt];
	}

	public static Case createCase(String quentionType) {
		Case c = new Case();
		c.Question_type__c = quentionType;
		return c;
	}

	public static Case createCase() {
		Case c = new Case();
		return c;
	}

	public static Switch__c createCaseHistorySwitch(Boolean isOn) {
		return createSwitch(SWITCH_NAME_CASE_HISTORY, isOn);
	}

	public static Switch__c createSwitch(String name, Boolean isOn) {
		Switch__c s = new Switch__c();
		s.Name = name;
		s.Switch__c = isOn;
		s.Switch_Description__c = PHSS_Utility.getRandomString(20);
		return s;
	}

	public static CaseComment createCaseComment(Id caseId) {
		CaseComment comment = new CaseComment();
		comment.CommentBody = PHSS_Utility.getRandomString(10);
		comment.ParentId = caseId;
		comment.IsPublished = true;
		return comment;
	}

	public static PHSS_Program__c createProgram(Boolean archived, Boolean featured, String libraryName) {
		PHSS_Program__c program = new PHSS_Program__c();
		program.Archived__c = archived;
		program.Content_Library_Name__c = libraryName;
		program.Description__c = PHSS_Utility.getRandomString(10);
		program.Featured__c = featured;
		program.Instructor_Bulletin__c = PHSS_Utility.getRandomString(10);
		program.Program_Long_Name__c = PHSS_Utility.getRandomString(10);
		program.Program_Name__c = PHSS_Utility.getRandomString(10);
		return program;
	}

	public static PHSS_Program__c createProgram(Boolean archived, Boolean featured) {
		return createProgram(archived, featured, PHSS_Utility.getRandomString(10));
	}

	public static ContentVersion createContent(String tags){
		return createContent(tags, 12);
	}

	public static ContentVersion createContent(String tags, Integer sequence){
		ContentVersion cv = new ContentVersion();
		cv.TagCsv = tags;
		cv.ContentURL = PHSS_Utility.getRandomUrl();
		cv.Sequence__c = sequence;
		cv.Create_IC_Program_Material_Record__c = true;
		return cv;
	}

	public static ContentWorkspace gerLibrary(){
		return [SELECT Id, Name FROM ContentWorkspace LIMIT 1];
	}

	public static void setupContent() {
		ContentWorkspace library = gerLibrary();
		insert createProgram(true, true, library.Name);
		List<ContentVersion> contentVersions = new List<ContentVersion>();
		for(Integer i = 0; i < NUMBER_OF_RECORDS / 4; i++){
			contentVersions.add(createContent('Link, Instructor Bulletin'));
			contentVersions.add(createContent('Video, Participant'));
			contentVersions.add(createContent('Link, Material'));
			contentVersions.add(createContent(null));
		}
		insert contentVersions;
	}
}