/*
Copyright (c) 2014, salesforce.com, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.
    * Neither the name of the salesforce.com, Inc. nor the names of its contributors
    may be used to endorse or promote products derived from this software
    without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
OF THE POSSIBILITY OF SUCH DAMAGE.

*/
public with sharing class RCAchievementAssignmentsHelper {

    public static final String APINAME_CFIELD_LMSSETTINGS_DISABLE_CUSTOM_ACHIEVEMENT_ASSIGNMENT_TRIGGER = 'Disable_RCAchievementAssignment_trigger__c';

    public static void processBeforeInsertAchievementAssignment(List<redwing__Achievement_Assignment__c> newAchievementAssignments) {
        setAcquiredDate(newAchievementAssignments, null);
        setExpDate(newAchievementAssignments, null);
    }

    public static void processBeforeUpdateAchievementAssignment(Map<Id, redwing__Achievement_Assignment__c> oldAssignmentsMap, List<redwing__Achievement_Assignment__c> newAchievementAssignments) {
        setAcquiredDate(newAchievementAssignments, oldAssignmentsMap);
        setExpDate(newAchievementAssignments, oldAssignmentsMap);
    }

    //without crud\fls validation, because user can not update fields directly
    private static void setAcquiredDate(List<redwing__Achievement_Assignment__c> newAchievementAssignments, Map<Id, redwing__Achievement_Assignment__c> oldAchievementAssignmentById) {

        List<redwing__ILT_Class__c>ILTClasses = getILTClassFromAchievementAssignment(newAchievementAssignments);
        List<redwing__Training_Plan__c> tPlans = getLearningPlansFromAchievementAssignment(newAchievementAssignments);

        for (redwing__Achievement_Assignment__c newAchievementAssignment : newAchievementAssignments) {
            if (
                    (
                            //on Insert
                            oldAchievementAssignmentById == null ||
                                    //on Update
                                    (
                                            oldAchievementAssignmentById.containsKey(newAchievementAssignment.Id) &&
                                                    (
                                                            oldAchievementAssignmentById.get(newAchievementAssignment.Id).redwing__Status__c != null &&
                                                                    oldAchievementAssignmentById.get(newAchievementAssignment.Id).redwing__Status__c != 'Acquired'
                                                    )
                                    )
                    ) &&
                            newAchievementAssignment.redwing__Status__c == 'Acquired'
                    ) {

                newAchievementAssignment.redwing__Acquisition_Date__c = System.Today();

                if (!iltClasses.isEmpty()) {
                    for (redwing__ILT_Class__c iltClass : iltClasses) {
                        if (iltClass.Classroom_Setting__c == 'Classroom' || iltClass.Classroom_Setting__c == 'Online + Classroom') {
                            newAchievementAssignment.redwing__Acquisition_Date__c = iltClass.redwing__End_Date__c;
                            break;
                        }
                    }
                } else if (!tPlans.isEmpty()) {
                    for (redwing__Training_Plan__c tp : tPlans) {
                        if (tp.Classroom_Setting__c == 'Classroom' || tp.Classroom_Setting__c == 'Online + Classroom') {
                            newAchievementAssignment.redwing__Acquisition_Date__c = tp.redwing__End_Date__c;
                        }
                    }
                }
            }
        }
    }

    private static void setExpDate(List<redwing__Achievement_Assignment__c> newAchievementAssignments, Map<Id, redwing__Achievement_Assignment__c> oldAchievementAssignmentById) {

        Date expDateForAchievementAssignmentByTerm;

        Set<Id> achievementIdByAssignmentId = new Set<Id>();
        List<redwing__ILT_Class__c> iltClasses = getILTClassFromAchievementAssignment(newAchievementAssignments);
        List<redwing__Training_Plan__c> tPlans = getLearningPlansFromAchievementAssignment(newAchievementAssignments);

        for (redwing__Achievement_Assignment__c newAchievementAssignment : newAchievementAssignments) {
            achievementIdByAssignmentId.add(newAchievementAssignment.redwing__Achievement__c);
        }
        //have to do query in without sharing, because user has no access to achievement object!!!
        Map<Id, redwing__Achievement__c> achievements = new Map<Id, redwing__Achievement__c>([
                SELECT
                        redwing__Expiration_Term__c,
                        redwing__Expiration_Term_Basis__c,
                        redwing__Expiration_Date__c

                FROM redwing__Achievement__c
                WHERE Id IN:achievementIdByAssignmentId
                LIMIT 10000
        ]);

        for (redwing__Achievement_Assignment__c newAchievementAssignment : newAchievementAssignments) {
            if (
                    (
                            //on Insert
                            oldAchievementAssignmentById == null ||
                                    //on Update
                                    (
                                            oldAchievementAssignmentById.containsKey(newAchievementAssignment.Id) &&
                                                    (
                                                            oldAchievementAssignmentById.get(newAchievementAssignment.Id).redwing__Status__c != null &&
                                                                    oldAchievementAssignmentById.get(newAchievementAssignment.Id).redwing__Status__c != 'Acquired'
                                                    )
                                    )
                    ) &&
                            newAchievementAssignment.redwing__Status__c == 'Acquired' &&
                            newAchievementAssignment.redwing__Acquisition_Date__c != null &&
                            achievements.containsKey(newAchievementAssignment.redwing__Achievement__c) &&
                            (achievements.get(newAchievementAssignment.redwing__Achievement__c).redwing__Expiration_Term__c != null || achievements.get(newAchievementAssignment.redwing__Achievement__c).redwing__Expiration_Date__c != null)
                    ) {
                Integer achievementExpirationTerm = achievements.get(newAchievementAssignment.redwing__Achievement__c).redwing__Expiration_Term__c != null ? Integer.valueOf(achievements.get(newAchievementAssignment.redwing__Achievement__c).redwing__Expiration_Term__c) : null;
                String achievementExpirationTermBasis = achievements.get(newAchievementAssignment.redwing__Achievement__c).redwing__Expiration_Term_Basis__c;
                Date achievementExpirationDate = achievements.get(newAchievementAssignment.redwing__Achievement__c).redwing__Expiration_Date__c;


                for (redwing__Training_Plan__c tp : tPlans) {
                    if (tp.Classroom_Setting__c == 'Classroom' || tp.Classroom_Setting__c == 'Online + Classroom') {
                        newAchievementAssignment.redwing__Acquisition_Date__c = tp.redwing__End_Date__c;
                        expDateForAchievementAssignmentByTerm = getExpDateByAcquiredDateAndExpTerm (
                                tp.redwing__End_Date__c, achievementExpirationTerm, achievementExpirationTermBasis);
                        continue;
                    } else {
                        expDateForAchievementAssignmentByTerm = getExpDateByAcquiredDateAndExpTerm (
                                newAchievementAssignment.redwing__Acquisition_Date__c, achievementExpirationTerm, achievementExpirationTermBasis);
                        continue;
                    }
                }

                for (redwing__ILT_Class__c iltClass : iltClasses) {
                    if (iltClass.Classroom_Setting__c == 'Classroom' || iltClass.Classroom_Setting__c == 'Online + Classroom') {
                        newAchievementAssignment.redwing__Acquisition_Date__c = iltClass.redwing__End_Date__c;
                        expDateForAchievementAssignmentByTerm = getExpDateByAcquiredDateAndExpTerm (
                                iltClass.redwing__End_Date__c, achievementExpirationTerm, achievementExpirationTermBasis);
                        break;
                    } else {
                        expDateForAchievementAssignmentByTerm = getExpDateByAcquiredDateAndExpTerm (
                                newAchievementAssignment.redwing__Acquisition_Date__c, achievementExpirationTerm, achievementExpirationTermBasis);
                        continue;
                    }
                }

                if (iltClasses.isEmpty() && tPlans.isEmpty()) {
                    expDateForAchievementAssignmentByTerm = getExpDateByAcquiredDateAndExpTerm (
                            newAchievementAssignment.redwing__Acquisition_Date__c, achievementExpirationTerm, achievementExpirationTermBasis);
                }

                if (achievementExpirationDate != null || achievementExpirationTerm != null) {
                    if (expDateForAchievementAssignmentByTerm == null) {
                        newAchievementAssignment.redwing__Expiration_Date__c = achievementExpirationDate;
                    } else if (expDateForAchievementAssignmentByTerm != null) {
                        newAchievementAssignment.redwing__Expiration_Date__c = expDateForAchievementAssignmentByTerm;
                        achievementExpirationDate = expDateForAchievementAssignmentByTerm;
                    }
                }
            }
        }
    }

    private static Date getExpDateByAcquiredDateAndExpTerm(Date acquiredDate, Integer expirationTerm, String expirationTermBasis) {
        Date expDateByExpTerm = null;
        expirationTermBasis = expirationTermBasis == null ? expirationTermBasis = 'Days' : expirationTermBasis;
        if (acquiredDate != null && expirationTerm != null && expirationTermBasis != null) {
            if (expirationTermBasis == 'Days') {
                expDateByExpTerm = acquiredDate.addDays(expirationTerm);
            } else if (expirationTermBasis == 'Weeks') {
                expirationTerm = expirationTerm * 7;
                expDateByExpTerm = acquiredDate.addDays(expirationTerm);
            } else if (expirationTermBasis == 'Months') {
                expDateByExpTerm = acquiredDate.addMonths(expirationTerm);
            } else if (expirationTermBasis == 'Years') {
                expDateByExpTerm = acquiredDate.addYears(expirationTerm);
            }
        }
        return expDateByExpTerm;
    }

    // get ILTClass from Achievement Assignment record
    private static List<redwing__ILT_Class__c> getILTClassFromAchievementAssignment(List<redwing__Achievement_Assignment__c> newAchievementAssignments) {
        Set<Id> ILTClassesIds = new Set<Id>();
        List<redwing__ILT_Class__c> onlineILTClasses = new List<redwing__ILT_Class__c>();

        for (redwing__Achievement_Assignment__c newAchievementAssignment : newAchievementAssignments) {
            ILTClassesIds.add(newAchievementAssignment.ILT_Class__c);
        }

        List<redwing__ILT_Class__c> iltClasses = new List<redwing__ILT_Class__c>([
                SELECT
                        redwing__End_Date__c,
                        Classroom_Setting__c
                FROM redwing__ILT_Class__c
                WHERE Id IN:ILTClassesIds
                LIMIT 10000
        ]);

        if (!iltClasses.isEmpty()) {
            for (redwing__ILT_Class__c iltClass : iltClasses) {
                onlineILTClasses.add(iltClass);
            }
        }
        return onlineILTClasses;
    }

    //get Learning Plans from Learning Plan Achievement if Learning Plan Achievement is not null
    private static List<redwing__Training_Plan__c> getLearningPlansFromAchievementAssignment(List<redwing__Achievement_Assignment__c> newAchievementAssignments) {
        Set<Id> tpAchievementsIds = new Set<Id>();
        Set<Id> tpIds = new Set<Id>();
        List<redwing__Training_Plan__c> onlineTPlans = new List<redwing__Training_Plan__c>();
        for (redwing__Achievement_Assignment__c newAchievementAssignment : newAchievementAssignments) {
            tpAchievementsIds.add(newAchievementAssignment.redwing__Training_Plan_Achievement__c);
        }

        Map<Id, redwing__Training_Plan_Achievement__c> tpAchievements = new Map<Id, redwing__Training_Plan_Achievement__c>([
                SELECT
                        redwing__Training_Plan__c
                FROM redwing__Training_Plan_Achievement__c
                WHERE Id IN:tpAchievementsIds
        ]);

        for (redwing__Training_Plan_Achievement__c tpAchievement : tpAchievements.values()) {
            tpIds.add(tpAchievement.redwing__Training_Plan__c);
        }

        List<redwing__Training_Plan__c> tPlans = new List<redwing__Training_Plan__c>([
                SELECT
                        redwing__End_Date__c,
                        Classroom_Setting__c
                FROM redwing__Training_Plan__c
                WHERE Id IN:tpIds
        ]);

        if (!tPlans.isEmpty()) {
            for (redwing__Training_Plan__c tp : tPlans) {
                onlineTPlans.add(tp);
            }
        }
        return onlineTPlans;
    }
    
    private static Object getLMSSettingsValue(String key, Object defaultValue) {
        redwing__LMS_Settings__c cs = redwing__LMS_Settings__c.getInstance();
        if (cs != null && cs.get(key) != null) {
            return cs.get(key);
        } else {
            return defaultValue;
        }
    }

    public static Boolean getAchievementAssignmentDisableTrigger() {
        Boolean result = false;
        try {
            result = (Boolean) getLMSSettingsValue(
                    APINAME_CFIELD_LMSSETTINGS_DISABLE_CUSTOM_ACHIEVEMENT_ASSIGNMENT_TRIGGER,
                    false
            );
        } catch (Exception e) {
            system.debug('Error:  ' + e);
        }
        return result;
    }
}