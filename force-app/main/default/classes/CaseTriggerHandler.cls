public without sharing class CaseTriggerHandler extends TriggerHandler {
    private Set<String> weekdays = new Set<String> {'Mon', 'Tue', 'Wed', 'Thu', 'Fri'};
    private Time startTime = Time.newInstance(7, 30, 0, 0);
    private Time endTime = Time.newInstance(22, 0, 0, 0);
    private Time satEndTime = Time.newInstance(20, 0, 0, 0);


    public override void beforeInsert() {
        getResponseTrackingUpdates();
    }

    public override void beforeUpdate() {
        getResponseTrackingUpdates();
    }

    private void getResponseTrackingUpdates() {
        Id socialCaseId = [SELECT Id From RecordType Where SObjectType = 'Case' And DeveloperName = 'Social_Case' Limit 1][0].Id;

        for (Case c : (List<Case>) Trigger.new) {
            if (c.RecordTypeId == socialCaseId) {
                if (c.First_Customer_Post_Date_Time__c != null &&
                        c.First_ARC_Response_Date_Time__c != null &&
                        c.First_Response_Time_Minutes__c == null) {
                    c.First_Response_Time_Minutes__c = calculateResponseTime_Minutes(c.First_Customer_Post_Date_Time__c, c.First_ARC_Response_Date_Time__c);
                }

                if (c.Second_Customer_Post_Date_Time__c != null &&
                        c.Second_ARC_Response_Date_Time__c != null &&
                        c.Second_Response_Time_Minutes__c == null) {
                    c.Second_Response_Time_Minutes__c = calculateResponseTime_Minutes(c.Second_Customer_Post_Date_Time__c, c.Second_ARC_Response_Date_Time__c);
                }

                if (c.Third_Customer_Post_Date_Time__c != null &&
                        c.Third_ARC_Response_Date_Time__c != null &&
                        c.Third_Response_Time_Minutes__c == null) {
                    c.Third_Response_Time_Minutes__c = calculateResponseTime_Minutes(c.Third_Customer_Post_Date_Time__c, c.Third_ARC_Response_Date_Time__c);
                }
            }
        }
    }

    private Integer calculateResponseTime_Minutes(Datetime postDatetime, Datetime responseDatetime) {
        Datetime calculatedPostTime = calculatePostTime(postDatetime);
        Datetime calculatedResponseTime = calculateResponseTime(responseDatetime);

        return Integer.valueOf((calculatedResponseTime.getTime() - calculatedPostTime.getTime()) / 1000 / 60);
    }

    private Datetime calculatePostTime(Datetime postDatetime) {
        String postDay = postDatetime.format('EEE');
        Time postTime = postDatetime.time();
        Datetime adjustedDatetime = Datetime.newInstance(postDatetime.date(), postTime);

        if (weekdays.contains(postDay)) {
            if (postTime < startTime) {//M-F prior to working hours, move to todays start time
                adjustedDatetime = Datetime.newInstance(postDatetime.date(), startTime);
            } else if (postTime > endTime) {//M-F after working hours, move to tomorrow's start time (7:30am)
                adjustedDatetime = Datetime.newInstance(postDatetime.date().addDays(1), startTime);
            }
        } else if (postDay == 'Sat') {
            if (postTime < startTime) {//Sat prior to start time => Saturday start time
                adjustedDatetime = Datetime.newInstance(postDatetime.date(), startTime);
            } if (postTime > satEndTime) {//Sat after end time => move to start of monday
                adjustedDatetime = Datetime.newInstance(postDatetime.date().addDays(2), startTime);
            }
        } else {//Sunday, set to monday at start time
            adjustedDatetime = Datetime.newInstance(postDatetime.date().addDays(1), startTime);
        }

        return adjustedDatetime;
    }

    private Datetime calculateResponseTime(Datetime responseDatetime) {
        String responseDay = responseDatetime.format('EEE');
        Time responseTime = responseDatetime.time();
        Datetime adjustedDatetime = Datetime.newInstance(responseDatetime.date(), responseTime);

        if (responseDay == 'Mon') {
            if (responseTime < startTime) {//monday prior to start => saturday end time
                adjustedDatetime = Datetime.newInstance(responseDatetime.date().addDays(-2), satEndTime);
            } else if (responseTime > Time.newInstance(22, 0, 0, 0)) {//monday after stop time => monday end time
                adjustedDAtetime = Datetime.newInstance(responseDatetime.date(), endTime);
            }
        } else if (weekdays.contains(responseDay)) {
            if (responseTime < startTime) {//Tue - Fri prior to start time => previous day end time
                adjustedDatetime = Datetime.newInstance(responseDatetime.date().addDays(-1), endTime);
            } else if (responseTime > Time.newInstance(22, 0, 0, 0)) {//Tue - Fri after hours => current day end time
                adjustedDatetime = Datetime.newInstance(responseDatetime.date(), endTime);
            }
        } else if (responseDay == 'Sat') {
            if (responseTime < startTime) {//Sat prior to start time => Friday end time
                adjustedDatetime = Datetime.newInstance(responseDatetime.date().addDays(-1), endTime);
            } else if (responseTime > Time.newInstance(20, 0, 0, 0)) {//Sat after end time => Saturday end time
                adjustedDatetime = Datetime.newInstance(responseDatetime.date(), satEndTime);
            }
        } else {//Sunday anytime => Sat end time
            adjustedDatetime = Datetime.newInstance(responseDatetime.date().addDays(-1), satEndTime);
        }

        return adjustedDatetime;
    }
}