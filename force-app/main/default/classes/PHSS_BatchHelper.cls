public with sharing class PHSS_BatchHelper {
	private static final Set<String> CORRECT_STATUSES = new Set<String>{'Aborted', 'Completed', 'Failed'};
    private static final String BATCH_TYPE = 'Batch Apex'; 
	private static final String SEPARATOR = ',';
	private static final Integer ADDICTIONAL_MINUTS = 5;
	private static final String SPACE = ' ';
    private static final String TEST_DEFAULTS_NAME = 'PHSS_Instructors_Corner_Test';
    private static final String DEFAULTS_NAME = 'PHSS_Instructors_Corner';

    public static final String DELAYED_BATCH_NAME = 'Delayed provisioning';
    public static final String SCHEDULER_NAME = 'Dailly provisioning';
    public static final String SCHEDULER_NAME_CERTIFICATE = 'Dailly certification provisioning';

    public static Boolean shouldBeEnqueued(String className) {
    	return Test.isRunningTest() || [SELECT Id FROM AsyncApexJob WHERE ApexClassId IN (SELECT Id FROM ApexClass WHERE Name = :className) AND Status NOT IN :CORRECT_STATUSES AND JobType = :BATCH_TYPE].isEmpty();
    }

    public static Boolean shouldBeScheduled(String jobName) {
    	Datetime now = Datetime.now();
    	return Test.isRunningTest() || [SELECT Id, StartTime, NextFireTime, EndTime FROM CronTrigger WHERE CronJobDetailId IN (SELECT Id FROM CronJobDetail WHERE Name = :jobName) AND NextFireTime >= :now].isEmpty();
    }

    public static void abortJob(String jobName) {
        for(CronTrigger job: [SELECT Id, StartTime, NextFireTime, EndTime FROM CronTrigger WHERE CronJobDetailId IN (SELECT Id FROM CronJobDetail WHERE Name = :jobName)]) {
            System.abortJob(job.Id);
        }
    }

    public static void abortDelayedJob() {
        PHSS_BatchHelper.abortJob(DELAYED_BATCH_NAME);
    }

    public static void abortCertificationJob() {
        PHSS_BatchHelper.abortJob(SCHEDULER_NAME_CERTIFICATE);
    }

    public class DmlProvisioningException extends Exception {
        private Integer index;
        private String uniqueId;
        private String username;

        public void setIndex(Integer index) {
            this.index = index;
        }

        public void setUniqueId(String uniqueId) {
            this.uniqueId = uniqueId;
        }

        public void setUsername(String userName) {
            this.username = username;
        }

        public Integer getIndex() {
            return this.index;
        }

        public String getUniqueId() {
            return this.uniqueId;
        }

        public String getUsername() {
            return this.username;
        }
    }

    public static String buildString(List<String> values){
        List<String> filtred = new List<String>();
        for(String value: values){
            if(String.isNotBlank(value)){
                filtred.add(value);
            }
        }
        return String.join(filtred, PHSS_BatchHelper.SEPARATOR);
    }

    public static PHSS_BatchHelper.DmlProvisioningException createException(List<Database.Error> errors) {
        Set<String> errorMessages = new Set<String>();
        for(Database.Error err: errors) {
            errorMessages.add(err.getMessage());
        }
        return new PHSS_BatchHelper.DmlProvisioningException(PHSS_BatchHelper.buildString(errorMessages));
    }

    public static String buildString(Set<String> values) {
        return PHSS_BatchHelper.buildString(new List<String>(values));
    }

    public static String buildCronString() {
    	Datetime future = Datetime.now().addMinutes(PHSS_BatchHelper.ADDICTIONAL_MINUTS);
        List<String> data = new List<String>();
        data.add(String.valueOf(future.second()));
        data.add(String.valueOf(future.minute()));
        data.add(String.valueOf(future.hour()));
        data.add(String.valueOf(future.day()));
        data.add(String.valueOf(future.month()));
        data.add('?');
        data.add(String.valueOf(future.year()));
        return String.join(data, PHSS_BatchHelper.SPACE);
    }

    private static PHSS_Custom_Metadata__mdt getCustomMetadata(String developerName) {
        return [
                    SELECT
                    Bucket_Account_Name_Prefix__c, Default_Email_Encoding_Key__c, Default_Language_Key__c, Default_Locale_Key__c,
                    Default_Timezone_Key__c, Maximum_Contacts_Per_Account__c, ProfileName__c, Marked_As_Resource_Group_Name__c, UserProvisioningTriggerDebug__c, Username_Suffix__c,
                    Certification_Error_Message__c, User_Error_Message__c
                    FROM
                    PHSS_Custom_Metadata__mdt
                    WHERE DeveloperName = :developerName
                    LIMIT 1];
    }

    public static PHSS_Custom_Metadata__mdt getDefaults() {
        return PHSS_BatchHelper.getCustomMetadata(Test.isRunningTest() ? PHSS_BatchHelper.TEST_DEFAULTS_NAME : PHSS_BatchHelper.DEFAULTS_NAME);
    }

    public static String buildSchedulerName(String name) {
        return Test.isRunningTest() ? (name + PHSS_Utility.getRandomString(10)) : name;
    }
}