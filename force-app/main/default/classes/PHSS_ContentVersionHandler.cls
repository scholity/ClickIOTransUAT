public with sharing class PHSS_ContentVersionHandler implements PHSS_TriggerHandler {
    private static String TAG_LINK = 'Link';
    private static String TAG_VIDEO = 'Video';
    private static String TAG_INSTRUCTOR_BULLETIN = 'Instructor Bulletin';
    private static String TAG_PARTICIPANT_MATERIALS = 'Participant';
    private static String TAG_INSTRUCTOR_MATERIALS = 'Material';

    private static String TYPE_LINK = 'Link';
    private static String TYPE_VIDEO = 'Video';
    private static String TYPE_DOCUMENT = 'Document';
    private static String TYPE_INSTRUCTOR_BULLETIN = 'Instructor Bulletin';
    private static String TYPE_PARTICIPANT_MATERIALS = 'Participant Materials';
    private static String TYPE_INSTRUCTOR_MATERIALS = 'Instructor Materials';
    private static String TYPE_SUPPORTING_MATERIALS = 'Supporting Materials';


	public static Boolean isDisabled = false;

	public Boolean isDisabled(){
        return isDisabled || PHSS_TriggerUtility.getSettings().ContentVersionDisabled__c;
    }

    public void beforeInsert(List<SObject> newItems){}

    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){}

    public void beforeDelete(Map<Id, SObject> oldItems){}

    public void afterInsert(Map<Id, SObject> newItems){}

    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        PHSS_ContentVersionHandler.createMaterials(newItems.keySet());
        PHSS_ContentVersionHandler.deleteMaterials(newItems.keySet());
    }

    public void afterDelete(Map<Id, SObject> oldItems){}

    public void afterUndelete(Map<Id, SObject> oldItems){}

    private static Id getProgram(List<PHSS_Program__c> programs, String libraryName){
        for(PHSS_Program__c program: programs){
            if(program.Content_Library_Name__c != null && libraryName.startsWithIgnoreCase(program.Content_Library_Name__c)){
                return program.Id;
            }
        }
        return null;
    }

    private static void deleteMaterials(final Set<Id> materialIds) {
        Set<Id> contentDocumentIds = new Set<Id>();
        for(ContentVersion cv: [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :materialIds AND To_Delete__c = true]) {
            contentDocumentIds.add(cv.ContentDocumentId);
        }
        List<SObject> toRemove = new List<SObject>();
        toRemove.addAll((List<SObject>)[SELECT Id FROM PHSS_Material__c WHERE ContentDocumentID__c IN :contentDocumentIds]);
        toRemove.addAll((List<SObject>)[SELECT Id FROM ContentDocument WHERE Id IN :contentDocumentIds]);
        toRemove.sort();
        Savepoint sp = Database.setSavepoint();
        try {
            delete toRemove;
        } catch(Exception e) {
            Database.rollback(sp);
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
        }
    }

    private static void createMaterials(final Set<Id> contentVersionsIds){
        Map<Id, ContentVersion> contentVersions = new Map<Id, ContentVersion>([
            SELECT Id, TagCsv, Disable_Community_Preview__c, Is_S3_Content__c, S3_URL__c, ContentDocumentId, ContentURL, FileType, VersionNumber, Description, FeaturedContentBoost, Title, Sequence__c 
            FROM ContentVersion 
            WHERE Id IN :contentVersionsIds AND Create_IC_Program_Material_Record__c = true AND To_Delete__c = false
            ]);
        Map<Id, PHSS_Material__c> materialsToUpdate = new Map<Id, PHSS_Material__c>();
        Set<Id> contentDocumentIds = new Set<Id>();
        for(ContentVersion cv: contentVersions.values()) {
            contentDocumentIds.add(cv.ContentDocumentId);
        }
        for(PHSS_Material__c material: [SELECT Id, ContentVersionId__c, Content_Tags__c, ContentDocumentID__c FROM PHSS_Material__c WHERE ContentDocumentID__c IN :contentDocumentIds]) {
            materialsToUpdate.put(material.ContentDocumentID__c, material);
        }
        Map<Id, Id> contentToLibraryIds = new Map<Id, Id>();
        for(ContentWorkspaceDoc cwd : [SELECT Id, ContentDocumentId, ContentWorkspaceId FROM ContentWorkspaceDoc WHERE ContentDocumentId IN :contentDocumentIds]) {
            contentToLibraryIds.put(cwd.ContentDocumentId, cwd.ContentWorkspaceId);
        }
        Set<Id> workspaceIds = new Set<Id>(contentToLibraryIds.values());
        Map<Id, ContentWorkspace> contentWorkspaces = new Map<Id, ContentWorkspace>([SELECT Id, Name FROM ContentWorkspace WHERE Id IN :workspaceIds]);
        List<PHSS_Program__c> programs = [SELECT Id, Name, Content_Library_Name__c FROM PHSS_Program__c];
        List<PHSS_Material__c> materials = new List<PHSS_Material__c>();
        for(ContentVersion cv: contentVersions.values()) {
            PHSS_Material__c material = materialsToUpdate.containsKey(cv.ContentDocumentId) ? materialsToUpdate.get(cv.ContentDocumentId) : new PHSS_Material__c();
            material.Category__c = setMaterialCategory(cv.TagCsv);
            material.ContentDocumentID__c = cv.ContentDocumentId;
            if(contentToLibraryIds.containsKey(cv.ContentDocumentId)) {
                material.Content_Library_Name__c = contentWorkspaces.get(contentToLibraryIds.get(cv.ContentDocumentId)).Name;
                material.ContentWorkspaceID__c = contentToLibraryIds.get(cv.ContentDocumentId);
                material.PHSS_Program__c = getProgram(programs, material.Content_Library_Name__c);
                material.IsCandidateMaterial__c = material.Content_Library_Name__c.containsIgnoreCase('candidate');
            }
            material.Content_Tags__c = cv.TagCsv;
            material.ContentVersionContentURL__c = cv.ContentURL;
            material.ContentVersionFileType__c = cv.FileType;
            material.ContentVersionID__c = cv.Id;
            material.Is_S3_Content__c = cv.Is_S3_Content__c;
            material.S3_URL__c = cv.S3_URL__c;
            material.ContentVersionVersionNumber__c = cv.VersionNumber;
            material.Description__c = cv.Description;
            material.Sequence__c = cv.Sequence__c;
            material.Material_Name__c = cv.Title;
            material.Disable_Community_Preview__c = cv.Disable_Community_Preview__c;
            material.Name = cv.Title.left(80);
            material.Type__c = setMaterialType(cv.TagCsv);
            materials.add(material);
        }
        Savepoint sp = Database.setSavepoint();
        try {
            upsert materials;
        } catch(Exception e) {
            Database.rollback(sp);
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            prevent(contentVersions.values());
        }
    }

    private static String setMaterialType(String tagCsv) {
        Set<String> tags = PHSS_Utility.tagsCsvToCollection(tagCsv);
        if(tags != null && PHSS_Utility.matchTag(tags, TAG_LINK)) {
        	return TYPE_LINK;
        } else if(tags != null && PHSS_Utility.matchTag(tags, TAG_VIDEO)) {
        	return TYPE_VIDEO;
        } else {
        	return TYPE_DOCUMENT;
        }
    }

    private static String setMaterialCategory(String tagCsv) {
        Set<String> tags = PHSS_Utility.tagsCsvToCollection(tagCsv);
    	if(tags != null && PHSS_Utility.matchTag(tags, TAG_INSTRUCTOR_BULLETIN)) {
        	return TYPE_INSTRUCTOR_BULLETIN;
        } else if(tags != null && PHSS_Utility.matchTag(tags, TAG_PARTICIPANT_MATERIALS)){
        	return TYPE_PARTICIPANT_MATERIALS;
        } else if(tags != null && PHSS_Utility.matchTag(tags, TAG_INSTRUCTOR_MATERIALS)){
        	return TYPE_INSTRUCTOR_MATERIALS;
        } else {
        	return TYPE_SUPPORTING_MATERIALS;
        }
    }

    private static void prevent(List<ContentVersion> contentVersions) {
        for(ContentVersion cv: contentVersions) {
            cv.addError('Prevent saving because of error');
        }
    }
}