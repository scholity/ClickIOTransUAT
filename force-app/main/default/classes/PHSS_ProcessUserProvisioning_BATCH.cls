global class PHSS_ProcessUserProvisioning_BATCH implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    private static final String ACCOUNT_SETTINGS_NAME = 'PHSS-CS-0001';
    private static final String CLASS_NAME = PHSS_ProcessUserProvisioning_BATCH.class.getName();
    private static final Pattern EMAIL_PATTERN = Pattern.compile('.+@.+\\..+');

    private static final String CRON_EXPRESSION = '0 0 2 * * ?';

	private String query;
	private Set<Id> instructorMembership;
	private Id groupId;
	private PHSS_Custom_Metadata__mdt defaults;
	private Set<Id> usersToDeactivation;
	private Map<Id, String> usernamesToUpdate;
    private Id profileId;
    private Boolean isError;
    private Integer numberOfSuccess;
    private Integer numberOfErrors;
    private Integer numberOfNotProcessed;

	global static void run() {
        PHSS_BatchHelper.abortDelayedJob();
		if(PHSS_BatchHelper.shouldBeEnqueued(PHSS_ProcessUserProvisioning_BATCH.CLASS_NAME)) {
			Id newJobId = Database.executeBatch(new PHSS_ProcessUserProvisioning_BATCH());
		}
	}

    public static void processRemainingRecords(Boolean isError) {
        String name = PHSS_BatchHelper.buildSchedulerName(PHSS_BatchHelper.DELAYED_BATCH_NAME);
        if(isError && PHSS_BatchHelper.shouldBeScheduled(name)) {       
            System.schedule(
                name,
                PHSS_BatchHelper.buildCronString(),
                new PHSS_ProcessUserProvisioning_BATCH()
            );
        } 
    }

    public static String schedule() {
        return PHSS_ProcessUserProvisioning_BATCH.schedule(PHSS_ProcessUserProvisioning_BATCH.CRON_EXPRESSION);
    }

    public static String schedule(String cronExpression) {
        String name = PHSS_BatchHelper.buildSchedulerName(PHSS_BatchHelper.SCHEDULER_NAME);
        return PHSS_BatchHelper.shouldBeScheduled(name) ? System.schedule(name, cronExpression, new PHSS_ProcessUserProvisioning_BATCH()) : null;
    }

    global void execute(SchedulableContext sc) {
        PHSS_ProcessUserProvisioning_BATCH.run();
    }

    private static void sendEmailNotification(Integer numberOfSuccess, Integer numberOfErrors, Integer numberOfNotProcessed) {
        List<PHSS_Custom_Metadata__mdt> configs = [SELECT Prevent_User_Provisioning_Email__c FROM PHSS_Custom_Metadata__mdt WHERE DeveloperName = 'PHSS_Instructors_Corner' LIMIT 1];
         if(configs.isEmpty() || !configs.get(0).Prevent_User_Provisioning_Email__c) {
            PHSS_EmailNotification.send(PHSS_EmailNotification.Type.User_Provisioning, numberOfSuccess, numberOfErrors, numberOfNotProcessed);
        }
    }

    public static Boolean clearRecords = false; 

    private PHSS_ProcessUserProvisioning_BATCH() {
        this.query = 'SELECT Id, City__c, Country__c, State__c, Zipcode__c, Main_Phone__c, Address1__c, Address2__c, Address3__c, Firstname__c, ' + 
            'Employee_ID__C, SABA_Internal_ID__c, Lastname__c, Email__c, Username__c, SABA_Person_Number__c, Good_Standing__c, Marked_as_Resource__c ' + 
            'FROM PHSS_User_Provisioning__c';
        this.defaults = PHSS_BatchHelper.getDefaults();
        System.debug('Settings:');
        System.debug(this.defaults);
        String groupName = this.defaults.Marked_As_Resource_Group_Name__c;
        List<Group> groups = [SELECT Id FROM Group WHERE Name = :groupName];
        System.debug('Groups:');
        System.debug(groups);
        if(groups.isEmpty()) {
            throw new GroupMembershipException('This group doesn\'t exist: ' + groupName);
        }
        this.groupId = groups.get(0).Id;
        this.instructorMembership = new Set<Id>();
        this.usersToDeactivation = new Set<Id>();
        this.usernamesToUpdate = new Map<Id, String>();
        this.profileId = [SELECT Id FROM Profile WHERE name = :this.defaults.ProfileName__c LIMIT 1].Id;
        System.debug('ProfileId:');
        System.debug(this.profileId);
        this.isError = false;
        this.numberOfSuccess = 0;
        this.numberOfErrors = 0;
        this.numberOfNotProcessed = 0;
    }

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(this.query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		this.processUserProvisioning((List<PHSS_User_Provisioning__c>)scope);
	}

	global void finish(Database.BatchableContext BC) {
		this.enqueueJobs();
        PHSS_ProcessCertProvisioning_BATCH.scheduleCertificationProvisioning(this.isError);
        PHSS_ProcessUserProvisioning_BATCH.sendEmailNotification(this.numberOfSuccess, this.numberOfErrors, this.numberOfNotProcessed);
	}

	private class Bucket {
        public Integer size;
        public String name;
        public Id accountId;

        public Bucket(String name, Integer size, Id accountId) {
            this.name = name;
            this.size = size;
            this.accountId = accountId;
        }
    }

    private static List<Account> createAccounts(List<Bucket> buckets) {
        List<Account> filtred = new List<Account>();
        for (Bucket buck : buckets) {
            if (buck.accountId == null) {
                filtred.add(new Account(Name = buck.name));
            }
        }
        return filtred;
    }

    private static Map<String, Id> getExistedAccountIds(List<Bucket> buckets) {
        Map<String, Id> filtred = new Map<String, Id>();
        for (Bucket buck : buckets) {
            if (buck.accountId != null) {
                filtred.put(buck.name, buck.accountId);
            }
        }
        return filtred;
    }

    private static Map<String, Id> accountNameToId(List<Account> accounts) {
        Map<String, Id> mapped = new Map<String, Id>();
        for (Account acc : accounts) {
            mapped.put(acc.Name, acc.Id);
        }
        return mapped;
    }

    private static String getRandomSufix() {
        return PHSS_Utility.getRandomString(10);
    }

    private void clear(List<PHSS_User_Provisioning__c> userProvisioningData) {
        if (!this.defaults.UserProvisioningTriggerDebug__c || clearRecords) {
            delete userProvisioningData;
        }
    }

    private String buildBucketName(Decimal counter) {
        return this.defaults.Bucket_Account_Name_Prefix__c + ' ' + String.valueOf(counter.intValue());
    }

    private static Boolean isUserProvisioningRecordCorrect(PHSS_User_Provisioning__c userProvisioning) {
        return userProvisioning != null && 
            userProvisioning.Username__c != null && 
            userProvisioning.Email__c != null && 
            userProvisioning.Lastname__c != null && 
            PHSS_ProcessUserProvisioning_BATCH.EMAIL_PATTERN.matcher(userProvisioning.Username__c).matches() && 
            PHSS_ProcessUserProvisioning_BATCH.EMAIL_PATTERN.matcher(userProvisioning.Email__c).matches();
    }

    private void processUserProvisioning(List<PHSS_User_Provisioning__c> userProvisioningData) {
        List<PHSS_Custom_Settings__c> allSettings = PHSS_Custom_Settings__c.getAll().values();
        PHSS_Custom_Settings__c settings;
        if(allSettings.isEmpty()) {
            settings = new PHSS_Custom_Settings__c();
            settings.Bucket_Account_Number_Suffix__c = 0;
            settings.Current_Bucket_Account_ID__c = null;
            settings.Name = PHSS_ProcessUserProvisioning_BATCH.ACCOUNT_SETTINGS_NAME;
        } else {
            settings = allSettings.get(0);
        }
        System.debug('PHSS_Custom_Settings__c:');
        System.debug(settings);
        Id currentBucketId = settings.Current_Bucket_Account_ID__c;
        Bucket currentBucket = null;
        AggregateResult currentBucketDetails = [SELECT count(Id) currentBucketSize FROM Contact WHERE AccountId = :currentBucketId];
        Integer currentBucketSize = Integer.valueOf(currentBucketDetails.get('currentBucketSize'));
        if (currentBucketSize < this.defaults.Maximum_Contacts_Per_Account__c) {
            List<Account> accounts = [SELECT Id, Name FROM Account WHERE Id = :currentBucketId];
            if (accounts.isEmpty()) {
                currentBucket = new PHSS_ProcessUserProvisioning_BATCH.Bucket(this.buildBucketName(settings.Bucket_Account_Number_Suffix__c), 0, null);
                settings.Bucket_Account_Number_Suffix__c++;
            } else {
                currentBucket = new PHSS_ProcessUserProvisioning_BATCH.Bucket(accounts.get(0).Name, currentBucketSize, accounts.get(0).Id);
            }
        } else {
            currentBucket = new PHSS_ProcessUserProvisioning_BATCH.Bucket(this.buildBucketName(settings.Bucket_Account_Number_Suffix__c), 0, null);
            settings.Bucket_Account_Number_Suffix__c++;
        }
        System.debug('Current Bucket init:');
        System.debug(currentBucket);
        List<Bucket> buckets = new List<Bucket>();
        Set<String> userSabaInternalIds = new Set<String>();
        Set<String> contactSabaInternalIds = new Set<String>();
        Set<String> usernames = new Set<String>();
        Map<String, PHSS_User_Provisioning__c> userProvisioningByUniqueValues = new Map<String, PHSS_User_Provisioning__c>();
        for (PHSS_User_Provisioning__c userProvisioning : userProvisioningData) {
            userSabaInternalIds.add(userProvisioning.SABA_Internal_ID__c);
            contactSabaInternalIds.add(userProvisioning.SABA_Internal_ID__c);
            usernames.add(userProvisioning.Username__c);
            userProvisioningByUniqueValues.put(userProvisioning.SABA_Internal_ID__c, userProvisioning);
            userProvisioningByUniqueValues.put(userProvisioning.Username__c, userProvisioning);
        }
        System.debug('userSabaInternalIds:');
        System.debug(userSabaInternalIds);
        System.debug('contactSabaInternalIds:');
        System.debug(contactSabaInternalIds);
        System.debug('usernames:');
        System.debug(usernames);
        System.debug('userProvisioningByUniqueValues:');
        System.debug(userProvisioningByUniqueValues);
        Map<String, User> users = new Map<String, User>();
        Map<String, Contact> contacts = new Map<String, Contact>();
        Map<String, User> usernamesToUser = new Map<String, User>();
        for (User us : [SELECT Id, SABA_Internal_ID__c, ContactId, Username FROM User WHERE SABA_Internal_ID__c IN :userSabaInternalIds OR Username IN :usernames]) {
            if(userSabaInternalIds.contains(us.SABA_Internal_ID__c)) {
                users.put(us.SABA_Internal_ID__c, us);
            }
            usernamesToUser.put(us.Username, us);
        }
        System.debug('users:');
        System.debug(users);
        System.debug('usernamesToUser:');
        System.debug(usernamesToUser);
        for (Contact con : [SELECT ID, Firstname, Lastname, SABA_Internal_ID__c FROM Contact WHERE SABA_Internal_ID__c IN :contactSabaInternalIds]) {
            contacts.put(con.SABA_Internal_ID__c, con);
        }
        System.debug('contacts:');
        System.debug(contacts);

        List<User> usersToUpdate = new List<User>();
        List<User> usersToInsert = new List<User>();
        List<Contact> contactsToUpsert = new List<Contact>();
        Map<String, String> contactAccounts = new Map<String, String>();
        Map<String, User> newUsers = new Map<String, User>();
        List<Contact> newContacts = new List<Contact>();
        Set<String> markedAsResources = new Set<String>();
        List<PHSS_Logger.Log> logs = new List<PHSS_Logger.Log>();
        List<PHSS_User_Provisioning__c> incorrectRecords = new List<PHSS_User_Provisioning__c>();
        for (PHSS_User_Provisioning__c userProvisioning : userProvisioningData) {
            System.debug('current userProvisioning:');
            System.debug(userProvisioning);
            if(!PHSS_ProcessUserProvisioning_BATCH.isUserProvisioningRecordCorrect(userProvisioning)) {
                logs.add(PHSS_Logger.createLog().setRecord(userProvisioning).setMessage(this.defaults.User_Error_Message__c));
                this.numberOfNotProcessed++;
                incorrectRecords.add(userProvisioning);
                System.debug('Record validation:');
                System.debug('continue');
                continue;
            }
            if (currentBucket.size == this.defaults.Maximum_Contacts_Per_Account__c) {
                buckets.add(currentBucket);
                currentBucket = new PHSS_ProcessUserProvisioning_BATCH.Bucket(this.buildBucketName(settings.Bucket_Account_Number_Suffix__c), 0, null);
                settings.Bucket_Account_Number_Suffix__c++;
            }
            System.debug('Current bucket:');
            System.debug(currentBucket);
            if (users.containsKey(userProvisioning.SABA_Internal_ID__c)) {
                User usr = setUserData(users.get(userProvisioning.SABA_Internal_ID__c), userProvisioning);
                System.debug('User update - saba id lookup:');
                System.debug(usr);
                if(contacts.containsKey(userProvisioning.SABA_Internal_ID__c)) {
                    contactsToUpsert.add(setContactData(contacts.get(userProvisioning.SABA_Internal_ID__c), userProvisioning));
                }
                if (!userProvisioning.Good_Standing__c) {
                    this.usersToDeactivation.add(usr.Id);
                }
                if(userProvisioning.Username__c != usr.Username) {
                    this.usernamesToUpdate.put(usr.Id, userProvisioning.Username__c);
                }
                usersToUpdate.add(usr);
            } else if(contacts.containsKey(userProvisioning.SABA_Internal_ID__c) && usernamesToUser.containsKey(userProvisioning.Username__c)) {
                User usr = setUserData(usernamesToUser.get(userProvisioning.Username__c), userProvisioning);
                usersToUpdate.add(usr);
                PHSS_ProcessUserProvisioning_BATCH.setUniqueValues(usr, userProvisioning);
                contactsToUpsert.add(setContactData(contacts.get(userProvisioning.SABA_Internal_ID__c), userProvisioning));
                if (!userProvisioning.Good_Standing__c) {
                    this.usersToDeactivation.add(usr.Id);
                }
                System.debug('User update - username lookup && contact exists:');
                System.debug(usr);
            }else if (userProvisioning.Good_Standing__c && contacts.containsKey(userProvisioning.SABA_Internal_ID__c)) {
                Contact con = setContactData(contacts.get(userProvisioning.SABA_Internal_ID__c), userProvisioning);
                User usr = setUserData(new User(), userProvisioning);
                this.setUserDefaults(usr);
                PHSS_ProcessUserProvisioning_BATCH.setNewUserDetails(usr, con.Id, userProvisioning.Username__c);
                PHSS_ProcessUserProvisioning_BATCH.setUniqueValues(usr, userProvisioning);
                usersToInsert.add(usr);
                contactsToUpsert.add(con);
                System.debug('User create - contact exists:');
                System.debug(usr);
                System.debug(con);
            } else if(usernamesToUser.containsKey(userProvisioning.Username__c)) {
                User usr = setUserData(usernamesToUser.get(userProvisioning.Username__c), userProvisioning);
                PHSS_ProcessUserProvisioning_BATCH.setUniqueValues(usr, userProvisioning);
                usersToUpdate.add(usr);
                if (!userProvisioning.Good_Standing__c) {
                    this.usersToDeactivation.add(usr.Id);
                }
                System.debug('User update - internal user:');
                System.debug(usr);
            } else if (userProvisioning.Good_Standing__c) {
                User usr = setUserData(new User(), userProvisioning);
                Contact con = setContactData(new Contact(), userProvisioning);
                this.setUserDefaults(usr);
                PHSS_ProcessUserProvisioning_BATCH.setNewContactData(con, userProvisioning);
                contactAccounts.put(userProvisioning.SABA_Internal_ID__c, currentBucket.name);
                currentBucket.size++;
                PHSS_ProcessUserProvisioning_BATCH.setNewUserDetails(usr, con.Id, userProvisioning.Username__c);
                PHSS_ProcessUserProvisioning_BATCH.setUniqueValues(usr, userProvisioning);
                newContacts.add(con);
                newUsers.put(userProvisioning.SABA_Internal_ID__c, usr);
                System.debug('User create - new user:');
                System.debug(usr);
                System.debug(con);
            }
            if(userProvisioning.Marked_as_Resource__c && userProvisioning.Good_Standing__c){
                markedAsResources.add(userProvisioning.SABA_Internal_ID__c);
            }
        }
        buckets.add(currentBucket);
        Savepoint sp = Database.setSavepoint();
        Boolean isException = false;
        try {
            List<Account> accounts = createAccounts(buckets);
            System.debug('accounts');
            System.debug(accounts);
            insert accounts;
            Map<String, Id> accountNameToIdMap = accountNameToId(accounts);
            accountNameToIdMap.putAll(getExistedAccountIds(buckets));
            for (Contact con : newContacts) {
                if (contactAccounts.containsKey(con.SABA_Internal_ID__c)) {
                    con.AccountId = accountNameToIdMap.get(contactAccounts.get(con.SABA_Internal_ID__c));
                }
            }
            contactsToUpsert.addAll(newContacts);
            contactsToUpsert.sort();
            System.debug('contactsToUpsert');
            System.debug(contactsToUpsert);
            PHSS_ProcessUserProvisioning_BATCH.doContactUpsert(contactsToUpsert);
            for (Contact con : newContacts) {
                newUsers.get(con.SABA_Internal_ID__c).ContactId = con.Id;
            }
            List<User> allNewUsers = new List<User>();
            allNewUsers.addAll(newUsers.values());
            allNewUsers.addAll(usersToInsert);
            allNewUsers.sort();
            System.debug('allNewUsers');
            System.debug(allNewUsers);
            PHSS_ProcessUserProvisioning_BATCH.doUserInsert(allNewUsers);
            usersToUpdate.sort();
            System.debug('usersToUpdate');
            System.debug(usersToUpdate);
            PHSS_ProcessUserProvisioning_BATCH.doUserUpdate(usersToUpdate);
            List<User> processedUsers = new List<User>();
            processedUsers.addAll(newUsers.values());
            processedUsers.addAll(usersToUpdate);
            System.debug('processedUsers');
            System.debug(processedUsers);
            
            settings.Current_Bucket_Account_ID__c = accountNameToIdMap.get(currentBucket.name);
            upsert settings;
            System.debug('upsert settings');
            System.debug(settings);
            this.clear(userProvisioningData);
            this.processUsersMarkedAsResources(processedUsers, markedAsResources);
        } catch (PHSS_BatchHelper.DmlProvisioningException e) {
            Database.rollback(sp);
            System.debug('Exception:');
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            PHSS_ProcessUserProvisioning_BATCH.createLog(userProvisioningByUniqueValues, e, logs);
            this.isError = true;
            isException = true;
        } catch (Exception e) {
            Database.rollback(sp);
            System.debug('Exception:');
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            logs.add(PHSS_Logger.createLog().setException(e));
            isException = true;
        }
        if(isException) {
            this.numberOfErrors++;
            delete incorrectRecords;
        } else {
            this.numberOfSuccess += userProvisioningData.size();
        }
        PHSS_ProcessUserProvisioning_BATCH.processLogs(logs);
    }

    private static void processLogs(List<PHSS_Logger.Log> logs) {
        List<SObject> records = PHSS_Logger.logErrors(logs);
        Savepoint sp = Database.setSavepoint();
        try {
            delete records;
        } catch(Exception e) {
            Database.rollback(sp);
            System.debug('Exception:');
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
        }
    }

    private static void createLog(Map<String, PHSS_User_Provisioning__c> userProvisionings, PHSS_BatchHelper.DmlProvisioningException e, List<PHSS_Logger.Log> logs) {
        PHSS_User_Provisioning__c userProvisioning = null;
        if(userProvisionings.containsKey(e.getUniqueId())) {
            userProvisioning = userProvisionings.get(e.getUniqueId());
        } else if(userProvisionings.containsKey(e.getUsername())) {
            userProvisioning = userProvisionings.get(e.getUsername());
        }
        logs.add(PHSS_Logger.createLog().setException(e).setRecord(userProvisioning));
    }

    @TestVisible private static void doContactUpsert(List<Contact> contactsToUpsert) {
        List<DataBase.UpsertResult> results = Database.upsert(contactsToUpsert, Contact.Id.getDescribe().getSObjectField(), false);
        DataBase.UpsertResult result = null;
        for(Integer i = 0; i < results.size(); i++) {
            result = results.get(i);
            if(!result.isSuccess()) {
                PHSS_BatchHelper.DmlProvisioningException e = PHSS_BatchHelper.createException(result.getErrors());
                e.setIndex(i);
                e.setUniqueId(contactsToUpsert.get(i).SABA_Internal_ID__c);
                throw e;
            }
        }
    }

    @TestVisible private static void doUserInsert(List<User> allNewUsers) {
        List<DataBase.SaveResult> results = Database.insert(allNewUsers, false);
        DataBase.SaveResult result = null;
        for(Integer i = 0; i < results.size(); i++) {
            result = results.get(i);
            if(!result.isSuccess()) {
                User us = allNewUsers.get(i);
                PHSS_BatchHelper.DmlProvisioningException e = PHSS_BatchHelper.createException(result.getErrors());
                e.setIndex(i);
                e.setUniqueId(us.SABA_Internal_ID__c);
                e.setUserName(us.Username);
                throw e;
            }
        }
    }

    @TestVisible private static void doUserUpdate(List<User> usersToUpdate) {
        List<DataBase.SaveResult> results = Database.update(usersToUpdate, false);
        DataBase.SaveResult result = null;
        for(Integer i = 0; i < results.size(); i++) {
            result = results.get(i);
            if(!result.isSuccess()) {
                User us = usersToUpdate.get(i);
                PHSS_BatchHelper.DmlProvisioningException e = PHSS_BatchHelper.createException(result.getErrors());
                e.setIndex(i);
                e.setUniqueId(us.SABA_Internal_ID__c);
                e.setUserName(us.Username);
                throw e;
            }
        }
    }

    private static void setNewUserDetails(User usr, Id contactId, String username) {
        System.debug('begin setNewUserDetails');
        System.debug(usr);
        System.debug(contactId);
        System.debug(username);
        try {
            usr.CommunityNickname = usr.LastName.left(8) + '_' + PHSS_ProcessUserProvisioning_BATCH.getRandomSufix();
            usr.ContactId = contactId;
            usr.Username = username;
        } catch (Exception e) {
            System.debug('Exception:');
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
        }
    }

    private static void setUniqueValues(User usr, PHSS_User_Provisioning__c userProvisioning) {
        System.debug('begin setUniqueValues');
        System.debug(usr);
        System.debug(userProvisioning);
        try {
            usr.SABA_Internal_ID__c = setEmptyValue(userProvisioning.SABA_Internal_ID__c);
            usr.SABA_Person_Number__c = setEmptyValue(userProvisioning.SABA_Person_Number__c);
        } catch (Exception e) {
            System.debug('Exception:');
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
        }
    }

    private static String setEmptyValue(String value) {
        return value == null ? '' : value;
    }

    private static void setNewContactData(Contact con, PHSS_User_Provisioning__c userProvisioning) {
        System.debug('begin setNewContactData');
        System.debug(con);
        System.debug(userProvisioning);
        try {
            con.SABA_Internal_ID__c = userProvisioning.SABA_Internal_ID__c;
        } catch (Exception e) {
            System.debug('Exception:');
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
        }
    }

    private static User setUserData(User usr, PHSS_User_Provisioning__c userProvisioning) {
        System.debug('begin setUserData');
        System.debug(usr);
        System.debug(userProvisioning);
        try {
            usr.Firstname = PHSS_ProcessUserProvisioning_BATCH.setEmptyValue(userProvisioning.Firstname__c);
            usr.LastName = PHSS_ProcessUserProvisioning_BATCH.setEmptyValue(userProvisioning.Lastname__c);
            usr.Email = PHSS_ProcessUserProvisioning_BATCH.setEmptyValue(userProvisioning.Email__c);
            usr.Alias = usr.LastName.left(8);
            usr.Employee_ID__c = PHSS_ProcessUserProvisioning_BATCH.setEmptyValue(userProvisioning.Employee_ID__c);
            usr.City = PHSS_ProcessUserProvisioning_BATCH.setEmptyValue(userProvisioning.City__c);
            usr.Country = PHSS_ProcessUserProvisioning_BATCH.setEmptyValue(userProvisioning.Country__c);
            usr.State = PHSS_ProcessUserProvisioning_BATCH.setEmptyValue(userProvisioning.State__c);
            usr.PostalCode = PHSS_ProcessUserProvisioning_BATCH.setEmptyValue(userProvisioning.Zipcode__c);
            usr.Phone = PHSS_ProcessUserProvisioning_BATCH.setEmptyValue(userProvisioning.Main_Phone__c);
            usr.Street = PHSS_ProcessUserProvisioning_BATCH.setEmptyValue(PHSS_BatchHelper.buildString(new List<String>{
                userProvisioning.Address1__c,
                userProvisioning.Address2__c,
                userProvisioning.Address3__c
            }));
        } catch (Exception e) {
            System.debug('Exception:');
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
        }
        return usr;
    }

    private void setUserDefaults(User usr) {
        System.debug('begin setUserDefaults');
        System.debug(usr);
        try {
            usr.TimeZoneSidKey = this.defaults.Default_Timezone_Key__c;
            usr.LanguageLocaleKey = this.defaults.Default_Language_Key__c;
            usr.LocaleSidKey = this.defaults.Default_Locale_Key__c;
            usr.EmailEncodingKey = this.defaults.Default_Email_Encoding_Key__c;
            usr.ProfileId = this.profileId;
        } catch (Exception e) {
            System.debug('Exception:');
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
        }
    }

    private static Contact setContactData(Contact con, PHSS_User_Provisioning__c userProvisioning) {
        System.debug('begin setContactData');
        System.debug(con);
        System.debug(userProvisioning);
        try {
            con.FirstName = userProvisioning.Firstname__c;
            con.LastName = userProvisioning.Lastname__c;
        } catch (Exception e) {
            System.debug('Exception:');
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
        }
        return con;
    }

    private class GroupMembershipException extends Exception {}

    private void processUsersMarkedAsResources(List<User> processedUsers, Set<String> resourceUsers) {
        Map<String, Id> processedUserIds = new Map<String, Id>();
        for(User processedUser: processedUsers){
            processedUserIds.put(processedUser.SABA_Internal_ID__c, processedUser.Id);
        }
        for(String resourceUser: resourceUsers){
            if(processedUserIds.containsKey(resourceUser)){
                this.instructorMembership.add(processedUserIds.get(resourceUser));
            }
        }
    }

    private void enqueueJobs() {
        Map<Id, Set<Id>> memberships = new Map<Id, Set<Id>>();
        for(Id userId: this.instructorMembership){
            memberships.put(userId, new Set<Id>{this.groupId});
        }
        PHSS_AsyncExecution job = new PHSS_AsyncExecution();
        job.groupMemberships = memberships;
        job.usersToDeactivate = this.usersToDeactivation;
        job.usersToUpdateUsername = this.usernamesToUpdate;
        job.enqueueJob();
    }
}