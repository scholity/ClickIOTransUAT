global class PHSS_ProcessCertProvisioning_BATCH implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
	private static final String CLASS_NAME = PHSS_ProcessCertProvisioning_BATCH.class.getName();
    private static final String SPACE = ' ';

    private String query;
	private Map<Id, Set<Id>> memberships;
	private List<Id> exGroupMembers;
    private Boolean isError;
    private Integer size;
    private Integer numberOfSuccess;
    private Integer numberOfErrors;
    private Integer numberOfNotProcessed;
    private PHSS_Custom_Metadata__mdt defaults;

	public static Boolean clearRecords = false;

	global static void run() {
        PHSS_BatchHelper.abortCertificationJob();
		if(PHSS_BatchHelper.shouldBeEnqueued(CLASS_NAME)) {
			Id newJobId = Database.executeBatch(new PHSS_ProcessCertProvisioning_BATCH(false));
		}
	}

    public static void scheduleCertificationProvisioning(Boolean isError) {
        String name = PHSS_BatchHelper.buildSchedulerName(PHSS_BatchHelper.SCHEDULER_NAME_CERTIFICATE);
        if(PHSS_BatchHelper.shouldBeScheduled(name)) {
            System.schedule(
                name,
                PHSS_BatchHelper.buildCronString(),
                new PHSS_ProcessCertProvisioning_BATCH(isError)
            );
        }
    }

    global void execute(SchedulableContext sc) {
        PHSS_ProcessCertProvisioning_BATCH.run();
    }

    private static void sendEmailNotification(Integer numberOfSuccess, Integer numberOfErrors, Integer numberOfNotProcessed) {
        List<PHSS_Custom_Metadata__mdt> configs = [SELECT Prevent_Certification_Provisioning_Email__c FROM PHSS_Custom_Metadata__mdt WHERE DeveloperName = 'PHSS_Instructors_Corner' LIMIT 1];
         if(configs.isEmpty() || !configs.get(0).Prevent_Certification_Provisioning_Email__c) {
            PHSS_EmailNotification.send(PHSS_EmailNotification.Type.Certification_Provisioning, numberOfSuccess, numberOfErrors, numberOfNotProcessed);
        }
    }

    private PHSS_ProcessCertProvisioning_BATCH(Boolean isError) {
        this.query = 'SELECT Id, SABA_Internal_ID__c, Certification_Name__c, Acquired_On__c, Certification_Version__c, Expired_On__c, Status__c, ' + 
            'SABA_Certificate_Number__c FROM PHSS_Certification_Provisioning__c';
        this.memberships = new Map<Id, Set<Id>>();
        this.exGroupMembers = new List<Id>();
        this.isError = isError;
        this.size = size;
        this.numberOfSuccess = 0;
        this.numberOfErrors = 0;
        this.numberOfNotProcessed = 0;
        this.defaults = PHSS_BatchHelper.getDefaults();
    }
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(this.query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		processCertificationProvisioning((List<PHSS_Certification_Provisioning__c>) scope);
	}
	
	global void finish(Database.BatchableContext BC) {
		this.enqueueJobs();
        PHSS_ProcessCertProvisioning_BATCH.sendEmailNotification(this.numberOfSuccess, this.numberOfErrors, this.numberOfNotProcessed);
        PHSS_ProcessUserProvisioning_BATCH.processRemainingRecords(this.isError);
	}

    private static Map<String, String> getCertificationMapping(){
        Map<String, String> certificationMapping = new Map<String, String>();
        for(PHSS_Custom_Certification_Mapping__mdt mapping: [SELECT Access_Level__c, Certification_Name__c FROM PHSS_Custom_Certification_Mapping__mdt]) {
            certificationMapping.put(mapping.Certification_Name__c, mapping.Access_Level__c);
        }
        return certificationMapping;
    }

    private static Map<String, Id> getUsers(List<PHSS_Certification_Provisioning__c> certifications){
        Set<String> userInternalIds = new Set<String>();
        for(PHSS_Certification_Provisioning__c certification: certifications) {
            userInternalIds.add(certification.SABA_Internal_ID__c);
        }
        Map<String, Id> users = new Map<String, Id>();
        for(User us: [SELECT Id, SABA_Internal_ID__c FROM User WHERE SABA_Internal_ID__c IN :userInternalIds]) {
            users.put(us.SABA_Internal_ID__c, us.Id);
        }
        return users;
    }

    private static Map<String, PHSS_Instructor_Certification__c> getCertifications(List<PHSS_Certification_Provisioning__c> certifications){
        Set<String> certificationNumbers = new Set<String>();
        for(PHSS_Certification_Provisioning__c certification: certifications) {
            certificationNumbers.add(certification.SABA_Certificate_Number__c);
        }
        Map<String, PHSS_Instructor_Certification__c> instCerts = new Map<String, PHSS_Instructor_Certification__c>();
        for(PHSS_Instructor_Certification__c cert: [SELECT Id, Status__c, SABA_Internal_ID__c, Acquired_On__c, Certification_Name__c, Certification_Version__c, SABA_Certificate_Number__c
                FROM
                    PHSS_Instructor_Certification__c
                WHERE
                    SABA_Certificate_Number__c IN :certificationNumbers
                ])
        {
            instCerts.put(cert.SABA_Certificate_Number__c, cert);
        }
        return instCerts;
    }

    private static Map<String, Id> getGroups(List<String> groupNames){
        Map<String, Id> groups = new Map<String, Id>();
        for(Group gr: [SELECT Id, Name FROM Group WHERE Name IN :groupNames]) {
            groups.put(gr.Name, gr.Id);
        }
        return groups;
    }

    private class Membership {
        public String groupName;
        public String certificationNumber;
        public Boolean toCreate;

        public Membership(String groupName, String certificationNumber, Boolean toCreate){
            this.groupName = groupName;
            this.certificationNumber = certificationNumber;
            this.toCreate = toCreate;
        }
    }

    private static Map<Id, Set<String>> getUsersCertifications(Map<String, Id> users){
        Map<Id, Set<String>> userCertifications = new Map<Id, Set<String>>();
        Set<String> userSabaIds = users.keySet();
        for(Id userId: users.values()){
            userCertifications.put(userId, new Set<String>());
        }
        for(PHSS_Instructor_Certification__c certification: [SELECT Certification_Name__c, SABA_Internal_ID__c FROM PHSS_Instructor_Certification__c WHERE SABA_Internal_ID__c IN :userSabaIds]){
            userCertifications.get(users.get(certification.SABA_Internal_ID__c)).add(certification.Certification_Name__c);
        }
        return userCertifications;
    }

    private void processCertificationProvisioning(List<PHSS_Certification_Provisioning__c> certifications){
        Map<String, String> certificationMapping = getCertificationMapping();

        Map<String, Id> users = getUsers(certifications);
        Map<String, PHSS_Instructor_Certification__c> instCerts = getCertifications(certifications);
        Map<String, Id> groups = getGroups(certificationMapping.values());

        List<PHSS_Instructor_Certification__c> instructorCertificationsToUpsert = new List<PHSS_Instructor_Certification__c>();
        Map<Id, List<Membership>> membershipsToProcessByUser = new Map<Id, List<Membership>>();
        Map<String, PHSS_Certification_Provisioning__c> certsByNumber = new Map<String, PHSS_Certification_Provisioning__c>();
        List<PHSS_Logger.Log> logs = new List<PHSS_Logger.Log>();
        for(PHSS_Certification_Provisioning__c certification: certifications) {
            certsByNumber.put(certification.SABA_Certificate_Number__c, certification);
            Id userId = users.containsKey(certification.SABA_Internal_ID__c) ? users.get(certification.SABA_Internal_ID__c) : null;
            if(userId == null){
                logs.add(PHSS_Logger.createLog().setRecord(certification).setMessage(this.defaults.Certification_Error_Message__c));
                this.numberOfNotProcessed++;
                continue;
            }
            Boolean toCreate = null;
            if ((certification.Status__c.equalsIgnoreCase('Revoked') || certification.Status__c.equalsIgnoreCase('Expired')) && instCerts.containsKey(certification.SABA_Certificate_Number__c)) {
                instructorCertificationsToUpsert.add(setCertificationDetails(instCerts.get(certification.SABA_Certificate_Number__c), certification, false));
                toCreate = false;
            } else if (certification.Status__c.equalsIgnoreCase('Acquired')) {
                Boolean isOld = instCerts.containsKey(certification.SABA_Certificate_Number__c);
                PHSS_Instructor_Certification__c instCert = setCertificationDetails(
                    isOld ? instCerts.get(certification.SABA_Certificate_Number__c) : new PHSS_Instructor_Certification__c(),
                    certification,
                    !isOld
                );
                instCert.User__c = userID;
                instCert.OwnerId = userID;
                instructorCertificationsToUpsert.add(instCert);
                toCreate = true;
            }
            if(toCreate != null) {
                Membership userMembership = new Membership(
                    certificationMapping.get(certification.Certification_Name__c),
                    certification.SABA_Certificate_Number__c,
                    toCreate
                );
                if(membershipsToProcessByUser.containsKey(userId)){
                    membershipsToProcessByUser.get(userId).add(userMembership);
                } else {
                    membershipsToProcessByUser.put(userId, new List<Membership>{userMembership});
                }
            }
        }
        Map<Id, Set<String>> userCertifications = getUsersCertifications(users);
        Map<Id, Set<Id>> groupMembershipsToRemoveByUser = new Map<Id, Set<Id>>();

        for(Id userId: membershipsToProcessByUser.keySet()) {
            Map<String, Integer> access = new Map<String, Integer>();
            for(String certification: userCertifications.get(userId)) {
                String groupName = certificationMapping.get(certification);
                if(access.containsKey(groupName)) {
                    access.put(groupName, access.get(groupName) + 1);
                } else {
                    access.put(groupName, 1);
                }
            }
            for(Membership userMembership: membershipsToProcessByUser.get(userId)) {
                if(userMembership.toCreate) {
                    if(access.containsKey(userMembership.groupName)) {
                        access.put(userMembership.groupName, access.get(userMembership.groupName) + 1);
                    } else {
                        access.put(userMembership.groupName, 1);
                    }
                } else {
                    if(access.containsKey(userMembership.groupName)) {
                        access.put(userMembership.groupName, access.get(userMembership.groupName) - 1);
                    } else {
                        access.put(userMembership.groupName, -1);
                    }
                }
            }           
            if(!groupMembershipsToRemoveByUser.containsKey(userId)) {
                groupMembershipsToRemoveByUser.put(userId, new Set<Id>());
            }
            if(!this.memberships.containsKey(userId)) {
                this.memberships.put(userId, new Set<Id>());
            }
            for(String groupName: access.keySet()) {
                if(access.get(groupName) < 0) {
                    groupMembershipsToRemoveByUser.get(userId).add(certificationMapping.get(groupName));
                } else if(!userCertifications.get(userId).contains(groupName)) {
                    this.memberships.get(userId).add(groups.get(groupName));
                }
            }
        }
        Set<Id> exGroupMemberIds = groupMembershipsToRemoveByUser.keySet();
        Set<Id> groupIds = new Set<Id>(groups.values());
        for(GroupMember gm: [SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHERE UserOrGroupId IN :exGroupMemberIds]){
            if(groupMembershipsToRemoveByUser.get(gm.UserOrGroupId).contains(gm.GroupId)) {
                this.exGroupMembers.add(gm.Id);
            }
        }
        Savepoint sp = Database.setSavepoint();
        Boolean isException = false;
        try{
            System.debug('Certifications: ' + String.valueOf(instructorCertificationsToUpsert));
            PHSS_ProcessCertProvisioning_BATCH.doUpsert(instructorCertificationsToUpsert);
            clear(certifications);
        } catch (PHSS_BatchHelper.DmlProvisioningException e) {
            Database.rollback(sp);
            System.debug('Exception:');
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            PHSS_ProcessCertProvisioning_BATCH.createLog(certsByNumber, e, logs);
            this.isError = true;
            isException = true;
        } catch(Exception e) {
            Database.rollback(sp);
            System.debug('Exception:');
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            logs.add(PHSS_Logger.createLog().setException(e));
            isException = true;
        }
        if(isException) {
            this.numberOfErrors++;
        } else {
            this.numberOfSuccess += certifications.size();
        }
        PHSS_ProcessCertProvisioning_BATCH.processLogs(logs);
    }

    private static void createLog(Map<String, PHSS_Certification_Provisioning__c> certsByNumber, PHSS_BatchHelper.DmlProvisioningException e, List<PHSS_Logger.Log> logs) {
        PHSS_Certification_Provisioning__c certificate = null;
        if(certsByNumber.containsKey(e.getUniqueId())) {
            certificate = certsByNumber.get(e.getUniqueId());
        }
        logs.add(PHSS_Logger.createLog().setException(e).setRecord(certificate));
    }

    @TestVisible private static void doUpsert(List<PHSS_Instructor_Certification__c> instructorCertificationsToUpsert) {
        List<DataBase.UpsertResult> results = Database.upsert(instructorCertificationsToUpsert, PHSS_Instructor_Certification__c.Id.getDescribe().getSObjectField(), false);
        DataBase.UpsertResult result = null;
        for(Integer i = 0; i < results.size(); i++) {
            result = results.get(i);
            if(!result.isSuccess()) {
                PHSS_BatchHelper.DmlProvisioningException e = PHSS_BatchHelper.createException(result.getErrors());
                e.setIndex(i);
                e.setUniqueId(instructorCertificationsToUpsert.get(i).SABA_Certificate_Number__c);
                throw e;
            }
        }
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

    private static PHSS_Instructor_Certification__c setCertificationDetails(PHSS_Instructor_Certification__c certification, PHSS_Certification_Provisioning__c certificationProvisioning, Boolean isNew){
        certification.Name = certificationProvisioning.Certification_Name__c;
        certification.Acquired_On__c = certificationProvisioning.Acquired_On__c;
        certification.Certification_Name__c = certificationProvisioning.Certification_Name__c;
        certification.Certification_Version__c = certificationProvisioning.Certification_Version__c;
        certification.Expired_On__c = certificationProvisioning.Expired_On__c;
        certification.Status__c = certificationProvisioning.Status__c;
        if(isNew){
            certification.SABA_Internal_ID__c = certificationProvisioning.SABA_Internal_ID__c;
            certification.SABA_Certificate_Number__c = certificationProvisioning.SABA_Certificate_Number__c;
        }
        return certification;
    }

    private static void clear(List<PHSS_Certification_Provisioning__c> certifications) {
        List<PHSS_Custom_Metadata__mdt> configs = [SELECT CertificationProvisioningTriggerDebug__c FROM PHSS_Custom_Metadata__mdt WHERE DeveloperName = 'PHSS_Instructors_Corner' LIMIT 1];
         if(configs.isEmpty() || !configs.get(0).CertificationProvisioningTriggerDebug__c) {
            delete certifications;
        }
    }

    private void enqueueJobs(){
        System.debug('New memberships: ' + String.valueOf(this.memberships));
        System.debug('Exmemberships: ' + String.valueOf(this.exGroupMembers));
        PHSS_AsyncExecution job = new PHSS_AsyncExecution();
        job.groupMemberships = this.memberships;
        job.exGroupMemberIds = this.exGroupMembers;
        job.enqueueJob();
    }
}