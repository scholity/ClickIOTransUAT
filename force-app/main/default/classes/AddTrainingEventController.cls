public with sharing class AddTrainingEventController
{
    private final OpportunityLineItem oli;
    
    public Training_Events__c trainingEvent{get;set;}
    
    public AddTrainingEventController()
    {
        oli = [SELECT   Id,
                        OpportunityId,
                        Product2Id,
                        ProductCode,
                        Product2.ProductCode,
                        Product2.Name,
                        Opportunity.AccountId,
                        UnitPrice
               FROM     OpportunityLineItem
               WHERE    Id = : ApexPages.currentPage().getParameters().get('id')];
               
        trainingEvent = new Training_Events__c();
        
        trainingEvent.SCC_Code__c               = '';
        trainingEvent.Scheduling_Status__c      = '';
        trainingEvent.Course_ID__c              = oli.Product2.ProductCode;
        trainingEvent.Void_Reason__c            = '';
        trainingEvent.Course_Name__c            = oli.Product2.Name;
        trainingEvent.TE_Owner__c               = UserInfo.getUserId();
        trainingEvent.Account__c                = oli.Opportunity.AccountId;
        trainingEvent.Times_Rescheduled__c      = '';
        trainingEvent.Opportunity__c            = oli.OpportunityId;
        trainingEvent.Rescheduling_Fee__c       = false;
        trainingEvent.Billing_Account__c        = null;
        trainingEvent.Region__c                 = null;
        trainingEvent.Sales_Price__c            = oli.UnitPrice;
        trainingEvent.Course_Order_Status__c    = 'Schedule';
        
    }
    
    public Training_Events__c getTrainingEvent ()
    {
        return trainingEvent;
    }
    
    public PageReference save()
    {
        Training_Events__c te = new Training_Events__c();
        
        te.SCC_Code__c              = trainingEvent.SCC_Code__c;
        te.Scheduling_Status__c     = trainingEvent.Scheduling_Status__c;
        te.Course_ID__c             = trainingEvent.Course_ID__c;           //oli.Product2.ProductCode;
        te.Void_Reason__c           = trainingEvent.Void_Reason__c;
        te.Course_Name__c           = trainingEvent.Course_Name__c;         //oli.Product2.Name;
        te.TE_Owner__c              = trainingEvent.TE_Owner__c;
        te.Account__c               = trainingEvent.Account__c;             //oli.Opportunity.AccountId;
        te.Times_Rescheduled__c     = trainingEvent.Times_Rescheduled__c;
        te.Opportunity__c           = trainingEvent.Opportunity__c;         //oli.OpportunityId;
        te.Rescheduling_Fee__c      = trainingEvent.Rescheduling_Fee__c;
        te.Billing_Account__c       = trainingEvent.Billing_Account__c;
        te.Region__c                = trainingEvent.Region__c;
        te.Sales_Price__c           = trainingEvent.Sales_Price__c;
        te.Course_Order_Status__c   = trainingEvent.Course_Order_Status__c;
        
        insert te;
    
        PageReference redirectSuccess = new ApexPages.StandardController(te).view();
        return (redirectSuccess);
    }
    
    public PageReference cancel()
    {
        PageReference redirectSuccess = new ApexPages.StandardController(oli).view();
        return (redirectSuccess);
    }
}