public with sharing class PHSS_Logger {
	public static List<SObject> logErrors(List<PHSS_Logger.Log> logs) {
		Savepoint sp = Database.setSavepoint();
		try {
			insert PHSS_Logger.processLogs(logs);
		} catch(Exception e) {
			Database.rollback(sp);
			System.debug(e.getMessage());
			System.debug(e.getStackTraceString());
		}
		return PHSS_Logger.getRecords(logs);
	}

	public static PHSS_Logger.Log createLog() {
		return new PHSS_Logger.Log();
	}

	private static List<SObject> getRecords(List<PHSS_Logger.Log> logs) {
		List<SObject> records = new List<SObject>();
		SObject record = null;
		for(PHSS_Logger.Log particularLog: logs) {
			record = particularLog.getRecord();
			if(record != null) {
				records.add(record);
			}
		}
		return records;
	}

	public class Log {
		private Exception e;
		private String message;
		private SObject record;

		public Log() {}

		public PHSS_Logger.Log setException(Exception e) {
			this.e = e;
			return this;
		}

		public PHSS_Logger.Log setRecord(SObject record) {
			this.record = record;
			return this;
		}

		public PHSS_Logger.Log setMessage(String message) {
			this.message = message;
			return this;
		}

		public Exception getException() {
			return this.e;
		}

		public SObject getRecord() {
			return this.record;
		}

		public String getMessage() {
			return this.message;
		}
	}

	private static List<PHSS_Error_Logger__c> processLogs(List<PHSS_Logger.Log> logs) {
		List<PHSS_Error_Logger__c> logsData = new List<PHSS_Error_Logger__c>();
		for(PHSS_Logger.Log particularLog: logs) {
			logsData.add(PHSS_Logger.buildErrorLog(particularLog));
		}
		return logsData;
	}

	private static PHSS_Error_Logger__c buildErrorLog(PHSS_Logger.Log particularLog) {
		PHSS_Error_Logger__c errorLogger = new PHSS_Error_Logger__c();
		Exception e = particularLog.getException();
		SObject so = particularLog.getRecord();
		if(e != null) {
			errorLogger.Message__c = e.getMessage();
			errorLogger.Stack_Trace__c = e.getMessage();
		} else {
			errorLogger.Message__c = particularLog.getMessage();
		}
		if(so != null) {
			errorLogger.Record__c = JSON.serialize(so);
			errorLogger.Formatted_Record__c = JSON.serializePretty(so);
		}
		return errorLogger;
	}
}