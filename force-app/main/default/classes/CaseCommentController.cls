public with sharing class CaseCommentController {

	
	private static String ERROR_MESSAGE_PREFIX = 'Error Occured: ';
    public ApexPages.StandardController standardController {set; get;}
    public CaseCommentModel caseCommentModel {get; set;}

    
    public CaseCommentController(ApexPages.StandardController controller) {
        
        this.standardController = controller;
        this.caseCommentModel = new CaseCommentModel();
        this.caseCommentModel.loadCaseCommentTemplatesMap();
        
    }
    
    /*
    * Purpose: Upon ajax request set comment body in Case Comment Body text area
    */
    public PageReference insertCommentTemplate() {
        
        if (this.caseCommentModel != null && 
                                        caseCommentModel.caseCommentTemplatesMap != null && 
                                        String.isNotBlank(this.caseCommentModel.selectedTemplate) &&
                                        this.caseCommentModel.selectedTemplate != 'None') {
                
            List<Case_Comment_Template__c> templatesByGroup = caseCommentModel.caseCommentTemplatesMap.get(caseCommentModel.selectedCommentTemplateCategory);
            
            for (Case_Comment_Template__c cct :templatesByGroup ) {
                    
                if (this.caseCommentModel.selectedTemplate.equalsIgnoreCase(cct.Id)) {
                    this.caseCommentModel.caseCommentSobj.commentBody = cct.Comment_Body__c;
                    break;
                }
            }
        }
        
        return null;
    }
    
    /*
    * Purpose: Upon ajax refresh select tempaltes based on the selected template group
    */
    public PageReference selectTemplatesForCategory() {
        
        if (caseCommentModel != null && caseCommentModel.caseCommentTemplatesMap != null) {
                
            List<Case_Comment_Template__c> tempTemplates = caseCommentModel.caseCommentTemplatesMap.get(caseCommentModel.selectedCommentTemplateCategory);
            
            if (tempTemplates != null && tempTemplates.size() > 0) {
                    
                    this.caseCommentModel.templates = new List<SelectOption>();
                    
                    for (Case_Comment_Template__c cct :tempTemplates) {
                    this.caseCommentModel.templates.add(new SelectOption(cct.Id, cct.Name));      
                    }
            } else {
                    this.caseCommentModel.templates = new List<SelectOption>();
                    this.caseCommentModel.templates.add(new SelectOption('None','None'));
            }
        }
        return null;
    }
    
    public PageReference saveComment() {
        
        try {
			
			if (String.isBlank(this.caseCommentModel.caseCommentSobj.CommentBody)) {
				
				ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, ERROR_MESSAGE_PREFIX + 'Case Comment field must have text value!');
				ApexPages.addMessage(message);
				return null;
				
			}else {
			
				Case relatedCase = (Case)this.standardController.getRecord();
				
	            this.caseCommentModel.caseCommentSobj.ParentId = this.standardController.getRecord().id;
	            insert this.caseCommentModel.caseCommentSobj;
	            
	            update relatedCase;
	            
	            string strCasePage = '/' + this.standardController.getRecord().id;
	            //ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Info, s));
	            return new Pagereference(strCasePage );
			}
            
        }catch (Exception ex) {
            System.debug('*** Exception:' + ex);
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,ERROR_MESSAGE_PREFIX + ex.getMessage());
			ApexPages.addMessage(message);
            ExLog.log(ex);
        }
        return null;
    }


        /*
        *       Purpose: Inner Class to present model data for vforce page
        */
    public class CaseCommentModel {
       
       public CaseCommentModel() {
            
            caseCommentSobj = new CaseComment();
            
            templates = new List<SelectOption>();
            templates.add(new SelectOption('None', 'None'));
       }
       
        public CaseComment caseCommentSobj{
            get;
            set;
        }
        
        // String = Comment Template Category, List = Corresponding Comment Template Objects
        public Map<String, List<Case_Comment_Template__c>> caseCommentTemplatesMap {set; get;} 

        public String selectedCommentTemplateCategory {set; get;}
        
        public String selectedTemplate {set; get;}
                            
        public List<SelectOption> commentTemplateCategory{
            set;
            
            get{
                List<SelectOption> caseTemplateCategoryList = null;
                    
                try {
                    
                    Schema.DescribeFieldResult fieldResult = Case_Comment_Template__c.Category__c.getDescribe();
                    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                    
                    caseTemplateCategoryList = new List<SelectOption>();
                    
                    caseTemplateCategoryList.add(new SelectOption('None', 'None'));
                    
                    for( Schema.PicklistEntry f : ple){
                           caseTemplateCategoryList.add(new SelectOption(f.getLabel(), f.getValue()));
                    }  
                        
                } catch (Exception ex) {
                    ExLog.log(ex);
                    ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, ERROR_MESSAGE_PREFIX + ex.getMessage());
					ApexPages.addMessage(message);
                }
                
                return caseTemplateCategoryList;
            }
        }
        
        public List<SelectOption> templates{
            
            set;
            get;
        }
        
        public void loadCaseCommentTemplatesMap() {
            
            try {
                
                List<Case_Comment_Template__c> commentTemplates = [SELECT Id, Comment_Body__c, Name, Category__c FROM Case_Comment_Template__c 
                                                     WHERE Active__c = true Order By Category__c];
                                                     
                if (commentTemplates != null && commentTemplates.size() > 0) {  
                    
                    caseCommentTemplatesMap = new Map<String, List<Case_Comment_Template__c>>();                                 
                    String templateCategoryInprocess = commentTemplates[0].Category__c;
                    
                    List<Case_Comment_Template__c> caseCommentsListMapItem = new List<Case_Comment_Template__c>();                                   
                    caseCommentsListMapItem.add(commentTemplates[0]);
                    
                    for (Integer i=1; i <commentTemplates.size(); i++) {
                    
                        if (commentTemplates[i].Category__c.equalsIgnoreCase(templateCategoryInprocess)) {
                            caseCommentsListMapItem.add(commentTemplates[i]);
                        } else {
                            caseCommentTemplatesMap.put(templateCategoryInprocess, caseCommentsListMapItem);
                            
                            templateCategoryInprocess = commentTemplates[i].Category__c;
                            caseCommentsListMapItem = new List<Case_Comment_Template__c>();
                            
                            caseCommentsListMapItem.add(commentTemplates[i]);
                        }
                    }
                    //Add the last group
                    caseCommentTemplatesMap.put(templateCategoryInprocess, caseCommentsListMapItem);
                    
                }
                
            }catch(Exception ex){
                ExLog.log(ex);
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, ERROR_MESSAGE_PREFIX + ex.getMessage());
				ApexPages.addMessage(message);
            }
        }   
            
    }
    
    

}