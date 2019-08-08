public class SubmitCaseController {
  
  public Case c { get; set; }
  public String invoiceNumber {set; get;}
  public String lmsOrgId {set; get;}
  public String state {set; get;}
  public String description {set; get;}
  public String companyOrganization {set; get;}
  public String salesRepEmail {set; get;}
  public String billingContactFirstName {set; get;}
  public String billingContactLastName {set; get;}
  public String billingContactEmail {set; get;}
  public String billingContactPhone {set; get;}
  public String billingContactExtension {set; get;}  
  public String personToContactFirstName {set; get;}
  public String personToContactLastName {set; get;}
  public String receiveOpenCaseConfirmation {set; get;}
    public String PHSSStaffPhone {set; get;}
  public String InvoiceRecordTypeId{set;get;}
  
  public Attachment attachment {
    get {
        if (attachment == null)
          attachment = new Attachment();
        return attachment;
      }
    set;
    }
    @TestVisible
    private Boolean isReceiveOpenCaseNotificaiton() {
      
      try {
        system.debug('receiveOpenCaseConfirmation>>>'+receiveOpenCaseConfirmation);
        if (!String.isEmpty(this.receiveOpenCaseConfirmation)) {
          
          if (this.receiveOpenCaseConfirmation.equalsIgnoreCase('yes')) {
            return true;
          } else if (this.receiveOpenCaseConfirmation.equalsIgnoreCase('no')) {
            return false;
          } else {
            return false;
          }
          
        } else {
          return false;
        }
        
      }catch (System.Exception ex) {
        System.Debug('*** Exception in isReceiveOpenCaseNotificaiton, message: ' + ex.getMessage());
        return false;
      }
    } 
    
    public List<SelectOption> customerReceivesNotificaitonOptions{
      get{
        List<SelectOption> tempOptions = new List<SelectOption>();
        
        tempOptions.add(new SelectOption('None', 'None'));
        tempOptions.add(new SelectOption('Yes', 'Yes'));
        tempOptions.add(new SelectOption('No', 'No'));
        
        return tempOptions;
      }
        set{}
    }
    
  public String webRequestType {set; get;}
  
  public List<SelectOption> webRequestTypeOptions{
    set;
    
    get{
      try {
      
        Schema.DescribeFieldResult fieldResult = Case.Billing_Web_Request_Type__c.getDescribe();
           
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            
            this.webRequestTypeOptions = new List<SelectOption>();
            
            this.webRequestTypeOptions.add(new SelectOption('None', 'None'));
            
            for( Schema.PicklistEntry f : ple){
                   webRequestTypeOptions.add(new SelectOption(f.getLabel(), f.getValue()));
            } 
            
            return webRequestTypeOptions;
            
      }catch(System.Exception ex) {
        System.Debug('*** Exception in getWebRequestTypeOptions, message: ' + ex.getMessage());
        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL, ex.getMessage());
        return null;
        
      }  
    }
  }
    
  public List<SelectOption> stateOptions{
    set;
    get{
      try {
        Schema.DescribeFieldResult fieldResult = Case.State__c.getDescribe();
           
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            
            this.stateOptions = new List<SelectOption>();
            
            this.stateOptions.add(new SelectOption('None', 'None'));
            
            for( Schema.PicklistEntry f : ple){
                 stateOptions.add(new SelectOption(f.getLabel(), f.getValue()));
            } 
            
            return stateOptions;
            
      }catch (System.Exception ex) {
        System.Debug('*** Exception in getstateOptions, message: ' + ex.getMessage());
        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL, ex.getMessage());
        return null;
      }
    }
  }

  public SubmitCaseController() {
    c = new Case();
  }
  
  //todo: add error messages to page
  public PageReference submitCase() {
    
    try {
    
    Invoicing_Case_RecordType__c CustomSet = null;
    List<Account>  AccNames = [SELECT id,SABA_LMS_Code__c,CFS_Account_Number_1__c from Account where SABA_LMS_Code__c =: lmsOrgId OR CFS_Account_Number_1__c =: lmsOrgId LIMIT 1];
    if(InvoiceRecordTypeId == null || InvoiceRecordTypeId == ''){
        CustomSet = [Select Invoicing_Case_RecordType_Id__c from Invoicing_Case_RecordType__c LIMIT 1] ; 
        InvoiceRecordTypeId  = CustomSet.Invoicing_Case_RecordType_Id__c;
        }
        
      Case c = new Case(Company_Name__c = companyOrganization,                    
                  Type = 'Invoicing', 
                  Origin = 'Web to Case', 
                  Invoice_Number__c = invoiceNumber, 
                  Customer_ID__c = lmsOrgId, 
                  RecordTypeId = InvoiceRecordTypeId,
                  //RecordTypeId = '012d000000097TD',//service case, todo: add to custom setting
                  State__c = state, 
                  SuppliedName = personToContactFirstName + ' ' + personToContactLastName,
                  SuppliedEmail = salesRepEmail,
                  SuppliedPhone = PHSSStaffPhone,
                  //Billing_Sale_Rep_Web_Form_Request__c = salesRepEmail,
                  Receives_Billing_Open_Case_Notification__c = isReceiveOpenCaseNotificaiton(),
                  Description = //'PHSS Staff Email Address: ' + salesRepEmail + '\n' +
                                       // 'PHSS Staff Phone #: ' + PHSSStaffPhone + '\n' +
                                        'Billing Contact Name: ' + billingContactFirstName + ' ' + billingContactLastName + '\n' +
                                        'Billing Contact Phone #: ' + billingContactPhone + '\n' +
                                        'Billing Contact Email Address #: ' + billingContactEmail + '\n\n' +
                              
                          //'Person To Contact About this Problem: ' + this.personToContactFirstName + ' ' + this.personToContactLastName + '\n\n' 
                          + description,
                  Billing_Web_Request_Type__c = webRequestType,
                  Subject = webRequestType);
                  
                  if(AccNames.size() > 0)
                      c.AccountId = AccNames[0].id;
      
      System.Debug('*** Case to be submitted: ' + c);
      
      Boolean validationFormFailed = false;
      
      if (String.isEmpty(c.Billing_Web_Request_Type__c) || c.Billing_Web_Request_Type__c.toLowerCase() == 'none') {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Request Type field is required!'));
        validationFormFailed = true;
      }
      
      if (String.isEmpty(c.State__c) || c.State__c.toLowerCase() == 'none') {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'State field is required!'));
        validationFormFailed = true;
      }
      
      if (!validationFormFailed) {
        insert c;
        
        if (this.attachment != null && this.attachment.name != null) {
          uploadAttachment(c.Id);
        }
      } else {
        return null;
      }
      
    }catch (System.Exception ex) {
      ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL, ex.getMessage());
      System.Debug('*** Exception in submitCase, message: ' + ex.getMessage());
      return null;
    }
    
    System.Debug('*** now redirecting to thankyou, baseUrl: ' + Site.getBaseUrl());
    return new PageReference('https://arcliveagent.secure.force.com/thankyou');//todo: change with a thank you page
  }
  
  public void uploadAttachment(String caseId) {
    
      this.attachment.OwnerId = UserInfo.getUserId();
      this.attachment.ParentId = caseId; // the record the file is attached to
      this.attachment.IsPrivate = false;
  
      try {
        insert attachment;
      } catch (DMLException e) {
          ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment'));
      } finally {
        attachment = new Attachment(); 
      }
    }
  
}