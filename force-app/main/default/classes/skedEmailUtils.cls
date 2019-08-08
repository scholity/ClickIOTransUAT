public class skedEmailUtils {

    public static boolean useSchedulingEmail;

    public static Map<string, Id> map_template_Name_Id;

    public static Messaging.SingleEmailMessage setTemplatedEmail(String[] toRecipients, String templateApiName, ID targetObjId, Id whatId, ID orgWideEmailId, Boolean saveAsActivity, Attachment[] attachList ) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
        Id templateId;  
        try {
            if (map_template_Name_Id == null) {
                map_template_Name_Id = new Map<string, Id>();
            }
            if (map_template_Name_Id.containsKey(templateApiName)) {
                templateId = map_template_Name_Id.get(templateApiName);
            }
            else {
                templateId = [SELECT id, name FROM EmailTemplate WHERE developername = :templateApiName].id;
                map_template_Name_Id.put(templateApiName, templateId);
            }
        }
        catch (Exception e) {
            return NULL;
        }
        
        email.setToAddresses(toRecipients);
        
        email.setTargetObjectId(targetObjId);
        if (whatId != NULL) {
            email.setWhatId(whatId);
        }
        
        email.setorgWideEmailAddressId(orgWideEmailId);
        
        email.setTemplateId(templateId);
        email.setSaveAsActivity(saveAsActivity);
        System.debug(LoggingLevel.INFO,'** entered sendTemplatedEmail, to:' + toRecipients +  ' templateId:' + templateId + ' tagetObjId:' + targetObjId +
                     ' whatId:' + whatId + ' orgWideEmailId: ' + orgWideEmailId);
        try {
            return email;
        }
        catch (EmailException e) {
            return null;
        }
    }

    public static void sendJobNotification(Set<Id> allocationIds) {
        List<sked__Job_Allocation__c> skedAllocations = [SELECT Id, sked__Status__c, sked__Resource__c, sked__Resource__r.sked__User__c, 
                                                         sked__Resource__r.sked__Email__c, sked__Job__r.sked__Recurring_Schedule__c
                                                         FROM sked__Job_Allocation__c
                                                         WHERE Id IN :allocationIds
                                                         AND sked__Resource__r.sked__User__c != NULL
                                                         AND sked__Resource__r.sked__Email__c != NULL];

        Set<string> set_processed_resource_recurring = new Set<string>();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();

        Id orgWideEmailId;

        if (useSchedulingEmail == true) {
            string fromAddress = getSchedulingEmail();
            if (!String.isBlank(fromAddress)) {
                List<OrgWideEmailAddress> orgEmailResult = [SELECT Id, Address 
                                                            FROM OrgWideEmailAddress
                                                            WHERE Address =: fromAddress];
                if (orgEmailResult != NULL && orgEmailResult.size() > 0) {
                    OrgWideEmailAddress fromAddressEmail = orgEmailResult.get(0);
                    orgWideEmailId = fromAddressEmail.Id;
                }
            }
        }

        for (sked__Job_Allocation__c skedAllocation : skedAllocations) {
            string templateName;
            if (skedAllocation.sked__Status__c == skedConstants.JOB_ALLOCATION_STATUS_DELETED) {
                templateName = 'sked_Job_Cancellation_Notification_Email';
            }
            else {
                continue;
            }
            
            List<String> toList = new List<String>();

            toList.add(skedAllocation.sked__Resource__r.sked__Email__c);

            Messaging.SingleEmailMessage email = setTemplatedEmail(toList, templateName, 
               skedAllocation.sked__Resource__r.sked__User__c, skedAllocation.Id, orgWideEmailId, false, null);
            if (email != NULL) {
                emailList.add(email);
            }
        }
        if (emailList.size() > 0) {
            Messaging.sendEmail(emailList);
        }
    }

    public static string getSchedulingEmail() {
        sked_Admin_Setting__c skedSetting = sked_Admin_Setting__c.getOrgDefaults();
        return skedSetting.Scheduling_Email__c;
    }

}