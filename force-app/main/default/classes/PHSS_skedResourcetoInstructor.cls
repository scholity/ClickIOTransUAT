public without sharing class PHSS_skedResourcetoInstructor {

    public static void afterInsert(List<sked__Resource__c> newRecords) {
        upsertInstructor(newRecords);
    }
    public static void afterUpdate(List<sked__Resource__c> newRecords, Map<Id, sked__Resource__c> updatedRecords) {
        upsertInstructor(newRecords);
    }
    public static void beforeDelete(Map<Id, sked__Resource__c> deleteRecords) {
        deleteInstructor(deleteRecords);
    }

    private static void upsertInstructor(List<sked__Resource__c> newRecords){
        List<redwing__Instructor__c> rdILTList = new List<redwing__Instructor__c>();
        for(sked__Resource__c skld : newRecords)
        {
            // if(skld.sked__Resource_Type__c == 'Person' && (skld.sked__Category__c == 'Instructor' || skld.sked__Category__c == 'Nurse Instructor')){
            // 09-18-2018 (SJC) - Per Red Cross, remove constraint on Category and allow any Category to be defined as an Instructor
            if (skld.sked__Resource_Type__c == 'Person') {
                redwing__Instructor__c rl = new redwing__Instructor__c();
                rl.Skedulo_Instructor_External__c = skld.id;
                rl.Skedulo_Is_Active__c = skld.sked__Is_Active__c;
                rl.Skedulo_Instructor__c = skld.Id;
                //rl.Name = skld.Name;
                rl.redwing__User__c = skld.sked__User__c;
                
                rdILTList.add(rl);
                system.debug(rdILTList);
            }
        }
        
        Schema.SObjectField f = redwing__Instructor__c.Fields.Skedulo_Instructor_External__c; 
               
        if(!rdILTList.isEmpty())
        {
            database.upsert(rdILTList, f, false);
        }
    }
    
    private static void deleteInstructor(Map<Id, sked__Resource__c> deleteRecords) {
        set<Id> resourceId = new set<Id>();
        for (sked__Resource__c skld : deleteRecords.values()) {
            // if(skld.sked__Resource_Type__c == 'Person' && (skld.sked__Category__c == 'Instructor' || skld.sked__Category__c == 'Nurse Instructor')){
            // 09-18-2018 (SJC) - Per Red Cross, remove constraint on Category and allow any Category to be defined as an Instructor
            if (skld.sked__Resource_Type__c == 'Person') {
               resourceId.add(skld.Id);
            }
        }
        if(resourceId.size() > 0) {
        list<redwing__Instructor__c> delRecords = [Select Id, Skedulo_Is_Active__c from redwing__Instructor__c where Skedulo_Instructor__c IN: resourceId];
            if(delRecords.size() > 0){
                for(redwing__Instructor__c rid:delRecords)
                {
                    rid.Skedulo_Is_Active__c = false;
                }
                Database.update (delRecords, false);
            }
        }
    }
}