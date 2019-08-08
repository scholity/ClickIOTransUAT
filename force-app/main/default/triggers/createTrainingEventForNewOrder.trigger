trigger createTrainingEventForNewOrder on Order (after insert, after update) {
    List <Training_Events__c> newTrainingEvents = new List <Training_Events__c>();
    
    // Collect Order Ids
    List <Id> orderIds = new List <Id>();
    for (Order o : trigger.new) {
        orderIds.add(o.Id);
    }
        
    // Validate Opportunity for New Order is Closed and Won
    Map <Id, Id> orderMap = new Map <Id, Id>();
    for (Order o : trigger.new) {
        if (o.OpportunityId != null) orderMap.put(o.Id, o.OpportunityId);
    }
    
    List <Opportunity> orderOpportunityList = [Select Id, Name, AccountId, StageName From Opportunity Where Id in :orderMap.values()];
    Map <Id, Opportunity> orderOpportunityMap = new Map <Id, Opportunity>();
    for (Opportunity o : orderOpportunityList){
        orderOpportunityMap.put(o.Id, o);
    }
    
    for (Id orderId : orderMap.keySet()) {
        Id orderOpportunityId = orderMap.get(orderID);
        Opportunity orderOpportunity = orderOpportunityMap.get(orderOpportunityId);
        if (orderOpportunity.StageName == 'Closed Won') {
  
            // Validate that a Training Event Does Not Yet Exist for this Order
            List <Training_Events__c> opportunityTrainingEvents = new List <Training_Events__c>();
            opportunityTrainingEvents = [Select Id From Training_Events__c Where Opportunity__c = :orderOpportunityId];
            if (opportunityTrainingEvents != null && opportunityTrainingEvents.size() > 0) continue;
    
            // Create a New Training Event for First Order Item Representing an FS or AP Class
            List <OrderItem> orderItemList = new List <OrderItem>();
            
            orderItemList = [Select Id, OrderId, OrderItemNumber, PricebookEntry.Product2.ProductCode,
                PricebookEntry.Product2.Name From OrderItem Where OrderId In :orderIds Order By OrderItemNumber];
            
            for (OrderItem oi : orderItemList) {
                String productCodePrefix = oi.PricebookEntry.Product2.ProductCode.substring(0,2);
                if ('FSAP'.contains(productCodePrefix)) {
                
                    Training_Events__c te = new Training_Events__c();
                    te.Opportunity__c = orderOpportunity.Id;
                    te.Account__c = orderOpportunity.AccountId;
                    te.Course_Id__c = oi.PricebookEntry.Product2.ProductCode;
                    te.Course_Name__c = oi.PricebookEntry.Product2.Name;
                    newTrainingEvents.add(te);
                    
                    break;
                }
            }
        }
    }

    try {
        insert newTrainingEvents;
    }
    catch (Exception e)
    {
        e.getMessage();
    }
    
}