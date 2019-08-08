public with sharing class PHSS_VideoPlayerTwoApexController {
    @AuraEnabled
    public static List<PHSS_Material__c> getPHSSMaterialDetails(String phssID){      
        return PHSS_Utility.checkMaterialAccess([SELECT Category__c, ContentDocumentID__c, Content_Library_Name__c, Content_Tags__c, ContentVersionContentURL__c, ContentVersionFileType__c, ContentVersionID__c, 
                                                ContentVersionLink__c, ContentVersionVersionNumber__c, ContentWorkspaceID__c, Description__c, Featured__c, IsCandidateMaterial__c, Material_Name__c, Name, PHSS_Program__c, 
                                                Sequence__c, Type__c FROM PHSS_Material__c WHERE ID =: phssID]);
    } 
}