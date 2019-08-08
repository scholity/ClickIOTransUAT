@isTest
private class PHSS_ContentVersionHandler_TEST {
	private static final Integer NUMBER_OF_RECORDS = 3;

	private static ContentVersion createContent(String tags){
		ContentVersion cv = new ContentVersion();
		cv.TagCsv = tags;
		cv.ContentURL = 'test.com';
		cv.Sequence__c = 12;
		cv.Create_IC_Program_Material_Record__c = true;
		return cv;
	}

	private static ContentWorkspace gerLibrary(){
		return [SELECT Id, Name FROM ContentWorkspace LIMIT 1];
	}

	private static ContentWorkspaceDoc connectContenttoLibrary(Id libraryId, Id documentId){
		ContentWorkspaceDoc cwd = new ContentWorkspaceDoc();
		cwd.ContentWorkspaceId = libraryId;
		cwd.ContentDocumentId = documentId;
		return cwd;
	}

	private static PHSS_Program__c createProgram(String libraryName){
		PHSS_Program__c program = new PHSS_Program__c();
		program.Content_Library_Name__c = libraryName;
		return program;
	}


	@isTest static void afterUpdate_test() {
		ContentWorkspace library = gerLibrary();
		insert createProgram(library.Name);
		List<ContentVersion> contentVersions = new List<ContentVersion>();
		for(Integer i=0; i<NUMBER_OF_RECORDS; i++){
			contentVersions.add(createContent('Link, Instructor Bulletin'));
			contentVersions.add(createContent('Video, Participant'));
			contentVersions.add(createContent('Link, Material'));
			contentVersions.add(createContent(null));
		}
		insert contentVersions;
		Set<Id> contentVersionIds = new Set<Id>();
		for(ContentVersion cv: contentVersions){
			contentVersionIds.add(cv.Id);
		}
		List<ContentVersion> insertedContent = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN :contentVersionIds];
		List<ContentWorkspaceDoc> cwds = new List<ContentWorkspaceDoc>();
		for(ContentVersion cv: insertedContent){
			cwds.add(connectContenttoLibrary(library.Id, cv.ContentDocumentId));
		}
		Set<Id> contentDocumentIds = new Set<Id>();
		for(ContentVersion cv: insertedContent){
			contentDocumentIds.add(cv.ContentDocumentId);
		}
		Test.startTest();
		insert cwds;
		Test.stopTest();
		List<PHSS_Material__c> materials = [SELECT Id, Content_Library_Name__c, ContentWorkspaceID__c FROM PHSS_Material__c WHERE ContentVersionID__c IN :contentVersionIds];
		System.assertEquals(insertedContent.size(), materials.size(), 'Material records should be created for each content');
		for(PHSS_Material__c material: materials){
			System.assertEquals(library.Name, material.Content_Library_Name__c, 'Library name should be populated');
			System.assertEquals(library.Id, material.ContentWorkspaceID__c, 'Library name should be populated');
		}
	}

	@isTest static void cover_rest(){
		PHSS_ContentVersionHandler instance = new PHSS_ContentVersionHandler();
		instance.beforeInsert(new List<SObject>());
		instance.beforeUpdate(new Map<Id, SObject>(), new Map<Id, SObject>());
		instance.beforeDelete(new Map<Id, SObject>());
		instance.afterInsert(new Map<Id, SObject>());
		instance.afterDelete(new Map<Id, SObject>());
		instance.afterUndelete(new Map<Id, SObject>());
	}
}