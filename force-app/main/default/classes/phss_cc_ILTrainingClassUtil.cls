/**
 * Created by jbarker on 2019-06-20.
 */

public with sharing class phss_cc_ILTrainingClassUtil {

    /**
     * @description Returns an ILT Class for a class Id
     *
     * @param classId
     *
     * @return
     */
    public static redwing__ILT_Class__c getILTrainingClass(String classId) {
        return [
                SELECT Id, Cloud_Craze_Product__c
                FROM redwing__ILT_Class__c
                WHERE Id = :classId
                LIMIT 1
        ];
    }
}