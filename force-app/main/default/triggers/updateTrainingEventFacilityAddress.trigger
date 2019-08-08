trigger updateTrainingEventFacilityAddress on Facility__c (after Insert, after Update) 
{
    List<Training_Events__c> trainingEventListToUpdate = new List<Training_Events__c>();
    for(Facility__c facRecord : [select Facility_Address_1__c, Facility_Address_2__c, Facility_City__c, Facility_State__c, Facility_Zip__c, Aquatics_Examiner_Service__c from Facility__c where id In : Trigger.newMap.keySet()])
    {
        if(facRecord.Aquatics_Examiner_Service__c != null)
        {
            Training_Events__c teRecord = new Training_Events__c();
            teRecord.Id = facRecord.Aquatics_Examiner_Service__c;
            teRecord.Facility_Address_1__c = facRecord.Facility_Address_1__c;
            teRecord.Facility_Address_2__c = facRecord.Facility_Address_2__c;
            teRecord.Facility_City__c = facRecord.Facility_City__c;
            teRecord.Facility_State__c = facRecord.Facility_State__c;
            teRecord.Facility_Zip__c = facRecord.Facility_Zip__c;
            trainingEventListToUpdate.add(teRecord);
        }
    }
    if(trainingEventListToUpdate.size() > 0)
        update trainingEventListToUpdate;
}