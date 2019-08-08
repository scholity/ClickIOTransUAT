@isTest
public class skedResourceReport_Test {
	
    static testmethod void mainTest() {
        Date nextMonthStartDate = system.today().toStartOfMonth().addMonths(1);
        
        Date startDate = nextMonthStartDate.addDays(7).toStartOfWeek();
        DateTime startTime = DateTime.newInstance(startDate, time.newInstance(0, 0, 0, 0));
        
        Date nextWeekStartDate = startDate.addDays(7);
        DateTime nextWeekStartTime = DateTime.newInstance(nextWeekStartDate, time.newInstance(0, 0, 0, 0));
        
        map<string, sObject> mapTestData = skedDataSetup.setupFullServiceTestData();
        
        Test.startTest();
        
        skedResourceReportController.getConfigData();
        
        skedResourceReportController.reportCriteria criteria = new skedResourceReportController.reportCriteria();
        criteria.startDateStr = startTime.format(skedDateTimeUtils.DATE_ISO_FORMAT);
        criteria.endDateStr = nextWeekStartTime.format(skedDateTimeUtils.DATE_ISO_FORMAT);
        
        skedResourceReportController.runReport(criteria);
        
        Test.stopTest();
    }
    
}