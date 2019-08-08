public without sharing class RCILTClassroomAndLocationCmpCtrl {
    private static RCILTClassroomAndLocationCmpCtrl.WithoutSharingOps wosInstance;
    private static RCILTClassroomAndLocationCmpCtrl.WithoutSharingOps getWOSInstance(){
        if(wosInstance != null){
            return wosInstance;
        }
        wosInstance = new RCILTClassroomAndLocationCmpCtrl.WithoutSharingOps();
        return wosInstance;
    }

    @AuraEnabled
    public static ResultData getRecords(String itemId) {
        ResultData outputData = new ResultData();

        outputData.lang          = UserInfo.getLanguage().substring(0, 2);
        try {
            Id recId                = itemId;
            String recType          = recId.getSobjectType().getDescribe().getLocalName();
            Boolean isInstructor    = RCUtils.isInstructor((String)recId);

            if (recType == 'redwing__ILT_Class__c' && isInstructor) {
                List<redwing__ILT_Session__c> sessions = new List<redwing__ILT_Session__c>();

                sessions = getWOSInstance().getILTClassSessions(recId);
                if(!sessions.isEmpty()) {
                    outputData.records = new List<RCILTClassroomAndLocationCmpCtrl.ILTSessionWrapper>();
                }

                for(redwing__ILT_Session__c s: sessions) {
                    outputData.records.add(new ILTSessionWrapper(s));
                }
            }
        } catch (Exception e) {
            outputData.status       = RCConstants.ANSWER_STATUS_ACCESS_DENIED;
            outputData.message      = e.getMessage();
        }

        return outputData;
    }

    public without sharing class ILTSessionWrapper {
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public Integer day;
        @AuraEnabled public Date startDate;
        @AuraEnabled public String startTime;
        @AuraEnabled public String endTime;
        @AuraEnabled public ILTLocationWrapper location;

        public ILTSessionWrapper(redwing__ILT_Session__c rec) {
            Set<String> fieldNames = rec.getPopulatedFieldsAsMap().keySet();

            if(fieldNames.contains('Id')) {
                this.id = rec.Id;
            }
            if(fieldNames.contains('Name')) {
                this.name = rec.Name;
            }
            if(fieldNames.contains('redwing__Date__c')) {
                this.startDate = rec.redwing__Date__c;
                this.day = getDay(rec.redwing__ILT_Class__r.redwing__Start_Date__c);
            }
            if(fieldNames.contains('ltui__Start_Time_Formatted__c')) {
                this.startTime = rec.ltui__Start_Time_Formatted__c;
            }
            if(fieldNames.contains('ltui__End_Time_Formatted__c')) {
                this.endTime = rec.ltui__End_Time_Formatted__c;
            }
            if(fieldNames.contains('redwing__Location__r')) {
                this.location = new ILTLocationWrapper(rec.redwing__Location__r);
            }
        }

        private Integer getDay(Date classStartDate) {
            return classStartDate.daysBetween(this.startDate) + 1;
        }
    }

    public without sharing class ILTLocationWrapper {
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public String address1;
        @AuraEnabled public String city;
        @AuraEnabled public String country;
        @AuraEnabled public String state;
        @AuraEnabled public String postalCode;
        @AuraEnabled public String formattedAddress;
        @AuraEnabled public String mapUrl;

        public ILTLocationWrapper(redwing__ILT_Location__c rec) {
            Set<String> fieldNames = rec.getPopulatedFieldsAsMap().keySet();

            if(fieldNames.contains('Id')) {
                this.id = rec.Id;
            }
            if(fieldNames.contains('Name')) {
                this.name = rec.Name;
            }
            if(fieldNames.contains('redwing__Address_1__c')) {
                this.address1 = rec.redwing__Address_1__c;
            }
            if(fieldNames.contains('redwing__City__c')) {
                this.city = rec.redwing__City__c;
            }
            if(fieldNames.contains('redwing__Country__c')) {
                this.country = rec.redwing__Country__c;
            }
            if(fieldNames.contains('redwing__State__c')) {
                this.state = rec.redwing__State__c;
            }
            if(fieldNames.contains('redwing__Postal_Code__c')) {
                this.postalCode = rec.redwing__Postal_Code__c;
            }

            this.formatAddress();
            this.getMapUrl();
        }

        private void formatAddress() {
            String temp = '';

            temp += this.country != null ? this.country : '';
            temp += ' ';
            temp += this.state != null ? this.state : '';
            temp += ' ';
            temp += this.city != null ? this.city : '';
            temp += ' ';
            temp += this.address1 != null ? this.address1 : '';
            temp += ' ';
            temp += this.postalCode != null ? this.postalCode : '';

            this.formattedAddress = temp.trim();
        }
        private void getMapUrl() {
            String temp = '';

            temp += this.country != null ? this.country : '';
            temp += ' ';
            temp += this.state != null ? this.state : '';
            temp += ' ';
            temp += this.city != null ? this.city : '';
            temp += ' ';
            temp += this.address1 != null ? this.address1 : '';
            temp = 'https://www.google.com/maps/search/?api=1&query=' + EncodingUtil.urlEncode(temp,'UTF-8');

            this.mapUrl = temp.trim();
        }
    }

    public without sharing class ResultData {
        @AuraEnabled public String status   = RCConstants.ANSWER_STATUS_SUCCESS;
        @AuraEnabled public String message  = '';
        @AuraEnabled public String  lang    = '';

        @AuraEnabled public List<ILTSessionWrapper> records;
    }

    private without sharing class WithoutSharingOps {
        public List<redwing__ILT_Session__c> getILTClassSessions(Id recId) {
            List<redwing__ILT_Session__c> sessions = new List<redwing__ILT_Session__c>();

            sessions = [
                    SELECT Id, Name, redwing__Date__c, ltui__Start_Time_Formatted__c, ltui__End_Time_Formatted__c,
                            redwing__Location__r.Name, redwing__Location__r.redwing__Address_1__c,
                            redwing__Location__r.redwing__City__c, toLabel(redwing__Location__r.redwing__Country__c),
                            redwing__Location__r.redwing__State__c, redwing__Location__r.redwing__Postal_Code__c, redwing__ILT_Class__r.redwing__Start_Date__c
                    FROM redwing__ILT_Session__c
                    WHERE redwing__ILT_Class__c = :recId
                    AND redwing__Date__c >= TODAY
                    ORDER BY redwing__Date__c, redwing__Start_Time__c
            ];

            return sessions;
        }
    }
}