/*******************************************************************
Name                : SmartAccountSearchExtension
Author              : Appirio Offshore (Urminder Vohra)
Date                : July 19, 2011
Last Modified       : July 1,2014
Last Modified By    : Kiril Minev
Changes Description : Added redirect call to prevent createAccount jscript method from sending the user to an i-frame and link and block page due to same_origin security policy    
 
*************************************************************************/
//
// Changed to without sharing so that users can see duplicates across the world
//
//public with sharing class SmartAccountSearchExtension {
public  class SmartAccountSearchExtension {
    
    //Search criteria fields
    public String accountNameToSeaarch {set;get;}
   // public String shippingCountryToSearch {set;get;}
    
    
    public integer searchCount{set; get;}
    public string searchStatus{set; get;}
    public string sortField{set;get;}
    private string previousSortField;
    private string sortOrder;
      
    public boolean isAsc{set; get;}
    public Integer showingFrom{get;set;}
    public Integer showingTo{get;set;}
    public string query;
    
    public boolean showAccountButton{set; get;}
    public boolean hasNext{get;set;}
    public boolean hasPrevious{get;set;}
    public String requestedPage {get;set;}
    
    public integer totalResults {set; get;}
    
    public Integer totalPage {set; get;}
    //public transient List<Account> accounts {get;set;}
    private static final Integer DEFAULT_RESULTS_PER_PAGE = 20;  
    private static final string SEARCH_TYPE = ' and ';
    private static final string DEFAULT_SORT_ORDER = ' ASC ';
    private static final string DEFAULT_SORT_FIELD = 'Name';
    
    private ApexPages.StandardSetController accountResults{get;set;}
    //Constructor
    public SmartAccountSearchExtension(ApexPages.StandardController controller) {
        resetSearchStatus();
    }

    //Constructor
    public SmartAccountSearchExtension(){
        resetSearchStatus();
    }
    
    //set to default status of page
    public void resetSearchStatus(){
        //Reset account fields
        showAccountButton = false;
        accounts = new List<Account>();
        searchCount = 0;
        searchStatus = '';
        sortOrder = DEFAULT_SORT_ORDER;
        sortField = DEFAULT_SORT_FIELD;
        previousSortField = DEFAULT_SORT_FIELD;
        accountNameToSeaarch = '';
       // shippingCountryToSearch ='';
        isAsc = true;
        hasPrevious = false;
        hasNext = false; 
       
    }
    public transient List<Account> accounts{get;set;}
    public List<Account> getAccounts(){
       return accounts;       
    }
   
   public PageReference redirectToAccountPage(){
        
        String pageRecordTypeId = ApexPages.currentPage().getParameters().get('RecordType');
        
        if (pageRecordTypeId != null && pageRecordTypeId != '')
        {
            return new PageReference('/../001/e?retURL=/apex/SmartAccountSearch&nooverride=1&RecordType=' + pageRecordTypeId + '&acc2=' + this.accountNameToSeaarch);   
        }
        else
        {
            Schema.DescribeSObjectResult dsr = Account.SObjectType.getDescribe();
            Schema.RecordTypeInfo defaultRecordType;
            
            for(Schema.RecordTypeInfo rti : dsr.getRecordTypeInfos())
            {
                if(rti.isDefaultRecordTypeMapping())
                {
                    defaultRecordType = rti;
                }
            }
            return new PageReference('/../001/e?retURL=/apex/SmartAccountSearch&nooverride=1&RecordType=' + defaultRecordType.recordtypeid + '&acc2=' + this.accountNameToSeaarch);
        }

        return new PageReference('/../001/e?retURL=/apex/SmartAccountSearch&nooverride=1&RecordType=012d000000097TF&acc2=' + this.accountNameToSeaarch);
        
   } 

    public PageReference cancel(){
        return new PageReference('/001/o');  
    }
    
    public String findSearchCondition(String query){
    accountNameToSeaarch=String.escapeSingleQuotes(accountNameToSeaarch);
     accountNameToSeaarch = accountNameToSeaarch.replace('*','');
     if(accountNameToSeaarch != null && accountNameToSeaarch != ''){
          if(query.toUpperCase().contains('WHERE')){
            query += ' and Name like \'%' + accountNameToSeaarch.Trim() + '%\'';
          }else{
            query += ' where Name like \'%' + accountNameToSeaarch.Trim() +  '%\'';
          }
      }
     /* if(shippingCountryToSearch != null && shippingCountryToSearch != ''){
          if(query.toUpperCase().contains('WHERE')){
            query += ' and ShippingCountry like \'%' + shippingCountryToSearch.Trim() + '%\'';
          }else{
            query += ' where ShippingCountry like \'%' + shippingCountryToSearch.Trim() + '%\'';
          }
      }*/
      system.debug('query======'+query );
    return query;
  }
  
  
    
    
    public void performSearch() {
        searchAccount();
        System.debug('Account list ::::::::::::' + accounts);
    }
    
    //method to search account and make list according to pagesize
    private void searchAccount(){
        showAccountButton = true;
        //query = 'Select isActive, Region__c, Phone, Name, ERP_Customer_Code__c, Category__c,Owner.Name,BillingCountry From Account';
        query = 'Select  Name, Owner.Name,BillingStreet, BillingCity, BillingState, BillingPostalCode, Parent.Name From Account';  
        query = findSearchCondition(query);
        System.debug('QUERY+++++++++:' + query);
        query += ' order by ' + sortField + sortOrder + ' nulls last limit 2000'  ;
          
        try{
            accounts = new List<Account>();
            accountResults = new ApexPages.StandardSetController(Database.query(query));
            accountResults.setPageSize(DEFAULT_RESULTS_PER_PAGE);
            accounts = accountResults.getRecords();
            searchCount = accountResults.getResultSize();
        }catch(Exception e){
            searchCount = 0;
        }  
        if (searchCount  == 0){
//            searchStatus = 'No matching results found.';
              searchStatus = Label.No_matching_results;
        }
        requestedPage = String.valueOf(accountResults.getPageNumber());
        showingFrom = 1;
        
        
        totalResults = 0;
        for (List<Sobject> recordBatch:Database.query(query))  {
             totalResults = totalResults + recordBatch.size();
         }
        totalPage = 0;
        totalPage = totalResults / accountResults.getPageSize() ; 
        if (totalPage * accountResults.getPageSize() < totalResults){
          totalPage++;
        }
        
        
        
        if(searchCount < accountResults.getPageSize()) {
            showingTo = searchCount;
        } else {
            showingTo = accountResults.getPageSize();
        }
        if(accountResults.getHasNext()) {
            hasNext = true;
        } else {
            hasNext = false;
        }
        hasPrevious = false;
      
    }
    
    
    public PageReference nextAccountPage(){
        
        if(accountResults.getHasNext()) {
            accounts = new List<Account>();
            accountResults.next();
            accounts = accountResults.getRecords();
            showingFrom = showingFrom + accountResults.getPageSize();
            showingTo =  showingTo + accounts.size();
            if(accountResults.getHasNext()) {
                hasNext = true;
            } else {
                hasNext = false;
            }
            hasPrevious = true; 
        }
        requestedPage = String.valueOf(accountResults.getPageNumber());
        return null;
    }
    
   
  
    public PageReference previousAccountPage(){
        if(accountResults.getHasPrevious()) {
            showingTo =  showingTo - accounts.size();
            accounts = new List<Account>();
            accountResults.previous();
            accounts = accountResults.getRecords();
            showingFrom = showingFrom - accountResults.getPageSize();
            hasNext = true;
            if(accountResults.getHasPrevious()) {
                hasPrevious = true;
            } else {
                hasPrevious = false;
            }
        }
        requestedPage = String.valueOf(accountResults.getPageNumber());  
        return null;
    }
    
   
  
    public PageReference requestedAccountPage(){
        
        boolean check = pattern.matches('[0-9]+',requestedPage); 
        Integer pageNo = check? Integer.valueOf(requestedPage) : 0;
        if(pageNo == 0 || pageNo > totalPage){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Invalid page number.')); 
            return null;       
        }   
        accountResults.setPageNumber(pageNo);
        accounts = accountResults.getRecords();
        if(accountResults.getHasPrevious()) {
            hasPrevious = true;
         } else {
            hasPrevious = false;
         }
         if(accountResults.getHasNext()) {
            hasNext = true;
        } else {
            hasNext = false;
        }
        showingFrom  = (pageNo - 1) * accountResults.getPageSize() + 1;
       
        showingTo = showingFrom + accounts.size() - 1;
        if(showingTo > totalResults) {
            showingTo = totalResults;
        }
        return null;
    }
    
    
  
    //used to sort
    public void sortData(){
        if (previousSortField.equals(sortField)){
          isAsc = !isAsc;  
        }else{
            isAsc = true;
        }   
        sortOrder = isAsc ? ' ASC ' : ' DESC ';
        previousSortField = sortField;
        searchAccount();
    }
    
    
   

}