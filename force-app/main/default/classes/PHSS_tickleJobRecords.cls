/**
 * Created by scholity on 12/9/19.
 */

public without sharing class PHSS_tickleJobRecords implements Database.Batchable<sObject> {

    public Database.QueryLocator start(Database.BatchableContext bc) {

        String theJobQuery = 'Select Id, Name, Ready_To_Publish__c, Location_Confirmed__c, ';
        theJobQuery += 'Sked__Type__c, sked__Start__c From sked__Job__c ';
        theJobQuery += 'Where Sked__Type__c IN (\'Community\',\'Nurse Assistant Testing\') ';
        theJobQuery += 'And sked__Start__c >= 2019-12-10T05:00:00Z ';
        theJobQuery += 'And (Location_Confirmed__c = true  Or Ready_To_Publish__c = true) ';
        theJobQuery += 'And sked__Recurring_Schedule__c != null ';
        theJobQuery += 'And sked__Job_Status__c != \'Cancelled\' ';
        theJobQuery += 'And (Is_Stacked_Class__c = false Or (Is_Stacked_Class__c = true And Is_Master_Class__c = true)) ';
        theJobQuery += 'Order by sked__Recurring_Schedule__c ';

        return Database.getQueryLocator(theJobQuery);
    }

    public void execute(Database.BatchableContext bc, List<sked__Job__c> jobsToTickle) {
        Map <Id, sked__Job__c> jobsInScope = new Map<Id, sked__Job__c>();
        Set <Id> jobsWithClasses = new Set<Id>();
        List <sked__Job__c> jobsMissingClasses = new List<sked__Job__c>();
        List <sked__Job__c> jobsToUpdate = new List<sked__Job__c>();

        for (sked__Job__c theJob : jobsToTickle) {
            jobsInScope.put(theJob.Id, theJob);
        }

        for (redwing__ILT_Class__c theClass : [
                Select Id, Name, Skedulo_Job_Id__c
                From redwing__ILT_Class__c
                Where skedulo_Job_Id__c IN :jobsInScope.keySet()
        ]) {

            jobsWithClasses.add(theClass.skedulo_Job_Id__c);
        }
        for (sked__Job__c theJob : jobsInScope.values()) {
            if (!jobsWithClasses.contains(theJob.id)) {
                jobsMissingClasses.add(theJob);
            }
        }

        for (sked__Job__c theJob : jobsMissingClasses) {
            sked__Job__c updatedJob = new sked__Job__c();
            updatedJob.Id = theJob.Id;
            jobsToUpdate.add(updatedJob);
        }

        Database.update(jobsToUpdate);
        return;
    }

    public void finish(Database.BatchableContext bc){

    }

}