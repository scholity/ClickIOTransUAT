global class cls_Opportunity_Line_Item_Wrapper implements Comparable{
    
    public OpportunityLineItem opportunityLineItem;
    
    public cls_Opportunity_Line_Item_Wrapper(OpportunityLineItem ol){
        this.opportunityLineItem = ol;
    }
    
    global Integer compareTo(Object compareTo) {
        cls_Opportunity_Line_Item_Wrapper comparateToOl = (cls_Opportunity_Line_Item_Wrapper) compareTo;
        
        if (comparateToOl.opportunityLineItem.Price_Variance__c == this.opportunityLineItem.Price_Variance__c) return 0;
        if (this.opportunityLineItem.Price_Variance__c > comparateToOl.opportunityLineItem.Price_Variance__c) return 1;
        return -1;
    }
}