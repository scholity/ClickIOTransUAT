public with sharing class PHSS_EmailNotification {
	private static final Integer NUMBER_OF_EMAILS = 1;
	private static final String MISSING_EMAIL_DETAILS = 'PHSS_Email_Notification__mdt for selected email type doesn\'t exist.';
	private static final String DELIMETER = '  ';

	public enum Type {
		User_Provisioning, Certification_Provisioning
	}

	public static void send(final PHSS_EmailNotification.Type emailType, final Integer numberOfSuccess, final Integer numberOfErrors, final Integer numberOfNotProcessed) {
		try {
			Messaging.reserveSingleEmailCapacity(PHSS_EmailNotification.NUMBER_OF_EMAILS);
			PHSS_Email_Notification__mdt details = PHSS_EmailNotification.getEmailDetails(emailType.name());
			if(details == null) {
				throw new EmailNotificationException(PHSS_EmailNotification.MISSING_EMAIL_DETAILS);
			}
			Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {PHSS_EmailNotification.buildEmail(details, numberOfSuccess, numberOfErrors, numberOfNotProcessed)});
		} catch(Exception e) {
			System.debug('Email exception:');
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            System.debug(e.getTypeName());
		}
	}

	private static PHSS_Email_Notification__mdt getEmailDetails(String metadataDeveloperName) {
		List<PHSS_Email_Notification__mdt> details = [
			SELECT Body__c, Subject__c, Receivers__c, CC_Receivers__c, Error_Message__c, Not_Processed_Message__c, Success_Message__c
			FROM PHSS_Email_Notification__mdt
			WHERE DeveloperName = :metadataDeveloperName
			LIMIT 1
		];
		return details.isEmpty() ? null : details.get(0);
	}

	private static String buildMessageLine(String baseMessage, Integer size) {
		String message = '';
		if(String.isNotBlank(baseMessage)) {
			message += baseMessage;
		}
		if(size != null) {
			message += String.valueOf(size);
		}
		return message;
	}

	private static String buildMessageLine(String baseMessage) {
		return PHSS_EmailNotification.buildMessageLine(baseMessage, null);
	}

	private static List<String> getReceivers(String receiversCsv) {
		if(String.isBlank(receiversCsv)) {
			return new List<String>();
		} else {
			Set<String> filtred = new Set<String>();
			for(String receiver: receiversCsv.split(',')) {
				if(String.isNotBlank(receiver)){
	                filtred.add(receiver.trim());
	            }
			}
			return new List<String>(filtred);
		}
	}

	private static String buildBody(PHSS_Email_Notification__mdt details, Integer numberOfSuccess, Integer numberOfErrors, Integer numberOfNotProcessed) {
		List<String> lines = new List<String>();
		lines.add(PHSS_EmailNotification.buildMessageLine(details.Body__c));
		lines.add(PHSS_EmailNotification.buildMessageLine(details.Success_Message__c, numberOfSuccess));
		lines.add(PHSS_EmailNotification.buildMessageLine(details.Error_Message__c, numberOfErrors));
		lines.add(PHSS_EmailNotification.buildMessageLine(details.Not_Processed_Message__c, numberOfNotProcessed));
		return String.join(lines, '\n');
	}

	private static Messaging.SingleEmailMessage buildEmail(PHSS_Email_Notification__mdt details, Integer numberOfSuccess, Integer numberOfErrors, Integer numberOfNotProcessed) {
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		List<String> receivers = PHSS_EmailNotification.getReceivers(details.Receivers__c);
		List<String> ccReceivers = PHSS_EmailNotification.getReceivers(details.CC_Receivers__c);
		System.debug(receivers);
		System.debug(ccReceivers);
		mail.setToAddresses(receivers);
		if(!ccReceivers.isEmpty()) {
			mail.setCcAddresses(ccReceivers);
		}
		mail.setBccSender(false);
		mail.setUseSignature(true);
		mail.setSubject(String.join(new List<String>{details.Subject__c, Datetime.now().format()}, PHSS_EmailNotification.DELIMETER));
		mail.setPlainTextBody(buildBody(details, numberOfSuccess, numberOfErrors, numberOfNotProcessed));
		return mail;
	}

	public class EmailNotificationException extends Exception {}
}