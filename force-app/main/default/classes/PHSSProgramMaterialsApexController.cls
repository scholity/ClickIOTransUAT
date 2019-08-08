public with sharing class PHSSProgramMaterialsApexController {

    @AuraEnabled
    public static List<PHSS_Material__C> getMaterialsByProgramApex(String programID, Boolean isCandidateMaterial) {
        System.debug('>>>>>>>>> PHSSProgramMaterialsApexController.getMaterialsByProgramApex');
        System.debug('>>>>>>>>> programID : ' + String.valueOf(programID));
        return PHSS_Utility.checkMaterialAccess([SELECT ID, Name, Material_Name__c, Sequence__c, ContentVersionFileType__c, Disable_Community_Preview__c, Content_Tags__c, Category__c, Type__c, ContentDocumentID__c, ContentVersionID__c, ContentVersionLink__c, LastModifiedDate, ContentVersionContentURL__c FROM PHSS_Material__C where PHSS_Program__c =: programID AND IsCandidateMaterial__c = :isCandidateMaterial ORDER BY Sequence__c]);
    }
    
    @AuraEnabled
    public static String getProgramNameByIDApex(String programID) {
        System.debug('>>>>>>>>> PHSSProgramMaterialsApexController.getProgramNameByIDApex');
        System.debug('>>>>>>>>> programID : ' + String.valueOf(programID));
        List<PHSS_Program__c> programs = [SELECT Name FROM PHSS_Program__c where ID =: programID];
        if (programs.isEmpty()) {
	        return null;
	    } else {
            return programs.get(0).Name;
        }
    }
        
    @AuraEnabled
    public static PHSS_Program__c getProgramDetailsApex(String programID) {
        System.debug('>>>>>>>>> PHSSProgramMaterialsApexController.getProgramDetailsApex');
        System.debug('>>>>>>>>> programID : '+ String.valueOf(programID));
        List<PHSS_Program__c> programs = [SELECT Name, Description__c, Program_Long_Name__c FROM PHSS_Program__c where ID =: programID];
        if (programs.isEmpty()) {
            return null;
        } else {
            return programs.get(0);
        }
    }  

    @AuraEnabled
    public static List<PHSS_Material__C> getMaterialsByCategoryTypeByProgramApex(String programID, String category, String type) {
        System.debug('>>>>>>>>> PHSSProgramMaterialsApexController.getMaterialsByCategoryTypeByProgramApex');
        System.debug('>>>>>>>>> programID : ' + String.valueOf(programID));
        System.debug('>>>>>>>>> category : ' + String.valueOf(category));
        System.debug('>>>>>>>>> type : ' + String.valueOf(type));
        return PHSS_Utility.checkMaterialAccess([SELECT ID, Name, Material_Name__c, Sequence__c, ContentVersionFileType__c, Disable_Community_Preview__c, Content_Tags__C, Category__c, Type__c,  ContentDocumentID__c, ContentVersionID__c, LastModifiedDate, ContentVersionContentURL__c
                FROM PHSS_Material__C where PHSS_Program__c =: programID 
				AND Category__c =: category AND IsCandidateMaterial__c = false
                AND Type__c =: type ORDER BY Sequence__c]);
    }    

    @AuraEnabled
    public static List<PHSS_Material__C> getMaterialsByTagsOrLibrary(String libaryName, String tagsCsv, Boolean isCandidateMaterial) {
        String query = 'SELECT Id, Name, Material_Name__c, ContentVersionFileType__c, Sequence__c, Disable_Community_Preview__c, Content_Tags__C, Category__c, Type__c, ContentDocumentID__c, ContentVersionID__c, ContentVersionLink__c, LastModifiedDate, ContentVersionContentURL__c FROM PHSS_Material__C WHERE IsCandidateMaterial__c = ' + String.valueOf(isCandidateMaterial);
        List<String> conditions = new List<String>();
        if(String.isNotBlank(libaryName)){
            query += ' AND Content_Library_Name__c = \'' + libaryName + '\'';
        }
        query += ' ORDER BY Sequence__c';
        List<PHSS_Material__C> materials = (List<PHSS_Material__C>)Database.query(query);
        return PHSS_Utility.checkMaterialAccess(String.isBlank(tagsCsv) ? materials : filterTags(tagsCsv, materials));

    }

    private static List<PHSS_Material__C> filterTags(String tagsCsv, List<PHSS_Material__C> materials) {
        Set<String> tags = PHSS_Utility.tagsCsvToCollection(tagsCsv);
        List<PHSS_Material__C> filtredMaterials = new List<PHSS_Material__C>();
        for(PHSS_Material__C material: materials) {
            if(String.isNotBlank(material.Content_Tags__C) && PHSS_Utility.matchTags(PHSS_Utility.tagsCsvToCollection(material.Content_Tags__C), tags)){
                filtredMaterials.add(material);
            }
        }
        return filtredMaterials;
    }
}