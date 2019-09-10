public class SDRelatedListDocumentsController {
    private final String RELATED_LIST_DOCUMENT = 'Related List Document';
    public String parentId {get;set;}
    public Boolean allowEmail {get;set;}
    public Boolean allowCombineAll {get;set;}
    public Boolean emailedDocuments {get;set;}
    public Map<Id, SObject> childRecordMap {get;set;}
    public String whereClause {get;set;}
     
    public List<SDJobWrapper> sdocJobWrappers {
        get {
            List<SDJobWrapper> sdjwList = new List<SDJobWrapper>(); 
            List<SDOC__SDJob__c> relatedListDocJobs = [
                SELECT SDOC__Status_Link__c, SDOC__Oid__c, 
                SDOC__SDoc1__r.Id, SDOC__SDoc1__r.SDOC__Attachment_Name__c
                FROM SDOC__SDJob__c
                WHERE OwnerId=:UserInfo.getUserId()
                AND SDOC__Type__c=:RELATED_LIST_DOCUMENT
            ];
            for (SDOC__SDJob__c sdj : relatedListDocJobs) {
                sdjwList.add(
                    new SDJobWrapper(
                        sdj, childRecordMap.get(sdj.SDOC__Oid__c)
                    )
                );
            }
            return sdjwList;
        }
        set;
    }
    
    public class SDJobWrapper {
        public SDOC__SDJob__c job {get;set;}
        public SObject obj {get;set;}
        
        public SDJobWrapper(SDOC__SDJob__c job, SObject obj) {
            this.job = job;
            this.obj = obj;
        }
    }
    
    public void createSDocJobs() {
        delete [SELECT Id FROM SDOC__SDJob__c WHERE OwnerId=:UserInfo.getUserId()];
        List<SDOC__SDJob__c> sdJobs = new List<SDOC__SDJob__c>();
        childRecordMap = new Map<Id, SObject>();
        emailedDocuments = false;
    
        parentId = ApexPages.currentPage().getParameters().get('parentId');
        String childObjName = ApexPages.currentPage().getParameters().get('childObjName').toLowerCase();
        String lookupFieldName = ApexPages.currentPage().getParameters().get('lookupFieldName');
        String doclist = ApexPages.currentPage().getParameters().get('doclist');
        String allowCombineAllParam = ApexPages.currentPage().getParameters().get('allowCombineAll');
        allowCombineAll =  allowCombineAllParam == 'true' || allowCombineAllParam == '1';
        String whereClause = ApexPages.currentPage().getParameters().get('whereClause');
        
        String templateBaseObject; String fieldPrefix;
        if (childObjName == 'opportunitycontactrole') {
            templateBaseObject = 'Contact';
            fieldPrefix = 'Contact.';
        } else {
            templateBaseObject = childObjName;
            fieldPrefix = '';
        }

        lookupFieldName = lookupFieldName.toLowercase();
        lookupFieldName = lookupFieldName.replace('__c', '__r');
        if (lookupFieldName.endsWith('id')) {
            lookupFieldName = lookupFieldName.substring(0, lookupFieldName.length() - 2);
        }
        
        String childrenQuery 
            = 'SELECT ' + fieldPrefix + 'Name, ' + fieldPrefix + 'Id '
            + ' FROM ' + childObjName 
            + ' WHERE ' + lookupFieldName + '.Id =\'' + parentId + '\' ' ;

        String additionalFilters = ApexPages.currentPage().getParameters().get('additionalFilters');
        if (additionalFilters != null) childrenQuery += additionalFilters;

        for (SObject child : Database.query(childrenQuery)) {
            String oid;
            if (childObjName == 'opportunitycontactrole') {
                oid = String.valueOf(child.getSObject('Contact').get('Id'));
                childRecordMap.put(oid, child.getSObject('Contact'));
            } else {
                oid = child.Id;
                childRecordMap.put(oid, child);
            }
            SDOC__SDJob__c sdj = 
            new SDOC__SDJob__c(
                SDOC__Start__c=true,
                SDOC__Oid__c=oid,
                SDOC__ObjApiName__c=templateBaseObject,
                SDOC__SendEmail__c='0',
                SDOC__Doclist__c=doclist,
                SDOC__Type__c=RELATED_LIST_DOCUMENT
            );
            sdJobs.add(sdj);
        }
        
        insert sdJobs;
    }
    
    public Boolean jobsAreCompleted {
        get {
            Integer totalNumJobs = Database.countQuery(
                'SELECT COUNT()'
                + ' FROM SDOC__SDJob__c'
                + ' WHERE OwnerId = \'' + UserInfo.getUserId() + '\''
                + ' AND SDOC__Status__c'
                + ' IN(\'Selected\',\'0\',\'10\',\'20\',\'40\',\'60\','
                + '\'80\',\'90\',\'95\',\'Queued\',\'Completed\',\'Error\')'
            );
            Integer completedSize = Database.countQuery(
                'SELECT COUNT()'
                + ' FROM SDOC__SDJob__c'
                + ' WHERE OwnerId = \'' + UserInfo.getUserId() + '\''
                + ' AND SDOC__Status__c = \'Completed\''
            );

            return (completedSize + getErrorSize() == totalNumJobs) && totalNumJobs > 0;
        }
        set;
    }

    public Integer getErrorSize() {
        return Database.countQuery(
            'SELECT COUNT()'
            + ' FROM SDOC__SDJob__c'
            + ' WHERE OwnerId = \'' + UserInfo.getUserId() + '\''
            + ' AND SDOC__Status__c = \'Error\''
        );
    }
    
    public PageReference returnToParentRecord() {
        return new PageReference('/' + parentId);
    }
    
    public PageReference emailDocuments() {
        if (!emailedDocuments) {
            emailedDocuments = true;

            String aid = ApexPages.currentPage().getParameters().get('aid');
            String did = ApexPages.currentPage().getParameters().get('did');
            PageReference emailPage = new PageReference('/apex/SDOC__SDEmail');
            emailPage.setRedirect(true);
            if (aid != null && aid != '') {
                emailPage.getParameters().put('aid', aid);
            } 
            if (did != null && did != '') {
                emailPage.getParameters().put('did', did);
            }
            
            /* EMAIL SECTION A */
            /* Emails each document individually on a per-record basis.
            This occurs in the background, so the email body can't be edited in this case. */
            for (SDJobWrapper sdjw : sdocJobWrappers) {
                emailPage.getParameters().put('SDId', sdjw.job.SDOC__SDoc1__r.Id);
                if (!Test.isRunningTest()) {
                    emailPage.getContent();
                }
            }

            /* EMAIL SECTION B */
            /* UNCOMMENT THIS SECTION and COMMENT OUT EMAIL SECTION A
            if you want to include all documents in a single email and have
            the user be redirected to the email page (where they can edit the email body)
            when they click the email button. */
            /*String sdocIds = '';
            for (SDJobWrapper sdjw : sdocJobWrappers) {
                sdocIds += sdjw.job.SDOC__SDoc1__r.Id + ',';
            }
            sdocIds = sdocIds.substring(0, sdocIds.length() - 1); // remove last comma
            emailPage.getParameters().put('SDId', sdocIds);
            return emailPage;*/
        }
        return null;
    }

    private String combineAllType = ApexPages.currentPage().getParameters().get('combineAll');
    private String combinedDocUrl;
    public void combineIntoSingleDocument() {
        if (combineAllType == null) return;
        throwExceptionIfErrors();
        combineAllType = combineAllType.toLowerCase();

        List<String> sdocIds = new List<String>();
        for (SDJobWrapper sdjw : sdocJobWrappers) sdocIds.add(sdjw.job.SDOC__SDoc1__r.Id);
        String filters = 'WHERE OwnerId=\'' + UserInfo.getUserId() + '\' AND Id IN (\'' + String.join(sdocIds, '\',\'') + '\')';
        String combineAllOrderBy = ApexPages.currentPage().getParameters().get('combineAllOrderBy');
        if (combineAllOrderBy != null) filters += ' ORDER BY ' + combineAllOrderBy;
        combinedDocUrl = new List<String>( SDOC.SDJobTemplateController.combineSDocs(filters, 'PDF') )[0];
    }

    public void finishCombineAll() {
        if (combineAllType == 'file' || combineAllType == 'attachment') {
            String filename = sdocJobWrappers[0].job.SDOC__SDoc1__r.SDOC__Attachment_Name__c;
            Blob filebody = new PageReference(combinedDocUrl).getContent();
            // &combineall=true,file,attachment&autoRedirect=record
            if (combineAllType == 'file') {
                insert new ContentVersion(
                    Title=filename,
                    PathOnClient=filename,
                    VersionData=filebody,
                    FirstPublishLocationId=parentId
                );
            } else if (combineAllType == 'attachment') {
                insert new Attachment(
                    Name=filename,
                    Body=filebody,
                    ParentId=parentId
                );
            }
        }
    }

    private Boolean doFinishRedirect = false;

    public void redirectIfComplete() {
        if (!jobsAreCompleted) return;
        combineIntoSingleDocument();
        doFinishRedirect = true;
    }

    public PageReference finishRedirect() {
        if (!doFinishRedirect) return null;

        // PageReference.getContent() must be done in a separate transaction, 
        // hence splitting up redirectIfComplete and finishRedirect
        finishCombineAll();

        String autoRedirect = ApexPages.currentPage().getParameters().get('autoRedirect');
        if (autoRedirect == null) return null;
        throwExceptionIfErrors();
        autoRedirect = autoRedirect.toLowerCase();
        if (autoRedirect == 'record') return returnToParentRecord();
        else if (autoRedirect == 'combineall') return new PageReference(combinedDocUrl);
        else if (autoRedirect == 'email') return emailDocuments();
        else if (autoRedirect == 'email,record') { emailDocuments(); return returnToParentRecord(); }
        return null;
    }

    public void throwExceptionIfErrors() {
        if (getErrorSize() > 0) throw new SDException('Error: one or more S-Docs Jobs failed');
    }

    public class SDException extends Exception {}
}