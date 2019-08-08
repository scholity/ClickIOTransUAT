public class skedARCUtils {

    public static List<skedModels.courseTemplate> getCourseTemplates() {
        List<Course_Template__c> skedCourseTemplates = [SELECT Id, Name, Course_Catalog__c, Course_Class_Days__c, 
                                                        Maximum_Hours_Per_Day__c, Default_Template__c,
                                                        (SELECT Id, Name, Class_Type__c, Display_Order__c, 
                                                         Total_Hours__c, Start_Time__c, End_Time__c, 
                                                         Location__c, Ratio_to_Instructor__c
                                                         FROM Course_Class_Types__r)
                                                        FROM Course_Template__c];
        List<skedModels.courseTemplate> result = new List<skedModels.courseTemplate>();
        for (Course_Template__c skedCourseTemplate : skedCourseTemplates) {
            skedModels.courseTemplate courseTemplate = new skedModels.courseTemplate(skedCourseTemplate);
            result.add(courseTemplate);
        }
        return result;
    }

    public static List<skedModels.courseCatalog> getCourseCatalogs(string courseType) {
        List<Course_Catalog__c> skedCourseCatalogs = [SELECT Id, Name, Number_of_Students__c, Number_of_Instructors__c, 
                                                      Ratio_to_Instructor__c, Class_Duration__c, Number_of_Classes__c, 
                                                      Break_Duration__c, Number_of_Breaks__c, Is_Active__c,
                                                      Master_Class_Name__c, 
                                                      (SELECT Tag__c, Tag__r.Name
                                                       FROM Course_Catalog_Tags__r),
                                                      (SELECT Course_Catalog__c, Course_Code__c, Display_Order__c, Duration__c
                                                       FROM Sub_Class_Settings__r)	
                                                      FROM Course_Catalog__c
                                                      WHERE Type__c INCLUDES (:courseType)
                                                      AND Is_Active__c = TRUE];
        List<skedModels.courseCatalog> result = new List<skedModels.courseCatalog>();
        for (Course_Catalog__c skedCourseCatalog : skedCourseCatalogs) {
            skedModels.courseCatalog courseCatalog = new skedModels.courseCatalog(skedCourseCatalog);
            result.add(courseCatalog);
        }
        return result;
    }

    public static skedModels.natClassSetting getNatSetting() {
        skedModels.natClassSetting setting = new skedModels.natClassSetting();
        setting.durationToHaveBreak = 300;
        setting.durationToHave2ndClass = 120;
        setting.breakTime = 30;
        setting.classTypeSettings = new List<skedModels.natClassTypeSetting>();

        sked_Admin_Setting__c skedSetting = sked_Admin_Setting__c.getOrgDefaults();
        if (skedSetting.NAT_Min_Duration_to_have_break__c != NULL) {
            setting.durationToHaveBreak = integer.valueOf(skedSetting.NAT_Min_Duration_to_have_break__c);
        }
        if (skedSetting.NAT_Min_Duration_for_2nd_class__c != NULL) {
            setting.durationToHave2ndClass = integer.valueOf(skedSetting.NAT_Min_Duration_for_2nd_class__c);
        }
        if (skedSetting.NAT_Break_Time__c != NULL) {
            setting.breakTime = integer.valueOf(skedSetting.NAT_Break_Time__c);
        }

        List<NAT_Class_Type_Setting__mdt> skedClassTypeSettings = [SELECT Class_Type__c, Backgroun_Color__c, Text_Color__c
                                                                   FROM NAT_Class_Type_Setting__mdt];
        for (NAT_Class_Type_Setting__mdt skedClassTypeSetting : skedClassTypeSettings) {
            skedModels.natClassTypeSetting classTypeSetting = new skedModels.natClassTypeSetting();
            classTypeSetting.classType = skedClassTypeSetting.Class_Type__c;
            classTypeSetting.backgroundColor = skedClassTypeSetting.Backgroun_Color__c;
            classTypeSetting.textColor = skedClassTypeSetting.Text_Color__c;
            setting.classTypeSettings.add(classTypeSetting);
        }
        return setting;
    }

}