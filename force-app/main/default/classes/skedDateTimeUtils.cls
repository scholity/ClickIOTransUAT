public class skedDateTimeUtils {
    
    public static final string DATE_FORMAT = 'MM/dd/yyyy';
    public static final string TIME_FORMAT = 'h:mma';
    public static final string DATE_TIME_FORMAT = 'MM/dd/yyyy hh:mm a';
    public static final string DATE_ISO_FORMAT = 'yyyy-MM-dd';
    public static final string DATE_TIME_ISO_FORMAT = '"yyyy-MM-ddThh:mm:ssZ"';

    public static Date getArcWeekStartDate(Date inputDate) {
        return inputDate.addDays(1).toStartOfWeek().addDays(-1);
    }
    
    public static DateTime toTimezone(DateTime input, string toTimezoneSidId) {
        return switchTimezone(input, UserInfo.getTimeZone().getID(), toTimezoneSidId);
    }
    
    public static DateTime switchTimezone(DateTime input, string fromTimezoneSidId, string toTimezoneSidId) {
        if (fromTimezoneSidId == toTimezoneSidId) {
            return input;
        }
        TimeZone fromTz = Timezone.getTimeZone(fromTimezoneSidId);
        Timezone toTz = Timezone.getTimeZone(toTimezoneSidId);
        integer offsetMinutes = fromTz.getOffset(input) - toTz.getOffset(input);
        offsetMinutes = offsetMinutes / 60000;
        input = addMinutes(input, offsetMinutes, toTimezoneSidId);
        return input;
    }
    
    public static DateTime addMinutes(DateTime input, integer minutes, string timezoneSidId) {
        DateTime result = input.addMinutes(minutes);
        Timezone tz = Timezone.getTimezone(timezoneSidId);
        integer inputOffset = tz.getOffset(input) / 60000;
        integer resultOffset = tz.getOffset(result) / 60000;
        result = result.addMinutes(inputOffset - resultOffset);
        
        return result;
    }
    
    public static DateTime addHours(DateTime input, integer hours, string timezoneSidId) {
        DateTime result = input.addHours(hours);
        Timezone tz = Timezone.getTimezone(timezoneSidId);
        integer inputOffset = tz.getOffset(input) / 60000;
        integer resultOffset = tz.getOffset(result) / 60000;
        result = result.addMinutes(inputOffset - resultOffset);
        
        return result;
    }
    
    public static DateTime addDays(DateTime input, integer days, string timezoneSidId) {
        DateTime result = input.addDays(days);
        Timezone tz = Timezone.getTimezone(timezoneSidId);
        integer inputOffset = tz.getOffset(input) / 60000;
        integer resultOffset = tz.getOffset(result) / 60000;
        result = result.addMinutes(inputOffset - resultOffset);
        
        return result;
    } 
    
    public static DateTime addMonths(DateTime input, integer months, string timezoneSidId) {
        DateTime result = input.addMonths(months);
        Timezone tz = Timezone.getTimezone(timezoneSidId);
        integer inputOffset = tz.getOffset(input) / 60000;
        integer resultOffset = tz.getOffset(result) / 60000;
        result = result.addMinutes(inputOffset - resultOffset);
        
        return result;
    } 
    
    public static DateTime addYears(DateTime input, integer years, string timezoneSidId) {
        DateTime result = input.addYears(years);
        Timezone tz = Timezone.getTimezone(timezoneSidId);
        integer inputOffset = tz.getOffset(input) / 60000;
        integer resultOffset = tz.getOffset(result) / 60000;
        result = result.addMinutes(inputOffset - resultOffset);
        
        return result;
    } 
    
    public static Date getDate(DateTime input, string timezoneSidId) {
        string dateIsoString = input.format(DATE_ISO_FORMAT, timezoneSidId);
        //return (Date)Json.deserialize('"' + dateIsoString + '"', Date.class);
        return getDateFromIsoString(dateIsoString);
    }

    public static Date getDateFromIsoString(string dateIsoString) {
        return (Date)Json.deserialize('"' + dateIsoString + '"', Date.class);
    }
    
    public static DateTime getStartOfDate(DateTime input, string timezoneSidId) {
        Date inputDate = getDate(input, timezoneSidId);
        return getStartOfDate(inputDate, timezoneSidId);
    }
    
    public static DateTime getStartOfDate(Date input, string timezoneSidId) {
        DateTime result = DateTime.newInstance(input, time.newInstance(0, 0, 0, 0));
        result = toTimezone(result, timezoneSidId);
        return result;
    }
    
    public static DateTime getEndOfDate(DateTime input, string timezoneSidId) {
        DateTime dateStart = getStartOfDate(input, timezoneSidId);
        return addDays(dateStart, 1, timezoneSidId);
    }
    
    public static DateTime getEndOfDate(Date input, string timezoneSidId) {
        DateTime dateStart = getStartOfDate(input, timezoneSidId);
        return addDays(dateStart, 1, timezoneSidId);
    }
    
    public static integer convertTimeNumberToMinutes(integer input) {
        return integer.valueOf(input / 100) * 60 + Math.mod(input, 100);
    }

    public static string getDurationText(decimal duration) {
        string totalDurationText = integer.valueOf(duration / 60) + 'h';
        integer minutes = Math.mod(integer.valueOf(duration), 60);
        if (minutes != 0) {
            totalDurationText += ' ' + minutes + 'm';
        }
        return totalDurationText;
    }
    
    public static Map<string, Set<Date>> getHolidays() {
        Map<string, Set<Date>> mapHolidays = new Map<string, Set<Date>>();
        Date currentDate = system.now().date().addDays(-1);//buffer for different timezone
        
        List<sked__Holiday__c> skedGlobalHolidays = [SELECT Id, sked__Start_Date__c, sked__End_Date__c
                                                     FROM sked__Holiday__c
                                                     WHERE sked__Global__c = TRUE
                                                     AND sked__End_Date__c >= :currentDate];
        List<sked__Holiday_Region__c> skedRegionHolidays = [SELECT Id, sked__Holiday__r.sked__Start_Date__c, sked__Holiday__r.sked__End_Date__c, 
                                                            sked__Region__c
                                                            FROM sked__Holiday_Region__c
                                                            WHERE sked__Holiday__r.sked__End_Date__c >= :currentDate];
        
        Set<Date> globalHolidays = new Set<Date>();
        for (sked__Holiday__c globalHoliday : skedGlobalHolidays) {
            Date tempDate = globalHoliday.sked__Start_Date__c;
            while (tempDate <= globalHoliday.sked__End_Date__c) {
                globalHolidays.add(tempDate);
                tempDate = tempDate.addDays(1);
            }
        }
        mapHolidays.put(skedConstants.HOLIDAY_GLOBAL, globalHolidays);
        
        for (sked__Holiday_Region__c regionHoliday : skedRegionHolidays) {
            Set<Date> regionHolidays;
            if (mapHolidays.containsKey(regionHoliday.sked__Region__c)) {
                regionHolidays = mapHolidays.get(regionHoliday.sked__Region__c);
            } else {
                regionHolidays = new Set<Date>();
            }
            
            Date tempDate = regionHoliday.sked__Holiday__r.sked__Start_Date__c;
            while (tempDate <= regionHoliday.sked__Holiday__r.sked__End_Date__c) {
                regionHolidays.add(tempDate);
                tempDate = tempDate.addDays(1);
            }
            
            if (!mapHolidays.containsKey(regionHoliday.sked__Region__c)) {
                mapHolidays.put(regionHoliday.sked__Region__c, regionHolidays);
            }
        }
        return mapHolidays;
    }

    public static Map<string, Set<skedModels.selectOption>> getHolidayOptions() {
        Map<string, Set<skedModels.selectOption>> mapHolidays = new Map<string, Set<skedModels.selectOption>>();
        Date currentDate = system.now().date().addDays(-1);//buffer for different timezone
        
        List<sked__Holiday__c> skedGlobalHolidays = [SELECT Id, Name, sked__Start_Date__c, sked__End_Date__c
                                                     FROM sked__Holiday__c
                                                     WHERE sked__Global__c = TRUE
                                                     AND sked__End_Date__c >= :currentDate];
        List<sked__Holiday_Region__c> skedRegionHolidays = [SELECT Id, sked__Holiday__r.Name, sked__Holiday__r.sked__Start_Date__c, sked__Holiday__r.sked__End_Date__c, 
                                                            sked__Region__c
                                                            FROM sked__Holiday_Region__c
                                                            WHERE sked__Holiday__r.sked__End_Date__c >= :currentDate];
        
        Set<skedModels.selectOption> globalHolidays = new Set<skedModels.selectOption>();
        for (sked__Holiday__c globalHoliday : skedGlobalHolidays) {
            Date tempDate = globalHoliday.sked__Start_Date__c;
            while (tempDate <= globalHoliday.sked__End_Date__c) {
                string dateIso = Json.serialize(tempDate).replace('"', '');
                skedModels.selectOption holidayOption = new skedModels.selectOption(dateIso, globalHoliday.Name);
                globalHolidays.add(holidayOption);
                tempDate = tempDate.addDays(1);
            }
        }
        mapHolidays.put(skedConstants.HOLIDAY_GLOBAL, globalHolidays);
        
        for (sked__Holiday_Region__c regionHoliday : skedRegionHolidays) {
            Set<skedModels.selectOption> regionHolidays;
            if (mapHolidays.containsKey(regionHoliday.sked__Region__c)) {
                regionHolidays = mapHolidays.get(regionHoliday.sked__Region__c);
            } else {
                regionHolidays = new Set<skedModels.selectOption>();
            }
            
            Date tempDate = regionHoliday.sked__Holiday__r.sked__Start_Date__c;
            while (tempDate <= regionHoliday.sked__Holiday__r.sked__End_Date__c) {
                string dateIso = Json.serialize(tempDate).replace('"', '');
                skedModels.selectOption regionHolidayOption = new skedModels.selectOption(dateIso, regionHoliday.sked__Holiday__r.Name);
                regionHolidays.add(regionHolidayOption);
                tempDate = tempDate.addDays(1);
            }
            
            if (!mapHolidays.containsKey(regionHoliday.sked__Region__c)) {
                mapHolidays.put(regionHoliday.sked__Region__c, regionHolidays);
            }
        }
        return mapHolidays;
    }

}