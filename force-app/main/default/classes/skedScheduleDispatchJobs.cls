global class skedScheduleDispatchJobs implements Schedulable {

	global void execute(SchedulableContext sc) {
		DateTime currentTime = system.now();
		sked_Admin_Setting__c skedSetting = sked_Admin_Setting__c.getOrgDefaults();
		integer autoDispatchDuration = skedSetting.Auto_Dispatch_Duration__c == NULL ? 60 : integer.valueOf(skedSetting.Auto_Dispatch_Duration__c);
		DateTime autoDispatchThreshold = skedDateTimeUtils.addDays(currentTime, autoDispatchDuration, UserInfo.getTimeZone().getID());

		List<sked__Job__c> jobsToDispatch = [SELECT Id, sked__Type__c, sked__Start__c,
											(SELECT Id
									     	 FROM sked__Job_Allocations__r
										     WHERE sked__Status__c != :skedConstants.JOB_ALLOCATION_STATUS_DELETED)
											FROM sked__Job__c
											WHERE sked__Job_Status__c = :skedConstants.JOB_STATUS_PENDING_DISPATCH
											AND Dispatch__c = TRUE
											AND sked__Start__c < :autoDispatchThreshold
											AND sked__Finish__c > :currentTime];
		if (!jobsToDispatch.isEmpty()) {
			skedEmailUtils.useSchedulingEmail = true;
			
			List<sked__Job_Allocation__c> allocationsToUpdate = new List<sked__Job_Allocation__c>();
			for (sked__Job__c job : jobsToDispatch) {
				job.sked__Job_Status__c = skedConstants.JOB_STATUS_DISPATCHED;
				for (sked__Job_Allocation__c allocation : job.sked__Job_Allocations__r) {
					allocation.sked__Status__c = skedConstants.JOB_ALLOCATION_STATUS_DISPATCHED;
					allocationsToUpdate.add(allocation);
				}
			}
			update jobsToDispatch;
			if (!allocationsToUpdate.isEmpty()) {
				update allocationsToUpdate;
			}
		}
	}

}