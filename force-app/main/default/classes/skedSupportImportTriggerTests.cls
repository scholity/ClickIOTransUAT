@isTest
private class skedSupportImportTriggerTests {
    
    @isTest static void test_method_one() {

        // Implement test code
        createskedLocationr();
        createCourse_Catalogr();
        createJob();
    }
    
    private  static sked__Region__c createskedRegionr(){
        sked__Region__c createNewskedRegionr = new sked__Region__c();
         createNewskedRegionr.Name = 'New England EST' ;
         createNewskedRegionr.sked__Country_Code__c = 'US' ;
         createNewskedRegionr.sked__Description__c = 'Daylight Savings Observed: Yes | States:  MA,ME,NH,NY,PA,VT' ;
         createNewskedRegionr.sked__Timezone__c = 'US/Eastern' ;
        insert createNewskedRegionr;
        return createNewskedRegionr;
    }


private  static sked__Location__c createskedLocationr(){
        sked__Location__c createNewskedLocationr = new sked__Location__c();
         createNewskedLocationr.Name = 'MA - Springfield, Red Cross' ;
         createNewskedLocationr.sked__Address__c = '150 Brookdale Drive, Springfield, MA 01104' ;
         createNewskedLocationr.sked__GeoLocation__Latitude__s = 42.145636 ;
         createNewskedLocationr.sked__GeoLocation__Longitude__s = -72.5284343 ;
         createNewskedLocationr.sked__Region__c = createskedRegionr().Id ;
         createNewskedLocationr.sked__Requires_Whitelist__c = false ;
         createNewskedLocationr.sked__Type__c = 'Community' ;
         createNewskedLocationr.Is_Active__c = true ;
        insert createNewskedLocationr;
        return createNewskedLocationr;
}


private static Course_Catalog__c createCourse_Catalogr(){
        Course_Catalog__c createNewCourse_Catalogr = new Course_Catalog__c();
         createNewCourse_Catalogr.Name = 'BLS101-12WB' ;
         createNewCourse_Catalogr.Type__c = 'Community' ;
         createNewCourse_Catalogr.Number_of_Students__c = 12 ;
         createNewCourse_Catalogr.Ratio_to_Instructor__c = '1:10-12' ;
         createNewCourse_Catalogr.Number_of_Instructors__c = 1 ;
         createNewCourse_Catalogr.Number_of_Breaks__c = 1 ;
         createNewCourse_Catalogr.Break_Duration__c = 15 ;
         createNewCourse_Catalogr.Class_Duration__c = 195 ;
         createNewCourse_Catalogr.Number_of_Classes__c = 1 ;
        insert createNewCourse_Catalogr;
        return createNewCourse_Catalogr;
}


public static sked__Job__c createJob(){
sked__Location__c createNewskedLocationr = new sked__Location__c();
         createNewskedLocationr.Name = 'MA - Springfield, Red Cross' ;
         createNewskedLocationr.sked__Address__c = '150 Brookdale Drive, Springfield, MA 01104' ;
         createNewskedLocationr.sked__GeoLocation__Latitude__s = 42.145636 ;
         createNewskedLocationr.sked__GeoLocation__Longitude__s = -72.5284343 ;
         createNewskedLocationr.sked__Region__c = createskedRegionr().Id ;
         createNewskedLocationr.sked__Requires_Whitelist__c = false ;
         createNewskedLocationr.sked__Type__c = 'Community' ;
         createNewskedLocationr.Is_Active__c = true ;
        insert createNewskedLocationr;
        
        sked__Job__c createNewJob = new sked__Job__c();
         createNewJob.sked__Job_Status__c = 'Queued' ;
         createNewJob.sked__Type__c = 'Community' ;
         createNewJob.Number_of_Breaks__c = 1 ; 
         createNewJob.Break_Duration__c = 15 ;
         createNewJob.Number_of_Instructors__c = 1 ;
         createNewJob.Start_Date__c = '26/08/19' ;
         createNewJob.Start_Time__c = '9:00:00' ;
         createNewJob.End_Date__c = '26/08/19' ;
         createNewJob.End_Time__c = '12:15:00' ;
         createNewJob.Temp_Location__c = 'MA - Springfield, Red Cross' ;
         createNewJob.Temp_Course__c = 'BLS101-12WB' ;
         //createNewJob.sked__Start__c =Datetime.newInstanceGmt(2011,6,1,12,1,5);
         createNewJob.sked__Description__c= 'Daylight Savings Observed: Yes | States:  MA,ME,NH,NY,PA,VT';
         createNewJob.sked__Location__c = createNewskedLocationr.id;
         
        insert createNewJob;
        return createNewJob;
}



    
}