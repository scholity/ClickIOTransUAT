public without sharing class CustomLookUpController {

    private static final String ALL_ACCOUNTS = 'All';
    private static final String ACQUIRED_STATUS = 'Acquired';

    // SObjects
    private static final String ACCOUNT_OBJECT = 'Account';
    private static final String USER_OBJECT = 'User';
    private static final String CLASS_OBJECT = 'redwing__ILT_Class__c';
    private static final String ILT_LOCATION_OBJECT = 'redwing__ILT_Location__c';

    // Profile names
    private static final String SB_ARC_INSTRUCTOR_PROFILE = 'SB ARC SD Instructor';
    private static final String SB_PARTNER_COMMUNITY_LOGIN_PROFILE = 'SB PHSS-Partner-Community Plus Login';

    // RecordType names
    private static final String ILT_EVENT_RECORDTYPE_NAME = 'ILT Event';
    private static final String ORG_ACCT_RECORDTYPE_NAME = 'Organization Account';
    private static final String SB_ORG_ACCT_RECORDTYPE_NAME = 'SB Organization Account';

    // Role names
    private static final String ADMINISTRATOR_ROLE = 'Administrator';
    private static final String INSTRUCTOR_ROLE = 'Instructor';

    // User license names
    private static final String CUSTOMER_COMMUNITY_USER_LICENSE = 'Customer Community';


    /**
     * @description Fetches information about the current user
     *
     * @return
     */
    @AuraEnabled
    public static User fetchUser() {
        User u = [
                SELECT  Id,
                        ContactId,
                        Name,
                        Profile.Name,
                        Profile.UserLicense.Name
                FROM    User
                WHERE   Id = :UserInfo.getUserId()
        ];
        System.debug('User--->'+u);
        return u;
    }

    /**
     * @description Fetches lookup values
     *
     * @param searchKeyWord
     * @param ObjectName
     * @param accId
     * @param learningplanid
     *
     * @return
     */
    @AuraEnabled
    public static List <SObject> fetchLookUpValues(String searchKeyWord, String ObjectName, String accId, String learningplanid) {
        Set<Id> PreachSet = new Set<Id>();
        List<Id> Prereqid = new List<Id>();
        User u = fetchUser();

        List<String> searchKey = new List<String>{
                searchKeyWord + '%', '%' + searchKeyWord + '%', '%' + searchKeyWord
        };

        String sQuery = '';

        List <SObject> returnList = new List <SObject>();


        if (ObjectName == ACCOUNT_OBJECT) {
            if (u.Profile.UserLicense.Name.contains(CUSTOMER_COMMUNITY_USER_LICENSE) || u.Profile.Name == SB_ARC_INSTRUCTOR_PROFILE) {
                sQuery = 'SELECT Id, Name, BillingAddress FROM Account WHERE Id IN (SELECT AccountId FROM AccountContactRelation WHERE ContactId = \'' + u.ContactId + '\') AND Name LIKE :searchKey ORDER BY CreatedDate DESC LIMIT 5';

            } else {
                sQuery = 'SELECT Id, Name, BillingAddress FROM Account WHERE Name LIKE :searchKey AND (Recordtype.Name = :ORG_ACCT_RECORDTYPE_NAME OR RecordType.Name = :SB_ORG_ACCT_RECORDTYPE_NAME) ORDER BY CreatedDate DESC LIMIT 5';
            }

        } else if (ObjectName == USER_OBJECT) {
            if (accId != ALL_ACCOUNTS) {
                List<String> ListRolesName = new List<String>{
                        ADMINISTRATOR_ROLE, INSTRUCTOR_ROLE
                };
                if (u.Profile.Name == SB_PARTNER_COMMUNITY_LOGIN_PROFILE) {
                    sQuery = 'SELECT Id, Name FROM User WHERE ContactId IN (SELECT ContactId FROM AccountContactRelation WHERE AccountId = \'' + accId + '\' AND Roles IN :ListRolesName) AND Name LIKE :searchKey ORDER BY CreatedDate DESC LIMIT 20';

                } else {
                    sQuery = 'SELECT Id, Name FROM User WHERE Id != \'' + UserInfo.getUserId() + '\' AND ContactId IN (SELECT ContactId FROM AccountContactRelation WHERE AccountId = \'' + accId + '\' AND Roles IN: ListRolesName) AND Name LIKE :searchKey ORDER BY CreatedDate DESC LIMIT 20';
                }
            }

        } else if (ObjectName == CLASS_OBJECT) {
            sQuery = 'select Id, Site_Address_1__c, Site_Address_2__c, Site_City__c, Site_Name__c, Site_Postal_Code__c, State__c from ' + ObjectName + ' where Site_Name__c LIKE :searchKey OR Site_Address_1__c LIKE :searchKey OR Site_Postal_Code__c LIKE :searchKey ORDER BY CreatedDate DESC limit 10';
        } else if (ObjectName == ILT_LOCATION_OBJECT) {
            sQuery = 'SELECT Id, Name, redwing__Address_1__c, redwing__Address_2__c, redwing__City__c, redwing__Country__c, redwing__Street__c, redwing__State__c, redwing__Postal_Code__c FROM ' + ObjectName + ' WHERE Account__c = \'' + accId + '\' AND Account__c != null AND ( Name LIKE :searchKey OR redwing__Address_1__c LIKE :searchKey OR redwing__Postal_Code__c LIKE :searchKey ) ORDER BY CreatedDate DESC LIMIT 10';
        } else {
            sQuery = 'SELECT Id, Name FROM ' + ObjectName + ' WHERE Name LIKE :searchKey ORDER BY CreatedDate DESC LIMIT 5';
        }

        List <SObject> lstOfRecords = Database.query(sQuery);
        Map<Id, Set<Id>> mapuserach = new Map<Id, Set<Id>>();
        if (ObjectName == USER_OBJECT) {

            // Logic to retrieve the prerequisite of the current course
            redwing__Training_Plan_Section_Item__c learningPlanILTEventItem = [
                    SELECT  Id,
                            redwing__Learning__c,
                            redwing__Learning__r.RecordType.Name,
                            redwing__Training_Plan_Section__c
                    FROM    redwing__Training_Plan_Section_Item__c
                    WHERE   redwing__Training_Plan_Section__r.redwing__Training_Plan__c = :learningplanid
                    AND     redwing__Learning__c != NULL
                    AND     redwing__Learning__r.RecordType.Name = :ILT_EVENT_RECORDTYPE_NAME
                    LIMIT   1
            ];

            List<redwing__Learning_Prerequisite__c> learningpreid = [
                    SELECT  Name,
                            redwing__Training_Plan__c,
                            redwing__Learning__c,
                            redwing__Prerequisite__c
                    FROM    redwing__Learning_Prerequisite__c
                    WHERE   redwing__Learning__c = :learningPlanILTEventItem.redwing__Learning__c
                    LIMIT   1
            ];
            if (learningpreid.size() > 0) {
                List<redwing__Prerequisite__c> Prereqlist = [
                        SELECT  Id
                        FROM    redwing__Prerequisite__c
                        WHERE   Id = :learningpreid[0].redwing__Prerequisite__c
                ];
                for (redwing__Prerequisite__c ObjPreq : Prereqlist) {
                    Prereqid.add(ObjPreq.Id);
                }

                List<redwing__Prerequisite_Item__c> PrereitemAchv = [
                        SELECT  redwing__Achievement__c
                        FROM    redwing__Prerequisite_Item__c
                        WHERE   redwing__Prerequisite__c IN :Prereqid
                        AND     redwing__Required_Status__c = :ACQUIRED_STATUS
                ];
                for (redwing__Prerequisite_Item__c ObjPreItm : PrereitemAchv) {
                    PreachSet.add(ObjPreItm.redwing__Achievement__c);
                }
            }

            // Get Achievement Assignment records
            List<redwing__Achievement_Assignment__c> InstructorAchv = [
                    SELECT  redwing__Achievement__c,
                            redwing__User__c
                    FROM    redwing__Achievement_Assignment__c
                    WHERE   redwing__User__c IN :lstOfRecords
                    AND     redwing__Status__c = :ACQUIRED_STATUS
            ];
            for (redwing__Achievement_Assignment__c raa : InstructorAchv) {
                if (mapuserach.containsKey(raa.redwing__User__c)) {
                    Set<Id> AchvmntSet = mapuserach.get(raa.redwing__User__c);
                    AchvmntSet.add(raa.redwing__Achievement__c);
                    mapuserach.put(raa.redwing__User__c, AchvmntSet);

                } else {
                    Set<Id> AchvmntSet = new Set<Id>{ raa.redwing__Achievement__c };
                    mapuserach.put(raa.redwing__User__c, AchvmntSet);
                }
            }
        }

        if (ObjectName == USER_OBJECT && PreachSet.size() > 0) {
            for (SObject u1 : lstOfRecords) {
                if (mapuserach.containsKey(u1.Id)) {
                    if (mapuserach.get(u1.Id).containsAll(PreachSet)) {
                        returnList.add(u1);
                    }
                }
            }
        } else if (ObjectName == CLASS_OBJECT) {
            for (SObject obj : lstOfRecords) {
                if (String.isNotBlank((String) obj.get('Site_Name__c'))) {
                    obj.put('Name', obj.get('Site_Name__c'));
                } else {
                    String address = (String) obj.get('Site_Address_1__c')
                            + ' ' + obj.get('Site_Address_2__c') + ' ' + obj.get('Site_City__c')
                            + ', ' + obj.get('State__c') + ' ' + obj.get('Site_Postal_Code__c');
                    if (String.isNotBlank(address)) {
                        obj.put('Name', address);
                    }

                }
                returnList.add(obj);
            }
        } else if (ObjectName == ILT_LOCATION_OBJECT) {
            for (SObject obj : lstOfRecords) {
                if (String.isNotBlank((String) obj.get('Name'))) {
                    obj.put('Name', obj.get('Name'));
                } else {
                    String address = (String) obj.get('redwing__Address_1__c')
                            + ' ' + obj.get('redwing__Address_2__c') + ' ' + obj.get('redwing__City__c')
                            + ', ' + obj.get('redwing__State__c') + ' ' + obj.get('redwing__Postal_Code__c');
                    if (String.isNotBlank(address)) {
                        obj.put('Name', address);
                    }

                }
                returnList.add(obj);
            }
        } else {
            for (SObject obj : lstOfRecords) {
                returnList.add(obj);
            }
        }
        return returnList;
    }
}